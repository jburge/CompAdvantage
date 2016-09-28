from bs4 import BeautifulSoup
import re
import requests
import csv

initialyear = 1968
#finalyear = 1992;
finalyear = 1992
items = list(list())
category = ''
subcategory = ''

titles = list()
authors = list(list())
url = ["http://www.informs-sim.org/wsc", "papers/prog", "sim.html"]

for year in range(initialyear, finalyear):
#add continue for missing year
	if year == 1972:
		continue


	url_year = str(year % 100)
	url_to_scrape = url[0] + url_year + url[1] + url_year + url[2]
	r = requests.get(url_to_scrape)
	data = r.text

	soup = BeautifulSoup(data)
	titlesSpan = soup.findAll("span", class_ = "paperTitle")
	authorsSpan = soup.findAll("span", class_ = "author")
	selected = soup.findAll(['span', 'h2','h3'])
	print(len(selected))

	for line in selected:
			try:
				found = re.search('<h2>(.*?)</h2>', str(line)).group(1)
				category = found
				subcategory = ''
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
				item  = [category, subcategory, title, year, found]
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

for i in range(1, len(items)):
	print(str(items[i]))

f = open('test.csv', "wb")
writer = csv.writer(f, delimiter=',', quotechar='"', quoting = csv.QUOTE_MINIMAL)
for item in items:
	writer.writerow(item[0:4] + item[4])
