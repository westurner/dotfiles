#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
strace_compare
"""
import logging
import os
import re
import subprocess
import sys
import unittest

try:
    import pytest
except ImportError:
    class pytest:
        class mark:
            def parametrize(self, *args, **kwargs):
                pass


__version__ = "0.0.1"

log = logging.getLogger()


def add_output_args(cmd, outputfile, argv0="strace"):
    if isinstance(cmd, str):
        pos = cmd.index(argv0)
        start = pos + len(argv0)
        # TODO: quote outputfile for the
        return f"{cmd[0:start]} -o '{outputfile}' {cmd[start:]}"
    elif hasattr(cmd, 'index'):
        pos = cmd.index(argv0)
        start = pos + 1
        return [*cmd[0:start], *['-o', outputfile], *cmd[start:]]
    else:
        raise ValueError(('unknown cmd type', type(cmd), cmd))


@pytest.mark.parametrize('cmd,outputfile,argv0,expected', [
    ['strace -e trace=file -f CMD', 'test.log', 'strace',
     "strace -o 'test.log'  -e trace=file -f CMD"],
])
def test_add_output_args_str(cmd, outputfile, argv0, expected):
    output = add_output_args(cmd, outputfile, argv0)
    assert output == expected


@pytest.mark.parametrize('cmd,outputfile,argv0,expected', [
    [['strace','-e trace=file','-f','CMD'], 'test.log', 'strace',
     ["strace","-o",'test.log','-e trace=file','-f','CMD']],
])
def test_add_output_args_list(cmd, outputfile, argv0, expected):
    output = add_output_args(cmd, outputfile, argv0)
    assert output == expected


# def add_extension_prefix(path, prefix):
#     pth, ext = os.path.splitext(path)
#     return f'{pth}{prefix}.{ext}'


def add_filename_suffix(path, suffix):
    fileparts = [path, suffix]
    current_extension = os.path.splitext(path)[-1][1:]
    if current_extension:
        fileparts.append(current_extension)
    return '.'.join(fileparts)


@pytest.mark.parametrize('path,suffix,expected', [
    ['/home/user/file.log', 'test1', '/home/user/file.log.test1.log'],
    ['/home/user/file', 'test1', '/home/user/file.test1'],
])
def test_add_filename_suffix(path, suffix, expected):
    output = add_filename_suffix(path, suffix)
    assert output == expected


def strace_compare(cmd1, cmd2, cmd0=None, verbose=False):
    """run the given strace commands cmd1 and cmd2 and compare their outputs, less the output of cmd0

    Arguments:
        cmd1, cmd2, cmd0 (str): ...

    Keyword Arguments:
        cmd1, cmd2, cmd0 (str): ...

    Returns:
        str: ...

    Yields:
        str: ...

    Raises:
        Exception: ...
    """
    data = dict(
        cmd1={'command': cmd1},
        cmd2={'command': cmd2})
    if cmd0 is not None:
        data['cmd0'] = {'command': cmd0}
    for name,cmd in data.items():
        cmd['output_path'] = f'{name}.strace.log'
        cmd_ = add_output_args(cmd['command'], cmd['output_path'])
        cmd['command_with_output_path'] = cmd_
        log.debug({'cmd_': cmd_})
        proc = subprocess.Popen(
            cmd_,
            shell=True, # !
            text=True,
            stderr=subprocess.STDOUT)
        proc.communicate()
        cmd['returncode'] = proc.returncode
        if verbose:
            with open(cmd['output_path'], 'r') as file_:
                output = file_.read()
                print('\n##', name, cmd)  # file=sys.stderr)
                print(f'+{cmd}')  # TODO; ~shell $PS2
                print(output)

    # TODO: build output_transformers according to [cli input, config idk yaml]

    class TransformerPipeline:
        def __init__(self, config):
            self.config = config

        def transform(self):
            if self.config.get('striphex12'):
                self.striphex12

    class striphex12:
        @staticmethod
        def process_line(line):
            return re.sub(r'\d{12}')

    for name, transformer in output_transformers.items():
        outputfile = add_filename_suffix(cmd['output_path'], name)
        cmd['transformed']['output_path'] = outputfile
        cmd['transformed']['name'] = name
        with open(cmd['output_path'], 'r') as file_:
            with open(cmd['transformed']['output_path'], 'w') as transformed:
                transformed.write(transformer(file_.read()))
                # NOTE: this does not buffer lines; TODO handling the long
                # streaming case

    cmd = ['git',
           'diff',
           '--word-diff',
           data["cmd1"]["output_path"],
           data["cmd2"]["output_path"],
           ]
    proc = subprocess.Popen(cmd)
    proc.communicate()
    assert proc.returncode == 0, (dict(returncode=proc.returncode))
    return data



#def test_strace_compare():
@pytest.mark.parametrize('cmd1, cmd2, cmd0', [
    ['strace -e trace=file -f python -c "import this"',
     'strace -e trace=file -f python -c "import math"',
     'strace -e trace=file -f python -c "pass"',]
])
def test_strace_compare(cmd1, cmd2, cmd0):
    output = strace_compare(cmd1, cmd2, cmd0=cmd0)
    assert output
    print(output)
    raise NotImplementedError("TODO")


@pytest.mark.parametrize('argv', [
    None,
    [],
    ['-h'],
    ['--help'],
])
def test_main(argv, capsys):
    """test the main(sys.argv) CLI function"""
    with pytest.raises(SystemExit) as e:
        output = main(argv)
        assert e.code == 0
        captured = capsys.readouterr()
        assert '--help' in captured.out
        assert output == 0


def main(argv=None):
    """
    strace_compare main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import argparse

    prs = argparse.ArgumentParser(
        usage="%(prog)s [-h][-v] --cmd1 <cmd> --cmd2 <cmd> [--cmd0 <cmd>]")

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

    prs.add_argument('--cmd1',
                   dest='cmd1',
                   action='store',
                   help='First command')
    prs.add_argument('--cmd2',
                   dest='cmd2',
                   action='store',
                   help='Second command')
    prs.add_argument('--cmd0',
                   dest='cmd0',
                   action='store',
                   help='Third command to subtract from cmd1 and cmd2')

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
        #sys.argv = [sys.argv[0]] + args
        #return unittest.main()
        import subprocess
        return subprocess.call(['pytest', '-v', '-l'] + args + [__file__])

    EX_OK = 0
    if not opts.cmd1 or not opts.cmd2:
        prs.error("--cmd1 and --cmd2 must be specified")

    output = strace_compare(opts.cmd1, opts.cmd2, cmd0=opts.cmd0)
    print(output)
    return EX_OK


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
