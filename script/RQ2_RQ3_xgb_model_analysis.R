# Install/load necessary packages
# install.packages(c("tidyverse", "readr"))
library(tidyverse)
library(readr)

# 1. Read in your merged dataset
setwd("C:/Users/james/Downloads")
combined_model1 <- read_csv("combined_movie_data_updated.csv")

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
summary(model_RQ2)

#xg boost
set.seed(1031)
library(caret)
library(xgboost)


df_numeric_q2 <- combined_model1 |>
  select(BoxOffice_Global, IMDb_Rating, RottenTomatoes, Metacritic, Reddit_Sentiment, YouTube_Sentiment)

train_index_q2 <- createDataPartition(df_numeric_q2$BoxOffice_Global, p = 0.8, list = FALSE)
train_data_q2 <- df_numeric_q2[train_index, ]
test_data_q2 <- df_numeric_q2[-train_index, ]

dtrain_q2 <- xgb.DMatrix(data = as.matrix(train_data_q2 |> select(-BoxOffice_Global)),
                      label = train_data_q2$BoxOffice_Global)
dtest_q2 <- xgb.DMatrix(data = as.matrix(test_data_q2 |> select(-BoxOffice_Global)),
                     label = test_data_q2$BoxOffice_Global)

xgb_model_q2 <- xgboost(data = dtrain_q2,
                     nrounds = 100,
                     objective = "reg:squarederror",
                     verbose = 0)

importance_q2 <- xgb.importance(model = xgb_model_q2)
xgb.plot.importance(importance_matrix = importance_q2)




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


#xgb
library(recipes)

glimpse(combined_model1$Genre)

genre_recipe <- recipe(BoxOffice_Global ~ Genre, data = combined_model1) |>
  step_dummy(all_nominal_predictors()) |>
  prep()

df_genre <- bake(genre_recipe, new_data = NULL)

train_index_genre <- createDataPartition(df_genre$BoxOffice_Global, p = 0.8, list = FALSE)
train_data_genre <- df_genre[train_index, ]
test_data_genre <- df_genre[-train_index, ]

dtrain_genre <- xgb.DMatrix(data = as.matrix(train_data_genre |> select(-BoxOffice_Global)),
                            label = train_data_genre$BoxOffice_Global)
dtest_genre <- xgb.DMatrix(data = as.matrix(test_data_genre |> select(-BoxOffice_Global)),
                           label = test_data_genre$BoxOffice_Global)

xgb_model_q3 <- xgboost(data = dtrain_genre,
                        nrounds = 100,
                        objective = "reg:squarederror",
                        verbose = 0)

importance_q3 <- xgb.importance(model = xgb_model_q3)
xgb.plot.importance(importance_matrix = importance_q3)

