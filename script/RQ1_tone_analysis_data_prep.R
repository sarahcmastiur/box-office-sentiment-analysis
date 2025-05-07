setwd("C:/Users/james/Downloads/APAN 5205 group project movies")

'''
reddit 
-------------------
'''

movie_comments_red = read.csv(file = 'reddit_comments.csv')
library(stringr)

movie_comments_red_data =  data.frame(
                             id = movie_comments_red$Comment_Number,
                             movie = movie_comments_red$Movie_Title,
                             comments = movie_comments_red$Comment_Text)


movie_comments_red_words = 
  movie_comments_red_data %>%
  select(id, movie, comments) %>%
  unnest_tokens(output = word, input = comments)

colnames(movie_comments_red_data)

sentiment_counts_red = movie_comments_red_words %>%
  inner_join(get_sentiments("nrc"), by = "word", relationship = "many-to-many") %>%
  group_by(movie, sentiment) %>%
  summarise(count = n(), .groups = "drop")

# Pivot wider to get tones as columns for each movie
sentiment_wide_red = sentiment_counts_red %>%
  pivot_wider(names_from = sentiment, values_from = count, values_fill = 0)

# View result
sentiment_wide_red

movie_combined = read.csv(file = 'combined_movie_data_updated.csv')

red_sentiment_wide = 
  sentiment_wide_red %>%
  left_join(movie_combined %>% 
              select(Title, BoxOffice_Global), by = c("movie" = "Title"))


write.csv(red_sentiment_wide, "reddit_sentiments_specific.csv", row.names = FALSE)




library(tidytext); library(dplyr)
movie_comments_red_words = 
  movie_comments_red_data%>%
  group_by(id)%>%
  unnest_tokens(output = word,input = comments)%>%
  ungroup()
movie_comments_red_words


library(ggplot2)
movie_comments_red_words |>
  inner_join(y = get_sentiments('bing'),by = c('word' = 'word'))|>
  group_by(sentiment)|>
  count()|>
  ggplot(aes(x = sentiment, y = n))+
  geom_col()+
  xlab('')+
  coord_flip()+
  theme_minimal()


library(ggplot2)
movie_comments_red_words |>
  inner_join(y = get_sentiments('nrc'),by = c('word' = 'word'))|>
  group_by(sentiment)|>
  count()|>
  ggplot(aes(x = reorder(sentiment,n), y = n))+
  geom_col()+
  xlab('')+
  coord_flip()+
  theme_minimal()


library(tidyr); library(wordcloud)

custom_stopwords = data.frame(
  word = c('movie', 'MOVIE', 'Movie', 'film', 'FILM', 'Film'),
  lexicon = 'custom'
)
wordcloud_data_red= 
  movie_comments_red_words %>%
  anti_join(rbind(stop_words, custom_stopwords),by = 'word')%>%
  inner_join(get_sentiments('bing'),by='word')%>%
  count(sentiment, word,sort=T)%>%
  ungroup()%>%
  spread(key = sentiment,value = 'n',fill = 0)

wordcloud_data_red= as.data.frame(wordcloud_data_red)
rownames(wordcloud_data_red) = wordcloud_data_red[,'word']
wordcloud_data_red = wordcloud_data_red[,c('positive','negative')]

comparison.cloud(wordcloud_data_red, scale=c(2,0.5),max.words = 200, rot.per=0, random.order = F)

'''
youtube
---------------
'''  

#setwd("C:/Users/james/Downloads")

movie_comments_yt = read.csv(file = 'youtube_movie_comments_cleaned (1).csv')

# comment word length (count)
movie_comments_yt %>% 
  select(Movie, textDisplay) %>% 
  group_by(Movie) %>% 
  unnest_tokens(output = word, input = textDisplay) %>% 
  ungroup() %>% 
  group_by(Movie) %>% 
  summarize(count = n())

# sentiment analysis: afinn (quantifiable)
afinn_yt = get_sentiments('afinn')
ytsentiments = movie_comments_yt %>% 
  group_by(Movie) %>% 
  unnest_tokens(output = word, input = textDisplay) %>% 
  inner_join(afinn_yt) %>% 
  group_by(Movie) %>% 
  summarize(reviewSentiment = mean(value))



