Notes of Madness
================

# Tournament dates	
March 13-April 2, 2011-2012

March 19–April 8, 2012-2013

March 18–April 7, 2013-2014

Overview
--------
Objective: To create an algorithm which assigns a probability of winning to two teams that are matched up, based on any available data from NCAA Div I Men's Basketball.

### Ideas:
...
Test

1. Cluster the teams to several groups. So when A play B, the teams that belong to the same group as B can be used as tranning data, so does for team A.

### Methods:
...


Dates
--------

- Mar. 3: Registration opens (Buffett)
- Mar. 15: Final submission of historical model building results (Kaggle)
- Mar. 16: Selection Sunday
- Mar. 18: Four play-in games (don't need to predict)
- Mar. 19: Final submission of 2014 predictions by 3pm PST (Kaggle)
- Mar. 19: Final submission by 9am PST (Buffett)
- Mar. 19: Round 1 of NCAA tournament

Weekly to-do
------------

### Feb. 21-28
- Brainstorm Ideas
- Collect/Clean Data (to where)? 
- Download [data provided by Kaggle](http://www.kaggle.com/c/march-machine-learning-mania/data)
- Need JavaScript code for scraping the [NCAA site](http://stats.ncaa.org/team/inst_team_list) for more data?

### TO DO after meeting Feb 27th
Rankings/Seeding Algorithms
- Try RPI. [RPI Data](http://www.teamrankings.com/ncb/rpi/)
- Implement Fearnhead and compare with RPI

Modelling
- Finish random forest
- Robust model?
- Read about "Deep Learning"


### Mar. 1-8
- Final cleaning, structure for training/testing data
- Implement simple methods

### Mar. 9-17
- Implement more methods
- Test methods on historical data: pick best one and submit!

Features
-------------

#### Player stats:
- Traditional
- Advanced
- Physical
- Age (year in school)
- Season/tournament stats

#### Team
- Style
- Aggregate player
- Player "balance"

#### External
- Program budget
- Vegas odds
- RPI/Seed
- [Fearnhead Rank](http://www.maths.lancs.ac.uk/~fearnhea/Basketball.html)
- Game location


#### Some game data variables descriptions
- Minutes: Total minutes played (?)
- FGM: Field goal made, number of goals made (successful throws)
- FGA: Field goal attempted, number of throws at the basket, disconsidering free throws
- Three FGM: Number of three-point goals made
- Three FGA: Number of three-point goals attempted
- FT: Number of free throws made
- FTA: Number of free throw attempted
- PTS: Points
- OffReb: Number of offensive rebounds
- DefReb: Number of deffensive rebounds
- AST: Number of assistances
- TO: Number of turnovers (opponent team steals the ball)
- STL: Number of steals (you steal the ball from your opponent)
- BLK: Number of blocks
- Fouls: Number of fouls
- TotReb: Total rebounds

Odds of winning $1 billion
--------------------------

1 in 9,200,000,000,000,000,000 (9.2 quintillion)
