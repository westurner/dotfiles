
dotfiles
+++++++++++
**Bash scripts**, **Python scripts**, and **configuration files**
for working with projects on \*nix platforms in Bash, ZSH, Ruby, and Python.

.. contents:: dotfiles


Objective
===========
* Minimize error by standardizing common workflows and processes

::

    wget https://raw.githubusercontent.com/westurner/dotfiles/master/scripts/bootstrap_dotfiles.sh
    bash ./bootstrap_dotfiles.sh -h
    bash ./bootstrap_dotfiles.sh -I  # install
    bash ./bootstrap_dotfiles.sh -U  # upgrade


Installation
==============

Create a virtualenvwrapper virtualenv
---------------------------------------

Install **virtualenvwrapper** (with pip)::

    pip install --upgrade --user pip virtualenv virtualenvwrapper
    source $(HOME)/.local/bin/virtualenvwrapper.sh 

(or) Install **virtualenvwrapper** (with apt)::

    apt-get install virtualenvwrapper
    source  /etc/bash_completion.d/virtualenvwrapper


Make a virtualenv for the **dotfiles** source::

    mkvirtualenv dotfiles
    workon dotfiles
    cdvirtualenv
    mkdir -p ${VIRTUAL_ENV}/src
    cdvirtualenv src



Install the dotfiles python package (virtualenv)
-------------------------------------------------

* Install into ``${VIRTUAL_ENV}`` (with pip)::

  workon dotfiles  # source ${VIRTUAL_ENV}/bin/activate
  pip install -e git+https://github.com/westurner/dotfiles#egg=dotfiles

* (or) Install into ``${VIRTUAL_ENV}`` (manually)::

  cd ${VIRTUAL_ENV}/src
  git clone https://github.com/westurner/dotfiles
  cd dotfiles
  git remote -v
  git branch -v
  ls -l ./dotfiles
  python setup.py develop


Build and test with git and make
---------------------------------
::

    # sudo apt-get install make git
    cd ${VIRTUAL_ENV}/src/dotfiles
    make build
    make install


Install the dotfiles python package (user local)
--------------------------------------------------

* Install to ``${HOME}/.local``::

  pip install --user --upgrade -e git+https://github.com/westurner/dotfiles#egg=dotfiles

* (or) Install::

  cd src/dotfiles
  pip install --user --upgrade -e .
  # python setup.py develop




Symlink dotfiles into place
-----------------------------

Symlink configuration files from ``dotfiles/etc``::

    bash ./scripts/bootstrap_dotfiles.sh -S

    ln -s ${_etc}/mimeapps.list ~/.local/share/applications/
    ln -s ${_etc}/pip/

    source ${HOME}/.bashrc
    touch  ${HOME}/.projects.sh



Sources
=========
- https://bitbucket.org/westurner/dotfiles
- https://github.com/westurner/dotfiles


Usage
=======
List commands from ``setup.py`` (``pavement.py``) and ``Makefile``::

    make help

Install from pip requirements files::

    make pip_install_requirements_all  # pip install requirements/*.txt
    

Building
==========
Install into a virtualenv.

See the ``Makefile``::

    make test
    make build
    # make build

Build ctags for the virtualenv::

    make build_tags



Configuration files
=====================
Included in ``etc/`` are configuration files for:

* `Bash`_
*  Bash `bashmarks`
* `Compiz`_
* `Gnome`_
* `Htop`_
* `Git`_
* `Mercurial`_
* `Python 2`_
*  Python `Distribute`_
*  Python `Pip`_
*  Python `PDB`_
*  Python `IPDB`_
*  Python `IPython`_
*  Python `Virtualenv`_
*  Python `Virtualenvwrapper`_
* `Readline`_
* `Ruby`_
*  Ruby `Gems`_
* `Vim`_
*  Vim `NERDTree`_
* `Vimperator`_
* `ZSH`_

.. _Bash: https://www.gnu.org/software/bash/ 
.. _Compiz: http://compiz.org
.. _Gnome: http://gnome.org
.. _Git: http://git-scm.com/documentation 
.. _Htop: http://htop.sourceforge.net
.. _IPDB: http://pypi.python.org/pypi/ipdb 
.. _IPython: http://ipython.org/ipython-doc/stable/overview.html 
.. _Mercurial: http://hgbook.red-bean.com/ 
.. _NERDTree: https://github.com/scrooloose/nerdtree 
.. _PDB: http://docs.python.org/2/library/pdb.html 
.. _Python: http://docs.python.org/2/
.. _Python 2: http://docs.python.org/2/
.. _Distribute: http://packages.python.org/distribute/index.html 
.. _Pip: http://www.pip-installer.org/en/latest/ 
.. _Readline: http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html 
.. _Ruby: http://www.ruby-lang.org/en/documentation/ 
.. _Gems: http://guides.rubygems.org/ 
.. _Vimperator: http://vimperator.org/vimperator
.. _Vim: http://www.vim.org/docs.php
.. _ZSH: http://zsh.sourceforge.net/Guide/zshguide.html 

