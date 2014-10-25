#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""Search for code repositories and generate reports"""

import datetime
import errno
import logging
import os
import pprint
import re
import subprocess
import sys
from collections import deque, namedtuple
from distutils.util import convert_path
from itertools import chain, imap, izip_longest

# TODO: arrow
from dateutil.parser import parse as parse_date

try:
    from collections import OrderedDict as Dict
except ImportError as e:
    Dict = dict

# def parse_date(*args, **kwargs):
#     print(args)
#     print(kwargs)

# logging.basicConfig()
log = logging.getLogger('repos')
dtformat = lambda x: x.strftime('%Y-%m-%d %H:%M:%S %z')


def itersplit(s, sep=None):
    """
    Split a string by ``sep`` and yield chunks

    Args:
        s (str-type): string to split
        sep (str-type): delimiter to split by

    Yields:
        generator of strings: chunks of string s
    """
    if not s:
        yield s
        return
    exp = re.compile(r'\s+' if sep is None else re.escape(sep))
    pos = 0
    while True:
        m = exp.search(s, pos)
        if not m:
            if pos < len(s) or sep is not None:
                yield s[pos:]
            break
        if pos < m.start() or sep is not None:
            yield s[pos:m.start()]
        pos = m.end()


DEFAULT_FSEP = ' ||| '
DEFAULT_LSEP = ' |..|'
# DEFAULT_FSEP=u' %s ' % unichr(0xfffd)
# DEFAULT_LSEP=unichr(0xfffc)


def itersplit_to_fields(str_,
                        fsep=DEFAULT_FSEP,
                        revtuple=None,
                        fields=[],
                        preparse=None):
    """
    Itersplit a string into a (named, if specified) tuple.

    Args:
        str_ (str): string to split
        fsep (str): field separator (delimiter to split by)
        revtuple (object): namedtuple (or class with a ``._fields`` attr)
            (optional)
        fields (list of str): field names (if revtuple is not specified)
        preparse (callable): function to parse str with before itersplitting

    Returns:
        tuple or revtuple: fields as a tuple or revtuple, if specified

    """
    if preparse:
        str_ = preparse(str_)
    _fields = itersplit(str_, fsep)

    if revtuple is not None:
        try:
            values = (t[1] for t in izip_longest(revtuple._fields, _fields))
            return revtuple(*values)
        except:
            log.error(revtuple)
            log.error(_fields)
            raise

    return tuple(izip_longest(fields, _fields, fillvalue=None))


_missing = unichr(822)


class cached_property(object):

    """Decorator that converts a function into a lazy property.  The
    function wrapped is called the first time to retrieve the result
    and then that calculated result is used the next time you access
    the value::

        class Foo(object):

            @cached_property
            def foo(self):
                # calculate something important here
                return 42

    The class must have a `__dict__` (e.g. be a subclass of object)

    :copyright: BSD

    see: https://github.com/mitsuhiko/werkzeug/blob/master/werkzeug/utils.py
    """

    def __init__(self, func, name=None, doc=None):
        self.__name__ = name or func.__name__
        self.__module__ = func.__module__
        self.__doc__ = doc or func.__doc__
        self.func = func

    def __get__(self, obj, _type=None):
        if obj is None:
            return self
        value = obj.__dict__.get(self.__name__, _missing)
        if value is _missing:
            value = self.func(obj)
            obj.__dict__[self.__name__] = value
        return value


# TODO: sarge
def sh(cmd, ignore_error=False, cwd=None, *args, **kwargs):
    """
    Execute a command with subprocess.Popen and block until output

    Args:
        cmd (tuple or str): same as subprocess.Popen args
        ignore_error (bool): if False, raise an Exception if p.returncode is
            not 0
        cwd (str): path to current working directory

    Returns:
        str: command execution stdout

    Raises:
        Exception: if ignore_error is true and returncode is not zero

    .. note:: this executes commands with ``shell=True``: careful with
       shell-escaping.

    """
    kwargs.update({
        'shell': True,
        'cwd': cwd,
        'stderr': subprocess.STDOUT,
        'stdout': subprocess.PIPE})
    log.debug('cmd: %s %s' % (cmd, kwargs))
    p = subprocess.Popen(cmd, **kwargs)
    p_stdout = p.communicate()[0]
    if p.returncode and not ignore_error:
        raise Exception("Subprocess return code: %d\n%r\n%r" % (
            p.returncode, cmd, p_stdout))
    return p_stdout


