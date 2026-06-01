#!/usr/bin/env python

import datetime

limit = 23500

sofar = [(datetime.date(2025, 1, 3), 890),
         (datetime.date(2025, 1, 17), 890),
        (datetime.date(2025, 1, 31), 890),
        (datetime.date(2025, 2, 14), 890),
        (datetime.date(2025, 2, 28), 890),
        (datetime.date(2025, 3, 14), 890),
        (datetime.date(2025, 3, 28), 908),
         ]

for date, _ in sofar:
    last = date

d = last + datetime.timedelta(days = 14)
n = 0
while True:
    if d.year == last.year:
        n += 1
        d = d + datetime.timedelta(days = 14)
    else:
        break

assert len(sofar) + n == 26

remaining = limit - sum(x for _,x in sofar)

print(len(sofar), n, len(sofar) + n)
print(remaining)
print(remaining / n)