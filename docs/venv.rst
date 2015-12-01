
.. index:: dotfiles.venv
.. index:: Venv
.. _venv:   

======
Venv
======

Venv makes working with :ref:`virtualenv`, 
:ref:`virtualenvwrapper`, :ref:`Bash`, :ref:`ZSH`,
:ref:`Vim`, and :ref:`IPython` within a project context very easy.

There are a few parts to ``venv``:

* `ipython_config.py`_
  (:py:mod:`dotfiles.venv.ipython_config`) configures IPython at
  startup.
* `venv.py`_ is a symlink to ``ipython_config.py``.
* `venv.py`_ is a CLI script for generating `shell configuration`_
  and `CdAlias`_
  scripts for :ref:`Bash`, :ref:`ZSH`, :ref:`IPython`, and :ref:`Vim`.

* `ipython_magics.py`_
  (:py:mod:`dotfiles.venv.ipython_magics`) 
  configures
  :py:class:`CdAliases <dotfiles.venv.ipython_config.CdAlias>`
  and the ``dotfiles_status`` (``ds``) command
  for :ref:`IPython`.

* `10-bashrc.venv.sh`_ configures :ref:`Bash` at startup
  (see: :ref:`Usage > Bash <dotfiles_bash_config>`)

To configure a shell, print relevant env variables (twice),
``cd`` to the working directory (``$_WRD``),
and open ``README.rst`` in a named :ref:`Vim` server for an existing
venv named ``dotfiles``:

.. code-block:: bash

   we dotfiles; ds; cdwrd; e README.rst
 
.. note::
    For a new venv (as might be created with ``mkvirtualenv dotfiles``),
    the ``$_SRC`` and ``$_WRD`` directories do not yet exist. You can
    create these like so:

    .. code-block:: bash

        ## _APP=dotfiles _WRD=$VIRTUAL_ENV/src/$_APP
        mkdir -p $_WRD

    Or, to create a more complete :ref:`FHS` tree of directories under
    ``$VIRTUAL_ENV``:

    .. code-block:: bash

        venv_mkdirs; mkdir -p $_WRD

        

.. _10-bashrc.venv.sh:
    https://github.com/westurner/dotfiles/blob/master/etc/bash/10-bashrc.venv.sh
.. _ipython_config.py:
    https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/ipython_config.py
.. _ipython_magics.py:
    https://github.com/westurner/dotfiles/blob/master/src/dotfiles/venv/ipython_magics.py




Working With Venv
===================

To work on a venv:

.. code-block:: bash

    we dotfiles


``we`` is an alias for ``workon_venv``, which does
``source <(venv.py -q --print-bash --ve=dotfiles)``.


Verbosely:

.. code-block:: bash

   __WRK="~/-wrk"                    # cdwrk
   PROJECT_HOME="${__WRK}"           # cdph cdprojecthome
   WORKON_HOME="${__WRK}/-ve27"      # cdwh cdworkonhome
   __DOTFILES="~/-dotfiles"          # cdd  cddotfiles
                                     # a very special symlink to
                                     # $WORKON_HOME/dotfiles/src/dotfiles

   __VENV=$(which venv.py);
   __VENV="${__DOTFILES}/scripts/venv.py"  # 10-bashrc.venv.sh
   # venv()  { (set -x; $__VENV $@)    }   # 10-bashrc.venv.sh
   # venv-() { (set -x; $__VENV -e $@) }   # 10-bashrc.venv.sh

   # These all print venv.py --help:
   $__VENV --help
   venv.py --help
   venv -h

   # Print environment variables for the "dotfiles" venv:
   venv.py --print-vars --VIRTUAL_ENV="${WORKON_HOME}/dotfiles"
   venv.py --print-vars --virtual-env="${WORKON_HOME}/dotfiles"
   venv.py --print-vars --ve="${WORKON_HOME}/dotfiles"
   venv.py --print-vars --ve dotfiles
   venv.py --print-vars dotfiles

   # Generate a source-able Bash configuration script
   venv.py --print-bash dotfiles

   ## Workon the dotfiles virtualenv (in the current shell)
   we dotfiles

   ## Workon the dotfiles virtualenv (with a bash subshell)
   venv.py -x bash dotfiles
   venv.py -xb dotfiles


.. note:: The following commands are different to argparse
   (argument order matter with positional arguments)

   .. code-block:: bash

       venv dotfiles --print-bash        # does not work
       venv --print-bash dotfiles        # does work

       # As a workaround, be explicit
       venv --ve=dotfiles --print-bash   # does work


CdAlias
-----------------
Virtualenv paths can be really long.

CdAliases make it easy to jump around to ``venv`` defined variables
(like ``$_WRK`` (cdwrk), ``$WORKON_HOME`` (cdwh), ``VIRTUAL_ENV`` (cdv),
``$_SRC`` (cds), and ``$_WRD`` (cdw)). 