class Repository(object):
    """
    Abstract Repository class from which VCS-specific implementations derive

    Attributes:
        label (str): vcs name (e.g. "hg")
        prefix (str): vcs folder name (e.g. ".hg")
        preparse (callable): pre-processing function for vcs log output
        fsep (str): field separator / record delimiter
        lsep (str): log output record separator / delimiter
        fields (list of tuples): (colname, vcs formatter, postprocess_callable)
        clone_cmd (str): name of commandline clone command (e.g. "clone")
    """
    label = None
    prefix = None
    preparse = None
    fsep = DEFAULT_FSEP
    lsep = DEFAULT_LSEP
    fields = []
    clone_cmd = 'clone'

    def __init__(self, fpath):
        """
        Create a new Repository instance

        Args:
            fpath (str): path (relative or absolute) to repository
        """
        self.fpath = os.path.abspath(fpath)
        self.symlinks = []

    def __new__(cls, name):
        self = super(Repository, cls).__new__(cls, name)
        self._tuple = self._namedtuple
        return self

    @property
    def relpath(self):
        """
        Determine the relative path to this repository

        Returns:
            str: relative path to this repository
        """
        here = os.path.abspath(os.path.curdir)
        relpath = os.path.relpath(self.fpath, here)
        return relpath

    @cached_property
    def _namedtuple(cls):
        return namedtuple(
            ''.join((str.capitalize(cls.label), "Rev")),
            (f[0] for f in cls.fields))

    def unique_id(self):
        """
        Determine a "unique id" for this repository

        Returns:
            str: a "unique id" for this repository
        """
        pass

    def status(self):
        """
        Run the repository status command and return stdout

        Returns:
            str: stdout output of Repository status command
        """
        pass

    def remote_url(self):
        """
        Determine the primary remote url for this Repository

        Returns:
            str: primary remote url for this Repository
        """
        pass

    def diff(self):
        """
        Run the repository diff command to compare working directory with 'tip'

        Returns:
            str: stdout output of Repository diff command
        """
        pass

    def current_id(self):
        """
        Determine the current revision identifier for the working directory
        of this Repository

        Returns:
            str: revision identifier
        """
        pass

    def branch(self):
        """
        Determine the branch name of the working directory of this Repository

        Returns:
            str: branch name
        """
        pass

    @cached_property
    def last_commit(self):
        """
        Get and parse the most recent Repository revision

        Returns:
            tuple: Repository log tuple
        """
        return self.log_iter(maxentries=1).next()

    def log(self, n=None, **kwargs):
        """
        Run the repository log command

        Returns:
            str: output of log command
        """
        pass

    def itersplit_to_fields(self, _str):
        """
        Split (or parse) repository log output into fields

        Returns:
            tuple: self._tuple(*values)
        """
        if self.preparse:
            _str = self.preparse(_str)

        _fields = itersplit(_str, self.fsep)

        try:
            values = (
                t[1] for t in izip_longest(self._tuple._fields, _fields))
            return self._tuple(*values)
        except:
            log.error(self._tuple)
            log.error(_fields)
            raise
    _parselog = itersplit_to_fields

    def log_iter(self, maxentries=None, template=None, **kwargs):
        """
        Run the repository log command, parse, and yield log tuples

        Yields:
            tuple: self._tuple
        """
        # op = self.sh((
        #   "hg log %s --template"
        #   % (maxentries and ('-l%d' % maxentries) or '')),
        #   ignore_error=True
        # )
        template = repr(template or self.template)
        op = self.log(n=maxentries, template=template, **kwargs)
        if not op:
            return
        print(op)
        for l in itersplit(op, self.lsep):
            l = l.strip()
            if not l:
                continue
            try:
                yield self._parselog(l,)
            except Exception:
                log.error("%s %r" % (str(self), l))
                raise
        return

    # def search_upwards():
    #     """ Implemented for Repositories that store per-directory
    #     metadata """
    #     pass

    def full_report(self):
        """
        Show origin, last_commit, status, and parsed complete log history
        for this repository

        Yields:
            str: report lines
        """
        yield ''
        yield "# %s" % self.origin_report().next()
        yield "%s [%s]" % (self.last_commit, self)
        if self.status:
            for l in self.status.split('\n'):
                yield l
            yield ''

        if hasattr(self, 'log_iter'):
            for r in self.log_iter():
                yield r
        return

    @cached_property
    def eggname(self):
        """
        Returns:
            str: basename of repository path (e.g. for pip_report)
        """
        return os.path.basename(self.fpath)

    @classmethod
    def to_normal_url(cls, url):
        """
        Args:
            url (str): repository URL (potentially with hg schemes)

        Returns:
            str: normal repository URL (un-hg-schemes-ed repository URL)
        """
        return url

    def str_report(self):
        """
        Yields:
            str: pretty-formatted representation of ``self.to_dict``
        """
        yield pprint.pformat(self.to_dict())

    def sh_report(self):
        """
        Show shell command necessary to clone this repository

        If there is no primary remote url, prefix-comment the command

        Yields:
            str: shell command necessary to clone this repository
        """
        output = []
        if not self.remote_url:
            output.append('#')
        output.extend([
            self.label,
            self.clone_cmd,
            repr(self.remote_url),  # TODO: shell quote?
            repr(self.relpath)
        ])

        yield ' '.join(output)

    def pip_report(self):
        """
        Show editable pip-requirements line necessary to clone this repository

        Yields:
            str: pip-requirements line necessary to clone this repository
        """
        comment = '#' if not self.remote_url else ''
        if os.path.exists(os.path.join(self.fpath, 'setup.py')):
            yield u"%s-e %s+%s@%s#egg=%s" % (
                comment,
                self.label,
                self.to_normal_url(self.remote_url),
                self.current_id,
                self.eggname)
        return

    def origin_report(self):
        """
        Yields:
            str: ``label://fpath = remote_url``
        """
        yield "%s://%s = %s" % (
            self.label,
            self.fpath,
            self.remote_url,
            # revid
            )
        return

    def status_report(self):
        """
        Yields:
            str: sh_report, last_commit, and repository status output
        """
        yield '######'
        yield self.sh_report().next()
        yield self.last_commit
        yield self.status
        yield ""

    def hgsub_report(self):
        """
        Yields:
            str: .hgsubs line for this repository
        """
        if self.relpath == '.':
            return
        yield "%s = [%s]%s" % (
            self.fpath.lstrip('./'),
            self.label,
            self.remote_url)

    def gitmodule_report(self):
        """
        Yields:
            str: .gitmodules configuration lines for this repository
        """
        fpath = self.relpath
        if fpath == '.':
            return
        yield '[submodule "%s"]' % fpath.replace(os.path.sep, '_')
        yield "    path = %s" % fpath
        yield "    url = %s" % self.remote_url
        yield ""

    def __unicode__(self):
        """
        Returns:
            str: ``label://fpath``
        """
        return '%s://%s' % (self.label, self.fpath)

    def __str__(self):
        """
        Returns:
            str: ``label://fpath``
        """
        return self.__unicode__()

    @cached_property
    def mtime(self, fpath=None):
        """
        Returns:
            str: strftime-formatted mtime (modification time) of fpath
        """
        return dtformat(
            datetime.datetime.utcfromtimestamp(
                os.path.getmtime(fpath or self.fpath)))

    @cached_property
    def ctime(self, fpath=None):
        """
        Returns:
            str: strftime-formatted ctime (creation time) of fpath
        """
        return dtformat(
            datetime.datetime.utcfromtimestamp(
                os.path.getctime(fpath or self.fpath)))

    @cached_property
    def find_symlinks(self):
        """
        Find symlinks within fpath

        Returns:
            str: ``path -> link``
        """
        cmd = ("find . -type l -printf '%p -> %l\n'")
        return self.sh(cmd)

    def lately(self, count=15):
        """
        Show ``count`` most-recently modified files by mtime

        Yields:
            tuple: (strftime-formatted mtime, self.fpath-relative file path)
        """
        excludes = '|'.join(('*.pyc', '*.swp', '*.bak', '*~'))
        cmd = ('''find . -printf "%%T@ %%p\\n" '''
               '''| egrep -v '%s' '''
               '''| sort -n '''
               '''| tail -n %d''') % (excludes, count)
        op = self.sh(cmd)
        for l in op.split('\n'):
            l = l.strip()
            if not l:
                continue
            mtime, fname = l.split(' ', 1)
            mtime = datetime.datetime.fromtimestamp(float(mtime))
            mtimestr = dtformat(mtime)
            yield mtimestr, fname

    def sh(self, cmd, ignore_error=False, cwd=None, *args, **kwargs):
        """
        Run a command with the current working directory set to self.fpath

        Returns:
            str: stdout output of wrapped call to ``sh`` (``subprocess.Popen``)
        """
        kwargs.update({
            'shell': True,
            'cwd': cwd or self.fpath,
            'stderr': subprocess.STDOUT,
            'stdout': subprocess.PIPE})
        log.debug('cmd: %s %s' % (cmd, kwargs))
        return sh(cmd, ignore_error=ignore_error, **kwargs)

        # p = subprocess.Popen(cmd, **kwargs)
        # p_stdout = p.communicate()[0]
        # if p.returncode and not ignore_error:
        #     raise Exception("Subprocess return code: %d\n%r\n%r" % (
        #         p.returncode, cmd, p_stdout))
        # return p_stdout #.rstrip()

    def to_dict(self):
        """
        Cast this Repository to a dict

        Returns:
            dict: this Repository as a dict
        """
        return self.__dict__


