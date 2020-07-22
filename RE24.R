library(Lahman)
library(dplyr)
library(tidyr)

## Getting Retrosheet Data ------------------------------------------------
source("parse_retrosheet_pbp.R")
parse_retrosheet_pbp(2019)

fields <- read.csv("fields.csv")
data2019 <- read.csv("retrosheet/unzipped/all2019.csv", 
                     col.names = pull(fields, Header)) 



## Calculating RE24 -------------------------------------------------------
# Creates Runs.Scored, indicating how many runs were scored on given play
data2019 %>%  
  mutate(RUNS = AWAY_SCORE_CT + HOME_SCORE_CT,  
         HALF.INNING = paste(GAME_ID, INN_CT, BAT_HOME_ID),  
         RUNS.SCORED =  
           (BAT_DEST_ID > 3) + (RUN1_DEST_ID > 3) +  
           (RUN2_DEST_ID > 3) + (RUN3_DEST_ID > 3)) ->  
  data2019 


# Gets runs scored for each half inning
data2019 %>%  
  group_by(HALF.INNING) %>%  
  summarize(Outs.Inning = sum(EVENT_OUTS_CT),  
            Runs.Inning = sum(RUNS.SCORED),  
            Runs.Start = first(RUNS),  
            MAX.RUNS = Runs.Inning + Runs.Start) ->  
  half_innings 


# Joins with Retrosheet PBP data
data2019 %>%  
  inner_join(half_innings, by = "HALF.INNING") %>%  
  mutate(RUNS.ROI = MAX.RUNS - RUNS) ->  
  data2019


# Creates States, in format xxx x
# 1 = runner on base, 0 = base empty
data2019 %>%
  mutate(BASES = 
           paste(ifelse(BASE1_RUN_ID != "", 1, 0),  
                 ifelse(BASE2_RUN_ID != "", 1, 0),  
                 ifelse(BASE3_RUN_ID != "", 1, 0), sep = ""),  
         STATE = paste(BASES, OUTS_CT)) ->  
  data2019 


# NRUNNER indicates if that base was occupied after a play
data2019 %>%  
  mutate(NRUNNER1 =  
           as.numeric(RUN1_DEST_ID == 1 | BAT_DEST_ID == 1),  
         NRUNNER2 =  
           as.numeric(RUN1_DEST_ID == 2 | RUN2_DEST_ID == 2 |  
                        BAT_DEST_ID == 2),  
         NRUNNER3 =  
           as.numeric(RUN1_DEST_ID == 3 | RUN2_DEST_ID == 3 |  
                        RUN3_DEST_ID == 3 | BAT_DEST_ID == 3),  
         NOUTS = OUTS_CT + EVENT_OUTS_CT,  
         NEW.BASES = paste(NRUNNER1, NRUNNER2,  
                           NRUNNER3, sep = ""),  
         NEW.STATE = paste(NEW.BASES, NOUTS)) ->  
  data2019 


# Gets plays where either the state changed or a run(s) scored
data2019 %>%  
  filter((STATE != NEW.STATE) | (RUNS.SCORED > 0)) ->  
  data2019 


# Filters by complete innings only (no walk-offs)
data2019 %>%  
  filter(Outs.Inning == 3) -> data2019C 


# Summarizes each state and its Run Expectancy
data2019C %>%  
  group_by(STATE) %>%  
  summarize(Mean = mean(RUNS.ROI)) %>%  
  mutate(Outs = substr(STATE, 5, 5)) %>%  
  arrange(Outs) -> RUNS 


# Creates Run Expectancy Matrix
RUNS_out <- matrix(round(RUNS$Mean, 2), 8, 3)  
dimnames(RUNS_out)[[2]] <- c("0 outs", "1 out", "2 outs")  
dimnames(RUNS_out)[[1]] <- c("000", "001", "010", "011",  
                             "100", "101", "110", "111")


# Joins RE Matrix with Retrosheet PBP data
data2019 %>%  
  left_join(select(RUNS, -Outs), by = "STATE") %>%  
  rename(Runs.State = Mean) %>%  
  left_join(select(RUNS, -Outs),  
            by = c("NEW.STATE" = "STATE")) %>% 
  rename(Runs.New.State = Mean) %>%  
  replace_na(list(Runs.New.State = 0)) %>%  
  mutate(run_value = Runs.New.State - Runs.State +  
           RUNS.SCORED) -> data2019 


data2019 %>% filter(BAT_EVENT_FL == TRUE) -> data2019b 


# Gets RE24, PA, and Runs.Start for each batter
data2019b %>%  
  group_by(BAT_ID) %>%  
  summarize(RE24 = sum(run_value),  
            PA = length(run_value),  
            Runs.Start = sum(Runs.State)) %>%
  mutate(Run.Pct = RE24/Runs.Start) -> runs 


# Joins with Master to get player names
runs %>%
  inner_join(Master, by = c("BAT_ID" = "retroID")) %>%
  select(nameFirst, nameLast, BAT_ID, RE24, PA, Runs.Start)-> runs


write.csv(runs, "RE24.csv")







