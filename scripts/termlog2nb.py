#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
termlog2nb -- generate an .ipynb notebook from terminal logs

- [ ] compose nb with nbformat
- [ ] parse usrlog-style PS4 before the \n


"""
import logging
import os.path
import re
import sys
import types
import unittest

import pytest

from pathlib import Path

__version__ = "0.0.1"


log = logging.getLogger()
log.setLevel(logging.DEBUG)


def termlog2nb(filename: str):
    """mainfunc

    Arguments:
         (str): ...

    Keyword Arguments:
         (str): ...

    Returns:
        str: ...

    Yields:
        str: ...

    Raises:
        Exception: ...
    """
    path = Path(os.path.expanduser(filename))
    log.debug("path=%r", path)

    if not path.exists():
        raise FileNotFoundError('path does not exist:', path)

    # TODO
    # if not canread(path):
    #     raise FileNotFoundError('path does not exist:', path)

    lines = []
    with open(path, 'r') as termlog:
        for line in termlog:
            lines.append(list(match_regexes(line)))

    return lines


class Regex:
    regexstr: str = None
    fields: list = None
    tags_implied: list = None

    def __init__(self, name=None):
        if name is None:
            name = self.__class__.__name__
        self.name = name
        self.rgx = re.compile(self.regexstr)


class PS4Regex(Regex):
    regexstr = r'^\[(?P<user>[\w\-_]+)@(?P<host>[\w\-_]+) (?P<path>[/\-_\w~\.]+)\](?P<rootornot>[\$#]) (?P<cmd>.*)'
    fields = ['user', 'host', 'path', 'rootornot', 'cmd']
    tags_implied = ['ps4_default']


class SetXRegex(Regex):
    regexstr = r'^(?P<depth>\++)\s(?P<cmd>.*)$'
    fields = ['depth', 'cmd']
    tags_implied = ['setx']


class UsrlogDotfilesRegex(Regex):
    regexstr = r'^\$\s(?P<cmd>.*)$'
    fields = ['cmd']
    tags_implied = ['usrlog']


def build_regexes():
    return [
        PS4Regex(),
        SetXRegex(),
        UsrlogDotfilesRegex()
    ]


REGEXES = build_regexes()


def match_regexes(lines, regexes=None):
    if regexes is None:
        regexes = REGEXES
    for line in (lines if not isinstance(lines, str) else (lines,)):
        linedata = {'line': line, 'matches': {}}
        for regex in regexes:
            matchobj = regex.rgx.match(line, )
            if matchobj is None:
                continue
            data = linedata['matches'][regex] = {}
            data['tags'] = regex.tags_implied
            data['groupdict'] = _groupdict = matchobj.groupdict()
            if not _groupdict:
                data['groups'] = matchobj.groups()
        yield linedata


@pytest.mark.parametrize('lines,regexes,expected', [
    [["+ echo a"], None, None],
    [["$ echo b"], None, None],
])
def test_match_regexes(lines, regexes, expected):
    linesiter = match_regexes(lines, regexes)
    assert isinstance(linesiter, types.GeneratorType)
    for linedata in linesiter:
        assert isinstance(linedata, dict)
        assert 'line' in linedata
        for regexmatch in linedata.get('matches').values():
            assert 'groupdict' in regexmatch or 'groups' in regexmatch


@pytest.mark.parametrize('regexstr,matches', [
    [r'^\[(?P<user>[\w\-_]+)@(?P<host>[\w\-_]+) (?P<path>[/\-_\w~\.]+)\]([\$#]) (?P<cmd>.*)', [
        ["[username@hostname /path/to]$ ls", ["username", "hostname", "/path/to", '$', "ls"]],
    ]],
    [r'^(\++)\s(?P<cmd>.*)$', [
        ["+ echo a",  ["+",  "echo a"]],
        ["++ echo 2", ["++", "echo 2"]],
    ]],

    [r'^\$\s(?P<cmd>.*)$', [
        ["$ echo A", "echo A"],
        # ["output\n$ echo 'B'\n", "echo 'B'"]
    ]],
    # [r'^\$\s(.*)$', [
    #     ["$ echo A", "echo A"],
    #     ["output\n$ echo 'B'\n", "echo 'B'"]
    # ]],

])
def test_regexes(regexstr, matches):
    rgx = re.compile(regexstr, re.MULTILINE)
    for matchstr, match_expected in matches:
        matchobj = rgx.match(matchstr)
        assert matchobj
        assert matchobj.groups()
        for i, expected_value in enumerate(
                match_expected if isinstance(match_expected, list)
                else (match_expected,)):
            assert matchobj.group(i+1) == expected_value


def test_build_regexes():
    output = build_regexes()
    for rgx in output:
        assert hasattr(rgx, '__dict__')
        assert hasattr(rgx, 'rgx')


@pytest.mark.parametrize('filename, expected', [
    ["~/shell_log_test1.html.log", None],
])
def test_termlog2nb(filename, expected):
    output = termlog2nb(filename)
    assert isinstance(output, list)
    # assert isinstance(output, types.GeneratorType)

    assert list(output) == expected


@pytest.mark.parametrize('argv', [
    None,
    [],
    ['-h'],
    ['--help'],
])
def test_main(argv):
    """test the main(sys.argv) CLI function"""
    with pytest.raises(SystemExit):
        _ = main(argv)


def main(argv=None):
    """
    termlog2nb main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import argparse

    prs = argparse.ArgumentParser(
        usage="%(prog)s [-h][-v] -f <filename>")

    prs.add_argument(
        "-f", "--filename",
        dest="filename",
        action="store")

    prs.add_argument(
        '-v', '--verbose',
        dest='verbose',
        action='store_true',)
    prs.add_argument(
        '-q', '--quiet',
        dest='quiet',
        action='store_true',)
    prs.add_argument(
        '-t', '--test',
        dest='run_tests',
        action='store_true',)
    prs.add_argument(
        '--version',
        dest='version',
        action='store_true')



    argv = list(argv) if argv else []
    (opts, args) = prs.parse_known_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log = logging.getLogger('main')
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)
    if opts.version:
        print(__version__)

    if opts.run_tests:
        # sys.argv = [sys.argv[0]] + args
        # return unittest.main()
        import subprocess
        return subprocess.call(['pytest', '-v', '-l'] + args + [__file__])

    EX_OK = 0
    if not opts.filename:
        prs.error("-f <filename> must be specified")

    output = termlog2nb(opts.filename)
    for regexmatches in output:
        for regexmatch in regexmatches:
            if hasattr(regexmatch, 'get') and regexmatch.get('matches'):
                print(regexmatch['line'].removesuffix('\n'))
                # print(regexmatch, type(regexmatch))
                for match_ in regexmatch['matches'].values():
                    print('#', match_)
                print("")
    return EX_OK


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
