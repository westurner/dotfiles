#!/usr/bin/env python
# dotfiles.venv
"""

Objectives
------------
- Set variables for standard paths in the environment dict
- Define IPython aliases
- Serialize variables and aliases to:

  - IPython configuration (variables, aliases)
  - Bash/zsh configuration (variables, aliases, functions) [``--bash``]
  - JSON (variables, aliases) [``--print``]

For historical and consistency reasons, all "``venv``" Python code
is contained within the ``ipython_config.py`` file, which depends
only upon the Python standard library.


Configuration
---------------
Flexible symlink paths relative to ``${__DOTFILES}``

.. code-block:: bash

    __DOTFILES="~/.dotfiles"

    # Working directory (path to the dotfiles repository)
    _WRD=${WORKON_HOME}/dotfiles/src/dotfiles

    # stored in the dotfiles git repository
    ln -s ${_WRD}/src/dotfiles/venv/ipython_config.py \\
          ${_WRD}/etc/ipython/ipython_config.py

    # automatically created by ``bootstrap_dotfiles.sh -S``
    ln -s ${_WRD}/src/dotfiles/venv/ipython_config.py \\
          ${__DOTFILES}/etc/ipython/ipython_config.py

    # manually installed for an IPython profile
    ln -s ${__DOTFILES}/etc/ipython/ipython_config.py \\
          ~/.ipython/profile_default/ipython_config.py

"""

from dotfiles.venv import ipython_config
__ALL__ = ['ipython_config']
