
## function to find the N most common hashtags in a string vector
getCommonHashtags <- function(text, n=20){

    hashtags <- regmatches(text,gregexpr("#(\\d|\\w)+",text))

    hashtags <- unlist(hashtags)

    tab <- table(hashtags)

    return(head(sort(tab, dec=TRUE), n=n))

}




## function to obatin the timeline of a user
getTimeline <- function(file.name, screen_name=NULL, n=1000, oauth){

    require(rjson); require(ROAuth)

    ## url to call
    url <- "https://api.twitter.com/1.1/statuses/user_timeline.json"

    ## first API call
    params <- list(screen_name = screen_name, count=200, trim_user="false")
   
    url.data <- oauth$OAuthRequest(URL=url, params=params, method="GET", 
    cainfo=system.file("CurlSSL", "cacert.pem", package = "RCurl")) 

    ## trying to parse JSON data
    json.data <- fromJSON(url.data, unexpected.escape = "skip")
    if (length(json.data$error)!=0){
        cat(url.data)
        stop("error parsing tweets!")
    }
    ## writing to disk
    conn <- file(file.name, "w")
    invisible(lapply(json.data, function(x) writeLines(toJSON(x), con=conn)))
    close(conn)
    ## max_id
    tweets <- length(json.data)
    max_id <- json.data[[tweets]]$id_str
    max_id_old <- "none"
    cat(tweets, "tweets.\n")

    while (tweets < n & max_id != max_id_old){
        max_id_old <- max_id
        params <- list(screen_name = screen_name, count=200, max_id=max_id,
                trim_user="false")
        url.data <- oauth$OAuthRequest(URL=url, params=params, method="GET", 
        cainfo=system.file("CurlSSL", "cacert.pem", package = "RCurl")) 
        ## trying to parse JSON data
        json.data <- fromJSON(url.data, unexpected.escape = "skip")
        if (length(json.data$error)!=0){
            cat(url.data)
            stop("error! Last cursor: ", cursor)
        }
        ## writing to disk
        conn <- file(file.name, "a")
        invisible(lapply(json.data, function(x) writeLines(toJSON(x), con=conn)))
        close(conn)
        ## max_id
        tweets <- tweets + length(json.data)
        max_id <- json.data[[length(json.data)]]$id_str
        cat(tweets, "tweets.\n")
    }
}

