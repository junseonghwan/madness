library(RSQLite)
library(plyr)
# don't forget to setwd()
setwd("~/Documents/NCAA/")

sqlite<-dbDriver("SQLite")
ncaaDB1<-dbConnect(sqlite, "data/ncaa.db")
dbListTables(ncaaDB1)

gameData2012<-dbGetQuery(ncaaDB1, "select * from game_data_2012")
names(gameData2012)
head(gameData2012)

## Olivia's code
gameDataTrain2012 <- get_train_data(ncaaDB1, 2012)
dat <- subset(gameData2012, !home_team_id==0 | !away_team_id==0)
team_id <- sort(unique(c(dat$home_team_id, dat$away_team_id)))
N <- length(team_id)

Sc <- matrix(NA, nrow=N, ncol=N)
for(i in 1:N){
  # data for home team id
  dati <- subset(dat, home_team_id==team_id[i])
  # order by away_team_id
  dati <- dati[with(dati, order(dati$away_team_id)), ]
  # home_pts/away_pts
  fn <- function(fn){log(mean(fn[["home_team_pts"]]/fn[["away_team_pts"]]))}
  odds <- do.call(c,dlply(dati, .(away_team_id), fn))   
  js <- which(team_id%in%names(odds))
  Sc[i, js] <- odds
}

rowIds <- apply(Sc, 1, function(d){ sum(!is.na(d)) > 0 })
colIds <- apply(Sc, 2, function(d){ sum(!is.na(d)) > 0 })
#sum( rowIds & colIds )
sps <- which(rowIds & colIds )

#test_dat<-get_train_data(ncaaDB1, 2012)
X<-Sc[sps, sps]
# X<-Sc
train.ind<-(!is.na(X))
Z0<-matrix(0, nrow=dim(X)[1], ncol=dim(X)[2])
Zhat<-soft.impute(1.5, Z0, X, train.ind, 0.0001)

year_str<-paste("game_data_", 2012, sep="")
select_str<-paste("select * from ", year_str, sep="")
gameData<-dbGetQuery(ncaaDB1, select_str)

dates<-as.Date(gameData$game_date, "%m/%d/%Y")
index<-(start_date$year == year)
tournament_date<-start_date[index, 2]

# get the games (with only the ids)
games<-gameData[dates >= tournament_date, c("away_team_id", "home_team_id")]
winlose<-gameData[dates >= tournament_date, c("away_team_pts", "home_team_pts")]
testY <- (winlose[,2] - winlose[,1]) > 0

res <- rep(NA, nrow(games))
for(i in 1:nrow(games)){
  res[i] <- Zhat$Z[match(games[i, 2], team_id[sps]), match( games[i, 1], team_id[sps] )]
}

predY = (res > 0)
predY
testY
mean(predY==testY)
