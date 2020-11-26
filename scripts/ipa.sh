#!/bin/sh
ip a | pyline.py -r '^((\d+):\s+(.*))|^\s+(inet6? (.*))' '[obj for obj in [(row[2] if row[2] else "\n"+row[1]) if row else None for row in [rgx.groups()[1:] if rgx else None]] if obj]'