movie_comments_yt_data =  data.frame(
  id = movie_comments_yt$videoId,
  movie = movie_comments_yt$Movie,
  comments = movie_comments_yt$textDisplay)


movie_comments_yt_data$comment = 
  movie_comments_yt_data$comments|>
  str_remove_all(pattern = "['\\n','\030','\031','\034','\035']")|>
  str_remove_all(pattern = 'http[[:alnum:][:punct:]]*')


movie_comments_yt_words = 
  movie_comments_yt_data %>%
  select(id, movie, comments) %>%
  unnest_tokens(output = word, input = comments)


library(ggplot2)
movie_comments_yt_words |>
  inner_join(y = get_sentiments('nrc'),by = c('word' = 'word'))|>
  group_by(sentiment)|>
  count()|>
  ggplot(aes(x = reorder(sentiment,n), y = n))+
  geom_col()+
  xlab('')+
  coord_flip()+
  theme_minimal()


colnames(movie_comments_yt_data)

sentiment_counts_yt = movie_comments_yt_words %>%
  inner_join(get_sentiments("nrc"), by = "word", relationship = "many-to-many") %>%
  group_by(movie, sentiment) %>%
  summarise(count = n(), .groups = "drop")

# Pivot wider to get tones as columns for each movie
sentiment_wide_yt = sentiment_counts_yt %>%
  pivot_wider(names_from = sentiment, values_from = count, values_fill = 0)

# View result
sentiment_wide_yt

movie_combined = read.csv(file = 'combined_movie_data_updated.csv')

yt_sentiment_wide = 
  sentiment_wide_yt %>%
  left_join(movie_combined %>% 
              select(Title, BoxOffice_Global), by = c("movie" = "Title"))


write.csv(yt_sentiment_wide, "youtube_sentiments_specific_updated.csv", row.names = FALSE)




library(tidyr); library(wordcloud)

custom_stopwords = data.frame(
  word = c('movie', 'MOVIE', 'Movie', 'film', 'FILM', 'Film'),
  lexicon = 'custom'
)
wordcloud_data_yt= 
  movie_comments_yt_words %>%
  anti_join(rbind(stop_words, custom_stopwords),by = 'word')%>%
  inner_join(get_sentiments('bing'),by='word')%>%
  count(sentiment, word,sort=T)%>%
  ungroup()%>%
  spread(key = sentiment,value = 'n',fill = 0)

wordcloud_data_yt= as.data.frame(wordcloud_data_yt)
rownames(wordcloud_data_yt) = wordcloud_data_yt[,'word']
wordcloud_data_yt = wordcloud_data_yt[,c('positive','negative')]

comparison.cloud(wordcloud_data_yt, scale=c(2,0.5),max.words = 200, rot.per=0, random.order = F)

'''
combine of two apis
---------------
'''


sentiment_combined = bind_rows(sentiment_wide_yt, sentiment_wide_red)

# Step 3: Sum tone counts by movie
sentiment_aggregated = sentiment_combined %>%
  group_by(movie) %>%
  summarise(across(everything(), sum, na.rm = TRUE))

sentiment_aggregated

sentiment_final = sentiment_aggregated %>%
  left_join(movie_combined %>% select(Title, BoxOffice_Global), 
            by = c("movie" = "Title"))

sentiment_final$BoxOffice_Global = parse_number(sentiment_final$BoxOffice_Global)
sentiment_final

tone_columns = setdiff(names(sentiment_final), c("movie", "BoxOffice_Global"))

sentiment_final = sentiment_final %>%
  rowwise() %>%
  mutate(total_tones = sum(c_across(all_of(tone_columns)), na.rm = TRUE)) %>%
  ungroup()

sentiment_normalized = sentiment_final %>%
  mutate(across(all_of(tone_columns), ~ .x / total_tones)) %>%
  select(-total_tones)

sentiment_normalized

write.csv(sentiment_normalized, "sentiments_tone_specific_update.csv", row.names = FALSE)



sentiment_score = sentiment_aggregated %>%
  left_join(movie_combined %>% select(Title, IMDb_Rating, RottenTomatoes, Metacritic), 
            by = c("movie" = "Title"))

sentiment_score


write.csv(sentiment_score, "sentiments_tone_score_with_rating.csv", row.names = FALSE)
