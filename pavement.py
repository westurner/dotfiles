import sets
from paver.easy import *
#from paver.easy import options, Bunch, task, tasks, needs, sh
from paver.path import path
from paver.setuputils import setup
from paver.setuputils import find_package_data
from setuptools import find_packages
#import os
try:
    import z3c.recipe.tag
except ImportError:
    pass

#here = path.abspath(os.path.dirname(__file__))
here = path(__file__).dirname().abspath()
README = open(here / path('README.rst')).read()
CHANGELOG = open(here / path('CHANGELOG.rst')).read()


version = '0.01'

install_requires = [
    # List your project dependencies here.
    # For more details, see:
    # http://packages.python.org/distribute/setuptools.html#declaring-dependencies
]


setup(
    name='dotfiles',
    version=version,
    description="dotfiles",
    long_description=README + '\n\n' + CHANGELOG,
    classifiers=[
      # Get strings from http://pypi.python.org/pypi?%3Aaction=list_classifiers
    ],
    keywords='',
    author='',
    author_email='',
    url='',
    license='',
    packages=find_packages('src'),
    package_dir = {'': 'src'},
    include_package_data=True,
    package_data=find_package_data(only_in_packages=False),
    zip_safe=False,
    test_suite='nose.collector',
    install_requires=install_requires,
    entry_points={
        'console_scripts':
            ['dotfiles=dotfiles:main']
    }
)

options(
    minilib=Bunch(
        extra_files=[
            'doctools',
            'virtual'
            ]
        ),
    virtualenv=Bunch(
        script_name='bootstrap.py',
        dest_dir='./env/',
        install_paver=True,
        #no_site_packages=True,
        packages_to_install=[
            "virtualenv>=1.3.3",
            #"github-tools>=0.1.6",
            "nose>=0.11.1",
            'z3c.recipe.tag>=0.4.0'
            ]
        ),
    sphinx=Bunch(
        docroot='docs',
        builddir='build',
        sourcedir='source',
        ),
    )

@task
def pip_requirements():
    """Create a pip requirement file."""
    req = sets.Set()
    for d in (
        options.virtualenv.packages_to_install
        + options.setup.get('install_requires', [])
        ):
        req.add(d+'\n')

    f = open('dev-requirements.txt', 'w')
    try:
        f.writelines(req)
    finally:
        f.close()

@task
def manifest():
    """Generate a Manifest from 'hg manifest'"""
    manifest_in = open('MANIFEST.in', 'w')
    try:
        includes = (
            "include %s\n" % f
            for f in sh('hg manifest', capture=True, cwd=here).splitlines()
            if (not path(f).basename().startswith('.')
                and f != 'docs/build/html')
            )
        manifest_in.writelines(includes)
    finally:
        manifest_in.close()

@task
@needs('pip_requirements', 'generate_setup', 'manifest', 'minilib',
    'setuptools.command.sdist')
def sdist():
    """Overrides sdist to make sure that our setup.py is generated."""

@task
@needs("build_sphinx")
def docs():
    """Builds docs and launches to index page"""
    html_index = here / 'build' / 'sphinx' / 'html' / 'index.html'
    sh("sensible-browser %s" % html_index)


ACTIONS = {
    'NULL': lambda x,y : True,
    'SYMLINK': lambda x, y: path.symlink(x,y),
    'MKDIR': lambda x, y: path.mkdir(y),
    'EXISTS': lambda x, y: y / 0 * 1,
    'UNK': lambda x, y: y / 0 * 2,
}

@task
def link():
    """Create symlinks for files"""
    src = here / 'etc'
    dest = path('~/').expanduser() # TODO: $HOME

    def path_transform(p, dest):
        # make path p relative to dest
        print p, dest

    symlinks = _links(src, lambda x: path_transform(x, dest))
    dry = tasks.environment.dry_run
    if dry:
        for link in symlinks:
            print link
    else:
        for move, src_path, dest_path in symlinks:
            print move, src_path, dest_path
            movefunc = _map[move]
            try:
                movefunc(src_path, dest_path)
            except Exception:
                raise


def _links(src, path_transform):
    """Iterate over symlink sync map"""
    for p in path.walk(src):
        dest_path = path_transform(src)
        if p.is_dir():
            if not dest_path.exists():
                yield ('MKDIR', p, dest_path)
                continue
            else:
                yield ('NULL', p, dest_path) #
                continue
        elif p.is_file():
            if not dest_path.exists():
                yield ('SYMLINK', p, dest_path)
                continue
            else:
                yield ('EXISTS', p, dest_path) # TODO: compare
                continue
        else:
            yield (UNK, p, dest_path)
    return

#@task
#@needs("z3c.recipe.tag.tags")
def _tags():
    """Build ctags"""
    from z3c.recipe.tag import build_tags
    languages="JavaScript,Python,Shell"
    args = [languages, "--ctags-vi", ] # or "--ctags-emacs"
    build_tags(args)
