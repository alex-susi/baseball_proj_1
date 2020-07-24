# MLB Player Salary Estimator

## Project Overview
* First baseball project analyzing the relationship between Run Expectancy per the 24 different base states (RE24), Ultimate Zone Rating per 150 games (UZR/150) for non-catchers, Defensive Runs Above Average (Def) for catchers, and Salary
* Scraped 2020 salary data from spotrac.com, looking at veteran and arbitration contracts (only players that have already signed/negotiated contracts)
* Scraped play-by-play data from Retrosheet to calculate RE24 for all batters in the 2019 season
* Downloaded Defensive data from Fangraphs
* Created various linear models to determine how much teams value offense (RE24) vs defense (UZR/150 or DEF) when deciding how much a player is worth

### Background on Metrics used in this project
**RE24:** https://library.fangraphs.com/misc/re24/  
**DEF:** https://library.fangraphs.com/defense/def/  
**UZR/150:** https://blogs.fangraphs.com/the-fangraphs-uzr-primer/  



## Code and Resources used
**R Version:** 4.02  
**RStudio Version:** 1.3.959  
**Packages:** Lahman, dplyr, purrr, xml2, data.table, rvest, tidyverse, tidyr, ggplot2, car  
**Salary Data:** https://www.spotrac.com/mlb/rankings/  
**RE24 Code:** https://www.amazon.com/Analyzing-Baseball-Data-Second-Chapman/dp/0815353510#ace-g6308736939  
**DEF and UZR/150 Data:** https://www.fangraphs.com/leaders.aspx?pos=all&stats=fld&lg=all&qual=0&type=1&season=2019&month=0&season1=2019&ind=0&team=0&rost=0&age=0&filter=&players=0&startdate=&enddate=  
**Retrosheet PBP Scraper:** https://github.com/beanumber/baseball_R/tree/master/scripts



## EDA
* I looked at the relationship between RE24 and DEF (Catchers) or UZR/150 (non-Catchers) for players grouped by position
* I only wanted to look at players that started or played in a significant portion of the season so I filtered the data to include players with at least 300 plate appearances and 300 innings played in the field   
* Then I grouped players by position and looked at average RE24, average DEF or UZR/150, and average salary


## Model Building
I tried numerous different models
* I first ran a regression with all positions grouped together  
*Salary = RE24 + DEF*
* I then ran a regression with Position as a categorical variable  
*Salary = RE24 + DEF + position*
* I then ran a separate regression for each position
1. Catchers: *Salary = RE24 + DEF*
2. Non-catchers: *Salary = RE24 + UZR/150*  
* I decided to use separate regressions for each position, since teams may care more about offense for some positions and more about defense for others   


## Performance of Models
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_scatterplots/plot_1B.png" width="500">
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_residual_scatterplots/residual_plot_1B.png" width="500">
