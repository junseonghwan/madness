library(RSQLite)
library(plyr)
# don't forget to setwd()

sqlite<-dbDriver("SQLite")
ncaaDB1<-dbConnect(sqlite, "data/ncaa.db")
dbListTables(ncaaDB1)

dat<-get_train_data(ncaaDB1, 2012)

source("scripts//functions.r")
test_dat<-get_test_data(ncaaDB1, 2012, avg=T)

