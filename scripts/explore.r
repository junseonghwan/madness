library(RSQLite)

# don't forget to setwd()
 setwd("madness/")

sqlite<-dbDriver("SQLite")
ncaaDB1<-dbConnect(sqlite, "data/ncaa.db")
dbListTables(ncaaDB1)

games<-dbGetQuery(ncaaDB1, "select * from game_data_2012")
players<-dbGetQuery(ncaaDB1, "select * from player_data_2012")
names(gameData2012)
head(gameData2012)
