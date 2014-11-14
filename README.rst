
===========
Dotfiles
===========

`GitHub`_ | `BitBucket`_ | `Documentation`_

.. _GitHub: https://github.com/westurner/dotfiles
.. _BitBucket: https://bitbucket.org/westurner/dotfiles
.. _Documentation: https://westurner.github.io/dotfiles/   
.. _ReadTheDocs: https://wrdfiles.readthedocs.org/en/latest/


Goals
=======
* Streamline frequent workflows
* Configure Bash, ZSH, and Vim
* Configure Python, pip, virtualenv, virtualenvwrapper
* Configure IPython
* Configure Gnome
* Configure i3wm
* Support Debian Linux, Ubuntu Linux, OSX
* Document commands and keyboard shortcuts
* Create a productive working environment

  
Usage
=======

* ``scripts/bootstrap_dotfiles.sh`` installs symlinks in ``$HOME``
  (such as ``~/.bashrc`` -> ``${__DOTFILES}/etc/bashrc``)
* ``etc/bashrc`` sources ``etc/bash/00-bashrc.before.sh``
* ``etc/bash/00-bashrc.before.sh`` sources a documented,
  ordered sequence of Bash scripts
* ``etc/zsh/00-zshrc.before.sh`` sources a documented,
  ordered sequence of ZSH scripts

See: `Usage`_ and `Venv`_ for documentation.

.. _usage: https://westurner.github.io/dotfiles/usage.html
.. _venv: https://westurner.github.io/dotfiles/venv.html


Examples
------------

Installing the dotfiles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash


    # clone and install dotfiles and dotvim
    # with venv-style paths (_SRC, _APP, _WRD)

    # WORKON_HOME       -- base path for virtualenvs [virtualenvwrapper]
    WORKON_HOME="~/wrk/.ve"
    test -d ${WORKON_HOME} || mkdir -p ${WORKON_HOME}

    # VIRTUAL_ENV_NAME  -- basename for VIRTUAL_ENV [venv]
    VIRTUAL_ENV_NAME="dotfiles"

    # VIRTUAL_ENV       -- current virtualenv prefix [virtualenv]
    VIRTUAL_ENV="${WORKON_HOME}/${VIRTUAL_ENV_NAME}"
    _SRC="$[VIRTUAL_ENV}/src"

    # _APP              -- basename of current working directory [venv]
    _APP="dotfiles"
    # _WRD              -- working directory [venv]
    _WRD="${_SRC}/${_APP}"      # ${WORKON_HOME}/dotfiles/src/dotfiles

    git clone https://github.com/westurner/dotfiles $_WRD
    git clone https://github.com/westurner/dotvim ${_WRD}/etc/vim
    cd $_WRD                    # cdw [venv]

    __DOTFILES="${HOME}/.dotfiles"
    ln -s $_WRD $__DOTFILES
    ls ~/.dotfiles
   
    $_WRD/scripts/bootstrap_dotfiles.sh -h
    $_WRD/scripts/bootstrap_dotfiles.sh -I      # or: make install

    # TODO: move / replicate this in bootstrap_dotfiles.sh


Bash
-----
| Source: https://github.com/westurner/dotfiles/tree/master/etc/bash
| Documentation: https://westurner.github.io/dotfiles/usage.html#bash


.. code-block:: bash

    # There should be a symlink from ~/.dotfiles
    # to the current dotfiles repository.
    # All dotfiles symlinks are relative to ${__DOTFILES}.
    __DOTFILES="${HOME}/.dotfiles"
    ls -ld $__DOTFILES || ln -s $_WRD $__DOTFILES

    # There should be symlinks for each dotfile: e.g.
    # ln -s ~/.dotfiles/etc/.bashrc ~/.bashrc
    # ln -s ~/.dotfiles/etc/vim/vimrc ~/.vimrc
    # ln -s ~/.dotfiles/etc/vim ~/.vim
    # Create these symlinks with bootstrap_dotfiles.sh
    $_WRD/scripts/bootstrap_dotfiles.sh -S      # or: make install_symlinks


.. code-block:: bash
   
   source ~/.bashrc
   # source dotfiles/etc/bash/00-bashrc.before.sh


.. code-block:: bash

   dotfiles_status  # print dotfiles environment variables
   ds               # print dotfiles environment variables
   dotfiles_reload  # source ${__DOTFILES}/etc/bash/00-bashrc.before.sh
   dr               # source ${__DOTFILES}/etc/bash/00-bashrc.before.sh



vimrc
------
| Source: https://github.com/westurner/dotvim
| Documentation: https://westurner.github.io/dotfiles/usage.html#vim

Vim configuration should be cloned to ``${__DOTFILES}/etc/vim``.

.. code-block:: bash

   make dotvim_clone dotvim_install


.. _installation:

Installation
==============

Requirements
---------------
Project requirements are installed by 
`bootstrap_dotfiles.sh`_ and, optionally, also the `Makefile`_.

* :ref:`Bash`
* :ref:`Git`
* :ref:`Python` (:ref:`pip`)

.. _bootstrap_dotfiles.sh: https://github.com/westurner/dotfiles/blob/master/scripts/bootstrap_dotfiles.sh
.. _Makefile: https://github.com/westurner/dotfiles/blob/master/Makefile


.. _install the dotfiles:

Install the dotfiles
---------------------
| Source: https://github.com/westurner/dotfiles
| Documentation: https://westurner.github.io/dotfiles/


The `bootstrap_dotfiles.sh`_ shell script 
clones the `dotfiles git repository`_
and installs the ``dotfiles`` Python package.


Create a :ref:`virtualenv` with :ref:`virtualenvwrapper`
named "``dotfiles``":

.. code-block:: bash

    [sudo] pip install virtualenvwrapper
    source $(which 'virtualenvwrapper.sh')
    mkvirtualenv dotfiles
    mkdir $VIRTUAL_ENV/src
    cd $VIRTUAL_ENV/src

Install the dotfiles (symlink dotfiles into ``$HOME``, install the
dotfiles package, and install additional helpful packages):

.. code-block:: bash

    git clone ssh://git@github.com/westurner/dotfiles && cd dotfiles
    # Install and symlink dotfiles and dotvim
    scripts/bootstrap_dotfiles.sh -I -R

    # (Optional) Install dotfiles scripts into ~/.local/bin (pip --user)
    scripts/bootstrap_dotfiles.sh -I -u


.. _dotfiles git repository: https://github.com/westurner/dotfiles

.. note:: See the `Installing the dotfiles`_ example, which uses
   venv-style paths.


Upgrade the dotfiles
----------------------

.. code-block:: bash

   # Check for any changes to symlinked dotfiles
   cd ~/.dotfiles && git status && git diff

   # Pull and upgrade dotfiles and dotvim (later)
   scripts/bootstrap_dotfiles.sh -U


Further Dotfiles Resources
===========================
* https://dotfiles.github.io/
* https://westurner.github.io/wiki/workflow
* https://westurner.github.io/dotfiles/

*****

Next: https://westurner.github.io/dotfiles/usage.html
