#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""Search for code repositories and generate reports"""

import datetime
import errno
import logging
import os
import subprocess
import sys
from collections import deque, namedtuple
from distutils.util import convert_path

from dateutil.parser import parse as parse_date

#def parse_date(*args, **kwargs):
#    print(args)
#    print(kwargs)

#logging.basicConfig()
log = logging.getLogger('repos')
dtformat = lambda x: x.strftime('%Y-%m-%d %H:%M:%S %z')

import re
def itersplit(s, sep=None):
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


DEFAULT_FSEP=' ||| '
DEFAULT_LSEP=' |..|'
#DEFAULT_FSEP=u' %s ' % unichr(0xfffd)
#DEFAULT_LSEP=unichr(0xfffc)
from itertools import izip_longest
def itersplit_to_fields(_str,
                        fsep=DEFAULT_FSEP,
                        revtuple=None,
                        fields=[],
                        preparse=None):
    if preparse:
        _str = preparse(_str)
    _fields = itersplit(_str, fsep)

    if revtuple is not None:
        try:
            values = ( t[1] for t in izip_longest(revtuple._fields, _fields) )
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

def sh(cmd, ignore_error=False, cwd=None, *args, **kwargs):
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
    label           = None
    prefix          = None
    preparse        = None
    fsep            = DEFAULT_FSEP
    lsep            = DEFAULT_LSEP
    fields          = []

    def __init__(self, fpath):
        self.fpath = os.path.abspath(fpath)
        self.symlinks = []


    def __new__(cls, name):
        self = super(Repository, cls).__new__(cls, name)
        self._tuple = self._namedtuple
        return self


    @cached_property
    def _namedtuple(cls):
        return namedtuple(
                    ''.join( (str.capitalize(cls.label), "Rev") ),
                    (f[0] for f in cls.fields))


    def unique_id(self):
        """
        :returns: str
        """
        pass

    def status(self):
        """
        :returns: str
        """
        pass

    def remote_url(self):
        """
        :returns: str
        """
        pass

    def diff(self):
        """
        :returns: str
        """
        pass

    def current_id(self):
        """
        :returns: str
        """
        pass

    def branch(self):
        """
        :returns: str
        """
        pass

    @cached_property
    def last_commit(self):
        return self.log_iter(maxentries=1).next()

    def log(self, n=None, **kwargs):
        """
        :returns: str
        """
        pass

    def itersplit_to_fields(self, _str):
        if self.preparse:
            _str = self.preparse(_str)

        _fields = itersplit(_str, self.fsep)

        try:
            values = ( t[1] for t in izip_longest(self._tuple._fields, _fields) )
            return self._tuple(*values)
        except:
            log.error(self._tuple)
            log.error(_fields)
            raise
    _parselog = itersplit_to_fields

    def log_iter(self, maxentries=None, template=None, **kwargs):
        #op = self.sh((
            #"hg log %s --template"

                #% (maxentries and ('-l%d' % maxentries) or '')),
            #ignore_error=True
            #)
        template = repr(template or self.template)
        op = self.log(n=maxentries, template=template, **kwargs)
        if not op:
            return
        for l in itersplit(op, self.lsep):
            l = l.strip()
            if not l:
                continue
            try:
                yield self._parselog( l,)
            except Exception:
                log.error("%s %r" % (str(self), l))
                raise
        return

    #def search_upwards():
    #    """ Implemented for Repositories that store per-directory
    #    metadata """
    #    pass

    def full_report(self):
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
        return os.path.basename(self.fpath)

    @classmethod
    def to_normal_url(cls, url):
        return url

    def pip_report(self):
        yield u"-e %s+%s@%s#egg=%s" % (
                self.label,
                self.to_normal_url(self.remote_url),
                self.current_id,
                self.eggname)
        return


    def origin_report(self):
        yield "%s://%s = %s" % (
                self.label,
                self.fpath,
                self.remote_url,
                # revid
                )
        return

    def status_report(self):
        yield self.origin_report().next()
        yield self.last_commit
        yield self.status
        yield ""

    def hgsub_report(self):
        yield "%s = [%s]%s" % (
                self.fpath.lstrip('./'),
                self.label,
                self.remote_url)

    def gitsubmodule_report(self):
        fpath = self.fpath.lstrip('.%s' % os.path.sep)
        yield '[submodule "%s"]' % fpath.replace(os.path.sep, '_')
        yield "path = %s" % fpath
        yield "url = %s" % self.remote_url
        yield ""

    def __unicode__(self):
        return '%s://%s' % (self.label, self.fpath)

    def __str__(self):
        return self.__unicode__()

    @cached_property
    def mtime(self, fpath=None):
        return dtformat(
            datetime.datetime.utcfromtimestamp(
                os.path.getmtime(fpath or self.fpath)
                )
            )

    @cached_property
    def ctime(self, fpath=None):
        return dtformat(
            datetime.datetime.utcfromtimestamp(
                os.path.getctime(fpath or self.fpath)
                )
            )

    @cached_property
    def find_symlinks(self):
        cmd = ("find . -type l -printf '%p -> %l\n'")
        return self.sh(cmd)

    def lately(self, count=15):
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
        kwargs.update({
                'shell': True,
                'cwd': cwd or self.fpath,
                'stderr': subprocess.STDOUT,
                'stdout': subprocess.PIPE})
        return sh(cmd, ignore_error=ignore_error, **kwargs)

        #log.debug('cmd: %s %s' % (cmd, kwargs))
        #p = subprocess.Popen(cmd, **kwargs)
        #p_stdout = p.communicate()[0]
        #if p.returncode and not ignore_error:
        #    raise Exception("Subprocess return code: %d\n%r\n%r" % (
        #        p.returncode, cmd, p_stdout))

        #return p_stdout #.rstrip()

    def to_dict(self):
        return self.__dict__

