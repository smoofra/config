#!/usr/bin/python
# coding=utf8

import unicodedata
from Foundation import NSUserDefaults, NSCFDictionary, NSGlobalDomain
import sqlite3
import time
import os

def my_replacements():
    for code in range(ord(u'α'), ord(u'ω') + 1):
        char = unichr(code)
        name =unicodedata.name(char)
        assert name.startswith("GREEK SMALL LETTER ")
        name = name[len("GREEK SMALL LETTER "):].lower().replace(' ', '')
        replace = '\\' + name
        yield (replace, char)


def add_replacements_to_defaults():
    defaults = NSUserDefaults.standardUserDefaults()
    replacements = defaults.objectForKey_('NSUserDictionaryReplacementItems').mutableCopy()
    existing = set( x['replace'] for x in replacements )
    for key,value in my_replacements():
        if not key in existing:
            replacements.append({'replace': key,
                                 'with'   : value,
                                 'on'     : 1})
            defaults.setObject_forKey_inDomain_(replacements, 'NSUserDictionaryReplacementItems', NSGlobalDomain)
    defaults.synchronize()


def add_replacements_to_sqlite(filename):
    sql = sqlite3.connect(filename)
    for key,value in my_replacements():
        cur = sql.cursor()
        cur.execute("SELECT Z_PK FROM ZUSERDICTIONARYENTRY WHERE ZSHORTCUT == ?", (key,))
        if not len(cur.fetchall()):
            cur.execute(
                "INSERT INTO ZUSERDICTIONARYENTRY(Z_ENT, Z_OPT, ZTIMESTAMP, ZPHRASE, ZSHORTCUT) VALUES(1, 1, ?, ?, ?);",
                (int(time.time()), value, key))
            cur.fetchall()
    sql.commit()


add_replacements_to_defaults()

for root, dirs, files in os.walk(os.path.join(os.getenv("HOME"), "Library/Dictionaries/CoreDataUbiquitySupport")):
    for name in files:
        if name.endswith(".db"):
            add_replacements_to_sqlite(os.path.join(root, name))


