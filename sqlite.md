### A super quick guide to using SQLite with R

#### Install `RSQLite`, and then load the package


```r
library(RSQLite)
```

```
## Loading required package: DBI
```


#### Assuming that there is already a SQLite data base to connect to, use the `dbConnect` function to access the data base. For the arguments, set the SQL driver (`"SQLite"`, in our case), and then open a connection to the SQLite data base by providing the path to the data base.


```r
# Open a connection to the SQLite data base
con <- dbConnect(drv = "SQLite", "data/ncaa.db")
```


#### Look at the tables listed in the data base using the `dbListTables`, and providing the connection to the data base that you created in step 2. Another helpful command is the `dbListFields`, which can list the column names for any table in the data base.


```r
# List all the tables in the data base that you are connected to in the con
# object
dbListTables(conn = con)
```

```
##  [1] "game_data_2011"           "game_data_2012"          
##  [3] "game_data_2013"           "player_data_2011"        
##  [5] "player_data_2012"         "player_data_2013"        
##  [7] "player_mappings_2011"     "player_mappings_2012"    
##  [9] "player_mappings_2013"     "schedule_mappings_2011"  
## [11] "schedule_mappings_2012"   "schedule_mappings_2013"  
## [13] "summary_player_data_2011" "summary_player_data_2012"
## [15] "summary_player_data_2013" "summary_team_data_2011"  
## [17] "summary_team_data_2012"   "summary_team_data_2013"  
## [19] "team_data_2011"           "team_data_2012"          
## [21] "team_data_2013"           "team_mappings_2011"      
## [23] "team_mappings_2012"       "team_mappings_2013"
```

```r

# List the columns in the connection
dbListFields(conn = con, name = "game_data_2011")
```

```
##  [1] "row_names"           "game_id"             "game_date"          
##  [4] "away_team_id"        "away_team_name"      "away_team_minutes"  
##  [7] "away_team_fgm"       "away_team_fga"       "away_team_three_fgm"
## [10] "away_team_three_fga" "away_team_ft"        "away_team_fta"      
## [13] "away_team_pts"       "away_team_offreb"    "away_team_defreb"   
## [16] "away_team_totreb"    "away_team_ast"       "away_team_to"       
## [19] "away_team_stl"       "away_team_blk"       "away_team_fouls"    
## [22] "home_team_id"        "home_team_name"      "home_team_minutes"  
## [25] "home_team_fgm"       "home_team_fga"       "home_team_three_fgm"
## [28] "home_team_three_fga" "home_team_ft"        "home_team_fta"      
## [31] "home_team_pts"       "home_team_offreb"    "home_team_defreb"   
## [34] "home_team_totreb"    "home_team_ast"       "home_team_to"       
## [37] "home_team_stl"       "home_team_blk"       "home_team_fouls"    
## [40] "neutral_site"
```


#### Send SQL(ite) queries using the `dbGetQuery` and providing the connection to the data base and a valid SQLite query.


```r
# Retrieve results from SQL queries For example, select all columns from the
# game_data_2011 table and get the first 10 rows
dbGetQuery(conn = con, statement = paste("SELECT game_date, away_team_name, home_team_name", 
    "FROM game_data_2011 LIMIT 10"))
```

```
##     game_date    away_team_name home_team_name
## 1  02/23/2011      Rhode Island       Duquesne
## 2  11/27/2010              Army           Yale
## 3  11/27/2010          Longwood       Campbell
## 4  11/27/2010          Marshall     Louisville
## 5  03/02/2011              Iowa   Michigan St.
## 6  11/27/2010          Delaware      Lafayette
## 7  01/15/2011 Central Conn. St.     Quinnipiac
## 8  01/15/2011           Georgia       Ole Miss
## 9  02/19/2011            Butler   Ill.-Chicago
## 10 01/15/2011      Presbyterian  Coastal Caro.
```


#### After you are finished, close the connection.


```r
dbDisconnect(con)
```

```
## [1] TRUE
```


#### Some useful SQLite commands

The basic syntax for querying from a SQL data base is as follows:

`SELECT <Columns> FROM <Table> WHERE <Condition>`

There are some more advanced SQL commands, and Google is probably the best teacher.

For example, check out this [site](http://www.w3schools.com/sql/) for a list of common SQL queries with examples. Note that some may not work with SQLite, but most of them should.
