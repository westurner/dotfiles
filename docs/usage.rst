Usage
=======
List commands::

    python setup.py --help
    python setup.py --help-commands
    # bash scripts/bootstrap_dotfiles.sh -h
    # less_ Makefile
    # make help
    # make <tab>
    # make vim_help
    # vim: :ListMappings

Install dev, docs. testing, and suggests from pip requirements files::

    pip install -r ./requirements-all.txt
    # make pip_install_requirements_all 
    


bootstrap_dotfiles.sh
-----------------------

``bash scripts/bootstrap_dotfiles.sh``:

.. program-output:: bash ../scripts/bootstrap_dotfiles.sh -h


Makefile
---------
``make help``:

.. program-output:: cd .. && make help
   :shell:


Vim
-----
``make -C ../etc/vim vim_help``:

.. program-output:: test -f ../etc/vim/Makefile && cd .. && make vim_help
   :shell:



ipython
----------
**ip_session**
   generate a new ipython notebook sessionkey

**ipnb**
   Start ipython notebook with notebooks from ${_SRC}/notebooks

**ipqt**
   Start IPython Qt console


Scripts
---------
In ``scripts/``

**bashmarks_to_nerdtree.sh**
   Convert `bashmarks` shortcut variables
   starting with ``DIR_`` to `NERDTreeBookmarks <NERDTree>`_ format::

       l
       ./bashmarks_to_nerdtree.sh | tee ~/.NERDTreeBookmarks

**gittagstohgtags.sh**
   Convert ``git`` tags to ``hgtags`` format

**pulse.sh**
   Setup, configure, start, stop, and restart ``pulseaudio``

**setup_mathjax.py**
   Setup ``MathJax``

**setup_pandas_notebook_deb.sh**
   Setup ``IPython Notebook``, ``Scipy``, ``Numpy``, ``Pandas``
   with Ubuntu packages and pip

**setup_pandas_notebook.sh**
   Setup ``Brew``, ``IPython Notebook``, ``scipy``, ``numpy``,
   and pandas on OSX

**setup_scipy_deb.py**
   Install and symlink ``scipy``, ``numpy``, and ``matplotlib`` from ``apt``


**deb_deps.py**
   Work with debian dependencies

**deb_search.py**
   Search for a debian package

**build_docs.py**
   Build sets of sphinx documentation projects

**greppaths.py**
   Grep

**lsof.py**
   lsof subprocess wrapper

**mactool.py**
   MAC address tool

**optimizepath.py**
   Work with PATH as an ordered set

**passwordstrength.py**
   Gauge password strength

**pipls.py**
   Walk and enumerate a pip requirements file

**pycut.py**
   Similar to ``coreutils``' ``cut``: split line-based files into fields

**py_index.py**
   Create a python package index HTML file for a directory of
   packages. (``.egg``, ``.zip``, ``.tar.gz``, ``tgz``)

**pyline.py**
   Similar to ``sed`` and ``awk``:
   Execute python expressions over line-based files.

   See: https://github.com/westurner/pyline

**pyren.py**
   Skeleton regex file rename script

**repos.py**
   Wrap version control system commandline interfaces

   * Find vcs repositories
   * Wrap shell commands
   * Yield event tuples from repositories in
     `hg <Mercurial>`_, `bzr`, `git`_, ``svn``

**usrlog.py**
   Search through ``.usrlog`` files

