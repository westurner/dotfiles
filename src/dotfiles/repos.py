#!/usr/bin/env python
# encoding: utf-8
"""Search for code repositories"""

import os
import errno
import logging
import subprocess
import datetime
from collections import deque
from distutils.util import convert_path

#logging.basicConfig()
log = logging.getLogger()

dtformat = lambda x: x.strftime('%Y-%m-%d %H:%M:%S %z')


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

    def __get__(self, obj, type=None):
        if obj is None:
            return self
        value = obj.__dict__.get(self.__name__, _missing)
        if value is _missing:
            value = self.func(obj)
            obj.__dict__[self.__name__] = value
        return value

class Repository(object):
    label = None
    prefix = None

    def __init__(self, fpath):
        self.fpath = fpath
        self.symlinks = []

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

    def branch(self):
        """
        :returns: str
        """
        pass

    def last_commit(self):
        """
        :returns: (datestr, (revid, author, branchinfo, commitmsg))
        """
        pass

    def log():
        """
        :returns: str
        """
        pass

    #def search_upwards():
    #    """ Implented for Repositories that store per-directory
    #    metadata """
    #    pass

    def report(self):
        log.info('')
        log.info('='*len(str(self)))
        log.info(self)
        log.info('='*len(str(self)))
        for l in self.remote_url.split('\n'):
            log.info(l)

        log.info("%s [%s]", self.last_commit, self)
        log.info('')
        if self.status:
            for l in self.status.split('\n'):
                log.info(l)
            log.info('')

        if hasattr(self, 'log_iter'):
            for r in self.log_iter():
                log.info(r)

    def __unicode__(self):
        return '<%s: %s>' % (self.label, self.fpath)

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
        cmd=("find . -type l -printf '%p -> %l\n'")
        return self.sh(cmd)

    def lately(self, count=15):
        excludes='|'.join(('*.pyc','*.swp','*.bak','*~'))
        cmd=('''find . -printf "%%T@ %%p\\n" '''
             '''| egrep -v '%s' '''
             '''| sort -n '''
             '''| tail -n %d''') % (excludes, count)
        op = self.sh(cmd)
        for l in op.split('\n'):
            l = l.strip()
            if not l:
                continue
            mtime, fname = l.split(' ',1)
            mtime = datetime.datetime.fromtimestamp(float(mtime))
            mtimestr = dtformat(mtime)
            yield mtimestr, fname


    def sh(self, cmd, ignore_error=False, cwd=None, *args, **kwargs):
        kwargs.update({
                'shell': True,
                'cwd': cwd or self.fpath,
                'stderr': subprocess.STDOUT,
                'stdout': subprocess.PIPE})
        p = subprocess.Popen(cmd, **kwargs)
        p_stdout = p.communicate()[0]
        if p.returncode and not ignore_error:
            raise Exception("Subprocess return code: %d\n%r\n%r" % (
                p.returncode, cmd, p_stdout))

        return p_stdout #.rstrip()

    def to_dict(self):
        return self.__dict__

class MercurialRepository(Repository):
    label='hg'
    prefix='.hg'

    def unique_id(self):
        return self.fpath #self.sh('hg id -r 0').rstrip()

    @cached_property
    def status(self):
        return self.sh('hg status').rstrip()

    @cached_property
    def remote_url(self):
        return self.sh('hg showconfig | grep paths.default',
                ignore_error=True).strip()

    @cached_property
    def diff(self):
        return self.sh('hg diff -g')

    @cached_property
    def branch(self):
        return self.sh('hg branch')

    def log(self):
        return self.sh('hg log')

    def loggraph(self):
        return self.sh('hg log --graph')

    @cached_property
    def last_commit(self):
        return self.log_iter(maxentries=1).next()

    def log_iter(self, maxentries=None):
        op = self.sh((
            "hg log %s --template "
            "'{date|isodatesec} |.| {node|short} |.| {author} |.| {desc|firstline}\n'"
                % (maxentries and ('-l%d' % maxentries) or '')),
            ignore_error=True
            )
        if not op:
            return
        for l in op.split('\n'):
            l = l.rstrip()
            if not l:
                continue
            datestr, noderev, author, desc = l.split(' |.| ')
            yield datestr, (noderev, author, desc)
        return

    def unpushed(self):
        raise NotImplementedError()

    def serve(self):
        return self.sh('hg serve')

class GitRepository(Repository):
    label='git'
    prefix='.git'

    def unique_id(self):
        return self.fpath

    @cached_property
    def status(self):
        return self.sh('git status -s')

    @cached_property
    def remote_url(self):
        return self.sh('git config -l | grep "url"',
                ignore_error=True).strip() #.split('=',1)[1]# *

    def diff(self):
        return self.sh('git diff')

    @cached_property
    def branch(self):
        return self.sh('git branch')

    def log(self):
        return self.sh('git log')

    def loggraph(self):
        return self.sh('git log --graph')

    @cached_property
    def last_commit(self):
        return self.log_iter(maxentries=1).next()

    def log_iter(self, maxentries=None):
        rows = self.sh((
            'git log %s '
            '--format="%%ai|.|%%h|.|%%an|.|%%d|.|%%s|..|"')
            % (maxentries and ('-n%d ' % maxentries) or ''))
        if not rows:
            return
        for row in rows.split('|..|'):
            row = row.strip()
            if not row:
                continue
            datestr, noderev, author, branches, desc = row.split('|.|')
            branches = branches.strip()[1:-1]
            yield datestr, (noderev, author, branches, desc)
        return

    def unpushed(self):
        return self.sh("git log master --not --remotes='*/master'")

    def serve(self):
        return self.sh("git serve")


