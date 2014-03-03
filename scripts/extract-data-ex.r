library(RSQLite)

# don't forget to setwd()

sqlite<-dbDriver("SQLite")
ncaaDB1<-dbConnect(sqlite, "data/ncaa.db")
dbListTables(ncaaDB1)

gameData2012<-dbGetQuery(ncaaDB1, "select * from game_data_2012")
names(gameData2012)
head(gameData2012)

### Fitting Random Forests on game data 2012

sqlite  <- dbDriver("SQLite")
ncaaDB1 <- dbConnect(sqlite,"ncaa.db")
dbListTables(ncaaDB1)

game_data_2012 <- dbGetQuery(ncaaDB1, "select * from game_data_2012")
summary_team_data_2012 <- dbGetQuery(ncaaDB1, "select * from summary_team_data_2012")
#sort(as.Date(unique(game_data_2012$game_date), format = "%m/%d/%Y"))

library(randomForest)
X <- game_data_2012[, - c( match(c("home_team_pts", "away_team_pts", 
                                    "row_names", "game_id", "game_date",
                                    "away_team_id", "away_team_name",
                                    "away_team_minutes",  "home_team_id", 
                                    "home_team_name", "home_team_minutes"), 
                        colnames(game_data_2012)) )]
y <- (game_data_2012[, "home_team_pts"] - game_data_2012[, "away_team_pts"]) > 0 
rfMod <- randomForest( X, as.factor(y) )
