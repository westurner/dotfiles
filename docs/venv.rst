
.. index:: dotfiles.venv
.. index:: Venv
.. _venv:   

Venv
======

Overview
----------
Venv makes working with :ref:`virtualenvwrapper`, :ref:`Bash`, 
:ref:`Vim`, and :ref:`IPython` within a project context very easy.

There are a few parts to "``venv``":

* `ipython_config.py`_
  (:py:mod:`dotfiles.venv.ipython_config`)
  provides a `shell command`_ (``venv.py``)
  for verbosely generating source-able `shell configuration`_
  for a :ref:`virtualenv`
  and :ref:`IPython`,
  and generates
  :py:class:`CdAlias <dotfiles.venv.ipython_config.CdAlias>`
  scripts for Bash, ZSH, IPython, and Vim

* `ipython_magics.py`_
  (:py:mod:`dotfiles.venv.ipython_magics`) 
  configures
  :py:class:`CdAliases <dotfiles.venv.ipython_config.CdAlias>`
  (``cdwrk``, ``cdv``, ``cdsrc``, ``cdwrd``)
  and ``dotfiles_status`` (``ds``)
  for :ref:`IPython`.

* `10-bashrc.venv.sh`_
  (:ref:`Usage > Bash <dotfiles_bash_config>`) 
   
  * for :ref:`Bash` (and :ref:`ZSH`)
  * sets ``$__WRK``, ``$__DOTFILES``, and ``$WORKON_HOME``;
  * defines functions like ``we()`` and ``e()``

.. _10-bashrc.venv.sh:
    https://github.com/westurner/dotfiles/blob/master/etc/bash/10-bashrc.venv.sh
.. _ipython_config.py:
    https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/ipython_config.py
.. _ipython_magics.py:
    https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/ipython_magics.py



Quickstart
===========

.. code-block:: bash


    # print shell configuration for a (hypothetical) dotfiles virtualenv
    venv --print-bash dotfiles

    # print shell configuration for the current ${VIRTUAL_ENV} [and ${_WRD}]
    venv --print-bash -E

    # run a bash subprocess within a virtual env
    venv -x bash dotfiles
    venv -xb dotfiles

    # workon a virtualenvwrapper virtualenv (source <(venv -E --print-bash))
    we dotfiles

    # workon ${WORKON_HOME}/dotfiles/src/otherproject (echo $_APP $_WRD)
    we dotfiles otherproject


Usage
=========

.. code-block:: bash


   __WRK="~/-wrk"                                # cdwrk # workspace
   __DOTFILES="~/-dotfiles"                      # cdd cddotfiles
   PROJECT_HOME="${__WRK}"                       # cdph cdprojecthome
   WORKON_HOME="${__WRK}/-ve27"                  # cdwh cdworkonhome

   __VENV=$(which venv.py);
   # ${__DOTFILES}/src/dotfiles/venv/ipython_config.py  # source
   # ${__DOTFILES}/etc/ipython/ipython_config.py        # symlink
   # ~/.ipython/profile_default/ipython_config.py       # symlink
   # ${__DOTFILES}/scripts/venv.py                      # symlink ($PATH)
   # ${VIRTUAL_ENV}/bin/venv                      # setup.py console_script
   # ~/.local/bin/venv                            # setup.py console_script

   __VENV="${__DOTFILES}/scripts/venv.py"               # 10-bashrc.venv.sh
   # venv()                 -- (set -x; $__VENV $@)     # 10-bashrc.venv.sh
   # venv-()                -- (set -x; $__VENV -e $@)  # 10-bashrc.venv.sh

   $__VENV --help
   venv.py --help
   venv -h

   # Generate venv CdAlias scripts
   venv.py --print-bash-cdalias . | tee venv_cdalias.sh
   venv.py --print-ipython-cdalias . | tee venv_cdmagic.py
   venv.py --print-vim . | tee venv.vim

   # Generate venv configuration for the "dotfiles" virtualenv
   venv.py --print-vars --VIRTUAL_ENV="${WORKON_HOME}/dotfiles"
   venv.py --print-vars --virtual-env="${WORKON_HOME}/dotfiles"
   venv.py --print-vars --ve="${WORKON_HOME}/dotfiles"
   venv.py --print-vars --ve dotfiles
   venv.py --print-vars dotfiles
   venv.py --print-vars dotfiles
   venv.py --print-bash dotfiles

   ## Workon the dotfiles virtualenv
   source <(venv.py -q --print-bash dotfiles)

   ## Workon the dotfiles virtualenv (with a bash subprocess)
   venv.py -xb dotfiles

   ## Workon the dotfiles virtualenv (after virtualenvwrapper workon)
   workon dotfiles
   source <(venv.py -q --print-bash --from-environ)


   ## Note: the following two commands are different to argparse:
   ## (positional VENVSTR and VENVSTRAPP must come last,
   ##  or be specified as --ve and --app)
   venv dotfiles --print-bash        # does not work
   venv --print-bash dotfiles        # does work


