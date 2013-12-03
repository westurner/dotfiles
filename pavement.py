#!/usr/bin/env python
# encoding: utf-8
"""
pavement setup script

see:
    - ``python setup.py help``
    - ``paver help``
"""
import os
import errno
import logging
from paver.easy import * # options, Bunch, task, tasks, needs, sh
from paver.tasks import environment as env #env.dry_run
from paver.path import path
from paver.setuputils import setup
from paver.setuputils import find_package_data
from setuptools import find_packages
from fnmatch import fnmatchcase
from distutils.util import convert_path
from collections import deque

try:
    from paver.virtual import bootstrap; bootstrap
    import paver.doctools; paver.doctools
    import z3c.recipe.tag; z3c.recipe.tag
except ImportError:
    pass

VERSION = 'v0.0.02'
APPNAME = 'dotfiles'

CONFIG={}
DATA_DIRS = CONFIG['data_dirs'] = ['bin','etc','docs']
CONFIG['excludes'] = (
    '*.pyc',
    '*.pyo',
    '*.swp*',
    '.hgignore',
    '.hgsubs',
    '.netrwhist',
    '*~',
    '*.bak',
    'MANIFEST.in', #
)
CONFIG['exclude_dirs'] = (
    '.git',
    '.hg',
    '.bzr',
    '.svn',
    'CVS',
    '_darcs',
    './build',
    './dist',
    'EGG-INFO',
    '*.egg-info',
)
DEBUG = CONFIG['debug'] = env.debug # False # True

logging.basicConfig(
    format='%(asctime)s %(name)s %(levelname)-5s %(message)s')
log = logging.getLogger('setup')

if DEBUG:
    log.setLevel(logging.DEBUG)
else:
    log.setLevel(logging.INFO)

# requires path.py (...)
here = path(__file__).dirname() or path('.')#.abspath()
log.debug('Here: %s' % here)


def get_package_data(dirs=DATA_DIRS, exclude=CONFIG['excludes']):
    """Generate a manifest from 'hg manifest'"""
    return [
        (d, sorted(find_package_data( here / d,
                                only_in_packages=False,
                                exclude=exclude,
                                show_ignored=bool(DEBUG),
                                )['']) )
        for d in dirs]
    #
    # .. note: about `paver.setuputils.find_package_data`
    #

def get_data_files(dirs=DATA_DIRS, exclude=CONFIG['excludes']):
    """ flat generator of package_data paths in dirs """
    for _path, fileset in get_package_data(dirs, exclude):
        basepath = path(_path) #.relpathto(here) #
        for f in fileset:
            yield basepath / f

def list_files(
    where='.',
    exclude=CONFIG['excludes'],
    exclude_directories=CONFIG['exclude_dirs'],
    show_ignored=True):
    """
    Return an iterator of ``files`` below ``where`` that
    don't match anything in ``exclude``.

    Directories matching any pattern in ``exclude_directories`` will
    be ignored; by default directories with leading ``.``, ``CVS``,
    and ``_darcs`` will be ignored.

    If ``show_ignored`` is true, then all the files that aren't
    included in package data are logged at DEBUG level

    Note patterns use wildcards, or can be exact paths (including
    leading ``./``), and all searching is case-insensitive.

    This function is derived from ``find_package_data`` by Ian Bicking.
    """
    stack = deque([(convert_path(where), '')])
    while stack:
        where, prefix = stack.pop()
        try:
            for name in sorted(os.listdir(where), reverse=True):
                fn = os.path.join(where, name)
                bad_name = False
                if os.path.isdir(fn):
                    for pattern in exclude_directories:
                        if (fnmatchcase(name, pattern)
                            or fn.lower() == pattern.lower()):
                            bad_name = True
                            if show_ignored:
                                log.debug(
                                    "Skipping dir %s [[ pattern %s ]]",
                                    fn, pattern)
                    if not bad_name:
                        stack.append((fn, prefix + name + '/'))
                else:
                    for pattern in exclude:
                        if (fnmatchcase(name, pattern)
                            or fn.lower() == pattern.lower()):
                            bad_name = True
                            if show_ignored:
                                log.debug(
                                    "Skipping file %s [[ pattern %s ]]",
                                    fn, pattern)
                            continue
                    if not bad_name:
                        yield prefix+name
        except OSError, e:
            if e.errno == errno.EACCES:
                log.error("Skipping %s", name)
    return

