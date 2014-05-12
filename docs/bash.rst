

.bashrc
=========

Bash Load Sequence

:: 

    $ bash
    # (~/.bashrc)                    -> ./etc/.bashrc
    #    -> (~/00-bashrc.before.sh)  -> ./etc/00-bashrc.before.sh


etc/.bashrc
-----------------
Deliberately minimal ``.bashrc``. Should be symlinked to
``~/.bashrc``.

**Sources**:

- ``etc/bash/00-bashrc.before.sh``

etc/bash/00-bashrc.before.sh
------------------------------
Sources all other etc/bash/\d\d-bashrc.*.sh scripts
explicitly.

Sourced by ``~/.bashrc``.

.. program-include:: cat ../etc/bash/00-bashrc.before.sh

~/.projectsrc.sh
--------------------
``${__WORKSPACE}/projectsrc.sh``

System-local bash configuration.


etc/bash/07-bashrc.virtualenv.sh
----------------------------------
Virtual python environment builder

**Install**::

    pip install virtualenv

**Sources**:

- https://pypi.python.org/pypi/virtualenv
- https://github.com/pypa/virtualenv/ 

**Documentation**:

- https://virtualenv.pypa.io/en/latest/
- http://virtualenv.readthedocs.org/en/latest/


virtualenvwrapper
------------------
Enhancements to virtualenv

**Install**::

    # install virtualenvwrapper
    pip install virtualenvwrapper

    # configure virtualenvwrapper shell variables
    grep WORKON_HOME ~/.bashrc.venv.sh
    grep VIRTUALENVWRAPPER_SCRIPT ~/.bashrc.venv.sh
    
**Sources**:

- https://pypi.python.org/pypi/virtualenvwrapper 
- https://bitbucket.org/dhellmann/virtualenvwrapper

**Documentation**:

- http://virtualenvwrapper.readthedocs.org/en/latest/
- http://virtualenvwrapper.readthedocs.org/en/latest/scripts.html



etc/bash/10-bashrc.venv.sh
----------------------------
Configures ``${__WORKSPACE}`` and ``${WORKON_HOME}`` for
**virtualenvwrapper** and **venv**.

**Sources**:

- ``etc/.bashmarks.sh``
- ``etc/usrlog.sh``
- ``${__WORKSPACE}/.projectsrc.sh``



etc/bash/30-bashrc.usrlog.sh
------------------------------
``etc/scripts/usrlog.sh``

Delimited and timestamped terminal history with lightweight 'sessions'

Each invocation of bash or zsh generates a new TERM_ID string which is
prepended to the terminal history record.

TERM_ID values are random, but can be set by calling ``stid``
::

    echo $TERM_ID
    # 0eZfHHVar76

    # Set a new TERM_ID
    stid

    echo $TERM_ID
    BUaOZ2FshNk

    # Specify a TERM_ID
    stid app_configuration
    
    echo $TERM_ID
    app_configuration


::

    # term_id ::: 0eZfHHVar76 [ ./dotfiles/.usrlog ]
    $


**$VIRTUAL_ENV**

When ``$VIRTUAL_ENV`` is set in the environment, terminal history is
appended to ``$VIRTUAL_ENV``-specific ``_USRLOG`` and ``HISTFILE`` files.

::

    tail -n 5 ~/.usrlog
    tail -n 5 ~/.virtualenvs/dotfiles/.usrlog


etc/bash/50-bashrc.bashmarks.sh
---------------------------------
``etc/bashmarks/bashmarks.sh``

A shell script that allows you to save and jump to commonly used
directories.

**Usage**::

    # Save bookmark
    s bookmarkname
    
    # Goto bookmark
    g bookmarkname
    g b[TAB]
    
    # Print bookmark
    p bookmarkname
    p b[TAB]

    # Delete bookmark
    d bookmarkname
    d [TAB]

    # List bookmarks
    l
    
**Sources**:

- https://github.com/huyng/bashmarks


