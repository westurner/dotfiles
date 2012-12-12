==========
dotfiles
==========

About
======
Configuration files
---------------------

* Bash shell
* ZSH shell
* Mercurial
* Python
* Setuptools
* IPython
* Pip
* PDB
* Ruby Gems
* Htop
* Gnome
* Compiz
* Vimperator


Python Modules
---------------
In ``src/dotfiles/dotfiles``:

deb_deps.py
    Work with debian dependencies

deb_search.py
    Search for a debian package

build_docs.py
    Build sets of sphinx documentation projects

greppaths.py
    Grep

lsof.py
    TODO

mactool.py
    MAC address tool

optimizepath.py
    Work with PATHS TODO

passwordstrength.py
    Gauge password strength

pipls.py
    Walk and enumerate a pip requirements file

pycut.py
    Similar to coreutils' ``cut``: split line-based files into fields

py_index.py
    TODO

pyline.py
    Similar to ``sed`` and ``awk``:
    Execute python expressions over line-based filse

pyren.py
    Skeleton regex file rename script

repos.py
    Find repositories and execute and scrape shell commands for
    ``hg``, ``bzr``, ``git``, and ``svn``

usrlog.py
    Search through ``.usrlog`` files


Scripts
--------
In ``scripts``

bashmarks_to_nerdtree.sh
    Convert ``bashmarks`` shortcuts to ``NERDTreeBookmarks`` format

gittagstohgtags.sh
    Convert ``git`` tags to ``hgtags`` format

pulse.sh
    Setup, configure, start, stop, and restart ``pulseaudio``

setup_mathjax.py
    Setup ``MathJax``

setup_pandas_notebook_deb.sh
    Setup ``IPython Notebook``, ``Scipy``, ``Numpy``, ``Pandas``
    with Ubuntu packages and pip

setup_pandas_notebook.sh
    Setup ``Brew``, ``IPython Notebook``, ``scipy``, ``numpy``,
    and pandas on OSX

setup_scipy_deb.py
    Install and symlink ``scipy``, ``numpy``, and ``matplotlib`` from ``apt``

setup.py
---------
``setup.py`` imports from ``pavement.py``, which requires ``paver``.


Install
========

Manually, from Github or Bitbucket::

    hg clone https://github.com/westurner/dotfiles
    git clone https://bitbucket.org/westurner/dotfiles

    cd dotfiles
    python setup.py help
    python setup.py test

    python setup.py develop
    # or
    python setup.py install


pip
----
::

    pip install -e git+https://github.com/westurner/dotfiles
    # or
    pip install -e hg+https://bitbucket.org/westurner/dotfiles
