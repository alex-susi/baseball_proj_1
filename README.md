# MLB Player Salary Estimator

## Project Overview
* First baseball project analyzing the relationship between Run Expectancy per the 24 different base states (RE24), Ultimate Zone Rating per 150 games (UZR/150) for non-catchers, Defensive Runs Above Average (DEF) for catchers, and Salary
* [Scraped 2020 salary data](https://github.com/alex-susi/baseball_proj_1/blob/master/salary_scraper.R) from spotrac.com, looking at veteran and arbitration contracts (only players that have already signed/negotiated contracts)
* [Scraped Retrosheet play-by-play data](https://github.com/alex-susi/baseball_proj_1/blob/master/parse_retrosheet_pbp.R) to [calculate RE24](https://github.com/alex-susi/baseball_proj_1/blob/master/RE24.R) for all batters in the 2019 season  
* Downloaded Defensive data from Fangraphs
* [Created various linear models](https://github.com/alex-susi/baseball_proj_1/blob/master/models.R) to determine how much teams value offense (RE24) vs defense (UZR/150 or DEF) when deciding how much a player is worth
* These models can be used to determine a player's value on the open market based on their offensive and defensive skills, as well as their position

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



## [EDA](https://github.com/alex-susi/baseball_proj_1/blob/master/EDA.R)
* I looked at the relationship between RE24 and DEF (Catchers) or UZR/150 (non-Catchers) for players grouped by position
* I only wanted to look at players that started games or played in a significant portion of the season, so I filtered the data to include players with at least 300 plate appearances and 300 innings played in the field   
* Then I grouped players by position and looked at average RE24, average DEF, and average salary to get a general idea of which positions are generally better on offense and defense, and which positions typically get paid more 

| Postition | N  | Avg Salary | Avg RE24 | Avg DEF |
| --------- |:--:| :---------:| :-------:| -------:|
| 1B        | 20 | 13,256,236 | 15.96    | -8.61   |
| 2B        | 19 | 7,992,105  | -1.26    | 1.12    |
| SS        | 17 | 10,101,470 | 5.89     | 7.85    | 
| 3B        | 16 | 14,599,255 | 12.15    | 2.18    |
| LF        | 15 | 9,152,333  | 11.23    | -3.39   |
| CF        | 20 | 8,912,291  | 0.78     | 2.17    | 
| RF        | 16 | 11,370,737 | 13.00    | -4.86   |
| C         | 17 | 7,908,986  | 0.40     | 8.62    | 




## Model Building
I tried numerous different models
* I first ran a regression with all positions grouped together  
*Salary = RE24 + DEF*
* I then ran a regression with Position as a categorical variable  
*Salary = RE24 + DEF + position*
* I then ran a separate regression for each position
1. Catchers: *Salary = RE24 + DEF*
2. Non-catchers: *Salary = RE24 + UZR/150*  
* I decided to use separate regressions for each position, since teams may care more about offensive production (RE24) for some positions and more about defensive production (DEF and UZR/150) for others   
* I used UZR/150 for non-catchers since the metric compares players to others that play the same position
* Catchers do not have an UZR/150 so I used DEF for their model  

<br />
<br />  


# Performance of Models
## 1B
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_scatterplots/plot_1B.png" width="410"> <img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_residual_scatterplots/residual_plot_1B.png" width="410">

Formula = salaries ~ RE24 + UZR_150
| Coefficient   | Estimate      | P-value  |
| ------------- |:-------------:| --------:|
| Intercept     | 14,015,293    | 0.000176 |
| RE24          | 44,790        | 0.720384 |
| UZR_150       | 537,847       | 0.126790 |

Residual standard error: 9162000 on 17 degrees of freedom  
Multiple R-squared:  0.1342,	Adjusted R-squared:  0.03234  
F-statistic: 1.318 on 2 and 17 DF,  p-value: 0.2938  

---
---
## 2B
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_scatterplots/plot_2B.png" width="410"> <img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_residual_scatterplots/residual_plot_2B.png" width="410">

Formula = salaries ~ RE24 + UZR_150
| Coefficient   | Estimate      | P-value  |
| ------------- |:-------------:| --------:|
| Intercept     | 7,743,945     | 0.000481 |
| RE24          | 71,201        | 0.675788 |
| UZR_150       | -465,276      | 0.144246 |

Residual standard error: 7608000 on 16 degrees of freedom  
Multiple R-squared:  0.1432,	Adjusted R-squared:  0.03607  
F-statistic: 1.337 on 2 and 16 DF,  p-value: 0.2905  

---
---
## SS
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_scatterplots/plot_SS.png" width="410"> <img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_residual_scatterplots/residual_plot_SS.png" width="410">

Formula = salaries ~ RE24 + UZR_150
| Coefficient   | Estimate      | P-value  |
| ------------- |:-------------:| --------:|
| Intercept     | 8,891,816     | 1.55e-05 |
| RE24          | 102,805       | 0.153    |
| UZR_150       | 264,788       | 0.237    |

Residual standard error: 5116000 on 14 degrees of freedom  
Multiple R-squared:  0.229,	Adjusted R-squared:  0.1189  
F-statistic: 2.079 on 2 and 14 DF,  p-value: 0.1619  

---
---
## 3B
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_scatterplots/plot_3B.png" width="410"> <img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_residual_scatterplots/residual_plot_3B.png" width="410">

Formula = salaries ~ RE24 + UZR_150
| Coefficient   | Estimate      | P-value  |
| ------------- |:-------------:| --------:|
| Intercept     | 11,249,115    | 0.000718 |
| RE24          | 282,676       | 0.021093 |
| UZR_150       | 275,452       | 0.404067 |

Residual standard error: 8683000 on 13 degrees of freedom  
Multiple R-squared:  0.4607,	Adjusted R-squared:  0.3777  
F-statistic: 5.552 on 2 and 13 DF,  p-value: 0.01807  

---
---
## LF
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_scatterplots/plot_LF.png" width="410"> <img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_residual_scatterplots/residual_plot_LF.png" width="410">

Formula = salaries ~ RE24 + UZR_150
| Coefficient   | Estimate      | P-value  |
| ------------- |:-------------:| --------:|
| Intercept     | 8,858,473     | 0.000774 |
| RE24          | 34,662        | 0.741001 |
| UZR_150       | -234,940      | 0.183789 |

Residual standard error: 6268000 on 12 degrees of freedom  
Multiple R-squared:  0.1457,	Adjusted R-squared:  0.003345   
F-statistic: 1.023 on 2 and 12 DF,  p-value: 0.3887  
 

---
---
## CF
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_scatterplots/plot_CF.png" width="410"> <img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_residual_scatterplots/residual_plot_CF.png" width="410">

Formula = salaries ~ RE24 + UZR_150
| Coefficient   | Estimate      | P-value  |
| ------------- |:-------------:| --------:|
| Intercept     | 8,941,887     | 1.31e-05 |
| RE24          | 259,879       | 0.000463 |
| UZR_150       | -75,184       | 0.561796 |

Residual standard error: 6389000 on 17 degrees of freedom  
Multiple R-squared:  0.5279,	Adjusted R-squared:  0.4723  
F-statistic: 9.504 on 2 and 17 DF,  p-value: 0.001696  

---
---
## RF
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_scatterplots/plot_RF.png" width="410"> <img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_residual_scatterplots/residual_plot_RF.png" width="410">

Formula = salaries ~ RE24 + UZR_150
| Coefficient   | Estimate      | P-value  |
| ------------- |:-------------:| --------:|
| Intercept     | 7,246,300     | 0.00917  |
| RE24          | 321,826       | 0.01583  |
| UZR_150       | 100,973       | 0.41795  |

Residual standard error: 7244000 on 13 degrees of freedom  
Multiple R-squared:  0.4392,	Adjusted R-squared:  0.353   
F-statistic: 5.092 on 2 and 13 DF,  p-value: 0.02328  

---
---
## C
<img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_scatterplots/plot_C.png" width="410"> <img src="https://github.com/alex-susi/baseball_proj_1/blob/master/model_residual_scatterplots/residual_plot_C.png" width="410">

Formula = salaries ~ RE24 + DEF
| Coefficient   | Estimate      | P-value  |
| ------------- |:-------------:| --------:|
| Intercept     | 5,552,639     | 0.0145   |
| RE24          | 137,839       | 0.3682   |
| DEF           | 266,894       | 0.1004   |

Residual standard error: 6098000 on 14 degrees of freedom  
Multiple R-squared:  0.1845,	Adjusted R-squared:  0.06797   
F-statistic: 1.583 on 2 and 14 DF,  p-value: 0.2399  

---


# Conclusions and Future Steps
* While many of the models aren't statistically significant, it is clear that teams value offense more from certain positions (RF, CF, 3B) and value defense more from others (C, 1B)  
* The low R-squared values indicate that teams aren't necessarily paying players solely based on their RE24 and UZR/150 or DEF
* While these metrics are one way of valuing players, there are many other stats that teams look at for determining a player's worth (WAR, wOBA, wRC, DRS, etc.)
* Future steps could include more variables such as age, recent awards won, and off-field components such as merchandise and ticket revenue brought in by the player (mainly useful for superstars)
* The regressions could also include RE24 and UZR/150 over the course of multiple seasons to get a better idea of a player's true skill, since players can have up or down seasons (i.e. due to injury)
* One final point to make note of is that this model consistently claims that many highly paid players are not worth the large, lengthy contracts they recieve. Older players still on larger contracts such as Albert Pujols and Robinson Cano are some of the most overpaid players according to the models. While Pujols and Cano were both elite talents in their primes, they have since regressed significantly while still making $29 and $24 million respectively in 2020. This could be an indicator that those long lucrative contracts extending well into a player's late 30s or early 40s are rarely worth it, and teams might be better off with shorter contracts to their superstar players, especially since you need a well-rounded roster to compete in the MLB 





