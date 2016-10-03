dat <- read.csv("~/z/CompAnalysis/CompAdvantage/test.csv",header=FALSE, stringsAsFactors = FALSE)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_article;");
article = dbFetch(rs)

cats = unique(dat$V1)
subcats = unique(dat$V2)
titles = dat$V3
years = dat$V4
authors = unique(dat$V5)

articles = as.data.frame(unique(cbind(titles, years)), stringsAsFactors = FALSE)

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
for(i in 1:nrow(articles))
{
  sql = paste("INSERT INTO scratch.jburge.winsim_article (title, year) VALUES ($$", articles[i,1], "$$,$$", articles[i,2], "$$)", sep = "")
  dbGetQuery(cnx, sql)
}

mapping = merge(x = article_author, y = author, by = "name")
