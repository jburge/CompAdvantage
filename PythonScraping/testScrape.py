from bs4 import BeautifulSoup
import re
import requests
import csv

initialyear = 1968
finalyear = 1996
items = list(list())
category = ''
subcategory = ''

url = ["http://www.informs-sim.org/wsc", "papers/prog", "sim.html"]

for year in range(initialyear, finalyear +1):
#add continue for missing year
	if year == 1972:
		continue


	url_year = str(year % 100)
	url_to_scrape = url[0] + url_year + url[1] + url_year + url[2]
	r = requests.get(url_to_scrape)
	data = r.text

	soup = BeautifulSoup(data)
	selected = soup.findAll(['span', 'h2','h3'])
	print(len(selected))

	for line in selected:
			try:
				found = re.search('<h2>(.*?)</h2>', str(line)).group(1)
				category = found.strip()
				subcategory = ''
			except AttributeError:
				found =''

			try:
				found = re.search('<h3>(.*?)</h3>', str(line)).group(1)
				subcategory = found.strip()
			except AttributeError:
				found = ''
	#	if 'class=\"author\"' in line:
	#		print("Found author")
			try:
				found = re.search('"author">(.*?)</span>', str(line)).group(1)
				found = found.replace(' and ', ',')
				found = found.split(',')
				for i in range(0, len(found)):
					if (found[i] == " Jr." or found[i] == " III"):
						found[i-1] += " " + found[i]
						found[i] = ""
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
				title = found.strip()
			except AttributeError:
				found = ''
			try:
				found = re.search('Title">(.*?) \[No', str(line)).group(1)
				title = found.strip()
			except AttributeError:
				found = ''

#for i in range(1, len(items)):
#	print(str(items[i]))

f = open('scrapedData.csv', "wb")
writer = csv.writer(f, delimiter=',', quotechar='"', quoting = csv.QUOTE_MINIMAL)
for item in items:
	for name in item[4]:
		writer.writerow(item[0:4] + [name.strip()])
