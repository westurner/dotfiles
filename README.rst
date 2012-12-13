==========
dotfiles
==========
**Bash scripts**, **Python scripts**, and **configuration files**
for working with projects on \*nix platforms in Bash, ZSH, Ruby, and Python.

Objective
===========
* Minimize error by standardizing common workflows and processes

Configuration files
=====================
Included in ``etc/`` are configuration files for:

* Bash
* Compiz
* Gnome
* Htop
* IPDB
* IPython
* Mercurial
* NERDTree
* PDB
* Pip
* Python
* Readline
* Ruby Gems
* Setuptools
* Vimperator
* ZSH


Bash Configuration
===================

**Load Sequence**::

    $ bash
    #(~/.bashrc)                    -> ./etc/.bashrc
    #    -> (~/.bashrc.venv.sh)     -> ./etc/.bashrc.venv.sh
    #        -> (./etc/.bashmarks.sh)
    #        -> (./etc/usrlog.sh)
    #        -> (~/.projectsrc.sh


~/.bashrc
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


**${VIRTUAL_ENV}**

When ``${VIRTUAL_ENV}`` is set in the environment, terminal history is
appended to ``${VIRTUAL_ENV}``-specific ``_USRLOG`` and ``HISTFILE`` files.

::

    tail -n 5 ~/.usrlog
    tail -n 5 ~/.virtualenvs/dotfiles/.usrlog


~/.projectsrc.sh
--------------------
``${__WORKSPACE}/projectsrc.sh``

System-local bash configuration.


virtualenv
-----------
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


Venv
--------
``./etc/ipython/profile_default/ipython_config.py``

Venv is a one-file configuration script that extends ``virtualenvwrapper``
with environment variables and aliases that can be sourced in a shell::

    echo $_VENV
    cat $_VENV
    venv -E --bash
    source <(venv -E --bash)


**Features**

* Configures python site paths for virtualenv
* Configures IPython extension paths
* Configures IPython command aliases
* Configures shell shortcuts starting with ``_``
* Generates Bash environments from virtualenv paths
* Executes subcommands within generated environments


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
    # ~/.virtualenvs/dotfiles
    print(venv.aliases['_edit'])
    # gvim --servername dotfiles --remote-tab


.. note:: At the moment, Venv is not a ``virtualenvwrapper``
   postactivate script.


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
**grin[d]v**::
    grin[d] ${VIRTUAL_ENV}

**grin[d]s**::

    grin[d] ${_SRC}

**grin[d]w**::

    grin[d] ${_WRD}

