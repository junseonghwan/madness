## Test the results
library(RSQLite)
source("scripts/functions.r")
sqlite    <- dbDriver("SQLite")
ncaaDB1 <- dbConnect(sqlite,"data/ncaa.db")

game_data <- get_test_data_wIDS(ncaaDB1, 2012)

## For each of these games we need a list of winners and losers
## Easiest way is to likely have an indicator if the home team won
## then match to ranks and determine probability

ranked <- read.csv("data/LRMCRanking2012.csv")

len <- length(game_data$testY)

sim <- matrix(0, nrow = len, ncol = 1)
for (i in 1:len)
{
  sim[i] <- (which(ranked$team_id == game_data$ids[i, 1]) < which(ranked$team_id == game_data$ids[i, 2]))
}

predict <- sum(1 * (sim == game_data$testY)) / len
## [1] 0.5890411