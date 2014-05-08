#!/usr/bin/env python
"""

# updated 2012.11.17, Wes Turner
# updated 2005.07.21, thanks to Jacob Oscarson
# updated 2006.03.30, thanks to Mark Eichin

see: http://code.activestate.com/recipes/437932-pyline-a-grep-like-sed-like-command-line-tool/


"""
#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
pyline
"""

import logging
import sys

EPILOG="""  """

REGEX_DOC="""I  IGNORECASE  Perform case-insensitive matching.
L  LOCALE      Make \w, \W, \b, \B, dependent on the current locale.
M  MULTILINE   "^" matches the beginning of lines (after a newline)
                as well as the string.
                "$" matches the end of lines (before a newline) as well
                as the end of the string.
S  DOTALL      "." matches any character at all, including the newline.
X  VERBOSE     Ignore whitespace and comments for nicer looking RE's.
U  UNICODE     Make \w, \W, \b, \B, dependent on the Unicode locale."""
REGEX_OPTIONS=dict(
    (l[0],
        (l[1:14].strip(), l[15:]))
            for l in REGEX_DOC.split('\n'))

STANDARD_REGEXES = {}

log = logging.getLogger()

from collections import namedtuple
Result = namedtuple('Result', ('n', 'result'))
class PylineResult(Result):
    def __str__(self):
        result = self.result
        odelim = u'\t' # TODO
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


def pyline(_input,
        cmd=None,
        modules=[],
        regex=None,
        regex_options=None,
        path_tools=False,
        idelim=None,
        odelim="\t",
        **kwargs):

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
                  #rgx and rgx.groupdict()
        else:
            cmd = "line"

    Path = None
    if path_tools:
        try:
            from path import path as Path
        except ImportError:
            try:
                from pathlib import Path
                pass
            except ImportError:
                log.error("pip install pathlib (or path.py)")
                Path = str
                pass

    try:
        log.debug("_cmd: %r" % cmd)
        codeobj = compile(cmd, 'command', 'eval')
    except Exception, e:
        e.message = "%s\ncmd: %s" % (e.message, cmd)
        log.error(repr(cmd))
        log.exception(e)
        raise


    def item_keys(obj, keys):
        if isinstance(keys, (str, unicode)):
            keys = [keys]
        for k in keys:
            if k == None:
                yield k
            else:
                yield obj.__getslice__(k)

    k = lambda obj, keys=(':',): [obj.__getslice__(k) for k in keys]
    j = lambda args: odelim.join(str(_value) for _value in args)
    # from itertools import imap, repeat
    # j = lambda args: imap(str, izip_longest(args, repeat(odelim)))

    for i, line in enumerate(_input):
        l = line
        w = words = [w for w in line.strip().split(idelim)]

        p = path = None
        if path_tools and line.rstrip():
            try:
                path = Path(line) or None
            except Exception, e:
                log.exception(e)
                path = None
                pass

        rgx = _rgx and _rgx.match(line) or None

        # Note: eval
        try:
            result =  eval(codeobj, globals(), locals()) # ...
        except Exception, e:
            e.cmd = cmd
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
        columns = xrange(len(line))
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

# TODO FIXME
import operator
def sort_by(sortstr, nl, reverse=False):
    columns = get_list_from_str(sortstr)
    log.debug("columns: %r" % columns)

    get_columns = operator.itemgetter(*columns)

    get_columns = itemgetter_default(columns, default=None)

    return sorted(nl,
            key=get_columns,
            reverse=reverse)

import csv
import json
import StringIO

class ResultWriter(object):
    OUTPUT_FILETYPES = {
        'csv': ",",
        'json': True,
        'tsv': "\t",
        'html': True,
        "txt": True,
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

        :param output_filetype: csv | json | tsv
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
        else:
            raise NotImplementedError()
        return (
            writer,
            (kwargs.get('number_lines')
                and writer.write_numbered or writer.write ))

class ResultWriter_txt(ResultWriter):
    filetype = 'txt'
    def write_numbered(self, obj):
        self.write(obj._numbered_str(odelim='\t'))

class ResultWriter_csv(ResultWriter):
    filetype = 'csv'

    def setup(self, *args, **kwargs):
        self.delimiter=kwargs.get('delimiter',
            ResultWriter.OUTPUT_FILETYPES.get(self.filetype, ','))
        self._output_csv = csv.writer(self._output,
                quoting=csv.QUOTE_NONNUMERIC,
                delimiter=self.delimiter)
                #doublequote=True)


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
        for attr,col in obj._asdict().iteritems(): # TODO: zip(_fields, ...)
            yield "<td%s>" % (attr is not None and (' class="%s"' % attr) or '')
            if hasattr(col, '__iter__'):
                for value in col:
                    yield u'<span>%s</span>' % value
            else:
                yield u'%s' % col and hasattr(col, 'rstrip') and col.rstrip() or str(col)  #TODO
            yield "</td>"
        yield "</tr>"

    def write(self, obj):
        return self._output.write( u''.join(self._html_row(obj,)) )

    def footer(self):
        self._output.write('</table>\n')

TEST_INPUT="""
Lines
=======
Of a file
---------
With Text