# todo:
#try:
#   import mercurial as hg
#   native facade
#except ImporError:
#   pass
#

#import mercurial.commands
#class NativeMercurialRepository(MercurialRepository):
#    @cached_property
#    def status(self):
#        return mercurial.commands.status(



class MercurialRepository(Repository):
    label = 'hg'
    prefix = '.hg'

    fields = (
        ('datestr', '{date|isodatesec}', parse_date),
        ('noderev', '{node|short}', None),
        ('author', '{author|firstline}', None),
        ('tags', '{tags}', lambda x: x.strip().split()),
        ('desc', '{desc}', None),
        )
    template=''.join((
        DEFAULT_FSEP.join(f[1] for f in fields),
        DEFAULT_LSEP)
    )

    @property
    def unique_id(self):
        return self.fpath #self.sh('hg id -r 0').rstrip()

    @cached_property
    def status(self):
        return self.sh('hg status').rstrip()

    @cached_property
    def remote_url(self):
        return self.sh('hg showconfig paths.default',
                ignore_error=True).strip()

    @cached_property
    def remote_urls(self):
        return self.sh('hg showconfig paths')

    @cached_property
    def diff(self):
        return self.sh('hg diff -g')

    @cached_property
    def current_id(self):
        return self.sh('hg id -i').rstrip().rstrip('+') # TODO

    @cached_property
    def branch(self):
        return self.sh('hg branch')

    def log(self, n=None, **kwargs):
        return self.sh(' '.join((
                'hg log',
                ('-l%d'%n) if n else '',
                ' '.join(
                    ('--%s=%s' % (k,v)) for (k,v) in kwargs.iteritems()
                )
            ))
        )

    def loggraph(self):
        return self.sh('hg log --graph')

    def unpushed(self):
        raise NotImplementedError()

    def serve(self):
        return self.sh('hg serve')

    #@cached_property # TODO: once
    @staticmethod
    def _get_url_scheme_regexes():
        output = sh("hg showconfig | grep '^schemes.'").split('\n')
        log.debug(output)
        schemes = (
            l.split('.',1)[1].split('=') for l in output if '=' in l)
        import re, operator
        regexes = sorted(
            ((k, v, re.compile(v.replace('{1}','(.*)')+'(.*)'))
                for k,v in schemes),
            key=lambda x: (len(x[0]), x),
            reverse=True)
        return regexes

    @classmethod
    def to_hg_scheme_url(cls, url):
        """
        convert a URL to local mercurial URL schemes

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
        for scheme_key, pattern, regex in regexes:
            if url.startswith(scheme_key):
                if '{1}' in pattern:
                    return pattern.replace('{1}', url.lstrip(scheme_key))
                else:
                    return (pattern + url.lstrip(scheme_key).lstrip('://'))
        return url




class GitRepository(Repository):
    label = 'git'
    prefix = '.git'
    fields=(
        ('datestr', '%ai', None, parse_date),
        ('noderev', '%h', None),
        ('author', '%an', None),
        ('tags','%d', lambda x: x.strip(' ()').split(', ')),
        ('desc', '%s ', None),
    )
    template=''.join((
        DEFAULT_FSEP.join(f[1] for f in fields),
        DEFAULT_LSEP)
    )

    @property
    def unique_id(self):
        return self.fpath

    @cached_property
    def status(self):
        return self.sh('git status -s')

    @cached_property
    def remote_url(self):
        return self.sh('git config remote.origin.url',
                ignore_error=True).strip() #.split('=',1)[1]# *

    @cached_property
    def remote_urls(self):
        return self.sh('git config -l | grep "url"',
                ignore_error=True).strip() #.split('=',1)[1]# *

    @cached_property
    def current_id(self):
        return self.sh('git rev-parse --short HEAD').rstrip()

    def diff(self):
        return self.sh('git diff')

    @cached_property
    def branch(self):
        return self.sh('git branch')

    def log(self, n=None, **kwargs):
        kwargs['format'] = kwargs.pop('template')
        return self.sh(' '.join((
                'git log',
                ('-n%d'%n) if n else '',
                ' '.join(
                    ('--%s=%s' % (k,v)) for (k,v) in kwargs.iteritems()
                )
            ))
        )

    def loggraph(self):
        return self.sh('git log --graph')

    @cached_property
    def last_commit(self):
        return self.log_iter(maxentries=1).next()

    #def __log_iter(self, maxentries=None):

        #rows = self.log(
            #n=maxentries,
            #format="%ai ||| %h ||| %an ||| %d ||| %s  ||||\n",)
        #if not rows:
            #return
        #for row in rows.split('||||\n'):
            #row = row.strip()
            #if not row:
                #continue
            #try:
                #fields = (s.strip() for s in row.split('|||'))
                #datestr, noderev, author, branches, desc = fields
            #except ValueError:
                #print(str(self), row, fields)
                #raise
            #branches = branches.strip()[1:-1]
            #yield datestr, (noderev, author, branches, desc)
        #return

    def unpushed(self):
        return self.sh("git log master --not --remotes='*/master'")

    def serve(self):
        return self.sh("git serve")


class BzrRepository(Repository):
    label = 'bzr'
    prefix = '.bzr'
    template = None
    lsep='-'*60
    fsep='\n'

    fields=(
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

    logrgx = re.compile(r'^(revno|tags|committer|branch\snick|timestamp|message):\s?(.*)\n?')

    @property
    def unique_id(self):
        return self.fpath

    @cached_property
    def status(self):
        return self.sh('bzr status')

    @cached_property
    def remote_url(self):
        return self.sh("""bzr info  | egrep '^  parent branch:' | awk '{ print $3 }'""",
                ignore_error=True)

    def diff(self):
        return self.sh('bzr diff')

    @cached_property
    def current_id(self):
        return self.sh("bzr version-info --custom --template='{revision_id}'")

    @cached_property
    def branch(self):
        return self.sh('bzr nick')

    def log(self, n=None, template=None):
        return self.sh(' '.join((
                'bzr log',
                '-l%d'%n if n else '')))

    #@cached_property
    #def last_commit(self):
        #op = self.sh('bzr log -l1')
        #return self._parselog(op)

    @classmethod
    def _logmessage_transform(cls, s, by=2):
        if len(s) >= by:
            return s[by:].strip('\n')
        return s.strip('\n')

    def _parselog(self, r):
        """

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
            bufname=None
            buf=deque()
            for l in itersplit(entry, '\n'):
                mobj = self.logrgx.match(l)
                if not mobj:
                    # "  - Log message"
                    buf.append(self._logmessage_transform(l))
                if mobj:
                    mobjlen=len(mobj.groups())
                    if mobjlen == 2:
                        # "attr: value"
                        attr, value = mobj.groups()
                        if attr=='message':
                            bufname='desc'
                        else:
                            attr = self.field_trans.get(attr, attr)
                            yield ( self.field_trans.get(attr, attr), value )
                    else:
                        raise Exception()
            if bufname is not None:
                if len(buf):
                    buf.pop()
                    len(buf)>1 and buf.popleft()
                yield (bufname, '\n'.join(buf))
            return

        kwargs = dict(__parselog(r)) # FIXME
        if kwargs:
            if 'tags' not in kwargs:
                kwargs['tags'] = tuple()
            else:
                kwargs['tags'].split(' ') # TODO
            if 'branchnick' not in kwargs:
                kwargs['branchnick'] = None
            try:
                return self._tuple(**kwargs)
            except:
                log.error(r)
                log.error(kwargs)
                raise
        else:
            log.error("failed to parse: %r" % r)


