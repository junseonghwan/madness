############################################################
### Master script for data formatting
############################################################
setwd('C:/Users/User/Documents/madness/')

source('rpi_functions.r')

library(RSQLite)

sqlite <- dbDriver('SQLite')
ncaa.db <- dbConnect(sqlite, 'data/ncaa.db')
dbListTables(ncaa.db)

### My query wrapper
myq <- function(...) dbGetQuery(ncaa.db, ...)

### Import all years of team data
tabs <- paste0('game_data_', 2011:2013)

years <- 2011:2013
dates <- c('2011-03-15', '2012-03-13', '2013-03-19')


reg_seas <- vector('list', 3)
post_seas <- vector('list', 3)
names(reg_seas) <- names(post_seas) <- years

for(i in 1:3){
  print(years[i])
  game_data <- myq(paste0('select * from game_data_', years[i]))
  game_data <- format.date(game_data)
  game_data <- add_fields(game_data)
  game_data <- format_teamOpp(game_data)
  reg_seas[[i]] <- subset(game_data, game_date < as.Date(dates[i]))
  post_seas[[i]] <- subset(game_data, game_date >= as.Date(dates[i]))
}

#### Fields to do RPI transform on:
fields <- c('fgm', 'fga', 'three_fgm', 'three_fga', 'ft', 'fta', 'offreb', 'defreb', 
            'totreb', 'ast', 'to', 'stl', 'blk', 'fouls', 'ORt', 'DRt', 'efg', 'tfg',
            'ftr', 'tor', 'orr')
fields <- paste(rep(c('team', 'opp'), each = length(fields)), fields, sep = '_')

keepers <- c('game_id', 'game_date', 'neutral_site', 'team_name', 'opp_name', 'loc')

reg_seas <- lapply(reg_seas, function(x) team.rpiTransform(fields, x, keepers))

for(i in years){
  dat <- reg_seas[[as.character(i)]]
  dbWriteTable(ncaa.db, paste0('game_data_rpiTransform_', i), dat)
}

save(reg_seas, file = 'regular_season_game_data_rpiTransform.rda')
