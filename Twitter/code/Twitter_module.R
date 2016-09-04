#---------------------------------------------------------------------------------#
#              Workshop on Web and Social Media for Demographic Research          #
#                                 EPC 2016                                        #
#---------------------------------------------------------------------------------#
#   Module:       Using R to Gather and Analyze Data from Twitter                 #
#   Script:                    Twitter Module                                     #
#   Author:                     Kivan Polimis                                     #
#---------------------------------------------------------------------------------#

#' set working directory
rm(list=ls())
setwd("FILL ME IN/iussp-mainz-social-media/Twitter/code")

#' load libraries
#' uncomment the command below to install the necessary packages
#install.packages(c("twitteR","streamR","ROAuth", "RCurl",  "plyr", "dplyr", "tidyr", "lubridate", "stringr", "base64enc"))

library(twitteR)
library(streamR)
library(ROAuth)
library(RCurl)
library(plyr)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(base64enc)

#' if the twitteR package doesn't install initially, uncommenting the following lines may help 
#install.packages("devtools")
#library(devtools)
#devtools::install_github("jrowen/twitteR", ref = "oauth_httr_1_0")

#' Pablo Barbera, author of streamR, has written additional functions for Twitter analysis
#' uncomment the two commands below to download and add these functions to your environment with source
#download.file("https://raw.githubusercontent.com/pablobarbera/social-media-workshop/master/functions.r","../src/functions_by_pablobarbera.R")
source("../src/functions_by_pablobarbera.R")

#' few functions to clean data
source("../src/twitterFunctions.R") 

#' Twitter credentials for streamR and twitteR authentication
twitter_api_key <- "FILL ME IN"
twitter_api_secret<- "FILL ME IN"
twitter_access_token<- "FILL ME IN"
twitter_access_token_secret<- "FILL ME IN"

#' parameters and URLs for streamR authentication
reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL<- "https://api.twitter.com/oauth/access_token"
authURL<- "https://api.twitter.com/oauth/authorize"

#' Note:  You only need to create an authentication object for streamR once
#' Microsoft Windows users need to uncomment the following command to download a cert file
#download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

#' create an object "cred" that will save the authenticated object for later sessions
twitCred<- OAuthFactory$new(consumerKey=twitter_api_key,consumerSecret=twitter_api_secret,
                            requestURL=reqURL,accessURL=accessURL,authURL=authURL)

#' the `twitCred$handshake` will open a window in your browser and ask you to authorize your application
#' insert the pin number you receive after authorizing in the R console
twitCred$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

#' save authenticated credentials for later sessions
#' for later use, uncomment the following command in a folder that contains twitCred.RData
#load(twitCred)
save(twitCred, file = "twitCred.RData")

#' setup direct Twitter authentication for twitteR package functions
#' you will be prompted to cache an authentication token (.httr-oauth)
#' you will need to reselect direct authentication when you run `setup_twitter_oauth`
#' unless you are running an analysis from a location with a cached authentication token 
setup_twitter_oauth(twitter_api_key, twitter_api_secret,
                    twitter_access_token, twitter_access_token_secret)

## Gather Data ##  

### Search tweets by location ###
#' Search for tweets by location using twitteR package functions. 
#' The functions below interact with the trend portion of the Twitter API.
#'  Use Where on Earth Identifiers for locations

#availableTrendLocations() 
woeid = availableTrendLocations()
glimpse(woeid)

#' get trending Frankfurt area tweets
Frankfurt_tweets = getTrends(650272)
glimpse(Frankfurt_tweets)

#' trending hashtags
glimpse(Frankfurt_tweets$name)
getCommonHashtags(Frankfurt_tweets$name)

### Search Twitter stream by subject ###
#' Search for tweets by subject using streamR package functions. 
#' The streamR functions interact with Twitter's Streaming API to filter tweets by keywords, users, language, and location. 
#' See the streamR vignette  by Pablo Barbera for more information about the package.  

system("mkdir ../data")
#' Windows users may have to manually create a data folder

