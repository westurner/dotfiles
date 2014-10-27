#!/usr/bin/env python
# encoding: utf-8
"""
setup.py -- dotfiles

::
    python setup.py --help
    python setup.py --help-commands

"""
import errno
import glob
import logging
import os
import subprocess
import sys

from collections import deque
from fnmatch import fnmatchcase

import setuptools

from distutils.command.build import build as DistutilsBuildCommand
from distutils.util import convert_path
from distutils.text_file import TextFile

from setuptools import setup, find_packages

try:
    import z3c.recipe.tag
    z3c.recipe.tag
except ImportError:
    pass

SETUPPY_PATH = os.path.dirname(os.path.abspath(__file__)) or '.'


def read_version_txt():
    with open(os.path.join(SETUPPY_PATH, 'VERSION.txt')) as f:
        version = f.read().strip()
    return version

VERSION = read_version_txt()
APPNAME = 'dotfiles'

CONFIG = {}
DEBUG = CONFIG.get('debug', True)  # False # True

logging.basicConfig(
    format='%(asctime)s %(name)s %(levelname)-5s %(message)s')
log = logging.getLogger()

if DEBUG:
    log.setLevel(logging.DEBUG)
else:
    log.setLevel(logging.INFO)

SETUPPY_PATH = os.path.dirname(os.path.abspath(__file__)) or '.'
# log.debug('SETUPPY_PATH: %s' % SETUPPY_PATH)


DATA_DIRS = CONFIG['data_dirs'] = ['bin', 'etc', 'docs', 'requirements']
CONFIG['excludes'] = (
    '*.pyc',
    '*.pyo',
    '*.swp*',
    '.hgignore',
    '.hgsubs',
    '.netrwhist',
    '*~',
    '*.un~',
    '*.bak',
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
    '__pycache__',
)


def list_files(
        where='.',
        exclude=CONFIG['excludes'],
        exclude_directories=CONFIG['exclude_dirs'],
        show_ignored=False):
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
        except OSError as e:
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
            p = os.path.join(d, f)
            dirname = os.path.dirname(p)
            yield './%s' % dirname, (p,)


data_files = list(get_data_dirs())


def get_long_description(readme='README.rst', changelog='CHANGELOG.rst'):
    """
    Returns:
        str: README.rst and CHANGELOG.rst read into a string

    Expects README and CHANGELOG to include compatible headers
    """

    with open(os.path.join(SETUPPY_PATH, readme)) as f:
        README = f.read()
    with open(os.path.join(SETUPPY_PATH, changelog)) as f:
        CHANGELOG = f.read()
    return '\n\n'.join((README, CHANGELOG,))


def read_requirements_txt(path):
    """
    read only entries from requirements.txt in the form::

       pkg
       pkg==0.1.0
       pkg<=0.1.0
       pkg>=0.1.0

    this parser reads any non-comment, non -* line
    """
    requirements = []
    _path = os.path.join(SETUPPY_PATH, path)
    try:
        tf = TextFile(_path)
        requirements_txt = (x.lstrip() for x in tf.readlines())
        for line in requirements_txt:
            if not line.startswith('-'):
                requirements.append(line)
    finally:
        tf and tf.close()
    return requirements


def read_requirements_pip(path):
    import pip.req
    return list(
        (req.name, req.editable)
        for req in pip.req.parse_requirements(path))


# Extra requirement sets
dev_extras = read_requirements_txt('requirements/requirements-dev.txt')
testing_extras = read_requirements_txt('requirements/requirements-testing.txt')
docs_extras = read_requirements_txt('requirements/requirements-docs.txt')

extras_require = {
    "dev": dev_extras,
    "testing": testing_extras,
    "docs": docs_extras,
}


class RunCommand(setuptools.Command):
    user_options = []
    description = "<TODO>"

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        print(self.__class__.__name__)


# log.debug(extras_require)
class PyTestCommand(RunCommand):
    def run(self):
        cmd = [sys.executable,
               os.path.join(SETUPPY_PATH, 'runtests.py')]
        cmd.extend([
            os.path.join(SETUPPY_PATH, 'etc/ipython/ipython_config.py'),
        ])

        globp_pkg_src = os.path.join(SETUPPY_PATH, 'src/dotfiles/*.py')
        globp_pkg_src_ipython = os.path.join(SETUPPY_PATH, 'src/dotfiles/venv/*.py')
        cmd.extend(sorted(glob.glob(globp_pkg_src)))
        cmd.extend(sorted(glob.glob(globp_pkg_src_ipython)))

        globp_pkg_scripts = os.path.join(SETUPPY_PATH, 'scripts/*.py')
        cmd.extend(sorted(glob.glob(globp_pkg_scripts)))

        globp_pkg_bin = os.path.join(SETUPPY_PATH, 'bin/*')
        cmd.extend(glob.glob(globp_pkg_bin))

        cmdlist = list(cmd)
        for x in cmdlist:
            log.info(x)

        errno = subprocess.call(cmdlist)
        raise SystemExit(errno)