class BzrRepository(Repository):
    label='bzr'
    prefix='.bzr'

    def unique_id(self):
        return self.fpath

    @cached_property
    def status(self):
        return self.sh('bzr status')

    @cached_property
    def remote_url(self):
        return self.sh('bzr info | grep parent',
                ignore_error=True)

    def diff(self):
        return self.sh('bzr diff')

    @cached_property
    def branch(self):
        return self.sh('bzr nick')

    def log(self):
        return self.sh('bzr log')

    @cached_property
    def last_commit(self):
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
        op = self.sh('bzr log -l1')
        blank, noderev, committer, branch, datestr, messagehdr, message = (
                op.split('\n',6))
        noderev = noderev.split(': ',1)[1]
        committer = committer.split(': ',1)[1]
        branchnick = branch.split(': ',1)[1]
        datestr = datestr.split(': ',1)[1][4:]
        message = message.strip()
        return datestr, (noderev, committer, branchnick, message)


class SvnRepository(Repository):
    label='svn'
    prefix='.svn'

    @cached_property
    def unique_id(self):
        cmdo = self.sh('svn info | grep "^Repository UUID"',
                ignore_error=True)
        if cmdo:
            return cmdo.split(': ',1)[1].rstrip()
        return None

    @cached_property
    def status(self):
        return self.sh('svn status')

    @cached_property
    def remote_url(self):
        return (
            self.sh('svn info | grep "^Repository Root:"')
            .split(': ',1)[1]).strip()

    def diff(self):
        return self.sh('svn diff')

    def log(self):
        return self.sh('svn log')

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
        data, rest = op.split('\n',2)[1:]
        revno, user, datestr, lc = data.split(' | ', 3)
        desc = '\n'.join(rest.split('\n')[1:-2])
        revno = revno[1:]
        #lc = long(lc.rstrip(' line'))
        return datestr, (revno, user, None,  desc)

    @cached_property
    def last_commit(self):
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
        author = author.split(': ',1)[1].strip()
        rev = rev.split(': ',1)[1].strip()
        datestr = datestr.split(': ',1)[1].split('(',1)[0].strip()
        return datestr, (rev, author, None, None)

    @cached_property
    def search_upwards(self, fpath=None, repodirname='.svn'):
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

        .. note:: **WARNING** SVN vagaries be damned ... ~transitivity

        """
        fpath = fpath or self.fpath
        uuid = self.unique_id()
        last_path = None
        path_comp = fpath.split(os.path.sep)
        # [0:-1], [0:-2], [0:-1*len(path_comp)]
        for n in xrange(1, len(path_comp)-1):
            checkpath = os.path.join(*path_comp[ 0 : -1 * n ])
            repodir = os.path.join(checkpath, repodirname)
            if os.path.exists(repodir):
                other = SvnRepository(checkpath)
                other_uuid = other.unique_id()
                # TODO: match on REVISION too
                if other_uuid != uuid:
                    break
                else:
                    last_path = other

        return last_path or self


REPO_REGISTRY = [
    MercurialRepository,
    GitRepository,
    BzrRepository,
    SvnRepository,
]
REPO_PREFIXES=dict((r.prefix, r) for r in REPO_REGISTRY)

def find_repos(where):
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

def find_unique_repos(where):
    repos = {}
    for repo in find_repos(where):
        #log.debug(repo)
        if hasattr(repo, 'search_upwards'):
            repo = repo.search_upwards()
        if repo.fpath not in repos:
            repos[repo.fpath] = repo
            yield repo


def do_repo_report(path='.'):
    for i,r in enumerate(find_unique_repos(path)):
        log.debug(i )
        try:
            r.report()
            yield r
        except Exception, e:
            [log.error(l) for l in str(e).split('\n')]
            raise

import unittest
class TestThese(unittest.TestCase):
    #def test_00_files(self):
    #    for f in list_files('.'):
    #        log.info(f)

    def test_01_find_repos(self):
        for r in do_repo_report('.'):
            for f in r.lately():
                log.debug(f)


def main():
    """
    mainfunc
    """

    import optparse
    import logging

    prs = optparse.OptionParser(usage="./")

    prs.add_option('-s', '--scan',
                    dest='scan',
                    action='store',
                    help='Path to scan')

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
        logging.basicConfig(format="%(levelname)s\t%(message)s")

    if opts.verbose:
        log.setLevel(logging.DEBUG)
    else:
        log.setLevel(logging.INFO)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        exit(unittest.main())

    if opts.scan:
        repos = list(do_repo_report(opts.scan))
        repos

if __name__ == "__main__":
    main()

