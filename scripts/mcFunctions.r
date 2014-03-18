## Function calculates the probability rxH from the paper
RXH <- function(intercept, slope, pointDiff, hAdj)
{
  x <- pointDiff + hAdj
  y <- exp( intercept + slope * x) / (1 + exp( intercept + slope * x))
  return(y)
}

## Create the transition matrix
main<-function(intercept, slope, hAdj, year)
{
  sqlite  <- dbDriver("SQLite")
  ncaaDB1 <- dbConnect(sqlite,"data/ncaa.db")
  dbListTables(ncaaDB1)
  
  game_data <- get_train_data(ncaaDB1, year)
  
  ## These are the ids to match off of
  ids <- intersect(game_data$away_team_id, game_data$home_team_id)
  ids <- ids[-which(ids == 0)]
  
  ## Create a dataframe to store all of the games played by each team
  ## will contain sums over both home and away games played
  nTeams <- length(ids)
  nGamesPerTeam <- NULL
  for (i in 1:nTeams)
  {
    df <- data.frame(id = ids[i], nGames = sum(1 * (game_data$away_team_id == ids[i])) + sum(1 * (game_data$home_team_id == ids[i])))
    nGamesPerTeam <- rbind(nGamesPerTeam, df)
  }
  
  ## Drop any teams who played less than gameCutOff games
  gameCutOff <- 25
  ids <- intersect(ids, nGamesPerTeam[which(nGamesPerTeam$nGames > gameCutOff),1])
  keepIds <- which(game_data$home_team_id %in% ids)

  nTeams <- length(ids) ## differs because the teams who never play will not be ranked

  ## Warning: Overwrite gamedata to only contain useful ids
  game_data <- game_data[keepIds, ]
  
  trans <- matrix(0, nrow = nTeams, ncol = nTeams)
  
  for (i in 1:nTeams)
  {
    homeGames <- game_data[which(game_data$home_team_id == ids[i]), ]
    awayGames <- game_data[which(game_data$away_team_id == ids[i]), ]
    ni <- as.numeric(subset(nGamesPerTeam, id == ids[i])[2])
    for (j in 1:nTeams)
    {
      if (i != j)
      {
        homeGamesAj <- homeGames[which(homeGames$away_team_id == ids[j]),]
        awayGamesAj <- awayGames[which(awayGames$home_team_id == ids[j]),]
        ptHG <- homeGamesAj$home_team_pts - homeGamesAj$away_team_pts
        ptAG <- awayGamesAj$home_team_pts - awayGamesAj$away_team_pts
        rxH <- sum(RXH(intercept, slope, ptHG, hAdj))
        rxR <- sum(1 - RXH(intercept, slope, ptAG, hAdj))  
        trans[i, j]  <- (rxH + rxR) * ( 1 / ni)
      }
    }
  }
  ## Fill in diagonal
  diag(trans)  <- 1 - rowSums(trans)
  ranks<-get_rankings(trans, nTeams, ids, ncaaDB1)
  return(ranks)
}

## sort the ranks vector
get_rankings<-function(trans, nTeams, ids, ncaaDB1)
{
  eigenSystem <- eigen(t(trans))
  ranks <- eigenSystem$vectors[ ,1] ## assumes the first eigenvector corresponds to eigenvalue 1!! 
  if (abs(eigenSystem$values[1] - 1) > 0.001)
    stop("Eigenvalue error")
  
  sortInd <- sort.int(abs(ranks), index = T)$ix
  rankDf <- data.frame(rank = 1:nTeams, team_id = ids[sortInd])
  teamIds <- dbGetQuery(ncaaDB1, "Select team_id, team_name from team_mappings_2012")
  rankFinal <- join(rankDf, teamIds, by = "team_id")
  return(rankFinal)
}

cv<-function(year, hh, fitCoef)
{
  ## parameters from regression
  intercept <- fitCoef[1]
  slope <- fitCoef[2]
  
  sqlite    <- dbDriver("SQLite")
  ncaaDB1 <- dbConnect(sqlite,"data/ncaa.db")
  
  # not all of these games are tournament games
  test_data <- get_test_data_wIDS(ncaaDB1, year)
  
  ## For each of these games we need a list of winners and losers
  ## Easiest way is to likely have an indicator if the home team won
  ## then match to ranks and determine probability
  
  # do cross-validation on the testing data to find the optimal h
  best<-0
  h_opt<-0
  for (h in hh)
  {
    ranked<-main(intercept, slope, h, year)

    len <- length(test_data$testY)

    sim <- matrix(0, nrow = len, ncol = 1)
    for (i in 1:len)
    {
      sim[i] <- (which(ranked$team_id == test_data$ids[i, 1]) < which(ranked$team_id == test_data$ids[i, 2]))
    }
    
    predict <- sum(1 * (sim == test_data$testY)) / len
    print(paste(predict, h, sep=", "))
    if (predict > best)
    {
      best <- predict
      h_opt <- h
    }
  }
  return(c(h_opt, best))
}
