################################################################################
# Create lubridate date time objects from vector of tweets created at date
################################################################################

lubridate_tweet_datestring<-function(tweet_datestring){
  #' @author Kivan Polimis \email{kivan.polimis@gmail.com}
  #' @description create datestring of tweets that is manageable by lubridate package
  #' @param tweet_datestring: vector of tweet times created by filterStream (from streamR package)
  #' @export tweet_datestring_lubridate: character vector of lubridate object tweet datestrings
  #' @seealso `filterStream` command from streamR package
  require(lubridate)
  timestamp<-unlist(strsplit(tweet_datestring, split = " ", fixed = TRUE))
  date<-paste(timestamp[c(6,2,3)], sep="", collapse="-")
  time<-timestamp[4]
  date_time<-paste(date,time)
  parsed_date<-ymd_hms(date_time)
  tweet_datestring_lubridate<-as.character(as.POSIXlt(parsed_date, format = "%y%m%d %H:%M", tz="UTC",origin="1970-01-01"),
                                format = "%m-%d-%Y %H:%M")
  return (tweet_datestring_lubridate)
}