class MercurialRepository(Repository):
    """
    Mercurial Repository subclass

    Attributes:
        label (str): vcs name (e.g. "hg")
        prefix (str): vcs folder name (e.g. ".hg")
        preparse (callable): pre-processing function for vcs log output
        fsep (str): field separator / record delimiter
        lsep (str): log output record separator / delimiter
        fields (list of tuples): (colname, vcs formatter, postprocess_callable)
        clone_cmd (str): name of commandline clone command (e.g. "clone")
        template (str): concatenated log output template
    """
    label = 'hg'
    prefix = '.hg'

    fields = (
        ('datestr', '{date|isodatesec}', parse_date),
        ('noderev', '{node|short}', None),
        ('author', '{author|firstline}', None),
        ('tags', '{tags}', lambda x: x.strip().split()),
        ('desc', '{desc}', None),
        )
    template = ''.join((
        DEFAULT_FSEP.join(f[1] for f in fields),
        DEFAULT_LSEP)
    )

    @property
    def unique_id(self):
        """
        Determine a "unique id" for this repository

        Returns:
            str: fpath of this repository
        """
        return self.fpath  # self.sh('hg id -r 0').rstrip()

    @cached_property
    def status(self):
        """
        Run the repository status command and return stdout

        Returns:
            str: stdout output of ``hg status`` command
        """
        return self.sh('hg status').rstrip()

    @cached_property
    def remote_url(self):
        """
        Determine the primary remote url for this Repository

        Returns:
            str: primary remote url for this Repository
                (``hg showconfig paths.default``)
        """
        return self.sh('hg showconfig paths.default',
                       ignore_error=True).strip()

    @cached_property
    def remote_urls(self):
        """
        Get all configured remote urls for this Repository

        Returns:
            str: primary remote url for this Repository
                (``hg showconfig paths.default``)
        """
        return self.sh('hg showconfig paths')

    @cached_property
    def diff(self):
        """
        Run the repository diff command to compare working directory with 'tip'

        Returns:
            str: stdout output of ``hg diff -g``
        """
        return self.sh('hg diff -g')

    @cached_property
    def current_id(self):
        """
        Determine the current revision identifier for the working directory
        of this Repository

        Returns:
            str: revision identifier (``hg id -i``)
        """
        return self.sh('hg id -i').rstrip().rstrip('+')  # TODO

    @cached_property
    def branch(self):
        """
        Determine the branch name of the working directory of this Repository

        Returns:
            str: branch name (``hg branch``)
        """
        return self.sh('hg branch')

    def log(self, n=None, **kwargs):
        """
        Run the repository log command

        Returns:
            str: output of log command (``hg log -l <n> <--kwarg=value>``)
        """
        # TODO: nested generator
        return self.sh(' '.join((
            'hg log',
            ('-l%d' % n) if n else '',
            ' '.join(
                ('--%s=%s' % (k, v)) for (k, v) in kwargs.iteritems()
                )
            ))
        )

    def loggraph(self):
        """
        Show the log annotated an with ASCII revlog graph

        Returns:
            str: stdout output from ``hg log --graph``
        """
        return self.sh('hg log --graph')

    def unpushed(self):
        """
        Show outgoing changesets

        Raises:
            NotImplementedError: always
        """
        raise NotImplementedError()

    def serve(self):
        """
        Run the ``hg serve`` command
        """
        return self.sh('hg serve')

    # @cached_property # TODO: once
    @staticmethod
    def _get_url_scheme_regexes():
        """
        Get configured mercurial schemes and convert them to regexes

        Returns:
            tuple: (scheme_name, scheme_value, compiled scheme_regex)
        """
        output = sh("hg showconfig | grep '^schemes.'").split('\n')
        log.debug(output)
        schemes = (
            l.split('.', 1)[1].split('=') for l in output if '=' in l)
        regexes = sorted(
            ((k, v, re.compile(v.replace('{1}', '(.*)')+'(.*)'))
                for k, v in schemes),
            key=lambda x: (len(x[0]), x),
            reverse=True)
        return regexes

    @classmethod
    def to_hg_scheme_url(cls, url):
        """
        Convert a URL to local mercurial URL schemes

        Args:
            url (str): URL to map to local mercurial URL schemes

        example::

            # schemes.gh = git://github.com/
            >> remote_url = git://github.com/westurner/dotfiles'
            >> to_hg_scheme_url(remote_url)
            << gh://westurner/dotfiles

        """
        regexes = cls._get_url_scheme_regexes()
        for scheme_key, pattern, regex in regexes:
            match = regex.match(url)
            if match is not None:
                groups = match.groups()
                if len(groups) == 2:
                    return u''.join(
                        scheme_key,
                        '://',
                        pattern.replace('{1}', groups[0]),
                        groups[1])
                elif len(groups) == 1:
                    return u''.join(
                        scheme_key,
                        '://',
                        pattern,
                        groups[0])

    @classmethod
    def to_normal_url(cls, url):
        """
        convert a URL from local mercurial URL schemes to "normal" URLS

        example::

            # schemes.gh = git://github.com/
            # remote_url = "gh://westurner/dotfiles"
            >> to_normal_url(remote_url)
            << 'git://github.com/westurner/dotfiles'

        """
        regexes = cls._get_url_scheme_regexes()
        _url = url[:]
        for scheme_key, pattern, regex in regexes:
            if _url.startswith(scheme_key):
                if '{1}' in pattern:
                    _url = pattern.replace('{1}', _url.lstrip(scheme_key))
                else:
                    _url = (pattern + _url.lstrip(scheme_key).lstrip('://'))
        return _url

    # def to_pip_compatible_url(cls, url):
    #     PATTERNS = (
    #             ('gh+ssh://','https://github.com/'),
    #             ('bb+ssh://', 'https://bitbucket.org/'),
    #     )
    # ('gcode', '') ,
    # ('gcode+svn', ''),
    #     for p in PATTERNS:
    #         url = url.replace(*p)


