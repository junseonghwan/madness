## Calculating the MC transition model
library(RSQLite)
library(plyr)
source("scripts/functions.r")

## parameters from regression
intercept <- -0.72684039
slope <- 0.05751562
hAdj <- 0

## Function calculates the probability rxH from the paper
RXH <- function(intercept, slope, pointDiff, hAdj)
{
  x <- pointDiff + hAdj
  y <- exp( intercept + slope * x) / (1 + exp( intercept + slope * x))
  return(y)
}

sqlite    <- dbDriver("SQLite")
ncaaDB1 <- dbConnect(sqlite,"data/ncaa.db")
dbListTables(ncaaDB1)

game_data <- get_train_data(ncaaDB1, 2012)

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

## Create the transition matrix
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

eigenSystem <- eigen(t(trans))
ranks <- eigenSystem$vectors[ ,1] ## assumes the first eigenvector corresponds to eigenvalue 1!! 
if (abs(eigenSystem$values[1] - 1) > 0.001)
  stop("Eigenvalue error")

## sort the ranks vector
sortInd <- sort.int(abs(ranks), index = T)$ix
rankDf <- data.frame(rank = 1:nTeams, team_id = ids[sortInd])
teamIds <- dbGetQuery(ncaaDB1, "Select team_id, team_name from team_mappings_2012")
rankFinal <- join(rankDf, teamIds, by = "team_id")

write.csv(rankFinal, file = "data/LRMCRanking2012.csv", row.names = F)

