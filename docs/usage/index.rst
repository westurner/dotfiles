
.. index:: Usage
.. _usage:



Usage
=======
* :ref:`Install the dotfiles` with `bootstrap_dotfiles.sh`_
* Develop with the `Makefile`_ (:ref:`Make`)
* Shell with `Bash`_ (:ref:`Bash`, :ref:`ZSH`)
* Edit text files with `Vim`_ (:ref:`Vim`)
* Manage windows on :ref:`Linux` platforms with `I3wm`_ (:ref:`I3wm`)
* `Script <scripts>`_ all the `things <http://schema.org/Thing>`__


.. index:: bootstrap_dotfiles.sh
.. _bootstrap_dotfiles.sh:

bootstrap_dotfiles.sh
-----------------------
| Src: https://github.com/westurner/dotfiles/blob/master/scripts/bootstrap_dotfiles.sh
| Docs: :ref:`scripts/bootstrap_dotfiles.sh`

``bash scripts/bootstrap_dotfiles.sh -h``:

.. command-output:: bash ../../scripts/bootstrap_dotfiles.sh -h
   :shell:


.. index:: Dotfiles Makefile
.. _dotfiles_makefile:

Makefile
-------------
| Src: https://github.com/westurner/dotfiles/blob/master/Makefile
| Src: https://github.com/westurner/dotfiles/blob/develop/Makefile

.. code:: bash
``make help``:

.. command-output:: cd $_WRD && make help
   :shell:


.. index:: Dotfiles Readline Configuration
.. _dotfiles_readline_config:

Readline
---------
| Src: https://github.com/westurner/dotfiles/blob/master/etc/.inputrc
| Docs: :ref:`etc/.inputrc`

.. code:: bash

   dhelp readline  # == dhelp inputrc

.. literalinclude:: ./readline_conf.txt


.. index:: Dotfiles Bash Configuration
.. _dotfiles_bash_config:

Bash
-----
| Src: https://github.com/westurner/dotfiles/blob/master/etc/.bashrc
| Docs: :ref:`etc/.bashrc`
| Src: https://github.com/westurner/dotfiles/blob/master/etc/bash/00-bashrc.before.sh
| Docs: :ref:`etc/bash/00-bashrc.before.sh`

.. code:: bash

   dhelp bash


.. literalinclude:: ./bash_conf.txt


.. index:: Dotfiles ZSH Configuration
.. _dotfiles_zsh_config:

ZSH
-----
| Src: https://github.com/westurner/dotfiles/blob/master/etc/.zshrc
| Src: https://github.com/westurner/dotfiles/blob/master/etc/zsh/00-zshrc.before.sh
| Docs: :ref:`etc/i3/config`

.. code:: bash

   dhelp zsh


.. literalinclude:: ./zsh_conf.txt


.. index:: Dotfiles i3wm Configuration
.. index:: I3wm configuration
.. _i3wm:
.. _dotfiles_i3wm:

I3wm
-----
| Src: https://github.com/westurner/dotfiles/blob/master/etc/.i3/config
| Src: https://github.com/westurner/dotfiles/blob/develop/etc/.i3/config
| Docs: :ref:`etc/i3/config`

.. code:: bash

   dhelp i3

.. literalinclude:: ./i3_conf.txt


.. index:: Dotvim Usage
.. _dotvim usage:

Vim
-----
| Src: https://github.com/westurner/dotvim/blob/master/vimrc
| Docs: :ref:`etc/vim/vimrc`
| Src: https://github.com/westurner/dotvim/blob/master/vimrc.full.bundles.vimrc
| Docs: :ref:`etc/vim/vimrc.full.bundles.vimrc`
| Src: https://github.com/westurner/dotvim/blob/master/vimrc.tinyvim.bundles.vimrc
| Docs: :ref:`etc/vim/vimrc.tinyvim.bundles.vimrc`

.. code:: bash

   dhelp vim

.. literalinclude:: ./dotvim_conf.txt