def get_data_dirs(dirs=DATA_DIRS):
    """

    mkdir ./a
    mkdir ./a/b
    mkdir ./a/b/c
    touch ./a/b/c/1
    touch ./a/file
    touch ./a/b/c/2

    >> get_data_dirs('.')
    << (
    ('./a/b/c', ('a/b/c/1',) ), # ..
    ('./a', ('a/file',) ),
    ('./a/b/c', ('2',) ),
    #...,
    )

    """
    # from itertools import groupby
    # groupby(func, lambda x: x[0])
    for d in dirs:
        for f in list_files(d):
            p = os.path.join(d,f)
            dirname = os.path.dirname(p)
            yield './%s' % dirname, ( p,  )

package_data = dict(
    (k, sorted(v)) for k,v in
        find_package_data('.',
            only_in_packages=False,
            exclude=CONFIG['excludes']).iteritems(),
)
data_files = list(get_data_dirs())

#package_data = dict( (p,package_data[p]) for p in package_data
#                        if p in DATA_DIRS)
#from pprint import pprint
#log.debug(pprint(package_data))
#log.debug(pprint(data_files))

def get_long_description():
    README = open(here / path('README.rst')).read()
    CHANGELOG = open(here / path('CHANGELOG.rst')).read()
    return '\n\n'.join((README, CHANGELOG,))

def read_requirements_txt(path):
    requirements = []
    with open(here / path) as f:
        requirements = [x.strip() for x in f.readlines()]
    return requirements

# Extra requirement sets
dev_extras = read_requirements_txt('requirements/dev.txt')
testing_extras = read_requirements_txt('requirements/testing.txt')
docs_extras = read_requirements_txt('requirements/docs.txt')

setup(
    name=APPNAME,
    version=VERSION,
    description=APPNAME,
    long_description=get_long_description(),
    classifiers=[],
    keywords='',
    author='',
    author_email='',
    url='',
    license='',
    packages=find_packages('src'),
    package_dir = {'': 'src'},
    include_package_data=True,
    #package_data=package_data,
    data_files=data_files,
    zip_safe=False,
    test_suite='nose.collector',
    tests_require=testing_extras,
    #install_requires=(always_install + testing_extras),
    extras_require={
        "dev": dev_extras,
        "testing": testing_extras,
        "docs": docs_extras,
    },
    entry_points={
        'console_scripts':
            [
                'dotfiles=dotfiles:main',
                'repo=dotfiles.repos:main',
                'pyline=dotfiles.pyline:main',
                'greppaths=dotfiles.greppaths:main',
                'optimizepath=dotfiles.optimizepath:main',
                'deb_search=dotfiles.deb_search:main',
                'deb_deps=dotfiles.deb_deps:main',
                'py_index=dotfiles.py_index:main',
                'pipls=dotfiles.pipls:main',
                'mactool=dotfiles.mactool:main',
                'pylsof=dotfiles.lsof:main',
                'pyren=dotfiles.pyren:main',
                'pycut=dotfiles.pycut:main',
                'pwstrength=dotfiles.passwordstrength:main'
            ]
    }
)



