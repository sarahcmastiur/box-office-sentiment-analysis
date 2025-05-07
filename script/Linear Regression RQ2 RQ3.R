# Install/load necessary packages
# install.packages(c("tidyverse", "readr"))
library(tidyverse)
library(readr)

# 1. Read in your merged dataset
combined_model1 <- read_csv("/Users/mac/Documents/Term 2/Applied Analytics Frameworks and Methods II/Group project/combined_movie_data_updated.csv")

# 2. Clean up the BoxOffice column and create a log‐transformed target
combined_model1 <- combined_model1 %>%
  mutate(
    BoxOffice_Global = parse_number(BoxOffice_Global),         # strips “$” and commas → numeric
    Log_BoxOffice = log(BoxOffice_Global)               # log transform to stabilize variance
  )


model_RQ2 <- lm(
  Log_BoxOffice ~ 
    IMDb_Rating + 
    RottenTomatoes + 
    Metacritic + 
    Reddit_Sentiment + 
    YouTube_Sentiment, 
  data = combined_model1
)


#RQ3
library(tidyverse)
library(car)  

# Research Question 3 Model
model_RQ3 <- lm(
  Log_BoxOffice~ 
    Genre,
  data = combined_model1
)

summary(model_RQ3)


