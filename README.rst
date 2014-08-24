
===========
dotfiles
===========

`GitHub`_ | `BitBucket`_ | `ReadTheDocs`_

.. _GitHub: https://github.com/westurner/dotfiles
.. _BitBucket: https://bitbucket.org/westurner/dotfiles
.. _ReadTheDocs: https://wrdfiles.readthedocs.org/en/latest/

**Shell**, **Python**, and **configuration files**
for working with projects on \*nix platforms with Bash, ZSH, Ruby, and Python.


Goals
=======
* Create a productive working environment
* Streamline frequent workflows
* Configure bash, zsh, and vim
* Streamline frequent workflows
* Configure bash and vim
* Support Debian/Ubuntu, OSX 
* Document keyboard shortcuts


Usage
=======

Requirements
---------------
* bash
* python
* git
* hg
* python setuptools
* python pip


Makefile
---------

.. code-block:: bash

    make install


Bootstrap Shell Script
~~~~~~~~~~~~~~~~~~~~~~~
The bootstrap shell script clones this repository and
and installs files from this python package::

    wget https://github.com/westurner/dotfiles/blob/master/scripts/bootstrap_dotfiles.sh
    bash ./bootstrap_dotfiles.sh -h     # help
    bash ./bootstrap_dotfiles.sh -u     # add --user to pip commands

    bash ./bootstrap_dotfiles.sh -I     # clone and pip install
    bash ./bootstrap_dotfiles.sh -I -u  # clone and pip install --user

    bash ./bootstrap_dotfiles.sh -S     # symlink into $HOME

There are examples of installing python, pip, and setuptools both in
``scripts/bootstrap_dotfiles.sh`` and the ``Makefile``.

    bash ./bootstrap_dotfiles.sh -U     # pull, update, and upgrade


Manual Installation
~~~~~~~~~~~~~~~~~~~~~

::

    ## Create a virtualenv

    mkvirtualenv dotfiles       # virtualenvwrapper
    workon dotfiles             # virtualenvwrapper (we dotfiles)
    mkdir -p $VIRTUAL_ENV/src   # virtualenv

    ## Clone and `setup.py develop` dotfiles python package with pip

    pip install -e git+https://github.com/westurner/dotfiles#egg=dotfiles

    ## Install pip requirements::

    cd $VIRTUAL_ENV/src/dotfiles
    bash ./scripts/bootstrap_dotfiles.sh -R
    # pip install ./requirements-all.txt

    ## Create symlinks from ``~/.dotfiles/etc`` to ``${HOME}``::

    # symlink and backup existing with a filename postfix
    bash ./scripts/bootstrap_dotfiles.sh -S

(Optional) ``--user`` installation into ``${HOME}/.local/{bin,}``::

    ## Install dotfiles for the current user

    bash ./scripts/bootstrap_dotfiles.sh -u -I
    bash ./scripts/bootstrap_dotfiles.sh -u -R

(Optional) Upgrade pip::

    ## upgrade pip

    pip install --user pip --upgrade
    # pip install --user pip --upgrade --force-reinstall

    ## install current directory into ${HOME}/.local
    # pip install --user $(pwd)
    # pip install --user --editable $(pwd)


Reuse
======
Bash configuration chain-loads from ``etc/bash/00-bashrc.before.sh``.

Symlinks in ``$HOME`` are
created by ``scripts/bootstrap_dotfiles.sh -S`` (``dotfiles_symlink_all``)
::

    # {{ full_name }}
    symlink_gitconfig
    symlink_hgrc
    symlink_mutt

Vim configuration should be cloned to ``etc/vim``
(e.g. from https://github.com/westurner/dotvim).
