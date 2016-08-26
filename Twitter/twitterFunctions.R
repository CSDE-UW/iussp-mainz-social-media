################################################################################
# Create lubridate date time objects from vector of tweets created at date
################################################################################

tweet_time<-function(tweet_created_at){
  #' @author Kivan Polimis \email{kivan.polimis@gmail.com}
  #' @description create timestamp of tweets that is manageable by lubridate package
  #' @param tweet_created_at: vector of tweet times created by filterStream (from streamR package)
  #' @export tweet_timestamp: character vector of tweet timestamps
  #' @seealso `filterStream` command from streamR package
  require(lubridate)
  tweet_created_at<-as.character(tweet_created_at)
  timestamp<-unlist(strsplit(tweet_created_at, split = " ", fixed = TRUE))
  date<-paste(timestamp[c(6,2,3)], sep="", collapse="-")
  time<-timestamp[4]
  date_time<-paste(date,time)
  parsed_date<-ymd_hms(date_time)
  tweet_timestamp<-as.character(as.POSIXct(parsed_date, format = "%y%m%d %H:%M", tz="UTC"),
                                format = "%m-%d-%Y %H:%M")
  return (tweet_timestamp)
}