class GitRepository(Repository):
    """
    Git Repository subclass

    Attributes:
        label (str): vcs name (e.g. "hg")
        prefix (str): vcs folder name (e.g. ".hg")
        preparse (callable): pre-processing function for vcs log output
        fsep (str): field separator / record delimiter
        lsep (str): log output record separator / delimiter
        fields (list of tuples): (colname, vcs formatter, postprocess_callable)
        clone_cmd (str): name of commandline clone command (e.g. "clone")
        template (str): concatenated log output template
    """
    label = 'git'
    prefix = '.git'
    fields = (
        ('datestr', '%ai', None, parse_date),
        ('noderev', '%h', None),
        ('author', '%an', None),
        ('tags', '%d', lambda x: x.strip(' ()').split(', ')),
        ('desc', '%s ', None),
    )
    template = ''.join((
        DEFAULT_FSEP.join(f[1] for f in fields),
        DEFAULT_LSEP)
    )

    @property
    def unique_id(self):
        """
        Determine a "unique id" for this repository

        Returns:
            str: fpath of this repository
        """
        return self.fpath

    @cached_property
    def status(self):
        """
        Run the repository status command and return stdout

        Returns:
            str: stdout output of ``hg status`` command
        """
        return self.sh('git status -s')

    @cached_property
    def remote_url(self):
        """
        Determine the primary remote url for this Repository

        Returns:
            str: primary remote url for this Repository
                (``git config remote.origin.url``)
        """
        return self.sh('git config remote.origin.url',
                       ignore_error=True).strip()  # .split('=',1)[1]# *

    @cached_property
    def remote_urls(self):
        """
        Get all configured remote urls for this Repository

        Returns:
            str: primary remote url for this Repository
                (``git config -l | grep "url"``)
        """
        return self.sh('git config -l | grep "url"',
                       ignore_error=True).strip()  # .split('=',1)[1]# *

    @cached_property
    def current_id(self):
        return self.sh('git rev-parse --short HEAD').rstrip()

    def diff(self):
        """
        Run the repository diff command to compare working directory with 'tip'

        Returns:
            str: stdout output of ``git diff``
        """
        return self.sh('git diff')

    @cached_property
    def branch(self):
        """
        Determine the branch name of the working directory of this Repository

        Returns:
            str: branch name (``git branch``)
        """
        return self.sh('git branch')

    def log(self, n=None, **kwargs):
        """
        Run the repository log command

        Returns:
            str: output of log command (``git log -n <n> <--kwarg=value>``)
        """
        kwargs['format'] = kwargs.pop('template')
        cmd = ' '.join((
            'git log',
            ('-n%d' % n) if n else '',
            ' '.join(
                ('--%s=%s' % (k, v)) for (k, v) in kwargs.iteritems()
            )
        ))
        try:
            output = self.sh(cmd)
            if "fatal: bad default revision 'HEAD'" in output:
                return output
            return output
        except Exception as e:
            e
            return

    def loggraph(self):
        """
        Show the log annotated an with ASCII revlog graph

        Returns:
            str: stdout output from ``git log --graph``
        """
        return self.sh('git log --graph')

    @cached_property
    def last_commit(self):
        """
        Get and parse the most recent Repository revision

        Returns:
            tuple: Repository log tuple
        """
        return self.log_iter(maxentries=1).next()

    # def __log_iter(self, maxentries=None):
    #    rows = self.log(
    #         n=maxentries,
    #         format="%ai ||| %h ||| %an ||| %d ||| %s  ||||\n",)
    #     if not rows:
    #         return
    #     for row in rows.split('||||\n'):
    #         row = row.strip()
    #         if not row:
    #             continue
    #         try:
    #             fields = (s.strip() for s in row.split('|||'))
    #             datestr, noderev, author, branches, desc = fields
    #         except ValueError:
    #             print(str(self), row, fields)
    #             raise
    #         branches = branches.strip()[1:-1]
    #         yield datestr, (noderev, author, branches, desc)
    #     return

    def unpushed(self):
        """
        Returns:
            str: stdout output from
                ``git log master --not --remotes='*/master'``.
        """
        return self.sh("git log master --not --remotes='*/master'")

    def serve(self):
        """
        Run the ``git serve`` command
        """
        return self.sh("git serve")


