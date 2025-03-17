#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
quoteindent
"""
import io
import logging
import re
import sys
import types
import unittest

try:
    import pytest
except ImportError as e:
    print(('DEBUG', 'pytest not found', str(e)), file=sys.stderr)

    import inspect

    TODO = """
    - [ ] BUG: This only works if the pytest fixture args are at the end of the argspec
    """

    class pytest:
        class mark:
            def parametrize(argspecstr: str, testcases: list[list]):
                # print(('args', args))
                # return func(*args, **kwargs)
                def otherfunc(func, *args, **kwargs):
                    func_signature = inspect.signature(func)
                    func_argspec = inspect.getfullargspec(func)
                    func_args = func_argspec.args
                    # remaining = [x for x in func_args if x not in
                    #              (str.strip(y) for y in argspecstr.split(','))]
                    data = dict(func=func,
                                func_args=func_args,
                                args=None,  # =args,
                                kwargs=kwargs,
                                _args=None,
                                _kwargs=None,
                                # pytest_fixture_args=remaining,
                                )

                    allargs = {}
                    for argname, arg in func_signature.parameters.items():
                        allargs[argname] = dict(value=1j, type=1j, definition=dict(argname=argname, arg=arg, arg_kind=arg.kind, arg_default=arg.default))

                    TYPES_TESTARG = 'testarg'
                    TYPES_PYTEST_FIXTURE = 'pytestfixture'

                    for args in testcases:
                        data['args'] = args

                        # TODO: this assumes that all pytest fixture args are *after* parametrized args

                        _args = allargs.copy()
                        for argname, argvalue in zip(func_args[:-1*len(args)], args):
                            _args[argname]['value'] = argvalue
                            _args[argname]['type'] = TYPES_TESTARG
                        for pytest_argname_fixture in func_args[len(args):]:
                            _args[pytest_argname_fixture]['value'] = inspect._empty
                            _args[pytest_argname_fixture]['type'] = TYPES_PYTEST_FIXTURE
                        data['_args'] = _args

                        print(inspect.getsource(func))
                        print(('DEBUG', 'pytest.mark.parametrize', data), file=sys.stderr)
                        print(f'>>> {func.__name__}({str(args)[1:-1]})', file=sys.stderr)

                        argstrs = []
                        for argname, arg in _args.items():
                            arg_kind = arg['definition']['arg_kind']

                            # TODO: here
                            raise Exception()

                            if arg['value'] == inspect._empty:
                                continue
                            if arg_kind in (
                                    inspect._ParameterKind.POSITIONAL_ONLY,
                                    inspect._ParameterKind.VAR_POSITIONAL):
                                argstrs.append(f'{str(arg["value"])}')
                            elif arg_kind == (inspect._ParameterKind.POSITIONAL_OR_KEYWORD):
                                if arg['definition']['arg_default'] == inspect._empty:
                                    argstrs.append(f'{str(arg["value"])}')  # TODO:  thid
                                else:
                                    argstrs.append(f'{argname}={str(arg["value"])}')
                            elif arg_kind in (
                                    inspect._ParameterKind.KEYWORD_ONLY,
                                    inspect._ParameterKind.VAR_KEYWORD):
                                argstrs.append(f'{argname}={str(arg["value"])}')
                        print(('argstrs', argstrs))
                        print(('argstr', f'{func.__name__}({", ".join(argstrs)})'))
                    return lambda func, *args, **kwargs: func(*args, **kwargs)
                return otherfunc


__version__ = "0.0.1"


def quoteindent():
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


class Test_quoteindent(unittest.TestCase):

    def setUp(self):
        pass

    def test_quoteindent(self):
        pass

    def tearDown(self):
        pass


def quoteindent_lines(lines, *, quote_empty_lines, quotechar, wrapchar, wrapchar_end):
    if wrapchar is None:
        wrapchar = ''
    if wrapchar_end is None:
        wrapchar_end = ''
    rgxstr = r'^('+quotechar+r'+\s+)(.*)'
    # print(('debug', 'rgxstr', rgxstr))
    linergx = re.compile(rgxstr)
    for line in lines:
        if not line.strip():
            if quote_empty_lines:
                yield quotechar
            else:
                yield ''
            continue
        _line = line.removesuffix('\n')
        if wrapchar:
            _line = _line.replace(wrapchar, '\\'+wrapchar)
            rgx = linergx.match(_line)
            if rgx:
                yield f'{quotechar}{rgx.group(1)}{wrapchar}{rgx.group(2)}{wrapchar_end}'
            else:
                yield f'{quotechar} {wrapchar}{_line}{wrapchar_end}'
        else:
            rgx = linergx.match(_line)
            if rgx:
                yield f'{quotechar}{rgx.group(1)}{rgx.group(2)}'
            else:
                yield f'{quotechar} {_line}'


CONFIGS = {}
CONFIGS['hn'] = {
    'quotechar': '>',
    'quote_empty_lines': False,
    'wrapchar': '*',
    'wrapchar_end': ' *',  # to prevent "http://url*"
}
CONFIGS['default'] = {
    'quotechar': '>',
    'quote_empty_lines': True,
    'wrapchar': None,
    'wrapchar_end': None
}


@pytest.mark.parametrize('inputfile,kwargs', [
    ["line1\n\nline2\n\n>>> line3_alre*ady_indented\n\n", CONFIGS['hn']],
    ["line1\n\nline2\n\n>>> line3_alre*ady_indented\n\n", CONFIGS['default']],
])
def test_quoteindent_lines(inputfile, kwargs, capsys):
    if isinstance(inputfile, str):
        inputfile = io.StringIO(inputfile)
    output = quoteindent_lines(inputfile, **kwargs)
    assert isinstance(output, types.GeneratorType)
    _output = list(output)
    for line in _output:
        print(line)
    if kwargs['wrapchar']:
        assert r">>>> *line3_alre\*ady_indented *" in _output
    # assert _output is None, _output


def QuoteindentHN(**kwargs):
    return QuoteIndentLinesVim('hn')


def QuoteIndentLinesVim(*args):
    output = sys.stdout.readlines()

    if 'vim' not in globals():
        print(('DEBUG', 'note: calling QuoteIndentLinesVim without globals()["vim"] because it is not set'))

        class vim:
            class current:
                buffer = output
                range = None

    buffer = vim.current.buffer
    if vim.current.range:
        cr = vim.current.range
        text = buffer[cr.start:cr.end+1]
    else:
        text = buffer

    kwargs = {}
    if 'hn' in args:
        kwargs.update(CONFIGS['hn'])
        for line in quoteindent_lines(text, **kwargs):
            print(line, file=output)
    else:
        kwargs.update(CONFIGS['default'])
        for line in quoteindent_lines(text, **kwargs):
            print(line, file=output)


@pytest.mark.parametrize('argv', [
    ['-h'],
    ['--help'],

])
def test_main_help(argv):
    """test the main(sys.argv) CLI function"""
    with pytest.raises(SystemExit):
        output = main(argv)
        assert output
        assert '[-h]' in output


@pytest.mark.parametrize('argv,_stdin', [
    [None, None],
    [[], None],

])
def test_main(argv, _stdin, monkeypatch, capsys):
    """test the main(sys.argv) CLI function"""
    monkeypatch.setattr('sys.stdin', io.StringIO(_stdin or ''))
    output = main(argv)
    assert output == 0
    # TODO: assert capsys.stdout


def main(argv=None):
    """
    quoteindent main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    if argv and "--test" in argv:
        argv.remove('--test')
        import subprocess
        return subprocess.call(['pytest', '-v'] + argv + [__file__])

    import optparse

    prs = optparse.OptionParser(
        usage="%prog [-h] [-i <path|->]")

    prs.add_option('-i',
                   dest='input_file',
                   action='store',
                   default='-',
                   help='file path to read (or "-" for stdin by default)')

    prs.add_option('--quote-empty-lines',
                   dest='quote_empty_lines',
                   action='store_true')
    prs.add_option('--wrapchar',
                   dest='wrapchar',
                   default='',
                   action='store')
    prs.add_option('--wrapchar-end',
                   dest='wrapchar_end',
                   default=None,
                   action='store')
    prs.add_option('--quotechar',
                   dest='quotechar',
                   action='store',
                   default='>')

    prs.add_option('--hn',
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
    prs.add_option('--version',
                   dest='version',
                   action='store_true')

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

    # if opts.run_tests:
    #     sys.argv = [sys.argv[0]] + args
    #     import subprocess
    #     return subprocess.call(['pytest', '-v'] + args + [__file__])

    EX_OK = 0
    kwargs = dict(
        quote_empty_lines=opts.quote_empty_lines,
        quotechar=opts.quotechar,
        wrapchar=opts.wrapchar,
        wrapchar_end=opts.wrapchar_end
    )
    if opts.hn:
        kwargs.update(CONFIGS['hn'])

    if opts.input_file == '-':
        inputfile = sys.stdin
        _inputfile_open = False
    else:
        inputfile = open(opts.input_file, 'r')
        _inputfile_open = True

    for line in quoteindent_lines(inputfile, **kwargs):
        print(line)

    if _inputfile_open:
        inputfile.close()

    return EX_OK


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
