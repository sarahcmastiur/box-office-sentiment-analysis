library(httr)
library(jsonlite)
library(dplyr)

# Replace with your OMDB API key
api_key <- "1b7d4dac"


# Function to fetch movie details from OMDB
get_movie_details <- function(imdb_id) {
  url <- paste0("http://www.omdbapi.com/?apikey=", api_key, "&i=", imdb_id)
  response <- GET(url)
  data <- content(response, as = "text", encoding = "UTF-8")
  json_data <- fromJSON(data, flatten = TRUE)
  
  if (json_data$Response == "True") {
    # Initialize Rotten Tomatoes as NA
    rotten_tomatoes <- NA
    
    # Check if Ratings exist and are a list
    if ("Ratings" %in% names(json_data) && is.list(json_data$Ratings)) {
      # Convert Ratings into a data frame
      ratings_df <- as.data.frame(json_data$Ratings)
      
      # Check if Rotten Tomatoes exists in the Ratings
      if ("Source" %in% colnames(ratings_df) && "Value" %in% colnames(ratings_df)) {
        rt_index <- which(ratings_df$Source == "Rotten Tomatoes")
        if (length(rt_index) > 0) {
          rotten_tomatoes <- ratings_df$Value[rt_index]
        }
      }
    }
    
    return(data.frame(
      IMDb_ID = imdb_id,
      Title = json_data$Title,
      Year = json_data$Year,
      Genre = json_data$Genre,
      IMDb_Rating = json_data$imdbRating,
      RottenTomatoes = rotten_tomatoes,
      Metacritic = json_data$Metascore,
      BoxOffice = json_data$BoxOffice,
      Production = json_data$Production,
      Director = json_data$Director,
      Actors = json_data$Actors,
      Plot = json_data$Plot,
      stringsAsFactors = FALSE
    ))
  } else {
    return(data.frame(
      IMDb_ID = imdb_id,
      Title = NA,
      Year = NA,
      Genre = NA,
      IMDb_Rating = NA,
      RottenTomatoes = NA,
      Metacritic = NA,
      BoxOffice = NA,
      Production = NA,
      Director = NA,
      Actors = NA,
      Plot = NA,
      stringsAsFactors = FALSE
    ))
  }
}

# Apply function to all IMDb IDs
movie_details_list <- lapply(movies_df$Const, get_movie_details)

# Combine results into a dataframe
movie_details_df <- bind_rows(movie_details_list)


write.csv(movie_details_df, "updated_movie_list.csv", row.names = FALSE)
