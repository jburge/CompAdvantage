from bs4 import BeautifulSoup
import re
import requests

url = "http://www.informs-sim.org/wsc90papers/prog90sim.html"
titles = list()
authors = list(list())
r = requests.get(url)

data = r.text

soup = BeautifulSoup(data)
titlesSpan = soup.findAll("span", class_ = "paperTitle")
authorsSpan = soup.findAll("span", class_ = "author")
for i in titlesSpan:
	try:
		found = re.search('blank">(.*?)</a', str(i)).group(1)
		titles.append(found)
	except AttributeError:
		found = ''
for i in authorsSpan:
	try:
		found = re.search('"author">(.*?)</span>', str(i)).group(1)
		found = found.split(',')
		authors.append(found)
		for j in found:
			print j
	except AttributeError:
		found = ''
for i in range(1, 10):
	print(titles[i] + " by " + str(authors[i]))

