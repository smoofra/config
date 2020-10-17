#!/usr/bin/env python3

# pip install PyRSS2Gen
# apt install chromium-browser

from html.parser import HTMLParser
import subprocess
import shlex
import PyRSS2Gen as rss
import datetime
import re
import sys

if sys.platform == 'linux':
    chrome = 'chromium'
elif sys.platform == 'darwin':
    chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'

cmd = [chrome] + shlex.split(
    '--headless --virtual-time-budget=20000 '
    ' --dump-dom https://www.tabletmag.com/contributors/bari-weiss')

#print(' '.join(cmd))
content = subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding='utf8').stdout

class Parser(HTMLParser):
    def __init__(self):
        super(Parser, self).__init__()
        self.seen_labels = set()
        self.rss_itmes = list()
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'a' and (href := attrs.get('href')) and (label := attrs.get("aria-label")):
            if label in self.seen_labels:
                return
            self.seen_labels.add(label)
            m = re.match(r'Navigate to (.*) article page$', label)
            if not m:
                return
            if href.startswith('/'):
                href = 'https://www.tabletmag.com' + href
            self.rss_itmes.append(rss.RSSItem(
                title = m.group(1),
                link = href,
            ))

parser = Parser()
parser.feed(content)

if not parser.rss_itmes:
    raise Exception("didn't find any articles")

feed = rss.RSS2(
    title = 'Bari Weiss',
    link = 'https://www.tabletmag.com/contributors/bari-weiss',
    lastBuildDate=datetime.datetime.now(),
    description = 'Bari Weiss',
    items = parser.rss_itmes)

with open('/var/www/html/feeds/bari.xml', 'w', encoding='utf-8') as f:
    feed.write_xml(f)

#feed.write_xml(sys.stdout)
