select a.name,count(aa.author_id) Publications from jburge.winsim_author_article aa join jburge.winsim_author a
on aa.author_id=a.author_id
group by aa.author_id,a.name
order by 2 desc;
