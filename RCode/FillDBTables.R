dat <- read.csv("~/z/CompAnalysis/CompAdvantage/test.csv",header=FALSE, stringsAsFactors = FALSE)

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

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_article;");
article = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_author;");
author = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_subcategory;");
subcat = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM jburge.winsim_category;");
cat = dbFetch(rs)

aa = as.data.frame(cbind(dat$V3,dat$V4, dat$V5), stringsAsFactors = FALSE, row.names = FALSE)
colnames(aa) = c("title", "year", "name")
mapping = merge(x = aa, y = author, by = "name")
mapping = merge(x = mapping, y = article, by = "title")
mapping = mapping[, (!names(mapping) %in% c("title", "name", "category_id", "subcategory_id"))]
mapping = unique(mapping)
mapping = mapping[, (!names(mapping) %in% "year")]
for(i in 1:nrow(mapping))
{
  sql = paste("INSERT INTO scratch.jburge.winsim_author_article (author_id, article_id) VALUES ($$", mapping[i,1], "$$,$$", mapping[i,2], "$$)", sep = "")
  dbGetQuery(cnx, sql)
}

acs = as.data.frame(cbind(dat$V1, dat$V2, dat$V3, dat$V4), stringsAsFactors = FALSE, 
                    row.names = FALSE)
colnames(acs) =  c("category", "subcategory", "title", "year")
mapping = join(acs, article, by = c("year" = "year", "title" = "title"))
mapping = unique(mapping)
mapping = mapping [, (!names(mapping) %in% c("category_id", "subcategory_id"))]
mapping = merge(mapping, cat, by.x = "category", by.y = "name")
mapping = merge( mapping, subcat, by.x = "subcategory", by.y = "name")
mapping = mapping[, (names(mapping) %in% c("article_id", "category_id.x", "subcategory_id"))]
colnames(mapping) = c("article_id", "category_id", "subcategory_id")

for(i in 1:nrow(mapping))
{
  sql = paste("UPDATE scratch.jburge.winsim_article SET category_id = $$", mapping[i,2],
"$$,subcategory_id = $$", mapping[i,3], "$$ WHERE article_id = $$", mapping[i,1], "$$;", sep = "")
  dbGetQuery(cnx, sql)
}

mapping = unique(mapping[, (!names(mapping) %in% "article_id")])


for(i in 1:nrow(mapping))
{
  sql = paste("INSERT INTO scratch.jburge.winsim_category_subcategory (category_id, subcategory_id) VALUES ($$", mapping[i,1], "$$,$$", mapping[i,2], "$$)", sep = "")
  dbGetQuery(cnx, sql)
}
