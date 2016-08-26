### European Population Conference
### Workshop on Web and Social Media for Demographic Research  
### August 31, 2016
### Emilio Zagheni
### Hands-on activity with the Face++ API

## load the packages "rjson" and "RCurl"
library(rjson)
library(RCurl)
## if you cannot load them, you may need to install them first
## for example you can use the command
## install.packages("rjson")
## install.packages("RCurl")

###################################
#### 1. PUT TOGETHER THE INPUTS ####
###################################

## consider the URL for Ron's image and save it a string:
pic_Ron<- "http://www.demog.berkeley.edu/images/ron_lee2.jpg"


## Register your Face++ APP
## go to http://www.faceplusplus.com/create-a-new-app/
## and follow the directions to create an APP
## copy your API Key and Api Secret and paste them below.

my_api_key<-	"7d5e35c7081a1dde5aa9510c804eeecf"
my_api_secret<-	"T9IwAEIERr4RjgUWpDXEv5w8VXKsDvKC"

###########################
## 2. PREPARE A REQUEST ####
###########################

## Make sure you understand the various components following URL
## then copy it and paste it in your web browser 
url_for_request<- paste("http://apius.faceplusplus.com/v2/detection/detect?api_key=",my_api_key,"&api_secret=",my_api_secret,"&url=",pic_Ron,"&attribute=age%2Cgender%2Crace%2Csmiling%2Cpose%2Cglass",sep="")
url_for_request
## what did you observe?


##################################
## 3. GET THE OUTPUT FROM THE REQUEST
##################################

plain_json_output<- getURL(url_for_request)
plain_json_output

## convert the json output into a list
output_list <- fromJSON(plain_json_output)
output_list

## extract attributes that interest you about Ron (or anybody else)
##estimate for age
output_list$face[[1]]$attribute$age$value
##range for age
output_list$face[[1]]$attribute$age$range
##value for race 
output_list$face[[1]]$attribute$race$value 
##value for gender 
output_list$face[[1]]$attribute$gender$value


####################################
## You have gone though the basic steps
## Like in a dance class, mastering the 1,2,3, or basic steps, is key to move beyond
## Make sure that the code for  1,2,3 is clear: this is a good time to ask for clarifications...

## Once you are comfortable with the basic steps, we can automate the process


## First of all we can write a function that takes the url of the picture as input and returns the content of the json file as output

figure_details<- function(pic_url){
  url_for_request<- paste("http://apius.faceplusplus.com/v2/detection/detect?api_key=",my_api_key,"&api_secret=",my_api_secret,"&url=",pic_url,"&attribute=age%2Cgender%2Crace%2Csmiling%2Cpose%2Cglass",sep="")
  
  return(fromJSON(getURL(url_for_request)))
}


##We can now apply the function to the URL for Ron's image in order to obtain the json file with the estimated attributes
Ron_estimate<- try(figure_details(pic_Ron),silent=TRUE)

Ron_estimate

Ron_estimate$face[[1]]$attribute$age$value

## Note the we uses the "try" function. What does it do? Why is it important?
## some information about "try" can be found by typing
## help(try)



## Now imagine that you had a list of URLs, for example for images  of faculty in Demography at UC Berkeley: 
#http://www.demog.berkeley.edu/faculty/dfcm.shtml

pics_Berkeley<- c("http://www.demog.berkeley.edu/images/Irene_Bloemraad_Sociology.jpg","http://www.demog.berkeley.edu/images/wdow.jpg","http://www.demog.berkeley.edu/images/feehan_144.jpeg","http://www.demog.berkeley.edu/images/joshgoldstein.jpg","http://www.demog.berkeley.edu/images/geneb.jpg","http://www.demog.berkeley.edu/images/baseball350_UCBarticle_144.jpg","http://www.demog.berkeley.edu/images/lucas.jpg")
 
############### 
### TO DO ###### 
## Write a loop that calls the function at each iteration to store an estimate of age of each person in a new vector.
##  
## If this sounds very foreign, this is a good time to ask questions...


########

age_Berkeley_folks<- rep(NA,length(pics_Berkeley))
for (ii in 1:length(pics_Berkeley)){
  
  temp_output <- figure_details(pics_Berkeley[ii])
  age_Berkeley_folks[ii]<- temp_output$face[[1]]$attribute$age$value
  }