class BzrRepository(Repository):
    """
    Bzr Repository subclass

    Attributes:
        label (str): vcs name (e.g. "hg")
        prefix (str): vcs folder name (e.g. ".hg")
        preparse (callable): pre-processing function for vcs log output
        fsep (str): field separator / record delimiter
        lsep (str): log output record separator / delimiter
        fields (list of tuples): (colname, vcs formatter, postprocess_callable)
        clone_cmd (str): name of commandline clone command (e.g. "clone")
        field_trans (dict): mapping between bzr field outputs and tuple fields
        logrgx (rgx): compiled regex for parsing log message fields
    """
    label = 'bzr'
    prefix = '.bzr'
    template = None
    lsep = '-'*60
    fsep = '\n'
    fields = (
        ('datestr', None, parse_date),
        ('noderev', None, None),
        ('author', None, None),
        ('tags', None, None),
        ('branchnick', None, None),
        ('desc', None, None),
    )
    field_trans = {
        'branch nick': 'branchnick',
        'timestamp': 'datestr',
        'revno': 'noderev',
        'committer': 'author',
        'message': 'desc'
    }
    logrgx = re.compile(
        r'^(revno|tags|committer|branch\snick|timestamp|message):\s?(.*)\n?')
    clone_cmd = 'branch'

    @property
    def unique_id(self):
        """
        Determine a "unique id" for this repository

        Returns:
            str: fpath of this repository
        """
        return self.fpath

    @cached_property
    def status(self):
        """
        Run the repository status command and return stdout

        Returns:
            str: stdout output of ``bzr status`` command
        """
        return self.sh('bzr status')

    @cached_property
    def remote_url(self):
        """
        Determine the primary remote url for this Repository

        Returns:
            str: primary remote url for this Repository
            (``bzr info | egrep '^ parent branch:` | awk '{ print $3 }'``)
        """
        return self.sh(
            """bzr info  | egrep '^  parent branch:' | awk '{ print $3 }'""",
            ignore_error=True)

    def diff(self):
        """
        Run the repository diff command to compare working directory with 'tip'

        Returns:
            str: stdout output of ``bzr diff``
        """
        return self.sh('bzr diff')

    @cached_property
    def current_id(self):
        """
        Determine the current revision identifier for the working directory
        of this Repository

        Returns:
            str: bazaar revision identifier
                (``bzr version-info --custom --template='{revision_id}'``)
        """
        return self.sh("bzr version-info --custom --template='{revision_id}'")

    @cached_property
    def branch(self):
        """
        Determine the branch name of the working directory of this Repository

        Returns:
            str: branch nick (``bzr nick``)
        """
        return self.sh('bzr nick')

    def log(self, n=None, template=None):
        """
        Run the repository log command

        Returns:
            str: output of log command (``bzr log -l <n>``)
        """
        return self.sh(' '.join((
            'bzr log',
            '-l%d' % n if n else '')))

    # @cached_property
    # def last_commit(self):
    #     op = self.sh('bzr log -l1')
    #     return self._parselog(op)

    @classmethod
    def _logmessage_transform(cls, s, by=2):
        """
        Preprocess/cleanup a bzr log message before parsing

        Args:
            s (str): log message string
            by (int): cutoff threshold for log message length

        Returns:
            str: preprocessed log message string
        """
        if len(s) >= by:
            return s[by:].strip('\n')
        return s.strip('\n')

    @classmethod
    def _parselog(self, r):
        """
        Parse bazaar log file format

        Args:
            r (str): bzr revision identifier

        Yields:
            dict: dict of (attr, value) pairs

        ::

            $ bzr log -l1
            ------------------------------------------------------------
            revno: 1
            committer: ubuntu <ubuntu@ubuntu-desktop>
            branch nick: ubuntu-desktop /etc repository
            timestamp: Wed 2011-10-12 01:16:55 -0500
            message:
              Initial commit

        """
        def __parselog(entry):
            """
            Parse bazaar log file format

            Args:
                entry (str): log message string

            Yields:
                tuple: (attrname, value)
            """
            bufname = None
            buf = deque()
            print(entry)
            if entry == ['']:
                return
            for l in itersplit(entry, '\n'):
                if not l:
                    continue
                mobj = self.logrgx.match(l)
                if not mobj:
                    # "  - Log message"
                    buf.append(self._logmessage_transform(l))
                if mobj:
                    mobjlen = len(mobj.groups())
                    if mobjlen == 2:
                        # "attr: value"
                        attr, value = mobj.groups()
                        if attr == 'message':
                            bufname = 'desc'
                        else:
                            attr = self.field_trans.get(attr, attr)
                            yield (self.field_trans.get(attr, attr), value)
                    else:
                        raise Exception()
            if bufname is not None:
                if len(buf):
                    buf.pop()
                    len(buf) > 1 and buf.popleft()
                yield (bufname, '\n'.join(buf))
            return

        kwargs = dict(__parselog(r))  # FIXME
        if kwargs:
            if 'tags' not in kwargs:
                kwargs['tags'] = tuple()
            else:
                kwargs['tags'].split(' ')  # TODO
            if 'branchnick' not in kwargs:
                kwargs['branchnick'] = None
            try:
                yield kwargs  # TODO
                # return self._tuple(**kwargs)
            except:
                log.error(r)
                log.error(kwargs)
                raise
        else:
            log.error("failed to parse: %r" % r)