CdAlias
-----------------
Each :py:class:`CdAlias <dotfiles.venv.ipython_config.CdAlias>`
in ``env.aliases`` is expanded for each output type.

For example, ``CdAlias('__WRK')`` becomes ``cdwrk``, ``%cdwrk``, and ``:Cdwrk``:

.. code:: bash

  # Bash
  cdwrk
  cdwrk<tab>
  cdwrk -ve27

  # IPython
  %cdwrk
  cdwrk
  cdwrk -ve27

  # Vim
  call Cd___WRK()
  :Cdwrk
  :Cdwrk -ve27



Usage
------

Shell Command
~~~~~~~~~~~~~~
.. command-output:: python ../src/dotfiles/venv/ipython_config.py --help
   :shell:


Python API
~~~~~~~~~~~~
Python API (see Test_Env, Test_venv_main):
A :py:mod:`dotfiles.venv.ipython_config.Venv` object
builds a :py:mod:`dotfiles.venv.ipython_config.Env` OrderedDict
(``.env``)
with ``$VIRTUAL_ENV``-relative paths and environment variables
in a common filesystem hierarchy
and an OrderedDict of
command aliases (``.aliases``), which can be serialized to
a bash script (``venv --bash``), JSON (``venv --print``),
and IPython configuration.




Example Venv Configuration
----------------------------

Shell Configuration
~~~~~~~~~~~~~~~~~~~~
``venv.py --print-bash --compress dotfiles``:

.. command-output:: python ../scripts/venv.py --print-bash --compress dotfiles \
   | sed "s,${HOME},~,g"
   :shell:


JSON Configuration
~~~~~~~~~~~~~~~~~~~
``venv.py --print-json dotfiles``:

.. command-output:: python ../scripts/venv.py --print-json dotfiles \
   | python ../scripts/venv.py --compress dotfiles \
   | sed "s,${HOME},~,g"
   :shell:


Other scripts with venv-style paths
======================================
To define a script environment just like venv:

.. code:: bash

   #!/bin/sh

   __WRK="${HOME}/-wrk"                          # cdwrk
   __DOTFILES="${HOME}/-dotfiles"                # cdd cddotfiles
   PROJECT_HOME="${__WRK}"                       # cdph cdprojecthome
   WORKON_HOME="${__WRK}/-ve27"                  # cdwh cdworkonhome

   VIRTUAL_ENV_NAME="dotfiles"                   # 'dotfiles'
   _APP=$VIRTUAL_ENV_NAME                        # 'dotfiles[/p/a/t/h]'
   VIRTUAL_ENV="$WORKON_HOME/$VIRTUAL_ENV_NAME"  # cdv cdvirtualenv
   _SRC="${VIRTUAL_ENV}/src"                     # cds cdsrc
   _BIN="${VIRTUAL_ENV}/bin"                     # cde cdbin
   _ETC="${VIRTUAL_ENV}/etc"                     # cde cdetc
   _LOG="${VIRTUAL_ENV}/var/log"                 # cdl cdlog
   # ... see: venv.py --print-vars / ...
   _WRD="${_SRC}/{_APP}"                         # cdw cdwrd

   (set -x; test "$_WRD" == "${HOME}/-wrk/-ve27/dotfiles/src/dotfiles"; \
       || echo "Exception: _WRD = '${_WRD}';" )

SeeAlso: ``unittest.TestCase`` tests in :py:mod:`dotfiles.venv.ipython_config`
(`ipython_config.py`_).
