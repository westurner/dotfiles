
===========
Dotfiles
===========

`GitHub`_ | `Documentation`_ | `ReadTheDocs`_

.. _GitHub: https://github.com/westurner/dotfiles
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
  (such as ``~/.bashrc`` -> ``${__DOTFILES}/etc/.bashrc``)
* ``etc/.bashrc`` sources ``etc/bash/00-bashrc.before.sh``
* ``etc/bash/00-bashrc.before.sh`` sources a documented,
  ordered sequence of Bash scripts
* ``etc/zsh/00-zshrc.before.sh`` sources a documented,
  ordered sequence of ZSH scripts

See: `Usage`_ and `Venv`_ for documentation.

.. _usage: https://westurner.github.io/dotfiles/usage.html
.. _venv: https://westurner.github.io/dotfiles/venv.html


Quickstart
------------

This is a verbose example of installing and working with a
``VIRTUAL_ENV`` in ``WORKON_HOME`` named "``dotfiles``".

See `Install the dotfiles`_ for more terse installation instructions.

.. code:: bash


    # clone and install dotfiles and dotvim
    # with venv-style paths (_SRC, _APP, _WRD)

    # __WRK             -- base path for workspace               [venv]
    __WRK="$HOME/-wrk"
    cd $__WRK                     # cdwrk                        [venv]

    # WORKON_HOME       -- path to virtualenv dirs  [virtualenvwrapper]
    WORKON_HOME="${__WRK}/-ve27"  # ~/-wrk/-ve27
    test -d ${WORKON_HOME} || mkdir -p ${WORKON_HOME}
    cd $WORKON_HOME               # cdworkonhome cdwh cdve       [venv]

    # VIRTUAL_ENV_NAME  -- basename for VIRTUAL_ENV              [venv]
    VIRTUAL_ENV_NAME="dotfiles"

    # VIRTUAL_ENV       -- current virtualenv path         [virtualenv]
    VIRTUAL_ENV="${WORKON_HOME}/${VIRTUAL_ENV_NAME}"
    cd $VIRTUAL_ENV               # cdv cdvirtualenv [venv, virtualenvwrapper]

    # _SRC              -- basepath of source repositories (e.g. for pip) 
    _SRC="${VIRTUAL_ENV}/src"
    cd $_SRC                      # cdsrc cds                    [venv]

    # _APP              -- basename of current working directory [venv]
    _APP="dotfiles"

    # _WRD              -- working directory path                [venv]
    _WRD="${_SRC}/${_APP}"        # cdwrd cdw                    [venv]

    git clone https://github.com/westurner/dotfiles $_WRD
    git clone https://github.com/westurner/dotvim ${_WRD}/etc/vim
    cd $_WRD                      # cdwrd cdw                    [venv]

    # __DOTFILES        -- symlink root for current dotfiles     [venv]
    __DOTFILES="${HOME}/.dotfiles"
    ln -s $_WRD $__DOTFILES
    ls ~/.dotfiles
    cd $__DOTFILES                # cddotfiles cdd               [venv]
  
    ## Install the dotfiles
    $_WRD/scripts/bootstrap_dotfiles.sh -h
    $_WRD/scripts/bootstrap_dotfiles.sh -I      # or: make install
    $_WRD/scripts/bootstrap_dotfiles.sh -S      # or: make install_symlinks


Bash
-----
| Source: https://github.com/westurner/dotfiles/tree/master/etc/bash
| Documentation: https://westurner.github.io/dotfiles/usage.html#bash


.. code:: bash

    # There should be a symlink from ~/.dotfiles
    # to the current dotfiles repository.
    # All dotfiles symlinks are relative to ${__DOTFILES}.
    __DOTFILES="${HOME}/-dotfiles"
    __WRK="${HOME}/-wrk"
    WORKON_HOME="${__WRK}/-ve27"
    _WRD="${WORKON_HOME}/dotfiles/src/dotfiles"
    ls -ld $__DOTFILES || ln -s $_WRD $__DOTFILES
    # Create dotfiles symlinks with bootstrap_dotfiles.sh -S
    $_WRD/scripts/bootstrap_dotfiles.sh -S      # or: make install_symlinks

At this point, there should be symlinks for each dotfile (e.g.):

.. code:: bash

    # ln -s ~/-dotfiles/etc/.bashrc    ~/.bashrc
    # ln -s ~/-dotfiles/etc/.gitconfig ~/.gitconfig
    # ln -s ~/-dotfiles/etc/.hgrc      ~/.hgrc
    # ln -s ~/-dotfiles/etc/vim/vimrc  ~/.vimrc
    # ln -s ~/-dotfiles/etc/vim        ~/.vim

Source ``~/.bashrc`` to load the Bash configuration:

.. code:: bash

   source ~/.bashrc  # ( source dotfiles/etc/bash/00-bashrc.before.sh )

Reload the dotfiles and print status information with ``dr`` and ``ds`` 
(again):

.. code:: bash

   dotfiles_status  # print dotfiles environment variables
   ds               # print dotfiles environment variables
   dotfiles_reload  # source ${__DOTFILES}/etc/bash/00-bashrc.before.sh
   dr               # source ${__DOTFILES}/etc/bash/00-bashrc.before.sh



vimrc
------
| Source: https://github.com/westurner/dotvim
| Documentation: https://westurner.github.io/dotfiles/usage.html#vim

Vim configuration should be cloned to ``${__DOTFILES}/etc/vim``.

.. code:: bash

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

.. code:: bash

    [sudo] pip install virtualenvwrapper
    source $(which 'virtualenvwrapper.sh')
    mkvirtualenv dotfiles
    mkdir $VIRTUAL_ENV/src
    cd $VIRTUAL_ENV/src

    # Clone the dotfiles git repository
    git clone ssh://git@github.com/westurner/dotfiles && cd dotfiles

    # Install and symlink dotfiles and dotvim
    scripts/bootstrap_dotfiles.sh -I -R

    # (Optional) Also install dotfiles scripts into ~/.local/bin (pip --user)
    scripts/bootstrap_dotfiles.sh -I -u


.. _dotfiles git repository: https://github.com/westurner/dotfiles

.. note:: See the `dotfiles venv example`_ which uses
   venv-style paths.


Upgrade the dotfiles
----------------------

.. code:: bash

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