class DotfilesBuildCommand(DistutilsBuildCommand):
    """re-generate MANIFEST.in and build"""
    description = (
        "update hg manifest AND " + DistutilsBuildCommand.description)

    def run(self):
        generate_manifest_in_from_vcs()
        DistutilsBuildCommand.run(self)


class HgManifestCommand(RunCommand):
    """re-generate MANIFEST.in from $(hg manifest)"""
    description = __doc__

    def run(self):
        generate_manifest_in_from_hg()


class GitManifestCommand(RunCommand):
    """Generate MANIFEST.in from $(git ls-files)"""
    description = __doc__

    def run(self):
        generate_manifest_in_from_git()


def launch_hg_serve(path='.'):
    cmd = ["hg", "-R", path, "serve"]
    output = subprocess.call(cmd)
    return output


class HgServeCommand(RunCommand):
    """run hg serve"""
    description = __doc__

    def run(self):
        return launch_hg_serve(SETUPPY_PATH)


def launch_git_serve():
    cmd = ["git", "instaweb", "--httpd=webrick"]
    print("# Run the following command to stop the git instaweb server::")
    print("      git instaweb --httpd=webrick --stop")
    output = subprocess.call(cmd)
    return output


class GitServeCommand(RunCommand):
    """run hg serve"""
    description = __doc__

    def run(self):
        return launch_git_serve()


def find_vcs_repository():
    """
    Find the nearest .hg and .git repository roots,
    accoridn to the commandline tools
    evaluated with ``shell=True``.

    Returns:
        (vcs_name, repo_path): generator of tuples
    """
    try:
        cmd = r'''hg root'''
        hg_root = subprocess.check_output(cmd, shell=True)
        yield ('hg', hg_root)

        cmd = r'''git rev-parse --show-toplevel 2>/dev/null '''
        git_root = subprocess.check_output(cmd, shell=True)
        yield ('git', git_root)
    except subprocess.CalledProcessError:
        pass


def find_closest_repository(matches, relative_to):
    """
    Args:
        matches (iterable): iterable of (key, path) tuples
        relative_to (str): path from which to measure filesystem 'distance'
    Returns:
        (key, path): closest path relative to the given
    Raises:
        Exception: no repositories found
    """
    minimum_relpath = None
    key, match = None, None
    for _key, _match in matches:
        relpath = os.path.relpath(_match, relative_to)
        if (minimum_relpath is None or len(relpath) < len(minimum_relpath)):
            minimum_relpath = relpath
            key, match = _key, _match
    # if None in (key, match):
    #     raise Exception("no repositories found")
    return (key, match)


def generate_manifest_in_from_vcs():
    """
    detect .hg or .git and run the manifest command

    this .git repository may be nested within a .hg repository
    this .hg repository my be nested within a .git repository

    example::

        # (mkdir outer && cd outer && hg init)
        # (mkdir outer/inner && cd outer/inner && git init)

        cd /outer/inner
        here=/outer/inner

        hg_root=$(hg root)
        # /outer
        git_root=$(git rev-parse --show-toplevel)
        # /outer/inner

        os.path.relpath(git_root, here)
        os.path.relpath(hg_root, here)

    """
    relative_to = SETUPPY_PATH
    matches = find_vcs_repository()
    (key, path) = find_closest_repository(matches, relative_to)
    funcmap = {
        'hg': generate_manifest_in_from_hg,
        'git': generate_manifest_in_from_git,
    }
    generate_func = funcmap.get(key, NotImplementedError)
    return generate_func()


def generate_manifest_in_from_hg():
    """Generate MANIFEST.in from 'hg manifest'"""
    print("generating MANIFEST.in from 'hg manifest'")
    cmd = r'''hg manifest | sed 's/\(.*\)/include \1/g' > MANIFEST.in'''
    return subprocess.call(cmd, shell=True)


def generate_manifest_in_from_git():
    """Generate MANIFEST.in from 'git ls-files'"""
    cmd = r'''git ls-files | sed 's/\(.*\)/include \1/g' > MANIFEST.in'''
    return subprocess.call(cmd, shell=True)


setup(
    name=APPNAME,
    version=VERSION,
    description=APPNAME,
    long_description=get_long_description(),
    classifiers=[],
    keywords='dotfiles',
    author='Wes Turner',
    author_email='wes@wrd.nu',
    url='https://github.com/westurner/dotfiles',
    license='',
    packages=find_packages('src'),
    package_dir={'': 'src'},
    include_package_data=True,
    # package_data=package_data,
    data_files=data_files,
    zip_safe=False,
    # test_suite='nose.collector',
    # tests_require=testing_extras, # pip install -r requirements-testing.txt
    # install_requires=(always_install + testing_extras),
    install_requires=[],
    extras_require=extras_require,
    entry_points={
        'console_scripts':
            [
                'dotfiles=dotfiles.cli:main',
            ]
    },
    cmdclass={
        'test': PyTestCommand,
        'hg_manifest': HgManifestCommand,
        'git_manifest': GitManifestCommand,
        'hg_serve': HgServeCommand,
        'git_serve': GitServeCommand,
        'build': DotfilesBuildCommand,
    }
)
