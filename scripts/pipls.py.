#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
not_pip_freeze
"""

import pip
import pip.req
import pip.download
import logging

log = logging.getLogger()


class Options(object):

    def __getattr__(self, attr):
        print(attr)
        return None


def get_pkg_reqs(path):
    log.debug("parsing pip reqs file: %r" % path)
    for _req in pip.req.parse_requirements(path,
                                           options=Options(),
                                           session=pip.download.PipSession()):
        yield _req


def not_pip_freeze(path):
    pkgreqs = get_pkg_reqs(path)

    for pkg in pkgreqs:
        log.debug(pkg.__dict__)
        if not pkg.url:
            log.error("pkg.url is none!: %r (%r)" % (pkg.url, pkg))
            continue
        if pkg.url.startswith('file://'):
            pkg.source_dir = pkg.url.split('file://', 1)[1]
        try:
            pkg.run_egg_info(force_root_egg_info=False)  # TODO
            info = pkg.pkg_info()
            print ('#', pkg.name,
                   info['version'],
                   pkg.installed_version,
                   pkg.url,
                   info['Homepage'],
                   )
        except Exception as e:
            log.exception(e)
            pass


import unittest

import os.path
requirements_test_file = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    '../',
    'requirements/requirements-dev.txt'
)


class Test_not_pip_freeze(unittest.TestCase):

    def test_not_pip_freeze(self):
        not_pip_freeze(requirements_test_file)


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
