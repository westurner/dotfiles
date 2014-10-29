#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""

**pyline**

A simple UNIX tool for line-based processing in Python.

Features:

* Python str.split by a delimiter (``-F``)
* Python Regex (``-r``, ``--regex``, ``-R``, ``--regex-options``)
* Output as txt, csv, ttsv, json (``-O``, ``-output-filetype``)
* (Lazy) sorting (``-s``, ``--sort-asc``, ``-S``, ``--sort-desc``)
* Create Path.py (or pathlib) objects from each line (``-p``)
* namedtuples, ``yield``ing generators

**Usage**

Shell::

    pyline.py --help
    pyline.py --test

    # Print every line (null transform)
    cat ~/.bashrc | pyline.py line
    cat ~/.bashrc | pyline.py l

    # Number every line
    cat ~/.bashrc | pyline -n l

    # Print every word (str.split(--input-delim=None))
    cat ~/.bashrc | pyline.py words
    cat ~/.bashrc | pyline.py w

    # Split into words and print (default: tab separated)
    cat ~/.bashrc | pyline.py 'len(w) >= 2 and w[1] or "?"

    # Select the last word, dropping lines with no words
    pyline.py -f ~/.bashrc 'w[-1:]'

    # Regex matching with groups
    cat ~/.bashrc | pyline.py -n -r '^#(.*)' 'rgx and rgx.group()'


"""

import csv
import json
import logging
import operator
import textwrap
import pprint

from collections import namedtuple

EPILOG = __doc__  # """  """

REGEX_DOC = """I  IGNORECASE  Perform case-insensitive matching.
L  LOCALE      Make \w, \W, \b, \B, dependent on the current locale.
M  MULTILINE   "^" matches the beginning of lines (after a newline)
                as well as the string.
                "$" matches the end of lines (before a newline) as well
                as the end of the string.
