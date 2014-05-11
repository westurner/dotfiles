#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
progname
"""

import re
from math import log,pow

RE_NUMERIC=re.compile(r'\d')
RE_LOWERALPHA=re.compile(r'[a-z]')
RE_UPPERALPHA=re.compile(r'[A-Z]')
RE_SYMBOLS=re.compile(r'[-_.:,;<>?"#$%&/()!@~]')

NUM_SYMBOLS=20

# TODO: is_unicode()

def password_strength(password=''):
    charset = 0
    if RE_NUMERIC.search(password):
        charset += 10
    if RE_LOWERALPHA.search(password):
        charset += 26
    if RE_UPPERALPHA.search(password):
        charset += 26
    if RE_SYMBOLS.search(password):
        charset += NUM_SYMBOLS
    if any(ord(x) > 256 for x in password):
        charset += 100000 # wikipedia.org/wiki/Unicode
    elif any(ord(x) > 126 for x in password):
        charset += 128
    entropy = log(pow(charset,len(password)),2)
    return entropy

import unittest
class TestPasswordStrength(unittest.TestCase):
    def test_test(self):
        passwords = (
                '',
                '0',
                '1',
                'one',
                'oone',
                'One',
                'OOne',
                'O0ne',
                'O0ne!',
                'eightcha',
                'ninechara',
                'oneሴ',
                'Ninechar!',
                u'oneሴ',
                'this is an extensive sentence password',
                'this is an extensive sentence password!',
                'this is an e123tensive se123ntence p123assword!',
                u'this is an e123tensive se123ntence p123assword!',
                u'this is an extensive sentence passwordሴ',
                u'This is an e123xtensive se123ntence p123asswordሴ!',
                )
        for p in passwords:
            print(p, password_strength(p))

if __name__ == '__main__':
    unittest.main(verbosity=2)
