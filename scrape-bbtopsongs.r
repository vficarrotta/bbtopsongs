### vficarrotta 2023
# "C:\Program Files\R\R-4.3.0\bin"

# Sources
# https://www.youtube.com/watch?v=Dkm1d4uMp34
# https://www.youtube.com/watch?v=9GR26Y4z_v4&t=712s
# RSelenium: https://rdrr.io/cran/RSelenium/f/vignettes/saucelabs.Rmd
# RSelenium: enter text into text field: https://stackoverflow.com/questions/64154120/rselenium-input-value-in-text-box
# https://stackoverflow.com/questions/74777106/rselenium-cant-connect-to-host-rsdriver



#########
### 1. Scrape billboard top songs from 1950 to 2023
#########
library('rvest'); library('tidyverse'); library('RSelenium'); library('netstat')

# Scraping wikipedia in one go
# Generates a list of each years top hits accounting for the three different URLs used by wikipedia

## vars
url1 <- 'https://en.wikipedia.org/wiki/Billboard_year-end_top_30_singles_of_'
url2 <- 'https://en.wikipedia.org/wiki/Billboard_year-end_top_50_singles_of_'
url3 <- 'https://en.wikipedia.org/wiki/Billboard_Year-End_Hot_100_singles_of_'

sit <- 1950
stand <- list()
for(i in 1:(2022-1950)){
    if(sit <= 1955){
        url <- paste0(url1, sit)
        kneel <- read_html(url) %>%
            html_element('table.wikitable') %>%
            html_table()
        colnames(kneel) <- c('Number', 'Song', 'Artists')
        kneel['Year'] <- rep(sit, length(kneel[,1]))
        stand[[i]] <- kneel
        sit <- sit + 1
        print(sit)
    }
    else if(sit > 1955 & sit < 1959){
        url <- paste0(url2, sit)
        kneel <- read_html(url) %>%
            html_element('table.wikitable') %>%
            html_table()
        colnames(kneel) <- c('Number', 'Song', 'Artists')
        kneel['Year'] <- rep(sit, length(kneel[,1]))
        stand[[i]] <- kneel
        sit <- sit + 1
        print(sit)
    }   
    else {
        url <- paste0(url3, sit)
        kneel <- read_html(url) %>%
            html_element('table.wikitable') %>%
            html_table()
        colnames(kneel) <- c('Number', 'Song', 'Artists')
        kneel['Year'] <- rep(sit, length(kneel[,1]))
        stand[[i]] <- kneel
        sit <- sit + 1
        print(sit)
    }
}

        ### wikipedia URL roots without year
        # 1950-1954: https://en.wikipedia.org/wiki/Billboard_year-end_top_30_singles_of_
        # 1956-1958: https://en.wikipedia.org/wiki/Billboard_year-end_top_50_singles_of_
        # 1959-2023: https://en.wikipedia.org/wiki/Billboard_Year-End_Hot_100_singles_of_

### Data storage and recall checkpoint 1
# saveRDS(stand, 'C:/Users/vfica/Documents/Project X/Data Objects/1950-2023_bbtopsongs.rds')
# stand <- readRDS('C:/Users/vfica/Documents/Project X/Data Objects/1950-2023_bbtopsongs.rds')

### Cleaning song list
# 1) index using test[[x]][x,x]
# 2) remove backslashes using this trick: 
    # gsub("[^A-Za-z0-9 '!?$&*@#()-_=.]", "", test[[1]][1,2])
    # removes backslashes because r trips over backslashes.

# unlist data    
bow <- tibble()
for(i in stand){
    bow <- rbind(bow, i)
}

# remove backslashes and quotations from song titles column
bow$Song <- gsub("[^A-Za-z0-9 '!?$&*@#()-_=.]", "", bow$Song)

### Data storage checkpoint 2
# write.csv(stand, 'C:/Users/vfica/Documents/Project X/Data Objects/1950-2023_bbtopsongs_clean.csv')
# saveRDS(bow, 'C:/Users/vfica/Documents/Project X/Data Objects/1950-2023_bbtopsongs_clean.rds')
stand <- readRDS('C:/Users/vfica/Documents/Project X/Data Objects/1950-2023_bbtopsongs_clean.rds')



##############################################################################
### 2. Use RSelenium to scrape lyrics of songs in 'bow' dataframe
##############################################################################
# if port is in use: system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)

# for https://www.lyricsfreak.com
    # 1) search using song title, will display page of songs with title by multiple artists
    # 2) search for artist on page of song by all artists, will display page of songs by that artist
    # 3) search for song title again, will display lyrics

# for www.genius.com
    # use the python module: lyricsgenius api

# starts server
rs_driver_object <- rsDriver(browser='firefox', chromever=NULL, version='latest', port=free_port())
    # Last worked: 7-19-2023
    # free_port() is from netstat package and makes finding a port easy

# creates client object
remDr <- rs_driver_object$client

# open browser and go to website
remDr$open()
    # jump <- 'https://www.lyrics.com/' # incomplete lyrics on Goodnight, Irene.
jump <- 'https://genius.com/'
remDr$navigate(jump)

### Genius token: -wACRrmhF4U4JbNzP4Oy7ncK4Fj871c_VPNVfyal1mUEMuCV4R1PS8mDaoXLJdJV
### Use python module: lyricsgenius


#####
# navigate to lyrics page given song name
#####

# will need to paste two objects together for initial entry
test <- 'Goodnight Irene'
entering <- remDr$findElement(using='name', 'q')
entering$clickElement()
entering$sendKeysToElement(list(test, key='enter'))
Sys.sleep(5)
remDr$findElement(using='class name', 'mini_card')$clickElement()
# save lyrics by taking the whole html page source
html <- remDr$getPageSource()[[1]]

salute <- read_html(html) %>% # parse HTML
  html_nodes(id="lyrics-root") %>% 
  html_table(fill=T) # have rvest turn it into a dataframe
View(salute)

### test
cURL <- remDr$getCurrentURL()
skip <- read_html(cURL) %>%
            html_element(xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "Dzxov", " " ))]') %>%
            html_table()
