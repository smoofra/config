#!/usr/bin/python
# coding=utf8

import unicodedata
from collections import OrderedDict
import subprocess
import json
import os
import sys

# FIXME "defaults read -g NSUserDictionaryReplacementItems" might be a better
# way to read and write this stuff.
#
# http://apple.stackexchange.com/questions/112363/mass-load-of-keyboard-text-mappings-in-mavericks

# import codecs
# sys.stdout = codecs.getwriter('utf8')(sys.stdout)

filename = os.path.join(os.getenv("HOME"), 'Library', 'Preferences', '.GlobalPreferences.plist')

proc = subprocess.Popen(["plutil", "-convert", "json", filename, '-o', '-'],
                        stdout = subprocess.PIPE);
prefs = json.load(proc.stdout);
if proc.wait() != 0:
    raise Exception, "plutil failed"


replacements = OrderedDict()
for x in prefs.get('NSUserDictionaryReplacementItems'):
    replacements[x['replace']] = x

for code in range(ord(u'α'), ord(u'ω') + 1):
    char = unichr(code)
    name =unicodedata.name(char)
    assert name.startswith("GREEK SMALL LETTER ")
    name = name[len("GREEK SMALL LETTER "):].lower().replace(' ', '')

    x = {'replace': '\\' + name,
         'with'   : char,
         'on'     : 1}
    replacements[x['replace']] = x


prefs['NSUserDictionaryReplacementItems'] = list(replacements.values())

proc = subprocess.Popen(["plutil", "-convert", "binary1", "-", '-o', filename + ".new"],
                        stdin = subprocess.PIPE)

json.dump(prefs, proc.stdin)
proc.stdin.close()
if proc.wait() != 0:
    raise Exception, "plutil failed"

os.rename(filename + '.new', filename)
