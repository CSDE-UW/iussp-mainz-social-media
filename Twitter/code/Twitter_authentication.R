#---------------------------------------------------------------------------------#
#              Workshop on Web and Social Media for Demographic Research          #
#                                 EPC 2016                                        #
#---------------------------------------------------------------------------------#
#   Module:       Using R to Gather and Analyze Data from Twitter                 #
#   Script:                   Twitter Authentication                              #
#   Author:                     Kivan Polimis                                     #
#---------------------------------------------------------------------------------#

#' Clearing workspace, setting working directory, and loading required packages.
#' Change FILL ME in with the file path that includes the folder you created for this workshop
rm(list=ls())
setwd("FILL ME IN/iussp-mainz-social-media/Twitter")

#' install.packages(c("twitteR","streamR","ROAuth"))
library(twitteR)
library(streamR)
library(ROAuth)

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

#' insert the number in the R console after you run this line
#' save authenticated credentials for later sessions
#' for later use, uncomment the following command in a folder that contains twitCred.RData
#load(twitCred)
twitCred$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
save(twitCred, file = "twitCred.RData")

#' setup direct twitter authentication for twitteR functions
#' you will be prompted to cache authentication token
#' you will need to repeat this step unless you are running analysis from a location with a
#' cached authentication token 
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_token_secret)