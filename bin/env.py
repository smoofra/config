#!/opt/homebrew/bin/python3

import os
import shlex

for k,v in os.environ.items():
    print(f"{k}={shlex.quote(v)}")