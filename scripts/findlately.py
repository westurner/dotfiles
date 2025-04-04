#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
findlately
"""
import datetime
import json
import logging
import os
import subprocess
import sqlite3
import sys

try:
    import pytest
except ImportError:
    class pytest:
        class mark:
            class parametrize:
                def __call__(self, *args, **kwargs):
                    return self

                def __init__(self, *args, **kwargs):
                    pass


__version__ = "0.0.1"


DEFAULT_LOGGER = 'pyline'
log = logging.getLogger(DEFAULT_LOGGER)
hdlr = logging.StreamHandler(stream=sys.stderr)
# fmt = logging.Formatter(logging.BASIC_FORMAT)
fmt = logging.Formatter('%(levelname)-5s %(name)s:%(lineno)5s: %(message)s')
hdlr.setFormatter(fmt)
log.addHandler(hdlr)
# log.setLevel(logging.DEBUG)
# log.setLevel(logging.INFO)
log.setLevel(logging.WARN)


def create_db():
    cx = sqlite3.connect(":memory:")
    cu = cx.cursor()
    cu.executescript("""
        BEGIN;
        CREATE TABLE jobs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ctime,
            command TEXT
        );
        CREATE TABLE files(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            job_id INTEGER REFERENCES jobs(id),
            path,
            mtime,
            type
        );

        CREATE INDEX file_path_idx ON files (path);
        CREATE INDEX file_jobid_path_idx ON FILES (job_id, path);

        COMMIT;
    """)
    return cx, cu


def findlately(paths):
    """list file modification times

    Arguments:
        paths (str): ...

    Returns:
        str: ...

    Raises:
        Exception: ...
    """
    config = {}
    config['paths'] = paths
    log.debug(('config', config))

    cx, cu = create_db()

    def now():
        return datetime.datetime.now().timestamp() * 1000

    command = ['find', paths, '-todo']

    cu.execute('BEGIN')
    cu.execute('INSERT INTO jobs (ctime,command) VALUES(?, ?)',
               (now(), json.dumps(command)))
    job_id = cu.lastrowid
    cu.execute('COMMIT')

    _output_lines = subprocess.check_output(command)
    for _line in _output_lines.splitlines():
        col1, col2 = _line.split('DELIMITER', 1)

    cu.execute('INSERT INTO files (jobid, ) VALUES(?, )',
               job_id,
    )

    breakpoint()

    cx.close()


TEST_PATHS = [os.path.dirname(__file__)]

#def test_findlately():
@pytest.mark.parametrize('paths', [
    [TEST_PATHS],
])
def test_findlately(paths):
    output = findlately(paths)
    assert output
    assert False


@pytest.mark.parametrize('argv', [
    None,
    [],
])
def test_main(argv):
    """test the main(sys.argv) CLI function"""
    output = main(argv)
    assert output == 0


@pytest.mark.parametrize('argv', [
    ['-h'],
    ['--help'],
])
def test_main_help(argv):
    """test the main(sys.argv) CLI function"""
    with pytest.raises(SystemExit):
        output = main(argv)
        assert output == 0


def main(argv=None):
    """
    findlately main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import argparse

    prs = argparse.ArgumentParser(
        usage="%(prog)s [-h][-v] <path> [<path2> [...]]")

    prs.add_argument('-v', '--verbose',
                     dest='verbose',
                     action='store_true',)
    prs.add_argument('-q', '--quiet',
                     dest='quiet',
                     action='store_true',)
    prs.add_argument('-t', '--test',
                     dest='run_tests',
                     action='store_true',)
    prs.add_argument('--version',
                     dest='version',
                     action='store_true')

    argv = list(argv) if argv else []
    (opts, args) = prs.parse_known_args(args=argv, namespace=None)
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
        sys.argv = [sys.argv[0]] + args
        #return unittest.main()
        import subprocess
        return subprocess.call(['pytest', '-v', '-l'] + args + [__file__])

    if not len(argv):
        prs.print_help()
        return 0

    EX_OK = 0
    paths = args
    if not len(paths):
        paths = ['.']
    log.debug(('paths', args))
    output = findlately(paths)
    print(output)
    return EX_OK


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
