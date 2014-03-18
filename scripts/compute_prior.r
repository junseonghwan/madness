rm(list=ls())
setwd("madness/")
tourney<-read.csv("data/tourney_results.csv")
seeds<-read.csv("data/tourney_seeds.csv")

# calculate the prior of being right if choosing higher seeded team
N<-dim(tourney)[1]
upset<-0 # total upsets
total<-0 # total matches (two different seeds)
results1<-rep(0, 16) # results of round 1
upset2<-0 # upsets beyond round 1
total2<-0
for (i in 1:N)
{
  seasonID<-tourney[i,"season"]
  wt<-tourney[i,"wteam"]
  lt<-tourney[i,"lteam"]

  wseed<-as.character(subset(seeds, season==seasonID & team==wt)[,2])
  lseed<-as.character(subset(seeds, season==seasonID & team==lt)[,2])

  seedw<-as.numeric(substr(wseed, 2, nchar(wseed)))
  seedl<-as.numeric(substr(lseed, 2, nchar(lseed)))

  if (is.na(seedw))
  {
    # this is due to there being a character at the end (a or b for 16 seeded team)
    seedw<-as.numeric(substr(wseed, 2, nchar(wseed)-1))
  }
  if (is.na(seedl))
  {
    # this is due to there being a character at the end (A or B for 16 seeded team)
    seedl<-as.numeric(substr(lseed, 2, nchar(lseed)-1))
  }
  
  
  if (seedw == seedl)
  {
    #print(paste(seedw, seedl, sep=" vs "))
    next
  }
  
  if ((seedw + seedl) == 17)
  {
    results1[seedw] <- results1[seedw] + 1
  }
  else
  {
    upset2 <- upset2 + as.numeric(seedw < seedl)
    total2 <- total2 + 1
    if (as.numeric(seedw < seedl) > 0)
    {
    	print(paste(seedw, seedl, sep=","))
    }
  }
  
  upset <- upset + as.numeric(seedw < seedl)
  total <- total + 1
}

upset/total # shows that simply choosing higher seed does not work
results1  # first round results -- #1 seed has never lost to #16 seed
sum(results1[1:8])/sum(results1)
sum(results1[9:16]) # upsets in the first round
upset2/total2

# try validating on the march madness data
tourney<-read.csv("data/tourney_results.csv")
tourney12<-subset(tourney, season == "Q")
teams<-read.csv("data/teams.csv")
head(tourney12)

# retrieve team names
N<-dim(tourney12)[1]
ret<-0
total<-0
for (i in 1:N)
{
  wteamId<-tourney12[i,"wteam"]
  lteamId<-tourney12[i,"lteam"]
  wteam<-subset(teams, id == wteamId)
  lteam<-subset(teams, id == lteamId)
  
  # look up the teams and get the ranks
  if (!(wteam[,2] %in% ranked[,3]) | !(lteam[,2] %in% ranked[,3]))
  {
    next  
  }
  total <- total + 1
  
  wrank<-subset(ranked, team_name == wteam[,2])[1]
  lrank<-subset(ranked, team_name == lteam[,2])[1]
  
  if (wrank > lrank)
    ret <- ret + 1
}