class SvnRepository(Repository):
    """
    SVN Repository subclass

    Attributes:
        label (str): vcs name (e.g. "hg")
        prefix (str): vcs folder name (e.g. ".hg")
        preparse (callable): pre-processing function for vcs log output
        fsep (str): field separator / record delimiter
        lsep (str): log output record separator / delimiter
        fields (list of tuples): (colname, vcs formatter, postprocess_callable)
        clone_cmd (str): name of commandline clone command (e.g. "clone")
    """
    label = 'svn'
    prefix = '.svn'
    fsep = ' | '
    lsep = ''.join(('-' * 72, '\n'))
    template = None
    fields = (
        ('noderev', None, None),
        ('author', None, None),
        ('datestr', None, None),
        ('changecount', None, None),
        ('desc', None, None),
        # TODO:
    )
    # def preparse(self, s):
    # return s# s.replace('\n\n',self.fsep,1)

    @cached_property
    def unique_id(self):
        """
        Determine a "unique id" for this repository

        Returns:
            str: Repository UUID of this repository
        """
        cmdo = self.sh('svn info | grep "^Repository UUID"',
                       ignore_error=True)
        if cmdo:
            return cmdo.split(': ', 1)[1].rstrip()
        return None

    @cached_property
    def status(self):
        """
        Run the repository status command and return stdout

        Returns:
            str: stdout output of ``svn status`` command
        """
        return self.sh('svn status')

    @cached_property
    def remote_url(self):
        """
        Determine the primary remote url for this Repository

        Returns:
            str: primary remote url for this Repository
                (``svn info | grep "^Repository Root:"``)
        """
        return (
            self.sh('svn info | grep "^Repository Root:"')
                .split(': ', 1)[1]).strip()

    def diff(self):
        """
        Run the repository diff command to compare working directory with 'tip'

        Returns:
            str: stdout output of ``svn diff``
        """
        return self.sh('svn diff')

    def current_id(self):
        """
        Determine the current revision identifier for the working directory
        of this Repository

        Returns:
            str: revision identifier
            (``svn info | grep "^Revision: "``)
        """
        # from xml.etree import ElementTree as ET
        # info = ET.fromstringlist(self.sh('svn info --xml'))
        # return info.find('entry').get('revision')
        return (
            self.sh('svn info | grep "^Revision: "')
            .split(': ', 1)[1].strip())

    def log(self, n=None, template=None, **kwargs):
        """
        Run the repository log command

        Returns:
            str: output of log command (``svn log -l <n> <--kwarg=value>``)
        """
        return (
            self.sh(' '.join((
                'svn log',
                ('-l%n' % n) if n else '',
                ' '.join(('--%s=%s' % (k, v)) for (k, v) in kwargs.items())
                ))
            )
        )

    @cached_property
    def _last_commit(self):
        """
        Retrieve the most recent commit message (with ``svn log -l1``)

        Returns:
            tuple: (datestr, (revno, user, None, desc))
        ::

$ svn log -l1
------------------------------------------------------------------------
r25701 | bhendrix | 2010-08-02 12:14:25 -0500 (Mon, 02 Aug 2010) | 1 line

added selection range traits to make it possible for users to replace
------------------------------------------------------------------------

        .. note:: svn log references the svn server
        """
        op = self.sh('svn log -l1')
        data, rest = op.split('\n', 2)[1:]
        revno, user, datestr, lc = data.split(' | ', 3)
        desc = '\n'.join(rest.split('\n')[1:-2])
        revno = revno[1:]
        # lc = long(lc.rstrip(' line'))
        return datestr, (revno, user, None,  desc)

    @cached_property
    def __last_commit(self):
        """
        Retrieve the most recent commit message (with ``svn info``)

        Returns:
            tuple: (datestr, (revno, user, None, desc))

        $ svn info
        Path: .
        URL: http://python-dlp.googlecode.com/svn/trunk/layercake-python
        Repository Root: http://python-dlp.googlecode.com/svn
        Repository UUID: d0ad5f6e-b329-0410-b51c-492c9c4f233d
        Revision: 378
        Node Kind: directory
        Schedule: normal
        Last Changed Author: chimezie
        Last Changed Rev: 378
        Last Changed Date: 2011-05-01 01:31:38 -0500 (Sun, 01 May 2011)
        """
        op = self.sh("svn info")
        if not op:
            return None
        author, rev, datestr = op.split('\n')[7:10]
        author = author.split(': ', 1)[1].strip()
        rev = rev.split(': ', 1)[1].strip()
        datestr = datestr.split(': ', 1)[1].split('(', 1)[0].strip()
        return datestr, (rev, author, None, None)

    @cached_property
    def last_commit(self):
        """
        Get and parse the most recent Repository revision

        Returns:
            tuple: Repository log tuple
        """
        return self.log_iter().next()

    # @cached_property
    def search_upwards(self, fpath=None, repodirname='.svn', upwards={}):
        """
        Traverse filesystem upwards, searching for .svn directories
        with matching UUIDs (Recursive)

        Args:
            fpath (str): file path to search upwards from
            repodirname (str): directory name to search for (``.svn``)
            upwards (dict): dict of already-searched directories

        example::

            repo/.svn
            repo/dir1/.svn
            repo/dir1/dir2/.svn

            >> search_upwards('repo/')
            << 'repo/'
            >> search_upwards('repo/dir1')
            << 'repo/'
            >> search_upwards('repo/dir1/dir2')
            << 'repo/'

            repo/.svn
            repo/dirA/
            repo/dirA/dirB/.svn

            >> search_upwards('repo/dirA')
            << 'repo/'
            >> search_upwards('repo/dirA/dirB')
            >> 'repo/dirB')

        """
        fpath = fpath or self.fpath
        uuid = self.unique_id
        last_path = self

        path_comp = fpath.split(os.path.sep)
        # [0:-1], [0:-2], [0:-1*len(path_comp)]
        for n in xrange(1, len(path_comp)-1):
            checkpath = os.path.join(*path_comp[0:-1 * n])
            repodir = os.path.join(checkpath, repodirname)
            upw_uuid = upwards.get(repodir)
            if upw_uuid:
                if upw_uuid == uuid:
                    last_path = SvnRepository(checkpath)
                    continue
                else:
                    break
            elif os.path.exists(repodir):
                repo = SvnRepository(checkpath)
                upw_uuid = repo.unique_id
                upwards[repodir] = upw_uuid
                # TODO: match on REVISION too
                if upw_uuid == uuid:
                    last_path = repo
                    continue
                else:
                    break

        return last_path


