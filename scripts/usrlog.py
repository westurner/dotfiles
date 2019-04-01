#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
usrlog.py
===========
usrlog.py is a parser for -usrlog.log files (as written by usrlog.sh)
"""

import codecs
import collections
import functools
import itertools
import logging
import re
import sys

log = logging.getLogger('usrlog')

ISODATETIME_RGX = re.compile(
    '\d\d\d\d\-\d\d\-\d\dT?\d\d:\d\d')

ISODATETIME_LOOSE_RGX = re.compile(
    '[\d\-T: \+Z]+')

TODO_PREFIXES = ('#TODO','#NOTE','#note','#_MSG')

dateutil = None
arrow = None
try:
    import dateutil
    import dateutil.parser
except ImportError:
    try:
        import arrow
    except ImportError:
        import datetime
        pass

if arrow:
    def parse_date(datestr):
        return arrow.get(datestr)
else:
    if dateutil:
        def parse_date(datestr):
            try:
                return dateutil.parser.parse(datestr)
            except ValueError as e:
                log.error(datestr)
                log.exception(e)
                raise
    else:
        import warnings
        warnings.warn("Neither 'dateutil' nor 'arrow' found, "
                      "defaulting to timezone-naieve datetime.strptime "
                      "(pip install arrow dateutil)")

        def parse_date(datestr):
            if not datestr:
                return datestr
            _datestr = datestr.lstrip()[:19]
            #  tzstr = datestr[19:]
            iso8601_strptime = '%Y-%m-%dT%H:%M:%S'
            return datetime.datetime.strptime(_datestr, iso8601_strptime)


def try_parse_datestr(datestr):
    _output = None
    try:
        mobj = ISODATETIME_LOOSE_RGX.match(datestr)
        if mobj:
            _datestr = mobj.group(0)
            _output = parse_date(_datestr)
    except TypeError as e:
        log.exception(e)
        log.exception(datestr)
        raise ValueError(e)
    return _output


class Usrlog(object):
    date_rgxstr = '^#? +(\d\d\d\d-\d\d-\d\dT?\d\d:\d\d:\d\d[-\+\d]+)\t(.*)'
    date_rgx = re.compile(date_rgxstr)

    def __init__(self, path):
        self.conf = collections.OrderedDict()
        self.conf['path'] = os.path.expanduser(path)

    def read_lines_joined(self, fileobj):
        thisline = []
        # chunk lines by rgx instead of (over) newlines
        for l in fileobj:
            mobj = self.date_rgx.match(l)
            if mobj:
                # date = mobj.group(1)
                # print("iso8601date: %r" % date)
                if thisline:
                    yield u''.join(thisline)
                thisline = [l.decode('utf8')]
            else:
                thisline.append(l.decode('utf8'))
        yield u''.join(thisline)

    def read_file_lines_joined(self, **kwargs):
        path = kwargs.get('path', self.conf['path'])
        if path == '-':
            fileobj = codecs.getreader('utf8')(sys.stdin)
            for l in self.read_lines_joined(fileobj):
                yield l
        else:
            with codecs.open(path, 'r') as fileobj:
                for l in self.read_lines_joined(fileobj):
                    yield l

    def tabescape(self, value):
        return value.replace('\t', '\\t')

    #def parse_line_cmds(self, line):
    #    if not line:
    #        return line
    #    mobj = self.date_rgx.match(line)
    #    if not mobj:
    #        return self.tabescape(line)

    #    w = line.split("\t", 8)
    #    # legacy usrlog support
    #    if len(w) > 8:
    #        cmd = u" ".join(w[8:]).rstrip()
    #    elif len(w) > 7:
    #        cmd = u" ".join(w[7:]).rstrip()
    #    elif len(w) > 3:
    #        cmd = u" ".join(w[3:]).rstrip()
    #    else:
    #        cmd = u" ".join(w).rstrip()
    #    return cmd

    def parse_line_to_dict(self, line, halt_on_error=False):  # TODO: lbt
        startswith_comment = line.startswith("# ")
        w = line.split('\t', 9)
        len_w = len(w)
        recordsep_pos = "$$" in w and w.index("$$")
        #print((recordsep_pos, line))
        try:
            if startswith_comment and recordsep_pos:
                _w = w[0:recordsep_pos] + [u"".join(w[recordsep_pos+1:])]
                #log.debug(('w', w))
                #log.debug(('_w', _w))
                w = _w
                if recordsep_pos == 6:
                    result = collections.OrderedDict((
                        ("line", line),
                        ("words", w),
                        ("date", w[0]),
                        ("id", w[1]),
                        ("virtualenv", None),
                        ("path", w[2]),
                        ("histstr", w[3:]),
                        ("histdate", w[3]),
                        ("hostname", w[4]),
                        ("user", w[5]),
                        ("histn", None),  # w[6].lstrip().split(None, 1)[0],    # {int, #NOTE, #TODO, #_MSG}
                        ("cmd", w[6].rstrip()),
                        ))
                elif recordsep_pos == 7:   ## <- latest format (8 fields)
                    if w[3].startswith(TODO_PREFIXES):
                        result = collections.OrderedDict((
                            ("line", line),
                            ("words", w),
                            ("date", w[0]),
                            ("id", w[1]),
                            ("virtualenv", None),
                            ("path", w[2]),
                            ("histstr", w[4:]),  # TODO XXX
                            ("histdate", w[4]),
                            ("hostname", w[5]),
                            ("user", w[6]),
                            ("histn", None), # TODO   # int or "#note"
                            ("cmd", w[7].rstrip()),
                            #  u"".join(w[7]).rstrip())), # TODO XXX ^
                            ))
                    else:
                        result = collections.OrderedDict((
                            ("line", line),
                            ("words", w),
                            ("date", w[0]),
                            ("id", w[1]),
                            ("virtualenv", w[2]),
                            ("path", w[3]),
                            ("histstr", w[4:]),
                            ("histdate", w[4]),
                            ("hostname", w[5]),
                            ("user", w[6]),
                            ("histn", None), # TODO   # int or "#note"
                            ("cmd", w[7].rstrip()),
                            ))

                elif recordsep_pos == 8:   ## <- latest format (8 fields)
                    if w[4].startswith(TODO_PREFIXES):
                        result = collections.OrderedDict((
                            ("line", line),
                            ("words", w),
                            ("date", w[0]),
                            ("id", w[1]),
                            ("virtualenv", w[2]),
                            ("path", w[3]),
                            ("histstr", w[5:]),  # TODO XXX
                            ("histdate", w[5]),
                            ("hostname", w[6]),
                            ("user", w[7]),
                            ("histn", w[4]), # TODO   # int or "#note"
                            ("cmd", w[8].rstrip()),
                            ))
                    else:
                        result = collections.OrderedDict((
                            ("line", line),
                            ("words", w),
                            ("date", w[0]),
                            ("id", w[1]),
                            ("virtualenv", w[2]),
                            ("path", w[3]),
                            ("histstr", w[4:]),
                            ("histdate", w[4]),
                            ("hostname", w[5]),
                            ("user", w[6]),
                            ("histn", w[7]), # TODO   # int or "#note"
                            ("cmd", w[8].rstrip()),
                            ))
                        raise Exception(result)
                else:
                    log.error(('unable to parse (recordsep)', (line, w, recordsep_pos)))
                    result = collections.OrderedDict((
                        ("line", line),
                        ("words", w),
                        ("date", None),
                        ("id", None),
                        ("virtualenv", None),
                        ("path", None),
                        ("histstr", None),
                        ("histn", None),    # int or "#note"
                        ("histdate", None),
                        ("hostname", None),
                        ("user", None),
                        ("cmd", line),
                        ))
                    #raise Exception(line, w)
            else:
                if len_w == 1:
                    result = collections.OrderedDict((
                        ("line", line),
                        ("words", w),
                        ("date", None),
                        ("id", None),
                        ("virtualenv", None),
                        ("path", None),
                        ("histstr", None),
                        ("histn", None),    # int or "#note"
                        ("histdate", None),
                        ("hostname", None),
                        ("user", None),
                        ("cmd", line),
                        ))
                elif len_w == 2:
                    if w[1].startswith('#ntid'):
                        result = collections.OrderedDict((
                            ("line", line),
                            ("words", w),
                            ("date", w[0]),
                            ("id", (
                                w[1].lstrip('#ntid')
                                    .lstrip(':').lstrip()),
                            ("path", None),
                            ("histstr", None),
                            ("histn", None),    # int or "#note"
                            ("histdate", None),
                            ("hostname", None),
                            ("user", None),
                            ("cmd", w[1]),
                            )))
                    else:
                        result = collections.OrderedDict((
                            ("line", line),
                            ("words", w),
                            ("date", w[0]),
                            ("id", None),
                            ("path", None),
                            ("histstr", w[1]),
                            ("histn", None),    # int or "#note"
                            ("histdate", None),
                            ("hostname", None),
                            ("user", None),
                            ("cmd", w[1]),
                            ))
                elif len_w == 3:  # legacy usrlog support
                    result = collections.OrderedDict((
                        ("line", line),
                        ("words", w),
                        ("date", w[0]),
                        ("id", w[1]),
                        ("virtualenv", None),
                        ("path", None),
                        ("histstr", None),
                        ("histn", None),    # int or "#note"
                        ("histdate", None),
                        ("hostname", None),
                        ("user", None),
                        ("cmd", w[2]),
                        ))
                elif len_w == 4:
                    #if w[3].startswith(('#ntid', '#stid')):
                    result = collections.OrderedDict((
                        ("line", line),
                        ("words", w),
                        ("date", w[0]),
                        ("id", w[1]),
                        ("virtualenv", None),
                        ("path", w[2]),
                        ("histstr", w[3]),
                        ("histn", None),    # int or "#note"
                        ("histdate", None),
                        ("hostname", None),
                        ("user", None),
                        ("cmd", w[3]),
                        ))
                elif len_w == 5:
                    #if w[4].startswith(('#ntid', '#stid')):
                    result = collections.OrderedDict((
                        ("line", line),
                        ("words", w),
                        ("date", w[0]),
                        ("id", w[1]),
                        ("virtualenv", w[2]),
                        ("path", w[3]),
                        ("histstr", w[4]),
                        ("histn", None),    # int or "#note"
                        ("histdate", None),
                        ("hostname", None),
                        ("user", None),
                        ("cmd", w[4]),
                        ))
                else:
                    log.error(('unable to parse (no recordsep, len=%s)' % len_w, (line, w, recordsep_pos)))
                    result = collections.OrderedDict((
                        ("line", line),
                        ("words", w),
                        ("date", None),
                        ("id", None),
                        ("virtualenv", None),
                        ("path", None),
                        ("histstr", None),
                        ("histn", None),    # int or "#note"
                        ("histdate", None),
                        ("hostname", None),
                        ("user", None),
                        ("cmd", line),
                        ))
        except IndexError as e:
            log.error(line)
            log.error(w)
            log.exception(e)
            raise

        _date = result.get('date')
        if _date:
            if _date.startswith('# '):
                result['date'] = _date = _date[2:]

        _cmd = result['cmd']
        _histn = result.get('histn')
        if not _cmd:
            if _histn:
                if _histn[:5] in ('#ntid', '#TODO'):
                    result['cmd'] = result['histn'].rstrip()
                    result['histn'] = None

        _date = result['date']
        if _date:
            date = None
            try:
                result['date'] = date = try_parse_datestr(_date)
            except ValueError as e:
                log.error("%r, %r", e, _date)
                if halt_on_error:
                    raise

        _histdate = result['histdate']
        if _histdate:
            result['histdate'] = _histdate = try_parse_datestr(_histdate)
            try:
                if date and _histdate:
                    diff = date - _histdate
                    # if diff.seconds > 0:
                    #    raise Exception(diff, date, _histdate)
                    diffstr = str(diff)
                    result['elapsed'] = diffstr
            except TypeError as e:
                log.error("%r, %r", e, _date, _histdate)
                if halt_on_error:
                    raise
            finally:
                result.setdefault('elapsed', None)
        else:
            result.setdefault('elapsed', None)
            # "%r %s" % (diff, diffstr)  # TODO XXX

        _date = result['date']
        if _date:
            if hasattr(_date, 'isoformat'):
                result['date'] = unicode(_date.isoformat())
            else:
                raise Exception(_date, try_parse_datestr(_date))

        if _histdate and hasattr(_histdate, 'isoformat'):
            result['histdate'] = unicode(_histdate.isoformat())

        return result

    def read_file_lines_as_dict(self, **kwargs):
        for l in self.read_file_lines_joined(**kwargs):
            yield self.parse_line_to_dict(
                l,
                halt_on_error=kwargs.get('halt_on_error'))

    cmdstr_rgx_ptrn = 'TODO|FIXME|XXX'
    cmdstr_rgx = re.compile(cmdstr_rgx_ptrn)

    def match_dict__todo(self, obj):
        cmd = obj.get('cmd')
        if cmd in (None, False):
            return False
        assert isinstance(cmd, basestring)
        mobj = self.cmdstr_rgx.match(cmd)
        if not mobj:
            return False
        tag = mobj.groups()[1]
        print("tag: ", tag)
        return tag


def usrlog(path, conf=None):
    """read a -usrlog.log file

    Arguments:
        path (str): path to usrlog

    Keyword Arguments:
        conf (dict): configuration dict

    Returns:
        OrderedDicts of usrlog attributes

    Raises:
        ValueError -- parsing exceptions bubble up if halt_on_error=True
        TypeError  -- parsing exceptions bubble up if halt_on_error=True
    """
    if conf is None:
        conf = {}
    _usrlog = Usrlog(path)
    return _usrlog.read_file_lines_as_dict(
        halt_on_error=conf.get('halt_on_error'))


import os
import unittest


class Test_usrlog(unittest.TestCase):
    conf = collections.OrderedDict([
        ('usrlogpath',
            os.path.join(
                os.path.expanduser('~'),
                '-usrlog.log'))])

    def setUp(self):
        pass

    def test_date_rgx(self):
        IO = [
            ["""# 2015-05-21T14:59:48-0500	#q3qyLhe7X4M	/Users/W/-wrk/-ve27/dotfiles/src/dotfiles	 9845  	2015-05-21T14:55:40-0500	nb-mb1	W	$$	nosetests ./scripts/usrlog.py""",  # NOQA
             True]
        ]
        for i, o in IO:
            print(i)
            output = Usrlog.date_rgx.match(i)
            self.assertEqual(bool(output), o)

    def test_usrlog(self):
        u = Usrlog(self.conf['usrlogpath'])
        for l in u.read_file_lines_joined():
            # log.debug(l)
            self.assertIsInstance(l, basestring)
            self.assertTrue(l.startswith('# ') or l.startswith('2014'))

    def test_usrlog_read_file_lines_as_dict(self):
        u = Usrlog(self.conf['usrlogpath'])
        for obj in u.read_file_lines_as_dict():
            log.debug(obj['cmd'])
            self.assertIsInstance(obj, collections.OrderedDict)
            self.assertTrue(len(obj.keys()))

    def tearDown(self):
        pass