class SvnRepository(Repository):
    label = 'svn'
    prefix = '.svn'

    fsep=' | '
    lsep=''.join( ('-'*72,'\n') )
    template=None

    fields=(
        ('noderev', None, None),
        ('author', None, None),
        ('datestr', None, None),
        ('changecount', None, None),
        ('desc', None, None),
        # TODO:
    )
    #def preparse(self, s):
    #    return s# s.replace('\n\n',self.fsep,1)

    @cached_property
    def unique_id(self):
        cmdo = self.sh('svn info | grep "^Repository UUID"',
                ignore_error=True)
        if cmdo:
            return cmdo.split(': ', 1)[1].rstrip()
        return None

    @cached_property
    def status(self):
        return self.sh('svn status')

    @cached_property
    def remote_url(self):
        return (
            self.sh('svn info | grep "^Repository Root:"')
                .split(': ', 1)[1]).strip()

    def diff(self):
        return self.sh('svn diff')

    def current_id(self):
        #from xml.etree import ElementTree as ET
        #info = ET.fromstringlist(self.sh('svn info --xml'))
        #return info.find('entry').get('revision')
        return (
            self.sh('svn info | grep "^Revision: "')
            .split(': ', 1)[1].strip())


    def log(self, n=None, template=None, **kwargs):
        return (
            self.sh(' '.join((
                'svn log',
                ('-l%n'%n) if n else '',
                ' '.join( ('--%s=%s' % (k,v)) for (k,v) in kwargs.items() )
                ))
            )
        )

    @cached_property
    def _last_commit(self):
        """

            $ svn log -l1
            ------------------------------------------------------------------------
            r25701 | bhendrix | 2010-08-02 12:14:25 -0500 (Mon, 02 Aug 2010) | 1 line

            added selection range traits to make it possible for users to replace selected text
            ------------------------------------------------------------------------

        .. note:: svn log references the svn server
        """
        op = self.sh('svn log -l1')
        data, rest = op.split('\n', 2)[1:]
        revno, user, datestr, lc = data.split(' | ', 3)
        desc = '\n'.join(rest.split('\n')[1:-2])
        revno = revno[1:]
        #lc = long(lc.rstrip(' line'))
        return datestr, (revno, user, None,  desc)

    @cached_property
    def __last_commit(self):
        """

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
        return self.log_iter().next()

    #@cached_property
    def search_upwards(self, fpath=None, repodirname='.svn', upwards={}):
        """
        Traverse filesystem upwards, searching for .svn directories
        with matching UUIDs

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
            checkpath = os.path.join(*path_comp[ 0 : -1 * n ])
            repodir = os.path.join(checkpath, repodirname)
            upw_uuid = upwards.get(repodir)
            if upw_uuid:
                if upw_uuid==uuid:
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
    #SvnRepository, # NOP'ing this functionality for now. requires net access.
]
REPO_PREFIXES=dict((r.prefix, r) for r in REPO_REGISTRY)
REPO_REGEX = (
    '|'.join('/%s' % r.prefix for r in REPO_REGISTRY) ).replace('.','\.')


