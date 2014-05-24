#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
dotfiles
"""


def get_pkg_resource_filename(path=''):
    """
    This package generates a MANIFEST.in file from version control (hg)
    in order to include files outside of the package source directory
    (src/dotfiles).

    When installed as an editable or a source dist, these additional
    data files have paths relative to ``pkg_resource.resource_filename``.

    Args:
        path (str): path fragment (eg. ``etc/vim``)
    Returns:
        path (str): absolute path to ``path``, relative to this package install
    """
    import pkg_resources
    import os.path
    _relpath = os.path.join('../..', path)
    resource_path = pkg_resources.resource_filename('dotfiles', _relpath)
    return os.path.abspath(resource_path)


def dotfiles():
    """
    mainfunc
    """
    pass


import unittest


class Test_dotfiles(unittest.TestCase):

    def test_get_pkg_resource_filename(self):
        path = get_pkg_resource_filename('etc/vim/vimrc')
        self.assertTrue(path)

    def test_dotfiles_main(self):
        retcode = main('--resource-path', 'etc/vim/vimrc')
        self.assertIsNone(retcode)
        # TODO


def main(*args):
    import sys
    import optparse
    import logging

    prs = optparse.OptionParser(usage="./%prog : args")

    prs.add_option('--resource-path',
                   dest='resource_path',
                   action='store')
    prs.add_option('--version',
                   dest='version',
                   action='store_true')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)

    args = args and list(args) or sys.argv[1:]
    (opts, args) = prs.parse_args()

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.version:
        import dotfiles
        print(dotfiles.version)
        sys.exit(0)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        sys.exit(unittest.main())

    if opts.resource_path:
        print(get_pkg_resource_filename(opts.resource_path))
        return 0

    dotfiles()

if __name__ == "__main__":
    main()

