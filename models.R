library(dplyr)
library(ggplot2)
library(car)

model_all <- lm(salaries ~ RE24 + total_def, data = re24_300)
summary(model_all)


model_by_position <- lm(salaries ~ RE24 + total_def + Position, data = re24_300)
summary(model_by_position)




## ------------------------------------------------------------------------
model_builder <- function(pos) {
  # Builds a linear model for each position
  re24_300 %>% 
    filter(Position == pos) -> filtered
  
  if(pos == "C") {
    return(lm(salaries ~ RE24 + total_def, data = filtered))
  } else {
    return(lm(salaries ~ RE24 + UZR_150, data = filtered))
  }
}


## ------------------------------------------------------------------------
scat_plot_builder <- function(pos) {
  # Creates scatter plot of RE24 and total_def or UZR_150
  re24_300 %>% 
    filter(Position == pos) -> filtered
  
  if(pos == "C") {
    ggplot(filtered, aes(RE24, total_def)) +  
      geom_point() +  
      geom_smooth() +  
      geom_hline(yintercept = 0, color = "blue") + 
      ggtitle(paste0("RE24 vs. DEF: ", pos)) + 
      theme(plot.title = element_text(hjust = 0.5)) -> plot
    ggsave(paste0("model_scatterplots/plot_", pos, ".pdf"), plot = plot)
    return(plot)
  } else {
    ggplot(filtered, aes(RE24, UZR_150)) +  
      geom_point() +  
      geom_smooth() +  
      geom_hline(yintercept = 0, color = "blue")+ 
      ggtitle(paste0("RE24 vs. UZR/150: ", pos)) +
      theme(plot.title = element_text(hjust = 0.5)) -> plot
    ggsave(paste0("model_scatterplots/plot_", pos, ".pdf"), plot = plot)
    return(plot)
  }
}


## ------------------------------------------------------------------------
residual_builder <- function(pos, linmod) {
  # Creates table with fitted and residual data
  re24_300 %>% 
    filter(Position == pos) -> filtered
  
  if(pos == "C") {
    inner_join(filtered, fortify(linmod), by = c("RE24", "total_def", "salaries"))
  } else {
    inner_join(filtered, fortify(linmod), by = c("RE24", "UZR_150", "salaries"))
  }
}


## ------------------------------------------------------------------------
residual_plots <- function(pos, data) {
  # Plots residuals
  re24_300 %>% 
    filter(Position == pos) -> filtered
  
  ggplot(data = data, aes(x = .fitted, y = .resid)) + 
    geom_point()
}


## ------------------------------------------------------------------------
get_coefs <- function(pos, linmod) {
  # Returns model coefficients
  df <- data.frame(linmod$coefficients)
  df <- as.data.frame(t(df))
  `rownames<-`(df, paste0("coefs_", pos))
}



## ------------------------------------------------------------------------
all_coefs <- data.frame()
for (p in Position) {
  name <- paste0("model_", p)
  assign(name, model_builder(p))
  
  plot_name <- paste0("plot_", p)
  assign(plot_name, scat_plot_builder(p))
  
  resids_name <- paste0("resids_", p)
  assign(resids_name, residual_builder(p, model_builder(p)))
  
  resids_plot_name <- paste0("resids_plot_", p)
  assign(resids_plot_name, residual_plots(p, residual_builder(p, model_builder(p))))
  
  coefs_name <- paste0("coefs_", p)
  assign(coefs_name, get_coefs(p, model_builder(p)))
  
  all_coefs <- bind_rows(all_coefs, assign(coefs_name, get_coefs(p, model_builder(p))))
  
}


















