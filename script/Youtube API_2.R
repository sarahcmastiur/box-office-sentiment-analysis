# load the packages
install.packages("tuber")
install.packages("tidyverse")
install.packages("jsonlite")
install.packages("httr")

library(tuber)
library(tidyverse)
library(jsonlite)
library(httr)
library(dplyr)

if (file.exists(".httr-oauth")) file.remove(".httr-oauth")

movies_df = read.csv("~/Downloads/33681f1b-39fe-4719-afc2-872e37dac5ce.csv")

# Print first 5 movie titles
print(head(movies_df$Title, 5))

# 🔒 Quota-safe comment availability checker
api_key = "" #sanitized

# ✅ Function to search for YouTube video ID using API key
search_youtube_video_by_api_key <- function(query, api_key) {
  url <- paste0(
    "https://www.googleapis.com/youtube/v3/search?part=snippet",
    "&q=", URLencode(query),
    "&type=video",
    "&maxResults=1",
    "&key=", api_key
  )
  
  response <- tryCatch({
    GET(url)
  }, error = function(e) {
    message("❌ API call failed for search query: ", query)
    return(NULL)
  })
  
  if (is.null(response) || http_error(response)) {
    message("❌ API error on search for: ", query)
    return(NA)
  }
  
  parsed <- content(response, as = "parsed", type = "application/json")
  
  if (length(parsed$items) > 0) {
    return(parsed$items[[1]]$id$videoId)
  } else {
    return(NA)
  }
}

# ✅ Function to get YouTube comments using API key
get_comments_by_api_key <- function(video_id, api_key, max_results = 25) {
  url <- paste0(
    "https://www.googleapis.com/youtube/v3/commentThreads?",
    "part=snippet&videoId=", video_id,
    "&maxResults=", max_results,
    "&textFormat=plainText",
    "&key=", api_key
  )
  
  response <- tryCatch({
    GET(url)
  }, error = function(e) {
    message("❌ Failed to reach API for video ID: ", video_id)
    return(NULL)
  })
  
  if (is.null(response) || http_error(response)) {
    message("❌ HTTP error for video ID: ", video_id,
            " — Status: ", status_code(response))
    return(NULL)
  }
  
  parsed <- tryCatch({
    content(response, as = "parsed", type = "application/json")
  }, error = function(e) {
    message("⚠️ Parsing error for video ID: ", video_id)
    return(NULL)
  })
  
  if (is.null(parsed$items) || length(parsed$items) == 0) return(NULL)
  
  comments <- lapply(parsed$items, function(item) {
    snippet <- item$snippet$topLevelComment$snippet
    data.frame(
      videoId = video_id,
      authorDisplayName = snippet$authorDisplayName,
      textDisplay = snippet$textDisplay,
      textOriginal = snippet$textOriginal,
      likeCount = snippet$likeCount,
      publishedAt = snippet$publishedAt,
      updatedAt = snippet$updatedAt,
      stringsAsFactors = FALSE
    )
  })
  
  do.call(rbind, comments)
}

# ✅ Main scraping loop
all_comments <- data.frame()
quota_used <- 0

# Optional: resume from a specific point
start_index <- 1  # change if you're resuming

for (i in start_index:nrow(movies_df)) {
  if (quota_used >= 9800) {
    cat("🚨 Stopping early: Quota cap nearly reached.\n")
    break
  }
  
  movie_title <- trimws(movies_df$Title[i])
  cat("\n🔍 Searching YouTube for:", movie_title, "\n")
  
  video_id <- search_youtube_video_by_api_key(movie_title, api_key)
  quota_used <- quota_used + 100
  
  if (!is.na(video_id) && video_id != "") {
    cat("✅ Found video ID:", video_id, "\n")
    
    comments_data <- tryCatch({
      get_comments_by_api_key(video_id, api_key, max_results = 25)
    }, error = function(e) {
      message("⚠️ Failed to fetch comments for: ", movie_title)
      return(NULL)
    })
    
    quota_used <- quota_used + 1
    
    if (!is.null(comments_data) && nrow(comments_data) > 0) {
      comments_data$Movie <- movie_title
      all_comments <- bind_rows(all_comments, comments_data)
      cat("✅ Added", nrow(comments_data), "comments.\n")
    } else {
      cat("❌ No comments retrieved for", movie_title, "\n")
    }
  } else {
    cat("❌ Skipping:", movie_title, " — no video ID found.\n")
  }
  
  cat("📊 Quota used so far:", quota_used, "units\n")
  Sys.sleep(1.5)
}

# ✅ Save output
ytcomments <- all_comments %>%
  select(videoId, textDisplay, textOriginal, likeCount, publishedAt, updatedAt, Movie)

write.csv(ytcomments, "youtube_movie_comments.csv", row.names = FALSE)
cat("\n✅ Scraping completed! Comments saved to youtube_movie_comments_clean.csv\n")
