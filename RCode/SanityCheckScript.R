library(dplyr)

scrapedat <- read.csv("~/z/CompAnalysis/CompAdvantage/PythonScraping/scrapedData.csv",header=FALSE, stringsAsFactors = FALSE)

colnames(scrapedat) = c("category_name", "subcategory_name", "title", "year", "author_name")
scrapedat = unique(scrapedat)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_author;");
author = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_article;");
article = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_author_article;");
aa = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_category;");
cat = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_subcategory;");
subcat = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_category_subcategory;");
cs = dbFetch(rs)


dbdat = merge(author, aa, by = "author_id")
dbdat = merge(dbdat, article, by =  "article_id")
dbdat = merge(dbdat, cat, by = "category_id")
dbdat = merge(dbdat, subcat, by = "subcategory_id")

colnames(dbdat) = c("subcategory_id", "category_id", "article_id", "author_id", "author_name", 
                    "title", "year", "category_name", "subcategory_name")

dbdat = dbdat[,(!names(dbdat) %in% c("subcategory_id", "category_id", "article_id", "author_id"))]

onlyScrape = anti_join(scrapedat, dbdat)
onlyDB = anti_join(dbdat, scrapedat)
