library(xml2)
library(data.table)
library(rvest)
library(dplyr)
library(tidyverse)


## Scrape Function -----------------------------------------------------------
get_data <- function(team, year, types) {
  # Goes to site for each team, year, and contract type 
  site <- paste0("https://www.spotrac.com/mlb/rankings/", year, "/", team, "/batters/", types, "/")
  page <- read_html(site)
  
  # Scrapes salaries, player names, and positions
  salaries <- page %>%
    html_nodes(".info") %>%
    html_text()
  
  players <- page %>%
    html_nodes(".team-name") %>%
    html_text()
  
  positions <- page %>%
    html_nodes(".rank-position+ .rank-position") %>%
    html_text()
  
  combined <- cbind(players, positions, salaries)
  
  # Cleans data
  combined[,2] <- trimws(combined[,2], 
                         which = c("both", "left", "right"), 
                         whitespace = "[ \t\r\n]")
  combined[,3] <- as.numeric(gsub('[$,]', '', combined[,3]))
  
  # Writes csv file and returns df
  write.csv(combined, file = paste0("salaries/", 
                                    team, "_salaries_", year, "_", types))
  
  df <- read.csv(paste0("salaries/", team, "_salaries_", year, "_", types))
  df <- df[-c(X)]
  
  return(df)
}



## ------------------------------------------------------------------------
scrape_salaries <- function(year) {
  all_teams <- c("arizona-diamondbacks", "atlanta-braves", "baltimore-orioles", 
                 "boston-red-sox", "chicago-cubs", "chicago-white-sox", 
                 "cincinnati-reds", "cleveland-indians", "colorado-rockies", 
                 "detroit-tigers", "houston-astros", "kansas-city-royals", 
                 "los-angeles-angels", "los-angeles-dodgers", "miami-marlins", 
                 "milwaukee-brewers", "minnesota-twins", "new-york-mets", 
                 "new-york-yankees", "oakland-athletics", "philadelphia-phillies", 
                 "pittsburgh-pirates", "san-diego-padres", "san-francisco-giants", 
                 "seattle-mariners", "st-louis-cardinals", "tampa-bay-rays", 
                 "texas-rangers", "toronto-blue-jays", "washington-nationals")
  
  
  df_master1 <- data.frame()
  
  # Scrapes data for each team, getting veteran and arbitration contracts
  for (i in all_teams) {
    name <- paste0(i, "_salaries")
    if(nrow(assign(name, get_data(i, year, "veteran"))) > 0) {
      df_master1 <- bind_rows(df_master1, 
                              assign(name, get_data(i, year, "veteran")))
    }
    if(nrow(assign(name, get_data(i, year, "arbitration"))) > 0) {
      df_master1 <- bind_rows(df_master1, 
                              assign(name, get_data(i, year, "arbitration")))
    }
  }
  
  # Splits name column into first and last names
  df_master1 <- extract(df_master1, players, 
                        c("FirstName", "LastName"), "([^ ]+) (.*)")
  write.csv(df_master1, paste0("all_salaries_", year, ".csv"))
  
  return(df_master1)

}







