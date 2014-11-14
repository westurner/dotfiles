
.. index:: dotfiles.venv
.. index:: Venv
.. _venv:   

Venv
======

Venv makes working with :ref:`virtualenvwrapper`, :ref:`Bash`,
and :ref:`IPython` very easy.

There are three parts to "``venv``":

* `10-bashrc.venv.sh`_  
* `dotfiles.venv.ipython_config.py`_
* `dotfiles.venv.ipython_magics.py`_
  
`10-bashrc.venv.sh`_ (:ref:`docs <dotfiles_bash_config`_) 
configures variables like ``$VIRTUAL_ENV_NAME``, ``$_SRC``, and ``$_WRD``;
and functions like ``we()`` and ``e()`` for :ref:`Bash` (and :ref:`ZSH`).

`dotfiles.venv.ipython_config.py`_ (:py:mod:`dotfiles.venv.ipython_config`)
provides a `shell command`_ called by ``we()``
for generating `shell configuration`_ for a :ref:`virtualenv`
and configures :ref:`IPython`.

`dotfiles.venv.ipython_magics.py`_
(:py:mod:`dotfiles.venv.ipython_magics`) 
configures the same ``cd`` commands
and ``ds`` command defined in ``10-bashrc.venv.sh`` and
``ipython_config.py`` for use in :ref:`IPython`.


.. _10-bashrc.venv.sh: https://github.com/westurner/dotfiles/blob/master/etc/bash/10-bashrc.venv.sh
.. _dotfiles.venv.ipython_config.py: https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/ipython_config.py
.. _dotfiles.venv.ipython_magics.py: https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/ipython_magics.py



Quickstart
-----------

.. code-block:: bash


    # print shell configuration for a (hypothetical) dotfiles virtualenv
    venv dotfiles --bash

    # print shell configuration for the current ${VIRTUAL_ENV} [and ${_WRD}]
    venv -E --bash

    # run a command within a virtualenv
    venv dotfiles -x bash

    # workon a virtualenvwrapper virtualenv (we) (source <(venv -E --bash))
    we dotfiles

    # workon ${WORKON_HOME}/dotfiles/src/otherproject (echo $_APP $_WRD)
    we dotfiles otherproject


Usage
------

Shell Command
~~~~~~~~~~~~~~
.. command-output:: python ../src/dotfiles/venv/ipython_config.py --help
   :shell:


Python API
~~~~~~~~~~~~
A :py:mod:`dotfiles.venv.ipython_config.Venv` object
builds a :py:mod:`dotfiles.venv.ipython_config.Env` OrderedDict
(``.env``)
with ``$VIRTUAL_ENV``-relative paths and environment variables
in a common filesystem hierarchy
and an OrderedDict of
command aliases (``.aliases``), which can be serialized to
a bash script (``venv --bash``), JSON (``venv --print``),
and IPython configuration.

.. code-block:: python

    from dotfiles.venv.ipython_config import Venv
    venv = Venv(from_environ=True)
    venv.print()
    venv.bash_env()

    venv.configure_sys()
    venv.configure_ipython()

    assert venv.virtualenv  == venv.env['VIRTUAL_ENV']
    assert venv.appname     == venv.env['_APP']

    print(venv.env['_WRD'])     # working directory
    print(venv.aliases['e'])    # edit with --servername $_APP



Example Venv Configuration
----------------------------

Shell Configuration
~~~~~~~~~~~~~~~~~~~~
``venv dotfiles --bash``:

.. command-output:: python ../src/dotfiles/venv/ipython_config.py dotfiles --bash \
   | sed "s,${HOME},~,g"
   :shell:


JSON Configuration
~~~~~~~~~~~~~~~~~~~
``venv dotfiles --print``:

.. command-output:: python ../src/dotfiles/venv/ipython_config.py dotfiles --print \
   | sed "s,${HOME},~,g"
   :shell:

