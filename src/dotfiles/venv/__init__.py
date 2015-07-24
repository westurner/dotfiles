#!/usr/bin/env python
# dotfiles.venv
"""

Objectives
------------
:py:mod:`dotfiles.venv.venv_ipyconfig` (`venv_ipyconfig.py`_):

- Set variables for standard :ref:`Virtualenv` paths in the environment dict
  (":ref:`Venv Paths`")
- Define :ref:`IPython` aliases (``%aliases``)
- Serialize variables and aliases to:

  - :ref:`IPython` configuration (variables, aliases)
  - :ref:`Bash`/:ref:`ZSH` configuration (variables, aliases, functions):

    .. code:: bash

        venv.py -e --bash        # venv --print-bash --from-environ
        venv.py dotfiles --bash  # venv --print-bash --wh=~/-wrk/-ve27 --ve=dotfiles

  - :ref:`JSON-` (variables, aliases) [``--print``]:

    .. code:: bash

        venv.py -e --json
        venv.py dotfiles --json

:py:mod:`dotfiles.venv.venv_ipymagics` (`venv_ipymagics.py`_):

- Configure :ref:`IPython` ``%magic`` commands

  - ``ds``  -- print dotfiles_status
  - ``cd*`` -- :ref:`CdAliases` for :ref:`Venv Paths`
    (e.g. ``%cdhelp``, ``%cdp``, ``%cdwh``, ``%cdv``, ``%cds``, ``%cdw``)

.. _venv_ipyconfig.py: https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/venv_ipyconfig.py
.. _venv_ipymagics.py: https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/venv_ipymagics.py


Configuration
---------------

Shell
~~~~~~~


**:ref:`dotfiles` configuration`**

.. code-block:: bash

    # TODO:

    source ${__DOTFILES}/scripts/venv.sh
    source ${__VENV}/scripts/venv.sh

    build-venv.sh:
        cat venv_core.sh > venv.sh
        cat venv_cdaliases >> venv.sh

    source ${__DOTFILES}/etc/bash/10-bashrc.venv.sh   # venv(), workon_venv
        source ${__DOTFILES}/scripts/venv.sh          # cdaliases, work

``etc/bash/10-bashrc.venv.sh`` is sourced by
``etc/bash/00-bashrc.before.sh``, which is sourced by ``~/.bashrc``
(a symlink to ``${__DOTFILES}/etc/.bashrc`` created by
:ref:`bootstrap_dotfiles.sh -S <bootstrap_dotfiles.sh>`).


IPython
~~~~~~~~

To configure :ref:`IPython` with venv, `venv_ipyconfig.py`_
must be symlinked into ``~/.ipython/profile_default/ipython_config.py``
and, optionally, for :ref:`CdAliases`,
`venv_ipymagics.py`_ must be symlinked
into e.g. ``~/.ipython/profile_default/startup/20-venv_ipymagics.py``):

.. code-block:: bash

    # symlink paths relative to ${__DOTFILES}
    __DOTFILES="~/-dotfiles"
    # working directory (path to the dotfiles repository)
    _WRD=${WORKON_HOME}/dotfiles/src/dotfiles

    # MANUALLY INSTALL for each IPython profile
    IPY_PROFILE="profile_default"
    ln -s ${__DOTFILES}/scripts/venv_ipyconfig.py \\
          ~/.ipython/${IPY_PROFILE}/ipython_config.py

    ln -s ${__DOTFILES}/scripts/venv_ipymagics.py \\
          ~/.ipython/${IPY_PROFILE}/startup/20-venv_ipymagics.py

"""
