### vficarrotta 2023
## Scrape wikipedia for top songs per year

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

### Cleaning song list
# 1) remove backslashes using this trick: 
    # gsub("[^A-Za-z0-9 '!?$&*@#()-_=.]", "", test[[1]][1,2])
    # removes backslashes because r trips over backslashes.

# unlist data    
bow <- tibble()
for(i in stand){
    bow <- rbind(bow, i)
}

# remove backslashes and quotations from song titles column
bow$Song <- gsub("[^A-Za-z0-9 '!?$&*@#()-_=.]", "", bow$Song)

### Data storage checkpoint 1
# write.csv(stand, '~/1950-2023_bbtopsongs_clean.csv')
# saveRDS(bow, '~/1950-2023_bbtopsongs_clean.rds')
stand <- readRDS('~/1950-2023_bbtopsongs_clean.rds')
