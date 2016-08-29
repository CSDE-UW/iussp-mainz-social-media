library(shiny)
library(ggplot2)
library(plyr)
library(dplyr)
library(lubridate)


# Define the overall UI
shinyUI(
  
  # Use a fluid Bootstrap layout
  fluidPage(    
    
    # Give the page a title
    title = "Exercise Sentiment on Twitter",  
    h3("Sentiment about Exercise on Twitter"),
    
    # Define the sidebar with one input
    fluidRow(
      column(4,
             wellPanel(
                       sliderInput("year",
                                   "Year of sign-up:",
                                   min = 2008,
                                   max = 2015,
                                   value = 1, 
                                   sep="")
             ),
             br(),
             h4("Example tweets:"),
             h5("Negative:"),
             textOutput("tweetNeg"),
             h5("Positive:"),
             textOutput("tweetPos")
             
      ),
      column(8, 
             plotOutput("distPlot"),
             plotOutput("pyramidPlot")
    )

  )
))
