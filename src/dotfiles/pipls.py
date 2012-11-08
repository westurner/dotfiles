#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
not_pip_freeze
"""

from pip import req

class Options(object):
    def __getattr__(self, attr):
        print(attr)
        return None

def not_pip_freeze(path):
    pkgreqs = list(
        req.parse_requirements(path, options=Options()))

    for pkg in pkgreqs:
        print(pkg.url)
        if pkg.url.startswith('file://'):
            pkg.source_dir = pkg.url.split('file://',1)[1]
        try:
            pkg.run_egg_info(force_root_egg_info=False) # TODO
            info = pkg.pkg_info()
            print ('#', pkg.name,
                    info['version'],
                    pkg.installed_version,
                    pkg.url,
                    info['Homepage'],
                    )
        except Exception, e:
            print(e)
            pass

import unittest
class Test_not_pip_freeze(unittest.TestCase):
    def test_not_pip_freeze(self):
        not_pip_freeze(
            '/srv/repos/etc/requirements-devenv.txt')


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

    not_pip_freeze(args[0])

if __name__ == "__main__":
    main()
