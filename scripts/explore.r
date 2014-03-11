library(RSQLite)
library(plyr)

# don't forget to setwd()
setwd("madness/")
rm(list=ls())

sqlite<-dbDriver("SQLite")
ncaaDB1<-dbConnect(sqlite, "data/ncaa.db")
dbListTables(ncaaDB1)

games<-dbGetQuery(ncaaDB1, "select * from game_data_2012")
players<-dbGetQuery(ncaaDB1, "select * from player_data_2012")

games<-subset(games, home_team_id != 0 & away_team_id != 0)

home<-ddply(games, c("home_team_id"), function(d) {
  c(sum(d$home_team_pts > d$away_team_pts), mean(d$home_team_fga), sd(d$home_team_fga), dim(d)[1])
})

home2<-subset(home, V4 > 1)

away<-ddply(games, c("away_team_id"), function(d) {
  c(sum(d$home_team_pts > d$away_team_pts), mean(d$home_team_fga), sd(d$home_team_fga), dim(d)[1])
})

away2<-subset(away, V4 > 1)

dukeH<-subset(games, home_team_name == "Duke")
dukeA<-subset(games, away_team_name == "Duke")

mean(dukeH$home_team_fga)
sd(dukeH$home_team_fga)
mean(dukeA$away_team_fga)
sd(dukeA$away_team_fga)