from itertools import chain
options(
    minilib=Bunch(
        extra_files=[
            'doctools',
            'virtual'
            ]
        ),
    virtualenv=Bunch(
        script_name='bootstrap.py',
        dest_dir=(
            os.environ.get('VIRTUAL_ENV')
            or (path(os.environ.get('WORKON_HOME','~')).expanduser() / APPNAME)
        ),
        install_paver=True,
        #no_site_packages=True,
        packages_to_install=chain(
            dev_extras,
            testing_extras,
            docs_extras,
            )
        ),
    sphinx=Bunch(
        docroot='docs',
        builddir='build',
        sourcedir='src',
        ),
    serve_docs=Bunch(
        host='127.0.0.1',
        port=8042,
        ),

    serve_dist=Bunch(
        host='127.0.0.1',
        port=8050,
        ),
)

def ordered_uniq(*iterables):
    """
    filter uniques from iterables
    """
    d={}
    for p in chain(*iterables):
        if p not in d:
            yield p
            d[p]=True
            continue
        else:
            log.debug("dupe: %s", p)


def iter_named_chain(chains):
    """ flatten an iterable of ('name', iterable) tuples """
    for pname, piter in chains:
        log.debug("Reading %r chain", pname)
        for l in piter:
            log.debug(l)
            yield l

@task
def pip_requirements():
    """Create a pip requirement file."""
    packages = ordered_uniq(
                    options.virtualenv.packages_to_install,
                    options.setup.get('install_requires', []))
    f = open('dev-requirements.txt', 'w')
    try:
        f.writelines('\n'.join(packages))
    finally:
        f.close()


@task
def freeze():
    """pip freeze"""
    print sh('pip freeze', cwd=here, capture=True)


def hg_manifest(cwd):
    basepath = path(cwd or here)
    hgpath = basepath / '.hg'
    if not hgpath.exists():
        log.error("no .hg repo at %r", hgpath)
        return
    for f in (f for f in
        sh('hg manifest', capture=True, cwd=basepath).splitlines()
            if (not path(f).basename().startswith('.')
                and f != 'docs/build/html')
        ):
        yield f #basepath, f
    return


@task
def manifest():
    """Generate a Manifest from 'hg manifest'"""
    #from itertools import imap, chain
    filesrcs = [('hg manifest', hg_manifest(here)),
                ('data_files',  get_data_files()) ]

    manifest_in = file('MANIFEST.in', 'w')
    try:
        for l in ordered_uniq(iter_named_chain(filesrcs)):
            manifest_in.write("include ")
            manifest_in.write(l)
            manifest_in.write('\n')
    finally:
        manifest_in.close()


@task
@needs('pip_requirements', 'generate_setup',  'manifest', 'minilib',
    'setuptools.command.sdist')
def sdist():
    """Overrides sdist to make sure that our setup.py is generated."""


@task
@needs("doctools.html")
def docs():
    """Builds docs and launches to index page"""
    html_index = (here / 'docs' / 'build' / 'html' / 'index.html').abspath()
    sh("sensible-browser %s" % html_index)


#@task
#@needs("z3c.recipe.tag.tags")
def _tags():
    """Build ctags"""
    from z3c.recipe.tag import build_tags
    languages="JavaScript,Python,Shell"
    args = [languages, "--ctags-vi", ] # or "--ctags-emacs"
    build_tags(args)


@task
def register():
    """ """

@task
@needs('distutils.command.clean', )
def clean():
    (here / 'MANIFEST.in').remove()
    #(here / 'dist').rmtree() # *
    (here / 'build').rmtree()
    (here / 'src' / ('%s.egg-info' % APPNAME)).rmtree()


def _serve(name, path, host='127.0.0.1', port=8000, opts=None):
    import SimpleHTTPServer
    import SocketServer

    HOST=opts and getattr(opts, 'host', host) or host
    PORT=opts and getattr(opts, 'port', port) or port
    VSTR='/'.join((APPNAME, VERSION))

    log = logging.getLogger('-'.join(("serve", name,)))
    log.setLevel(logging.INFO)

    path = str(path)
    os.chdir(path)
    log.info("Serving path: %s", path)

    Handler = SimpleHTTPServer.SimpleHTTPRequestHandler
    Handler.version_string = lambda x: VSTR
    Handler.log_message = lambda self, format, *args: (
            log.info("%s - - %s",
                self.client_address[:2], # address_string(), # Skip DNS
                format%args))
    Handler.log_request = lambda self, code='-', size='-': (
            self.log_message("%s %s %s",
                str(code), self.requestline, str(size)))
    Handler.log_error = lambda self, format, *args: (
            log.error("%s - - %s",
                self.client_address[:2], # address_string(), # Skip DNS
                format%args))

    server = SocketServer.TCPServer((HOST, PORT), Handler)

    log.info("serving at http://%s:%d", HOST, PORT)
    server.serve_forever()


