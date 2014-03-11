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
    results1[seedw] <- upsets[seedw] + 1
  }
  else
  {
    upset2 <- upset2 + as.numeric(seedw < seedl)
    total2 <- total2 + 1
  }
  
  upset <- upset + as.numeric(seedw < seedl)
  total <- total + 1
}

upset/total # shows that simply choosing higher seed does not work
results1  # first round results -- #1 seed has never lost to #16 seed
sum(results1[1:8])/sum(results1)
sum(results1[9:16]) # upsets in the first round
upset2/total2
