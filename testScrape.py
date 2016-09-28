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
selected = soup.findAll(['span', 'h2','h3'])
print(len(selected))
##, class_ = ['paperTitle', 'author'])
print(selected[1])
for line in selected:
	if "class=\"author\"" in line:
		print("Found author")
		try:
			found = re.search('"author">(.*?</span>', str(line)).group(1)
			found = found.split(',')
			authors.append(found)
		except AttributeError:
			found = ''	
	elif "class=\"paperTitle\"" in line:
		print("Found title")
		try:
			found = re.search('blank">(.*?)</a', str(i)).group(1)
			titles.append(found)
		except AttributeError:
			found = ''

print(len(titles))
for i in range(1, len(titles)):
	print(title[i] + str(author[i]))