Bash Configuration
===================

Load Sequence
--------------------

:: 

    $ bash
    # (~/.bashrc)                    -> ./etc/.bashrc
    #    -> (~/.bashrc.venv.sh)     -> ./etc/.bashrc.venv.sh
    #        -> (./etc/.bashmarks.sh)
    #        -> (./etc/usrlog.sh)
    #        -> (~/.projectsrc.sh


etc/.bashrc
-----------------
Deliberately minimal ``.bashrc``. Should be symlinked to
``~/.bashrc``.

**Sources**:

- ``etc/.bashrc.venv.sh``


etc/.bashrc.venv.sh
-------------------------
Configures ``${__WORKSPACE}`` and ``${WORKON_HOME}`` for
**virtualenvwrapper** and **venv**.

**Sources**:

- ``etc/.bashmarks.sh``
- ``etc/usrlog.sh``
- ``${__WORKSPACE}/.projectsrc.sh``


bashmarks
------------
``etc/.bashmarks.sh``

A shell script that allows you to save and jump to commonly used
directories.

**Usage**::

    # Save bookmark
    s bookmarkname
    
    # Goto bookmark
    g bookmarkname
    g b[TAB]
    
    # Print bookmark
    p bookmarkname
    p b[TAB]

    # Delete bookmark
    d bookmarkname
    d [TAB]

    # List bookmarks
    l
    
**Sources**:

- https://github.com/huyng/bashmarks


usrlog.sh
------------------
``etc/usrlog.sh``

Delimited and timestamped terminal history with lightweight 'sessions'

Each invocation of bash or zsh generates a new TERM_ID string which is
prepended to the terminal history record.

TERM_ID values are random, but can be set by calling ``stid``
::

    echo $TERM_ID
    # 0eZfHHVar76

    # Set a new TERM_ID
    stid

    echo $TERM_ID
    BUaOZ2FshNk

    # Specify a TERM_ID
    stid app_configuration
    
    echo $TERM_ID
    app_configuration


::

    # term_id ::: 0eZfHHVar76 [ ./dotfiles/.usrlog ]
    $


**$VIRTUAL_ENV**

When ``$VIRTUAL_ENV`` is set in the environment, terminal history is
appended to ``$VIRTUAL_ENV``-specific ``_USRLOG`` and ``HISTFILE`` files.

::

    tail -n 5 ~/.usrlog
    tail -n 5 ~/.virtualenvs/dotfiles/.usrlog


~/.projectsrc.sh
--------------------
``${__WORKSPACE}/projectsrc.sh``

System-local bash configuration.


virtualenv
-----------
Virtual python environment builder

**Install**::

    pip install virtualenv

**Sources**:

- http://pypi.python.org/pypi/virtualenv
- https://github.com/pypa/virtualenv/ 

**Documentation**:

- http://www.virtualenv.org/en/latest/
- http://virtualenv.rtfd.org


virtualenvwrapper
------------------
Enhancements to virtualenv

**Install**::

    # install virtualenvwrapper
    pip install virtualenvwrapper

    # configure virtualenvwrapper shell variables
    grep WORKON_HOME ~/.bashrc.venv.sh
    grep VIRTUALENVWRAPPER_SCRIPT ~/.bashrc.venv.sh
    
**Sources**:

- http://pypi.python.org/pypi/virtualenvwrapper 
- https://bitbucket.org/dhellmann/virtualenvwrappe

**Documentation**:

- http://virtualenvwrapper.rtfd.org
- http://virtualenvwrapper.readthedocs.org/en/latest/scripts.html


Venv
--------
``./etc/ipython/profile_default/ipython_config.py``

Enhancements to virtualenvwrapper for Bash, ZSH, and IPython

Venv is defined in an executable IPython ``ipython_config.py`` file::

    export
    alias

    echo $_VENV
    cat $_VENV
    #> omitted for readability

    venv -E --bash
    source <(venv -E --bash)

    export
    alias


**Features**

