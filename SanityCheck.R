#Re-combining tables for sanity check

#GPDB connection parameters
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "scratch", host = "gpdb", user="cward", pass="drEBumedr4dr0bra", port = "5432")

#Grab article table
rs = dbSendQuery(con, "SELECT * FROM scratch.jburge.winsim_article;")
article = dbFetch(rs)

#Grab author table
rs = dbSendQuery(con, "SELECT * FROM scratch.jburge.winsim_author;")
author = dbFetch(rs)

#Grab author_article table
rs = dbSendQuery(con, "SELECT * FROM scratch.jburge.winsim_author_article;")
author_article = dbFetch(rs)

#Grab category table
rs = dbSendQuery(con, "SELECT * FROM scratch.jburge.winsim_category;")
category = dbFetch(rs)

#Grab subcategory table
rs = dbSendQuery(con, "SELECT * FROM scratch.jburge.winsim_subcategory;")
subcategory = dbFetch(rs)

#Merge Tables
collection = merge(x = author, y = author_article, by="author_id", all = TRUE)
collection = merge(x = collection, y = article, by ="article_id", all = TRUE)
collection = merge(x = collection, y = category, by = "category_id", all = TRUE)
collection = merge(x = collection, y = subcategory, by = "subcategory_id", all = TRUE)

#Create CSV
write.csv(collection, file = "SanityCheck.csv", row.names = TRUE)