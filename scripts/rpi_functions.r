

format.date <- function(dat){
  dat$game_date <- as.Date(dat$game_date, format = "%m/%d/%Y")
  dat
}

my.grepl <- function(vec, ..., fun = c('any', 'all')){
  lis <- lapply(vec, function(x) grepl(x, ...))
  foo <- do.call(rbind, lis)
  fun <- get(match.arg(fun))
  apply(foo, 2, fun)
}

### adds fields to game data.
### Change this as you see fit
### Any fields used should be written like after "home_" or "away_"
### Like in teamOpp format
add_fields <- function(dat){
  
  ## Possessions
  dat$away_team_poss <- 0.96*(dat$away_team_fgm - dat$away_team_offreb + 
                                dat$away_team_to + 0.475*dat$away_team_fta)
  dat$home_team_poss <- 0.96*(dat$home_team_fgm - dat$home_team_offreb + 
                                dat$home_team_to + 0.475*dat$home_team_fta)
  
  ## Offensive Rating
  dat$away_team_ORt <- 100*dat$away_team_pts/dat$away_team_poss
  dat$home_team_ORt <- 100*dat$home_team_pts/dat$home_team_poss
  
  ## Defensive Rating
  dat$away_team_DRt <- 100*dat$home_team_pts/dat$away_team_poss
  dat$home_team_DRt <- 100*dat$away_team_pts/dat$home_team_poss
  
  ## Effective FG%
  dat$away_team_efg <- (dat$away_team_fgm + 0.5*dat$away_team_three_fgm)/
    dat$away_team_fga
  dat$home_team_efg <- (dat$home_team_fgm + 0.5*dat$home_team_three_fgm)/
    dat$home_team_fga
  
  ## True shooting %
  dat$away_team_tfg <- dat$away_team_pts/2/(dat$away_team_fga + 
                                              0.475*dat$away_team_fta)
  dat$home_team_tfg <- dat$home_team_pts/2/(dat$home_team_fga + 
                                              0.475*dat$home_team_fta)
  
  ## Free-throw Rate
  dat$away_team_ftr <- dat$away_team_fta/dat$away_team_fga
  dat$home_team_ftr <- dat$home_team_fta/dat$home_team_fta
  
  ## Turnover rate
  dat$away_team_tor <- 100*dat$away_team_to/
    (dat$away_team_fga + 0.475*dat$away_team_fta + dat$away_team_to)
  dat$home_team_tor <- 100*dat$home_team_to/
    (dat$home_team_fga + 0.475*dat$home_team_fta + dat$home_team_to)
  
  ## Offsne Rebound Rate
  dat$away_team_orr <- 100*dat$away_team_offreb/
    (dat$away_team_offreb + dat$home_team_defreb)
  dat$home_team_orr <- 100*dat$home_team_offreb/
    (dat$home_team_offreb + dat$away_team_defreb)
  
  return(dat)
}

#### Add advanced statistic fields
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



format_teamOpp <- function(dat){
  game_fields <- c(names(dat)[grepl('game', names(dat))], 'neutral_site')
  away_fields <- names(dat)[grepl('away', names(dat))]
  home_fields <- names(dat)[grepl('home', names(dat))]
  
  tmp <- dat[home_fields]; names(tmp) <- away_fields
  tmp2 <- dat[away_fields]; names(tmp2) <- home_fields

  df <- rbind(dat[away_fields], tmp)
  df2 <- rbind(dat[home_fields], tmp2)
  loc <- rep(c('away', 'home'), each = nrow(dat))
  ddff <- rbind(dat[game_fields], dat[game_fields])
  
  names(df) <- gsub('away_', '', names(df))
  names(df2) <- gsub('home_team', 'opp', names(df2))
  cbind(ddff, df, df2, loc = loc)
}

####################################
### Writing function: myRPI 
####################################

### Functions to edit later !!!!!!!!!!!!!!!!!!!!!!!!!!!!
g <- median
f <- median
rpi <- function(x, y, z) 0.25*x - 0.5*y + 0.25*z


### Returns data.frame with summarized fields (flds) for team (gameid only)
### opponent (opp) and opponent's opponents (oppOpp)
game.rpi <- function(gameid, ta, flds, reg = reg_game){
  require(plyr)
  tadat <- subset(reg, team_name == ta & game_id == gameid)
  tb <- tadat$opp_name
  tbdat <- subset(reg, opp_name == tb & game_id != gameid)
  oppoppdat <- subset(reg, !game_id %in% tbdat$game_id & 
                        team_name %in% tbdat$team_name)
  oppStat <- apply(tbdat[flds], 2, g)
  oppOppStat <- ddply(oppoppdat, .(team_name), function(dat) apply(dat[flds], 2, g))
  oppOppStat <- apply(oppOppStat[flds], 2, f)
  dl <- rbind(teamStat = tadat[flds], opp = oppStat, oppOpp = oppOppStat)
  apply(dl, 2, function(x) rpi(x[1], x[2], x[3]))
}

### This transforms an entire season of data (format like teamOpp)
team.rpiTransform <- function(flds, reg = reg_game, 
                              keeperFields = c('game_date', 'neutral_site', 'loc',
                                               'team_pts', 'opp_pts')){
  require(plyr)
  fn <- function(x) game.rpi(x$game_id, x$team_name, flds, reg)
  dat <- ddply(reg, .(game_id, team_name), fn, .progress = 'text')
  merge(dat, reg[c('game_id', 'team_name', keeperFields)])
}



