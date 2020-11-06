library(xml2)
library(rvest)

pages <- 5
items <- 20

cols <- c('Rank', 'Title', 'Subtitle', 'Author', 'Narrator', 'Length', 'Release', 'Language', 'Stars', 'Ratings', 'Price')
data <- matrix('', nrow = pages * items, ncol = length(cols))
colnames(data) <- cols

for (page in 1:pages) {
  url <- paste0('https://www.audible.com/adblbestsellers?page=', page)
  html <- read_html(url)

  for (item_num in 1:items) {
    row <- (page - 1) * items + item_num

    item_selector <- paste0('#product-list-a11y-skiplink-target > span > ul > div > li:nth-child(', item_num, ') > div > div.bc-col-responsive.bc-spacing-top-none.bc-col-8 > div > div.bc-col-responsive.bc-col-6 > div > div > span > ul')
    item_node <- html_node(html, item_selector)

    data[row, 'Rank'] <- row
    
    title_selector <- 'li:nth-child(1) > h3 > a'
    title_node <- html_node(item_node, title_selector)
    title <- html_text(title_node, trim = TRUE)
    data[row, 'Title'] <- title

    subtitle_selector <- 'li.bc-list-item.subtitle > span'
    subtitle_node <- html_node(item_node, subtitle_selector)
    subtitle <- html_text(subtitle_node, trim = TRUE)
    data[row, 'Subtitle'] <- subtitle
    
    author_selector <- 'li.bc-list-item.authorLabel > span > a'
    author_nodes <- html_nodes(item_node, author_selector)
    authors <- html_text(author_nodes, trim = TRUE)
    author <- paste(authors, collapse = ', ')
    data[row, 'Author'] <- author
    
    narrator_selector <- 'li.bc-list-item.narratorLabel > span > a'
    narrator_nodes <- html_nodes(item_node, narrator_selector)
    narrators <- html_text(narrator_nodes, trim = TRUE)
    narrator <- paste(narrators, collapse = ', ')
    data[row, 'Narrator'] <- narrator
    
    length_selector <- 'li.bc-list-item.runtimeLabel > span'
    length_node <- html_node(item_node, length_selector)
    length <- html_text(length_node, trim = TRUE)
    length <- gsub('Length: ', '', length)
    data[row, 'Length'] <- length
    
    release_selector <- 'li.bc-list-item.releaseDateLabel > span'
    release_node <- html_node(item_node, release_selector)
    release <- html_text(release_node, trim = TRUE)
    release <- gsub('Release date:\n\\s+', '', release)
    data[row, 'Release'] <- release
    
    language_selector <- 'li.bc-list-item.languageLabel > span'
    language_node <- html_node(item_node, language_selector)
    language <- html_text(language_node, trim = TRUE)
    language <- gsub('Language:\n\\s+', '', language)
    data[row, 'Language'] <- language
    
    stars_selector <- 'li.bc-list-item.ratingsLabel > span.bc-text.bc-pub-offscreen'
    stars_node <- html_node(item_node, stars_selector)
    stars <- html_text(stars_node, trim = TRUE)
    data[row, 'Stars'] <- stars
    
    ratings_selector <- 'li.bc-list-item.ratingsLabel > span.bc-text.bc-size-small.bc-color-secondary'
    ratings_node <- html_node(item_node, ratings_selector)
    ratings <- html_text(ratings_node, trim = TRUE)
    data[row, 'Ratings'] <- ratings
    
    price_selector <- paste0('#buybox-regular-price-', item_num - 1, ' > span:nth-child(2)')
    price_node <- html_node(html, price_selector)
    price <- html_text(price_node, trim = TRUE)
    data[row, 'Price'] <- price
  }
}

df <- as.data.frame(data)
View(df)

filename <- paste0('TopAudiobooks-', format(Sys.time(), '%Y%m%d-%H%M%S'), '.csv')
write.csv(df, filename, row.names = FALSE)