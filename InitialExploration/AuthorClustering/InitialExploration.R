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
  authormat[x1, x2] <<- y*y
  authormat[x2, x1] <<- y*y
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

#make a matrix for the graph
authormat = matrix(0, ncol = nrow(author), nrow = nrow(author))
for(i in 1:nrow(authormat))
{
  insertValueMatrix(i,i,1)
}
for(i in 1:nrow(edges)){
  insertValueMatrix(edges$r1[i], edges$r2[i], edges$nrow[i])
}
#remove authors with no collaborators
csum = apply(authormat, 2, sum)
test = csum > 0
cleanmat = authormat[test ,test]

#normalize
  #for each column normalize to sum to 1
normmat = cleanmat %*% diag(1/colSums(cleanmat))
#e_set = c(2, 2.4, 2.8, 3.2, 3.6, 4)
#r_set = c(2, 2.4, 2.8, 3.2, 3.6, 4)
# best seem to be 4, 2.4 (have low dupe count and high performance)
e = 2.4
r = 1.4
toleranceForConvergence = .00001
output = list()
#for(e in e_set)
#{
  #for(r in r_set)
  #{
  m = normmat
  while(TRUE)
  {
    #expand
    expand = m %^% e
    
    #inflate
    num = expand ^ r
    inflate = num %*% diag(1/colSums(num))
    maxdivergence = max(abs(m - inflate))
    m = inflate
    if(maxdivergence < toleranceForConvergence)
      break;
    print(maxdivergence)
  }
  
  ### draw conclusions from the resulting matrix
  nonzero = as.data.frame(cbind(row(m)[m!=0],col(m)[m!=0]))
  nonzero = nonzero[order(nonzero$V1),]
  
  
  clusters = vector("list", nrow(author))
  for(i in 1:nrow(author))
  {
    temp = nonzero[nonzero$V1 == i,2]
    clusters[[i]] = sort(temp)
  }
  t = table(sapply(clusters, length, simplify = TRUE))
  
  clusters = unique(clusters)
  clusters = clusters[order(sapply(clusters,length),decreasing=T)]
  c = clusters[lengths(clusters) > 1]
  t = table(sapply(clusters, length, simplify = TRUE))
  
  #determine effectiveness of clusters
  getEdgesInCluster = function(x){
    s = sum(edges[(edges$r1 %in% x) & (edges$r2 %in% x), 3])
    return(s)
  }
  getEdgesTouchingCluster = function(x){
    s = sum(edges[(edges$r1 %in% x) | (edges$r2 %in% x), 3])
    return(s)
  }
  clusterEdges = lapply(c[], getEdgesInCluster)
  clusterFringe = lapply(c[], getEdgesTouchingCluster)
  clusterEdges = unlist(x = clusterEdges)
  clusterFringe = unlist(clusterFringe)
  t
  table(clusterFringe)
  table(clusterEdges)
  table(clusterFringe - clusterEdges)
  percentInclusion = clusterEdges / clusterFringe
  (overallPerformance = sum(clusterEdges) / sum(clusterFringe))
  cluster_items = unlist(clusters)
  dup_items = cluster_items[duplicated(cluster_items)]
  length(dup_items)
  author[author$row_num %in% dup_items,]
  output = c(output, paste(e, r, overallPerformance))
#  }
#}
