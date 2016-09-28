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
items = list(list())
category = ''
subcategory = ''

print(selected[100])
for line in selected:
		try:
			found = re.search('<h2>(.*?)</h2>', str(line)).group(1)
			category = found
		except AttributeError:
			found =''

		try:
			found = re.search('<h3>(.*?)</h3>', str(line)).group(1)
			subcategory = found
		except AttributeError:
			found = ''
#	if 'class=\"author\"' in line:
#		print("Found author")
		try:
			found = re.search('"author">(.*?)</span>', str(line)).group(1)
			found = found.replace(' and ', ',')
			found = found.split(',')
			found = filter(None, found)
#			authors.append(found)
			item  = [category, subcategory, title, found]
			items.append(item)
		except AttributeError:
			found = ''	
#	elif 'class=\"paperTitle\"' in line:
#		print("Found title")
		try:
			found = re.search('blank">(.*?)</a', str(line)).group(1)
#			titles.append(found)
			title = found
		except AttributeError:
			found = ''

print(len(titles))
for i in range(1, len(items)):
	print(str(items[i]))
