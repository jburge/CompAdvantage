library(dplyr)

### establish connection to database

dat <- read.csv("~/z/CompAnalysis/CompAdvantage/PythonScraping/scrapedData.csv",header=FALSE, stringsAsFactors = FALSE)

###################
### Enter values for tables with no dependencies (foriegn keys)
###################
cats = unique(dat$V1)
subcats = unique(dat$V2)
authors = unique(dat$V5)

for(entry in cats)
  {
    sql = paste("INSERT INTO scratch.jburge.winsim_category (name) VALUES ($$", entry,"$$)", sep = "")
    dbGetQuery(cnx, sql)
}
for(entry in subcats)
{
  sql = paste("INSERT INTO scratch.jburge.winsim_subcategory (name) VALUES ($$", entry,"$$)", sep = "")
  dbGetQuery(cnx, sql)
}
for(entry in authors)
{
  sql = paste("INSERT INTO scratch.jburge.winsim_author (name) VALUES ($$", entry,"$$)", sep = "")
  dbGetQuery(cnx, sql)
}

###################
### Insert values into article table
### Use the Flat csv rows (minus author) as a unique identifier
###################
articles = dat[,(!names(dat) %in% "V5")]
colnames(articles) = c("category", "subcategory", "title", "year")
articles = unique(articles)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_subcategory;");
subcat = dbFetch(rs)
colnames(subcat) = c("subcategory_id", "subcategory")

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_category;");
cat = dbFetch(rs)
colnames(cat) = c("category_id", "category")


articles = merge(articles, subcat, by = "subcategory")
articles = merge(articles, cat, by = "category")
articlesFull = articles
articles = articles[, (!names(articles) %in% c("category", "subcategory"))]

for(i in 1:nrow(articles))
{
  sql = paste("INSERT INTO scratch.jburge.winsim_article (title, year, subcategory_id, category_id) VALUES ($$",
              articles[i,1], "$$,$$", articles[i,2], "$$,$$", articles[i,3], "$$,$$", articles[i,4], "$$)", sep = "")
  dbGetQuery(cnx, sql)
}

###################
### Get id's of articles for author article mapping table
###################

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_article;");
article = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_author;");
author = dbFetch(rs)

articlesFull = merge(articlesFull, subcat, by = "subcategory")
articlesFull = merge(articlesFull, cat, by = "category")
articlesFull = articlesFull[,(!names(articlesFull) %in% c("category_id.x", "subcategory_id.x"))]
colnames(articlesFull)[5] = "subcategory_id"
colnames(articlesFull)[6] = "category_id"

articlesFull = merge(articlesFull, article, by = c("title", "year", "category_id", "subcategory_id"))
articlesFull = articlesFull[,(!names(articlesFull) %in% c("category_id", "subcategory_id"))]

colnames(dat) = c("category", "subcategory", "title", "year", "author")
aamapping = merge(articlesFull, dat, c("title", "year", "subcategory", "category"))
aamapping = aamapping[,(names(aamapping) %in% c("author", "article_id"))]
aamapping = inner_join(aamapping, author, by = c("author" = "name"))
aamapping = aamapping[,(!names(aamapping) %in% "author")]


for(i in 1:nrow(aamapping))
{
  sql = paste("INSERT INTO scratch.jburge.winsim_author_article (article_id, author_id) VALUES ($$", aamapping[i,1], "$$,$$", aamapping[i,2], "$$)", sep = "")
  dbGetQuery(cnx, sql)
}

###################
### Insert pairs for category, subcategory mapping table
###################

csmapping = as.data.frame(cbind(dat$category, dat$subcategory), stringsAsFactors = FALSE, head(FALSE))
colnames(csmapping) = c("category", "subcategory")
csmapping = inner_join(csmapping, cat, by = "category")
csmapping = inner_join(csmapping, subcat, by = "subcategory")
csmapping = csmapping[, (!names(csmapping) %in% c("category", "subcategory"))]
csmapping = unique(csmapping)


for(i in 1:nrow(csmapping))
{
  sql = paste("INSERT INTO scratch.jburge.winsim_category_subcategory (category_id, subcategory_id) VALUES ($$",
              csmapping[i,1], "$$,$$", csmapping[i,2], "$$)", sep = "")
  dbGetQuery(cnx, sql)
}
