# box-office-sentiment-analysis
An R-based analytics pipeline to scrape, clean, and analyze YouTube trailer comments from upcoming 2024/2025 movies, with the goal of understanding how audience sentiment and keyword signals may correlate with box office performance.


## Project Overview

This project explores the relationship between public sentiment expressed in YouTube trailer comments and the financial success of films at the global box office.

It involves:
- Web scraping using the **YouTube Data API**, **Reddit API**, and **OMDb API**
- Natural language cleaning and **sentiment keyword tracking**
- Proportional sentiment scoring across movies
- Correlation analysis with box office revenue


## Research Question

RQ1: What emotional tones dominate the trailer comment sections of anticipated 2024/2025 films?

RQ2: Do higher average user ratings on IMDb, RT, and Metacritic significantly correlate with box office success?

RQ3: Can YouTube sentiment signal box office performance through keyword frequency and tone?


## File Directory Overview
    box-office-sentiment-analysis/
    ├── script/
    │   └── Youtube API_2.R # Scraping YouTube comments
    │   └── R Code for Movies Rating.R # Rating source ingestion (IMDb, RT, Metacritic)
    │   └── RQ1_tone_analysis_data_prep.R # Text cleaning & sentiment keyword tagging
    │   └── RQ1_model_analysis.R # Analysis of tone-specific variables
    │   └── Linear Regression RQ2 RQ3.R # Baseline regression for ratings & box office
    │   └── RQ2_RQ3_xgb_model_analysis.R # XGBoost modeling on structured predictors
    ├── data/
    │   └── combined_movie_data_updated.csv # Final movie dataset (ratings + box office)
    │   └── reddit_comments.csv # Reddit-sourced text comments (optional)
    │   └── sentiments_tone_specific_update.csv # Normalized tone metrics by movie
    │   └── youtube_movie_comments_cleaned.csv # Scraped and cleaned YouTube
    ├── README.Rmd  # This file


