## file structure
sapply(c("scripts", "data", "documents"), function(x) dir.create(file.path(x),showWarnings = FALSE))

if (!file.exists("data/surveys.csv")) {
    download.file("https://ndownloader.figshare.com/files/2292172",
                  "data/surveys.csv")
}
if (!file.exists("data/species.csv")) {
    download.file("https://ndownloader.figshare.com/files/3299483",
                  "data/species.csv")
}
if (!file.exists("data/plots.csv")) {
    download.file("https://ndownloader.figshare.com/files/3299474",
                  "data/plots.csv")
}
if (!file.exists("data/portal_data_joined.csv")) {
    download.file("https://ndownloader.figshare.com/files/2292169",
                  "data/portal_data_joined.csv")
}

if (!file.exists("data/portal_mammals.sqlite")) {
    download.file("https://ndownloader.figshare.com/files/2292171",
                  "data/portal_mammals.sqlite")
}


## knitr options
library(knitr)
knitr::opts_chunk$set(results='hide', fig.path='img/R-ecology-',
                      comment = "#>")
