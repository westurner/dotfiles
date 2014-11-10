
===========
dotfiles
===========

`GitHub`_ | `BitBucket`_ | `Documentation`_

.. _GitHub: https://github.com/westurner/dotfiles
.. _BitBucket: https://bitbucket.org/westurner/dotfiles
.. _Documentation: https://westurner.github.io/dotfiles/   
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
* Configure gnome, i3wm  
* Document keyboard shortcuts

  
Usage
=======

* ``etc/.bashrc`` loads ``etc/bash/00-bashrc.before.sh``
* ``etc/bash/00-bashrc.before.sh`` loads a documented,
  ordered sequence of bash scripts
* ``etc/zsh/00-zshrc.before.sh`` loads a documented,
  ordered sequence of zsh scripts
* https://westurner.github.io/dotfiles/usage.html documents 
* https://westurner.github.io/dotfiles/venv.html documents
  the venv (``ipython_config.py``) script, which generates shell
  configuration

Examples
------------

Installing the dotfiles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash


    # clone and install dotfiles and dotvim
    # with static dotfiles.venv style paths (_APP, _SRC, _WRD)

    # WORKON_HOME   -- virtualenvwrapper setting
    WORKON_HOME="~/wrk/.ve"
    test -d ${WORKON_HOME} || mkdir -p ${WORKON_HOME}

    # VIRTUAL_ENV_NAME  -- basename for VIRTUAL_ENV ('dotfiles') [venv]
    VIRTUAL_ENV_NAME="dotfiles"

    # VIRTUAL_ENV       -- virtualenv prefix
    VIRTUAL_ENV="${WORKON_HOME}/${VIRTUAL_ENV_NAME}"
    _SRC="$[VIRTUAL_ENV}/src"

    _APP="dotfiles"
    _WRD="${_SRC}/${_APP}"      # $WORKON_HOME/dotfiles/src/ dotfiles
    git clone https://github.com/westurner/dotfiles $_WRD
    git clone https://github.com/westurner/dotvim $_WRD/etc/vim
    cd $_WRD                    # cdw(), grinw(), grindw()

    __DOTFILES="${HOME}/.dotfiles"
    ln -s $_WRD $__DOTFILES
    ls ~/.dotfiles
   
    # If 'make' is not installed for 'make help install':
    $_WRD/scripts/bootstrap_dotfiles.sh -h
    $_WRD/scripts/bootstrap_dotfiles.sh -I

    # TODO: move / replicate this in bootstrap_dotfiles.sh


Bash
-----
| https://github.com/westurner/dotfiles/tree/master/etc/bash


.. code:: bash

    # There should be a symlink from ~/.dotfiles
    # to the current dotfiles repository.
    ls -ld ~/.dotfiles || ln -s ${_WRD} $__DOTFILES

    # There should be symlinks for each app; e.g.
    # ln -s ~/.dotfiles/etc/.bashrc ~/.bashrc
    # ln -s ~/.dotfiles/etc/vim/vimrc ~/.vimrc
    # ln -s ~/.dotfiles/etc/vim ~/.vim
    $_WRD/scripts/bootstrap_dotfiles.sh -S


.. code:: bash
   
   source ~/.bashrc
   # source dotfiles/etc/bash/00-bashrc.before.sh


.. code-block:: bash

   dotfiles_status  # print dotfiles environment variables
   ds               # print dotfiles environment variables
   dotfiles_reload  # source dotfiles/etc/bash/00-bashrc.before.sh
   dr               # source dotfiles/etc/bash/00-bashrc.before.sh



vimrc
------
| https://github.com/westurner/dotvim

Vim configuration should be cloned to ``etc/vim``.

.. code-block:: bash

   make dotvim_clone dotvim_install


Installation
==============

Requirements
---------------
Project requirements are installed by 
`bootstrap_dotfiles.sh`_ and, optionally, also the `Makefile`_.

* bash
* python
* git
* hg
* python setuptools
* python pip

.. _bootstrap_dotfiles.sh: https://github.com/westurner/dotfiles/blob/master/scripts/bootstrap_dotfiles.sh

Install the dotfiles
---------------------
| Src: https://github.com/westurner/dotfiles

The `bootstrap_dotfiles.sh`_ shell script 
clones the ``dotfiles`` git repository
and installs the ``dotfiles`` Python package.

.. code-block:: bash

    git clone ssh://git@github.com/westurner/dotfiles && cd dotfiles
    bootstrap_dotfiles.sh -I  

.. code-block:: bash

   # Install and symlink dotfiles and dotvim
   scripts/bootstrap_dotfiles.sh -I

   # Install and symlink dotfiles into ~/.local (optional)
   scripts/bootstrap_dotfiles.sh -I -u


Upgrade the dotfiles
----------------------

.. code-block:: bash

   # Check for any changes to symlinked dotfiles
   cd ~/.dotfiles && git status && git diff

   # Pull and upgrade dotfiles and dotvim (later)
   scripts/bootstrap_dotfiles.sh -U
   scripts/bootstrap_dotfiles.sh -U -i (optional)



Create a virtualenv
---------------------
.. code-block:: bash

    ## (Recommended) Create a virtualenv with virtualenvwrapper
    pip install --user virtualenvwrapper  # pip install --user virtualenv
    source $(which 'virtualenvwrapper.sh')
    mkvirtualenv dotfiles          # virtualenv $VIRTUAL_ENV
                                   # VIRTUAL_ENV=$WORKON_HOME/dotfiles
    mkdir $VIRTUAL_ENV/src
    cd $VIRTUAL_ENV/src            # cds; cd $_SRC; # once installed



Makefile
---------
| https://github.com/westurner/dotfiles/blob/master/Makefile


``make help``
~~~~~~~~~~~~~~~
.. code-block:: bash

  make help
  make help_vim
  make help_i3

``make install``
~~~~~~~~~~~~~~~~~
.. code-block:: bash

 make install



``make build``
~~~~~~~~~~~~~~~
.. code-block:: bash

   make test docs build