class Conf(object):

    def get(self, key, default=None):
        return getattr(self, key, default)


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

    prs = optparse.OptionParser(
        usage=(
            "%prog : [-u] [-p <path>|-P] [--cmds|--id|--dates|--elapsed|--ve]"))

    prs.add_option('-p', '--path',
                   dest='paths',
                   action='append',
                   default=[],
                   help=(
                        """Path to a -usrlog.log file to read """
                        '''(e.g. "${VIRTUAL_ENV}/-usrlog.log" '''
                        """or '-' for stdin)"""))

    prs.add_option('-P', '--paths-from-stdin',
                   dest='paths__stdin',
                   action='store_true',
                   default=False,
                   help=('Read -usrlog.log paths from stdin'))

    prs.add_option('-u', '-U', '--_USRLOG', '--USRLOG',
                   dest='paths__USRLOG',
                   action='store_true',
                   default=False,
                   help='Read -usrlog.log path from ${_USRLOG}')

    prs.add_option('--cmd', '--cmds',
                   dest='cmds',
                   action='store_true',
                   help='show <cmd>')
    prs.add_option('--id', '--ids', '--session', '--sessions',
                   dest='sessions',
                   action='store_true',
                   help='show [id, cmd]')
    prs.add_option('--date', '--dates',
                   dest='dates',
                   action='store_true',
                   help='show [date, id, cmd]')
    prs.add_option('--elapsed',
                   dest='elapsed',
                   action='store_true',
                   help='show [date, id, cmd, elapsed]')
    prs.add_option('--ve', '--venv', '--venvs', '--virtualenv', '--virtualenvs',
                   dest='venvs',
                   action='store_true',
                   help='include [date,id,virtualenv,cmd]')
    prs.add_option('--cwd', '--pwd', '--cwd-after-cmd', '--pwd-after-cmd',
                   dest='cwdpaths',
                   action='store_true',
                   help='include [date,id,virtualenv,path,cmd]')


    prs.add_option('-c', '--column',
                   dest='columns',
                   action='append',
                   default=[],
                   help='{ date, elapsed, id, virtualenv, path, cmd }')

    prs.add_option('--pyline',
                   dest='pyline',
                   action='store_true',
                   help=(
                       """run --pyline '" commands" + (l[:9] if l else ".")'"""))

    prs.add_option('--todo', '--todos',
                   dest='todo',
                   action='store_true',
                   help='grep for #TODO entries and parse out the #TODO prefix')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)

    argv = list(argv) if argv else sys.argv[1:]

    if '--pyline' in argv:
        argpos = argv.index('--pyline')
        argv, pyline_args = argv[:argpos+1], argv[argpos+1:]
    else:
        pyline_args = None

    (opts, args) = prs.parse_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)
    log.debug('pyline_args: %r', pyline_args)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        import unittest
        return unittest.main()

    conf = Conf()
    conf.paths = list()

    if opts.paths__USRLOG:
        _USRLOG = os.environ.get('_USRLOG')
        if _USRLOG:
            conf.paths.append(_USRLOG)
        else:
            prs.error('-P was specified but ${_USRLOG} is not set')

    if opts.paths__stdin:
        if '-' in opts.paths:
            prs.error("-P/'--paths-from-stdin and -p='-' cannot both be specified")
        else:
            with codecs.getreader('utf8')(sys.stdin) as stdin:
                for line in itertools.imap(str.rstrip, stdin):
                    if line:
                        log.debug(('path-from-stdin', line))
                        opts.paths.append(line)

    if opts.paths:
        for p in opts.paths:
            log.debug(('path-from-cmdline', p))
        conf.paths.extend(opts.paths)

    conf.paths.extend(args)
    conf.attrs = ['date', 'id', 'cmd']

    if not opts.quiet:
        conf.halt_on_error = True

    if not any((opts.columns,
                opts.cmds, opts.sessions, opts.dates, opts.elapsed,
                opts.todo)):
        log.info("no columns specified. defaulting to: %r" % conf.attrs)
        prs.print_help()
        # return 2

    ALL_COLUMNS = ['line', 'words', 'date', 'id', 'virtualenv',
                   'path', 'histstr', 'histdate', 'hostname',
                   'user', 'histn', 'cmd']
    if opts.columns:
        conf.attrs = opts.columns
    else:
        if opts.cmds:
            conf.attrs = ['cmd']
        if opts.sessions:
            conf.attrs = ['id', 'cmd']
        if opts.dates or opts.elapsed:
            if opts.elapsed:
                conf.attrs = ['date', 'id', 'elapsed', 'cmd']
            else:
                conf.attrs = ['date', 'id', 'cmd']
        if opts.venvs:
            # before 'id', 'date', or first
            attrs_i = 'id' in conf.attrs and conf.attrs.index('id') + 1
            if not attrs_i:
                attrs_i = 'date' in conf.attrs and conf.attrs.index('date') + 1
            if not attrs_i:
                attrs_i = 0
            conf.attrs.insert(attrs_i, 'virtualenv')

        if opts.cwdpaths:
            # before 'id', 'date', or first
            attrs_i = 'virtualenv' in conf.attrs and conf.attrs.index('virtualenv') + 1
            if not attrs_i:
                attrs_i = 'id' in conf.attrs and conf.attrs.index('id') + 1
            if not attrs_i:
                attrs_i = 'date' in conf.attrs and conf.attrs.index('date') + 1
            if not attrs_i:
                attrs_i = 0
            conf.attrs.insert(attrs_i, 'path')

    def select_all(obj):
        return True

    #conf.attrs = ['date', 'id', 'cmd']

    def select_usrlogtodos(obj, todo_prefixes=TODO_PREFIXES):
        cmd = obj.get('cmd')
        return cmd.startswith(todo_prefixes) if cmd else False

    import itertools
    import functools
    import operator

    if opts.todo:
        filterfunc = functools.partial(select_usrlogtodos,
                                        todo_prefixes=TODO_PREFIXES)
    else:
        filterfunc = functools.partial(select_all)
    select_items = operator.itemgetter(*conf.attrs)

    def usrlogs_iterable():
        for p in conf.paths:
            _usrlog = usrlog(p, conf)
            for l in _usrlog:
                l['_usrlog'] = p
                yield l

    iterable = ((obj, select_items(obj)) for obj in
                itertools.ifilter(filterfunc, usrlogs_iterable()))

    if opts.pyline:
        try:
            import pyline
        except ImportError:
            from pyline import pyline
            pyline
        # args = args after pyline (e.g. --pyline --help)
        retcode = pyline.main(pyline_args,
                              iterable=iterable,
                              output=sys.stdout)
        return retcode
        # codefunc = lambda x: x
        # output = pyline.pyline(iterable, codefunc=do_pyline)
    else:
        for obj, attrs in iterable:
            print(attrs)

    EX_OK = 0

    return EX_OK


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
