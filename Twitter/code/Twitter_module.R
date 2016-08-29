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
setwd("FILL ME IN/iussp-mainz-social-media/Twitter")

#' load libraries
#' uncomment the command below to install the necessary packages
#install.packages(c("twitteR","streamR","ROAuth", "RCurl",  "plyr", "dplyr", "lubridate", "stringr", "base64enc"))

library(twitteR)
library(streamR)
library(ROAuth)
library(RCurl)
library(plyr)
library(dplyr)
library(lubridate)
library(stringr)
library(base64enc)

#' uncommenting the following lines may help install twitteR package
#install.packages("devtools")
#library(devtools)
#devtools::install_github("jrowen/twitteR", ref = "oauth_httr_1_0")

#' Pablo Barbera, author of streamR, has written additional functions for Twitter analysis
#' uncomment the two commands below to download and add these functions to your environment with source
#download.file("https://raw.githubusercontent.com/pablobarbera/social-media-workshop/master/functions.r", "src/functions_by_pablobarbera.R")
#source("src/functions_by_pablobarbera.R")

#' few functions to clean data
source("src/twitterFunctions.R") 

#' Twitter credentials for streamR and twitteR authentication
consumer_key <- "FILL ME IN"
consumer_secret<- "FILL ME IN"
access_token<- "FILL ME IN"
access_token_secret<- "FILL ME IN"

#' parameters and URLs for streamR authentication
reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL<- "https://api.twitter.com/oauth/access_token"
authURL<- "https://api.twitter.com/oauth/authorize"

#' Note:  You only need to create an authentication object for streamR once
#' Microsoft Windows users need to uncomment the following command to download a cert file
#download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

#' create an object "cred" that will save the authenticated object for later sessions
twitCred<- OAuthFactory$new(consumerKey=consumer_key,consumerSecret=consumer_secret,
                            requestURL=reqURL,accessURL=accessURL,authURL=authURL)

#' executing twitCred$handshake will redirect you to a website and provide your app a PIN
#' insert the PIN in the R console after you run this line
#' you can save authenticated credentials for later sessions
#' for later use, uncomment the following command in a folder that contains twitCred.RData
#load("twitCred.RData")
twitCred$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
save(twitCred, file = "twitCred.RData")

#' setup direct Twitter authentication for twitteR functions
#' you will be prompted to cache authentication token
#' you will need to repeat this step unless you are running analysis from a location with a
#' cached authentication token 
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_token_secret)

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

physical_activity_tweet_stream<-filterStream("data/physical_activity_tweets.json",
                                             timeout = 120, language = "en", 
                                             track = c("#walking, #biking, #running, 
                                             #jogging, #pushups, #pullups, #homeworkouts,
                                             #bodyweightexercises, #bodyweightworkouts"),
                                             oauth = twitCred)

read.physical_activity_tweets <- readTweets("data/physical_activity_tweets.json")
physical_activity_tweets=unlist(read.physical_activity_tweets)

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

#' alternative way to make a table of users and profile urls
#' use if character vectors for user name, id, created at or picture url are not equal
#tweets_table <- tbl_df(matrix(NA,length(tweet_user_name),5))
#colnames(tweets_img_table)<-c("user_name", "user_id",  "user_created_at","tweet_pic_url", "tweet_text")
#for (i in 1:length(tweet_user_name)){
# tweets_img_table[i,1]<-tweet_user_name[i]
# tweets_img_table[i,2]<-tweet_user_id[i]
# tweets_img_table[i,3]<-tweet_user_created_at[i]
# tweets_img_table[i,4]<-tweet_pic_url[i]
# tweets_img_table[i,5]<-tweet_textsl[i]
#}
#head(tweets_img_table)

write.csv(tweets_table, "data/physical_activity_tweets.csv", row.names = FALSE)

physical_activity_tweets = tbl_df(read.csv("data/physical_activity_tweets.csv"))

## View summary statistics ## 

#' demographic characteristics of data
age_demo <- physical_activity_tweets %>% summarise(count = round(mean(age),2))
gender_demo <- physical_activity_tweets %>% group_by(gender) %>% summarise(count = n()) %>% arrange(desc(count))
male_race_demo <- physical_activity_tweets %>% filter(gender == "Male") %>% group_by(race) %>% summarise(count = n()) %>% arrange(desc(count))
female_race_demo <- physical_activity_tweets %>% filter(gender == "Female") %>% group_by(race) %>% summarise(count = n()) %>% arrange(desc(count))
male_age_demo <- physical_activity_tweets %>% filter(gender == "Male") %>% group_by(race) %>% summarise(count = round(mean(age),2))
female_age_demo <- physical_activity_tweets %>% filter(gender == "Female") %>% group_by(race) %>% summarise(count = round(mean(age),2))

age_demo
gender_demo
male_race_demo
male_age_demo
female_race_demo
female_age_demo
```

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
pos = readLines("opinion_lexicon/positive_words.txt")
neg = readLines("opinion_lexicon/negative_words.txt")
source("opinion_lexicon/sentiment.R")
glimpse(pos)
glimpse(neg)

#' to see all the words in each list, uncomment the two commands below
#pos
#neg

### Sentiment scores by demographic group ##
#' Compute a simple sentiment score for each tweet 
#' sentiment score = number of positive words  minus number of negative words
scores_male<- score.sentiment(male_tweets$text,pos, neg)$score 
scores_female <- score.sentiment(female_tweets$text,pos, neg)$score 
scores_black<- score.sentiment(black_tweets$text,pos, neg)$score 
scores_white <- score.sentiment(white_tweets$text,pos, neg)$score 
scores_asian <- score.sentiment(asian_tweets$text,pos, neg)$score

## Average sentiment by demographic background ##
#' sentiment score table
group_names <- c("male", "female", "black", "white", "asian") 
group_score_values<-round(rbind(mean(scores_male),mean(scores_female),mean(scores_black), mean(scores_white), mean(scores_asian)),2)
group_score_sd<-round(rbind(sd(scores_male),sd(scores_female),sd(scores_black), sd(scores_white), sd(scores_asian)),2)

group_score_df = tbl_df(cbind(group_names, group_score_values, group_score_sd))
colnames(group_score_df) = c("group", "mean score", "score st. dev")
group_score_df

### Save workspace ### 
#'Save all objects in your current workspace and read back from file in the future
save.image(file = "EPC2016-Mainz-Twitter.RData")

#' future R sessions will require you to reload necessary libraries
#' uncomment the command below to load saved objects in future workspace sessions
#load("EPC2016-Mainz-Twitter.RData")


# Acknowledgements #
#' I would like to thank workshop collaborators (Emilio Zagheni and Monica Alexander) 
#' for their questions and feedback while creating this module. 
