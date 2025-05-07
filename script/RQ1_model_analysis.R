library(tidyverse)
library(caret)
library(xgboost)
library(corrplot)
library(tidyr); library(wordcloud)

df <- read_csv("sentiments_tone_specific_update.csv")

df$BoxOffice_Global = parse_number(df$BoxOffice_Global) # convert to numeric

glimpse(df)

df_numeric <- df |> 
  select(-movie)

#correlation matrix
cor_matrix <- cor(df_numeric, use = "complete.obs")
corrplot(cor_matrix, method = "color", type = "lower", tl.cex = 0.8)

#linear regression
lm_model <- lm(BoxOffice_Global ~ ., data = df_numeric)
summary(lm_model)

#xg boost
set.seed(1031)
train_index <- createDataPartition(df_numeric$BoxOffice_Global, p = 0.8, list = FALSE)
train_data <- df_numeric[train_index, ]
test_data <- df_numeric[-train_index, ]

dtrain <- xgb.DMatrix(data = as.matrix(train_data |> 
                                         select(-BoxOffice_Global)), 
                      label = train_data$BoxOffice_Global)
dtest <- xgb.DMatrix(data = as.matrix(test_data |>
                                        select(-BoxOffice_Global)), 
                     label = test_data$BoxOffice_Global)

xgb_model <- xgboost(data = dtrain, 
                     nrounds = 100, 
                     objective = "reg:squarederror", 
                     verbose = 0)

importance <- xgb.importance(model = xgb_model)
xgb.plot.importance(importance_matrix = importance)


#random forest
library(randomForest)
set.seed(1031)

rf_model <- randomForest(BoxOffice_Global ~ ., data = df_numeric, importance = TRUE)
summary(rf_model)

importance(rf_model)
varImpPlot(rf_model)


#principal component regression
library(pls)

pcr_model <- pcr(BoxOffice_Global ~ ., data = df_numeric, scale = TRUE, validation = "CV")

summary(pcr_model)




sentiment_score = read.csv("sentiments_tone_score_with_rating.csv")


library(tidyr)

score_rating_IMDb = sentiment_score %>%
  pivot_longer(cols = anger:trust, names_to = 'sentiment', values_to = 'n') %>%
  mutate(IMDb_Rating = round(IMDb_Rating)) %>%
  group_by(sentiment, IMDb_Rating) %>%
  summarize(n = mean(n), .groups = 'drop') %>%
  ggplot(aes(x = IMDb_Rating, y = n, fill = as.factor(IMDb_Rating))) +
  geom_col() +
  facet_wrap(~sentiment) +
  coord_flip() +
  theme_bw() +
  scale_fill_discrete(name = "Score Range", limits = as.character(rev(4:8))) +
  theme(
    axis.text.x = element_blank(),    
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank())
score_rating_IMDb

score_rating_RT = sentiment_score %>%
  pivot_longer(cols = anger:trust, names_to = 'sentiment', values_to = 'n') %>%
  mutate(RottenTomatoes = floor(RottenTomatoes / 10) * 10) %>%
  group_by(sentiment, RottenTomatoes) %>%
  summarize(n = mean(n), .groups = 'drop') %>%
  ggplot(aes(x = RottenTomatoes, y = n, fill = as.factor(RottenTomatoes))) +
  geom_col() +
  facet_wrap(~sentiment) +
  coord_flip() +
  scale_fill_discrete(name = "Score Range", limits = as.character(rev(seq(0, 100, by = 10)))) +
  theme_bw() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank())
score_rating_RT

score_rating_MC = sentiment_score %>%
  pivot_longer(cols = anger:trust, names_to = 'sentiment', values_to = 'n') %>%
  mutate(Metacritic = floor(Metacritic / 10) * 10) %>%
  group_by(sentiment, Metacritic) %>%
  summarize(n = mean(n), .groups = 'drop') %>%
  ggplot(aes(x = Metacritic, y = n, fill = as.factor(Metacritic))) +
  geom_col() +
  facet_wrap(~sentiment) +
  coord_flip() +
  scale_fill_discrete(name = "Score Range", limits = as.character(rev(seq(20, 90, by = 10)))) +
  theme_bw() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank())
score_rating_MC
