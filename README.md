Overview
--------
Objective: To create an algorithm which assigns a probability of winning to two teams that are matched up, based on any available data from NCAA Div I Men's Basketball.

#### Contest rules ($1B bracket)
[Scan/read this](http://www.quickenloansbracket.com/rules/rules.html)

### Ideas:

1. Cluster the teams to several groups. So when A play B, the teams that belong to the same group as B can be used as tranning data, so does for team A.

### Methods:

Modelling for number of shots taken
-----------------

A strong predictor for the points scored is the number of shots taken.  
The game is played over 40 minutes with each team taking a turn to attack. A turn can take
at most 35 seconds before a shot must be taken (must reach the rim). Hypothetically, if each 
team takes full 35 seconds to take a shot, there are roughly 70 turns in total (35 turns each).

Of course, the amount of time needed to take a shot varies by possession and it may occur that
a team's attach may result in no shots taken if the team makes a mistake of turning the ball over.
Offensive rebounds also contribute to the number of shots taken as a team gets another possession 
upon gaining an offensive rebound.

We have largely, two ways to model for the number of shots taken.

1. Model for one possession using Markov Chain with state space defined as shown in figure (TODO).

2. Use two stage model (hierarchical model) or GLMM to model for N_{ij} as can be see in the figure below (TODO).

There are probably more ways, but we have discussed only the first one extensively in our meeting on March 2nd.

For the first method, I think we can obtain the MLE for the transition matrix [link](http://www.stat.cmu.edu/~cshalizi/462/lectures/06/markov-mle.pdf).
If we use CTMC, I wonder if we can use ideas explained [here](http://www.stat.ubc.ca/~bouchard/courses/stat547-sp2013-14/lecture/2014/02/05/lecture10.html).

For hierarchical model, we can use either Bayesian model or frequentist approach. The picture to explain this will come soon.

Modelling the performance of teams 
---

Another approach we discussed is to directly model for team's performance against different types of teams.

When we get the matchup (first round), the two teams will surely not have played against each other during the 
regular season. However, if we can label each team as playing a specific type (for example, defensive) and if
we can somehow measure how each team played against the opponent of specific type, then it becomes possible 
to predict the outcome of the games.

One approach is to use the idea of [matrix completion](http://jmlr.org/papers/volume11/mazumder10a/mazumder10a.pdf)
to fill out missing entries of a matrix A where A is a TxT matrix with T being the number of teams. 
The entries A_{ij} is supposed to measure performance of team i when playing against team j. But as mentioned above,
team i probably never played team j. The matrix completion relies on the idea that a matrix A is actually 
a product of two lower dimensional matrices B and C: A = BC + eI where e is the error term. 
We take B as TxL and C as LxT where L is the number of types of teams. 

An example where matrix completion can be useful is Netflix movie recommendation. A in this case would be
NxM where N is the number of users (millions) and M is the number of movies (thousands). Obviously, 
users will not have watched all M movies and will not have rated all M movies hence, A will have many missing
entries. However, if we consider the movies as grouped by L << M genres, then we can take A = BC where
B is NxL, which describes preference of users to each genre and C is LxM, which sort of describes
the rank of each movie within the genre.

Applying this idea to basketball, L would be the number of types of teams, for example, defensive, 3-pt shooting, etc.
And we should be able to complete the matrix using the method described in the above link (which is already implemented).
Not sure how good it will work and we still have to work out some details but this can be a promising approach.

Defining partial order on teams
---

The main idea is that each team has a true strength (latent) but this strength can vary depending 
on which team it is playing. So if we take the latent strength as l_i, then there is a conditional scaling by 
lambda\_{i|j}. This idea requires estimation of conditional quantities such as lambda\_{i|j}.

The details have not been worked out but we should continue to think about this approach.

Straightforward "RPI" approach
-----------------------

### Idea
For each feature we want to use, we "RPI" it. We will create a function which will transform one feature, say, eFG%, and transform it in order to normalize over all opponents during the regular season, and we do this for each team. So in the example of eFG%, for each game in the regular season, we measure 
1. the team's eFG% in that game
2. their opponent's aggregate eFG% AGAINST over the season (except for this game). 
3. their opponent's opponent's eFG% FOR against all other opponents over the season, aggregated somehow (TBD)
We then take the 3 statistics for each game, and aggregate (TBD also) them into one metric. We can then either use the metric for each game for each team, or aggregate this metric over all games. 

We can use normal stats or advanced stats. We can then put these transformed data into some model where we use regular season stats for any one given year to predict the playoff outcomes (score differential or binary win/loss).

Data Description
--------------------

## Advanced Statistics

- Possessions (POSS): 0.96*(FGA-ORb+TO+(0.475*FTA))
- Offensive Rating (ORt): 100*PtsFor/POSS
- Defensive Rating (DRt): 100*PtsAgainst/POSS
- Effective FG% (eFG): (FGM + (0.5)3FGM)/FGA
- True Shooting % (tFG): Pts/2(FGA+(0.475)FTA)
- Free-throw Rate (FTR): FTA/FGA
- Turnover Rate (TOR): 100*TO/(FGA+(FTA*0.475)+TO)
- Offense Rebound Rate (ORR): 100*ORb/(ORb+OppDRb)

### Tournament dates	

March 13-April 2, 2011-2012

March 19–April 8, 2012-2013

March 18–April 7, 2013-2014


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
