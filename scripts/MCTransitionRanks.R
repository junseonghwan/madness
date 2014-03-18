setwd("madness")      
rm(list=ls())

## Calculating the MC transition model
library(RSQLite)
library(plyr)
source("scripts/functions.r")
source("scripts/mcFunctions.r")

load(fitCoef)
fitCoef
fitCoef<-mcLogistic(2014) # do not save this as it will overwrite the existing one
)## parameters from regression
intercept <- fitCoef[1]
slope <- fitCoef[2]

hAdj <- 4
rankings<-main(intercept, slope, hAdj, 2014)
write.csv(rankings, file = "data/LRMCRanking2014.csv", row.names = F)

