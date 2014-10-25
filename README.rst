
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
* Support Debian Linux, Ubuntu Linux, OSX
* Configure Python, pip, virtualenv, virtualenvwrapper, IPython
* Document keyboard shortcuts

  
Usage
=======
| http://wrdfiles.readthedocs.org/en/latest/usage.html
| http://wrdfiles.readthedocs.org/en/latest/venv.html
| https://github.com/westurner/dotfiles/tree/master/etc/bash
| https://github.com/westurner/dotfiles/blob/master/etc/usrlog.sh
| https://github.com/westurner/dotfiles/blob/master/etc/ipython/ipython_config.py
| https://github.com/westurner/dotfiles/blob/master/etc/.gitconfig
| https://github.com/westurner/dotfiles/blob/master/etc/.hgrc

Bash
-----
Bash configuration chain-loads from ``etc/bash/00-bashrc.before.sh``.

.. code-block:: bash

   dotfiles_status  # print environment variables
   dotfiles_reload  # source dotfiles/etc/bash/*-bashrc.<name>.sh

.. code-block:: bash

   set | less
   set | grep '^_'

Symlinks
----------
Create symlinks in ``$HOME`` with `bootstrap_dotfiles.sh`_:

.. code-block:: bash

   bootstrap_dotfiles.sh -S



vimrc
------
| https://github.com/westurner/dotvim

Vim configuration should be cloned to ``etc/vim``
and installed (with vundle).

.. code-block:: bash

   make dotvim_clone dotvim_install


Installation
==============

Requirements
---------------
Project requirements are installed by 
`bootstrap_dotfiles.sh`_, which is called by the `Makefile`_.

* bash
* python
* git
* hg
* python setuptools
* python pip

| https://github.com/westurner/dotfiles/blob/master/requirements.txt
| https://github.com/westurner/dotfiles/blob/master/requirements/
| https://github.com/westurner/dotfiles/blob/master/docs/requirements.txt
| https://github.com/westurner/dotfiles/blob/master/scripts/bootstrap_dotfiles.sh

pip
~~~~
(Optional) Upgrade pip::

    # pip install pip --upgrade
    pip install --user pip
    pip install --user pip --upgrade
    # pip install --user pip --upgrade --force-reinstall


Makefile
---------
| https://github.com/westurner/dotfiles/blob/master/Makefile

``make install``
~~~~~~~~~~~~~~~~~
.. code-block:: bash

   make install


``make help``
~~~~~~~~~~~~~~~
.. code-block:: bash

   make help
   make help_vim
   make help_i3


bootstrap_dotfiles.sh
-----------------------
| https://github.com/westurner/dotfiles/blob/master/scripts/bootstrap_dotfiles.sh

The ``bootstrap_dotfiles.sh`` shell script 
clones this repository and
installs files from this python package:


Install the dotfiles
---------------------
.. code-block:: bash

    ## (Recommended) Create a virtualenv with virtualenvwrapper
    pip install --user virtualenvwrapper  # pip install --user virtualenv
    mkvirtualenv dotfiles          # virtualenv $VIRTUAL_ENV
                                   # VIRTUAL_ENV=$WORKON_HOME/dotfiles
    mkdir $VIRTUAL_ENV/src
    cd $VIRTUAL_ENV/src            # cds; cd $_SRC; # once installed
   
    # A. git clone (``bootstrap_dotfiles.sh -I``)
    # git clone ssh://git@github.com/westurner/dotfiles && cd dotfiles
    # make install install_hubflow

    # A. download bootstrap_dotfiles.sh to src/bootstrap_dotfiles.sh
    wget https://github.com/westurner/dotfiles/raw/master/scripts/bootstrap_dotfiles.sh

    ./bootstrap_dotfiles.sh -I     # clone and pip install
    ./bootstrap_dotfiles.sh -S     # symlink ./etc/{} into $HOME
                                   # and backup with a suffix
    ./bootstrap_dotfiles.sh -R     # pip install -r requirements

    ./bootstrap_dotfiles.sh -U     # pull, update, and upgrade

    ./bootstrap_dotfiles.sh -u     # add --user to pip commands

    ./bootstrap_dotfiles.sh -h     # help


Development
------------
(Optional) Install dotfiles as user::    

    ## install $(pwd)
    # pip install --user $(pwd)

(Optional) Development: install dotfiles as editable (RECOMMENDED):

.. code-block:: bash

    pip install --user -e git+https://github.com/westurner/dotfiles#egg=dotfiles
    pip install --user -e .


``make build``
~~~~~~~~~~~~~~~
.. code-block:: bash

   make test docs build