S  DOTALL      "." matches any character at all, including the newline.
X  VERBOSE     Ignore whitespace and comments for nicer looking RE's.
U  UNICODE     Make \w, \W, \b, \B, dependent on the Unicode locale."""
REGEX_OPTIONS = dict(
    (l[0],
        (l[1:14].strip(), l[15:]))
    for l in REGEX_DOC.split('\n'))

STANDARD_REGEXES = {}

log = logging.getLogger()
log.setLevel(logging.INFO)
log.setLevel(logging.DEBUG)


class NullHandler(logging.Handler):
    def emit(self, record):
        pass


h = NullHandler()
log.addHandler(h)

Result = namedtuple('Result', ('n', 'result'))


class PylineResult(Result):

    def __str__(self):
        result = self.result
        odelim = u'\t'  # TODO
        if result is None or result is False:
            return result

        elif hasattr(self.result, 'itervalues'):
            for col in self.result.itervalues():
                return odelim.join(str(s) for s in self.result.itervalues())

        elif hasattr(self.result, '__iter__'):
            result = odelim.join(str(s) for s in result)
        else:
            if result[-1] == '\n':
                result = result[:-1]
        return result

    def _numbered(self, **opts):
        yield self.n
        if self.result is None or self.result is False:
            yield self.result

        elif hasattr(self.result, 'itervalues'):
            for col in self.result.itervalues():
                yield col

        elif hasattr(self.result, '__iter__'):
            for col in self.result:
                yield col

        elif hasattr(self.result, 'rstrip'):
            yield self.result.rstrip()

    def _numbered_str(self, odelim):
        record = self._numbered()
        return ' %4d%s%s' % (
            record.next(),
            odelim,
            unicode(odelim).join(str(x) for x in record))


def _import_path_module():
    """
    Attempt to import a path module (path.py, pathlib, str)

    Returns:
        function: function to apply to each line
    """
    Path = None
    try:
        # First, try to import path.py (pip install path.py)
        from path import path as Path
    except ImportError:
        log.debug("path.py not found (pip install path.py)")
        try:
            # Otherwise, try to import pathlib (pip install pathlib OR Py3.4+)
            from pathlib import Path
            pass
        except ImportError:
            log.error("pathlib not found (pip install pathlib)")
            Path = str  # os.exists, os
            pass
    return Path

Path = _import_path_module()


def get_path_module():
    return Path


def pyline(iterable,
           cmd=None,
           modules=[],
           regex=None,
           regex_options=None,
           path_tools_pathpy=False,
           path_tools_pathlib=False,
           idelim=None,
           odelim="\t",
           **kwargs):
    """
    Process an iterable of lines

    Args:
        iterable (iterable): iterable of strings (e.g. sys.stdin or a file)
        cmd (str): python command string
        modules ([str]): list of modules to import
        regex (str): regex pattern to match (with groups)
        regex_options (TODO): Regex options: I L M S X U (see ``pydoc re``)
        path_tools (bool): try to cast each line to a file
        idelim (str): input delimiter
        odelim (str): output delimiter

    Returns:
        iterable of PylineResult namedtuples
    """

    for _importset in modules:
        for _import in _importset.split(','):
            locals()[_import] = __import__(_import.strip())

    _rgx = None
    if regex:
        import re
        _regexstr = regex
        if bool(regex_options):
            _regexstr = ("(?%s)" % (regex_options)) + _regexstr
        #    _regexstr = r"""(?%s)%s""" % (
        #        ''.join(
        #            l.lower() for l in regex_options
        #                if l.lower() in REGEX_OPTIONS),
        #        _regexstr)
        log.debug("_rgx = %r" % _regexstr)
        _rgx = re.compile(_regexstr)

    if cmd is None:
        if regex:
            cmd = "rgx and rgx.groups()"
            # cmd = "rgx and rgx.groupdict()"
        else:
            cmd = "line"
        if path_tools_pathpy or path_tools_pathlib:
            cmd = "p"

    Path = str
    if path_tools_pathpy:
        Path = path.path
    if path_tools_pathlib:
        Path = pathlib.Path


    try:
        log.info("_cmd: %r" % cmd)
        codeobj = compile(cmd, 'command', 'eval')
    except Exception as e:
        e.message = "%s\ncmd: %s" % (e.message, cmd)
        log.error(repr(cmd))
        log.exception(e)
        raise

    def item_keys(obj, keys):
        if isinstance(keys, (str, unicode)):
            keys = [keys]
        for k in keys:
            if k is None:
                yield k
            else:
                yield obj.__getslice__(k)

    k = lambda obj, keys=(':',): [obj.__getslice__(k) for k in keys]
    j = lambda args: odelim.join(str(_value) for _value in args)
    # from itertools import imap, repeat
    # j = lambda args: imap(str, izip_longest(args, repeat(odelim)))

    i_last = None
    if 'i_last' in cmd:
        # Consume the whole file into a list (to count lines)
        iterable = list(iterable)
        i_last = len(iterable)

    pp = pprint.pformat

    for i, line in enumerate(iterable):
        l = line
        w = words = [w for w in line.strip().split(idelim)]

        p = path = None
        if path_tools_pathpy or path_tools_pathlib and line.rstrip():
            try:
                p = path = Path(line.strip()) or None
            except Exception as e:
                log.exception(e)
                pass

        rgx = _rgx and _rgx.match(line) or None

        # Note: eval
        try:
            result = eval(codeobj, globals(), locals())  # ...
        except Exception as e:
            e.cmd = cmd
            log.exception(repr(cmd))
            log.exception(e)
            raise
        yield PylineResult(i, result)


def itemgetter_default(args, default=None):
    """
    Return a callable object that fetches the given item(s) from its operand,
    or the specified default value.

    Similar to operator.itemgetter except returns ``default``
    when the index does not exist
    """
    if args is None:
        columns = xrange(len(args))
    else:
        columns = args

    def _itemgetter(row):
        for col in columns:
            try:
                yield row[col]
            except IndexError:
                yield default
    return _itemgetter


def get_list_from_str(str_, cast_callable=int):
    if not str_ or not str_.strip():
        return []
    return [cast_callable(x.strip()) for x in str_.split(',')]


def sort_by(sortstr, nl, reverse=False):
    columns = get_list_from_str(sortstr)
    log.debug("columns: %r" % columns)

    # get_columns = operator.itemgetter(*columns)
    get_columns = itemgetter_default(columns, default=None)

    return sorted(nl,
                  key=get_columns,
                  reverse=reverse)


class ResultWriter(object):
    OUTPUT_FILETYPES = {
        'csv': ",",
        'json': True,
        'tsv': "\t",
        'html': True,
        "txt": True,
        "checkbox": True
    }
    filetype = None

    def __init__(self, _output, *args, **kwargs):
        self._output = _output
        self._conf = kwargs
        self.setup(_output, *args, **kwargs)

    def setup(self, *args, **kwargs):
        pass

    def set_output(self, _output):
        if _output and self._output is not None:
            raise Exception()
        else:
            self._output = _output

    def header(self, *args, **kwargs):
        pass

    def write(self, obj):
        print(obj, file=self._output)

    def write_numbered(self, obj):
        print(obj, file=self._output)

    def footer(self, *args, **kwargs):
        pass

    @classmethod
    def get_writer(cls, _output,
                   filetype="csv",
                   **kwargs):
        """get writer object for _output with the specified filetype

        :param output_filetype: txt | csv | tsv | json | html | checkbox
        :param _output: output file

        """
        output_filetype = filetype.strip().lower()

        if output_filetype not in ResultWriter.OUTPUT_FILETYPES:
            raise Exception()

        writer = None
        if output_filetype == "txt":
            writer = ResultWriter_txt(_output)
        elif output_filetype == "csv":
            writer = ResultWriter_csv(_output, **kwargs)
        elif output_filetype == "tsv":
            writer = ResultWriter_csv(_output, delimiter='\t', **kwargs)
        elif output_filetype == "json":
            writer = ResultWriter_json(_output)
        elif output_filetype == "html":
            writer = ResultWriter_html(_output, **kwargs)
        elif output_filetype == "checkbox":
            writer = ResultWriter_checkbox(_output, **kwargs)
        else:
            raise NotImplementedError()
        return (
            writer,
            (kwargs.get('number_lines')
                and writer.write_numbered or writer.write))


class ResultWriter_txt(ResultWriter):
    filetype = 'txt'

    def write_numbered(self, obj):
        self.write(obj._numbered_str(odelim='\t'))


class ResultWriter_csv(ResultWriter):
    filetype = 'csv'

    def setup(self, *args, **kwargs):
        self.delimiter = kwargs.get(
            'delimiter',
            ResultWriter.OUTPUT_FILETYPES.get(
                self.filetype,
                ','))
        self._output_csv = csv.writer(self._output,
                                      quoting=csv.QUOTE_NONNUMERIC,
                                      delimiter=self.delimiter)
        #                             doublequote=True)

    def header(self, *args, **kwargs):
        attrs = kwargs.get('attrs', PylineResult._fields)
        self._output_csv.writerow(attrs)

    def write(self, obj):
        self._output_csv.writerow(obj.result)

    def write_numbered(self, obj):
        self._output_csv.writerow(tuple(obj._numbered()))


class ResultWriter_json(ResultWriter):
    filetype = 'json'

    def write(self, obj):
        print(
            json.dumps(
                obj._asdict(),
                indent=2),
            end=',\n',
            file=self._output)

    write_numbered = write


class ResultWriter_html(ResultWriter):
    filetype = 'html'

    def header(self, *args, **kwargs):
        attrs = kwargs.get('attrs')
        self._output.write("<table>")
        self._output.write("<tr>")
        if bool(attrs):
            for col in attrs:
                self._output.write(u"<th>%s</th>" % col)
        self._output.write("</tr>")

    def _html_row(self, obj):
        yield '\n<tr>'
        for attr, col in obj._asdict().iteritems():  # TODO: zip(_fields, ...)
            yield "<td%s>" % (
                attr is not None and (' class="%s"' % attr) or '')
            if hasattr(col, '__iter__'):
                for value in col:
                    yield u'<span>%s</span>' % value
            else:
                # TODO
                yield u'%s' % (
                    col and hasattr(col, 'rstrip') and col.rstrip()
                    or str(col))
            yield "</td>"
        yield "</tr>"

    def write(self, obj):
        return self._output.write(u''.join(self._html_row(obj,)))

    def footer(self):
        self._output.write('</table>\n')


class ResultWriter_checkbox(ResultWriter):
    filetype = 'checkbox'

    def _checkbox_row(self, obj, wrap=79):
        yield u'\n'.join(textwrap.wrap(
            unicode(obj),
            initial_indent=u'- [ ] ',
            subsequent_indent=u'      '
        ))
        yield '\n'

    def write(self, obj):
        return self._output.write(u''.join(self._checkbox_row(obj)))


def get_option_parser():
    import optparse
    prs = optparse.OptionParser(
        usage="%prog: [options] \"<command>\"",
        epilog=EPILOG)

    prs.add_option('-f',
                   dest='file',
                   action='store',
                   default='-',
                   help="Input file (default: '-' for stdin)")

    prs.add_option('-o', '--output-file',
                   dest='output',
                   action='store',
                   default='-',
                   help="Output file (default: '-' for stdout)")
    prs.add_option('-O', '--output-filetype',
                   dest='output_filetype',
                   action='store',
                   default='txt',
                   help="Output filetype <txt|csv|tsv|json> (default: txt)")

    prs.add_option('-F', '--input-delim',
                   dest='idelim',
                   action='store',
                   default=None,
                   help=('Strings input field delimiter to split line'
                         ' into ``words`` by'
                         ' (default: None (whitespace)``'))
    prs.add_option('-d', '--output-delim',
                   dest='odelim',
                   default="\t",
                   help=('String output delimiter for lists and tuples'
                         ' (default: \t (tab))``'))

    prs.add_option('-m', '--modules',
                   dest='modules',
                   action='append',
                   default=[],
                   help='Module name to import (default: []) see -p and -r')

    prs.add_option('-p', '--pathpy',
                   dest='path_tools_pathpy',
                   action='store_true',
                   help='Create path.py objects (p) from each ``line``')

    prs.add_option('--pathlib',
                   dest='path_tools_pathlib',
                   action='store_true',
                   help='Create pathlib objects (p) from each ``line``')

    prs.add_option('-r', '--regex',
                   dest='regex',
                   action='store',
                   help='Regex to compile and match as ``rgx``')
    prs.add_option('-R', '--regex-options',
                   dest='regex_options',
                   action='store',
                   default='im',
                   help='Regex options: I L M S X U (see ``pydoc re``)')

    prs.add_option("-s", "--sort-asc",
                   dest="sort_asc",
                   action='store',
                   help="Sort Ascending by field number")
    prs.add_option("-S", "--sort-desc",
                   dest="sort_desc",
                   action='store',
                   help="Reverse the sort order")

    prs.add_option('-n', '--number-lines',
                   dest='number_lines',
                   action='store_true',
                   help='Print line numbers of matches')

    prs.add_option('-i', '--ipython',
                   dest='start_ipython',
                   action='store_true',
                   help='Start IPython with results')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)

    return prs


def get_sort_function(opts):  # (sort_asc, sort_desc)
    # FIXME
    if hasattr(opts, 'sort_asc'):
        _sort_asc = opts.sort_asc
        _sort_desc = opts.sort_desc
    else:
        _sort_asc = opts.get('sort_asc')
        _sort_desc = opts.get('sort_desc')

    sortfunc = None
    if _sort_asc:
        logging.debug("sort_asc: %r" % _sort_asc)
        if sortfunc is None:
            def sortfunc(_output):
                return sort_by(
                    _sort_asc,
                    _output,
                    reverse=False)
        else:
            def sortfunc(_output):
                return sort_by(
                    _sort_asc,
                    sortfunc(_output),
                    reverse=False)
    if _sort_desc:
        logging.debug("sort_desc: %r" % _sort_desc)
        if sortfunc is None:
            def sortfunc(_output):
                return sort_by(
                    _sort_desc,
                    _output,
                    reverse=True)
        else:
            def sortfunc(_output):
                return sort_by(
                    _sort_desc,
                    sortfunc(_output),
                    reverse=True)
    return sortfunc


def main(*args):
    import logging
    import sys

    prs = get_option_parser()

    args = args and list(args) or sys.argv[1:]
    (opts, args) = prs.parse_args(args)

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)
            logging.debug(opts.__dict__)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        exit(unittest.main())

    sortfunc = get_sort_function(opts)

    cmd = ' '.join(args)
    if not cmd.strip():
        if opts.regex:
            if opts.output_filetype == 'json' and '<' in opts.regex:
                cmd = 'rgx and rgx.groupdict()'
            else:
                cmd = 'rgx and rgx.groups()'
        else:
            cmd = 'line'

    cmd = cmd.strip()
    opts.cmd = cmd

    if opts.verbose:
        logging.debug(opts.__dict__)

    opts.attrs = PylineResult._fields

    try:
        if opts.file is '-':
            opts._file = sys.stdin
        else:
            opts._file = open(opts.file, 'r')

        if opts.output is '-':
            opts._output = sys.stdout
        else:
            opts._output = open(opts.output, 'w')

        writer, output_func = ResultWriter.get_writer(
            opts._output,
            filetype=opts.output_filetype,
            number_lines=opts.number_lines,
            attrs=opts.attrs)
        writer.header()

        # if not sorting, return a result iterator
        if not sortfunc:
            for result in pyline(opts._file, **opts.__dict__):
                if not result.result:
                    # skip result if not bool(result.result)
                    continue  # TODO

                output_func(result)
        # if sorting, return the sorted list
        else:
            results = []
            for result in pyline(opts._file, **opts.__dict__):
                if not result.result:
                    # skip result if not bool(result.result)
                    continue
                results.append(result)
            for result in sortfunc(results):
                output_func(result)

        writer.footer()
    finally:
        if getattr(opts._file, 'fileno', int)() not in (0, 1, 2):
            opts._file.close()

        if opts.output != '-':
            opts._output.close()


if __name__ == "__main__":
    main()
