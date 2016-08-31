# Advanced #  
### Map results ###  
#' use filterStream to search by location
#' map tweets with ggplot2 and grid packages

#' set working directory
rm(list=ls())
setwd("FILL ME IN/iussp-mainz-social-media/Twitter/code")

#' load libraries
#' uncomment the following line the first time you run this file
#install.packages(c("dplyr","ggplot2", "grid","lubridate", "maps", "png"))
library(dplyr)
library(ggplot2)
library(grid)
library(gridExtra)
library(lubridate)
library(maps)
library(png)

#' rearrange data by date
physical_activity_tweets = unique(tbl_df(read.csv("../data/physical_activity_tweets.csv")))
users_loc = unique(tbl_df(read.csv("../data/physical_activity_tweets_loc.csv")))
physical_activity_tweets<-arrange(physical_activity_tweets, user_created_at)

#' merge data frames
physical_activity_tweets_loc = inner_join(physical_activity_tweets, users_loc)

#' find tweets start and end date
users_start<- strsplit(unlist(as.character(physical_activity_tweets_loc$user_created_at))[1], split =' ')[[1]][1]
users_end<-strsplit(unlist(
as.character(physical_activity_tweets_loc$user_created_at)[nrow(physical_activity_tweets_loc)]), split =' ')[[1]][1]

#' a small percentage of users have location access enabled for their tweets
#' increase the timeout number to gather more tweets and increase geo-tagged tweets
map.data <- map_data("state")
points <- data.frame(x = as.numeric(physical_activity_tweets_loc$lon), 
                 y = as.numeric(physical_activity_tweets_loc$lat))

points <- subset(points, y > 25 & y <50) 
points<-subset(points, x> -125 & x< -66)

tweets.map<-ggplot(map.data) + ggtitle(sprintf("Map of tweets \n from users created %s to %s", users_start, users_end)) +
geom_map(aes(map_id = region), map = map.data, fill = "white", color = "grey20", size = 0.25) +
expand_limits(x = map.data$long, y = map.data$lat) + 
theme(axis.line = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
    axis.title = element_blank(), panel.background = element_blank(), panel.border = element_blank(), panel.grid.major = element_blank(), plot.background = element_blank(), plot.margin = unit(0 * c(-1.5, -1.5, -1.5, -1.5), "lines")) + geom_point(data = points, aes(x = x, y = y), size = .1, alpha = 1/5, color = "darkblue")

#' save map as a .png
png(filename="../images/tweets-map.png", height = 480 , width = 720, units = "px")
plot(tweets.map)
dev.off()

#' alternative ways to save map
#plot(tweets.map)
#dev.print(png, '../images/tweets-map.png',height = 480 , width = 720, units = "px") 
#dev.print(pdf, '../images/tweets-map.pdf')

# Map positive only tweets

#' Create a new data frame that only includes positive tweets
positive_tweets <- subset(physical_activity_tweets_loc, "sentimemt_score">=0)

positive_points <- data.frame(x = as.numeric(positive_tweets$lon), 
                         y = as.numeric(positive_tweets$lat))

#' subset points to only include locations (roughly) within the United States
positive_points <- subset(positive_points, y > 25 & y <50) 
positive_points<-subset(positive_points, x> -125 & x< -66)

positive_tweets.map<-ggplot(map.data) + ggtitle("Positive Tweets Map") +
geom_map(aes(map_id = region), map = map.data, fill = "white", 
       color = "grey20", size = 0.25) + expand_limits(x = map.data$long, y = map.data$lat) +
theme(axis.line = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(), 
    axis.title = element_blank(), panel.background = element_blank(), panel.border = element_blank(),
    panel.grid.major = element_blank(), plot.background = element_blank(),
    plot.margin = unit(0 * c(-1.5, -1.5, -1.5, -1.5), "lines")) + 
geom_point(data = positive_points, aes(x = x, y = y), size = .75, alpha = 1/5, color = "blue")

#' Save map of positive only tweets
png(filename="../images/positive_tweets-map.png", height = 480 , width = 720, units = "px")
plot(positive_tweets.map)
dev.off()


# Map negative only tweets

#' Create a new data frame that only includes negative tweets
#negative_tweets <- subset(physical_activity_tweets_loc, "sentimemt_score"<0)
negative_tweets <- physical_activity_tweets_loc[physical_activity_tweets_loc$sentiment_score<=0,]

negative_points <- data.frame(x = as.numeric(negative_tweets$lon), 
                              y = as.numeric(negative_tweets$lat))

#' subset points to only include locations (roughly) within the United States
negative_points <- subset(negative_points, y > 25 & y <50) 
negative_points<-subset(negative_points, x> -125 & x< -66)

negative_tweets.map<-ggplot(map.data) + ggtitle("Negative Tweets Map") +
  geom_map(aes(map_id = region), map = map.data, fill = "white", 
           color = "grey20", size = 0.25) + expand_limits(x = map.data$long, y = map.data$lat) +
  theme(axis.line = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(), 
        axis.title = element_blank(), panel.background = element_blank(), panel.border = element_blank(),
        panel.grid.major = element_blank(), plot.background = element_blank(),
        plot.margin = unit(0 * c(-1.5, -1.5, -1.5, -1.5), "lines")) + 
  geom_point(data = negative_points, aes(x = x, y = y), size = .75, alpha = 1/5, color = "red")

#' Save map of negative only tweets
png(filename="../images/negative_tweets-map.png", height = 480 , width = 720, units = "px")
plot(negative_tweets.map)
dev.off()


#' Compare positive and negative tweet maps side-by-side
grid.arrange(positive_tweets.map,negative_tweets.map, ncol=2)
dev.off()

#' Save comparison map
require(gridExtra)
ggsave("../images/combined_tweets-raw.png", arrangeGrob(positive_tweets.map,negative_tweets.map), dpi = 300)

#' Improve comparison map image quality by rasterization
img <- readPNG("../images/combined_tweets-raw.png")
grid.raster(img)
dev.off()

#' Save raster comparison map
png(filename="../images/combined_tweets-map.png", height = 720 , width = 1200, units = "px")
grid.raster(img)
dev.off()