@task
#@needs('docs')
@cmdopts([
    ('host=','-sdocsh', 'Hostname'),
    ('port=','-sdocsp', 'Port' ),
])
def serve_docs():
    """Serve docs/build/html"""
    _serve('docs',
            (here / 'docs' / 'build' / 'html').abspath(),
            opts=options.serve_docs)

@task
@cmdopts([
    ('host=','-sdisth', 'Hostname'),
    ('port=','-sdistp', 'Port' ),
])
def serve_dist():
    """Serve dist/"""
    _serve('dist',
            (here / 'dist').abspath(),
            opts=options.serve_dist)


from distutils.file_util import copy_file
def _copy_file(src, dst,
                dont_clobber=True,
                update=False,
                link='sym',
                **kwargs):
    src = path(src)
    dst = path(dst)
    if dst.exists():
        # todo: compare
        if dont_clobber:
            log.warn("backing up %s to %s.bkp", dst, dst)
            dst.copy("%s.bkp" % dst) # TODO:
            #dst.rm()
        else:
            log.warn("clobbering %s", dst)
        #(dest_name, copied) = (
    return copy_file(str(src), str(dst), link='sym', **kwargs)


ACTIONS = {
    'NULL': lambda x,y : True,
    'SYMLINK': lambda x, y: copy_file(x, y, update=True, link='sym'),
    'MKDIR': lambda x, y: path.mkdir(y),
    'EXISTS': lambda x, y: y / 0 * 1,
    'UNK': lambda x, y: y / 0 * 2,
}

@task
def link():
    """Create symlinks for files"""
    src = here / 'etc'
    # prefix
    dest = path('~/').expanduser() # TODO: $HOME

    def path_transform(p, dest):
        # make path p relative to dest
        print p.relpathto(here) #, dest
        # TODO
        return p

    #symlinks = _links(src, lambda x: path_transform(x, dest))
    symlinks = (path_transform(x, dest) for x in list_files(src))

    if env.dry_run:
        for link in symlinks:
            log.info(link)
    else:
        for move, src_path, dest_path in symlinks:
            log.info("%s, %s, %s", move, src_path, dest_path)
            try:
                movefunc = _map[move]
                movefunc(src_path, dest_path)
            except:
                raise


def _links(src, path_transform):
    """Iterate over symlink sync map

    .. note: `python setup.py install --prefix`

    """
    for p in path.walk(src):
        dest_path = path_transform(src)
        if p.isdir():
            if not dest_path.exists():
                yield ('MKDIR', p, dest_path)
                continue
            else:
                yield ('NULL', p, dest_path) #
                continue
        elif p.isfile():
            if not dest_path.exists():
                yield ('SYMLINK', p, dest_path)
                continue
            else:
                yield ('EXISTS', p, dest_path) # TODO: compare
                continue
        else:
            yield (UNK, p, dest_path)
    return


# TODO
# def pkgs_to_local_dir():
#     pass
# def pkgs_to_index(pkgdir, indexdir):
#     path=p
#     pkgs_to_local_dir(path)
#     buildindex.py(pkgdir, indexdir)
#     pass
# def serve_pkg_index(self):
#     blocked=False
#     while not blocked:
#       port = (math.random()*(65536-1024)+1024
#       simplehttpserver.()
# def serve_repository(self):
#     hg serve
#     git serve

