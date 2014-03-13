start_dates<-c("03/15/2011", "03/13/2012", "03/19/2013", "03/18/2014")
start_date<-data.frame(year=2011:2014, dates=as.Date(start_dates, "%m/%d/%Y"))

convert_date<-function(date_str)
{
  as.Date(date_str, "%m/%d/%Y")
}

get_train_data<-function(ncaaDB, year)
{
  year_str<-paste("game_data_", year, sep="")
  select_str<-paste("select * from ", year_str, sep="")
  gameData<-dbGetQuery(ncaaDB, select_str)
  
  dates<-as.Date(gameData$game_date, "%m/%d/%Y")
  index<-(start_date$year == year)
  tournament_date<-start_date[index, 2]
  
  dat<-gameData[dates < tournament_date, ]
  return(dat)
}

get_test_data<-function(ncaaDB, year, avg=F)
{
  year_str<-paste("game_data_", year, sep="")
  select_str<-paste("select * from ", year_str, sep="")
  gameData<-dbGetQuery(ncaaDB, select_str)
  
  dates<-as.Date(gameData$game_date, "%m/%d/%Y")
  index<-(start_date$year == year)
  tournament_date<-start_date[index, 2]

  # get the games (with only the ids)
  games<-gameData[dates >= tournament_date, c("away_team_id", "home_team_id")]
  winlose<-gameData[dates >= tournament_date, c("away_team_pts", "home_team_pts")]
  testY <- winlose[,1] - winlose[,2] > 0
  
  # grab team summary data
  year_str2<-paste("summary_team_data_", year, sep="")
  select_str2<-paste("select * from ", year_str2, sep="")  
  teamData<-dbGetQuery(ncaaDB, select_str2)
  
  # grab the cols that correspond to the team
  col_teams <- sapply( strsplit(colnames(teamData), split="_"), function(d){d[1]}) == "team"
  away_data<-teamData[match(games[,1], teamData$team_id), col_teams]
  home_data<-teamData[match(games[,2], teamData$team_id), col_teams]
  
  # get rid of the useless features
#   col_ids <- -c(1, 2, 3, sum(col_teams)-1, sum(col_teams))
    col_ids <- -c(sum(col_teams)-1, sum(col_teams))

  ## for away data
  away_data <- away_data[, col_ids]
  # make every attribute numeric
  away_data <- apply(away_data, 2, function(d){as.numeric(gsub(",","", d))}) 
  away_data <- as.data.frame(away_data)
  if(avg)
  {
    num_games <- away_data$team_totreb/away_data$team_rebavg
    away_data <- apply(away_data, 2, function(d){d/num_games})
    away_data <- as.data.frame(away_data)
  }
  
  colnames(away_data) <- paste("away", colnames(away_data), sep="_")
  
  ## for home data
  home_data <- home_data[, col_ids]
  # make every attribute numeric
  home_data <- apply(home_data, 2, function(d){as.numeric(gsub(",","", d))}) 
  home_data <- as.data.frame(home_data)
  if(avg)
  {
    num_games <- home_data$team_totreb/home_data$team_rebavg
    home_data <- apply(home_data, 2, function(d){d/num_games})
    home_data <- as.data.frame(home_data)
  }
  
  colnames(home_data) <- paste("home", colnames(home_data), sep="_")
  
  
  dat<-cbind(away_data, home_data)
  

  return(list(testDat = dat, testY = testY))
}

get_test_data_wIDS<-function(ncaaDB, year)
{
  year_str<-paste("game_data_", year, sep="")
  select_str<-paste("select * from ", year_str, sep="")
  gameData<-dbGetQuery(ncaaDB, select_str)
  
  dates<-as.Date(gameData$game_date, "%m/%d/%Y")
  index<-(start_date$year == year)
  tournament_date<-start_date[index, 2]
  
  # get the games (with only the ids)
  games<-gameData[dates >= tournament_date, c("away_team_id", "home_team_id")]
  winlose<-gameData[dates >= tournament_date, c("away_team_pts", "home_team_pts")]
  testY <- winlose[,1] - winlose[,2] > 0
  
  
  
  return(list(ids = games, testY = testY))
}

