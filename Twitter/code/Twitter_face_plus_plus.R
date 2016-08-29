#---------------------------------------------------------------------------------#
#              Workshop on Web and Social Media for Demographic Research          #
#                                 EPC 2016                                        #
#---------------------------------------------------------------------------------#
#   Module:       Using R to Gather and Analyze Data from Twitter                 #
#   Script:                Face++ API authentication                              #
#   Author:                     Kivan Polimis                                     #
#---------------------------------------------------------------------------------#

library(rjson)
library(RCurl)
#install.packages(c("rjson","RCurl"))

#' Face++ API authentication
face_plus_plus_api_key<- "FILL ME IN"
face_plus_plus_api_secret<- "FILL ME IN"

# url check with face++ api
paste("http://apius.faceplusplus.com/v2/detection/detect?api_key=",face_plus_plus_api_key,"&api_secret=",face_plus_plus_api_secret,"&url=",tweet_pic_url[3],"&attribute=age%2Cgender%2Crace%2Csmiling%2Cpose%2Cglass",sep="")

#function to estimate age, gender, etc. 
figure_details<- function(pic_url){
  url_for_request<- paste("http://apius.faceplusplus.com/v2/detection/detect?api_key=",face_plus_plus_api_key,"&api_secret=",face_plus_plus_api_secret,"&url=",pic_url,"&attribute=age%2Cgender%2Crace%2Csmiling%2Cpose%2Cglass",sep="")
  
  return(fromJSON(getURL(url_for_request)))
}

#' Estimating Twitter users demographic background
#' race/gender/age

# make an estimator for face++ (fpp) api info 
face_plus_plus_estimator<-c()

# make fpp matrix for estimates of twitter user name, age, age range, gender, race
face_plus_plus_table<- tbl_df(matrix(NA,nrow(tweets_img_table),4))
colnames(face_plus_plus_table)<-c("age","range","gender","race")

# apply figure details function to tweets img data frame
for (i in 1:length(tweets_img_table$tweet_pic_url)){
  face_plus_plus_estimator<- try(figure_details(tweets_img_table$tweet_pic_url[i]),silent=TRUE)
  # if face++ API unable to generate estimate, face list is length 0
  if (length(face_plus_plus_estimator$face) == 0)
  {
    face_plus_plus_table[i,1]<-NA
    face_plus_plus_table[i,2]<-NA
    face_plus_plus_table[i,3]<-NA
    face_plus_plus_table[i,4]<-NA
  }
  
  # if face++ API able to generate estimate, face list is length 1
  else if (length(face_plus_plus_estimator$face) == 1) 
  {
    face_plus_plus_table[i,1]<-face_plus_plus_estimator$face[[1]]$attribute$age['value']$value[1]
    face_plus_plus_table[i,2]<-face_plus_plus_estimator$face[[1]]$attribute$age['range']$range[1]
    face_plus_plus_table[i,3]<-face_plus_plus_estimator$face[[1]]$attribute$gender$value[1]
    face_plus_plus_table[i,4]<-face_plus_plus_estimator$face[[1]]$attribute$race$value[1]
  }
}

head(face_plus_plus_table)

## write face++ table estimates to file
write.csv(face_plus_plus_table, "data/face_plus_plus_estimates.csv", row.names=FALSE)
```