.. index:: Dotfiles src/
.. _dotfiles src/:

src/
----

pgs
~~~~~
| Src:  https://github.com/westurner/pgs
| PyPI: https://pypi.python.org/pypi/pgs

pyline.py
~~~~~~~~~~~~~~~~~~~
| Src:  https://github.com/westurner/pyline
| PyPI: https://pypi.python.org/pypi/pyline

Similar to ``sed`` and ``awk``:
Execute python expressions over line-based files.


pyrpo.py
~~~~~~~~~~~~~~~~~~~
| Src: https://github.com/westurner/pyrpo
| PyPI: https://pypi.python.org/pypi/pyrpo

Wrap version control system commandline interfaces


web.sh
~~~~~~~~~~~~~~~~~~~
| Src: https://github.com/westurner/web.sh
| PyPI: https://pypi.python.org/pypi/web.sh

Launch browser tabs for each argument (OSX, Linux, webbrowser)

.. code:: bash

   ${__DOTFILES}/scripts/websh.py  # vendored
   websh.py en.wikipedia.org/wiki/Wikipedia

   web https://westurner.org/dotfiles/usage#websh
   web localhost:8080 localhost:8080
   web https://localhost:8080/


   .. code:: bash

       Usage: websh.py [-b|-x|-o|-s] [-v|-q] <url1> [<url_n>]

       Open paths or URIS as tabs in the configured system default webbrowser

       Options:
         -h, --help           show this help message and exit
         -b, --webbrowser     Open with `python -m webbrowser`
         -x, --x-www-browser  Open with `x-www-browser` (Linux, X)
         -o, --open           Open with `open` (OSX)
         -s, --start          Open with `start` (Windows)
         -v, --verbose        
         -q, --quiet          
         -t, --test           
   


.. index:: Dotfiles Scripts
.. _dotfiles_scripts:

Scripts
---------
| https://github.com/westurner/dotfiles/tree/master/scripts

In ``scripts/``


dotfiles
~~~~~~~~~~

bootstrap_dotfiles.sh
+++++++++++++++++++++++
Clone, update, and install dotfiles in ``$HOME``

See: `bootstrap_dotfiles.sh`_


venv
~~~~~~

venv.py
+++++++++
See: :ref:`venv`See: bootstrap

venv_relabel.sh
+++++++++++++++++

venv_root_prefix.sh
++++++++++++++++++++++


.. literalinclude:: ../scripts/venv_root_prefix.sh


venv.sh
+++++++++++

_ewrd.sh
++++++++++

.. code:: bash

    e
    editdotfiles
    editetc
    editsrc
    editvirtualenv
    editworkonhome
    editwrd
    editwrk
    editwww
    edotfiles
    eetc
    es
    esrc
    ev
    evirtualenv
    ew
    ewh
    eworkonhome
    ewrd
    ewrk
    ewww
   

_dotfileshelp.sh
++++++++++++++++++

.. code:: bash

   _dotfileshelp.sh -h
   dotfileshelp -h
   dhelp -h
   dh -h
   dh help
   
   dh all
   dh all -n -v  # --number-lines, --verbose
   dh -v -h
   dh
   dh all
   dh readline
   dh bash
   dh zsh
   dh i3
   dh vim
 
   

gitw
+++++++++++++++++++
.. code:: bash
   
   $ gitw  # ~= (cd $WRD; git ${@})


_grinwrd.sh
+++++++++++++


.. code:: bash
    
    grindctags
    grindctagss
    grindctagssrc
    grindctagssys
    grindctagsw
    grindctagswrd
    grinds
    grindsrc
    grindv
    grindvirtualenv
    grindw
    grindwrd
    grindwrdhelp
    grins
    grinsrc
    grinv
    grinvirtualenv
    grinw
    grinwrd
    grinwrdhelp


    editgrindw
    editgrinw
    egrindw
    egrinw
    egw

