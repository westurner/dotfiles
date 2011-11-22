#!/usr/bin/env python
"""
http://stackoverflow.com/questions/1126930/is-it-possible-to-go-into-ipython-from-code/1127087#1127087

See also:
  - http://pypi.python.org/pypi/ipdb
  - https://github.com/gotcha/ipdb
  - https://github.com/flavioamieiro/nose-ipdb/blob/master/ipdbplugin.py
"""
import sys
from IPython.Debugger import Pdb
from IPython.Shell import IPShell
from IPython import ipapi

shell = IPShell(argv=[''])

def set_trace():
    ip = ipapi.get()
    def_colors = ip.options.colors
    Pdb(def_colors).set_trace(sys._getframe().f_back)
