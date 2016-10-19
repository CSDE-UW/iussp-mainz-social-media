#---------------------------------------------------------------------------------#
#              Workshop on Web and Social Media for Demographic Research          #
#                                 EPC 2016                                        #
#---------------------------------------------------------------------------------#
#   Module:       Using R to Gather and Analyze Data from Twitter                 #
#   Script:                Face++ API Demographic Estimates                       #
#   Author:                     Kivan Polimis                                     #
#---------------------------------------------------------------------------------#

#' set working directory
rm(list=ls())
setwd("FILL ME IN/iussp-mainz-social-media/Twitter/code")

#' load libraries
library(rjson)
library(RCurl)
#install.packages(c("rjson","RCurl"))

#' Face++ API authentication
face_plus_plus_api_key<- "FILL ME IN"
face_plus_plus_api_secret<- "FILL ME IN"

#' url check with Face++ API
obama_twitter_pic = "https://pbs.twimg.com/profile_images/738744285101580288/OUoCVEXG.jpg"
paste("http://apius.faceplusplus.com/v2/detection/detect?api_key=",face_plus_plus_api_key,"&api_secret=",face_plus_plus_api_secret,"&url=",obama_twitter_pic,"&attribute=age%2Cgender%2Crace%2Csmiling%2Cpose%2Cglass",sep="")

#' function to estimate age, gender, etc. 
figure_details<- function(pic_url){
  url_for_request<- paste("http://apius.faceplusplus.com/v2/detection/detect?api_key=",face_plus_plus_api_key,"&api_secret=",face_plus_plus_api_secret,"&url=",pic_url,"&attribute=age%2Cgender%2Crace%2Csmiling%2Cpose%2Cglass",sep="")
  
  return(fromJSON(getURL(url_for_request)))
}

#' Estimating Twitter users demographic background
#' race/gender/age

#' make an estimator for Face++ API demographic estimates 
face_plus_plus_estimator<-c()

#' make face plus plus table for estimates of twitter user name, age, age range, gender, race
#' this examples uses the tweets_img_table data frame from Twitter_module.R comprised of:
#'  "user_name", "user_id",  "user_created_at","tweet_pic_url"
tweets_img_table = tbl_df(read.csv("data/tweets_img_table.csv"))
face_plus_plus_table<- tbl_df(matrix(NA,nrow(tweets_img_table),8))
colnames(face_plus_plus_table)<-c("name", "id", "age","range","gender",
                                  "gender_confidence", "race", "race_confidence")

#' apply figure details function to tweets_img_table data frame
for (i in 1:length(tweets_img_table$tweet_pic_url)){
  face_plus_plus_estimator<- try(figure_details(tweets_img_table$tweet_pic_url[i]),silent=TRUE)
  #' if the Face++ API is unable to generate an estimate, face list is length 0
  if (length(face_plus_plus_estimator$face) == 0)
  {
    face_plus_plus_table[i,1]<-toString(tweets_img_table$name[i])
    face_plus_plus_table[i,2]<-tweets_img_table$tweet_user_id[i]
    face_plus_plus_table[i,3]<-NA
    face_plus_plus_table[i,4]<-NA
    face_plus_plus_table[i,5]<-NA
    face_plus_plus_table[i,6]<-NA
    face_plus_plus_table[i,7]<-NA
    face_plus_plus_table[i,8]<-NA
  }
  
  #' if  the Face++ API is able to generate an estimate, face list is length 1
  else if (length(face_plus_plus_estimator$face) == 1) 
  {
    face_plus_plus_table[i,1]<-toString(tweets_img_table$name[i])
    face_plus_plus_table[i,2]<-tweets_img_table$tweet_user_id[i]
    face_plus_plus_table[i,3]<-face_plus_plus_estimator$face[[1]]$attribute$age['value']$value[1]
    face_plus_plus_table[i,4]<-face_plus_plus_estimator$face[[1]]$attribute$age['range']$range[1]
    face_plus_plus_table[i,5]<-face_plus_plus_estimator$face[[1]]$attribute$gender$value[1]
    face_plus_plus_table[i,6]<-face_plus_plus_estimator$face[[1]]$attribute$gender$confidence[1]
    face_plus_plus_table[i,7]<-face_plus_plus_estimator$face[[1]]$attribute$race$value[1]
    face_plus_plus_table[i,8]<-face_plus_plus_estimator$face[[1]]$attribute$race$confidence[1]
  }
}

head(face_plus_plus_table)

#' write Face++ table estimates to file
write.csv(face_plus_plus_table, "../data/face_plus_plus_estimates.csv", row.names=FALSE)
