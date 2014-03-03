library(RSQLite)
library(randomForest)

dirName <- "~/Dropbox/Shared Folders/NCAA"
setwd(dirName)

source("functions.r")

sqlite    <- dbDriver("SQLite")
ncaaDB1 <- dbConnect(sqlite,"ncaa.db")
dbListTables(ncaaDB1)



game_data_2012 <- get_train_data(ncaaDB1, 2012)
trainDat <- game_data_2012[, - c( match(c("home_team_pts", "away_team_pts", 
                                    "row_names", "game_id", "game_date",
                                    "away_team_id", "away_team_name",
                                    "away_team_minutes",  "home_team_id", 
                                    "home_team_name", "home_team_minutes"), 
                        colnames(game_data_2012)) )]
trainDat <- trainDat[, -ncol(trainDat)]
trainY <- (game_data_2012[, "away_team_pts"] - game_data_2012[, "home_team_pts"]) > 0 

test <- get_test_data(ncaaDB1, 2012, avg=T)
testDat <- test$testDat
testDat <- testDat[, (colnames(testDat) %in% colnames(trainDat))]
testY <- test$testY
rfMod <- randomForest( x = trainDat, y = as.factor(trainY), 
                       xtest = testDat, ytest = as.factor(testY) )