* Configures `Python`_ ``site`` for a given `virtualenv`
* Configures `Python`_ ``sys.path``: `IPython`_ extension paths
* Configures `IPython`_ command aliases (``%alias``, or just ``alias``)
* Generates `Bash`_ environments from `virtualenv` paths
* Configures `Bash`_ variables starting with ``$_``
* Executes subcommands within generated environments (``venv -x bash``)

**Usage**

Create a virtualenv (**virtualenvwrapper**)::

    mkvirtualenv dotfiles
    workon dotfiles
    pip install -e https://bitbucket.org/westurner/dotfiles

Work on a project::

    we dotfiles

List current environment settings::

    venv -E --bash

Generate environment settings for an environment::

    venv dotfiles --bash

Execute a command within an environment::

    venv dotfiles -x gnome-terminal

The ``we`` command adds a ``_venv`` alias to ``venv -E``,
so the following commands are equivalent::

    venv -E --print
    venv dotfiles --print
    _venv --print
    _venv dotfiles --print
    $_VENV -E --print
    $_VENV dotfiles --print

List Venv-generated Venv variables, aliases, and commands with::

    venv -E --bash

Paths should be contained within ``${VIRTUAL_ENV}``, which is set by
``virtualenvwrapper`` through a call to ``workon``::

    echo ${VIRTUAL_ENV}
    #
    workon dotfiles
    echo ${VIRTUAL_ENV}
    # ~/.virtualenvs/dotfiles
    echo ${_WRD}
    #
    source <(venv -E --bash)
    echo ${_WRD}
    # ~/.virtualenvs/dotfiles/src/dotfiles
    echo ${_APP}
    # dotfiles


Python API
~~~~~~~~~~~~
A Venv object builds an ``Env`` with ``${VIRTUAL_ENV}``-relative paths
in a common filesystem hierarchy and an ordered dictionary of
command aliases, which can be serialized to
a bash script (``venv --bash``) or to JSON (``venv --print``).

.. code-block:: python

    import Venv, json
    venv = Venv(from_environ=True)
    venv.print()
    venv.bash_env()

    venv.configure_sys()
    venv.configure_ipython()

    assert venv.virtualenv  == venv.env['VIRTUAL_ENV']
    assert venv.appname     == venv.env['_APP']

    print(venv.env['_WRD'])     # working directory
    #> ~/.virtualenvs/dotfiles

    print(venv.aliases['_edit'])
    #> gvim --servername dotfiles --remote-tab

    print(venv.env['_EDIT_'])
    #> gvim --servername dotfiles --remote-tab


Command Aliases
-----------------
.. note:: Many of the aliases generated by `Venv` are also defined in
    ``bashrc.venv.sh``.


cd Aliases
~~~~~~~~~~~~~~
**cdb**::

    cd $_BIN
    # cdvirtualenv bin

**cde**::

    cd $_ETC
    # cdvirtualenv etc

**cdpylib**::

    cd $_PYLIB
    # cdsitepackages ..

**cdpysite**::

    cd $_PYSITE
    # cdsitepackages

**cds**::

    cd $_SRC
    # cdvirtualenv src

**cdv**::

    cd $VIRTUAL_ENV
    # cdvirtualenv

**cdvar**::

    cd $_VAR
    # cdvirtualenv var

**cdve**::

    cd $WORKON_HOME

**cdw**::

    cd $_WRD
    # cdvirtualenv src/${_APP}
   
**cdww**::

    cd $_WWW
    # cdvirtualenv var/www

**cdhelp**::

    set | grep '^cd.*()' | cut -f1 -d' ' 

gvim
~~~~~~~~~~~~~~~~~
**_edit**
    ``gvim --servername=${_APP} --remote-tab``

**_editp**::
    ``_edit {README,setup.py,...}``


grin
~~~~~~~~~~~~~~
**grin --help**::

    grin --help
    grind --help
    grin[d] --help

**grin[d]v**::

    grin[d] ${VIRTUAL_ENV}

**grin[d]s**::

    grin[d] ${_SRC}

**grin[d]w**::

    grin[d] ${_WRD}


ipython
~~~~~~~~~~~~~~~~~~
**ip_session**
    generate a new ipython notebook sessionkey

**ipnb**
    Start ipython notebook with notebooks from ${_SRC}/notebooks

**ipqt**
    Start IPython Qt console


Scripts
========
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


Python Console Scripts
=======================
In ``src/dotfiles``:

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
    Execute python expressions over line-based files

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


setup.py
=========
Python packaging.

``setup.py`` imports from ``pavement.py``, which requires ``paver``.

Standard setuptools commands are supported::

    python setup.py help


pavement.py
-------------
``pavement.py`` adds a few useful commands to the standard set of
``paver`` commands.



