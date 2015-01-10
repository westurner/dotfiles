
.. index:: Usage
.. _usage:

Usage
=======
* :ref:`Install the dotfiles` with `bootstrap_dotfiles.sh`_
* Develop with the `Makefile`_ (:ref:`Make`)
* Shell with `Bash`_ (:ref:`Bash`, :ref:`ZSH`)
* Edit text files with `Vim`_ (:ref:`Vim`)
* Manage windows on :ref:`Linux` platforms with `I3wm`_ (:ref:`I3wm`)
* :ref:`Script <scripts>` all the `things <http://schema.org/Thing>`__


.. index:: bootstrap_dotfiles.sh
.. _bootstrap_dotfiles.sh:

bootstrap_dotfiles.sh
-----------------------
| https://github.com/westurner/dotfiles/blob/master/scripts/bootstrap_dotfiles.sh

``bash scripts/bootstrap_dotfiles.sh -h``:

.. command-output:: bash $_WRD/scripts/bootstrap_dotfiles.sh -h
   :shell:


.. index:: Dotfiles Makefile
.. _dotfiles_makefile:

Makefile
-------------
| https://github.com/westurner/dotfiles/blob/master/Makefile

``make help``:

.. command-output:: cd $_WRD && make help
   :shell:


.. index:: Dotfiles Bash Configuration
.. _dotfiles_bash_config:

Bash
-----
| https://github.com/westurner/dotfiles/blob/master/etc/.bashrc
| https://github.com/westurner/dotfiles/blob/master/etc/bash/00-bashrc.before.sh

``make help_bash_rst``:

.. literalinclude:: bash_conf.txt


.. index:: Dotfiles Vim Configuration
.. index:: Dotvim
.. _dotvim:

Vim
-----
| https://github.com/westurner/dotvim/blob/master/vimrc
| https://github.com/westurner/dotvim/blob/master/vimrc.full.bundles.vimrc
| https://github.com/westurner/dotvim/blob/master/vimrc.tinyvim.bundles.vimrc

``make help_vim_rst``:

.. literalinclude:: dotvim_conf.txt


.. index:: Dotfiles i3wm Configuration
.. index:: I3wm configuration
.. _dotfiles_i3wm:

I3wm
-----
| https://github.com/westurner/dotfiles/blob/master/etc/.i3/config

``make help_i3_rst``:

.. literalinclude:: i3_conf.txt


.. index:: Dotfiles Scripts
.. _dotfiles_scripts:

Scripts
---------
| https://github.com/westurner/dotfiles/tree/master/scripts

In ``scripts/``

**bashmarks_to_nerdtree.sh**
   Convert `bashmarks` shortcut variables
   starting with ``DIR_`` to `NERDTreeBookmarks <NERDTree>`_ format::

       export | grep 'DIR_'
       l          # list bashmarks
       s awesome  # save PWD as 'awesome' bashmark
       g awesome  # goto the 'awesome' bashmark
       ./bashmarks_to_nerdtree.sh | tee ~/.NERDTreeBookmarks

**bootstrap_dotfiles.sh**
   Clone, update, and install dotfiles in ``$HOME``

    See: `bootstrap_dotfiles.sh`_

**compare_installed.py**
   Compare packages listed in a debian/ubuntu APT
   ``.manifest`` with installed packages.

   See: https://github.com/westurner/pkgsetcomp

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

**el**
   Open args from stdin with ``EDITOR_`` or ``EDITOR``. Similar to
   ``xargs``.

   ``grep -l TODO | el`` opens files in ``EDITOR_``

   ``grep -l TODO | el -x echo`` echos 'filename1 filename2 filenamen'

   ``grep -l TODO | el -v --each -x echo`` runs echo ``n`` times, verbosely

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
   Similar to ``coreutils``' ``cut``: split line-based files into
   fields. See: *pyline.py* (``pyline 'w[1:2]'``)

**py_index.py**
   Create a python package index HTML file for a directory of
   packages. (``.egg``, ``.zip``, ``.tar.gz``, ``tgz``)

**pyline.py**
   Similar to ``sed`` and ``awk``:
   Execute python expressions over line-based files.

   See: https://github.com/westurner/pyline

**pyren.py**
   Skeleton regex file rename script

   See: https://github.com/westurner/pyleset

**pyrpo.py**
   Wrap version control system commandline interfaces

   See: https://github.com/westurner/pyrpo

**usrlog.sh**
   **Log shell output** with (by default, unique)
   TERM_IDs, PWD, start / finish times
   to ``~/-usrlog.log`` 
   or ``$VIRTUAL_ENV/-usrlog.log``.

**usrlog.py**
   Search through ``.usrlog`` files

**xlck.sh**
   Wrap ``xautolock`` for screensaver, shutdown, suspend, resume config
   (e.g. ``.xinitrc`` calls ``xlck.sh -S``)

**x-www-browser**
   Launch browser tabs for each argument (OSX, Linux, webbrowser)
