#---------------------------------------------------------------------------------#
#              Workshop on Web and Social Media for Demographic Research          #
#                                 EPC 2016                                        #
#---------------------------------------------------------------------------------#
#   Module:       Using R to Gather and Analyze Data from Twitter                 #
#   Script:                   Twitter Demographics                                #
#   Author:                     Kivan Polimis                                     #
#---------------------------------------------------------------------------------#

#' set working directory
rm(list=ls())
setwd("FILL ME IN/iussp-mainz-social-media/Twitter")

#install.packages(c("plyr", "dplyr", "tidyr"))

#' laod libraries
library(plyr)
library(dplyr)
library(tidyr)

#physical_activity_tweets = tbl_df(read.csv("data/physical_activity_tweets.csv"))

#' demographic characteristics of data
age_demo <- physical_activity_tweets %>% summarise(count = round(mean(age),2))
gender_demo <- physical_activity_tweets %>% group_by(gender) %>% summarise(count = n()) %>% arrange(desc(count))
male_race_demo <- physical_activity_tweets %>% filter(gender == "Male") %>% group_by(race) %>% summarise(count = n()) %>% arrange(desc(count))
female_race_demo <- physical_activity_tweets %>% filter(gender == "Female") %>% group_by(race) %>% summarise(count = n()) %>% arrange(desc(count))
male_age_demo <- physical_activity_tweets %>% filter(gender == "Male") %>% group_by(race) %>% summarise(count = round(mean(age),2))
female_age_demo <- physical_activity_tweets %>% filter(gender == "Female") %>% group_by(race) %>% summarise(count = round(mean(age),2))

#' interactive analysis
black_male_race_demo <- physical_activity_tweets %>% filter(gender == "Male"& race == "Black") %>% summarise(count = n()) %>% arrange(desc(count))
white_male_race_demo <- physical_activity_tweets %>% filter(gender == "Male"& race == "White") %>% summarise(count = n()) %>% arrange(desc(count))
asian_male_race_demo <- physical_activity_tweets %>% filter(gender == "Male"& race == "Asian") %>% summarise(count = n()) %>% arrange(desc(count))
black_female_race_demo <- physical_activity_tweets %>% filter(gender == "Female"& race == "Black") %>% summarise(count = n()) %>% arrange(desc(count))
white_female_race_demo <- physical_activity_tweets %>% filter(gender == "Female"& race == "White") %>% summarise(count = n()) %>% arrange(desc(count))
asian_female_race_demo <- physical_activity_tweets %>% filter(gender == "Female"& race == "Asian") %>% summarise(count = n()) %>% arrange(desc(count))

#' subsetting the data by gender
male_tweets<- subset(physical_activity_tweets, gender == "Male") 
female_tweets<- subset(physical_activity_tweets, gender == "Female")

#' subsetting the data by race
black_tweets<- subset(physical_activity_tweets, race == "Black") 
white_tweets<- subset(physical_activity_tweets, race == "White") 
asian_tweets<- subset(physical_activity_tweets, race == "Asian")

# 'interactive analysis
black_male_tweets<- subset(physical_activity_tweets, race == "Black" & gender == "Male")
white_male_tweets<- subset(physical_activity_tweets, race == "White" & gender == "Male")
asian_male_tweets<- subset(physical_activity_tweets, race == "Asian" & gender == "Male")

black_female_tweets<- subset(physical_activity_tweets, race == "Black" & gender == "Female")
white_female_tweets<- subset(physical_activity_tweets, race == "White" & gender == "Female") 
asian_female_tweets<- subset(physical_activity_tweets, race == "Asian" & gender == "Female")

#' Compute a simple sentiment score for each tweet 
#' sentiment score = number of positive words  minus number of negative words
scores_male<- score.sentiment(male_tweets$tweet_text,pos, neg)$score 
scores_female <- score.sentiment(female_tweets$tweet_text,pos, neg)$score 
scores_black<- score.sentiment(black_tweets$tweet_text,pos, neg)$score 
scores_white <- score.sentiment(white_tweets$tweet_text,pos, neg)$score 
scores_asian <- score.sentiment(asian_tweets$tweet_text,pos, neg)$score
scores_black_male<- score.sentiment(black_male_tweets$tweet_text,pos, neg)$score 
scores_white_male <- score.sentiment(white_male_tweets$tweet_text,pos, neg)$score 
scores_asian_male <- score.sentiment(asian_male_tweets$tweet_text,pos, neg)$score
scores_black_female<- score.sentiment(black_female_tweets$tweet_text,pos, neg)$score 
scores_white_female <- score.sentiment(white_female_tweets$tweet_text,pos, neg)$score
scores_asian_female <- score.sentiment(asian_female_tweets$tweet_text,pos, neg)$score

# sentiment score table
group_names <- c("male", "female", "black", "white", "asian") 
group_score_values<-round(rbind(mean(scores_male),mean(scores_female),mean(scores_black), mean(scores_white), mean(scores_asian)),2)
group_score_sd<-round(rbind(sd(scores_male),sd(scores_female),sd(scores_black), sd(scores_white), sd(scores_asian)),2)

group_score_df = tbl_df(cbind(group_names, group_score_values, group_score_sd))
colnames(group_score_df) = c("group", "mean score", "score st. dev")
group_score_df