**grin --help**::

    $ grin --help
    usage: grin [-h] [-v] [-i] [-A AFTER_CONTEXT] [-B BEFORE_CONTEXT] [-C CONTEXT]
                [-I INCLUDE] [-n] [-N] [-H] [--without-filename] [--emacs] [-l]
                [-L] [--no-color] [--use-color] [--force-color] [-s]
                [--skip-hidden-files] [-b] [--skip-backup-files] [-S]
                [--skip-hidden-dirs] [-d SKIP_DIRS] [-D] [-e SKIP_EXTS] [-E]
                [--no-follow] [--follow] [-f FILE] [-0] [--sys-path]
                regex [files [files ...]]

    Search text files for a given regex pattern.

    positional arguments:
    regex                   the regular expression to search for
    files                   the files to search

    optional arguments:
    -h, --help              show this help message and exit
    -v, --version           show program's version number and exit
    -i, --ignore-case       ignore case in the regex
    -A AFTER_CONTEXT, --after-context AFTER_CONTEXT
                            the number of lines of context to show after the match
                            [default=0]
    -B BEFORE_CONTEXT, --before-context BEFORE_CONTEXT
                            the number of lines of context to show before the
                            match [default=0]
    -C CONTEXT, --context CONTEXT
                            the number of lines of context to show on either side
                            of the match
    -I INCLUDE, --include INCLUDE
                            only search in files matching this glob [default='*']
    -n, --line-number       show the line numbers [default]
    -N, --no-line-number    do not show the line numbers
    -H, --with-filename     show the filenames of files that match [default]
    --without-filename      do not show the filenames of files that match
    --emacs                 print the filename with every match for easier parsing
                            by e.g. Emacs
    -l, --files-with-matches
                            show only the filenames and not the texts of the
                            matches
    -L, --files-without-matches
                            show the matches with the filenames
    --no-color              do not use colorized output [default if piping the
                            output]
    --use-color             use colorized output [default if outputting to a
                            terminal]
    --force-color           always use colorized output even when piping to
                            something that may not be able to handle it
    -s, --no-skip-hidden-files
                            do not skip .hidden files
    --skip-hidden-files     do skip .hidden files [default]
    -b, --no-skip-backup-files
                            do not skip backup~ files [deprecated; edit --skip-
                            exts]
    --skip-backup-files     do skip backup~ files [default] [deprecated; edit
                            --skip-exts]
    -S, --no-skip-hidden-dirs
                            do not skip .hidden directories
    --skip-hidden-dirs      do skip .hidden directories [default]
    -d SKIP_DIRS, --skip-dirs SKIP_DIRS
                            comma-separated list of directory names to skip
                            [default='CVS,RCS,.svn,.hg,.bzr,build,dist']
    -D, --no-skip-dirs      do not skip any directories
    -e SKIP_EXTS, --skip-exts SKIP_EXTS
                            comma-separated list of file extensions to skip [defau
                            lt='.pyc,.pyo,.so,.o,.a,.tgz,.tar.gz,.rar,.zip,~,#,.ba
                            k,.png,.jpg,.gif,.bmp,.tif,.tiff,.pyd,.dll,.exe,.obj,.
                            lib']
    -E, --no-skip-exts      do not skip any file extensions
    --no-follow             do not follow symlinks to directories and files
                            [default]
    --follow                follow symlinks to directories and files
    -f FILE, --files-from-file FILE
                            read files to search from a file, one per line; - for
                            stdin
    -0, --null-separated    filenames specified in --files-from-file are separated
                            by NULs
    --sys-path              search the directories on sys.path


**grind --help**::

    $ grind --help
    usage: grind [-h] [-v] [-s] [--skip-hidden-files] [-b] [--skip-backup-files]
                [-S] [--skip-hidden-dirs] [-d SKIP_DIRS] [-D] [-e SKIP_EXTS] [-E]
                [--no-follow] [--follow] [-0] [--dirs DIRS [DIRS ...]]
                [--sys-path]
                [glob]

    Find text and binary files using similar rules as grin.

    positional arguments:
    glob                    the glob pattern to match; you may need to quote this
                            to prevent the shell from trying to expand it
                            [default='*']

    optional arguments:
    -h, --help              show this help message and exit
    -v, --version           show program's version number and exit
    -s, --no-skip-hidden-files
                            do not skip .hidden files
    --skip-hidden-files     do skip .hidden files
    -b, --no-skip-backup-files
                            do not skip backup~ files [deprecated; edit --skip-
                            exts]
    --skip-backup-files     do skip backup~ files [default] [deprecated; edit
                            --skip-exts]
    -S, --no-skip-hidden-dirs
                            do not skip .hidden directories
    --skip-hidden-dirs      do skip .hidden directories
    -d SKIP_DIRS, --skip-dirs SKIP_DIRS
                            comma-separated list of directory names to skip
                            [default='CVS,RCS,.svn,.hg,.bzr,build,dist']
    -D, --no-skip-dirs      do not skip any directories
    -e SKIP_EXTS, --skip-exts SKIP_EXTS
                            comma-separated list of file extensions to skip [defau
                            lt='.pyc,.pyo,.so,.o,.a,.tgz,.tar.gz,.rar,.zip,~,#,.ba
                            k,.png,.jpg,.gif,.bmp,.tif,.tiff,.pyd,.dll,.exe,.obj,.
                            lib']
    -E, --no-skip-exts      do not skip any file extensions
    --no-follow             do not follow symlinks to directories and files
                            [default]
    --follow                follow symlinks to directories and files
    -0, --null-separated    print the filenames separated by NULs
    --dirs DIRS [DIRS ...]
                            the directories to start from
    --sys-path              search the directories on sys.path


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
    Convert ``bashmarks`` shortcut variables
    starting with 'DIR_' to ``NERDTreeBookmarks`` format::

    l
    ./bashmarks_to_nerdtree.sh


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

**pipls.py
    Walk and enumerate a pip requirements file

**pycut.py**
    Similar to ``coreutils``' ``cut``: split line-based files into fields

**py_index.py**
    Create a python package index HTML file for a directory of
    packages. (``.egg``, ``.zip``, ``.tar.gz``, ``tgz``)

    TODO: build repo tags

**pyline.py**
    Similar to ``sed`` and ``awk``:
    Execute python expressions over line-based files

**pyren.py**
    Skeleton regex file rename script

**repos.py**
    Wrap version control system commandline interfaces

    * Find vcs repositories
    * Wrap shell commands
    * Yield event tuples with
    ``hg``, ``bzr``, ``git``, and ``svn``

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


Install
========

**Part One**

Install **virtualenvwrapper**::

    pip install virtualenvwrapper
    # or: apt-get install virtualenvwrapper


Make a virtualenv for the **dotfiles** source::

    mkvirtualenv dotfiles
    workon dotfiles
    cdvirtualenv
    mkdir -p ${VIRTUAL_ENV}/src
    cdvirtualenv src


**Part Two**

Clone and install the dotfiles repository.

From `BitBucket <https://bitbucket.org/westurner/dotfiles>`_::

    repo_url="https://bitbucket.org/westurner/dotfiles"
    git clone $repo_url
    cd dotfiles
    python setup.py develop

    # or:
    pip install -e hg+$repo_url


From `Github <https://github.com/westurner/dotfiles>`_::

    repo=_url"https://github.com/westurner/dotfiles"
    hg clone $repo_url
    cd dotfiles
    python setup.py develop

    # or: 
    pip install -e git+$repo_url


**Part Three**

Symlink configuration files from ``dotfiles/etc``::

    _etc="~/.dotfiles/etc"
    cd ${HOME}
    ln -s ${_etc}/.bashrc.venv.sh
    ln -s ${_etc}/.bashrc 
    # or: echo "source ~/.virtualenvs/dotfiles" >> ~/.bashrc

    ln -s ${_etc}/.gemrc
    ln -s ${_etc}/.htoprc
    ln -s ${_etc}/.inputrc
    ln -s ${_etc}/.pdbrc
    ln -s ${_etc}/.pydistutils.cfg
    ln -s ${_etc}/.pythonrc
    ln -s ${_etc}/.vimperatorrc
    ln -s ${_etc}/hg/.hgrc
    ln -s ${_etc}/ipython/ipython_default.py ~/.ipython/profile_default/
    ln -s ${_etc}/mimeapps.list ~/.local/share/applications/
    ln -s ${_etc}/pip/

    source ${HOME}/.bashrc
    touch  ${HOME}/.projects.sh


Sources
=========
- https://bitbucket.org/westurner/dotfiles
- https://github.com/westurner/dotfiles
