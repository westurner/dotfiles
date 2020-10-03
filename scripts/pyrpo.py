#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""Search for code repositories and generate reports

Usage:

.. code:: bash

    pyrpo --help
    pyrpo -s .
    pyrpo -s . -r full
    cd $VIRTUAL_ENV; pyrpo -s . -r sh
"""

import codecs
import datetime
import errno
import json
import logging
import os
import pprint
import re
import subprocess
import sys

from collections import deque, namedtuple
from distutils.util import convert_path

from itertools import chain
if sys.version_info.major < 3:
    from itertools import imap, izip_longest
    def iteritems(d):
        return d.iteritems()
else:
    imap = map
    izip_longest = __import__('itertools').zip_longest
    xrange = range

    def iteritems(d):
        return d.items()

# TODO: arrow
from dateutil.parser import parse as parse_date

import sarge

# def parse_date(*args, **kwargs):
#     print(args)
#     print(kwargs)

# logging.basicConfig()
log = logging.getLogger('pyrpo')

try:
    from collections import OrderedDict as Dict
except ImportError as e:
    log.error("collections.OrderedDict not found; falling back to dict")
    Dict = dict


def dtformat(time):
    return time.strftime('%F %T%z')


def shell_quote_single(cmdstr):
    return sarge.shell_quote(cmdstr)


def shell_quote_double(cmdstr):
    _singlequoted = sarge.shell_quote(cmdstr)
    if (_singlequoted[0], _singlequoted[-1]) == ("'", "'"):
        return '"%s"' % _singlequoted[1:-1]
    else:
        return _singlequoted

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
        except Exception as e:
            log.error(revtuple)
            log.error(_fields)
            log.exception(e)
            raise

    return tuple(izip_longest(fields, _fields, fillvalue=None))


if sys.version_info.major < 3:
    _missing = unichr(822)
else:
    _missing = chr(822)


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


# TODO: sarge.run
def sh(cmd, ignore_error=False, cwd=None, shell=False, **kwargs):
    """
    Execute a command with subprocess.Popen and block until output

    Args:
        cmd (tuple or str): same as subprocess.Popen args

    Keyword Arguments:
        ignore_error (bool): if False, raise an Exception if p.returncode is
            not 0
        cwd (str): current working directory path to run cmd with
        shell (bool): subprocess.Popen ``shell`` kwarg

    Returns:
        str: stdout output of wrapped call to ``sh`` (``subprocess.Popen``)

    Raises:
        Exception: if ignore_error is true and returncode is not zero

    .. note:: this executes commands with ``shell=True``: careful with
       shell-escaping.

    """
    kwargs.update({
        'shell': shell,
        'cwd': cwd,
        'stderr': subprocess.STDOUT,
        'stdout': subprocess.PIPE,})
    log.debug((('cmd', cmd), ('kwargs', kwargs)))
    p = subprocess.Popen(cmd, universal_newlines=True, **kwargs)
    p_stdout = p.communicate()[0]
    if p.returncode and not ignore_error:
        raise subprocess.CalledProcessError(p.returncode, cmd, p_stdout)
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
        clone_cmd (str): clone commandline part (e.g. ``clone``)
        repo_abspath_cmd (str): repo_abspath commandline part (e.g. ``-C`` or ``-R``)
        checkout_rev_cmd (str): checkout_rev commandline part (e.g. ``checkout -r``)
        checkout_branch_cmd (str): clone commandline part (e.g. ``checkout``)
        branch_cmd (str): branch commandline part (e.g. ``branch``)
        pull_cmd (str): pull commandline part (e.g. ``pull``)
        push_cmd (str): push commandline part (e.g. ``push``)
        incoming_cmd (str): incoming changes commandline part (e.g. ``incoming``)
        outgoing_cmd (str): outgoing changes commandline (e.g. ``outgoing``)
    """
    # These are defaults which can/should be redefined by subclasses
    label = None
    prefix = None
    preparse = None
    fsep = DEFAULT_FSEP
    lsep = DEFAULT_LSEP
    fields = []
    # commandline parts
    clone_cmd = ['clone']
    repo_abspath_cmd = ['--repo-path']
    checkout_rev_cmd = ['checkout', '-r']
    checkout_branch_cmd = ['checkout']
    new_branch_cmd = ['branch']  # hg, bzr, svn: branch // git: checkout -b
    pull_cmd = ['pull']
    push_cmd = ['push']
    incoming_cmd = ['incoming']
    outgoing_cmd = ['outgoing']

    def __init__(self, fpath):
        """
        Create a new Repository instance

        Args:
            fpath (str): path (relative or absolute) to repository
        """
        self.fpath = os.path.abspath(fpath)
        self.symlinks = []

    def __new__(cls, name):
        self = super(Repository, cls).__new__(cls)
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
        return next(self.log_iter(maxentries=1))

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
        except Exception as e:
            log.error(self._tuple)
            log.error(_fields)
            log.exception(e)
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
        template = str(template or self.template)
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
        yield "# %s" % next(self.origin_report())
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

    def recreate_remotes_shellcmd(self):
        """
        Yields:
            str: shell command blocks to recreate repo config
        """
        # self.overwrite_hg_paths(output)
        if self.cfg_file:
            yield "cat > %s << ____EOF____" % shell_quote_double(self.cfg_file)
            yield self.read_cfg_file()
            yield "____EOF____"

    def str_report(self):
        """
        Yields:
            str: pretty-formatted representation of ``self.to_dict``
        """
        yield pprint.pformat(self.to_dict())

    def json_report(self):
        for l in self.to_json().splitlines():
            yield l

    def sh_report(self, full=True, latest=False):
        """
        Show shell command necessary to clone this repository

        If there is no primary remote url, prefix-comment the command

        Keyword Arguments:
            full (bool): also include commands to recreate branches and remotes
            latest (bool): checkout repo.branch instead of repo.current_id

        Yields:
            str: shell command necessary to clone this repository
        """

        def pathvar_repr(var):
            _var = var.replace('"', '\"')
            return '"%s"' % _var

        output = []
        if not self.remote_url:
            output.append('#')
        output = output + (
            [self.label]
            + self.clone_cmd
            + [pathvar_repr(self.remote_url)]  # TODO: shell quote?
            + [pathvar_repr(self.relpath)]
        )
        yield ''
        yield "## %s" % pathvar_repr(self.relpath)
        yield ' '.join(output)

        if full:
            checkout_rev = self.current_id
            # if latest: checkout_rev = self.branch

            relpath = pathvar_repr(self.relpath) if self.relpath else None
            relpath = relpath if relpath else ''
            checkout_branch_cmd = (
                [self.label]
                + self.checkout_branch_cmd + [self.branch]
                + self.repo_abspath_cmd
                + [relpath])
            checkout_rev_cmd = (
                [self.label]
                + self.checkout_rev_cmd + [checkout_rev]
                + self.repo_abspath_cmd
                + [relpath])

            if latest:
                checkout_cmd = checkout_branch_cmd
                comment = checkout_rev_cmd
            else:
                checkout_cmd = checkout_rev_cmd
                comment = checkout_branch_cmd

            yield ' '.join(c for c in checkout_cmd if c is not None)
            yield '### %s' % ' '.join(c for c in comment if c is not None)
            # output.extend([checkout_cmd, ';', ' ###', comment])

            for x in self.recreate_remotes_shellcmd():
                yield x
            # TODO: recreate remotes

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
        yield next(self.sh_report())
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
        cmd = ['find', '.', '-type l', "-printf '%p -> %l\n'"]
        return self.sh(cmd, shell=False)

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
        op = self.sh(cmd, shell=True)
        for l in op.split('\n'):
            l = l.strip()
            if not l:
                continue
            mtime, fname = l.split(' ', 1)
            mtime = datetime.datetime.fromtimestamp(float(mtime))
            mtimestr = dtformat(mtime)
            yield mtimestr, fname

    def sh(self, cmd, ignore_error=False, cwd=None, shell=False, **kwargs):
        """
        Run a command with the current working directory set to self.fpath

        Args:
            cmd (str or tuple): cmdstring or listlike

        Keyword Arguments:
            ignore_error (bool): if False, raise an Exception if p.returncode is
                not 0
            cwd (str): current working dir to run cmd with
            shell (bool): subprocess.Popen ``shell`` kwarg

        Returns:
            str: stdout output of wrapped call to ``sh`` (``subprocess.Popen``)
        """
        kwargs.update({
            'shell': shell,
            'cwd': cwd or self.fpath,
            'stderr': subprocess.STDOUT,
            'stdout': subprocess.PIPE,
            'ignore_error': ignore_error})
        log.debug((('cmd', cmd), ('kwargs', kwargs)))
        return sh(cmd, **kwargs)

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

    def to_json_dict(self):
        values = [
            ('type', self.label),
            ('relpath', self.relpath),
            ('remote_url', self.remote_url),
            ('branch', self.branch),
            ('rev', self.current_id),
            ('cfg', self.read_cfg_file()),
            ('status', self.status),
            ('fpath', self.fpath),
        ]
        return Dict(values)

    def to_json(self):
        return json.dumps(self.to_json_dict(), indent=2)

    @property
    def cfg_file(self):
        return None

    def read_cfg_file(self):
        with codecs.open(self.cfg_file, 'r', 'utf8') as f:
            return f.read()


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
    clone_cmd = ['clone']
    repo_abspath_cmd = ['-R']  # hg
    checkout_rev_cmd = ['checkout' '-r']
    checkout_branch_cmd = ['checkout']
    checkout_branch_hard_cmd = ['checkout', '-C']
    new_branch_cmd = ['branch']  # hg, bzr, svn?
    pull_cmd = ['pull']
    push_cmd = ['push']
    incoming_cmd = ['incoming']
    outgoing_cmd = ['outgoing']

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

    def sh(self, *args, **kwargs):
        _output = super(MercurialRepository, self).sh(*args, **kwargs)
        output = []
        for line in _output.splitlines():
            if line.startswith('*** failed to import extension'):
                log.debug(line)
            output.append(line)
        return '\n'.join(output)

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
        cmd = ['hg', 'status']
        return self.sh(cmd, shell=False).rstrip()

    @cached_property
    def remote_url(self):
        """
        Determine the primary remote url for this Repository

        Returns:
            str: primary remote url for this Repository
                (``hg showconfig paths.default``)
        """
        cmd = ['hg', 'showconfig', 'paths.default']
        return self.sh(cmd, shell=False,
                       ignore_error=True).strip()

    @cached_property
    def remote_urls(self):
        """
        Get all configured remote urls for this Repository

        Returns:
            str: primary remote url for this Repository
                (``hg showconfig paths.default``)
        """
        cmd = ['hg', 'showconfig', 'paths']
        return self.sh(cmd, shell=False)

    @property
    def cfg_file(self):
        return os.path.join(self.relpath, '.hg', 'hgrc')

    def overwrite_hg_paths(self, text):

        section_header = '[paths]\n'
        hgrc_path = self.cfg_file
        hgrc_text = self.read_cfg_file()
        paths_start = hgrc_text.find(section_header)
        if paths_start:
            paths_end = hgrc_text.find('\n[', paths_start + 1)
            if paths_end == -1:
                paths_end = len(hgrc_text) - 1

            startchar = paths_start + len(section_header)
            endchar = paths_end
            existing = hgrc_text[startchar:endchar]
            print("EXISTING")
            print(existing)

            if existing == text:
                print("SAME ... skipping")
            else:
                import shutil
                shutil.copy2(hgrc_path, hgrc_path + ".bkp")

                new_text = hgrc_text[:startchar] + text + hgrc_text[:endchar]
                print("NEW TEXT")
                print(new_text)
                with open(hgrc_path, 'w') as f:
                    f.write(new_text)

        return hgrc_text, new_text

    @cached_property
    def diff(self):
        """
        Run the repository diff command to compare working directory with 'tip'

        Returns:
            str: stdout output of ``hg diff -g``
        """
        cmd = ['hg', 'diff' '-g']
        return self.sh(cmd, shell=False)

    @cached_property
    def current_id(self):
        """
        Determine the current revision identifier for the working directory
        of this Repository

        Returns:
            str: revision identifier (``hg -q id -i``)
        """
        cmd = ['hg', '-q', 'id', '-i']
        return self.sh(cmd, shell=False).rstrip().rstrip('+')  # TODO

    @cached_property
    def branch(self):
        """
        Determine the branch name of the working directory of this Repository

        Returns:
            str: branch name (``hg branch``)
        """
        cmd = ['hg', '-q', 'branch']
        return self.sh(cmd, shell=False)

    def log(self, n=None, **kwargs):
        """
        Run the repository log command

        Returns:
            str: output of log command (``hg log -l <n> <--kwarg=value>``)
        """
        cmd = ['hg', 'log']
        if n:
            cmd.extend('-l%d' % n)
        cmd.extend(
            (('--%s=%s' % (k, v)) for (k, v)
                in iteritems(kwargs))
        )
        return self.sh(cmd, shell=False)

    def loggraph(self):
        """
        Show the log annotated an with ASCII revlog graph

        Returns:
            str: stdout output from ``hg log --graph``
        """
        cmd = ['hg', 'log', '--graph']
        return self.sh(cmd, shell=False)

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
        cmd = ['hg', 'serve']
        return self.sh(cmd, shell=False)

    # @cached_property # TODO: once
    @staticmethod
    def _get_url_scheme_regexes():
        """
        Get configured mercurial schemes and convert them to regexes

        Returns:
            tuple: (scheme_name, scheme_value, compiled scheme_regex)
        """
        output = sh("hg showconfig | grep '^schemes.'", shell=True).split('\n')
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
    clone_cmd = ['clone']
    repo_abspath_cmd = ['-C']  # git
    checkout_rev_cmd = ['checkout', '-r']
    checkout_branch_cmd = ['checkout']
    checkout_branch_hard_cmd = ['checkout', '-C']
    new_branch_cmd = ['checkout', '-b']  # git
    pull_cmd = ['pull']
    push_cmd = ['push']
    incoming_cmd = ['incoming']
    outgoing_cmd = ['outgoing']

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
        cmd = ['git', 'status', '-s']
        return self.sh(cmd, shell=False)

    @cached_property
    def remote_url(self, remotename='origin'):
        """
        Determine the primary remote url for this Repository

        Returns:
            str: primary remote url for this Repository
                (``git config remote.origin.url``)
        """
        cmd = ['git', 'config', 'remote.%s.url' % remotename]
        return self.sh(cmd, shell=False,
                       ignore_error=True).strip()  # .split('=',1)[1]# *

    @cached_property
    def remote_urls(self):
        """
        Get all configured remote urls for this Repository

        Returns:
            str: primary remote url for this Repository
                (``git config -l | grep "url"``)
        """
        cmd = 'git config -l | grep "url"'
        return self.sh(cmd,
                       shell=True,
                       ignore_error=True).strip()  # .split('=',1)[1]# *

    @cached_property
    def current_id(self):
        """
        Determine the current revision identifier for the working directory
        of this Repository

        Returns:
            str: git HEAD revision identifier
                (``git rev-parse --short HEAD``)
        """
        try:
            cmd = ['git', 'rev-parse', '--short', 'HEAD']
            return self.sh(cmd,
                        shell=False,
                        ignore_error=True).rstrip()
        except subprocess.CalledProcessError as e:
            log.exception(e)
            #if e.returncode == 128  # bare repo
            return None

    def diff(self):
        """
        Run the repository diff command to compare working directory with 'tip'

        Returns:
            str: stdout output of ``git diff``
        """
        cmd = ['git', 'diff']
        return self.sh(cmd, shell=False)

    @cached_property
    def branch(self):
        """
        Determine the branch name of the working directory of this Repository

        Returns:
            str: branch name (``git symbolic-ref --short HEAD``)
        """
        # return self.sh(['git, 'branch'], shell=False)  # parse for '*'
        cmd = ['git', 'symbolic-ref', '--short', 'HEAD']
        try:
            output = self.sh(cmd, shell=False, ignore_error=True).rstrip()
        except subprocess.CalledProcessError as e:
            log.exception(e)
            return  "#err# %s" % output
            #if e.returncode == 128  # bare repo
        if output.startswith('fatal: ref HEAD is not a symbolic ref'):
            output = '# %s' % output
        return output

    def log(self, n=None, **kwargs):
        """
        Run the repository log command

        Returns:
            str: output of log command (``git log -n <n> <--kwarg=value>``)
        """
        kwargs['format'] = kwargs.pop('template', self.template)
        cmd = ['git', 'log']
        if n:
            cmd.append('-n%d' % n)
        cmd.extend(
            (('--%s=%s' % (k, v))
             for (k, v) in iteritems(kwargs)))
        try:
            output = self.sh(cmd, shell=False)
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
        cmd = ['git', 'log', '--graph']
        return self.sh(cmd, shell=False)

    @cached_property
    def last_commit(self):
        """
        Get and parse the most recent Repository revision

        Returns:
            tuple: Repository log tuple
        """
        return next(self.log_iter(maxentries=1))

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
        cmd = ['git', 'log', 'master', '--not', "--remotes='*/master'"]
        return self.sh(cmd, shell=False)

    def serve(self):
        """
        Run the ``git serve`` command
        """
        cmd = ['git', 'serve']
        return self.sh(cmd, shell=False)

    @property
    def cfg_file(self):
        """
        Return the configuration file for the given repo path
        """
        default_path = os.path.join(self.relpath, '.git', 'config')
        if os.path.exists(default_path):
            return default_path

        dotgitpath = os.path.join(self.relpath, '.git')
        cfg_path = None
        # with git submodules, .git is a file containing "gitdir: .../../path"
        if os.path.isfile(dotgitpath):
            with codecs.open(dotgitpath, 'r', encoding='utf8') as f:
                for _line in f:
                    l = _line.strip()
                    if l.startswith('gitdir:'):
                        # gitdir: ../.git/modules/modname
                        cfg_path_relative = l.split('gitdir:', 1)[-1].strip()
                        cfg_path_absolute = os.path.abspath(
                            os.path.join(
                                os.path.dirname(dotgitpath),
                                cfg_path_relative,
                                'config'))
                        cfg_path = cfg_path_absolute
                        log.debug(('cfg_path_absolute', cfg_path_absolute))
                        #raise Exception(cfg_path_absolute) #_absolute)
                        break
        return cfg_path


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
    clone_cmd = ['branch']

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
        cmd = ['bzr', 'status']
        return self.sh(cmd, shell=False)

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
            shell=True,
            ignore_error=True)

    def diff(self):
        """
        Run the repository diff command to compare working directory with 'tip'

        Returns:
            str: stdout output of ``bzr diff``
        """
        cmd = ['bzr', 'diff']
        return self.sh(cmd, shell=False)

    @cached_property
    def current_id(self):
        """
        Determine the current revision identifier for the working directory
        of this Repository

        Returns:
            str: bazaar revision identifier
                (``bzr version-info --custom --template='{revision_id}'``)
        """
        cmd = ['bzr', 'version-info', '--custom', "--template='{revision_id}'"]
        return self.sh(cmd, shell=False)

    @cached_property
    def branch(self):
        """
        Determine the branch name of the working directory of this Repository

        Returns:
            str: branch nick (``bzr nick``)
        """
        cmd = ['bzr', 'nick']
        return self.sh(cmd, shell=False)

    def log(self, n=None, template=None):
        """
        Run the repository log command

        Returns:
            str: output of log command (``bzr log -l <n>``)
        """
        cmd = ['bzr', 'log']
        if n:
            cmd.append('-l%d' % n)
        return self.sh(cmd, shell=False)

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
        cmd = 'svn info | grep "^Repository UUID"'
        cmdo = self.sh(cmd,
                       shell=True,
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
        cmd = ['svn', 'status']
        return self.sh(cmd, shell=False)

    @cached_property
    def remote_url(self):
        """
        Determine the primary remote url for this Repository

        Returns:
            str: primary remote url for this Repository
                (``svn info | grep "^Repository Root:"``)
        """
        cmd = 'svn info | grep "^Repository Root:"'
        return (
            self.sh(cmd, shell=True).split(': ', 1)[1]).strip()

    def diff(self):
        """
        Run the repository diff command to compare working directory with 'tip'

        Returns:
            str: stdout output of ``svn diff``
        """
        cmd = ['svn', 'diff']
        return self.sh(cmd, shell=False)

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
            self.sh('svn info | grep "^Revision: "',
                    shell=True)
            .split(': ', 1)[1].strip())

    def log(self, n=None, template=None, **kwargs):
        """
        Run the repository log command

        Returns:
            str: output of log command (``svn log -l <n> <--kwarg=value>``)
        """
        cmd = ['svn', 'log']
        if n:
            cmd.append('-l%d' % n)
        cmd.extend(
            (('--%s=%s' % (k, v)) for (k, v) in kwargs.items())
        )
        return self.sh(cmd, shell=False)

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
        cmd = ['svn', 'log' '-l1']
        op = self.sh(cmd, shell=False)
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
        cmd = ['svn', 'info']
        op = self.sh(cmd, shell=False)
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
        return next(self.log_iter())

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
    '|'.join('/%s' % r.prefix for r in REPO_REGISTRY)).replace('.', '\\.')


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
                if name in REPO_PREFIXES:
                    if 1:  # os.path.exists(fn):
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
    log.debug(('REPO_REGEX', REPO_REGEX))
    FIND_REPO_REGEXCMD = ("-regex", '.*(%s)$' % REPO_REGEX)
    if os.uname()[0] == 'Darwin':
        cmd = ("find",
               '-E',
               '-L',  # dereference symlinks
               where,
               FIND_REPO_REGEXCMD[0],
               FIND_REPO_REGEXCMD[1])
    else:
        cmd = ("find",
               '-O3',
               '-L',  # dereference symlinks
               where,  # " .",
               "-regextype","posix-egrep",
               FIND_REPO_REGEXCMD[0],
               FIND_REPO_REGEXCMD[1])
    _cmd = ' '.join(cmd)
    log.debug("find_find_repos(%r) = %s" % (where, _cmd))
    kwargs = {
        #'shell': True,
        'cwd': where,
        'stderr': sys.stderr,
        'stdout': subprocess.PIPE,}
    p = subprocess.Popen(cmd, universal_newlines=True, **kwargs)
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
        "json",
        "sh",  # default
        # "sh_full", # TODO
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
        log.debug(str((i, next(repo.origin_report()))))
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
            "[-r <report>] [--thg]"))

    prs.add_option('-s', '--scan',
                   dest='scan',
                   action='append',
                   default=[],
                   help='Path(s) to scan for repositories')

    prs.add_option('-r', '--report',
                   dest='reports',
                   action='append',
                   default=[],
                   help=("""origin, status, full, gitmodule, json, sh, """
                         """str, pip, hgsub"""))
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


def main(argv=None):
    """
    pyrpo.main: parse commandline options with optparse and run specified
    reports
    """

    import logging

    if argv is None:
        argv = sys.argv

    prs = get_option_parser()
    (opts, args) = prs.parse_args(args=argv)

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
                do_tortoisehg_report(repos, output=sys.stdout)

        else:
            opts.scan = '.'
            list(do_repo_report(
                find_unique_repos(opts.scan),
                report='sh'))
    return 0

if __name__ == "__main__":
    sys.exit(main())
