library(RSQLite)

# don't forget to setwd()

sqlite<-dbDriver("SQLite")
ncaaDB1<-dbConnect(sqlite, "data/ncaa.db")
dbListTables(ncaaDB1)

gameData2012<-dbGetQuery(ncaaDB1, "select * from game_data_2012")
names(gameData2012)
head(gameData2012)
