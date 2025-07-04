#!/bin/sh
# find virtualenvs in paths like .*/?-ve/{virtualenv}
pyline=${PYLINE:-"pyline"}
query=$1
(set -x; type -p locate && type -p pyline && type -p sort)
# 0: line, 1: prefix, 2: workon_home, 3: virtualenv_name, 4: restofpath
(set -x; locate "${query}" | ${pyline} -S 3,1,2,4 -r '(.*?)(-.e[\d]+.*?)/(.*?)/(.*)' 'rgx and (rgx.group(1), rgx.group(2), rgx.group(3), rgx.group(4))') # | sort -u)

# | pyline.py -F $'\t' 'w and (w[:-1]) or None' | sort -u
