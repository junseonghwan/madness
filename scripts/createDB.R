library(RSQLite)

dirName <- "~/Dropbox/Shared Folders/NCAA/data"
### set working dir
setwd(dirName)
### obtain all folder names in working dir
folders <- list.files(path = ".")
### create DB tables for all the data files within each folder
ncaaDB <- dbConnect("SQLite", dbname = "ncaa.db")
for(folderName in folders)
{
    splitName <- unlist( strsplit(folderName, "-", fixed=T) )
    year <- splitName[length(splitName)]
    print(year)
    ### data files
    dataPath <- paste(".", folderName, "data", sep="/")
    dataFiles <- list.files(path = dataPath)
    for(df in dataFiles)
    {
        datname <- paste(unlist( strsplit(df, split=".", fixed=T) )[1], 
                      year, sep="_")
        datvalue <- read.delim(paste(dataPath, df, sep="/"), 
                               sep="\t", header=T)
        dbWriteTable(ncaaDB, datname, datvalue)
        print(df)
    }
    
    ### mapping files
    mappingPath <- paste(".", folderName, "mappings", sep="/")
    mappingFiles <- list.files(mappingPath)
    for(mf in mappingFiles)
    {
        mapname <- paste(unlist( strsplit(mf, split=".", fixed=T) )[1], 
                      year, sep="_")
        mapvalue <- read.delim(paste(mappingPath, mf, sep="/"), 
                               sep="\t", header=T)
        dbWriteTable(ncaaDB, mapname, mapvalue)
        print(mf)
    }
}

dbListTables(ncaaDB)
dbDisconnect(ncaaDB)

sqlite    <- dbDriver("SQLite")
ncaaDB1 <- dbConnect(sqlite,"ncaa.db")
dbListTables(ncaaDB1)

game_data_2012 <- dbGetQuery(ncaaDB1, "select * from game_data_2012")
summary_team_data_2012 <- dbGetQuery(ncaaDB1, "select * from summary_team_data_2012")





