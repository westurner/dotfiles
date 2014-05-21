#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
greppaths
"""

import re

FILE_PATH_REGEX = r"""(/[^\0]*?)(!?[\"\',\n\s])"""
# method 1: using a compile object
compile_obj = re.compile(FILE_PATH_REGEX,  re.VERBOSE| re.UNICODE)


def greppaths(lines):
    """
    grep for path-looking things in the specified lines
    """
    if not hasattr(lines, '__iter__'):
        lines = [lines]
    for i, line in enumerate(lines):
        print(i, line)
        for _i, path in enumerate(compile_obj.findall(line)):
            yield (i, _i, path[0])



import unittest
class Test_greppaths(unittest.TestCase):
    def test_greppaths(self):
        TEST_LINES = [
        "sample",
        "stdout",
        "lines",
        "that have a /path/looking/object",
        "and another /with/two /paths/that",
        ]
        matchstr = """        "sample",
                "stdout",
                "lines",
                "that have a /path/looking/object",
                "and another /path/looking/object/with.ext:lineno",
                "and another /with two /paths/with.ext:lineno  ",
        """
        paths = list(enumerate(greppaths([matchstr])))
        for p in paths:
            print(p)
        paths = list(enumerate(greppaths(TEST_LINES)))
        for p in paths:
            print(p)
        #raise Exception()


def main():
    import optparse
    import logging

    prs = optparse.OptionParser(usage="./%prog : args")

    prs.add_option('-v', '--verbose',
                    dest='verbose',
                    action='store_true',)
    prs.add_option('-q', '--quiet',
                    dest='quiet',
                    action='store_true',)
    prs.add_option('-t', '--test',
                    dest='run_tests',
                    action='store_true',)

    (opts, args) = prs.parse_args()

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        exit(unittest.main())

    greppaths(lines)

if __name__ == "__main__":
    main()
