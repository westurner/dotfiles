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

.. code-block:: bash

    # symlink paths relative to ${__DOTFILES}
    __DOTFILES="~/.dotfiles"

    # working directory (path to the dotfiles repository)
    _WRD=${WORKON_HOME}/dotfiles/src/dotfiles

    # already stored in the dotfiles git repository
    ln -s ${_WRD}/src/dotfiles/venv/ipython_config.py \\
          ${_WRD}/etc/ipython/ipython_config.py

    # automatically created by ``bootstrap_dotfiles.sh -S``
    ln -s ${_WRD}/etc/ipython/ipython_config.py \\
          ${__DOTFILES}/etc/ipython/ipython_config.py

    # manually installed for each IPython profile
    IPY_PROFILE="profile_default"
    ln -s ${__DOTFILES}/etc/ipython/ipython_config.py \\
          ~/.ipython/${IPY_PROFILE}/ipython_config.py

    ln -s ${__DOTFILES}/etc/ipython/ipython_magics.py \\
          ~/.ipython/${IPY_PROFILE}/ipython_magica.py

"""

from dotfiles.venv import ipython_config
__ALL__ = ['ipython_config']
