#!/usr/bin/env python
# dotfiles.venv
"""

Objectives
------------
:py:mod:`dotfiles.venv.ipython_config` (`ipython_config.py`_):

- Set variables for standard :ref:`Virtualenv` paths in the environment dict
- Define :ref:`IPython` aliases
- Serialize variables and aliases to:

  - :ref:`IPython` configuration (variables, aliases)
  - :ref:`Bash`/:ref:`ZSH` configuration (variables, aliases, functions):

    * ``venv -E --bash``
    * ``venv dotfiles --bash``

  - :ref:`JSON` (variables, aliases) [``--print``]

    * ``venv -E --json``
    * ``venv dotfiles json``

:py:mod:`dotfiles.venv.ipython_magics` (`ipython_magics.py`_):

- Configure :ref:`IPython` ``%magic`` commands

  - ``cd*`` -- change directories (``%cdhelp``, ``%cdp``, ``%cdwh``, ``%cdv``,
    ``%cds``, ``%cdw``)
  - ``ds``  -- print dotfiles_status

.. _ipython_config.py: https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/ipython_config.py
.. _ipython_magics.py: https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/ipython_magics.py


Configuration
---------------

Shell
~~~~~~~
For Bash/ZSH, ``etc/bash/10-bashrc.venv.sh`` sets:

.. code-block:: bash

    # ...
    _VENV="${__DOTFILES}/etc/ipython/ipython_config.py"
    venv() {
        $_VENV $@
    }
    # ...

``etc/bash/10-bashrc.venv.sh`` is sourced by
``etc/bash/00-bashrc.before.sh``, which is sourced by ``~/.bashrc``
(a symlink to ``${__DOTFILES}/etc/bashrc`` created by
:ref:`bootstrap_dotfiles.sh -S <bootstrap_dotfiles>`).


IPython
~~~~~~~~

To configure IPython with venv, `ipython_config.py`_
must be symlinked into ``~/.ipython/profile_default``
(and, optionally,
`ipython_magics.py`_ into ``~/.ipython/profile_default/startup/``):

.. code-block:: bash

    # symlink paths relative to ${__DOTFILES}
    __DOTFILES="~/.dotfiles"

    # working directory (path to the dotfiles repository)
    _WRD=${WORKON_HOME}/dotfiles/src/dotfiles

    # created by ``bootstrap_dotfiles.sh -S``
    # ln -s ${_WRD} ${__DOTFILES}
    # ln -s ${__DOTFILES}/etc/bashrc ~/.bashrc
    # ln -s ${_WRD}/etc/ipython/ipython_config.py \\
    #       ${__DOTFILES}/etc/ipython/ipython_config.py

    # MANUALLY INSTALL for each IPython profile
    IPY_PROFILE="profile_default"
    ln -s ${__DOTFILES}/etc/ipython/ipython_config.py \\
          ~/.ipython/${IPY_PROFILE}/ipython_config.py

    ln -s ${__DOTFILES}/etc/ipython/ipython_magics.py \\
          ~/.ipython/${IPY_PROFILE}/ipython_magics.py

"""

from dotfiles.venv import ipython_config
__ALL__ = ['ipython_config']
