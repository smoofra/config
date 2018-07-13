#!/usr/bin/env python3

import newspaper
import PyRSS2Gen as rss
import datetime
import sys

paper = newspaper.build('http://nymag.com/author/Andrew%20Sullivan/', memoize_articles=False)

items = []

for a in paper.articles:
    a.build()
    if 'Andrew Sullivan' not in a.authors:
        continue

    #print(a.url)

    items.append(rss.RSSItem(
        title = a.title,
        link = a.url,
        description = a.summary,
        pubDate = a.publish_date))

feed = rss.RSS2(
    title = 'Andrew Sullivan',
    link = 'http://nymag.com/author/Andrew%20Sullivan/',
    lastBuildDate = datetime.datetime.now(),
    description = 'Andrew Sullivan',
    items = items)
    
with open('/var/www/html/feeds/sullivan.xml', 'w', encoding='utf-8') as f:
    feed.write_xml(f)


