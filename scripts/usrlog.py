#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
usrlog
"""

import codecs
import collections
import logging
import pprint
import re

log = logging

ISODATETIME_RGX = re.compile(
    '\d\d\d\d\-\d\d\-\d\dT?\d\d:\d\d')

ISODATETIME_LOOSE_RGX = re.compile(
    '[\d\-T: \+Z]+')

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

if dateutil:
    def parse_date(datestr):
        try:
            return dateutil.parser.parse(datestr)
        except ValueError as e:
            log.error(datestr)
            log.exception(e)
            raise
else:
    if arrow:
        def parse_date(datestr):
            return arrow.get(datestr)
    else:
        def parse_date(datestr):
            if not datestr:
                return datestr
            _datestr = datestr[:19]
            tzstr = datestr[19:]
            iso8601_strptime = '%Y-%m-%dT%H:%M:%S'
            return datetime.datetime.strptime(iso8601_strptime, _datestr)

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
    date_rgxstr = '^#? ?(\d\d\d\d-\d\d-\d\dT?\d\d:\d\d:\d\d[-\+\d]+)\t(.*)'
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

    def parse_line_cmds(self, line):
        if not line:
            return line
        mobj = self.date_rgx.match(line)
        if not mobj:
            return self.tabescape(line)
        w = line.split("\t", 8)
        # legacy usrlog support
        if len(w) > 8:
            cmd = u" ".join(w[8:]).rstrip()
        elif len(w) > 7:
            cmd = u" ".join(w[7:]).rstrip()
        elif len(w) > 3:
            cmd = u" ".join(w[3:]).rstrip()
        else:
            cmd = u" ".join(w).rstrip()
        return cmd

    def parse_line_to_dict(self, line, halt_on_error=False):  # TODO: lbt
        w = line.split('\t', 8)
        try:
            if len(w) >= 2 and w[1].startswith('#ntid'):
                result = collections.OrderedDict((
                    ("line", line),
                    ("words", w),
                    ("date", w[0]),
                    ("id", w[1]),
                    ("path", None),
                    ("histstr", None),
                    ("histn", None),    # int or "#note"
                    ("histdate", None),
                    ("histhostname", None),
                    ("histuser", None),
                    ("histcmd", None),
                    ))
            elif len(w) == 3:  # legacy usrlog support
                result = collections.OrderedDict((
                    ("line", line),
                    ("words", w),
                    ("date", w[0]),
                    ("id", w[1]),
                    ("path", None),
                    ("histstr", None),
                    ("histn", None),    # int or "#note"
                    ("histdate", None),
                    ("histhostname", None),
                    ("histuser", None),
                    ("histcmd", w[2]),
                    ))
            elif len(w) == 1:
                result = collections.OrderedDict((
                    ("line", line),
                    ("words", w),
                    ("date", None),
                    ("id", None),
                    ("path", None),
                    ("histstr", None),
                    ("histn", None),    # int or "#note"
                    ("histdate", None),
                    ("histhostname", None),
                    ("histuser", None),
                    ("histcmd", line),
                    ))
            else:
                result = collections.OrderedDict((
                    ("line", line),
                    ("words", w),
                    ("date", w[0]),
                    ("id", w[1]),
                    ("path", w[2]),
                    ("histstr", w[3:]),
                    ("histn", w[3]),    # int or "#note"
                    ("histdate", (w[4] if len(w) > 4 else None)),
                    ("histhostname", (w[5] if len(w) > 5 else None)),
                    ("histuser", (w[6] if len(w) > 6 else None)),
                    ("histcmd", (
                        u"".join(w[8:]).rstrip() if len(w) > 8 else None)),
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

        _histcmd = result['histcmd']
        _histn = result.get('histn')
        if not _histcmd:
            if _histn:
                if _histn[:5] in ('#ntid', '#TODO'):
                    result['histcmd'] = result['histn'].rstrip()
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
        histcmd = obj.get('histcmd')
        if histcmd in (None, False):
            return False
        assert isinstance(histcmd, basestring)
        mobj = self.cmdstr_rgx.match(histcmd)
        if not mobj:
            return False
        tag = mobj.groups()[1]
        print("tag: ", tag)
        return tag


def usrlog(path, conf=None):
    """mainfunc

    Arguments:
        path (str): path to usrlog

    Keyword Arguments:
        conf (dict): configuration dict

    Yields:
        tuple: parsed usrlog entries

    Raises:
        Exception: ...
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
        ('usrlogpath', os.path.expanduser('~/-usrlog.log'))])

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
            log.debug(obj['histcmd'])
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

    prs = optparse.OptionParser(usage="%prog : [-p <path>]")

    prs.add_option('-p', '--path',
                   dest='paths',
                   action='append',
                   default=[],
                   help=(
                        """Path to a -usrlog.log file to read """
                        '''(e.g. "${VIRTUAL_ENV}/-usrlog.log" '''
                        """or '-' for stdin)"""))

    prs.add_option('--cmds',
                   dest='cmds',
                   action='store_true',
                   help='show <cmd>')
    prs.add_option('--sessions',
                   dest='sessions',
                   action='store_true',
                   help='show [id, histcmd]')
    prs.add_option('--dates',
                   dest='dates',
                   action='store_true',
                   help='show [date, id, histcmd]')
    prs.add_option('--elapsed',
                   dest='elapsed',
                   action='store_true',
                   help='show [date, id, histcmd, elapsed]')

    prs.add_option('-c', '--column',
                   dest='columns',
                   action='append',
                   default=[],
                   help='id, date, histcmd, TODO')

    prs.add_option('--pyline',
                   dest='pyline',
                   action='store',
                   help='run pyline command')

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
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        return unittest.main()

    conf = Conf()
    conf.paths = list(opts.paths)
    conf.paths.extend(args)
    conf.attrs = ['date', 'id', 'histcmd']

    if not opts.quiet:
        conf.halt_on_error = True

    if opts.columns:
        conf.attrs = opts.columns
    else:
        if opts.cmds:
            conf.attrs = ['histcmd']
        if opts.sessions:
            conf.attrs = ['id', 'histcmd']
        if opts.dates or opts.elapsed:
            if opts.elapsed:
                conf.attrs = ['date', 'id', 'elapsed', 'histcmd']
            else:
                conf.attrs = ['date', 'id', 'histcmd']

    if opts.pyline:
        try:
            import pyline
        except ImportError:
            from pyline import pyline

        def do_pyline(obj, expr="{histcmd}"):
            return expr.format(**obj)

    def usrlogs_iterable():
        for p in conf.paths:
            _usrlog = usrlog(p, conf)
            for l in _usrlog:
                l['_usrlog'] = p
                yield l

    import operator
    select_items = operator.itemgetter(*conf.attrs)
    iterable = (select_items(obj) for obj in usrlogs_iterable())

    #output = pyline.pyline(iterable, codefunc=do_pyline)
    for o in iterable:
        print(o)

    EX_OK = 0

    return EX_OK


if __name__ == "__main__":
    import sys
    sys.exit(main(argv=sys.argv[1:]))
