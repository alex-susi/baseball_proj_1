library(ggplot2)

## Read in RE24 and scrape salary data ------------------------------------
re24 <- read.csv("RE24.csv")
re24 <- re24[-c(X)]
re24 %>%
  filter(PA >= 300) -> re24_300

source("salary_scraper.R")
all_salaries_2020 <- scrape_salaries(2020)


## Key for converting Positions to abbreviations --------------------------
full <- c("Designated Hitter", '1st Base', 
          '2nd Base', 'Shortstop',
          '3rd Base', 'Left Field',
          'Center Field', 'Right Field',
          'Catcher')
Position <- c('DH', '1B', '2B', 'SS','3B', 'LF', 'CF',
              'RF', 'C')
position_key <- data.frame(full, Position)


## ------------------------------------------------------------------------
# Clean Salary data, convert positions to abbreviations
all_salaries_2020 <- all_salaries_2020 %>% 
  mutate_if(is.character, str_replace_all, pattern = " Jr.", replacement = "") %>%
  left_join(position_key, by = c("positions" = "full"))


# Join Salary data with RE24 data
re24_300 %>%
  inner_join(all_salaries_2020, 
             by = c("nameFirst" = "FirstName", "nameLast" = "LastName")) -> re24_300


# Plot RE24 vs Salaries
ggplot(re24_300, aes(salaries, RE24)) +  
  geom_point() +  
  geom_smooth() +  
  geom_hline(yintercept = 0, color = "blue") -> re_salaries  
re_salaries


# Reading in Defensive Stats, cleaning, and joining with RE24
fangraphs_def <- read.csv("FanGraphs Leaderboard Def.csv")
fangraphs_def <- fangraphs_def %>% 
  extract(ï..Name, c("FirstName", "LastName"), "([^ ]+) (.*)") %>%
  select("FirstName", "LastName", "Team", "Pos", 
         "Inn", "UZR.150", "Def", "playerid") %>%
  filter(Pos != "P") %>%
  select("FirstName", "LastName", "Inn", "UZR.150", "Def", "playerid") %>%
  filter(Inn >= 300) %>%
  mutate_if(is.character, str_replace_all, 
            pattern = " Jr.", replacement = "") %>%
  group_by(playerid) %>%
  summarize(FirstName, LastName, total_inn = sum(Inn), 
            total_def = sum(Def), UZR_150 = sum(UZR.150)) %>%
  arrange(desc(total_def))

re24_300 %>%
  inner_join(fangraphs_def, 
             by = c("nameFirst" = "FirstName", "nameLast" = "LastName")) %>%
  distinct() %>%
  select(-playerid, -positions) %>%
  select("nameFirst", "nameLast", "BAT_ID", "Position", "RE24", "PA",
         "Runs.Start", "salaries", "total_inn", "total_def", "UZR_150")-> re24_300

ggplot(re24_300, aes(RE24, total_def)) +  
  geom_point() +  
  geom_smooth() +  
  geom_hline(yintercept = 0, color = "blue") -> re_def  
re_def 


write.csv(re24_300, file = "RE24_300.csv")



# Cluster Summary by Position
re24_300 %>%
  group_by(Position) %>%
  summarize(N = n(), Avg_Salary = mean(salaries), Avg_RE24 = mean(RE24),
            Avg_def = mean(total_def)) %>%
  filter(Position != "NA") -> cluster_summary

write.csv(cluster_summary, file = "cluster_summary.csv")