makew
+++++++
.. code:: bash

   $ makew  # ~= (cd $WRD; make ${@}) # w/ bash completion


usrlog.sh
+++++++++++++++++++
**Log shell output** with (by default, unique)
TERM_IDs, PWD, start / finish times
to ``~/-usrlog.log`` 
or ``$VIRTUAL_ENV/-usrlog.log``.

See: :ref:`usrlog`

usrlog.py
+++++++++++++++++++
Search through ``.usrlog`See: bootstrap` files

See: :ref:`usrlog`


git
~~~~

.gitconfig
++++++++++++++
``etc/gitconfig``

.. literalinclude:: ../../etc/.gitconfig


.gitignore_global
+++++++++++++++++++
``etc/.gitignore_global``

.. literalinclude:: ../../etc/.gitignore_global


gittagstohgtags.sh
+++++++++++++++++++
``etc/scripts/gittagstohgtags.sh``

Convert ``git`` tags to ``hgtags`` format

git-changelog.py
+++++++++++++++++++
``etc/scripts/git-changelog.py``

See: :ref:`usrlog`
Generate a reverse chronological changelog with headings for each tag from :ref:`git` commit messages.

* :ref:`RestructuredText`

.. code:: bash

   cd && test -d .git
   git-changelog.py
   git-changelog.py -r develop
   git-changelog.py --develop



git-subrepo2submodule.sh
++++++++++++++++++++++++++
``etc/scripts/git-subrepo2submodule.sh``


git-track-all-remotes.sh
++++++++++++++++++++++++++
``etc/scripts/git-track-all-remotes.sh``

.. code:: bash

    # git-track-all-remotes.sh -h
    git-track-all-remotes.sh <path> [<name:origin>] [prefix:remotes/<name>/]

    Create Git local tracking branches for **ALL** of a remote's branches.

      -t/--test             run all tests
      -T/--test-fail-early  run tests (and fail early)
      -h/--help             print (this) help



git-upgrade-remote-to-ssh.sh
+++++++++++++++++++++++++++++++
``etc/scripts/git-upgrade-remote-to-ssh.sh``

.. code:: bash

    # git-upgrade-remote-to-ssh.sh -h
    git-upgrade-remote-to-ssh.sh: <path> <remote>
      Upgrade Git remote URLs to SSH URLs

      -t / --test    -- run tests and echo PASS/FAIL
      -h / --help    -- print (this) help

      # git -C ./ --config --get remote.origin.url    # print 'origin' URL in ./
      $ git-upgrade-remote-to-ssh.sh -h       # print (this) help
      $ git-upgrade-remote-to-ssh.sh          # upgrade 'origin' URLs in ./
      $ git-upgrade-remote-to-ssh.sh .        # upgrade 'origin' URLs in ./
      $ git-upgrade-remote-to-ssh.sh . upstream       # upgrade 'upstream' URLs in ./
      $ git-upgrade-remote-to-ssh.sh ./path           # upgrade 'origin' URLs in ./path
      $ git-upgrade-remote-to-ssh.sh ./path upstream  # upgrade 'upstream' URLs in ./path

hg
~~~~

.hgrc
++++++++
``etc/.hgrc`` 

.. literalinclude:: ../../etc/.hgrc


.hgignore_global
+++++++++++++++++++

.. literalinclude:: ../../etc/.hgignore_global


bashmarks_to_nerdtree.sh
~~~~~~~~~~~~~~~~~~~~~~~~~~
Convert `bashmarks` shortcut variables
starting with ``DIR_`` to `NERDTreeBookmarks <NERDTree>`_ format:

.. code:: bash

   export | grep 'DIR_'
   l          # list bashmarks
   s awesome  # save PWD as 'awesome' bashmark
   g awesome  # goto the 'awesome' bashmark
   ./bashmarks_to_nerdtree.sh | tee ~/.NERDTreeBookmarks

compare_installed.py
~~~~~~~~~~~~~~~~~~~~~~
Compare packages listed in a debian/ubuntu APT
``.manifest`` with installed packages.