#' #' create a streaming object to download tweets
#' this object can be called again and will append new tweets to the existing file
physical_activity_tweets_stream<-filterStream("../data/physical_activity_tweets.json",
                                             timeout = 120, language = "en", 
                                             track = c("#walking, #biking, #running, 
                                             #jogging, #pushups, #pullups, #homeworkouts,
                                             #bodyweightexercises, #bodyweightworkouts"),
                                             oauth = twitCred)

read.physical_activity_tweets <- readTweets("../data/physical_activity_tweets.json")
physical_activity_tweets=unlist(read.physical_activity_tweets)

# `parseTweets` reads in tweets .json file with more available columns than `readTweets`
parsed_physical_activity_tweets = parseTweets("../data/physical_activity_tweets.json")

tweet_user_name=physical_activity_tweets[names(physical_activity_tweets)=="user.name"]
tweet_user_id=physical_activity_tweets[names(physical_activity_tweets)=="user.id_str"]
tweet_user_created_at=physical_activity_tweets[names(physical_activity_tweets)=="user.created_at"]
tweet_pic_url=physical_activity_tweets[names(physical_activity_tweets)=="user.profile_image_url"]
tweet_text=physical_activity_tweets[names(physical_activity_tweets)=="text"]

#' removing "_normal"" from url for figure details estimates
tweet_pic_url<-gsub("_normal", "", tweet_pic_url)

#' make a table of users, profile urls and tweet text
tweets_img_table= tbl_df(data.frame(tweet_user_name,tweet_user_id,
                                    tweet_user_created_at,tweet_pic_url, tweet_text))
head(tweets_img_table)
write.csv(tweets_img_table, "../data/tweets_img_table.csv")
#' alternative way to make a table of users and profile urls
#' use if character vectors for user name, id, created at or picture url are not equal
#tweets_table <- tbl_df(matrix(NA,length(tweet_user_name),5))
#colnames(tweets_img_table)<-c("user_name", "user_id",  "user_created_at","tweet_pic_url", "tweet_text")
#for (i in 1:length(tweet_user_name)){
# tweets_img_table[i,1]<-tweet_user_name[i]
# tweets_img_table[i,2]<-tweet_user_id[i]
# tweets_img_table[i,3]<-tweet_user_created_at[i]
# tweets_img_table[i,4]<-tweet_pic_url[i]
# tweets_img_table[i,5]<-tweet_texts[i]
#}
#head(tweets_img_table)

#' use Twitter_face_plus_plus.R here to create Face++ API demographic estimates
#' join tweets_img_table with Face++ demographic estimates
#' convert user_created_at into lubridate object with lubridate_tweet_datestring function
#' example of advantages of lubridate object: plotting,algebraic manipulation on date-time objects.
#tweets_img_table$user_timestamp = sapply(tweets_img_table$user_created_at,lubridate_tweet_datestring)
#drops = "user_created_at"
#tweets_img_table = tweets_img_table[, !(names(tweets_img_table) %in% drops)]
#tweets_img_table = dplyr::rename(tweets_img_table, user_created_at = user_timestamp)
#tweets_img_table = dplyr::rename(tweets_img_table, name = tweet_user_name)
#face_plus_plus_table = tbl_df(read.csv("../data/face_plus_plus_estimates.csv"))
#tweets_table =  inner_join(tweets_img_table, face_plus_plus_table, by = "name")

#write.csv(tweets_table, "../data/physical_activity_tweets.csv", row.names = FALSE)

#' unzip physical_activity_tweets.zip
#' place physical_activity_tweets.csv in the data folder you created earlier
physical_activity_tweets = tbl_df(read.csv("../data/physical_activity_tweets.csv"))

## View summary statistics ## 
### Pipes ###
#' Pipes let you take the output of one function and send it directly to the next,
#' which is useful when you need to many things to the same data set. 
#' Pipes in R look like `%>%` and are made available via the `magrittr`
#' package installed as part of `dplyr`

#' demographic characteristics of data
age_demo <- physical_activity_tweets %>% summarise(count = round(mean(age),2))
gender_demo <- physical_activity_tweets %>% group_by(gender) %>% summarise(count = n()) %>% arrange(desc(count))
male_race_demo <- physical_activity_tweets %>% filter(gender == "Male") %>% group_by(race) %>% summarise(count = n()) %>% arrange(desc(count))
female_race_demo <- physical_activity_tweets %>% filter(gender == "Female") %>% group_by(race) %>% summarise(count = n()) %>% arrange(desc(count))
male_age_demo <- physical_activity_tweets %>% filter(gender == "Male") %>% group_by(race) %>% summarise(count = round(mean(age),2))
female_age_demo <- physical_activity_tweets %>% filter(gender == "Female") %>% group_by(race) %>% summarise(count = round(mean(age),2))

### mean age and gender counts ###
age_demo
gender_demo

### mean age and race counts for males ###
male_age_demo
male_race_demo

### mean age and race counts for females ###
female_race_demo
female_age_demo

## Subset the data ## 
#' subsetting the data by gender
male_tweets<- subset(physical_activity_tweets, gender == "Male")
female_tweets<- subset(physical_activity_tweets, gender == "Female")

#' subsetting the data by race
black_tweets<- subset(physical_activity_tweets, race == "Black") 
white_tweets<- subset(physical_activity_tweets, race == "White") 
asian_tweets<- subset(physical_activity_tweets, race == "Asian")

## Sentiment Analysis ##
#' import positive and negative words
pos = readLines("../opinion_lexicon/positive_words.txt")
neg = readLines("../opinion_lexicon/negative_words.txt")
source("../opinion_lexicon/sentiment.R")
glimpse(pos)
glimpse(neg)

#' to see all the words in each list, uncomment the two commands below
#pos
#neg

### Sentiment scores by demographic group ##
#' Compute a simple sentiment score for each tweet 
#' sentiment score = number of positive words  minus number of negative words

#' to save time, sample 1000 tweets from each demographic subset for sentiment scores
male_tweets_sample =  sample_n(male_tweets, 1000)
female_tweets_sample =  sample_n(female_tweets, 1000)
black_tweets_sample =  sample_n(black_tweets, 1000)
white_tweets_sample =  sample_n(white_tweets, 1000)
asian_tweets_sample =  sample_n(asian_tweets, 1000)

#' sentiment scores
scores_male<- score.sentiment(male_tweets_sample$text,pos, neg)$score 
scores_female <- score.sentiment(female_tweets_sample$text,pos, neg)$score 
scores_black<- score.sentiment(black_tweets_sample$text,pos, neg)$score 
scores_white <- score.sentiment(white_tweets_sample$text,pos, neg)$score 
scores_asian <- score.sentiment(asian_tweets_sample$text,pos, neg)$score

## Average sentiment by demographic background ##
#' sentiment score table
group_names <- c("male", "female", "black", "white", "asian") 
group_score_values<-round(rbind(mean(scores_male),mean(scores_female),mean(scores_black), mean(scores_white), mean(scores_asian)),2)
group_score_sd<-round(rbind(sd(scores_male),sd(scores_female),sd(scores_black), sd(scores_white), sd(scores_asian)),2)

group_score_df = tbl_df(as.data.frame(cbind(group_names, group_score_values, group_score_sd)))
colnames(group_score_df) = c("group", "mean score", "score st. dev")
group_score_df

### Save workspace ### 
#'Save all objects in your current workspace and read back from file in the future
save.image(file = "../src/EPC2016-Mainz-Twitter.RData")

#' future R sessions will require you to reload necessary libraries
#' uncomment the command below to load saved objects in future workspace sessions
#load("../src/EPC2016-Mainz-Twitter.RData")


# Acknowledgements #
#' I would like to thank workshop collaborators (Emilio Zagheni and Monica Alexander) 
#' for their questions and feedback while creating this module. 
