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


## Data and Information

In the process of developing our analysis to prove or disprove the research questions, our team is going to be working with a dataset that consists of information relating to social media engagements and interactions for the Top 100 grossing films in 2024. This dataset is extracted from several channels - namely IMDb, rotten tomatoes, metacritic, youtube comments, and reddit threads.

### 1. IMDb, Rotten tomatoes, and metacritic

IMDb Rating, Rotten Tomatoes and Metacritic are gathered from web scraping through the OMDB API. The OMDb API is a RESTful web service that functions to facilitate API communication with the IMDb website and acquire film-related information from the portal. 

### 2. YouTube

Through establishing connection with Google Cloud Console, our team was able to perform web scraping on the YouTube comment section from each of the enlisted movie trailers.

### 3. Reddit

We used the Reddit API to collect comments from official discussion threads in the r/movies subreddit. Our focus was on threads titled "Official Discussion - <Movie Title> [SPOILERS]" to analyze audience reactions to different movies.


## Analytical Techniques and Results

### RQ1: Do viewer sentiments predict box office performance?

We analyzed sentiment tones (e.g., trust, joy, fear) extracted from Reddit and YouTube comments using the NRC lexicon. Initial linear and principal component regressions showed no statistically significant predictors, with PCA explaining only 10.5% of revenue variance.
However, machine learning models offered a deeper look:

- XGBoost highlighted trust, positive, anticipation, and anger as the most important features.

- Random Forest, in contrast, ranked joy and fear higher, while trust had minimal importance.

These discrepancies stem from how each model captures feature interactions, with XGBoost modeling nonlinear effects and Random Forest evaluating individual contributions. Overall, sentiment tone alone is not a strong predictor of box office performance, and we fail to reject the null hypothesis.

### RQ2: Do platform ratings and online sentiments drive box office outcomes?

Using linear regression, we assessed five predictors: IMDb rating, Rotten Tomatoes score, Metacritic rating, YouTube sentiment, and Reddit sentiment. Results showed:

- IMDb rating, YouTube sentiment, and Metacritic rating had statistically significant effects (p < 0.05) on box office revenue.

- Rotten Tomatoes and Reddit sentiment showed no significant relationship.

This indicates that not all platforms equally influence audience turnout, with IMDb being the strongest predictor in this model.


### RQ3: Does movie genre affect box office success?

We evaluated whether genre combinations influence movie revenue using linear regression. Out of 20 genre categories:

- 13 combinations (e.g., Drama, Fantasy, Musical, Comedy, Drama, Thriller) showed statistically significant effects, mostly negative.

- Mixed genres involving horror and thriller were also linked with lower box office performance.

These findings suggest genre blending may suppress audience turnout, revealing nuanced dynamics in viewer preferences.




## File Directory Overview
    box-office-sentiment-analysis/
    ├── data/
    │   └── 33681f1b-39fe-4719-afc2-872e37dac5ce.csv # OMDb raw dataset
    │   └── combined_movie_data_updated.csv # Final movie dataset (ratings + box office)
    │   └── reddit_comments.csv # Reddit-sourced text comments (optional)
    │   └── sentiments_tone_specific_update.csv # Normalized tone metrics by movie
    │   └── youtube_movie_comments_cleaned.csv # Scraped and cleaned YouTube
    ├── script/
    │   └── Youtube API_2.R # Scraping YouTube comments
    │   └── R Code for Movies Rating.R # Rating source ingestion (IMDb, RT, Metacritic)
    │   └── RQ1_tone_analysis_data_prep.R # Text cleaning & sentiment keyword tagging
    │   └── RQ1_model_analysis.R # Analysis of tone-specific variables
    │   └── Linear Regression RQ2 RQ3.R # Baseline regression for ratings & box office
    │   └── RQ2_RQ3_xgb_model_analysis.R # XGBoost modeling on structured predictors
    ├── README.Rmd  # This file


