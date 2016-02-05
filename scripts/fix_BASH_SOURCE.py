#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
fix_BASH_SOURCE
"""

import codecs
import collections
import difflib


def fix_BASH_SOURCE(fileobj=None):
    """mainfunc

    Keyword Arguments:
        fileobj(str): ...

    Returns:
        tuple: (modified <bool>, lines <list[str]>)

    Yields:
        str: ...

    Raises:
        Exception: ...


    .. warning:: This changes trailing newlines

    """

    lines = fileobj.readlines()
    lines_orig = lines[:]

    # transforms
    if lines[0].startswith('#!/bin/bash'):
        lines[0] = lines[0].replace(
            '#!/bin/bash',
            '#!/usr/bin/env bash',
            1)
    for n, line in enumerate(lines):
        _line = None
        if not line.startswith('if ['):
            continue
        _line = line.replace(
            'if [ "${BASH_SOURCE}" == "${0}" ]; then',
            'if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then',
            1)
        _line = _line.replace(
            'if [[ "${BASH_SOURCE}" == "${0}" ]]; then',
            'if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then',
            1)
        if _line != line:
            lines[n] = _line

    # comparison
    for line in difflib.unified_diff(
            lines_orig, lines,
            'original {!s}'.format(file.name),
            'modified {!s}'.format(file.name)):
        print(line, end='')

    return lines != lines_orig, lines


def fix_BASH_SOURCE_files(paths, inplace=True, suffix='.fix'):
    pthresults = collections.OrderedDict()
    for path in paths:
        modified = None
        lines = None
        if inplace:
            dst_path = path
        else:
            dst_path = dst_path + suffix
        with codecs.open(path, 'r', 'utf8') as f:
            modified, lines = fix_BASH_SOURCE(f)
        if modified:
            with codecs.open(dst_path, 'w', 'utf8') as f:
                f.writelines(lines)
        pthresults[path] = collections.OrderedDict(
            modified=modified, lines=lines)
    return pthresults


import unittest


class Test_fix_BASH_SOURCE(unittest.TestCase):

    def setUp(self):
        pass

    def test_fix_BASH_SOURCE(self):
        pass

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
    import optparse

    prs = optparse.OptionParser(usage="%prog : args")

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)

    argv = list(argv) if argv else []
    (opts, args) = prs.parse_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log = logging.getLogger()
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        return unittest.main()

    EX_OK = 0

    paths = args
    output = fix_BASH_SOURCE_files(paths)
    for key, value in output.items():
        print((key, value['modified']))
    return EX_OK


if __name__ == "__main__":
    import sys
    sys.exit(main(argv=sys.argv[1:]))
