#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
generate_sphinx_block
"""

tmpl = """.. index:: {0}
.. _{1}:

{0}
{2}
"""

def generate_sphinx_block(text, hdrchar=None, **kwargs):
    """Generate Sphinx Block of Text like::

        .. index:: Example Text
        .. _example text:

        Example Text
        =============

    Arguments:
        text (str): heading text
        hdrchar (str): heading character (e.g. '=')
    Raises:
        Exception: ...
    """
    hdrchar = hdrchar if hdrchar is not None else '='
    #hdrchar = kwargs.get('hdrchar', '=')
    return tmpl.format(text, text.lower(), hdrchar * (len(text)+1))


import unittest


class Test_generate_sphinx_block(unittest.TestCase):

    def setUp(self):
        pass

    def test_generate_sphinx_block(self):
        output = generate_sphinx_block('Example Text')
        self.assertMultiLineEqual(output,
""".. index:: Example Text
.. _example text:

Example Text
=============
""")


    def tearDown(self):
        pass


def main(argv=None):
    """
    Main function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import logging
    import argparse

    prs = argparse.ArgumentParser()  #usage="%prog : args")

    prs.add_argument('text', action='store')
    prs.add_argument('hdrchar', action='store', nargs='?', default='=')
    prs.add_argument('additional_index_terms',
                     action='store', nargs='*')

    prs.add_argument('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_argument('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_argument('-t', '--test',
                   dest='run_tests',
                   action='store_true',)


    argv = list(argv) if argv else []
    (opts) = prs.parse_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log = logging.getLogger()
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] # + args
        import unittest
        return unittest.main()

    EX_OK = 0
    output = generate_sphinx_block(opts.text, opts.hdrchar)
    print(output)
    return EX_OK


if __name__ == "__main__":
    import sys
    sys.exit(main(argv=sys.argv[1:]))
