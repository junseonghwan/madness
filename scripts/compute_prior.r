rm(list=ls())
setwd("madness/")
tourney<-read.csv("data/tourney_results.csv")
seeds<-read.csv("data/tourney_seeds.csv")

# calculate the prior of being right if choosing higher seeded team
N<-dim(tourney)[1]
upset<-0
upsets<-rep(0, 16)
for (i in 1:N)
{
  seasonID<-tourney[i,"season"]
  wt<-tourney[i,"wteam"]
  lt<-tourney[i,"lteam"]

  wseed<-subset(seeds, season==seasonID & team==wt)
  lseed<-subset(seeds, season==seasonID & team==lt)
  
  seedw<-as.numeric(substr(wseed[,2], 2, 3))
  seedl<-as.numeric(substr(lseed[,2], 2, 3))
  
  if ((seedw + seedl) == 17)
  {
    upsets[seedw] <- upsets[seedw] + 1
  }
  
  upset <- upset + as.numeric(seedw < seedl)
  if (is.na(upset))
  {
    print(paste(i, upset, sep=","))
    break
  }
}

upset/N # shows that simply choosing higher seed does not work
upsets # first round results -- #1 seed has never lost to #16 seed

