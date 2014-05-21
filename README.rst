
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


Bootstrap Shell Script
-----------------------
The bootstrap shell script clones this repository and
and installs files from this python package::

    wget https://github.com/westurner/dotfiles/blob/master/scripts/bootstrap_dotfiles.sh
    bash ./bootstrap_dotfiles.sh -h     # help
    bash ./bootstrap_dotfiles.sh -u     # add --user to pip commands

    bash ./bootstrap_dotfiles.sh -I     # clone and pip install
    bash ./bootstrap_dotfiles.sh -I -u  # clone and pip install --user

    bash ./bootstrap_dotfiles.sh -S     # symlink into $HOME
    bash ./bootstrap_dotfiles.sh -R     # pip install -r requirements.txt

    bash ./bootstrap_dotfiles.sh -U     # pull, update, and upgrade


Manual Installation
---------------------
Create a virtualenv::

    mkvirtualenv dotfiles    # virtualenvwrapper
    # mkdir -p dotfiles/src  # virtualenv
    # virtualenv dotfiles    # virtualenv

Install dotfiles python package with pip::

    pip install -e git+https://github.com/westurner/dotfiles#egg=dotfiles
    cd $VIRTUAL_ENV/src/dotfiles

Install pip requirements::

    bash ./scripts/bootstra_dotfiles.sh -R
    # pip install ./requirements-all.txt

Create symlinks from ``~/.dotfiles/etc`` to ``${HOME}``::

    # symlink and backup existing with a filename postfix
    bash ./scripts/bootstrap_dotfiles.sh -S

(Optional) ``--user`` installation into ``${HOME}/.local/{bin,}``::

    bash ./scripts/bootstrap_dotfiles.sh -u -I
    bash ./scripts/bootstrap_dotfiles.sh -u -R

    ## upgrade pip
    # pip install --user pip --upgrade
    # pip install --user pip --upgrade --force-reinstall

    ## install current directory into ${HOME}/.local
    # pip install --user $(pwd)
    # pip install --user --editable $(pwd)


Reuse
======
From ``scripts/bootstrap_dotfiles.sh``: ``dotfiles_symlink_all``::

    # {{ full_name }}
    symlink_gitconfig
    symlink_hgrc
    symlink_mutt
