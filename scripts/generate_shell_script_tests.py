#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
genshelltests
"""
import logging
import os
import pathlib
import re
import subprocess
import sys
import types

import typing

try:
    import pytest
except ImportError:
    pytest = None

__version__ = "0.0.1"

log = logging.getLogger()
log.setLevel(logging.DEBUG)

def genshelltests():
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
    pass


def test_main_no_args(capsys):
    with pytest.raises(SystemExit):
        output = main()
        assert output == 0


# @pytest.mark.parametrize('argv', [
#     None,
#     [],

# ]
def test_main_help():
    """test the main(sys.argv) CLI function"""
    with pytest.raises(SystemExit):
        output = main(argv=['-h'])
        assert output == 0
        captured = capsys.readouterr()
        assert "--help" in captured.out
    with pytest.raises(SystemExit):
        output = main(argv=['--help'])
        assert output == 0
        captured = capsys.readouterr()
        assert "--help" in captured.out


def main(argv=None):
    """
    genshelltests main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import optparse

    prs = optparse.OptionParser(
        usage="%prog [-h][-v] [--list <_.sh>] [--src <_.sh>]")

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)
    prs.add_option('--version',
                   dest='version',
                   action='store_true')

    prs.add_option('--list',
                   dest='list_functions',
                   action='store',
                   help='if specified, list functions from this shell script')

    prs.add_option('--src',
                   dest='src',
                   action='store',
                   help='if specified, generate test functions for this shell script')

    argv = list(argv) if argv else []
    (opts, args) = prs.parse_args(args=argv)
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
        cov_args = [f'--cov={__file__}', '--cov-report=term-missing']
        return subprocess.call(['pytest', '-v', *cov_args, *args, __file__])
    else:
        if not any((opts.list_functions, opts.src,)):
            prs.print_help()
            prs.error("None of --list, --src, or --test were specified")
            return 1

    if opts.list_functions:
        for line in genshelltests_list_functions(opts.list_functions):
            print(line)

    if opts.src:
        print(genshelltests_with_vim(opts.src))  # TODO: to file

    EX_OK = 0
    #output = genshelltests()
    return EX_OK


from functools import partial

class Popen_with_logging(subprocess.Popen):
    def __init__(self, *args, cmdprefix='+', **kwargs):
        print = kwargs.get("printfunc",
                           partial(__builtins__.print, file=sys.stderr))
        # print = log.debug ; printfunc=log.debug

        if kwargs.get('shell'):
            if len(args) == 1:
                cmdstr = args[0]
            else:
                cmdstr = " ".join(str(x) for x in args)
        else:  # elif shell==False:
            if len(args) == 1:
                cmdstr = " ".join(str(x) for x in args[0])
            else:
                cmdstr = " ".join(str(x) for x in args)

        event = dict(event='subprocess.Popen', args=args, kwargs=kwargs)
        event['cmdstr'] = cmdstr
        print(event)
        print(f'>>> subprocess.Popen(*{args}, **{kwargs})')
        print(cmdprefix, cmdstr)

        super().__init__(*args, **kwargs)


_subprocess_Popen = subprocess.Popen
subprocess.Popen = Popen_with_logging

# TODO: more proper monkeypatch


# def genshelltests_with_vim(src) -> int:
#     src = "scripts/usrlog.sh"
#     test_script=f"{src}_test.sh"
#     # | grep '\(\)\s*{\s*$'

#     cmd = (
#     """vim -c '%!cat '""" + f'{src}' + r""" | grep ^function .* {|\(\)\s*{\s*$' \
#         -c '%s:^function :function test_:g' \
#         -c '%s:{:{\r    (set -x; echo "NotImplemented"); return 2;\r}\r\r:g')"""
#            + f'-c :w {test_script}')
#     with subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, bufsize=1,
#         text=True) as proc:
#         for line in proc.stdout:
#             print(line)
#     return proc.returncode


# def test_genshelltests_with_vim():
#     src = pathlib.Path(__file__).parent / 'generate_shell_script_tests.sh'
#     output = genshelltests_with_vim(src)
#     assert output
#     assert isinstance(output, types.GeneratorType)
#     assert any('test_' in x for x in list(output))
#     raise NotImplementedError


def genshelltests_with_python(src) -> typing.Iterator[str]:
    for filename, loc, line in genshelltests_list_functions(src):
        log.debug((filename, loc, line))
        _line = line.replace('function ', 'function test_')
        _line = _line.replace('{', """{
    (set -x; echo "NotImplemented"); return 2;
}
""")
        yield _line


def test_genshelltests_with_python():
    src = pathlib.Path(__file__).parent / 'generate_shell_script_tests.sh'
    output = genshelltests_with_python(src)
    assert output
    assert isinstance(output, types.GeneratorType)
    assert any('test_' in x for x in list(output))
    #raise NotImplementedError


def genshelltests_list_functions(src, linesep=os.linesep) -> typing.Iterator[tuple[pathlib.Path, int, str]]:
    if not src:
        raise ValueError(('src must not be None'))
    rgx = re.compile(r'^function [\w_]+ {|[\w_]+\(\s*\)\s*\{')
    with open(src, 'r') as f:
        for line_number, line in enumerate(f):
            if rgx.match(line):
                yield ((src, line_number, line.removesuffix(linesep)))


def test_genshelltests_list_functions():
    src = pathlib.Path(__file__).parent / 'generate_shell_script_tests.sh'
    output = genshelltests_list_functions(src)
    assert output
    assert isinstance(output, types.GeneratorType)
    outputlist = list(output)
    outputstr = "\n".join(x[-1] for x in outputlist)
    assert 'function ' in outputstr
    assert 'genshelltests_with_vim() {' in outputstr


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
