#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""

**pyline**

Pyline is a UNIX command-line tool for
line-based processing in Python
with regex and output transform features
similar to grep, sed, and awk.

Features:

* Python ``str.split()`` by a delimiter (``-F``)
* Python ``shlex.split(posix=True)`` with POSIX quote parsing (``--shlex``)
* Python Regex (``-r``, ``--regex``, ``-R``, ``--regex-options``)
* Output as ``txt``, ``csv``, ``tsv``, ``json``, ``html``
  (``-O|--output-format=csv``)
* Output as Markdown/ReStructuredText ``checkbox`` lists
  (``-O|--output-format=checkbox``)
* (Lazy) sorting (``-s``, ``--sort-asc``, ``-S``, ``--sort-desc``) # XXX TODO
* Path.py or pathlib objects from each line (``-p``)
* ``namedtuple``s, ``yield``ing generators

**Usage**

Shell::

    pyline.py --help

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
    cat ~/.bashrc | pyline.py -n -r '^#(.*)' \
        'rgx and (rgx.group(0), rgx.group(1))'

    # Call a module function
    cat > pf.py << EOF
    def backwards(line):
        return line[::-1]
    EOF
    echo "wrd.nu" | pyline -m pf 'pf.backwards(l)'

.. note:: This file should only import from the standard library
    so that it is vendorable by copying one file::

    .. code:: bash

        # pip install pyline
        pyline      # -> pyline:main entry_point

        # vendored as pyline.py
        cp ./pyline.py ${__DOTFILES}/scripts/pyline.py
        pyline.py   # -> ${__DOTFILES}/scripts/pyline.py

"""

__version__ = '0.3.20'

import csv
import collections
import codecs
import json
import logging
import textwrap
import pprint
import re
import shlex as _shlex
import sys


from collections import namedtuple
from functools import partial

IS_PYTHON2 = sys.version_info.major == 2

if sys.version_info.major >= 3:
    xrange = range
    basestring = str
    unicode = str
    from html import escape as html_escape

    def itervalues(x):
        return x.values()

    def iteritems(x):
        return x.items()
else:
    from cgi import escape as html_escape

    def itervalues(x):
        return x.itervalues()

    def iteritems(x):
        return x.iteritems()

EPILOG = __doc__  # """  """

REGEX_DOC = r"""
I  IGNORECASE  Perform case-insensitive matching.
L  LOCALE      Make \w, \W, \b, \B, dependent on the current locale.
M  MULTILINE   "^" matches the beginning of lines (after a newline)
                as well as the string.
                "$" matches the end of lines (before a newline) as well
                as the end of the string.
