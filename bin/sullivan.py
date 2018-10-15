#!/usr/bin/env python3

import newspaper
import PyRSS2Gen as rss
import datetime
import sys
import os

verbose = os.isatty(1)

class Source(newspaper.Source):
    def _get_category_urls(self, domain):
        return [self.url]

paper = Source('http://nymag.com/author/Andrew%20Sullivan/', memoize_articles=False)
paper.build()

items = []

for a in paper.articles:

    try:
        a.build()
    except newspaper.article.ArticleException as e:
        print ("article failed: %s" % a.url)
        continue

    if verbose:
        print(a.url)
        print(a.authors)

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