See: https://github.com/westurner/pkgsetcomp


pulse.sh
~~~~~~~~~~~~~~~~~~~
Setup, configure, start, stop, and restart ``pulseaudio``

setup_mathjax.py
~~~~~~~~~~~~~~~~~~~
Setup ``MathJax``

setup_pandas_notebook_deb.sh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Setup ``IPython Notebook``, ``Scipy``, ``Numpy``, ``Pandas``
with Ubuntu packages and pip

setup_pandas_notebook.sh
~~~~~~~~~~~~~~~~~~~~~~~~~
Setup ``Brew``, ``IPython Notebook``, ``scipy``, ``numpy``,
and pandas on OSX

setup_scipy_deb.py
~~~~~~~~~~~~~~~~~~~
Install and symlink ``scipy``, ``numpy``, and ``matplotlib`` from ``apt``


deb_deps.py
~~~~~~~~~~~~~~~~~~~
Work with debian dependencies

deb_search.py
~~~~~~~~~~~~~~~~~~~
Search for a debian package

build_docs.py
~~~~~~~~~~~~~~~~~~~
Build sets of sphinx documentation projects

el
~~~~~~~~~~~~~~~~~~~
| Src: https://github.com/westurner/dotfiles/blob/master/scripts/el
| Src: https://github.com/westurner/dotfiles/blob/develop/scripts/el

Open args from stdin with ``EDITOR_`` or ``EDITOR``. Similar to
``xargs``.

.. code:: bash

   el.py  # ${__DOTFILES}/scripts/el.py
   el     # ln -s el.py el
   el -v --help

.. code:: bash

   # open files containing 'STR' in ``EDITOR_``
   grep -l 'STR' | el -e

   # open files containing 'STR' in ``EDITOR_`` (verbosely printing each)
   grep -l 'STR' | el -e -v

.. code:: bash

   # echo filenames containing 'STR' 
   $ grep -l 'STR' | el -x echo
   filename1 filename2 filenamen

   # echo each filename containing 'STR'
   $ grep -l 'TODO' | el --each -x echo
   filename1
   filename2
   filenamen

TODO

* EDITOR_ and EDITOR are somewhat deprecated in favor of ``scripts/e``
  and ``scripts/ew``.

  * [ ] BUG: call _setup_editor in dotfiles_postactivate


greppaths.py
~~~~~~~~~~~~~~~~~~~
Grep

lsof.py
~~~~~~~~~~~~~~~~~~~
lsof subprocess wrapper

mactool.py
~~~~~~~~~~~~~~~~~~~
MAC address tool
  
optimizepath.py
~~~~~~~~~~~~~~~~~~~
Work with PATH as an ordered set

passwordstrength.py
~~~~~~~~~~~~~~~~~~~
Gauge password strength

pipls.py
~~~~~~~~~~~~~~~~~~~
Walk and enumerate a pip requirements file

pycut.py
~~~~~~~~~~~~~~~~~~~
Similar to ``coreutils``' ``cut``: split line-based files into
fields. See: *pyline.py* (``pyline 'w[1:2]'``)

py_index.py
~~~~~~~~~~~~~~~~~~~
Create a python package index HTML file for a directory of
packages. (``.egg``, ``.zip``, ``.tar.gz``, ``tgz``)

pyren.py
~~~~~~~~~~~~~~~~~~~
Skeleton regex file rename script

See: https://github.com/westurner/pyleset


whyquote.sh
~~~~~~~~~~~~~~
| Objective: Demonstrate how and why shell quoting matters

* See also: 
  
  * strypes (str types)
  * | Src: https://github.com/westurner/strypes/blob/develop/strypes/strypes.py 


xlck.sh
~~~~~~~~~~~~~~~~~~~
Wrap ``xautolock`` for screensaver, shutdown, suspend, resume config
(e.g. ``.xinitrc`` calls ``xlck.sh -S``)