S  DOTALL      "." matches any character at all, including the newline.
X  VERBOSE     Ignore whitespace and comments for nicer looking RE's.
U  UNICODE     Make \w, \W, \b, \B, dependent on the Unicode locale."""
REGEX_OPTIONS = dict(
    (line[0],
        (line[1:14].strip(), line[15:]))
    for line in REGEX_DOC.split('\n') if line)

STANDARD_REGEXES = {}

DEFAULT_LOGGER='pyline'
log = logging.getLogger(DEFAULT_LOGGER)
hdlr = logging.StreamHandler(stream=sys.stderr)
# fmt = logging.Formatter(logging.BASIC_FORMAT)
fmt = logging.Formatter('%(levelname)-5s %(name)s:%(lineno)5s: %(message)s')
hdlr.setFormatter(fmt)
log.addHandler(hdlr)
# log.setLevel(logging.DEBUG)
# log.setLevel(logging.INFO)
log.setLevel(logging.WARN)


Result = namedtuple('Result', ('n', 'result')) # , 'uri', 'meta'))


class PylineResult(Result):

    def __str__(self):
        result = self.result
        odelim = u'\t'  # TODO
        odelim = unicode(odelim)

        if result is None or result is False:
            return result

        elif hasattr(self.result, 'itervalues') or hasattr(self.result, 'values'):
            result = odelim.join(unicode(s) for s in itervalues(self.result))

        elif isinstance(self.result, (basestring, unicode)):
            if result[-1] == '\n':   # TODO: remove_one_trailing_cr
                result = result[:-1]

        elif hasattr(self.result, '__iter__'):
            result = odelim.join(unicode(s) for s in result)

        elif hasattr(self.result, 'rstrip'):
            if result[-1] == '\n':
                result = result[:-1]

        return result

    def __unicode__(self):
        return self.__str__()

    def _numbered(self, **opts):
        yield self.n
        if self.result is None or self.result is False:
            yield self.result

        elif hasattr(self.result, 'itervalues') or hasattr(self.result, 'values'):
            for col in itervalues(self.result):
                yield col

        elif hasattr(self.result, 'rstrip'):
            if self.result[-1] == '\n':   # TODO: remove_one_trailing_cr
                yield self.result[:-1]
            else:
                yield self.result

        elif hasattr(self.result, '__iter__'):
            for col in self.result:
                yield col

    def _numbered_str(self, odelim):
        record = self._numbered()
        return ' %4d%s%s' % (
            next(record),
            odelim,
            unicode(odelim).join(str(x) for x in record))

def debug(*args, **kwargs):
    log_(*args, **kwargs)
    raise Exception(args, kwargs)

def log_(*args, **kwargs):
    """log through to stderr and return what is passed in

    .. code::

        log(value) -> value
        log(value, **kwargs) -> (value, kwargs)
        log(value1, value2, **kwargs) -> ([value1, value2], kwargs)
        log(value1, value2) -> [value1, value2]
    """
    log.debug((args, kwargs))
    #print((args, kwargs), file=sys.stderr)
    if kwargs is None:
        if len(args) == 1:
            return args[0]
        return args
    else:
        if args:
            if len(args) == 1:
                return args[0], kwargs
            return args, kwargs
        else:
            return kwargs

def pyline(iterable,
           cmd=None,
           codefunc=None,
           col_map=None,
           uri=None,
           meta=None,
           modules=[],
           regex=None,
           regex_options=None,
           path_tools_pathpy=False,
           path_tools_pathlib=False,
           shlex=None,
           idelim=None,
           idelim_split_max=-1,
           odelim="\t",
           **kwargs):
    """
    Process an iterable of lines

    Args:
        iterable (iterable): iterable of strings (e.g. sys.stdin or a file)
        cmd (str): python command string
        codefunc (callable): alternative to cmd ``codefunc(locals())``
        col_map (None or OrderedDict): a column-key to type-callable mapping
        uri (None or str): uri of the current file (for PylineResult objs)
        meta (None or str): uri of the current file (for PylineResult objs)
        modules ([str]): list of modules to import
        regex (str): regex pattern to match (with groups)
        regex_options (TODO): Regex options: I L M S X U (see ``pydoc re``)
        path_tools (bool): try to cast each line to a file
        idelim (str): input delimiter
        idelim_split_max (int): str.split(idelim, idelim_split_max)
        odelim (str): output delimiter

    Returns:
        iterable of PylineResult namedtuples
    """

    for _importset in modules:
        for _import in _importset.split(','):
            locals()[_import] = __import__(_import.strip())

    _rgx = None
    if regex:
        _regexstr = regex
        if bool(regex_options):
            _regexstr = ("(?%s)" % (regex_options)) + _regexstr
        #    _regexstr = r"""(?%s)%s""" % (
        #        ''.join(
        #            l.lower() for l in regex_options
        #                if l.lower() in REGEX_OPTIONS),
        #        _regexstr)
        log.info(('_rgx', _regexstr))
        _rgx = re.compile(_regexstr)

    Path = str
    if path_tools_pathpy:
        import path as pathpy
        Path = pathpy.Path
    if path_tools_pathlib:
        import pathlib
        Path = pathlib.Path

    if cmd is None and codefunc is None:
        if regex:
            cmd = "rgx and rgx.groups()"
            # cmd = "rgx and rgx.groupdict()"
        else:
            cmd = "line"
        if path_tools_pathpy or path_tools_pathlib:
            cmd = "p"

    codeobj = None
    if cmd:
        try:
            log.info(("cmd", cmd))
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

    def k(obj, keys=(':',)):
        return [obj.__getslice__(k) for k in keys]

    def j(args):
        return odelim.join(str(_value) for _value in args)
    # from itertools import imap, repeat
    # j = lambda args: imap(str, izip_longest(args, repeat(odelim)))

    i_last = None
    if cmd and 'i_last' in cmd:
        # Consume the whole file into a list (to count lines)
        iterable = list(iterable)
        i_last = len(iterable)

    pp = pprint.pformat

    if shlex:
        def splitfunc(line):
            return _shlex.split(line, posix=True)
    else:
        def splitfunc(obj):
            if hasattr(obj, 'strip'):
                return obj.strip().split(idelim, idelim_split_max)
            else:
                return obj

    endl = '\n'

    global_ctxt = globals()
    for i, obj in enumerate(iterable):
        l = line = o = obj
        w = words = [_w for _w in splitfunc(line)]
        rgx = _rgx and _rgx.match(line) or None

        p = path = None
        if path_tools_pathpy or path_tools_pathlib:
            try:
                _line = (line[:-1*len(endl)]
                         if line.endswith(endl) else line)
                if _line:
                    p = path = Path(_line) or None
                else:
                    p = None
            except Exception as e:
                log.exception(e)
                pass
        try:
            if codeobj:
                # Note: eval
                result = eval(codeobj, global_ctxt, locals())  # ...
            elif codefunc:
                ctxt = global_ctxt.copy()
                ctxt.update(locals())
                result = codefunc(ctxt)
        except Exception as e:
            e.cmd = cmd
            log.exception(repr(cmd))
            log.exception(e)
            raise
        yield PylineResult(n=i, result=result)  # , uri=uri, meta=meta)


class OrderedDict_(collections.OrderedDict):
    def keys(self):
        return list(collections.OrderedDict.keys(self))

    def values(self):
        return list(collections.OrderedDict.values(self))


# from collections import MutableMapping

class PylineDatasource(object):
    def __init__(self, **kwargs):
        self.data = OrderedDict_()
        self.data['uri'] = kwargs.get('uri')
        self.data['meta'] = kwargs.get('meta', OrderedDict_)
        self.data['resultsets'] = kwargs.get('resultsets', [])
        results = kwargs.get('results')
        if results is not None:
            self.add_resultset(results)

    def add_resultset(self, results):
        if results is not None:
            self.data['resultsets'].append(results)


typestr_func_map = collections.OrderedDict((
    ('b', bool),
    ('bool', bool),
    ('xsd:bool', bool),

    ('bin', bin),
    ('h', hex),
    ('hex', hex),

    ('i', int),
    ('int', int),
    ('xsd:integer', int),

    ('f', float),
    ('float', float),
    ('xsd:float', float),

    ('s', str),
    ('str', str),
    ('xsd:string', str),

    ('u', unicode),
    ('unicode', unicode),
))

COLSPECSTRRGX = re.compile('''::''')

def parse_colspecstr(colspecstr, default=unicode):
    """

    Args:
        colspecstr (str): e.g. "0,1,2,3" or "0,1,4::int"

    Keyword Arguments:
        default (callable): type casting callable

    Yields:
        tuple: (colkey, coltypefunc)

    .. code::

        ' '
        0
        0,1,2
        2, 1, 0
        2:int
        0:str, 1:int, 2:int
        0:int, 1:int, 2:int  # raises
        0, 1, 2:int
        2::int, 2::xsd:integer  #
        #0:"xsd:string", 2:xsd:integer #
        attr:"xsd:string", attr2:"xsd:integer" #

        # - [ ] ENH: [rdflib] RDFa default context
        # - [ ] ENH: shlex quote parsing after the split

    """
    if not colspecstr or not colspecstr.strip():
        return
    # parse column::datatype mappings
    for n, colspecstr_col_n in enumerate(colspecstr.split(',')):
        colkeystr = None  # '0'
        coltypefunc = default
        # coltypestr = colspecstr_col_n.strip()
        colspecstrrgx_split = COLSPECSTRRGX.split(
            colspecstr_col_n,
            maxsplit=1)
        if len(colspecstrrgx_split) == 2:
            colkeystr, coltypestr = colspecstrrgx_split
        elif len(colspecstrrgx_split) == 1:
            colkeystr = colspecstrrgx_split[0]
        else:
            raise ValueError(colspecstrrgx_split)

        colkey = parse_field(colkeystr).strip()
        coltypestr = parse_field(coltypestr).strip()
        coltypefunc = typestr_func_map.get(coltypestr, default)
        # raise Exception((colkey, coltypestr, coltypefunc))
        yield (colkey, coltypefunc)

SHLEXRGX = re.compile(r'''['"]+''') #

def parse_field(colspecfieldstr, shlex=None):
    """

    Args:
        str_ (basestring):
        shlex (None or bool): default None: shlex if ' or ", if True shlex
    """
    if shlex is None:
        matchobj = SHLEXRGX.match(colspecfieldstr)
        shlex = bool(matchobj)
    retval = None
    if shlex:
        shlexoutput = _shlex.split(colspecfieldstr, comments=False, posix=True)
        if shlexoutput:
            shlexword1 = shlexoutput[0]
            retval =  shlexword1
        else:
            raise ValueError(colspecfieldstr)
    else:
        retval = colspecfieldstr
    import pdb; pdb.set_trace()
    return retval


def build_column_map(colspecstr):
    """
    Args:
        colspecstr (str or OrderedDict): a colspecstrstr column-key to type-callable mapping
    Returns:
        OrderedDict: (colkey, type_func) mappings "column_map" # TODO
    """
    #
    if not colspecstr:
        return collections.OrderedDict()
    if hasattr(colspecstr, 'items'):
        return colspecstr
    return collections.OrderedDict(
        parse_colspecstr(colspecstr, default=unicode)
    )


def get_list_from_str(str_, idelim=',', typefunc=int):
    """
    Split a string of things separated by commas & cast/wrap with typefunc

    Args:
        str_ (str (.strip, .split)): string to split
        idelim (str): string to split by ("input delimiter")
        typefunc (callable): wrap results with this callable
    Returns:
        list: list of Type_func(
    """
    return [typefunc(x.strip()) for x in str_.split(idelim)]


def sort_by(iterable,
            sortstr=None,
            reverse=False,
            col_map=None,
            default_type=None,
            default_value=None):
    """sort an iterable, cast to ``col_map.get(colkey, default_type)``,
    and default to ``default_value``.

    Args:
        iterable (iterable): iterable of lines/rows
    Kwargs:
        sortstr (None, str): comma separated list of column index (``1,2,3``)
        reverse (bool): (True, Descending), (False, Ascending) default: False
        col_map (None, dict): dict mapping column n to a typefunc
        default_type (None, callable): type callable (default: None)
        default_value (\\*): default N/A value for columns not specified
                            in col_map (default: None)
    Returns:
        list: sorted list of lines/rows
    """
    # raise Exception()
    def keyfunc_iter(obj, sortstr=sortstr, col_map=col_map):
        """Parse and yield column values according to ``sortstr`` and ``col_map``

        Args:
            obj (object): obj to sort (as from ``sorted(keyfunc=thisfunc)``)
            sortstr (str): sort string of comma-separated columns
            col_map (None, dict): dict mapping column n to a typefunc (default: None)
        Yields:
            object: typecasted column value
        """
        if sortstr:
            column_sequence = get_list_from_str(sortstr, typefunc=int)
        else:
            column_sequence = xrange(len(obj.result))
        log.debug(('column_sequence', column_sequence))
        if col_map is None:
            col_map = {}
        for n in column_sequence:
            type_func = col_map.get(str(n), default_type)
            retval = default_value
            if n < len(obj.result):
                colvalue = obj.result[n]
                if type_func:
                    try:
                        retval = type_func(colvalue)
                    except ValueError as e:
                        e.msg += "\n" + repr((type_func, colvalue, e,))
                        raise
                else:
                    retval = colvalue
            else:
                retval = default_value
            yield retval

    def keyfunc(obj, sortstr=sortstr, col_map=col_map):
        """key function (e.g. for ``sorted(key=keyfunc)``)

        Args:
            obj (PylineResult): ``obj.result = ['col1', 'col2', 'coln']``
        Returns:
            tuple: (col2, col0, col1)
        """
        keyvalue = tuple(x if x is not None else "" for x in keyfunc_iter(obj, sortstr, col_map))  # TODO: default_value and/or approximate python 2 sort
        errdata = [
            (('keyvalue', keyvalue),
              ('sortstr', sortstr))]
        log.debug((errdata,))
        return keyvalue

    try:
        sorted_values = sorted(iterable,
                    key=keyfunc,
                    reverse=reverse)
    except TypeError:
        _iterable = list(iterable)
        log.error(dict(
            iterable=_iterable,
            keyfunc=keyfunc,
            reverse=reverse,
            keyfunc_applied=[keyfunc(x) for x in _iterable]
        ))
        raise
    return sorted_values


def str2boolintorfloat(str_):
    """
    Try to cast a string as a ``bool``, ``float``, ``int``,
    or ``str_.__class__``.

    Args:
        str_ (basestring): string to try and cast
    Returns:
        object: casted ``{boot, float, int, or str_.__class__}``
    """
    match = re.match(r'([\d\.]+)', str_)
    type_ = None
    if not match:
        type_ = str_.__class__
        value = str_
        value_lower = value.strip().lower()
        if value_lower == 'true':
            type_ = bool
            value = True
        elif value_lower == 'false':
            type_ = bool
            value = False
        return value
    else:
        try:
            numstr = match.group(1)
            if '.' in numstr:
                type_ = float
                value = type_(numstr)
            else:
                type_ = int
                value = type_(numstr)
        except (ValueError, NameError, IndexError) as e:
            value = str_
            log.exception((e, (type_, value)))
    return value


def parse_formatstring(str_):
    """
    Parse a format string like
    ``format:+isTrue,-isFalse,key0=value,key1=1.1,keyTrue=true``

    Args:
        str_ (basestring): _format

    Returns:
        OrderedDict_: {key: {True|False|float|int|str}}

        .. code:: python

            {
                fmtkey:   _formatstr,
                argkey: argstr,

                'key0':   'value0',
                'key1':   1,
                'key2':   True,
                'key2.1': 2.1,
            }

    Inspired by rdflib ``rdfpipe -h | grep 'FORMAT:'``::

        FORMAT:(+)KW1,-KW2,KW3=VALUE
        format
        format:opt1
        format:opt2=True

    """
    fmtkey = '_output_format'
    argkey = '_output_format_args'
    strsplit = str_.split(':', 1)
    if len(strsplit) == 1:
        _format = strsplit[0]
        _format = _format if _format else None
        return OrderedDict_((
            (fmtkey, _format),
            (argkey, None),
        ))
    else:
        _format, argstr = strsplit
        _format = _format if _format else None
        opts = OrderedDict_()
        opts[fmtkey] = _format
        opts[argkey] = argstr if argstr else None
        _args = [x.strip() for x in argstr.split(',')]
        for arg in _args:
            if not arg:
                continue
            key, value = None, None
            if '=' in arg:
                key, value = [x.strip() for x in arg.split('=', 1)]
            else:
                if arg[0] == '-':
                    key, value = arg[1:], False
                elif arg[0] == '+':
                    key, value = arg[1:], True
                else:
                    key, value = arg, True
            if not isinstance(value, (bool, float, int)):
                opts[key] = str2boolintorfloat(value)
            else:
                opts[key] = value
    return opts


class ResultWriter(object):
    OUTPUT_FILETYPES = {
        'csv': ",",
        'json': True,
        'tsv': "\t",
        'html': True,
        'jinja': True,
        "txt": True,
        "checkbox": True,
        "chk": True
    }
    output_format = None

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
        print(unicode(obj), file=self._output)

    def write_numbered(self, obj):
        print(obj, file=self._output)

    def footer(self, *args, **kwargs):
        pass

    @classmethod
    def is_valid_output_format(cls, _output_formatstr):
        opts = parse_formatstring(_output_formatstr)
        _output_format = opts.get('_output_format')
        if _output_format in cls.OUTPUT_FILETYPES:
            return _output_format
        return False

    @classmethod
    def get_writer(cls, _output,
                   output_format="csv",
                   **kwargs):
        """get writer object for _output with the specified output_format

        Args:
            _output (file-like .write): output to write to
        Kwargs:
            output_format (str): a formatstring to be parsed by
                            :py:func:`parse_formatstring`
            Filetypes::

                txt | csv | tsv | json | html | jinja | checkbox

        Returns:
            ResultWriter: a configured ResultWriter subclass instance
        """
        opts = parse_formatstring(output_format.strip())
        _output_format = opts.pop('_output_format', None)
        opts.update(kwargs)

        if not cls.is_valid_output_format(_output_format):
            raise ValueError("_output_format: %r" % _output_format)

        writer = None
        if _output_format == "txt":
            writer = ResultWriter_txt(_output)
        elif _output_format == "csv":
            writer = ResultWriter_csv(_output, **opts)
        elif _output_format == "tsv":
            writer = ResultWriter_csv(_output, delimiter='\t', **opts)
        elif _output_format == "json":
            writer = ResultWriter_json(_output)
        elif _output_format == "html":
            writer = ResultWriter_html(_output, **opts)
        elif _output_format.startswith("jinja"):
            writer = ResultWriter_jinja(_output, **opts)
        elif _output_format in ("checkbox", "chk"):
            writer = ResultWriter_checkbox(_output, **opts)
        else:
            raise ValueError("_output_format: %r" % _output_format)

        output_func = None
        if kwargs.get('number_lines'):
            output_func = writer.write_numbered
        else:
            output_func = writer.write
        writer.output_func = output_func
        return writer


class ResultWriter_txt(ResultWriter):
    output_format = 'txt'

    def write_numbered(self, obj):
        self.write(obj._numbered_str(odelim='\t'))


class ResultWriter_csv(ResultWriter):
    output_format = 'csv'

    def setup(self, *args, **kwargs):
        self.delimiter = kwargs.get(
            'delimiter',
            ResultWriter.OUTPUT_FILETYPES.get(
                self.output_format,
                ','))
        self._output_csv = csv.writer(self._output,
                                      quoting=csv.QUOTE_NONNUMERIC,
                                      delimiter=self.delimiter)
        #                             doublequote=True)

    def header(self, *args, **kwargs):
        attrs = kwargs.get('attrs')
        if attrs is not None:
            self._output_csv.writerow(attrs)

    def write(self, obj):
        self._output_csv.writerow(obj.result)

    def write_numbered(self, obj):
        self._output_csv.writerow(tuple(obj._numbered()))


class ResultWriter_json(ResultWriter):
    output_format = 'json'

    def write(self, obj):
        print(
            json.dumps(
                obj._asdict(),
                indent=2),
            end=',\n',
            file=self._output)

    write_numbered = write


class ResultWriter_html(ResultWriter):
    output_format = 'html'
    escape_func = staticmethod(html_escape)

    def header(self, *args, **kwargs):
        self._output.write("<table>")
        self._output.write("<tr>")
        attrs = kwargs.get('attrs')
        if attrs is not None:
            for col in attrs:
                self._output.write(u"<th>%s</th>" % self.escape_func(col))
        self._output.write("</tr>")

    def _html_row(self, obj):
        yield '\n<tr>'
        for attr, col in iteritems(obj._asdict()):  # TODO: zip(_fields, ...)
            yield "<td%s>" % (
                attr is not None and (' class="%s"' % attr) or '')
            if hasattr(col, '__iter__'):
                for value in col:
                    yield u'<span>%s</span>' % self.escape_func(value)
            else:
                # TODO
                colvalue = (
                    col and hasattr(col, 'rstrip') and col.rstrip()
                    or str(col))
                yield self.escape_func(colvalue)
            yield "</td>"
        yield "</tr>"

    def write(self, obj):
        return self._output.write(u''.join(self._html_row(obj,)))

    def footer(self):
        self._output.write('</table>\n')

class ResultWriter_jinja(ResultWriter):
    output_format = 'jinja'
    escape_func = staticmethod(html_escape)

    def setup(self, *args, **kwargs):
        log.debug(('args', args))
        log.debug(('kwargs', kwargs))
        import jinja2, os
        self.escape_func = jinja2.escape
        templatepath = kwargs.get('template', kwargs.get('tmpl'))
        if templatepath is None:
            raise ValueError(
                "Specify at least a template= like "
                "'jinja:+autoescape,template=./template.jinja2'")
        self.templatepath = os.path.dirname(templatepath)
        self.template = os.path.basename(templatepath)
        self.loader = jinja2.FileSystemLoader(self.templatepath)
        envargs = OrderedDict_()
        envargs['autoescape'] = kwargs.get('autoescape', True)
        # envargs['extensions'] = []
        self.env = jinja2.Environment(**envargs)
        self.tmpl = self.loader.load(self.env, self.template)

    def write(self, obj):
        context = OrderedDict_()
        context['obj'] = obj
        jinja2_output = self.tmpl.render(**context)
        return self._output.write(jinja2_output)

class ResultWriter_checkbox(ResultWriter):
    output_format = 'checkbox'

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
        usage=(
            "%prog [-f<path>] [-o|--output-file=<path>] \n"
            "              [-F|--input-delim='\\t'] \n"
            "              [--max|--max-split=3] \n"
            "              [-d|--output-delimiter='||'] \n"
            "              [-n|--number-lines] \n"
            "              [-m|--modules=<mod2>] \n"
            "              [-p|--pathpy] [--pathlib] \n"
            "              [-r '<rgx>'|--regex='<rgx>'] \n"
            "              '<python_expression>' \n"
        ),
        description=(
            "Pyline is a UNIX command-line tool for line-based processing "
            "in Python with regex and output transform features "
            "similar to grep, sed, and awk."
            ),
        epilog=EPILOG)

    prs.add_option('-f', '--in', '--input-file',
                   dest='file',
                   action='store',
                   default='-',
                   help="Input file  #default: '-' for stdin")

    prs.add_option('-F', '--input-delim',
                   dest='idelim',
                   action='store',
                   default=None,
                   help=('words = line.split(-F)'
                         '  #default: None (whitespace)'))
    prs.add_option('--max', '--input-delim-split-max', '--max-split',
                   dest='idelim_split_max',
                   action='store',
                   default=-1,
                   type=int,
                   help='words = line.split(-F, --max)')
    prs.add_option('--shlex',
                   action='store_true',
                   help='words = shlex.split(line)')

    prs.add_option('-o', '--out', '--output-file',
                   dest='output',
                   action='store',
                   default='-',
                   help="Output file  #default: '-' for stdout")
    prs.add_option('-d', '--output-delim',
                   dest='odelim',
                   default="\t",
                   help='String output delimiter for lists and tuples'
                        '''  #default: '\\t' (tab, chr(9), $'\\t')''')
    prs.add_option('-O', '--output-format', '--output-filetype',
                   dest='_output_format',
                   action='store',
                   default='txt',
                   help=("Output output_format <txt|csv|tsv|json|checkbox|chk|html> "
                         "  #default: txt"))
    prs.add_option('-p', '--pathpy',
                   dest='path_tools_pathpy',
                   action='store_true',
                   help='p = path.Path(line); import path  '
                        ' #pip install path.py')

    prs.add_option('--pathlib',
                   dest='path_tools_pathlib',
                   action='store_true',
                   help=('p = pathlib.Path(line); import pathlib'))

    prs.add_option('-r', '--regex',
                   dest='regex',
                   action='store',
                   help='rgx = re.compile(-r).match(line)')
    prs.add_option('-R', '--regex-options',
                   dest='regex_options',
                   action='store',
                   default='',
                   help='Regex options: I L M S X U (ref: `$ pydoc re`)')

    prs.add_option('--cols',
                   dest='col_mapstr',
                   action='store',
                   help='Optional column mappings (4::int, 0::unicode)')

    prs.add_option("-s", "--sort-asc",
                   dest="sort_asc",
                   action='store',
                   help=("sorted(lines, key=itemgetter(*-s))"))
    prs.add_option("-S", "--sort-desc",
                   dest="sort_desc",
                   action='store',
                   help=("sorted(lines, key=itemgetter(*-S), reverse=True)"))

    prs.add_option('-n', '--number-lines',
                   dest='number_lines',
                   action='store_true',
                   help='Print line numbers of matches')

    prs.add_option('-m', '--modules',
                   dest='modules',
                   action='append',
                   default=[],
                   help='for m in modules: import m  #default: []')

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

    prs.add_option('--version',
                   dest='version',
                   action='store_true',
                   help='Print the version string')

    return prs


def get_sort_function(**kwargs):  # (sort_asc, sort_desc)
    """
    get a sort function from the given opts dict

    Args:
        opts (dict): sort_asc:bool, sort_desc:bool
    """
    sortstr = kwargs.get('sortstr')
    sortfunc = None
    reverse = None
    col_map = kwargs.get('col_map')
    sort_asc = kwargs.get('sort_asc')
    sort_desc = kwargs.get('sort_desc')
    if sort_asc and sort_desc:
        raise ValueError("sort_asc and sort_desc are both specified")
    if sort_asc:
        sortstr = sort_asc
        reverse = False
        log.info((("sort_asc", sortstr), ('reverse', reverse)))
    if sort_desc:
        sortstr = sort_desc
        reverse = True
        log.info((("sort_desc", sortstr), ('reverse', reverse)))
    if sortstr:
        def sortfunc(iterable,
                     sortstr=sortstr,
                     reverse=reverse,
                     col_map=col_map):
            return sort_by(
                iterable,
                sortstr,
                reverse=reverse,
                col_map=col_map)
    else:
        def null_sortfunc(iterable):
            return iterable
        sortfunc = null_sortfunc
    # import pdb; pdb.set_trace()  # XXX BREAKPOINT
    return sortfunc


def main(args=None, iterable=None, output=None, results=None, opts=None):
    """parse args, process iterable, write to output, return a returncode

    ``pyline.main`` function

    Kwargs:
        args (None or list[str]): list of commandline arguments (``--help``)
        iterable (None or iterable[object{str,}]): iterable of objects
        output (object:write): a file-like object with a ``.write`` method
        results (None or object:append): if not None, append results here
        opts (None): if set, these preempt args and argument parsing
    Returns:
        int: nonzero on error

    Raises:
        OptParseError: optparse.parse_args(args) may raise

    .. code::

        import pyline
        pyline.main(['-v', 'l and l[1]'], ['one 1', 'two 2', 'three 3'])
        pyline.main(['-v', 'w and w[1]'], ['one 1', 'two 2', 'three 3'])

    """
    import logging
    import sys

    prs = get_option_parser()

    argv = args = list(args) if args is not None else [] # sys.argv[1:]
    if opts is None:
        (opts, args) = prs.parse_args(args)
    optsdict = None
    if hasattr(opts, '__dict__'):
        optsdict = opts.__dict__
    elif hasattr(opts, 'items'):
        optsdict = opts
    else:
        raise ValueError(opts)
    if not optsdict:
        optsdict = {}
    opts = optsdict

    log = logging.getLogger(DEFAULT_LOGGER)
    # if -q/--quiet is not specified
    if not opts.get('quiet'):
        #logging.basicConfig(
        #)
        log.setLevel(logging.WARN)

        # if -v/--verbose is specified
        if opts.get('verbose'):
            log.setLevel(logging.DEBUG)
    # if -q/--quiet is specified
    else:
        log.setLevel(logging.ERROR)
    log.info(('pyline.version', __version__))
    log.info(('argv', argv))
    log.info(('args', args))

    if opts.get('version'):
        print(__version__)
        return 0, None

    opts['col_map'] = collections.OrderedDict()
    if opts.get('col_mapstr'):
        opts['col_map'] = build_column_map(opts.get('col_mapstr'))

    sortfunc = None
    if opts.get('sort_asc') and opts.get('sort_desc'):
        prs.error("both sort-asc and sort-desc are specified")

    if 'cmd' not in opts:
        cmd = ' '.join(args)
        if not cmd.strip():
            if opts.get('regex'):
                if (opts.get('_output_format') == 'json'
                    and '<' in opts.get('regex')):
                    cmd = 'rgx and rgx.groupdict()'
                else:
                    cmd = 'rgx and rgx.groups()'
            else:
                cmd = 'obj'
        opts['cmd'] = cmd.strip()

    log.info(('cmd', opts['cmd']))
    # opts['attrs'] = PylineResult._fields # XX
    opts['attrs'] = list(opts['col_map'].keys()) if 'col_map' in opts else None

    try:
        if iterable is not None:
            opts['_file'] = iterable
        else:
            if opts.get('file') == '-':
                # opts._file = sys.stdin
                if IS_PYTHON2:
                    opts['_file'] = codecs.getreader('utf8')(sys.stdin)
                else:
                    opts['_file'] = sys.stdin
            else:
                if IS_PYTHON2:
                    opts['_file'] = codecs.open(opts['file'], 'r', encoding='utf8')
                else:
                    opts['_file'] = open(opts['file'], 'r', encoding='utf8')

        if output is not None:
            opts['_output'] = output
        else:
            if opts.get('output') == '-':
                # opts._output = sys.stdout
                if IS_PYTHON2:
                    opts['_output'] = codecs.getwriter('utf8')(sys.stdout)
                else:
                    opts['_output'] = sys.stdout
            elif opts.get('output'):
                if IS_PYTHON2:
                    opts['_output'] = codecs.open(opts['output'], 'w', encoding='utf8')
                else:
                    opts['_output'] = open(opts['output'], 'w', encoding='utf8')
            else:
                # opts._output = sys.stdout
                if IS_PYTHON2:
                    opts['_output'] = codecs.getwriter('utf8')(sys.stdout)
                else:
                    opts['_output'] = sys.stdout

        if opts.get('_output_format') is None:
            #opts._output_format = DEFAULTS['_output_format']
            #opts['_output_format'] = 'csv'
            opts['_output_format'] = 'json'
            #TODO
        log.info(('_output_format', opts['_output_format']))

        log.info(('opts', opts))

        writer = ResultWriter.get_writer(
            opts['_output'],
            output_format=opts['_output_format'],
            number_lines=opts.get('number_lines'),
            attrs=opts['attrs'])
        writer.header()

        sortfunc = get_sort_function(**opts)
        # if sorting, collect and sort before printing
        if sortfunc:
            _results = []
            for result in pyline(opts['_file'], **opts):
                if not result.result:
                    # skip result if not bool(result.result)
                    continue
                _results.append(result)
            sorted_results = sortfunc(_results)
            if results is not None:
                results.extend(sorted_results)
            # import pdb; pdb.set_trace()  # XXX BREAKPOINT
            for result in sorted_results:
                writer.output_func(result)
        # if not sorting, return a result iterator
        else:
            for result in pyline(opts['_file'], **opts):
                if not result.result:
                    # skip result if not bool(result.result)
                    continue
                writer.output_func(result)
                if results is not None:
                    results.append(result)

        writer.footer()
    finally:
        if (getattr(opts.get('_file', codecs.EncodedFile),
                'fileno', int)() not in (0, 1, 2)):
            opts['_file'].close()

    # opts
    # results
    # sorted_results
    # if passed, results are .append-ed to results
    return 0, results


def main_entrypoint():
    import sys
    retval, _ = main(args=sys.argv[1:])
    sys.exit(retval)


if __name__ == "__main__":
    main_entrypoint()