REPO_REGISTRY = [
    MercurialRepository,
    GitRepository,
    BzrRepository,
    # SvnRepository, # NOP'ing this functionality for now. requires net access.
]
REPO_PREFIXES = dict((r.prefix, r) for r in REPO_REGISTRY)
REPO_REGEX = (
    '|'.join('/%s' % r.prefix for r in REPO_REGISTRY)).replace('.', '\.')


def listdir_find_repos(where):
    """
    Search for repositories with a stack and ``os.listdir``

    Args:
        where (str): path to search from

    Yields:
        Repository subclass instance
    """
    stack = deque([(convert_path(where), '')])
    while stack:
        where, prefix = stack.pop()
        try:
            for name in sorted(os.listdir(where), reverse=True):
                fn = os.path.join(where, name)
                if os.path.isdir(fn):
                    if name in REPO_PREFIXES:
                        # yield name[1:], fn.rstrip(name)[:-1] # abspath
                        repo = REPO_PREFIXES[name](fn.rstrip(name)[:-1])
                        yield repo
                    stack.append((fn, prefix + name + '/'))
        except OSError as e:
            if e.errno == errno.EACCES:
                log.error("Skipping: %s", e)
            else:
                raise


def find_find_repos(where, ignore_error=True):
    """
    Search for repositories with GNU find

    Args:
        where (str): path to search from
        ignore_error (bool): if False, raise Exception when the returncode is
            not zero.

    Yields:
        Repository subclass instance
    """
    if os.uname()[0] == 'Darwin':
        cmd = ("find",
               " -E",
               repr(where),
               ' -type d',
               " -regex '.*(%s)$'" % REPO_REGEX)
    else:
        cmd = ("find",
               " -O3 ",
               repr(where),  # " .",
               " -type d",
               " -regextype posix-egrep",
               " -regex '.*(%s)$'" % REPO_REGEX)
    cmd = ' '.join(cmd)
    log.debug("find_find_repos(%r) = %s" % (where, cmd))
    kwargs = {
        'shell': True,
        'cwd': where,
        'stderr': sys.stderr,
        'stdout': subprocess.PIPE}
    p = subprocess.Popen(cmd, **kwargs)
    if p.returncode and not ignore_error:
        p_stdout = p.communicate()[0]
        raise Exception("Subprocess return code: %d\n%r\n%r" % (
            p.returncode, cmd, p_stdout))

    for l in iter(p.stdout.readline, ''):
        path = l.rstrip()
        _path, _prefix = os.path.dirname(path), os.path.basename(path)
        repo = REPO_PREFIXES.get(_prefix)
        if repo is None:
            log.error("repo for path %r and prefix %r is None" %
                      (path, _prefix))
        if repo:
            yield repo(_path)
        # yield repo