def listdir_find_repos(where):
    stack = deque([(convert_path(where), '')])
    while stack:
        where, prefix = stack.pop()
        try:
            for name in sorted(os.listdir(where), reverse=True):
                fn = os.path.join(where, name)
                if os.path.isdir(fn):
                    if name in REPO_PREFIXES:
                        #yield name[1:], fn.rstrip(name)[:-1] # abspath
                        repo = REPO_PREFIXES[name](fn.rstrip(name)[:-1])
                        yield repo
                    stack.append( (fn, prefix + name + '/') )
        except OSError, e:
            if e.errno == errno.EACCES:
                log.error("Skipping: %s", e)
            else:
                raise


def find_find_repos(where, ignore_error=True):
    cmd=("find",
        " -O3 ",
        repr(where), #" .",
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

    for l in iter(p.stdout.readline,''):
        path = l.rstrip()
        _path, _prefix = os.path.dirname(path), os.path.basename(path)
        repo = REPO_PREFIXES.get(_prefix)
        if repo is None:
            log.error("repo for path %r and prefix %r is None" % (path, _prefix))
        if repo:
            yield repo(_path)
        #yield repo


try:
    from collections import OrderedDict as Dict
except ImportError, e:
    Dict = dict


def find_unique_repos(where):
    repos = Dict()
    path_uuids = Dict()
    log.debug("find_unique_repos(%r)" % where)
    for repo in find_find_repos(where):
        #log.debug(repo)
        repo2 = (hasattr(repo, 'search_upwards')
                and repo.search_upwards(upwards=path_uuids))
        if repo2:
            if repo2 == repo:
                continue
            else:
                repo = repo2

        if (repo.fpath not in repos):
            log.debug("%s | %s | %s" % (repo.prefix, repo.fpath, repo.unique_id))
            repos[repo.fpath] = repo
            yield repo


REPORT_TYPES=dict( (attr, getattr(Repository,"%s_report" % attr)) for attr in (
    "origin",
    "full",
    "pip",
    "status",
    "hgsub",
    "gitsubmodule",
    ) )
def do_repo_report(repos, report='full', output=sys.stdout, *args, **kwargs):
    for i, repo in enumerate(repos):
        log.debug( str( (i, repo.origin_report().next()) ) )
        try:
            if repo is not None:
                for l in REPORT_TYPES.get(report)(repo, *args, **kwargs):
                    print(l, file=output)
        except Exception, e:
            log.error(repo)
            log.error(report)
            log.error(e)
            raise

        yield repo


def do_tortoisehg_report(repos, output):
    """generate a thg-reporegistry.xml file from a list of repos and print
    to output
    """
    import operator
    try:
        from collections import OrderedDict as Dict
    except ImportError, e:
        Dict=dict
    import xml.etree.ElementTree as ET

    root = ET.Element('reporegistry')
    item = ET.SubElement(root, 'treeitem')

    group = ET.SubElement(item, 'group',
                attrib=Dict(
                    name='groupname'))
    import os

    def fullname_to_shortname(fullname):
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
    print('<?xml version="1.0" encoding="UTF-8"?>', file=output)
    print("<!-- autogenerated: %s -->" % "TODO", file=output)
    print(ET.dump(root), file=output)


import unittest
#class TestThese(unittest.TestCase):
    #def test_00_files(self):
    #    for f in list_files('.'):
    #        log.info(f)

    #def test_01_find_repos(self):
    #    for r in do_repo_report('.'):
    #        for f in r.lately():
    #            log.debug(f)


class TestBzr(unittest.TestCase):
    def test_bzr_logparse(self):
        s='''------------------------------------------------------------
revno: 377
tags: 0.8.99~alpha2
committer: Siegfried-Angel Gevatter Pujals <siegfried@gevatter.com>
branch nick: zeitgeist
timestamp: Fri 2012-01-27 16:39:16 +0100
message:
  Release 0.8.99~alpha2.
------------------------------------------------------------
revno: 376
committer: Siegfried-Angel Gevatter Pujals <siegfried@gevatter.com>
branch nick: bluebird
timestamp: Fri 2012-01-27 15:33:29 +0100
message:
  Update NEWS file.
------------------------------------------------------------
revno: 375 [merge]
committer: Siegfried-Angel Gevatter Pujals <siegfried@gevatter.com>
branch nick: bluebird
timestamp: Fri 2012-01-27 14:34:18 +0100
message:
  Implement find_storage_for_uri
'''

        records = itersplit(s, '-'*60)

        for r in records:
            print(r)
            print(list(BzrRepository._parselog(itersplit(r,'\n'))))


def main():
    """
    mainfunc
    """

    import optparse
    import logging

    prs = optparse.OptionParser(usage="./")

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
                    help='Report template'
                    )

    prs.add_option('-v', '--verbose',
                    dest='verbose',
                    action='store_true',)
    prs.add_option('-q', '--quiet',
                    dest='quiet',
                    action='store_true',)
    prs.add_option('-t', '--test',
                    dest='run_tests',
                    action='store_true',)

    (opts, args) = prs.parse_args()

    if not opts.quiet:
        _format=None
        _format="%(levelname)s\t%(message)s"
        #_format="%(message)s"
        logging.basicConfig(format=_format)

    log = logging.getLogger('repos')

    if opts.verbose:
        log.setLevel(logging.DEBUG)
    elif opts.quiet:
        log.setLevel(logging.ERROR)
    else:
        log.setLevel(logging.INFO)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        exit(unittest.main())

    if not opts.scan:
        opts.scan = ['.']

    if opts.scan:
        #if not opts.reports:
        #    opts.reports = ['pip']
        if opts.reports or opts.thg_report:
            opts.reports = [s.strip() for s in opts.reports]
            if 'thg' in opts.reports:
                opts.thg_report = True
                opts.reports.remove('thg')

            #repos = []
            #for _path in opts.scan:
            #    repos.extend(find_unique_repos(_path))

            from itertools import chain, imap
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
                report='pip'))

if __name__ == "__main__":
    main()
