## ggplot and shiny with example twitter data
## Monica Alexander, August 2016

library(ggplot2)
library(plyr)
library(dplyr)
library(lubridate)

# load in the data
d <- read.csv("../Twitter/physical_activity_tweets.csv")
head(d)

## ggplot2 works in layers:
## DATA layer: identify data and mapping (often x, y)
## GEOM layer: specify type of plot (e.g. geom_point(), geom_histogram()...)
## ... can add more data/ geom layers
## aes = aesthetics: defines mappings to various parts of the plot. 


## GGPLOT EXAMPLE
# let's plot number of tweets per sign-up year

# transform data

year_counts <- d %>% group_by(year = year(user_created_at)) %>% summarise(number = n())

p <- ggplot(data = year_counts, aes(x = year, y = number))
p

# add in a line and points
p <- ggplot(data = year_counts, aes(x = year, y = number))+
  geom_line()
p

p <- ggplot(data = year_counts, aes(x = year, y = number))+
  geom_line()+ geom_point()
p

# fix x axis, add a heading
p <- ggplot(data = year_counts, aes(x = year, y = number))+
  geom_line()+ 
  geom_point()+
  scale_x_continuous(breaks=seq(2006, 2015, 1))+
  ggtitle("Exercise tweets by sign-up year")
p

# group by gender
year_gender_counts <- d %>% group_by(year = year(user_created_at), gender) %>% summarise(number = n())

p <- ggplot(data = year_gender_counts, aes(x = year, y = number, color = gender))+
  geom_line()+ 
  geom_point()+
  scale_x_continuous(breaks=seq(2006, 2015, 1))+
  ggtitle("Exercise tweets by sign-up year")
p

## customise look
p <- ggplot(data = year_gender_counts, aes(x = year, y = number, color = gender))+
  geom_line()+ 
  geom_point()+
  scale_x_continuous(breaks=seq(2006, 2015, 1))+
  ggtitle("Exercise tweets by sign-up year")+
  scale_color_brewer(palette = "Set1") + 
  theme_bw()
p



## HISTOGRAM OF SENTIMENT ANALYSIS

p <- ggplot(data = d, aes(x = sentiment_score, fill = gender)) + 
      geom_histogram(binwidth = 1, 
                     aes(y = (..count..)/sum(..count..)),  col = 'darkgrey') + 
      scale_fill_brewer(palette = "Set1") + 
      ggtitle("Distribution of Exercise Sentiment Scores")+
      theme_bw()+
      xlab("Sentiment score")+
      ylab("Proportion")
p



### POPULATION PYRAMID

# create age groups
ages <- c("0-4",  "5-9" , "10-14", "15-19",
          "20-24", "25-29", "30-34", "35-39",
          "40-44", "45-49", "50-54", "55-59",
          "60-64", "65+")
pyramid_ages <- seq(0, 65, by = 5)
d$pyramid_age <- findInterval(d$age, pyramid_ages)

# create a dataframe with age group, gender and proportion
counts_by_age <- count(d, pyramid_age, gender)
counts_by_age$freq <- NA
counts_by_age$freq[counts_by_age$gender=='Female'] <- counts_by_age$n[counts_by_age$gender=='Female'] /nrow(d)
counts_by_age$freq[counts_by_age$gender=='Male'] <- counts_by_age$n[counts_by_age$gender=='Male'] /nrow(d)

# create separate m/f dataframes
md<- as.data.frame(counts_by_age$freq[counts_by_age$gender=="Male"]*-1) #take negative for chart
colnames(md) <- "percent"
rownames(md) <- NULL
md$gender <- rep("Male", length.out=nrow(md))

fd<- as.data.frame(counts_by_age$freq[counts_by_age$gender=="Female"])
colnames(fd) <- "percent"
rownames(fd) <- NULL
fd$gender <- rep("Female", length.out=nrow(fd))

pd <- rbind(md, fd)
pd$age <- factor(ages, levels=ages)

p1 <- ggplot(pd, aes(x = age, y = percent, fill = gender)) + 
  geom_bar(stat = "identity", position = "identity")+
  scale_y_continuous(breaks = seq(-0.4, 0.4, 0.1), labels = as.character(c(4:0, 1:4))) +
  coord_flip()+
  scale_fill_brewer(palette = "Set1") + 
  theme_bw()+
  xlab("Age")+
  ylab("Percent of total population")+
  ggtitle("Age distribution of Twitter data")
p1
