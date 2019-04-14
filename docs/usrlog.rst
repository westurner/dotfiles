

.. index:: usrlog
.. _usrlog:

*********
usrlog
*********

usrlog: Shell CLI REPL command logs in userspace (per :ref:`virtualenv`)

* `-usrlog.log format`_ -- ``-usrlog.log`` log files
* `usrlog.sh`_ -- :ref:`Bash`, :ref:`ZSH` shell script (append, grep)
* `usrlog.py`_ -- :ref:`Python` commandline parsing script (parse, ~grep)


.. index:: usrlog.sh
.. _usrlog.sh:

usrlog.sh
============
| Source: https://github.com/westurner/dotfiles/blob/master/scripts/usrlog.sh

usrlog logs the most recent userspace
interactive shell commandline CLI command to ``$_USRLOG``
**after** the shell command completes,
with :ref:`Bash` ``PROMPT_COMMAND``
and :ref:`ZSH` ``precmd_functions`` (see: `Caveats`_).

.. code:: bash

    # setup bash
    if [ -n "$BASH" ]; then
        PROMPT_COMMAND="_usrlog_writecmd; _usrlog_echo_title;"
    fi

    # setup zsh
    if [ -n "$ZSH_VERSION" ]; then
        precmd_functions=(_usrlog_writecmd _usrlog_echo_title)
    fi


Installation
--------------

`usrlog.sh`_:

.. code:: bash

    # source "${__DOTFILES}/etc/bash/30-bashrc.usrlog.sh  # {
    source "${__DOTFILES}/scripts/usrlog.sh"              # }
    echo "${_USRLOG}"$'\t'"${_TERM_ID}"         # dotfiles_status, ds, cls



Features
----------
* Initial Use Case: merge ``.bash_history`` and ``.zsh_history`` files
* append each :ref:`Bash` or :ref:`ZSH` userspace commandstr to one file::

    _USRLOG="${HOME}/-usrlog.log"

* append each :ref:`Bash` or :ref:`ZSH` userspace commandstr to one file
  per ``$VIRTUAL_ENV``::

    _USRLOG="${VIRTUAL_ENV}/-usrlog.log"

* add a session id to differentiate between multiple term instances::

    echo "${_TERM_ID}"
    termid

* generate relatively unique session ids by default
  when ``$_TERM_ID`` is unset::

    set_term_id [<name>]        # stid "#project/uri-fragment"
    stid
    st

* include the ``$_TERM_ID`` in the shell prompt.
* include ``VIRTUAL_ENV_NAME``, ``TERM_ID``, ``USER``, ``HOSTNAME``,
  and ``CWD`` in the window title (and ``PS1``)::

    ### usrlog window title
    # (VIRTUAL_ENV_NAME) $_TERM_ID $USER@$HOSTNAME:/$CWD
    (dotfiles) #2T515Vf25Ko user@host:~/-wrk/-ve27/dotfiles/src/dotfiles

* include the previous command in the shell prompt ``PS1``::

    ### PS1 shell prompt
    # echo 'previous command'$'\t'"${PS1}"
    (dotfiles) #2T515Vf25Ko user@host:~/-wrk/-ve27/dotfiles/src/dotfiles
    $

* [ ] BUG: escape tabs ``\t`` and newlines ``\r\n`` when setting ``_TERM_ID``
  in order to support really any string (such as URI fragments)::

    stid '#westurner/dotfiles/\tinstall-screencast'


.. index:: usrlog venv Integration
.. _usrlog venv integration:

usrlog venv integration
~~~~~~~~~~~~~~~~~~~~~~~~~
* :ref:`venv` (:ref:`virtualenvwrapper` :ref:`virtualenvs <virtualenv>`)::

    echo "${_USRLOG}"        # _USRLOG=$HOME/-usrlog.log
    echo "${HISTFILE}"       # HISTFILE=$HOME/.bash_history

    workon_venv dotfiles     # _USRLOG=$VIRTUAL_ENV/-usrlog.log
                             # HISTFILE=$VIRTUAL_ENV/.bash_history
    we dotfiles              # "
    workon_conda dotfiles    # "
    wec                      # "

    # deactivating resets to __USRLOG
    echo "${__USRLOG}  *"         # $HOME/-usrlog.log *
    echo $_USRLOG                 # $VIRTUAL_ENV/-usrlog.log
    deactivate; echo $_USRLOG     # $HOME/-usrlog.log

* If defined, ``_usrlog_set_title`` calls ``_setup_venv_prompt``
  (on every ``PROMPT_COMMAND`` invocation)

  ::

      ### scripts/usrlog.sh
      function _usrlog_set_title {
          # _usrlog_set_title()  --  set xterm title
          export WINDOW_TITLE=${1:-"$_TERM_ID"}
          _usrlog_echo_title
          declare -f '_setup_venv_prompt' 2>&1 > /dev/null \
              && _setup_venv_prompt
      }

  A ``_setup_venv_prompt`` is defined in
  https://github.com/westurner/dotfiles/blob/master/etc/bash/10-bashrc.venv.sh::

      ### etc/bash/10-bashrc.venv.sh
      function _setup_venv_prompt { ... }
      _setup_venv_prompt

* ``_usrlog_grep_venv`` -- find commands pertaining to :ref:`venv`


.. index:: usrlog.log format
.. index:: -usrlog.log format
.. _usrlog.log format:

-usrlog.log format
-------------------
* Almost but not quite TSV (tab-separated values)

  * Maximum split (commands may contain additional unescaped tabs)
  * Initial "# " in the date column

    * Because newlines

* -usrlog.log format parsers:

  * `usrlog.sh`_: ``ugp (_usrlog_parse_cmds)`` (:ref:`pyline`)
  * `usrlog.py`_


Syntax ::

    #\s\t                           # assert col[0] == '# '
    <iso8601datewithtz_finish>\t
    <_TERM_ID>\t                    # usrlog_set_id (stid)
    <path>\t                        # path *after* command has run (see: prev)
    <hist_n>\t                      # sometimes null (\s\s)
    <iso8601datewithtz_start>\t
    <HOSTNAME>\t                    # $HOSTNAME when _usrlog_set_HIST runs
    <USER>\t                        # $USER when _usrlog_set_HIST runs
    $$\t                            # cmd = split('\t$$\t', 1)[1]  # pyline
    <cmd>                           # (history 1 || fc -l -1) | sedescape


-usrlog.log natural key
~~~~~~~~~~~~~~~~~~~~~~~~

::

    natural_key = (iso8601datewithtz_finish, $_TERM_ID, $HOSTNAME, $USER)

See: `Caveats`_



.. index:: usrlog.py
.. _usrlog.py:

usrlog.py
============
| Source: https://github.com/westurner/dotfiles/blob/master/scripts/usrlog.py

usrlog.py is a commandline script for parsing ``-usrlog.log`` files.


Installation
---------------
.. code:: bash

    python "${__DOTFILES}/scripts/usrlog.py"
    # echo "$PATH"              # dotfiles_status, ds, cls
    cat $_USRLOG | usrlog.py --cmds -


Usage
-------
.. code:: bash

    python usrlog.py --help

    Usage: usrlog.py : [-u] [-p <path>|-P] [--cmds|--id|--dates|--elapsed|--ve]

    Options:
    -h, --help            show this help message and exit
    -p PATHS, --path=PATHS
                          Path to a -usrlog.log file to read (e.g.
                          "${VIRTUAL_ENV}/-usrlog.log" or '-' for stdin)
    -P, --paths-from-stdin
                          Read -usrlog.log paths from stdin
    -u, -U, --_USRLOG, --USRLOG
                          Read -usrlog.log path from ${_USRLOG}
    -f, --force           silently skip ParseException (or log w/ -v)
    --cmd, --cmds         show <cmd>
    --id, --ids, --session, --sessions
                          show [id, cmd]
    --date, --dates       show [date, id, cmd]
    --elapsed             show [date, id, cmd, elapsed]
    --ve, --venv, --venvs, --virtualenv, --virtualenvs
                          include [date,id,virtualenv,cmd]
    --cwd, --pwd, --cwd-after-cmd, --pwd-after-cmd
                          include [date,id,virtualenv,path,cmd]
    -c COLUMNS, --column=COLUMNS
                          { date, elapsed, id, virtualenv, path, cmd }
    --pyline              run --pyline '" commands" + (l[:9] if l else ".")'
    --iterable-only       return an iterable (instead of an exitcode)
    --todo, --todos       grep for #TODO entries and parse out the #TODO prefix
    -v, --verbose
    -q, --quiet
    -t, --test

.. code:: bash

    python usrlog.py --cmds $_USRLOG
    cat $_USRLOG | tail -n 20 | usrlog.py --cmds -

Todo:

- [ ] ENH: ``pandas.DataFrame.from_records`` (``index=cols[1]``)
- [ ] REF: update westurner/workhours integration



Caveats
=========

* A ``-usrlog.log`` is a text file log which commands are appended to,
  in userspace, with user permissions

  * Linux: see also: ``avc.log``, ``audit.log``

* [ ] BUG: ``path`` is recorded after the command evaluates
  (see the previous command)

  * pass forward the ending path from the previous command (``PATH_PREV``)
    in ``PROMPT_COMMAND``

  * initial ``PATH_PREV`` (at shell startup):

    * see the previous command (in the ``-usrlog.log`` file)

* [ ] **BUG: usrlog.sh only records the last line of commands containing newlines**

  * ``history 1`` | parse | template | tee ``$_USRLOG``

* Sometimes, ``hist_n`` is not set (e.g. when n > ``HISTSIZE``),
  but the tabs should still be there.
* Sometimes, ``iso8601datewithtz_start`` is not set (e.g. when
  ``HISTTIMEFORMAT`` is not set),
  but the tabs should still be there.
* I still have logs with the old ``.usrlog`` formats to parse (~^2015),
  which is why `usrlog.py`_ is far more complex than
  `usrlog.sh`_ ``_usrlog_parse_cmds`` (``cat $_USRLOG | ugp``):

  * [ ] REF: write migration scripts for oldstyle logs

    * workaround: ``grep -C $_USRLOG``
    * workaround: ``grep -C $(lsusrlogs) | ugp``
    * workaround: ``grep -C $(lsusrlogs) | usrlog.py --cmds``


Ideas
=======

* ENH: prompt square::

    # prev_cmd
    # date_start
    # date_finish [timedelta]
    # (VIRTUAL_ENV_NAME) $_TERM_ID $USER@$HOSTNAME:/$CWD
    $

  * PERF: time delta overhead
  * UBY: minimize n rows
