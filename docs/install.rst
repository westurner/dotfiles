.. _install:

Install
=========

* :ref:`<bootstrap_dotfiles>`: `scripts/bootstrap_dotfiles.sh <https://github.com/westurner/dotfiles/blob/master/scripts/bootstrap_dotfiles.sh>`_
* :ref:`<install_python_package>`: `setup.py
  <https://github.com/westurner/dotfiles/blob/master/setup.py>`_

**For Development**
  * `Makefile <https://github.com/westurner/dotfiles/blob/master/Makefile>`_

.. _bootstrap_dotfiles::

Bootstrap dotfiles for the current user
-----------------------------------------

Install the dotfiles (clone, install, and symlink)::

    # download bootstrap script
    curl https://bitbucket.org/westurner/dotfiles/raw/tip/scripts/bootstrap_dotfiles.sh 

    # clone and install dotfiles package and symlinks from source
    bash ./bootstrap_dotfiles.sh -I

Reload::
   
    # reload bash configuration
    source ${HOME}/.bashrc

    # (or) start a new subshell
    (${SHELL})


Upgrade to trunk::

    # pull from trunk and install dotfiles
    bash ./bootstrap_dotfiles.sh -U


.. _install_python_package:

Install the dotfiles python package (user local)
--------------------------------------------------

* Install to ``${HOME}/.local``::

   make install_user
   # make upgrade_user
   # pip install --user --upgrade -e git+https://github.com/westurner/dotfiles#egg=dotfiles



Symlink dotfiles into place
-----------------------------

Symlink configuration files from ``dotfiles/etc``::

    bash ./scripts/bootstrap_dotfiles.sh -S

    ln -s ${_etc}/pip/


Print Dotfiles Documentation
---------------------------------
::

    make vim_help
    make help