And Without

http://localhost/path/to/file?query#fragment

"""
import tempfile
import os
import StringIO
import unittest
class TestPyline(unittest.TestCase):

    def setUp(self, *args):
        (self._test_file_fd, self.TEST_FILE) = tempfile.mkstemp(text=True)
        fd = self._test_file_fd
        os.write(fd, TEST_INPUT)
        os.write(fd, self.TEST_FILE)

        self.log = logging.getLogger(self.__class__.__name__)
        self.log.setLevel(logging.DEBUG)

    def tearDown(self):
        os.close(self._test_file_fd)
        os.remove(self.TEST_FILE)

    def test_pyline__function(self):
        PYLINE_TESTS=(
            {"cmd": "line" },
            {"cmd": "words"},
        )
        _test_output = sys.stdout
        for test in PYLINE_TESTS:
            for line in pyline(StringIO.StringIO(TEST_INPUT), **test):
                print(line, file=_test_output)

    def test_pyline_cmdline(self):
        CMDLINE_TESTS=(
            tuple(),
            ("line",),
            ("l",),
            ("l","-n"),
            ("l and l[:5]",),
            ("words",),
            ("w",),
            ("w", "-n"),
            ("w", '-O', 'csv'),
            ("w", '-O', 'csv', '-n'),

            ("w", '-O', 'csv', '-s', '0'),
            ("w", '-O', 'csv', '-s', '1'),
            ("w", '-O', 'csv', '-s', '1,2'),
            ("w", '-O', 'csv', '-S', '1'),
            ("w", '-O', 'csv', '-S', '1', '-n'),

            ("w", '-O', 'json'),
            ("w", '-O', 'json', '-n'),

            ("w", '-O', 'tsv'),

            ("w", '-O', 'html'),

            ("len(words) > 2 and words",),

            ('-r', '(.*with.*)'),
            ('-r', '(.*with.*)',            '-R', 'i'),
            ('-r', '(?P<line>.*with.*)'),
            ('-r', '(?P<line>.*with.*)',    '-O', 'json'),
            ('-r', '(.*with.*)', 'rgx and {"n":i, "match": rgx.groups()[0]}',
                                            '-O', 'json'),
            ("-r", '(.*with.*)', '_rgx.findall(line)',
                                            '-O', 'json'),

            ('-m','os','os.path.isfile(line) and (os.stat(line).st_size, line)'),
            #
            ("-p", "p and p.isfile() and (p.size, p, p.stat())")
        )

        TEST_ARGS = ('-f', self.TEST_FILE)

        for argset in CMDLINE_TESTS:
            _args = TEST_ARGS + argset
            self.log.debug("main%s" % str(_args))
            try:

                main(*_args)
            except Exception, e:
                self.log.error("cmd: %s" % repr(_args))
                self.log.exception(e)
                raise


def main(*args):
    import optparse
    import logging
    import sys

    prs = optparse.OptionParser(usage="./%prog: [options] <command>",
            epilog=EPILOG)

    prs.add_option('-f',
                    dest='file',
                    action='store',
                    default='-',
                    help="Input file (default: '-' for stdin)")
    prs.add_option('-o','--output-file',
                    dest='output',
                    action='store',
                    default='-',
                    help="Output file (default: '-' for stdout)")

    prs.add_option('-O','--output-filetype',
                    dest='output_filetype',
                    action='store',
                    default='txt',
                    help="Output filetype <txt|csv|tsv|json> (default: txt)")

    prs.add_option('-F','--input-delim',
                    dest='idelim',
                    action='store',
                    default=None,
                    help=('Strings input field delimiter to split line'
                         ' into ``words`` by'
                         ' (default: None (whitespace)``'))
    prs.add_option('-d','--output-delim',
                    dest='odelim',
                    default="\t",
                    help=('String output delimiter for lists and tuples'
                          ' (default: \t (tab))``'))

    prs.add_option('-m','--modules',
                    dest='modules',
                    action='append',
                    default=[],
                    help='Module name to import (default: []) see -p and -r')
    prs.add_option('-p','--path-tools',
                    dest='path_tools',
                    action='store_true',
                    help='Create path objects from each ``line``')
    prs.add_option('-r','--regex',
                    dest='regex',
                    action='store',
                    help='Regex to compile and match as ``rgx``')
    prs.add_option('-R','--regex-options',
                    dest='regex_options',
                    action='store',
                    default='im',
                    help='Regex options: I L M S X U (see ``pydoc re``)')

    prs.add_option("-s","--sort-asc",
                    dest="sort_asc",
                    action='store',
                    help="Sort Ascending by field number")
    prs.add_option("-S","--sort-desc",
                    dest="sort_desc",
                    action='store',
                    help="Reverse the sort order")

    prs.add_option('-n', '--number-lines',
                    dest='number_lines',
                    action='store_true',
                    help='Print line numbers of matches')

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

    if opts.file is '-':
        _input_file = sys.stdin
    else:
        _input_file = open(opts.file, 'r')

    if opts.output is '-':
        opts._output = sys.stdout
    else:
        opts._output = open(opts.output, 'w')
    _output = opts._output

    cmd = ' '.join(args)
    if not cmd.strip():
        if opts.regex:
            if opts.output_filetype=='json' and '<' in opts.regex:
                cmd = 'rgx and rgx.groupdict()'
            else:
                cmd = 'rgx and rgx.groups()'
        else:
            cmd = 'line'

    cmd = cmd.strip()
    opts.cmd = cmd

    if opts.verbose:
        logging.debug(opts.__dict__)

    # FIXME
    sortfunc = None
    if opts.sort_asc:
        logging.debug("sort_asc: %r" % opts.sort_asc)
        if sortfunc is None:
            sortfunc = (
                lambda _output:
                    sort_by(opts.sort_asc,
                            _output,
                            reverse=False))
        else:
            sortfunc = (
                lambda _output:
                    sort_by(opts.sort_asc, sortfunc(_output)))
    if opts.sort_desc:
        logging.debug("sort_desc: %r" % opts.sort_desc)
        if sortfunc is None:
            sortfunc = (
                lambda _output:
                    sort_by(opts.sort_desc,
                            _output,
                            reverse=True))
        else:
            sortfunc = (
                lambda _output:
                    sort_by(opts.sort_desc,
                            sortfunc(_output)))


    writer, output_func = ResultWriter.get_writer(
                    _output,
                    filetype=opts.output_filetype,
                    number_lines=opts.number_lines,
                    attrs=PylineResult._fields)
    writer.header()

    if not sortfunc:
        for result in pyline(_input_file, **opts.__dict__):
            if not result.result:
                continue # TODO
            output_func(result)
    else:
        results = []
        for result in pyline(_input_file, **opts.__dict__):
            if not result.result:
                continue
            results.append(result)
        for result in sortfunc(results):
            output_func(result)

    writer.footer()

    if opts.output is not '-':
        opts._output.close()

if __name__ == "__main__":
    main()

