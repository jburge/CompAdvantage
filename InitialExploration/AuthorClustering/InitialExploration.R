library(plyr)
library(dplyr)
library(Matrix)
library(expm)

rs = dbSendQuery(cnx, "SELECT * from winsim_author")
author = dbFetch(rs)

rs = dbSendQuery(cnx, "SELECT * FROM winsim_author_article")
aa = dbFetch(rs)

dat = inner_join(aa, aa, by = c("article_id" = "article_id"))
dat = dat[names(dat) %in% c("article_id", "author_id.x", "author_id.y")]
colnames(dat) = c("a1", "article_id", "a2")
getNumArticles = function(x){
  
  nrow(dat[dat$a1 == dat$a2 & dat$a1 == x,])  
  
}
insertValueMatrix = function(x1, x2, y){
  authormat[x1, x2] <<- y
  authormat[x2, x1] <<- y
}

#count each authors total number of articles
author$num_articles = sapply(author$author_id, getNumArticles)
#remove duplicate (transpose) values and self matches
dat = dat[dat$a1 < dat$a2,]
dat = dat[!(names(dat) %in% "article_id")]
edges = ddply(dat, .(a1, a2), c("nrow"))
partner = table(edges$nrow)

author$row_num = 1:nrow(author)
edges = inner_join(edges, author[,c(1,4)], by = c("a1" = "author_id") )
colnames(edges)[4] = "r1"
edges = inner_join(edges, author[,c(1,4)], by = c("a2" = "author_id") )
colnames(edges)[5] = "r2"

edgesimple  = edges[edges$nrow != 1,]

#make a matrix for the graph
authormat = matrix(0, ncol = nrow(author), nrow = nrow(author))
for(i in 1:nrow(authormat))
{
  insertValueMatrix(i,i,1)
}
for(i in 1:nrow(edges)){
  insertValueMatrix(edges$r1[i], edges$r2[i], edges$nrow[i])
}

#normalize
  #for each column normalize to sum to 1
normmat = authormat %*% diag(1/colSums(authormat))
e = 2
r = 5
toleranceForConvergence = .0001
m = normmat
while(TRUE)
{
  #expand
  expand = m %^% e
  
  #inflate
  t = expand %^% r
  inflate = t %*% diag(1/colSums(t))
  maxdivergence = max(abs(m - inflate))
  m = inflate
  if(maxdivergence < toleranceForConvergence)
    break;
  print(maxdivergence)
}

nonzero = as.data.frame(cbind(row(m)[m!=0],col(m)[m!=0]))
nonzero = nonzero[order(nonzero$V1),]


clusters = vector("list", nrow(author))
for(i in 1:nrow(author))
{
  temp = nonzero[nonzero$V1 == i,2]
  clusters[[i]] = sort(temp)
}
clusters = unique(clusters)
c1 = clusters[lengths(clusters) > 1]
t = table(sapply(clusters, length, simplify = TRUE))
