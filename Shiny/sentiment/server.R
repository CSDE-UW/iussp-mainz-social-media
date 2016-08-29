library(shiny)
d <- read.csv("physical_activity_tweets.csv")

shinyServer(function(input, output) {
  #histogram of sentiments
  output$distPlot <- renderPlot({
    d_year <- d %>% filter(year(user_created_at) == input$year)
    p <- ggplot(data = d_year, aes(x = sentiment_score, fill = gender)) + 
      #geom_histogram(data = d,
      #           binwidth = 1,
      #           aes(x = sentiment_score, 
      #               y = (..count..)/sum(..count..)),
      #           fill = 'grey')+
      geom_histogram(binwidth = 1, 
                     aes(y = (..count..)/sum(..count..)),  col = 'darkgrey') + 
      scale_fill_brewer(palette = "Set1") + 
      ggtitle("Distribution of Exercise Sentiment Scores")+
      theme_bw()+
      xlab("Sentiment score")+
      ylab("Proportion")
    p
  })
  #age pyramid
  output$pyramidPlot <- renderPlot({
    d_year <- d %>% filter(year(user_created_at) == input$year)
    pyramid_ages <- seq(0, 65, by = 5)
    d_year$pyramid_age <- findInterval(d_year$age, pyramid_ages)
    counts_by_age <- count(d_year, pyramid_age, gender)
    counts_by_age$freq <- NA
    counts_by_age$freq[counts_by_age$gender=='Female'] <- counts_by_age$n[counts_by_age$gender=='Female'] /nrow(d)
    counts_by_age$freq[counts_by_age$gender=='Male'] <- counts_by_age$n[counts_by_age$gender=='Male'] /nrow(d)
    ages <- c("0-4",  "5-9" , "10-14", "15-19",
              "20-24", "25-29", "30-34", "35-39",
              "40-44", "45-49", "50-54", "55-59",
              "60-64", "65+")
    
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
    
    maintitle <- paste0("Age distribution in ", input$year)
    p1 <- ggplot(pd, aes(x = age, y = percent, fill = gender)) + 
      geom_bar(stat = "identity", position = "identity")+
      scale_y_continuous(breaks = seq(-0.4, 0.4, 0.1), labels = as.character(c(4:0, 1:4))) +
      coord_flip()+
      scale_fill_brewer(palette = "Set1") + 
      theme_bw()+
      xlab("Age")+
      ylab("Percent of total population")+
      ggtitle("Age Distribution of sign-ups")
    p1
  })
  # example negative tweet
  output$tweetNeg <- renderText({ 
    d_year <- d %>% filter(year(user_created_at) == input$year) %>% filter(sentiment_score<0)
    rw = sample(1:nrow(d_year), 1)
    paste0("'", d_year$text[rw], "'")
  })
  # example positive tweet
  output$tweetPos <- renderText({ 
    d_year <- d %>% filter(year(user_created_at) == input$year) %>% filter(sentiment_score>0)
    rw = sample(1:nrow(d_year), 1)
    paste0("'", d_year$text[rw], "'")
  })
})