## Running the logistic regression

library(RSQLite)
library(plyr)
source("scripts/functions.r")

sqlite    <- dbDriver("SQLite")
ncaaDB1 <- dbConnect(sqlite,"data/ncaa.db")
dbListTables(ncaaDB1)

game_data <- get_train_data(ncaaDB1, 2012)

## These are the ids to match off of
ids <- intersect(game_data$away_team_id, game_data$home_team_id)

## remove id 0
ids <- ids[-which(ids == 0)]

## Only care about games which occured with two div I teams
homeIds <- game_data$home_team_id
awayIds <- game_data$away_team_id

ind <- (homeIds %in% ids) & (awayIds %in% ids) ## index set

homeIds <- homeIds[ind]
awayIds <- awayIds[ind] 

if( length(unique(homeIds)) != length(unique(awayIds)))
  stop("Error in team data, differing no. of teams")

if( length(homeIds) != length(awayIds))
  stop("Error in team data, non-matching teams in each game")

nIds <- length(ids)

## Annoying that the team ids are not dense in positive integers (c.f. plot(sort(homeIds))) 
## To avoid extremly large matrix we use an isomorphism 

## Generate an nIds * nIds matrix 
## M(i, j) = # of times home team i played away team j
## Team pairs for the regression are those teams where the following element relation holds
## (i, j) , (j, i) >= 1
M <- matrix(0, nrow = nIds, ncol = nIds)
nGames <- length(homeIds)
for (i in 1:nGames)
{
  hT <- which(ids == homeIds[i])
  aT <- which(ids == awayIds[i])
  
  M[hT, aT]  <-  min(M[hT, aT] + 1, 1) ##only care about the first game, not any of the subsequent games at home
  
}

## (i, j) , (j, i) >= 1 <=> M + M' >= 2
gameInd <- which(upper.tri(M, diag = F) & (M + t(M) >= 2), arr.ind = T)

## How sparse is this? 
plot(gameInd)

## Each pair in this gameInd corresponds to the index of an away team and a home team who have played each other at least 
## twice where both teams have had an opportunity to play at home. 
homeGamesPaired <- ids[gameInd[ ,1]]
awayGamesPaired <- ids[gameInd[ ,2]]

haPairs <- cbind(homeGamesPaired, awayGamesPaired)
gamePairs <- cbind(game_data$home_team_id, game_data$away_team_id)

len <- dim(haPairs)[1]

pointDiff <-  winInd <-  indSum <- NULL

for (i in 1:len)
{
  ind <- which(apply(gamePairs, 1, function(x) all(x %in% haPairs[i, ])))
  noMatches <- length(ind)
  
  if (noMatches <=2)
  {
  ## Check the home and home data 
  if(game_data[ind[1],]$home_team_name != game_data[ind[2],]$away_team_name)
     { stop(c("Matching error in ", i))}
  if(game_data[ind[1],]$away_team_name != game_data[ind[2],]$home_team_name)
    {stop(c("Matching error in ", i))}
  }
  
  for (j in 1:noMatches)
  {
    homeInd <- which(game_data[ind, ]$home_team_id != game_data[ind[j], ]$home_team_id)
    pointDiff <- c(pointDiff, game_data[ind[j], ]$home_team_pts - game_data[ind[j], ]$away_team_pts) 
    winInd <- c(winInd, sum( 1 * (game_data[ind[homeInd], ]$home_team_pts - game_data[ind[homeInd], ]$away_team_pts < 0)))
    indSum <- c(indSum, length(homeInd))
  }
}

## Check the distribution of the difference in points by the home team versus the away team
hist(pointDiff, breaks = 100)

empiricalRxH <- data.frame(pointDiff = pointDiff, win = winInd, num = indSum)
empiricalRxHGroup <- ddply(empiricalRxH, ~pointDiff, summarize, win = sum(win), num = sum(num))
plot(empiricalRxHGroup$pointDiff, empiricalRxHGroup$win / empiricalRxHGroup$num)


## Run the logistic regression, and validate results 
fit <- glm((win/num) ~ pointDiff, data = empiricalRxHGroup, family = "binomial")
fitCoef <- coef(fit)
yPred <- exp(fitCoef[2] * empiricalRxHGroup$pointDiff + fitCoef[1]) / ( exp(fitCoef[2] * empiricalRxHGroup$pointDiff + fitCoef[1]) + 1)
lines(empiricalRxHGroup$pointDiff, yPred)

