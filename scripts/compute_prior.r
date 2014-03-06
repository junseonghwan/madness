rm(list=ls())
setwd("madness/")
tourney<-read.csv("data/tourney_results.csv")
seeds<-read.csv("data/tourney_seeds.csv")

# calculate the prior of being right if choosing higher seeded team
N<-dim(tourney)[1]
upset<-0
for (i in 1:N)
{
  seasonID<-tourney[i,"season"]
  wt<-tourney[i,"wteam"]
  lt<-tourney[i,"lteam"]

  wseed<-subset(seeds, season==seasonID & team==wt)
  lseed<-subset(seeds, season==seasonID & team==lt)
  
  seedw<-as.numeric(substr(wseed[,2], 2, 3))
  seedl<-as.numeric(substr(lseed[,2], 2, 3))
  
  upset <- upset + as.numeric(seedw < seedl)
  if (is.na(upset))
  {
    print(paste(i, upset, sep=","))
    break
  }
}

upset/N # shows that choosing higher seed does not work