def find_unique_repos(where):
    """
    Search for repositories and deduplicate based on ``repo.fpath``

    Args:
        where (str): path to search from

    Yields:
        Repository subclass
    """
    repos = Dict()
    path_uuids = Dict()
    log.debug("find_unique_repos(%r)" % where)
    for repo in find_find_repos(where):
        # log.debug(repo)
        repo2 = (hasattr(repo, 'search_upwards')
                 and repo.search_upwards(upwards=path_uuids))
        if repo2:
            if repo2 == repo:
                continue
            else:
                repo = repo2

        if (repo.fpath not in repos):
            log.debug("%s | %s | %s" %
                      (repo.prefix, repo.fpath, repo.unique_id))
            repos[repo.fpath] = repo
            yield repo


# dict map between report names and report functions
REPORT_TYPES = dict(
    (attr, getattr(Repository, "%s_report" % attr)) for attr in (
        "str",
        "sh",
        "origin",
        "full",
        "pip",
        "status",
        "hgsub",
        "gitmodule",
    )
)


def do_repo_report(repos, report='full', output=sys.stdout, *args, **kwargs):
    """
    Do a repository report: call the report function for each Repository

    Args:
        repos (iterable): iterable of Repository instances
        report (string): report name
        output (writeable): output stream to print to

    Yields:
        Repository subclass
    """
    for i, repo in enumerate(repos):
        log.debug(str((i, repo.origin_report().next())))
        try:
            if repo is not None:
                reportfunc = REPORT_TYPES.get(report)
                if reportfunc is None:
                    raise Exception("Unrecognized report type: %r (%s)" %
                                    (report, ', '.join(REPORT_TYPES.keys())))
                for l in reportfunc(repo, *args, **kwargs):
                    print(l, file=output)
        except Exception as e:
            log.error(repo)
            log.error(report)
            log.error(e)
            raise

        yield repo


def do_tortoisehg_report(repos, output):
    """
    Generate a thg-reporegistry.xml file from a list of repos and print
    to output

    Args:
        repos (iterable): iterable of Repository subclass instances
        output (writeable): output stream to which THG XML will be printed
    """
    import operator
    import xml.etree.ElementTree as ET

    root = ET.Element('reporegistry')
    item = ET.SubElement(root, 'treeitem')

    group = ET.SubElement(item, 'group', attrib=Dict(name='groupname'))

    def fullname_to_shortname(fullname):
        """
        Return a TortoiseHG-friendly path to a repository

        Args:
            fullname (str): path to repository

        Returns:
            str: path with $HOME replaced with ``~`` and leading ``./``
                stripped
        """
        shortname = fullname.replace(os.environ['HOME'], '~')
        shortname = shortname.lstrip('./')
        return shortname

    for repo in sorted(repos, key=operator.attrgetter('fpath')):
        fullname = os.path.join(
            os.path.dirname(repo.fpath),
            os.path.basename(repo.fpath))
        shortname = fullname_to_shortname(fullname)
        if repo.prefix != '.hg':
            shortname = "%s%s" % (shortname, repo.prefix)
        _ = ET.SubElement(group, 'repo',
                          attrib=Dict(
                              root=repo.fpath,
                              shortname=shortname,
                              basenode='0'*40))
        _
    print('<?xml version="1.0" encoding="UTF-8"?>', file=output)
    print("<!-- autogenerated: %s -->" % "TODO", file=output)
    print(ET.dump(root), file=output)


def get_option_parser():
    """
    Build an ``optparse.OptionParser`` for pyrpo commandline use
    """
    import optparse

    prs = optparse.OptionParser(
        usage=(
            "$0 pyrpo [-h] [-v] [-q] [-s .] "
            "[-r <pip||full|status|hgsub|thg>] [--thg]"))

    prs.add_option('-s', '--scan',
                   dest='scan',
                   action='append',
                   default=[],
                   help='Path(s) to scan for repositories')

    prs.add_option('-r', '--report',
                   dest='reports',
                   action='append',
                   default=[],
                   help='pip || full || status || hgsub || thg')
    prs.add_option('--thg',
                   dest='thg_report',
                   action='store_true',
                   help='Write a thg-reporegistry.xml file to stdout')

    prs.add_option('--template',
                   dest='report_template',
                   action='store',
                   help='Report template')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)

    return prs


def main():
    """
    pyrpo.main: parse commandline options with optparse and run specified
    reports
    """

    import logging

    prs = get_option_parser()
    (opts, args) = prs.parse_args()

    if not opts.quiet:
        _format = None
        _format = "%(levelname)s\t%(message)s"
        # _format = "%(message)s"
        logging.basicConfig(format=_format)

    log = logging.getLogger('repos')

    if opts.verbose:
        log.setLevel(logging.DEBUG)
    elif opts.quiet:
        log.setLevel(logging.ERROR)
    else:
        log.setLevel(logging.INFO)
    if not opts.scan:
        opts.scan = ['.']

    if opts.scan:
        # if not opts.reports:
        #     opts.reports = ['pip']
        if opts.reports or opts.thg_report:
            opts.reports = [s.strip().lower() for s in opts.reports]
            if 'thg' in opts.reports:
                opts.thg_report = True
                opts.reports.remove('thg')
            # repos = []
            # for _path in opts.scan:
            #     repos.extend(find_unique_repos(_path))
            log.debug("SCANNING PATHS: %s" % opts.scan)
            repos = chain(*imap(find_unique_repos, opts.scan))

            if opts.reports and opts.thg_report:
                repos = list(repos)
                # TODO: tee

            if opts.reports:
                for report in opts.reports:
                    list(do_repo_report(repos, report=report))
            if opts.thg_report:
                import sys
                do_tortoisehg_report(repos, output=sys.stdout)

        else:
            opts.scan = '.'
            list(do_repo_report(
                find_unique_repos(opts.scan),
                report='sh'))

if __name__ == "__main__":
    main()
