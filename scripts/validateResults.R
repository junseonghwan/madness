## Test the results
library(RSQLite)
source("scripts/functions.r")
source("scripts/mcFunctions.r")

# aggregate all of the years data
fitCoef<-mcLogistic(2010:2014)
save(fitCoef, file="coef")

# do cross validation
h_opt0<-cv(2010, 1:5, fitCoef) # error?
h_opt1<-cv(2011, 1:7, fitCoef) # h = 5
h_opt2<-cv(2012, 1:5, fitCoef) # error?
h_opt3<-cv(2013, 1:5, fitCoef) # h = 3

h_opt<-(h_opt1[1]*h_opt1[2]+h_opt3[1]*h_opt3[2])/(h_opt1[2] + h_opt3[2]) # roughly 4
# take weighted average to find h_opt

