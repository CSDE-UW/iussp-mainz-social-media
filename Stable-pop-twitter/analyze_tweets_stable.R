### European Population Conference
### Workshop on Web and Social Media for Demographic Research  
### August 31, 2016
### Emilio Zagheni
### Estimate Twitter growth rate from a cross-section of tweets 

library(streamR)

## Function to format Twitter timestamps into 'date' format
formatTwDate <- function(datestring){
	date <- as.Date(datestring, format="%a %b %d %H:%M:%S %z %Y")
	return(date)
	}


## Read in a json file that contains a cross-sectional set of random tweets obtained using the streaming API  
tweets <- parseTweets("tweets_random.json", verbose = FALSE)

names(tweets)

## obtain a list of IDs for unique users
unique_users<- (unique(tweets$user_id_str))
head(unique_users)

## obtain timestamps for the date when unique users created their Twitter account
string_user_created_at<- tweets$user_created_at[tweets$user_id_str %in% unique_users]

head(string_user_created_at)

## Use the "sapply" function to apply the "formatTwDate" function to each element of
## "string_user_created_at", one at a time. 
date_user_created_at<- sapply(string_user_created_at,formatTwDate)
head(date_user_created_at)


##reference date (e.g., the date when the data was downloaded)
date_reference<- as.numeric(as.Date("2015/11/8"))

## evaluate age (where birth is signing up for Twitter) for Twitter users
age_in_days<- as.numeric(date_reference-date_user_created_at)
age_years<- age_in_days/365

## create a histogram of the "age" distribution
hist(age_years,xlab="Age (in years)",main="Age distribution of a sample of active Twitter users (birth=signing up)")

## count the number of people in various age groups
pop_age5<-length(age_years[age_years>5 & age_years<6])
pop_age5
pop_age3<-length(age_years[age_years>3 & age_years<4])
pop_age3

## Evaluate the Twitter growth rate based on the "age" structure.
r<- (1/(5-3)) * log((pop_age3/pop_age5))

r