Each :py:class:`CdAlias <dotfiles.venv.ipython_config.CdAlias>`
defined in ``env.aliases`` is expanded for Bash, IPython, and Vim.
For example, ``CdAlias('__WRD')`` is expanded to
``cdwrd``, ``cdw``; ``%cdwrd``, ``cdw``, and ``:Cdwrk``,
``:Cdw``:

.. code:: bash

  # Bash
  cdwrd
  cdwrd<tab>
  cdwrd docs/
  cdw docs/

  # IPython
  %cdwrd
  cdwrd
  cdwrd docs/
  cdw docs/

  # Vim
  :Cdwrk
  :Cdwrk docs/
  :Cdw docs/

At build time, the dotfiles Makefile generates the venv CdAlias scripts
like so:

.. code:: bash

    # Generate venv CdAlias scripts
    venv.py --print-bash-cdalias . | tee venv_cdalias.sh
    venv.py --print-ipython-cdalias . | tee venv_cdmagic.py
    venv.py --print-vim . | tee venv.vim

Subsequently, ``cdhelp`` displays:

.. code:: bash

  ## venv.sh
  # generated from $(venv --print-bash --prefix=/)
      # cdhome            -- cd $HOME /$@
      # cdh               -- cd $HOME
      # cdwrk             -- cd $__WRK /$@
      # cddotfiles        -- cd $__DOTFILES /$@
      # cdd               -- cd $__DOTFILES
      # cdprojecthome     -- cd $PROJECT_HOME /$@
      # cdp               -- cd $PROJECT_HOME
      # cdph              -- cd $PROJECT_HOME
      # cdworkonhome      -- cd $WORKON_HOME /$@
      # cdwh              -- cd $WORKON_HOME
      # cdve              -- cd $WORKON_HOME
      # cdcondaenvspath   -- cd $CONDA_ENVS_PATH /$@
      # cda               -- cd $CONDA_ENVS_PATH
      # cdce              -- cd $CONDA_ENVS_PATH
      # cdvirtualenv      -- cd $VIRTUAL_ENV /$@
      # cdv               -- cd $VIRTUAL_ENV
      # cdsrc             -- cd $_SRC /$@
      # cds               -- cd $_SRC
      # cdwrd             -- cd $_WRD /$@
      # cdw               -- cd $_WRD
      # cdbin             -- cd $_BIN /$@
      # cdb               -- cd $_BIN
      # cdetc             -- cd $_ETC /$@
      # cde               -- cd $_ETC
      # cdlib             -- cd $_LIB /$@
      # cdl               -- cd $_LIB
      # cdlog             -- cd $_LOG /$@
      # cdpylib           -- cd $_PYLIB /$@
      # cdpysite          -- cd $_PYSITE /$@
      # cdsitepackages    -- cd $_PYSITE
      # cdvar             -- cd $_VAR /$@
      # cdwww             -- cd $_WWW /$@
      # cdww              -- cd $_WWW


venv.py
--------------
.. command-output:: python ../src/dotfiles/venv/ipython_config.py --help
   :shell:


Python API
~~~~~~~~~~~~
A :py:mod:`dotfiles.venv.ipython_config.Venv` object
builds:

* a :py:mod:`dotfiles.venv.ipython_config.Env` ``OrderedDict``
  with ``$VIRTUAL_ENV``-relative paths and environment variables
  in a standard filesystem hierarchy
* an ``OrderedDict`` of command and `CdAlias`_ aliases
  
A :py:mod:`dotfiles.venv.ipython_config.Venv` object can then be
serialized:

* ``--print-vars`` -- easy to read variables
* ``--print-json`` -- quoted and escaped JSON
* ``--print-bash`` -- quoted and escaped shell script
* IPython ``%alias`` configuration dict (see ``%alias?``)

There are a number of ``unittest.TestCase`` tests in
:py:mod:`dotfiles.venv.ipython_config` (`ipython_config.py`_)
for each of the build steps.

``venv --verbose --show-diffs`` shows what is going on.


Example Venv Configuration
----------------------------

Shell Configuration
~~~~~~~~~~~~~~~~~~~~
``venv.py --print-bash --compress dotfilesx dotfilesx/docs``:

.. command-output:: python ../scripts/venv.py --print-bash --compress dotfilesx dotfilesx/docs \
   | sed "s,${HOME},~,g"
   :shell:

.. note:: The ``--compress`` option is for documentation purposes only;
   without this option, paths are expanded in full.


JSON Configuration
~~~~~~~~~~~~~~~~~~~
``venv.py --print-json dotfiles``:

.. command-output:: python ../scripts/venv.py --print-json dotfilesx dotfilesx/docs \
   | python ../scripts/venv.py --compress dotfilesx dotfilesx/docs \
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

