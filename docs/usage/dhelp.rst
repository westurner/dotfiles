
.. index:: Usage (dhelp)
.. _dhelp:

===============
Usage (dhelp)
===============

.. index:: scripts/_dotfileshelp.sh
.. _scripts/_dotfileshelp.sh:

scripts/_dotfileshelp.sh
=========================
| Src: `scripts/_dotfileshelp.sh <https://github.com/westurner/dotfiles/tree/develop/scripts/_dotfileshelp.sh>`__

.. code:: bash

   .
   ### _dotfileshelp.sh -- grep for comments in readline, bash, zsh, i3, vim cfg
       dotfileshelp  [-n] [-h] [-v -e -d] [<cmd> [<arg1> [<argn>]]]
    
         <cmd> may be zero or one of { all, readline, bash, zsh, i3, vim }
    
         -n/--number-lines  -- print line numbers
    
         -h/--help          -- print help
         -v/--verbose       -- set -x       (print commands and arguments)
         -e/--errexit       -- set -e       (exit if any command returns nonzero)
         -d/--debug         -- set -x -v -e (see: ``help set``)
            --test          -- run tests
    
         Usage examples:
    
             $ dotfileshelp -h
             $ dotfileshelp -v -h
             $ dhelp
             $ dh
             $ dh all
             $ dh all -n -v
             $ dh readline
             $ dh bash
             $ dh zsh
             $ dh i3
             $ dh vim
             $ dh dotfiles
    
      ### dhelp bash functions:
    
       ## dhelp_shell()             -- grep comments in a .sh file
       ## dhelp_help() -- grep shell comments in this file ($BASH_SOURCE)
       ## dhelp_dotfiles()          -- grep comments in bootstrap_dotfiles.sh
       ## dhelp_inputrc()           -- grep comments in a readline .inputrc
       ## dhelp_inputrc__dotfiles() -- grep comments in etc/.inputrc
       ## dhelp_bash()              -- grep comments in a .sh file
       ## dhelp_bash__dotfiles()    -- grep comments in etc/bash/*.sh
       ## dhelp_zsh()               -- grep comments in a zsh .sh file
       ## dhelp_zsh__dotfiles()     -- grep comments in etc/zsh/*.sh
       ## dhelp_i3()                -- grep comments in an i3/config
       ## dhelp_i3__dotfiles()      -- grep comments in etc/i3/config
       ## dhelp_vimrc()             -- grep comments in a .vim / vimrc file
       ## dhelp_vimrc__dotfiles()   -- grep comments in etc/vim/vimrc*
       ## dhelp_test() -- test dhelp (--test [--debug])
           ## dhelp_test_each() -- test dhelp functions
    
   .



.. index:: scripts/bootstrap_dotfiles.sh
.. _scripts/bootstrap_dotfiles.sh:

scripts/bootstrap_dotfiles.sh
==============================
| Src: `scripts/bootstrap_dotfiles.sh <https://github.com/westurner/dotfiles/tree/develop/scripts/bootstrap_dotfiles.sh>`__

.. code:: bash

   .
   ## westurner/dotfiles bootstrap_dotfiles.sh
     Install and upgrade dotfiles for the current user
    
     Can be run:
     * in a virtualenv (as current user)
     * for --user (as current user)
    
     * Clones into $VIRTUAL_ENV/src/dotfiles
     * Symlinks $VIRTUAL_ENV/src/dotfiles) to ${HOME}/-dotfiles
     * Symlinks from ~/-dotfiles/<...> into ${HOME}
    
     usage::
    
        bash scripts/bootstrap_dotfiles.sh -h
     set -e   -- exit on error (any nonzero return) [ should be set -e ]
     set -v   -- print source as run   [dotfiles: debug-on(), debug-off()]
     set -x   -- print commands        [dotfiles: debug-on(), debug-off()]
     echo $-  -- echo current shell set options [e.g. -e -v -x]
       ## date (file suffix for backup_and_symlink)
       ## Virtualenvwrapper [virtualenvwrapper.sh]
       ## Virtualenv + Venv [virtualenv, dotfiles.venv]
         __DOTFILES="${__DOTFILES_SYMLINK}"# ~/-dotfiles
       ## bootstrap_dotfiles.sh
       ## dotfiles repository  -- https://github.com/westurner/dotfiles
       ## dotvim repository    -- https://github.com/westurner/dotvim
         dotfiles_check_deps   -- check for installed commands and functions
         git_status()      -- show git rev, branches, remotes
         hg_status()       -- show hg id, branches, paths
         show_status()     -- show status for a (.hg or .git) repository
         clone_or_update() -- clone OR pull and update (git [or hg])
         clone_dotfiles_repo()         -- clone/up dotfiles_repo; create symlinks
         Create a $__DOTFILES symlink
         clone_dotvim_repo()           -- clone dotvim to etc/vim
         install_virtualenvwrapper()   -- pip install virtualenvwrapper
           OR: (manually) apt-get install python-virtualenvwrapper
         install_gitflow()     -- install gitflow git workflow [git flow help]
         install_hubflow()     --  Install hubflow git workflow [git hf help]
         get_md5sums()     -- get md5sums for a path or directory
         __realpath()  -- os.path.realpath (~ readlink -f --canonicalize)
         backup_and_symlink()  -- Create symlink at $dest, pointing to $src
         Args:
          filename: basename of file
          dest: location of symlink
          src: where symlink will point
          BKUPID: file suffix ( *.bkp.* ) (date)
                 if either src_md5 or dest_md5 are null
   ## /begin symlinks
            "${ipyprofile}/startup/20-venv_ipymagics.py"
            "${ipyprofile}/ipython_config.py"
   ## end /symlinks
       ## Create symlinks
         {{ full_name }}
       ## create a new virtualenv
       ## deactivate any current VIRTUAL_ENV in this $SHELL
       ## pip install --upgrade --editable and create symlinks
       ## pip install --user --editable and create symlinks
          Upgrade system pip
       ## Setup system dependencies
         dotfiles_install_bootstrap_pip
             Install virtualenv and virtualenvwrapper into ~/.local/bin/
       ## clone and/or pull and update dotfiles and dotvim; then install dotfiles
         Clone the dotfiles repository
         Clone the dotvim repository
         Install dotfiles into ${HOME}
         Install dotfiles into ~/.local/
       ## Install the dotfiles
         install and configure virtualenv and virtualenvwrapper
             create or activate $_VIRTUAL_ENV
       ## Clone and/or pull and update dotfiles and dotvim; then install dotfiles
         Symlink dotfiles into ${HOME}
       ## Install all pip requirements
       ## Upgrade setuptools with pip
       ## Upgrade system pip with pip (careful)
       ## Upgrade pip with pip (does not work)
       ## Install pip (and setuptools)
       ## Install setuptools
       ## Install virtualenv
       ## Install virtualenvwrapper
       ## source virtualenvwrapper[_lazy].sh from $PATH
       ## print usage information
       ## parse opts, set flags, and run commands
            while getopts "uISURGCdh" o; do
                dotfiles_bootstrap_parse_arg "${o}"
            done
   ## execute main if called as a script
   ## (e.g. not with `source`)
   .



.. index:: etc/.inputrc
.. _etc/.inputrc:

etc/.inputrc
=============
| Src: `etc/.inputrc <https://github.com/westurner/dotfiles/tree/develop/etc/.inputrc>`__

.. code:: 

   .
   ### .inputrc -- readline configuration
   ## Bash readline quickstart
      https://www.gnu.org/software/bash/manual/html_node/Command-Line-Editing.html#Command-Line-Editing
       * https://www.gnu.org/software/bash/manual/html_node/Readline-Interaction.html
       * https://www.gnu.org/software/bash/manual/html_node/Readline-Init-File.html
       * https://www.gnu.org/software/bash/manual/html_node/Readline-vi-Mode.html#Readline-vi-Mode
       * https://github.com/whiteinge/dotfiles/blob/master/.inputrc
    
          help bind
          # list bindings
          bind -p
          bind -P | grep -v 'is not bound'
          # read bindings
          bind -f ~/.inputrc
        
     - do not bell on tab-completion
     - show visible bell (flash the screen)
     Adds punctuation as word delimiters
     set bind-tty-special-chars off
     Adds punctuation as word delimiters
     Completion Options
     Useful stuff for UTF-8
     menu-complete-display-prefix on
         <OSX_opt>-k   -- reset screen
   ## vi-mode
          Various terminals have vi-mode settings:
          - bash: set -o vi  (default: set -o emacs)
          - ksh:  set -o vi
          - zsh:  bindkey -v
          - tcsh: bindkey -v
        
       ## <ctrl/alt> left/right -- backward/forward one word
          <alt> left   -- move backward one word
          <ctrl> left  -- move backward one word
          <alt> right  -- move forward one word
          <ctrl> right -- move forward one word
       ## <ctrl/alt> up/down -- beginning/end of line
          <alt> up     -- move to beginning of line
          <ctrl> up    -- move to beginning of line
          <ctrl> down  -- move to end of line
          <ctrl> down  -- move to end of line
     ## vi-command keymap
          <ctrl> l  -- clear screen
          <ctrl> k  -- clear whole line
          <ctrl> a  -- move to beginning of line (^)
          <ctrl> [  -- move to beginning of line (^)
          <ctrl> e  -- move to end of line ($)
          <ctrl> ]  -- move to end of line ($)
          <up>      -- history search backward (match current input)
          <down>    -- history search forward (match current input)
          <ctrl> w  -- delete last word
          <ctrl> BS -- delete last word
          <ctrl> gx -- expand without executing
          <ctrl> 3  -- prefix with '# '
     ## vi-insert keymap
          emulate a few options from "set -o emacs":
          <ctrl> l  -- clear screen
          <ctrl> k  -- clear whole line
          <ctrl> a  -- move to beginning of line (^)
          <ctrl> [  -- move to beginning of line (^)
          <ctrl> e  -- move to end of line ($)
          <ctrl> ]  -- move to end of line ($)
          <up>      -- history search backward (match current input)
          <down>    -- history search forward (match current input)
         <ctrl> <left>  -- move to prev word
         "\C-\e[D": vi-prev-word
         <ctrl> <right>  -- move to next word
         "\C-\e[C": vi-next-word
          <ctrl> w  -- delete last word
          <ctrl> BS -- delete last word
          <ctrl> gx -- glob expand without executing
          <ctrl> 3  -- prefix with '# '
          see: bindkey -p
   .

.. index:: etc/bash/00-bashrc.before.sh
.. _etc/bash/00-bashrc.before.sh:

etc/bash/00-bashrc.before.sh
=============================
| Src: `etc/bash/00-bashrc.before.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/00-bashrc.before.sh>`__

.. code:: bash

   .
   ## 00-bashrc.before.sh     -- bash dotfiles configuration root
      source ${__DOTFILES}/etc/bash/00-bashrc.before.sh    -- dotfiles_reload()
    
        dotfiles_reload()  -- (re)load the bash configuration
        $__DOTFILES (str): -- path to the dotfiles symlink (~/-dotfiles)
      
     ## 01-bashrc.lib.sh           -- useful bash functions (paths)
        lspath()           -- list every file along $PATH
        realpath()         -- readlink -f (python os.path.realpath)
        walkpath()         -- list every directory along ${1:-"."}
      
     ## 02-bashrc.platform.sh      -- platform things
        detect_platform()  -- set $__IS_MAC or $__IS_LINUX
     ## 03-bashrc.darwin.sh
      
     ## 04-bashrc.TERM.sh          -- set $TERM and $CLICOLOR
      
     ## 05-bashrc.dotfiles.sh      -- dotfiles
        $__DOTFILES (str): -- path to the dotfiles symlink (~/.dotfiles)
        dotfiles_status()  -- print dotfiles variables
        ds()               -- print dotfiles variables
      
     ## 06-bashrc.completion.sh    -- configure bash completion
      
     ##
        virtualenvwrapper / virtualenv / venv constants
      
        $PROJECT_HOME (str): path to project directory (~/-wrk)
        $WORKON_HOME  (str): path to virtualenvs directory (~/-wrk/-ve27)
        $VIRTUAL_ENV  (str): path to current $VIRTUAL_ENV ($WORKON_HOME/$VENVSTR)
      
     ## 07-bashrc.python.sh            -- python
        _setup_python()              -- configure PYTHONSTARTUP
        _setup_pip()                 -- configure PIP_REQUIRE_VIRTUALENV
        _setup_pyenv()               -- setup pyenv PYENV_ROOT and eval (manual)
      
     ## 08-bashrc.conda.sh             -- conda
        _setup_conda()               -- setup conda paths (manual)
                                        WORKON_HOME=CONDA_ENVS_PATH
          $1 (str): (optional) CONDA_ENVS_PATH (WORKON_HOME)
          $2 (str): (optional) CONDA_ROOT_PATH (or '27' or '34')
        $CONDA_ROOT      (str): path to conda install (~/-wrk/-conda34)
        $CONDA_ENVS_PATH (str): path to condaenvs directory (~/-wrk/-ce34) [conda]
      
     ## 07-bashrc.virtualenvwrapper.sh -- virtualenvwrapper
        _setup_virtualenvwrapper     -- configure virtualenvwrapper
        backup_virtualenv($VENVSTR)  -- backup a venv in WORKON_HOME
                                        $WORKON_HOME/$VENVSTR -> ./-bkp/$VENVSTR
        backup_virtualenvs()         -- backup all venvs in WORKON_HOME
                                        $WORKON_HOME/*        -> ./-bkp/*
        rebuild_virtualenv($VENVSTR) -- rebuild $WORKON_HOME/$VENVSTR
        rebuild_virtualenvs()        -- rebuild $WORKON_HOME/*
        TODO: restore_virtualenv($BACKUPVENVSTR, [$NEWVENVSTR])
      
     ## 08-bashrc.gcloud.sh        -- gcloud: Google Cloud SDK
        _setup_google_cloud()  -- setup google cloud paths
      
     ## 10-bashrc.venv.sh          -- venv: virtualenvwrapper extensions
        _setup_venv()
        $__PROJECTSRC     (str): script to source (${PROJECT_HOME}/.projectsrc.sh)
        $VIRTUAL_ENV_NAME (str): basename of $VIRTUAL_ENV [usrlog: prompt, title]
        $_APP             (str): $VIRTUAL_ENV/src/${_APP}
        we() -- workon a new venv
           $1: VIRTUAL_ENV_NAME [$WORKON_HOME/${VIRTUAL_ENV_NAME}=>$VIRTUAL_ENV]
           $2: _APP (optional; defaults to $VIRTUAL_ENV_NAME)
      
           we dotfiles
           we dotfiles etc/bash; cdw; ds; # ls -altr; lll; cd ~; ew etc/bash/*.sh
           type workon_venv; which venv.py; venv.py --help
      
      
     ## 11-bashrc.venv.pyramid.sh  -- venv-pyramid: pyramid-specific config
      
     ## 20-bashrc.editor.sh        -- $EDITOR configuration
        $EDITOR  (str): cmdstring to open $@ (file list) in editor
        $EDITOR_ (str): cmdstring to open $@ (file list) in current editor
        e()        -- open paths in current EDITOR_                   [scripts/e]
        ew()       -- open paths relative to $_WRD in current EDITOR_ [scripts/ew]
                      (~ cd $_WRD; $EDITOR_ ${@}) + tab completion
      
     ## 20-bashrc.vimpagers.sh     -- $PAGER configuration
        $PAGER   (str): cmdstring to run pager (less/vim)
        lessv()    -- open in vim with less.vim
                      VIMPAGER_SYNTAX="python" lessv
        lessg()    -- open in a gvim with less.vim
                      VIMPAGER_SYNTAX="python" lessv
        lesse()    -- open with $EDITOR_ (~e)
        manv()     -- open manpage with vim
        mang()     -- open manpage with gvim
        mane()     -- open manpage with $EDITOR_ (~e)
      
        TODO: GIT_PAGER="/usr/bin/less -R | /usr/bin/cat"
      
     ## 30-bashrc.usrlog.sh        -- $_USRLOG configuration
        _setup_usrlog()    -- configure usrlog
        $_USRLOG (str): path to a -usrlog.log command log
                      __USRLOG=~/-usrlog.log
                       _USRLOG=${VIRTUAL_ENV}/-usrlog.log
        lsusrlogs  -- ls -tr   "${__USRLOG}" "${WORKON_HOME}/*/-usrlog.log"
        stid       -- set $TERM_ID to a random string (e.g. "#Yt0PyyKWPro")
        stid $name -- set $TERM_ID to string (e.g. \#20150704, "#20150704")
        note       -- log a #note to $_USRLOG (histn==#note)
        todo       -- log a #todo to $_USRLOG (histn==#todo)
        usrlogv    -- open usrlog with vim:    $VIMBIN    $_USRLOG
        usrlogg    -- open usrlog with gmvim:  $GUIVIMBIN $_USRLOG
        usrloge    -- open usrlog with editor: $EDITOR    $_USRLOG
        ut         -- tail -n__ $_USRLOG [ #BUG workaround: see venv.py]
        ug         -- egrep current usrlog: egrep $@ $_USRLOG
        ugall      -- egrep all usrlogs [ #BUG workaround: see venv.py ]
                           egrep $@ "${__USRLOG}" "${WORKON_HOME}/*/-usrlog.log"
        ugrin      -- grin current usrlog: grin $@ ${_USRLOG}
        ugrinall   -- grin $@  "${__USRLOG}" "${WORKON_HOME}/*/-usrlog.log"
      
     ## 30-bashrc.xlck.sh          -- screensaver, (auto) lock, suspend
        _setup_xlck()      -- configure xlck
      
     ## 40-bashrc.aliases.sh       -- aliases
        _setup_venv_aliases()  -- source in e, ew, makew, ssv, hgw, gitw
          _setup_supervisord() -- configure _SVCFG
             $1 (str): path to a supervisord.conf file "${1:-${_SVCFG}"
     ## 42-bashrc.commands.sh      -- example commands
      
     ## 50-bashrc.bashmarks.sh     -- bashmarks: local bookmarks
      
     ## 70-bashrc.repos.sh         -- repos: $__SRC repos, docs
      
     ## 99-bashrc.after.sh         -- after: cleanup
         dr()  -- dotfiles_reload
         ds()  -- print dotfiles_status()
   .

   
   
.. index:: etc/bash/01-bashrc.lib.sh
.. _etc/bash/01-bashrc.lib.sh:

etc/bash/01-bashrc.lib.sh
==========================
| Src: `etc/bash/01-bashrc.lib.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/01-bashrc.lib.sh>`__

.. code:: bash

   .
   ### bashrc.lib.sh
   ## bash
         echo_args         -- echo $@ (for checking quoting)
         function_exists() -- check whether a bash function exists
       PATH_prepend()     -- prepend a directory ($1) to $PATH
           instead of:
               export PATH=$dir:$PATH
               PATH_prepend $dir 
         PATH_remove()  -- remove a directory from $PATH
         note: empty path components ("::") will be stripped
         PATH_contains() -- test whether $PATH contains $1
         lightpath()       -- display $PATH with newlines
         lspath()          -- list files in each directory in $PATH
         lspath_less()     -- lspath with less (color)
   ## file paths
         realpath()        -- print absolute path (os.path.realpath) to $1
                              note: OSX does not have readlink -f
         path()            -- realpath()
         walkpath()        -- walk down path $1 and $cmd each component
           $1: path (optional; default: pwd)
           $2: cmd  (optional; default: 'ls -ald --color=auto')
         ensure_symlink()  -- create or update a symlink to $2 from $1
                              if $2 exists, backup with suffix $3
         ensure_mkdir()    -- create directory $1 if it does not yet exist
   .

   
   
.. index:: etc/bash/02-bashrc.platform.sh
.. _etc/bash/02-bashrc.platform.sh:

etc/bash/02-bashrc.platform.sh
===============================
| Src: `etc/bash/02-bashrc.platform.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/02-bashrc.platform.sh>`__

.. code:: bash

   .
   ### bashrc.platform.sh
         detect_platform() -- set $__IS_MAC or $__IS_LINUX according to $(uname)
         j()               -- jobs
         f()               -- fg %$1
         b()               -- bg %$1
         killjob()         -- kill %$1
   .

   
   
.. index:: etc/bash/03-bashrc.darwin.sh
.. _etc/bash/03-bashrc.darwin.sh:

etc/bash/03-bashrc.darwin.sh
=============================
| Src: `etc/bash/03-bashrc.darwin.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/03-bashrc.darwin.sh>`__

.. code:: bash

   .
   ### bashrc.darwin.sh
     softwareupdate                -- install OSX updates
      | Docs: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/softwareupdate.8.html
      softwareupdate -l        # --list
      softwareupdate -i --all  # --install --all
      softwareupdate -i -r     # --install --recommended
     Mac Boot-time modifiers: (right after the chime)
    
      Option    -- boot to boot disk selector menu
      C         -- boot from CD/DVD
      Shift     -- boot into Safe mode
      Command-V -- boot into verbose mode
       sudo nvram boot-args="-v"  # always boot verbosely
       sudo nvram boot-args=""    # boot normally
       sudo nvram -p              # print current nvram settings
     if __IS_MAC:
         finder()    -- open Finder.app
         finder-killall()  -- close all Finder.app instances
         finder-restart()  -- close all and start Finder.app
         finder-hide-hidden()    -- hide .hidden files in Finder.app
                                    (and close all Finder windows)
         finder-show-hidden()    -- show .hidden files in Finder.app
                                    (and close all Finder windows)
   .

   
   
.. index:: etc/bash/04-bashrc.TERM.sh
.. _etc/bash/04-bashrc.TERM.sh:

etc/bash/04-bashrc.TERM.sh
===========================
| Src: `etc/bash/04-bashrc.TERM.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/04-bashrc.TERM.sh>`__

.. code:: bash

   .
   ### bashrc.TERM.sh
         configure_TERM            -- configure the $TERM variable (man terminfo)
           $1: (optional; autodetects if -z)
         configure_TERM_CLICOLOR   -- configure $CLICOLOR and $CLICOLOR_256
           CLICOLOR=1
         configure_TERM when sourced
   .

   
   
.. index:: etc/bash/05-bashrc.dotfiles.sh
.. _etc/bash/05-bashrc.dotfiles.sh:

etc/bash/05-bashrc.dotfiles.sh
===============================
| Src: `etc/bash/05-bashrc.dotfiles.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/05-bashrc.dotfiles.sh>`__

.. code:: bash

   .
   ### bashrc.dotfiles.sh
         dotfiles_add_path()       -- add ${__DOTFILES}/scripts to $PATH
         shell_escape_single()
         dotfiles_status()         -- print dotfiles_status
         ds()                      -- print dotfiles_status
         source "${__DOTFILES}/scripts/cls"
         clr()                     -- clear scrollback
         cls()                     -- clear scrollback and print dotfiles_status()
         echo "## lspath"
         lspath | tee $OUTPUT
     https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin
         debug-on()                 -- set -x -v
         debug-off()                -- set +x +v
         Virtualenvwrapper numeric sequence
         * to make logs in /var/log/venv.nnn-stepname.log naturally ordered
        
         * 0xx : 'initialization' actions  : [initialize]
         * 1xx : 'creation' actions        : [pre|post]mk[virtualenv|project]
         * 2xx : 'vation' actions          : [pre|post][activate|deactivate]
         * 8xx : 'managment' actions       : [pre|post][cpvirtualenv|rmvirtualenv]
         * 868 : unknown
         * xx0 : 'pre' actions
         * xx9 : 'post' actions
         Source-ordered according to the virtualenvwrapper docs
         * https://virtualenvwrapper.readthedocs.org/en/latest/scripts.html#scripts
         log_dotfiles_state()      -- save current environment to logfiles
           $1 -- logkey (virtualenvwrapper step name)
         XXX: PRF
         dotfiles_initialize()     -- virtualenvwrapper initialize
         dotfiles_premkvirtualenv -- virtualenvwrapper premkvirtualenv
         dotfiles_postmkvirtualenv -- virtualenvwrapper postmkvirtualenv
         NOTE: infer VIRTUAL_ENV_NAME from VIRTUAL_ENV
         dotfiles_preactivate()    -- virtualenvwrapper preactivate
         dotfiles_postactivate()   -- virtualenvwrapper postactivate
         dotfiles_predeactivate()  -- virtualenvwrapper predeactivate
         dotfiles_postdeactivate() -- virtualenvwrapper postdeactivate
       ### usrlog.sh
       ## unset _MSG
       ## unset NOTE
       ## unset TODO
   .

   
   
.. index:: etc/bash/06-bashrc.completion.sh
.. _etc/bash/06-bashrc.completion.sh:

etc/bash/06-bashrc.completion.sh
=================================
| Src: `etc/bash/06-bashrc.completion.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/06-bashrc.completion.sh>`__

.. code:: bash

   .
   ### bashrc.completion.sh
         _configure_bash_completion()  -- configure bash completion
                                       note: `complete -p` lists completions
   .

   
   
.. index:: etc/bash/07-bashrc.python.sh
.. _etc/bash/07-bashrc.python.sh:

etc/bash/07-bashrc.python.sh
=============================
| Src: `etc/bash/07-bashrc.python.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/07-bashrc.python.sh>`__

.. code:: bash

   .
   ### bashrc.python.sh
         pypath()              -- print python sys.path and site config
         _setup_python()       -- configure $PYTHONSTARTUP
         _setup_pip()          -- set $PIP_REQUIRE_VIRTUALENV=false
   ## Pyenv
         _setup_pyvenv()       -- set $PYENV_ROOT, PATH_prepend, and pyenv venvw
   .

   
   
.. index:: etc/bash/07-bashrc.virtualenvwrapper.sh
.. _etc/bash/07-bashrc.virtualenvwrapper.sh:

etc/bash/07-bashrc.virtualenvwrapper.sh
========================================
| Src: `etc/bash/07-bashrc.virtualenvwrapper.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/07-bashrc.virtualenvwrapper.sh>`__

.. code:: bash

   .
   ### bashrc.virtualenvwrapper.sh
    
     Installing Virtualenvwrapper:
       apt:
         sudo apt-get install virtualenvwrapper
       pip:
         [sudo] pip install -U pip virtualenvwrapper
    
   ## Configure dotfiles/virtualenv root/prefix environment variables
     __WRK         workspace root
     PROJECT_HOME  virtualenvwrapper project directory (mkproject)
     WORKON_HOME   virtualenvwrapper virtualenv prefix
                   VIRTUAL_ENV=${WORKON_HOME}/${VIRTUAL_ENV_NAME}
                   _APP=${VIRTUAL_ENV_NAME}  #[/subpath]
                   _SRC=${VIRTUAL_ENV}/${_APP}
                   _WRD=${VIRTUAL_ENV}/${_APP}
         _setup_virtualenvwrapper_config()    -- configure $VIRTUALENVWRAPPER_*
             elif "${VIRTUAL_ENV}/bin/python"  ## use extra-venv python
          if [ -n "${__IS_MAC}" ]; then  # for brew python
         lsvirtualenvs()       -- list virtualenvs in $WORKON_HOME
         lsve()                -- list virtualenvs in $WORKON_HOME
         backup_virtualenv()   -- backup VIRTUAL_ENV_NAME $1 to [$2]
         backup_virtualenvs()  -- backup all virtualenvs in $WORKON_HOME to [$1]
         dx()                      -- 'deactivate'
         rebuild_virtualenv()      -- rebuild a virtualenv, leaving pkgs in place
            $1="$VENVSTR"
            $2="$VIRTUAL_ENV"
         TODO: adjust paths beyond the shebang
          rebuild_virtualenv()     -- rebuild a virtualenv
            $1="$VENVSTR"
            $2="$VIRTUAL_ENV"
         rebuild_virtualenvs()     -- rebuild all virtualenvs in $WORKON_HOME
       _setup_virtualenvwrapper_default_config # ~/.virtualenvs/
   .

   
   
.. index:: etc/bash/08-bashrc.conda.sh
.. _etc/bash/08-bashrc.conda.sh:

etc/bash/08-bashrc.conda.sh
============================
| Src: `etc/bash/08-bashrc.conda.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/08-bashrc.conda.sh>`__

.. code:: bash

   .
   ### bashrc.conda.sh
   ## Conda / Anaconda
     see: 05-bashrc.dotfiles.sh
            # shell_escape_single()
            strtoescape=${1}
            output="$(echo "${strtoescape}" | sed "s,','\"'\"',g")"
            echo "'"${output}"'"
         _conda_status_core()      -- echo CONDA_ROOT and CONDA_ENVS_PATH
         _conda_status_defaults()   -- echo CONDA_ROOT__* and CONDA_ENVS_PATH_*
         _conda_status()   -- echo CONDA_ROOT, CONDA_ENVS_PATH, and defaults
         csc()             -- echo CONDA_ROOT and CONDA_ENVS_PATH
         _setup_conda_defaults()   -- configure CONDA_ENVS_PATH*, CONDA_ROOT*
            $1 (pathstr): prefix for CONDA_ENVS_PATHS and CONDA_ROOT
                         (default: ${__WRK})
         _setup_anaconda()     -- set CONDA_ENVS_PATH, CONDA_ROO
           $1 (pathstr or {27, 34}) -- lookup($1, CONDA_ENVS_PATH,
                                                           CONDA_ENVS__py27)
           $2 (pathstr or "")       -- lookup($2, CONDA_ROOT,
                                                           CONDA_ROOT__py27)
        
          Usage:
           _setup_conda     # __py27
           _setup_conda 27  # __py27
           _setup_conda 34  # __py34
           _setup_conda 35  # __py35
           _setup_conda ~/envs             # __py27
           _setup_conda ~/envs/ /opt/conda # /opt/conda
           _setup_conda <conda_envs_path> <conda_root>  # conda_root
        
                 CONDA_ROOT_DEFAULT=CONDA_ROOT__py27
         _setup_conda_path()   -- prepend CONDA_ROOT/bin to $PATH
         _unsetup_conda_path_all()  -- remove CONDA_ROOT & defaults from $PATH
         deduplicate_lines()   -- deduplicate lines w/ an associative array
                                                         (~OrderedMap)
         echo_conda_envs_paths()   -- print (CONDA_ENVS_PATH & defaults)
         lscondaenvs()             -- list CONDA_ENVS_PATH/* (and _conda_status)
           _conda_status>2
           find>1
         lsce()                    -- list CONDA_ENVS_PATH/* (and _conda_status)
         _condaenvs()              -- list conda envs for tab-completion
         workon_conda()        -- workon a conda + venv project
         wec()                 -- workon a conda + venv project
                               note: tab-completion only shows regular virtualenvs
         _mkvirtualenv_conda_usage()  -- echo mkvirtualenv_conda usage information
         mkvirtualenv_conda()  -- mkvirtualenv and conda create
         if there is a function named 'dotfiles_postmkvirtualenv',
         then run 'dotfiles_postmkvirtualenv'
         rmvirtualenv_conda()  -- rmvirtualenv conda
         mkvirtualenv_conda_if_available() -- mkvirtualenv_conda OR mkvirtualenv
         workon_conda_if_available()       -- workon_conda OR we OR workon
   .

   
   
.. index:: etc/bash/08-bashrc.conda.sh.un~
.. _etc/bash/08-bashrc.conda.sh.un~:

etc/bash/08-bashrc.conda.sh.un~
================================
| Src: `etc/bash/08-bashrc.conda.sh.un~ <https://github.com/westurner/dotfiles/tree/develop/etc/bash/08-bashrc.conda.sh.un~>`__

.. code:: bash

   .
   ### bashrc.conda.sh
   ## Conda / Anaconda
     see: 05-bashrc.dotfiles.sh
            # quote_shell_single_always()
            strtoescape=${1}
            output="$(echo "${strtoescape}" | sed "s,','\"'\"',g")"
            echo "'"${output}"'"
         _conda_status_core()      -- echo CONDA_ROOT and CONDA_ENVS_PATH
         _conda_status_defaults()   -- echo CONDA_ROOT__* and CONDA_ENVS_PATH_*
         _conda_status()   -- echo CONDA_ROOT, CONDA_ENVS_PATH, and defaults
         csc()             -- echo CONDA_ROOT and CONDA_ENVS_PATH
         _setup_conda_defaults()   -- configure CONDA_ENVS_PATH*, CONDA_ROOT*
            $1 (pathstr): prefix for CONDA_ENVS_PATHS and CONDA_ROOT
                         (default: ${__WRK})
         _setup_anaconda()     -- set CONDA_ENVS_PATH, CONDA_ROO
           $1 (pathstr or {27, 34}) -- lookup($1, CONDA_ENVS_PATH,
                                                           CONDA_ENVS__py27)
           $2 (pathstr or "")       -- lookup($2, CONDA_ROOT,
                                                           CONDA_ROOT__py27)
        
          Usage:
           _setup_conda     # __py27
           _setup_conda 27  # __py27
           _setup_conda 34  # __py34
           _setup_conda 35  # __py35
           _setup_conda ~/envs             # __py27
           _setup_conda ~/envs/ /opt/conda # /opt/conda
           _setup_conda <conda_envs_path> <conda_root>  # conda_root
        
                 CONDA_ROOT_DEFAULT=CONDA_ROOT__py27
         _setup_conda_path()   -- prepend CONDA_ROOT/bin to $PATH
         _unsetup_conda_path_all()  -- remove CONDA_ROOT & defaults from $PATH
         deduplicate_lines()   -- deduplicate lines w/ an associative array
                                                         (~OrderedMap)
         echo_conda_envs_paths()   -- print (CONDA_ENVS_PATH & defaults)
         lscondaenvs()             -- list CONDA_ENVS_PATH/* (and _conda_status)
           _conda_status>2
           find>1
         lsce()                    -- list CONDA_ENVS_PATH/* (and _conda_status)
         _condaenvs()              -- list conda envs for tab-completion
         workon_conda()        -- workon a conda + venv project
         wec()                 -- workon a conda + venv project
                               note: tab-completion only shows regular virtualenvs
         _mkvirtualenv_conda_usage()  -- echo mkvirtualenv_conda usage information
         mkvirtualenv_conda()  -- mkvirtualenv and conda create
         if there is a function named 'dotfiles_postmkvirtualenv',
         then run 'dotfiles_postmkvirtualenv'
         rmvirtualenv_conda()  -- rmvirtualenv conda
         mkvirtualenv_conda_if_available() -- mkvirtualenv_conda OR mkvirtualenv
         workon_conda_if_available()       -- workon_conda OR we OR workon
   .

   
   
.. index:: etc/bash/08-bashrc.gcloud.sh
.. _etc/bash/08-bashrc.gcloud.sh:

etc/bash/08-bashrc.gcloud.sh
=============================
| Src: `etc/bash/08-bashrc.gcloud.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/08-bashrc.gcloud.sh>`__

.. code:: bash

   .
   ### bashrc.gcloud.sh
       ## _get_GCLOUDSDK_PREFIX()   -- get GCLOUDSDK_PREFIX
           $1 (str): default:~/google-cloud-sdk (GCLOUDSDK_PREFIX)
       ## _setup_GCLOUDSDK_PREFIX() -- configure gcloud $PATH and bash completions
           $1 (str): default:~/google-cloud-sdk (GCLOUDSDK_PREFIX)
       ## _setup_gcloudsdk() -- configure gcloud $PATH and bash completions
           $1 (str): default:~/google-cloud-sdk (GCLOUDSDK_PREFIX)
       ## _unsetup_gcloudsdk() -- unset GCLOUDSDK_PREFIX
         XXX: PATH_remove <...>
       ## _get_APPENGINESDK_PREFIX()  -- get APPENGINESDK_PREFIX
       ## _setup_APPENGINESDK_PREFIX() -- configure gcloud $PATH and completion
           $1 (str): default:~/google-cloud-sdk (APPENGINESDK_PREFIX)
       ## _setup_appenginesdk() -- config GCLOUDSDK*, APPENGINESDK_PREFIX, PATH
           $1 (str): default: ~/google-cloud-sdk/platform/google_appengine
                     default: /usr/local/google_appengine
                     ${APPENGINESDK_PREFIX}
       ## _unsetup_appenginesdk() -- PATH_remove ${APPENGINESDK_PREFIX}
   .

   
   
.. index:: etc/bash/10-bashrc.venv.sh
.. _etc/bash/10-bashrc.venv.sh:

etc/bash/10-bashrc.venv.sh
===========================
| Src: `etc/bash/10-bashrc.venv.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/10-bashrc.venv.sh>`__

.. code:: bash

   .
   ### bashrc.venv.sh
       note: most of these aliases and functions are overwritten by `we` 
   ## Variables
         _setup_venv()    -- configure __PROJECTSRC, PATH, __VENV, _setup_venv_SRC()
          __PROJECTSRC (str): path to local project settings script to source
         PATH="~/.local/bin:$PATH" (if not already there)
         __VENV      -- path to local venv config script (executable)
         CdAlias functions and completions
         _setup_venv_SRC() -- configure __SRCVENV and __SRC global virtualenv
         __SRCVENV (str): global 'src' venv symlink (~/-wrk/src)
                          (e.g. ln -s ~/-wrk/-ve27/src ~/-wrk/src)
         __SRC     (str): global 'src' venv ./src directory path (~/-wrk/src/src)
                       ($__SRC/git $__SRC/git)
   ## Functions
         venv $@   -- call $_VENV $@
         venv -h   -- print venv --help
         venv --print-bash   -- print bash configuration
         venv --print-json   -- print IPython configuration as JSON
         venvw $@ -- venv -E $@ (for the current environment)
         workon_venv() -- workon a virtualenv and load venv (TAB-completion)
          param $1: $VIRTUAL_ENV_NAME ("dotfiles")
          param $2: $_APP ("dotfiles") [default: $1)
           ${WORKON_HOME}/${VIRTUAL_ENV_NAME}  # == $VIRTUAL_ENV
           ${VIRTUAL_ENV}/src                  # == $_SRC
           ${_SRC}/${VIRTUAL_ENV_NAME}         # == $_WRD
          examples:
           we dotfiles
           we dotfiles dotfiles
         we()          -- workon_venv
         _setup_venv_aliases()  -- load venv aliases
           note: these are overwritten by `we` [`source <(venv -b)`]
         makew     -- make -C "${WRD}" ${@}    [scripts/makew <TAB>]
         hgw       -- hg -R  ${_WRD}   [scripts/hgw <TAB>]
         gitw      -- git -C ${_WRD}   [scripts/gitw <TAB>]
         serve-()  -- ${_SERVE_}
         alias serve-='${_SERVE_}'
         shell-()  -- ${_SHELL_}
         alias shell-='${_SHELL_}'
         test-()   -- cd ${_WRD} && python setup.py test
         testr-()  -- reset; cd ${_WRD} && python setup.py test
         _setup_venv_prompt()    -- set PS1 with $WINDOW_TITLE, $VIRTUAL_ENV_NAME,
                                  and ${debian_chroot}
                   "WINDOW_TITLE (venvprompt) [debian_chroot]"
         try: _APP, VIRTUAL_ENV_NAME, $(basename VIRTUAL_ENV)
         TODO: CONDA
         venv_ls()     -- list virtualenv directories
         lsvenv()      -- venv_ls()
         venv_mkdirs()  -- create FSH paths in ${1} or ${VIRTUAL_ENV} 
   .

   
   
.. index:: etc/bash/11-bashrc.venv.pyramid.sh
.. _etc/bash/11-bashrc.venv.pyramid.sh:

etc/bash/11-bashrc.venv.pyramid.sh
===================================
| Src: `etc/bash/11-bashrc.venv.pyramid.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/11-bashrc.venv.pyramid.sh>`__

.. code:: bash

   .
   ### bashrc.venv.pyramid.sh
         workon_pyramid_app()  -- $VIRTUAL_ENV_NAME [$_APP] [open_terminals]
   .

   
   
.. index:: etc/bash/20-bashrc.editor.sh
.. _etc/bash/20-bashrc.editor.sh:

etc/bash/20-bashrc.editor.sh
=============================
| Src: `etc/bash/20-bashrc.editor.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/20-bashrc.editor.sh>`__

.. code:: bash

   .
   ### bashrc.editor.sh
         setup_editor()    -- configure ${EDITOR}
           VIMBIN  (str):   /usr/bin/vim
           GVIMBIN (str):   /usr/bin/gvim
           MVIMBIN (str):   /usr/local/bin/mvim
           GUIVIMBIN (str): $GVIMBIN || $MVIMBIN || ""
           EDITOR  (str):   $VIMBIN -f || $GUIVIMBIN -f
           EDITOR_ (str):   $EDITOR || $GUIVIMBIN $VIMCONF --remote-tab-silent
           VIMCONF (str):   --servername ${VIRTUAL_ENV_NAME:-'EDITOR'}
           SUDO_EDITOR (str): $EDITOR
         _setup_pager()    -- set PAGER='less'
         ggvim()   -- ${EDITOR} $@ 2>&1 >/dev/null
         edits()   -- open $@ in ${GUIVIMBIN} --servername $1
         editcfg() -- ${EDITOR_} ${_CFG} [ --servername $VIRTUAL_ENV_NAME ]
         sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
         sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
   .

   
   
.. index:: etc/bash/29-bashrc.vimpagers.sh
.. _etc/bash/29-bashrc.vimpagers.sh:

etc/bash/29-bashrc.vimpagers.sh
================================
| Src: `etc/bash/29-bashrc.vimpagers.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/29-bashrc.vimpagers.sh>`__

.. code:: bash

   .
   ### bashrc.vimpagers.sh
         _configure_lesspipe() -- (less <file.zip> | lessv)
         vimpager() -- call vimpager
         lessv()   -- less with less.vim and vim (g:tinyvim=1)
         lessg()   -- less with less.vim and gvim / mvim
         lesse()   -- less with current venv's vim server
         manv()    -- view manpages in vim
         mang()    -- view manpages in gvim / mvim
         mane()    -- open manpage with venv's vim server
   .

   
   
.. index:: etc/bash/30-bashrc.usrlog.sh
.. _etc/bash/30-bashrc.usrlog.sh:

etc/bash/30-bashrc.usrlog.sh
=============================
| Src: `etc/bash/30-bashrc.usrlog.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/30-bashrc.usrlog.sh>`__

.. code:: bash

   .
   ### bashrc.usrlog.sh
         _USRLOG (str): path to .usrlog userspace shell command log
         stid()      -- set $TERM_ID to a random string
         stid $name  -- set $TERM_ID to string
         note()      -- add a dated note to $_USRLOG [_usrlog_append]
         usrlogv()   -- open usrlog with vim:   $VIMBIN + $_USRLOG
         usrlogg()   -- open usrlog with gmvim: $GUIVIMBIN + $_USRLOG
         usrloge()   -- open usrlog with editor:$EDITOR + $_USRLOG
         ut()        -- tail $_USRLOG
         ug()        -- egrep current usrlog: egrep $@ $_USRLOG
         ugall()     -- egrep $@ $__USRLOG ${WORKON_HOME}/*/.usrlog
         ugrin()     -- grin current usrlog: grin $@ $_USRLOG
         ugrinall()  -- grin $@  $__USRLOG ${WORKON_HOME}/*/.usrlog
         lsusrlogs() -- ls -tr   $__USRLOG ${WORKON_HOME}/*/.usrlog
         _setup_usrlog()   -- source ${__DOTFILES}/etc/usrlog.sh
         usrlogv() -- open $_USRLOG w/ $VIMBIN (and skip to end)
         usrlogg() -- open $_USRLOG w/ $GUIVIMBIN (and skip to end)
         usrloge() -- open $_USRLOG w/ $EDITOR_ [ --servername $VIRTUAL_ENV_NAME ]
   .

   
   
.. index:: etc/bash/30-bashrc.xlck.sh
.. _etc/bash/30-bashrc.xlck.sh:

etc/bash/30-bashrc.xlck.sh
===========================
| Src: `etc/bash/30-bashrc.xlck.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/30-bashrc.xlck.sh>`__

.. code:: bash

   .
   ### 30-bashrc.xlck.sh
   ## xlck     -- minimal X screensaver
         xlck 
         xlck -I  --  (I)nstall xlck (apt-get)
         xlck -U  --  check stat(U)s (show xautolock processes on this $DISPLAY)
         xlck -S  --  (S)tart xlck (start xautolock on this $DISPLAY)
         xlck -P  --  sto(P) xlck (stop xautolock on this $DISPLAY)
         xlck -R  --  (R)estart xlck
         xlck -M  --  suspend to ra(M) (and lock)
         xlck -D  --  suspend to (D)isk (and lock)
         xlck -L  --  (L)ock
         xlck -X  --  shutdown -h now
         xlck -h  --  help
         xlck_status_all()             -- pgrep 'xautolock|xlock|i3lock', ps ufw
         xlck_status_this_display()    -- show status for this $DISPLAY
         _setup_xlck() -- source ${__DOTFILES}/etc/xlck.sh (if -z __IS_MAC)
   .

   
   
.. index:: etc/bash/40-bashrc.aliases.sh
.. _etc/bash/40-bashrc.aliases.sh:

etc/bash/40-bashrc.aliases.sh
==============================
| Src: `etc/bash/40-bashrc.aliases.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/40-bashrc.aliases.sh>`__

.. code:: bash

   .
   ### bashrc.aliases.sh
          _load_aliases()  -- load aliases
         chmodr   -- 'chmod -R'
         chownr   -- 'chown -R'
         grep     -- 'grep --color=auto'
         egrep    -- 'egrep --color=auto'
         fgrep    -- 'fgrep --color=auto'
         grindp   -- 'grind --sys.path'
         grinp    -- 'grin --sys-path'
         fumnt    -- 'fusermount -u'
         ga       -- 'git add'
         gac()    -- 'git diff ${files}; git commit -m $1 ${files}'
           $1 (str): quoted commit message
           $2- (list): file paths
         gb       -- 'git branch -v'
         gd       -- 'git diff'
         gds      -- 'git diff -p --stat'
         gc       -- 'git commit'
         gco      -- 'git checkout'
         gdc      -- 'git diff --cached'
         gl       -- 'git log --pretty=format:"%h : %an : %s" --topo-order --graph'
         gr       -- 'git remote -v'
         gs       -- 'git status'
         gsi      -- 'git is; git diff; git diff --cached'
         gsiw      -- 'git -C $_WRD gsi'
         gsl      -- 'git stash list'
         gsn      -- 'git stash save'
         gss      -- 'git stash save'
         gitr     -- 'git remote -v'
         hga      -- 'hg add'
         hgac()   -- 'hg add $@[1:]; hg commit $1'
           $1 (str): quoted commit message
           $2- (list): file paths
         hgl      -- 'hg glog --pager=yes'
         hgs      -- 'hg status'
         hgd      -- 'hg diff'
         hgds     -- 'hg diff --stat'
         hgdl     -- 'hg diff --color=always | less -R'
         hgc      -- 'hg commit'
         hgu      -- 'hg update'
         hgq      -- 'hg qseries'
         hgqd     -- 'hg qdiff'
         hgqs     -- 'hg qseries'
         hgqn     -- 'hg qnew'
         hgr      -- 'hg paths'
         __IS_MAC
             la       -- 'ls -A -G'
             ll       -- 'ls -alF -G'
             ls       -- 'ls -G'
             lt       -- 'ls -altr -G'
             lll      -- 'ls -altr -G'
         else
             la       -- 'ls -A --color=auto'
             ll       -- 'ls -alF --color=auto'
             ls       -- 'ls --color=auto'
             lt       -- 'ls -altr --color=auto'
             lll      -- 'ls -altr --color=auto'
         __IS_LINUX
             psx      -- 'ps uxaw'
             psf      -- 'ps uxawf'
             psxs     -- 'ps uxawf --sort=tty,ppid,pid'
             psxh     -- 'ps uxawf --sort=tty,ppid,pid | head'
             psh      -- 'ps uxaw | head'
             psc      -- 'ps uxaw --sort=-pcpu'
             psch     -- 'ps uxaw --sort=-pcpu | head'
             psm      -- 'ps uxaw --sort=-pmem'
             psmh     -- 'ps uxaw --sort=-pmem | head'
         __IS_MAC
             psx      -- 'ps uxaw'
             psf      -- 'ps uxaw' # no -f
             psh      -- 'ps uxaw | head'
             psc      -- 'ps uxaw -c'
             psch     -- 'ps uxaw -c | head'
             psm      -- 'ps uxaw -m'
             psmh     -- 'ps uxaw -m | head'
         pyg      -- pygmentize [pip install --user pygments]
         catp     -- pygmentize [pip install --user pygments]
         shtop    -- 'sudo htop' [apt-get/yum install -y htop]
         t        -- 'tail'
         tf       -- 'tail -f'
         xclipc   -- 'xclip -selection c'
   .

   
   
.. index:: etc/bash/42-bashrc.commands.sh
.. _etc/bash/42-bashrc.commands.sh:

etc/bash/42-bashrc.commands.sh
===============================
| Src: `etc/bash/42-bashrc.commands.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/42-bashrc.commands.sh>`__

.. code:: bash

   .
   ### bashrc.commands.sh
     usage: bash -c 'source bashrc.commands.sh; funcname <args>'
         chown-me()        -- chown -Rv user
         chown-me-mine()   -- chown -Rv user:user && chmod -Rv go-rwx
         chown-sme()       -- sudo chown -Rv user
         chown-sme-mine()  -- sudo chown -Rv user:user && chmod -Rv go-rwx
         chmod-unumask()   -- recursively add other+r (files) and other+rx (dirs)
   .

   
   
.. index:: etc/bash/50-bashrc.bashmarks.sh
.. _etc/bash/50-bashrc.bashmarks.sh:

etc/bash/50-bashrc.bashmarks.sh
================================
| Src: `etc/bash/50-bashrc.bashmarks.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/50-bashrc.bashmarks.sh>`__

.. code:: bash

   .
   ### bashrc.bashmarks.sh
   ## bashmarks
         l()  -- list bashmarks
         s()  -- save bashmarks as $1
         g()  -- goto bashmark $1
         p()  -- print bashmark $1
         d()  -- delete bashmark $1
         lsbashmarks() -- list Bashmarks (e.g. for NERDTree)
         see also: ${__DOTFILES}/scripts/nerdtree_to_bashmarks.py
   .

   
   
.. index:: etc/bash/70-bashrc.repos.sh
.. _etc/bash/70-bashrc.repos.sh:

etc/bash/70-bashrc.repos.sh
============================
| Src: `etc/bash/70-bashrc.repos.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/70-bashrc.repos.sh>`__

.. code:: bash

   .
   ### 70-bashrc.repos.sh
          git-commit()   -- git commit ${2:} -m ${1}; git log -n1 
          gc()             -- git-commit() <files> -m <log> ; log log -n1
          git-add-commit()   -- git add ${2:}; git commit ${2} -m ${1}; git log -n1 
          gac()            -- git-add-commit $@
     function msg {
       export _MSG="${@}"
       see: usrlog.sh
     }
          gitcmsg()    -- gitc "${_MSG}" ${@}
          gitcaddmsg()    -- gitc "${_MSG}" ${@}
    
    
    
     Use Cases
     * Original: a bunch of commands that i was running frequently
       before readthedocs (and hostthedocs)
     * local mirrors (manual, daily?)
       * no internet, outages
       * push -f
       * (~offline) Puppet/Salt source installs
         * bandwidth: testing a recipe that pulls a whole repositor(ies)
     * what's changed in <project>'s source dependencies, since i looked last
    
     Justification
     * very real risks for all development projects
       * we just assume that GitHub etc. are immutable and forever
    
     Features (TODO) [see: pyrpo]
     * Hg <subcommands>
     * Git <subcommands>
     * Bzr <subcommands>
     * periodic backups / mirroring
     * gitweb / hgweb
     * mirror_and_backup <URL>
     * all changes since <date> for <set_of_hg-git-bzr-svn_repositories>
     * ideally: transparent proxy
       * +1: easiest
       * -1: pushing upstream
    
     Caveats
     * pasting / referencing links which are local paths
     * synchronization lag
     * duplication: $__SRC/hg/<pkg> AND $VIRTUAL_ENV/src/<pkg>
    
          setup_dotfiles_docs_venv -- create default 'docs' venv
          setup_dotfiles_src_venv -- create default 'src' venv
        
           __SRC_HG=${WORKON_HOME}/src/src/hg
           __SRC_GIT=${WORKON_HOME}/src/src/git
        
          Hg runs hg commands as user hg
          Git runs git commands as user git
        
          Hgclone will mirror to $__SRC_HG
          Gitclone will mirror to $__SRC_GIT
        
        
     __SRC_GIT_REMOTE_URI_PREFIX   -- default git remote uri prefix
     __SRC_GIT_REMOTE_NAME         -- name for git remote v
     __SRC_HG_REMOTE_URI_PREFIX    -- default hg remote uri prefix
     __SRC_HG_REMOTE_NAME          -- name for hg paths
       ## Create a new hosted repository with gitolite-admin
          $1   -- repo [user/]name (e.g. westurner/dotfiles)
       ## push a git repository to local git storage
          $1   -- repo [user/]name (e.g. westurner/dotfiles) 
          $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
       ## Create a new hosted repository with mercurial-ssh
       ## push a hg repository to local git storage
          $1   -- repo [user/]name (e.g. westurner/dotfiles)
          $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
            fixperms ${path}
          host_docs    -- build and host documentation in a local directory
           param $1: <project_name>
           param $2: [<path>]
           param $3: [<docs/Makefile>]
           param $4: [<docs/conf.py>]
         * log documentation builds
         * build a sphinx documentation set with a Makefile and a conf.py
         * rsync to docs webserver
         * set permissions
         this is not readthedocs.org
         note: you must manually install packages into the
         local 'docs' virtualenv'
                             TODO: prompt?
             >> 'html_theme = "_-_"
             << 'html_theme = 'default'
   .

   
   
.. index:: etc/bash/99-bashrc.after.sh
.. _etc/bash/99-bashrc.after.sh:

etc/bash/99-bashrc.after.sh
============================
| Src: `etc/bash/99-bashrc.after.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/99-bashrc.after.sh>`__

.. code:: bash

   .
   .

   
   
.. index:: etc/bash/_ewrd.sh
.. _etc/bash/_ewrd.sh:

etc/bash/_ewrd.sh
==================
| Src: `etc/bash/_ewrd.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/_ewrd.sh>`__

.. code:: bash

   .
   ###   _ewrd.sh  -- convenient editor shortcuts
         # setup edit[*] and e[*] symlinks:
         $ ln -s ./_ewrd.sh _ewrd-setup.sh && ./_ewrd-setup.sh
   ##    editdotfiles, edotfiles -- cd $__DOTFILES and run edit w/ each arg
         editdotfiles() -- cd $__DOTFILES and run edit w/ each arg
         edotfiles()    -- cd $__DOTFILES and run edit w/ each arg
   ##    editwrk, ewrk   --- cd $__WRK and run edit w/ each arg
         editwrk()      -- cd $__WRK and run edit w/ each arg
         ewrk()         -- cd $__WRK and run edit w/ each arg
   ##    editworkonhome, eworkonhome --- cd $WORKON_HOME and run edit w/ each arg
         editworkonhome() -- cd $WORKON_HOME and run edit w/ each arg
         eworkonhome()    -- cd $WORKON_HOME and run edit w/ each arg
         ewh()            -- cd $WORKON_HOME and run edit w/ each arg
   ##    editvirtualenv, evirtualenv, ev  --- cd $VIRTUAL_ENV and run edit w/ each arg
         editvirtualenv() -- cd $VIRTUAL_ENV and run edit w/ each arg
         evirtualenv()    -- cd $VIRTUAL_ENV and run edit w/ each arg
         ev()             -- cd $VIRTUAL_ENV and run edit w/ each arg
   ##    editsrc, esrc, es  --- cd $_SRC and run edit w/ each arg
         editsrc() -- cd $_SRC and run edit w/ each arg
         esrc()    -- cd $_SRC and run edit w/ each arg
         es()      -- cd $_SRC and run edit w/ each arg
   ##    editwrd, ewrd, ew  --- cd $_WRD and run edit w/ each arg
         editwrd() -- cd $_WRD and run edit w/ each arg
         ewrd()    -- cd $_WRD and run edit w/ each arg
         ew()      -- cd $_WRD and run edit w/ each arg
   ##    editetc, eetc      --- cd $_ETC and run edit w/ each arg
         editetc() -- cd $_ETC and run edit w/ each arg
         eetc()    -- cd $_ETC and run edit w/ each arg
   ##    editwww, ewww      --- cd $_WWW and run edit w/ each arg
         editwww() -- cd $_WWW and run edit w/ each arg
         ewww()    -- cd $_WWW and run edit w/ each arg
    
   ## seeAlso ##
     * https://westurner.org/dotfiles/venv
    
     .. code:: bash
    
        type cdhelp; cdhelp 
        less scripts/venv_cdaliases.sh
        venv.py --prefix=/ --print-bash-cdaliases
   .

   
   
.. index:: etc/bash/usrlog.sh
.. _etc/bash/usrlog.sh:

etc/bash/usrlog.sh
===================
| Src: `etc/bash/usrlog.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/usrlog.sh>`__

.. code:: bash

   .
   ### usrlog.sh -- Shell CLI REPL command logs in userspace (per $VIRTUAL_ENV)
    
      Log shell commands with metadata as tab-separated lines to ${_USRLOG}
      with a shell identifier to differentiate between open windows,
      testing/screencast flows, etc
    
      By default, _USRLOG will be set to a random string prefixed with '#'
      by the `stid()` bash function (`_usrlog_set__TERM_ID()`)
    
      * _TERM_ID can be set to any string;
      * _TERM_ID is displayed in the PS1 prompt
      * _TERM_ID is displayed in the window title
      * _TERM_ID is reset to __TERM_ID upon 'deactivate'
        (westurner/dotfiles//etc/bash/07-bashrc.virtualenvwrapper.sh:
         TODO: virtualenvwrapper, conda)
    
      Environment Variables:
    
       __USRLOG (str): default -usrlog.log file (~/-usrlog.log)
       _USRLOG  (str): current -usrlog.log file to append REPL command strings to
       _TERM_ID (str): a terminal identifier with which command loglines will
                       be appended (default: _usrlog_randstr)
    
          _usrlog_get_prefix()    -- get a dirpath for the current usrlog
                                     (VIRTUAL_ENV or HOME)
          _usrlog_set__USRLOG()    -- set $_USRLOG (and $__USRLOG)
          _usrlog_set_HISTFILE()   -- configure shell history
               history -a   -- append any un-flushed lines to $HISTFILE
         set/touch HISTFILE
           history -c && history -r $HISTFILE   -- clear; reload $HISTFILE
             ZSH_VERSION
          _usrlog_set_HIST()    -- set shell $HIST<...> variables
          see HISTSIZE and HISTFILESIZE in bash(1)
          note that HOSTNAME and USER come from the environ
          and MUST be evaluated at the time HISTTIMEFORMAT is set.
          ... or force ignoredups and ignorespace
          HISTCONTROL=ignoredups:ignorespace
              append current lines to history
              append to the history file, don't overwrite it
              https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin
              replace newlines with semicolons
              enable autocd (if available)
          _usrlog_randstr      -- Generate a random string
            $1: number of characters
          _usrlog_get__TERM_ID()   -- echo the current _TERM_ID and $_USRLOG
          _usrlog_Set__TERM_ID     -- set or randomize the $_TERM_ID key
            $1: _term_id value for _TERM_ID
          _usrlog_echo_title   -- set window title (by echo'ing escape codes)
          else
             echo -ne "${USRLOG_WINDOW_TITLE}"
          _usrlog_set_title()  --  set xterm title
           $1: _window_title (defaults to ${_TERM_ID})
          _usrlog_setup()      -- configure usrlog for the current shell
          setup bash
          setup zsh
          _usrlog_append()  -- Write a line to $_USRLOG w/ an ISO8601 timestamp
            $1: text (command) to log
            note: _TERM_ID must not contain a tab character (tr '\t' ' ')
            note: _TERM_ID can be a URN, URL, URL, or simple \w+ str key
          example:
            2014-11-15T06:42:00-0600	dotfiles	 8311  ls
            (pwd -p)?
             this from HISTORY
        #  _usrlog_append_oldstype -- Write a line to $_USRLOG
        #    $1: text (command) to log
        #  examples:
        #    # qMZwZSGvJv8: 10/28/14 17:25.54 :::   522  histgrep BUG
        #    #ZbH08n8unY8	2014-11-11T12:27:22-0600	 2238  ls
        printf "#  %-11s: %s : %s" \
            "$_TERM_ID" \
            "$(date +'%D %R.%S')" \
            "${1:-'\n'}" \
                | tee -a $_USRLOG >&2
          _usrlog_writecmd()    -- write the most recent command to $_USRLOG
   ## usrlog parsing
          _usrlog_parse_newstyle -- Parse a -usrlog.log with pyline
            NOTE: handle when HISTTIMEFORMAT=""
            NOTE: this is approxmte (see: venv.py)
          _usrlog_parse_cmds -- Show histcmd or histstr from HISTTIMEFORMAT usrlog
          with pyline
          TODO: handle HISTTIMEFORMAT="" (" histn  <cmd>")
          TODO: handle newlines (commands that start on the next line)  (venv.py)
          NOTE: HISTTIMEFORMAT histn (OSX  ) [ 8 ]
          NOTE: HISTTIMEFORMAT histn (Linux) [ 7 ]
            'list((
                (" ".join(w[10:]).rstrip() if len(w) > 10 else None)
                or (" ".join(w[9:]).rstrip() if len(w) > 9 else None)
                or (" ".join(w[8:]).rstrip() if len(w) > 8 else None)
                or (" ".join(w[7:]).rstrip() if len(w) > 7 else None)
                or (" ".join(w[3:]).rstrip() if len(w) > 3 else None)
                or " ".join(w).rstrip())
                for w in [ line and line.startswith("#") and line.split("\t",9) or [line] ]
                )'
   ## usrlog.sh API
   ### usrlog _TERM_ID commands
          termid()      -- echo $_TERM_ID
          set_term_id() -- set $_TERM_ID to a randomstr or $1
          stid()        -- set $_TERM_ID to a randomstr or $1
          st()          -- set $_TERM_ID to a randomstr or $1
   ### usrlog tail commands
          ut()  -- show recent commands
          uta()  -- tail all usrlogs from lsusrlogs
          utap()  -- tail all userlogs from lsusrlogs and parse
          ut()  -- show recent commands
          usrlog_tail()     -- tail -n20 $_USRLOG
          usrlogtf()    -- tail -f -n20 $_USRLOG
          utf()         -- tail -f -n20 $_USRLOG
   ### usrlog grep commands
          usrlog_grep() -- egrep -n $_USRLOG
          ug()          -- egrep -n $_USRLOG
          uga2()
         # usrlog_grep_session_id()  -- egrep ".*\t${1:-$_TERM_ID}"
         (set -x;
         local _term_id=${1:-"${_TERM_ID}"};
         local _usrlog=${2:-"${_USRLOG}"};
         egrep "# [\d-T:Z ]+\t${_term_id}\t" ${_USRLOG} )
         usrlog_grep_todos | _usrlog_parse_cmds
         usrlog_grep_todos | _usrlog_parse_cmds
         usrlog_grep_todos | _usrlog_parse_cmds
         pyline '(l.replace("#TODO: ", "- [ ] ", 1).replace("#NOTE:", "- ", 1) if l.startswith("#TODO: ", "#NOTE: ") else l)'
          usrlog_grin() -- grin -s $@ $_USRLOG
          ugrin()       -- grin -s $@ $_USRLOG
          usrlog_grin_session_id()  -- egrep ".*\t${1:-$_TERM_ID}"
          usrlog_grin_session_id()  -- egrep ".*\t${1:-$_TERM_ID}"
          usrlog_grin_session_id_all()  -- grep $2:-$_USRLOG for $1:-$_TERM_ID
                                           in column position
            :returns: unsorted list of log entries in files
                      listed by mtime and then cat
        
          .. warning:: output lines are in file sequence but otherwise
                        unsorted
        
          ugrins()  -- grep $2:-$_USRLOG for $1:-$_TERM_ID in column position
          usrlog_grin_session_id_all_cmds()  -- grep $2:-$_USRLOG for $1:-$_TERM_ID
                                                in column position
          lsusrlogs_date_desc()   -- ls $__USRLOG ${WORKON_HOME}/*/.usrlog
                                     (oldest first)
          lsusrlogs_date_desc()   -- ls $__USRLOG ${WORKON_HOME}/*/.usrlog
                                     (newest first)
          lsusrlogs()             -- list usrlogs (oldest first)
          usrlog_lately()      -- lsusrlogs by mtime
          ull()                -- usrlog_lately() (lsusrlogs by mtime)
          usrlog_grep_all()    -- grep $(lsusrlogs) (drop filenames with -h)
          ugall()              -- grep $(lsusrlogs) (drop filenames with -h)
          uga()                -- grep $(lsusrlogs) (drop filenames with -h)
          usrlog_grin_all()    -- grin usrlogs
          usrlog_grin_all()    -- grin usrlogs
          todo()   -- _usrlog_append a #TODO and set _TODO ('-' unsets, '' prints)
              see: usrlog_grep_todos_parse (ugt, ugtp) 
          note()   -- _usrlog_append a #NOTE and set _NOTE ('-' unsets, '' prints)
          msg()   -- _usrlog_append a #_MSG and set __MSG ('-' unsets, '' prints)
          usrlog_screenrec_ffmpeg() -- record a screencast
            $1: destination directory (use /tmp if possible)
            $2: video name to append to datestamp
            - Press "q" to stop recording
          usrlogw()       -- usrlog.py -p ${_USRLOG} ${@}
          _setup_usrlog() -- call _usrlog_setup $@
   ## calls _usrlog_setup when sourced
   .

   
   
.. index:: etc/bash/xlck.sh
.. _etc/bash/xlck.sh:

etc/bash/xlck.sh
=================
| Src: `etc/bash/xlck.sh <https://github.com/westurner/dotfiles/tree/develop/etc/bash/xlck.sh>`__

.. code:: bash

   .
   ### xlck.sh -- script wrapper for xautolock, xlock, and/or i3lock
   ##             as well as issuing suspend, shutdown, and restart commands
         xlck()            -- xlck $@
         _xlck_install()   -- install xlck dependencies
         xlck requires: bash, pgrep, ps, kill, xautolock, xlock, i3lock, xset
         _xlck_setup_dpms() -- configure display with xset and dpms
         _xlck_setup()     -- setup xlck (export _XLCK=(this) && _xlck_setup_dpms)
         _xlck_xlck()      -- start xlock (white on black w/ a 3 second delay)
         _xlck_i3lock()    -- start i3lock with a dark gray background
         xlck_gnome_screensaver_status()  -- gnome-screensaver PIDs on $DISPLAY
         xlck_gnome_screensaver_start() -- start gnome-screensaver
         xlck_gnome_screensaver_lock() -- lock gnome-screensaver
         xlock_lock()      -- lock the current display
           $1 {i3lock|i3, xlock|x, gnome-screensaver|gnome|g}
           note: this will be run before suspend to RAM and Disk.
         _suspend_to_ram()     -- echo mem > /sys/power/state
         _suspend_to_disk()    -- echo disk > /sys/power/state
          note: this does not work on many machines
         _dbus_halt()      -- send a dbus stop msg to ConsoleKit
         _dbus_reboot()    -- send a dbus reboot msg to ConsoleKit
         _dbus_suspend()   -- send a dbus suspend msg to ConsoleKit
         _dbus_hibernate() -- send a dbus hibernate msg to ConsoleKit
         xlck_lock_suspend_ram()   -- lock and suspend to RAM
         xlck_lock_suspend_disk()  -- lock and suspend to disk
         xlck_suspend_ram()        -- lock and suspend to RAM
         xlck_suspend_disk()       -- lock and suspend to disk
         xlck_start()              -- start xlck
         xlck_stop()               -- stop xlck
         xlck_restart()            -- stop and start xlck
         xlck_pgrep_display()-- find xautolock on this display
         xlck_xautolock_pgrep_display()-- find xautolock on this display
         xlck_xautolock_status()       -- show xlck status 
         xlck_autolock_stop()          -- stop autolock on the current $DISPLAY
         xlck_status()     -- xlck_xautolock_status
         xlck_status_all() -- pgrep 'xautolock|xlock|i3lock', ps ufw
         xlck_status_this_display()  -- show status for this $DISPLAY
         _xlck_xautolock()           -- start xautolock (see: xlck_start)
             return nonzero if no args
   .

   
   
.. index:: etc/zsh/00-zshrc.before.sh
.. _etc/zsh/00-zshrc.before.sh:

etc/zsh/00-zshrc.before.sh
===========================
| Src: `etc/zsh/00-zshrc.before.sh <https://github.com/westurner/dotfiles/tree/develop/etc/zsh/00-zshrc.before.sh>`__

.. code:: bash

   .
      __DOTFILES -- local dotfiles repository clone
         ## lib: zsh functions
         ## bash: read bash config with bash_source function
       ## after:
          dr()     -- dotfiles_zsh_reload $@
   .

   
   
.. index:: etc/zsh/01-zshrc.lib.sh
.. _etc/zsh/01-zshrc.lib.sh:

etc/zsh/01-zshrc.lib.sh
========================
| Src: `etc/zsh/01-zshrc.lib.sh <https://github.com/westurner/dotfiles/tree/develop/etc/zsh/01-zshrc.lib.sh>`__

.. code:: bash

   .
     list all path key components leading to file
   .

   
   
.. index:: etc/zsh/05-zshrc.bashrc.sh
.. _etc/zsh/05-zshrc.bashrc.sh:

etc/zsh/05-zshrc.bashrc.sh
===========================
| Src: `etc/zsh/05-zshrc.bashrc.sh <https://github.com/westurner/dotfiles/tree/develop/etc/zsh/05-zshrc.bashrc.sh>`__

.. code:: bash

   .
     requires:
      bash_source function
      $__DOTFILES
   .

   
   
.. index:: etc/zsh/99-zshrc.after.sh
.. _etc/zsh/99-zshrc.after.sh:

etc/zsh/99-zshrc.after.sh
==========================
| Src: `etc/zsh/99-zshrc.after.sh <https://github.com/westurner/dotfiles/tree/develop/etc/zsh/99-zshrc.after.sh>`__

.. code:: bash

   .
     99-zsh.after.sh
   .

   
   
.. index:: etc/i3/config
.. _etc/i3/config:

etc/i3/config
==============
| Src: `etc/i3/config <https://github.com/westurner/dotfiles/tree/develop/etc/i3/config>`__

.. code:: bash

   .
   #### i3 config file (v4)
   
     #  Default location: ~/.i3/config
     #  List commented command shortcuts with::
   
     #     cat ~/.i3/config | egrep '(^(\s+)?##+ |^(\s+)?#  )'
   
    #!/bin/sh
    ### .i3/config requirements
   
    ## Ubuntu (12.04)
    # MUST
    apt-get install i3 i3status xautolock xlockmore i3lock
    hg clone https://github.com/westurner/dotfiles ~/.dotfiles  # etc/xlck.sh
   
    # SHOULD
    apt-get install gnome-terminal network-manager-gnome thunar pulseaudio-utils
    apt-get install feh                  # wallpaper
    apt-get install xfce4-screenshooter  # screenshots
    mkdir -p ~/pictures/screens          # screenshots
    apt-get install xbacklight           # brightness
   
    # COULD
    apt-get install vim-gnome            # scratchpad
    add-apt-repository ppa:kilian/f.lux  # f.lux
    apt-get update                       # f.lux
    apt-get install fluxgui              # http://justgetflux.com
   
    ## References
    * http://i3wm.org/docs/userguide.html
    * https://faq.i3wm.org/question/1425/variable-substitution/
    * i3-config-wizard
   
    ## Notes
    * grab keyboard mappings: xev | grep keycode
   ### Configure I3
   ## To swap layouts: (make swap-layout)
      sed 's/<alt>/<ALT>/g' && sed 's/<super>/<alt>/g' && sed 's/<ALT>/<super>/g'
   ## Set i3 keyboard modifier keys to variables $mod1 and $mod2  (for keyboard layout flexibility)
   ## PC Keyboard (default) ##
       PC: $mod1  == <Alt>
       PC: $mod2 == <Super>
   ## Alternate (e.g. Mac Keyboard ) ##
       Mac: $mod1  == <Super>
       Mac: $mod2 == <Alt>
    font for window titles. ISO 10646 = Unicode
    Pango requires i3 version >= ____
    reload the configuration file
     <alt><shift> c   -- reload i3 configuration
    restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
     <alt><shift> r   -- restart i3 (session preserving)
    exit i3 (logs you out of your X session)
     <super><shift> l  -- exit i3 (close all and logout of X session)
     <alt><shift> q   -- close focused window
     # Hide edge borders
   ### Launch programs
   ## Set Variables
    Open default tabs
    Open a blank tab/window with the default browser
    Open a browser tab/window to gmail#all with the default browser
     # Get WM_CLASS with $(xprop WM_CLASS)
   ## Autoruns
   
     - Start gnome-settings-daemon (e.g. for anti-aliasing)
     $PATH/gnome-settings-daemon        -- Ubuntu, Debian
     /usr/libexec/gnome-settings-daemon -- Fedora
     - Start screensaver
     - Set X background
     - Set X wallaper to (~/wallpaper.png)
    - Launch network applet (optional)
    see also: nmcli
   ## Lock, shutdown and suspend
     <super> l        -- lock screen
     <XF86PowerOff>   -- exit
     <XF86Sleep>      -- suspend
   ## Change backlight brightness
     <XF86MonBrightnessUp>      -- brightness up
     <XF86MonBrightnessDown>    -- brightness down
   ## Change volume
     <XF86AudioRaiseVolume>   -- volume up
     <XF86AudioLowerVolume>   -- volume down
   ## Launch Applications
     <alt> x      -- run command
     <super> r    -- run command
     <super> e    -- launch browser
     <alt><shift> g   -- launch editor
     <alt><shift> b   -- launch browser
     <alt><shift> t   -- launch terminal
     <super> t        -- launch terminal
     <alt> <enter>    -- launch terminal
     <super> <enter>    -- launch terminal
     XF86Calculator   -- launch calculator
     <alt><shift> w          -- launch network manager applet (see also: $(nmcli))
     <PrintScr>       -- screenshot (full screen)
     <alt> <PrintScr> -- screenshot (current window)
     <super><shift> 3       -- screenshot (full screen)
     <super><shift> 4       -- screenshot (current window)
   ## Focus to nearest instance
     <alt> v      -- focus nearest: editor
     <alt> t      -- focus nearest: terminal
     <alt> b      -- focus nearest: browser
   ## Start, stop, and reset xflux
     <alt> [         -- start xflux
     <alt> ]         -- stop xflux
     <alt><shift> ]  -- reset gamma to 1.0
     <alt><shift> [  -- xgamma -bgamma 0.6 -ggamma 0.9 -rgamma 0.9
     <alt><shift> \  -- xgamma -bgamma -0.4 -ggamma 0.4 -rgamma 0.9
   ## Change focus between tiling / floating windows
     <alt> <space>            -- toggle focus mode: tiling / floating
   ## Floating windows
     <alt><shift> <space>     -- toggle tiling/floating mode for focused window
     <alt> <backspace>        -- toggle tiling/floating mode for focused window
     <alt> <mouse>            -- drag floating window to position
   ## Fullscreen mode
     # Note: popups will be hidden below fullscreened windows
     <alt><shift> f   -- fullscreen
     # popup during fullscreen exits fullscreen
   ## Split windows
    Split next window
     <alt><shift> h   -- split [next] window horizontally
     <alt><shift> v   -- split [next] window vertically
   ## Toggle window layouts
     <alt> w          -- tabbed window layout
     <alt> e          -- Default window layout
     <alt> s          -- stacked window layout
   ## Focus parent/child windows
     <alt> a          -- focus parent container
     <alt><shift> a   -- focus child container
   ## Switch to window / container
     <alt> Up     -- focus up
     <alt> Down   -- focus down
     <alt> Left   -- focus left
     <alt> Right  -- focus right
   ## Switch to window / container (Vi)
     <alt> h      -- focus left
     <alt> j      -- focus down
     <alt> k      -- focus up
     <alt> l      -- focus right
   ## Switch to previous / next workspace with <super> minus / equal
     <super> - (minus)  -- switch to previous workspace
     <super> = (equal)  -- switch to next workspace
     Toggle between previous and current workspace
   ## Switch to workspace
     <alt> 0-9        -- switch to workspace N  (repeat to return)
     <super> 0-9      -- switch to workspace N  (repeat to return)
     <alt> <F_n>      -- switch to workspace N (repeat to return)
     <alt> <Keypad_n> -- switch to workspace N (repeat to return)
   ## Move to next/previous workspace
     <super> Left     -- move to previous workspace
     <super> Right    -- move to next workspace
     <super> Up       -- move to second most recently focused workspace
   ## Move focused container to next/previous workspace
     <super> Left     -- move container to previous workspace
     <super> Right    -- move container to next workspace
     <super> Up       -- move container to second most recently focused workspace
   ## Move focused container within workspace
     <alt><shift> Up      -- move window up
     <alt><shift> Down    -- move window down
     <alt><shift> Left    -- move window left
     <alt><shift> Right   -- move window right
   ## Move focused container within workspace (Vi)
     <alt><shift> h       -- move window left
     <alt><shift> j       -- move window down
     <alt><shift> k       -- move window up
     <alt><shift> l       -- move window right
   ## Move focused container to workspace
     <alt><shift>  [N: 0-9]   -- move to workspace N
   ## Move focused container to workspaces (with number pad)
     <alt><shift> [KP_N: 0-9] -- move to workspace N
   ## Move focused container to workspaces (with number pad)
     <super> [KP_N: 0-9] -- move to workspace N
   ## Move workspace to output (e.g. with multiple monitors)
     <super><shift> Left  -- move workspace to left
     <super><shift> Right -- move workspace to right
   ## Scratchpad workspace
     <alt><shift> <minus>     -- make the currently focused window a scratchpad
     <alt> <minus>            -- show/hide and cycle through scratchpad windows
     <alt><shift> s           -- start scratchpad editor
     <alt> <XF86Favorites>    -- start scratchpad editor
     <XF86Favorites>          -- show the $scratchpad_editor_selector
     <alt> <backspace>        -- toggle tiling/floating mode for focused window
    see above.
     # on (re)load, move $scratchpad_editor_selector windows to scratchpad
   ## Resize Mode
     <alt> r      -- enter resize mode
       ## Grow and shrink windows
        These bindings trigger as soon as you enter the resize mode
       
        They resize the border in the direction you pressed, e.g.
        when pressing left, the window is resized so that it has
        more space on its left
        same bindings, but for the arrow keys
         Left         -- grow left
         <shift> Left     -- shrink left
         Down             -- grow down
         <shift> Down     -- shrink down
         Up               -- grow up
         <shift> Up       -- shrink up
         Right            -- grow right
         <shift> Right    -- shrink right
       ## Grow and shrink windows (Vi)
         h            -- grow left
         <shift> h    -- shrink left
         j            -- grow down
         <shift> j    -- shrink down
         k            -- grow up
         <shift> k    -- shrink up
         l            -- grow right
         <shift> l    -- shrink right
        back to normal: Enter or Escape
         <enter>  -- exit resize mode
         <esc>    -- exit resize mode
   ## Set colors
    color defines for zenburn styled i3 derived from:
    https://faq.i3wm.org/question/2071/how-can-i-change-look-of-windows/?answer=2075
    set some nice colors      border     background  text
   ## i3bar
     # display i3bar with i3status
        $ xrandr-tool outputs
   .

.. index:: etc/vim/vimrc
.. _etc/vim/vimrc:

etc/vim/vimrc
==============
| Src: `etc/vim/vimrc <https://github.com/westurner/dotvim/tree/master/vimrc>`__

.. code:: vim

   .
   .vimrc
   ==========
   ::
     git clone https://github.com/westurner/dotvim
     git clone ssh://git@github.com/westurner/dotvim
     make help
   Vim Reference
   ---------------
    :help            --  open vim help               [help]
    :help <tag>      --  open vim help for           [<tag>]
                         tag: (<cmd>, plugin/doc/<tag>.txt)
    :help vimtutor   --  open vim help for vimtutor tutorial
    :help quickref   --  open vim quick reference    [quickref, Q_bu]
    :<up arrow>      --  search backward through vim history
    [[               --  up a section                [ [[ ]
    C-o              --  goto previous position      [CTRL-O, jumplist]
    C-]              --  follow a tag (help quickref, select Q_bu, C-])
    %          --  variable: current filename
    %:p        --  variable: current filepath
    %          --  motion: find the next instance of selected word [%]
    :buffers         --  list vim buffers            [Q_bu]
    $VIMRUNTIME      --  /{colors,syntax,macros}     [$VIMRUNTIME]
    :set [all]       --  list all nondefault options [set, redir, SaveSession]
    :map             --  list actual mappings        [Q_km]
    ListMappings     --  list commented mappings
    Dotvimhelp       --  list commented mappings
    DotvimReload     --  reload vim configuration (on top of existing config)
    :scriptnames     --  list scripts and plugins
    e[dit]           --  reload the current file
    e <path>         --  open file                   [edit, Q_ed]
    e <pa...><tab>   --  open file with tab-completion [wildmenu, wildmode]
    :tabnew <path>   --  open file in a new tab
    :read filename|  --  insert filename after cursor
    :read !cmd       --  insert 'cmd' output after cursor
    :%! [cmd]        --  buffer > stdin > [cmd] > stdout => buffer.replace
    :put %           --  put % (current filename) after the cursor [help put]
    h, j, k, l       --  left, down, up, right       [Q_lr, Q_ud] 
    C-E              --  move N lines downwards (1)
    C-D              --  move N lines Downwards (1/2 move)
    C-F              --  move N pages Forwards (downwards)
    C-Y              --  move N lines upwards (default: 1)
    C-U              --  move N lines Upwards (default: 1/2 move)
    C-B              --  move N pages Backwards (upwards)
    [n]G             --  goto line #
    g <C-g>          --  whereami
    u                --  undo
    ^r               --  redo
    :%s:\(.*\):+\1:g --  Regex
   Modes
    i                --  insert
    I                --  insert at beginning of line
    a                --  append
    A                --  append at end of line
    v                --  visual
    c-v              --  visual block
    ;;               --  command
    <Esc>            --  command
   Vim Marks
    m[a-z]{1}        --  set mark
    `[a-z]{1}        --  goto mark
    '[a-z]{1}        --  goto mark
   Macros
    q[a-z]{1}        --  start recording
    q                --  stop recording
    @[a-z]{1}        --  replay macro
    @@               --  repeat macro
    q2<seq><esc>q;@2 --  record macro to 2 and repeat
   Searching
    /<pattern>       --  search for term
    *                --  search for term under cursor next
    n                --  next search ocurrence
    #                --  search for term under cursor previous
    N                --  previous search ocurrence
    :[l][vim]grep <pattern> <file>
    :cl   :ll        --  list list
    :copen :lopen    --  open list
    :cw   :lw        --  toggle show list
    :ccl[ose] :lcl   --  close list
    :cn   :ln        --  next <Enter>
    :cp   :lp        --  prev <Enter>
    :cc!  :lc [nr]   --  jump to [nr]
    :cfir :cla       --  first, last
   Yanking and Pasting
    y[a-z]           --  yank to buffer [a-z]
    p[a-z]           --  paste from buffer [a-z]
    ]p               --  paste to level
   Indenting/Shifting Blocks
    [n]<             --  shift block left
    [n]>             --  shift block right
   Folding
    :help Fold       --  also usr_28
    :set nofen       --  stop folding
    zf               --  create fold
    zo               --  fold open
    zO               --  fold open recursive
    zc               --  fold close
    zC               --  fold close recursive
    zx               --  undo manual fold actions
    zX               --  undo manual fold actions and recompute
    zM               --  fold close all but current (focus)
    zR               --  fold open all (review)
    :Voom [format]   --  open VOom outline sidebar
    <leader> t       --  :TagBarToggle " outline sidebar
   Etiquette
    <leader> i       --  toggle unprintables
    <leader> sd      --  toggle highlight EOL whitespace
    <leader> sc      --  clear highlighting
   set window title to vim title (display full path)
    :ListMappings     -- list .vimrc(.*) comments (n(next) and p(rev))
    :DotvimHelp       -- "
    :Help             -- "
    :DotvimReload   -- reload ~/.vimrc
    :Reload         -- reload ~/.vimrc
    :Dr             -- reload ~/.vimrc
      seeAlso: :SaveSession, :RestoreSession (*)     [help SaveSession]
    :Path()   -- echo path information %s %:h %:p:h       [help expand]
    :Cdhere() -- cd to here (this dir, dirname(__file__))    [cd %:p:h]
    \       -- <leader>
    <space> -- <leader>
    ,       --  <leader> == <comma>
    :;   --  colon semicolon -> <esc>:
    :;   --  colon semicolon -> <esc>:
    ;;   --  <esc> == double semicolon
    Quicklist
    <leader> q               --  toggle quicklist [:cw/:cwindow]
    <leader> n               --  next quicklist item [:cn/:cnext]
    Location List
    <leader> l               --  toggle location list [:lw/:lwindow]
    <leader> <shift> N       --  next location list item [:ln/:lnext]
   Workaround vim lp:#572863
   Code Folding
   UTF-8
   TODO XXX
   Code Indenting
   Searching
    set colorcolumn=0    --  clear color column
   Turn Off Visual Bell
   WildMenu
   Spell Checking
    <leader> sp           --  toggle spellcheck
    shift-<enter>        --  insert new line w/o changing mode
       no error bells
       Jump to last position
       remove trailing whitespace
       filetype extensions
          if &previewwindow
              exec 'setlocal winheight='.&previewheight
          endif
       Auto completion
        CTRL-<space>     --  autocomplete menu
        CTRL-<tab>       --  autocomplete menu
       close vim if the only window left open is a NERDTree
       Open NERDTree automatically if no files were specified
   Drag and Drop
     :help drag-n-drop
     shift-<drop>    --  cd to file's directory
     ctrl-<drop>     --  split new window for file
     <drop>          --  open file or paste path at cursor
   Fonts
    :PatchFont      -- set the font (s:fontsize, s:fonts, guifont (set gfn=))
                       tries each font in s:fonts until one is found
   GUI Menubar
    :HideMenubar    -- hide GUI menubar
    :ShowMenubar    -- show GUI menubar
     :Set256         -- set 256 colors (for console vim)
     :Set88          -- set 88 colors (for console vim)
   GUI
        Remove gui scrollbars
        ctrl-z   --  undo [u]
        alt-z    --  undo
        ctrl-r   --  redo
        alt-r    --  redo
        ctrl-X   --  cut
        alt-x    --  cut
        ctrl-c   --  copy
        alt-c    --  copy
           always call Set256.
           if this causes problems with older terminals
           :Set88
   autocmd! Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/
    <leader> sd              --  match EOL whitespace
    <leader> sc              --  clear search highlighting
    ctrl-q       --  close
    <leader> i   --  toggle show invisibles
    ,cd          --  :cd %:p:h
    T            --  wrap paragram
   Keep search matches in the middle of the window.
    <leader> [    --  toggle cursorline and cursorcolumn
    <leader> hm   --  set horizontal line mark
    <leader> hv   --  set vertical column mark
    <leader> c    --  clear virt marks
    Tab          --  Indent Line
   map <Tab>         >gb
    Shift-Tab    --  Dedent Line
    ctrl-t       --  Indent Current Line
    ctrl-d       --  Dedent Current Line
    >            --  Visual Indent Block
    <            --  visual dedent block
   Alternative using Tab/Shift-Tab (for gvim).
    tab          --  shift right
    Shift-tab    --  shift left
   vnoremap <Tab>    >gv
    ctrl-f       --  find
    ctrl-alt-A   --  copy all
    ctrl-v       -- paste (*)
                    conflict: vim blockwise visual selection [CTRL-v]
   map <C-v> <space>"+gP
   imap <C-v> <space><Esc>"+gP
   vmap <C-v> <Esc>"+gP
    alt-v        -- paste (*)
   nm \\paste\\        "=@*.'xy'<CR>gPFx"_2x:echo<CR>
   imap <a-v>          x<Esc>\\paste\\"_s
   vmap <a-v>          "-cx<Esc>\\paste\\"_x
   Paste
    shift-insert --  paste (*)
                     conflict: mac keyboards do not have <Insert>
   Save / Close
    ctrl-S       --  Save
    ctrl-Alt-W   --  Close
    ctrl-Home    --  Goto line one
                     conflict: mac keyboards do not have <Home>
    ctrl-End     --  Goto last line (lines[:-1])
                     conflict: mac keyboards do not have <Home>
   Page Up / Page Down
    shift-Down    --  PageDown (<C-d>)
    shift-Up      --  PageUp (<C-u>)
   K    --  PageUp
   nnoremap K  <PageUp>
   J    --  PageDown
   nnoremap J  <PageDown>
   Keyboard PageUp/PageDown are actually 2*<c-U>
                     conflict: mac keyboards do not have <PageUp, PageDown>
   Buffer Nav
    ctrl-a       --  move to beginning of line (^)
    ctrl-e       --  move to end of line ($)
   Window Nav        (window-move-cursor)
    ctrl-j       --  cursor window down
    ctrl-u       --  cursor window down
    ctrl-k       --  cursor window up
    ctrl-l       --  cursor window right
    ctrl-h       --  cursor window left
   Window Resize     (window-resize)
    ctrl-w _     --  maximize window height
    ctrw-w 1_    --  minimize window height
    ctrl-w |     --  maximize window width
    ctrl-w 1|    --  minimize window width
    ctrl-w =     --  equalize window sizes
    [n]ctrl-w >  --  expand width
    [n]ctrl-w <  --  contract width
    [n]ctrl-w +  --  increase height
    [n]ctrl-w -  --  reduce height
    ctrl-w o     --  minimze all other windows
   Window Movement (window-move)
   Window Up
    <leader> wk  --  move window up
    ctrl-wi      --  move window up
    <leader> wi  --  move window up
   Window Right
    <leader> wl  --  move window right
   Window Down
    <leader> wj  --  move window down
    ctrl-wu      --  move window down
    <leader> wu  --  move window down
   Window Left
    <leader> wj  --  move window left
   Window Rotate
    ctrl-w R     --  rotate window up
    ctrl-w r     --  rotate window down
   Tab Movement (tab-page-commands)
    ctrl-Alt-h   --  previous tab
    Alt-u        --  previous tab
    ctrl-Alt-l   --  next tab
    Alt-i        --  next tab
   Man.vim          --  view manpages in vim
    :Man man        --  view manpage for 'man'
    <leader> o      --  Open uri under cursor
        :Ack <term> <path>
        <leader>a        --  Ack
   Grin              -- Find in Python
   Ctags
    ctrl-[           --  go to tag under cursor
    ctrl-T           --  go back  #TODO
   sh: ctags -R -f ~/.vim/tags/python-$PYVER.ctags $PYLIBDIR
   Use :make to see syntax errors. (:cn and :cp to move around, :dist to see
   all errors)
   Colors
    :PatchColors     --  load local colorizing postsets
   call PatchColors()    -- call PatchColors when sourced
        Vim2VimWrite()   -- write highlight codes to ./vim_highlight_output.txt
          pip install vim2vim   -- https://pypi.python.org/pypi/vim2vim
   List highlight colors
   Python
    Wrap at 72 chars for comments.
    read virtualenv's site-packages to vim path
       TODO: python regex current buffer
        :Pyline -- python regex current buffer
   Tabsetting functineions
    :Fourtabs    -- set to four (4) soft tabs (Default)
   Default to fourtabs
    :Threetabs   -- set to three (3) soft tabs
    :Twotabs     -- set to two (2) soft tabs
    :Onetab      -- set to one (1) soft tab
    :Hardtabs    -- set to hard \t tabs (e.g. for Makefiles)
    :CurrentBuffer -- display number of current buffer
    diff           -- vimdiff, Hgvdiff, Gdiff
      :diffget   -- get from diff (overwrite or append)
      do         -- :diffget other block
      :diffput   -- put from diff (overwrite or append)
      dp         -- :diffput block 
      <C-W><C-w> -- cycle between buffers
    diffget maps   -- 3-way merge buffers
      <leader> 2   -- diffget from bufnr 2
      <leader> 3   -- diffget from bufnr 3
      <leader> 4   -- diffget from bufnr 4
    :Striptrailingwhitespace -- strip spaces at the end of lines
   Adjust font-size
    <C-Up>   -- increase font size
    <C-Down> -- decrease font size
    <F3>     -- insert ReST date heading
   Trac
   References
     - https://dev.launchpad.net/UltimateVimPythonSetup
     - https://github.com/kennethreitz/dotfiles/blob/master/.vimrc
     - https://bitbucket.org/sjl/dotfiles/src/tip/vim/.vimrc#cl-716
     - http://vim.wikia.com/wiki/Highlight_unwanted_spaces
     - http://stackoverflow.com/questions/1551231
     - http://superuser.com/questions/117969/is-there-a-way-to-move-a-split-page-to-a-new-tab-in-vim
     - http://sontek.net/turning-vim-into-a-modern-python-ide
     - http://vim.wikia.com/wiki/VimTip320
   .

   
   
.. index:: etc/vim/vimrc.full.bundles.vimrc
.. _etc/vim/vimrc.full.bundles.vimrc:

etc/vim/vimrc.full.bundles.vimrc
=================================
| Src: `etc/vim/vimrc.full.bundles.vimrc <https://github.com/westurner/dotvim/tree/master/vimrc.full.bundles.vimrc>`__

.. code:: vim

   .
   Bundle            -- Vim bundle manager [help bundle]
   :BundleList          - list configured plugins
   :BundleInstall(!)    - install (update) plugins
   :BundleSearch(!) foo - search (or refresh cache first) for foo
   :BundleClean(!)      - confirm (or auto-approve) removal of unused plugins
   The Bundle URLs are intentionally complete https URLs
   * grep '^Bundle \'' vimrc.bundles
   * sed -i 's\https://github.com/\ssh://git@github.com/\g'
   venv.vim          -- venv CdAlias commands
    :Cdhome          -- Cd_HOME()
    :Cdh             -- Cd_HOME()
    :Cdwrk           -- Cd___WRK()
    :Cddotfiles      -- Cd___DOTFILES()
    :Cdd             -- Cd___DOTFILES()
    :Cdprojecthome   -- Cd_PROJECT_HOME()
    :Cdp             -- Cd_PROJECT_HOME()
    :Cdph            -- Cd_PROJECT_HOME()
    :Cdworkonhome    -- Cd_WORKON_HOME()
    :Cdwh            -- Cd_WORKON_HOME()
    :Cdve            -- Cd_WORKON_HOME()
    :Cdcondahome     -- Cd_CONDA_HOME()
    :Cda             -- Cd_CONDA_HOME()
    :Cdce            -- Cd_CONDA_HOME()
    :Cdvirtualenv    -- Cd_VIRTUAL_ENV()
    :Cdv             -- Cd_VIRTUAL_ENV()
    :Cdsrc           -- Cd__SRC()
    :Cds             -- Cd__SRC()
    :Cdwrd           -- Cd__WRD()
    :Cdw             -- Cd__WRD()
    :Cdbin           -- Cd__BIN()
    :Cdb             -- Cd__BIN()
    :Cdetc           -- Cd__ETC()
    :Cde             -- Cd__ETC()
    :Cdlib           -- Cd__LIB()
    :Cdl             -- Cd__LIB()
    :Cdlog           -- Cd__LOG()
    :Cdpylib         -- Cd__PYLIB()
    :Cdpysite        -- Cd__PYSITE()
    :Cdsitepackages  -- Cd__PYSITE()
    :Cdvar           -- Cd__VAR()
    :Cdwww           -- Cd__WWW()
    :Cdww            -- Cd__WWW()
   file_line.vim     -- open files named 'file(line[:col])', 'file:line[:col]'
   Info.vim          -- vim infopages in vim [help info]
    :Info sed        --  view infopage for 'sed'
    <Space>          --  Scroll forward (page down).
    <Backspace>      --  Scroll backward (page up).
    <Tab>            --  Move cursor to next hyperlink within this node.
    <Enter>,<C-]>    --  Follow hyperlink under cursor.
    ;,<C-T>          --  Return to last seen node.
    .,>              --  Move to the "next" node of this node.
    p,<              --  Move to the "previous" node of this node.
    u                --  Move "up" from this node.
    d                --  Move to "directory" node.
    t                --  Move to the Top node.
    <C-S>            --  Search forward within current node only.
    s                --  Search forward through all nodes for a specified
    string.
    q                --  Quit browser.
   Signify   -- show git/hg file changes in gutter [help signify]
    <leader>gt       -- SignifyToggle
    <leader>gh       -- SignifyToggleHighlight
    <leader>gr       -- SignifyRefresh
    <leader>gd       -- SignifyDebug
   hunk jumping
    <leader>gj       -- signify-next-hunk
    <leader>gk       -- signify-prev-hunk
   hunk text object
    ic               -- signify inner textobj
    ac               -- signify outer textobj
   Fugitive      -- Git commands and statusline display [help fugitive]
   Lawrencium    -- Hg commands [help lawrencium]
   NERDTree      -- File browser [help NERDTree]
    <Leader>e         --  toggle NERDTree
    ctrl-e            --  toggle NERDTree
    <Leader>E         --  open nerdtree to current file (:NERDTreeFind %:p:h)
    ctrl-E            --  open nerdtree to current file (:NERDTreeFind %:p:h)
    I                 --  toggle view hidden files
    B                 --  toggle view bookmarks
    cd                --  set vim CWD to selected dir
    C                 --  refocus view to selected dir
    o                 --  open
    r                 --  refresh dir
    R                 --  refresh root
    t                 --  open in new tab
    T                 --  open in new tab silently
    u                 --  up a dir
    U                 --  up a dir and leave open
    x                 --  close node
    X                 --  close all nodes recursive
    ?                 --  toggle help
   FindInNERDTree    -- NERDTRee show current file [help NERDTreeFind]
    <c-b>            --  toggle BufExplorer
    ?                --  toggle BufExplorer help
    <leader>b        --  toggle BufExplorer
   CtrlP             -- file/buffer/mru finder [help ctrlp]
    <C-p>            -- CtrlP (fuzzy matching)
   Syntastic         -- syntax highlighting [help syntastic]
   NERDCommenter     -- commenting [help NERDCommenter]
    ,cm              --  minimal comment
    ,cs              --  sexy comment
    ,c<space>        --  toggle comment
   UltiSnips         --  syntax-specific snippets [help ultisnips]
    snippetname<C-CR>    --  insert snippet
    <c-j>            --  next placeholder
    <c-k>            --  prev placeholder
    ~/.vim/snippets-ulti/python.snippets:
      climain         --  new cli script
      setuppy         --  new setup.py script
    ~/.vim/snippets-ulti/html.snippets:
      schemaorgclass  --  new schema.org RDFa class
      schemaorgprop   --  new schema.org RDFa property
   NeoComplCache -- code completion [help neocomplcache]
   unstack.vim   -- parse and open stacktrace paths [help unstack]
    <leader> s   -- parse part/all of a stacktrace
   accordion.vim -- work w/ a number of vsplits at once [help accordion]
   ViM Airline   -- helpful statusbar information w/ vimscript [help airline]
       base16, wombat, luna
       base16, wombat, luna
   EasyMotion    -- easy visual motions [help easymotion]
    <Leader>m-w/e    --  search forward (beg/end of word)
    <Leader>m-b      --  search backward
    <Leader>m-j      --  search line down
    <Leader>m-k      --  search line up
   Jellybeans    -- a good colorscheme w/ sensible diff highlighting
    :colorscheme jellybeans -- switch to the jellybeans colorscheme
   Vim-misc      -- functions for colorscheme-switcher and vim-session
   Vim Colorscheme Switcher [help colorscheme-switcher]
    <F8>         -- cycle colors forward
    <Shift><F8>  -- cycle colors reverse
   HiColors
    call HiTest() -- print highlighting colors 
   Pasting       -- make paste work normally [help paste]
   Vim Room      -- focus just the relevant text [help vimroom] 
   VOoM Outline Viewer   -- view outlines of code and text [help voom]
    VOoM modes:  html, markdown, python, rest,
                 thevimoutliner, txt2tags,
                 viki, vimwiki, wiki
    :Voom [<format>] -- open Voom outline tab
    :Voom rest       -- open ReStructuredText outline
    ggg?G
    <leader> V   -- toggle Voom outline sidebar
   TagBar        -- source tag browser [help tagbar]
    <leader> t   -- toggle TagBar outline sidebar"
   Vim Session   -- save and restore sessions between exits [help session]
    :SaveSession <name>  -- save a session
    :OpenSession <name>  -- open a saved session
    :Restart             -- SaveSession restart && exit
    :OpenSession restart -- open the 'restart' saved session
   Vim Unimpaired        --  moving between buffers [help unimpaired]
    [a      :previous
    ]a      :next
    [A      :first
    ]A      :last
    [b      :bprevious
    ]b      :bnext
    [B      :bfirst
    ]B      :blast
    [l      :lprevious
    ]l      :lnext
    [L      :lfirst
    ]L      :llast
    [<C-L>  :lpfile
    ]<C-L>  :lnfile
    [q      :cprevious
    ]q      :cnext
    [Q      :cfirst
    ]Q      :clast
    [<C-Q>  :cpfile (Note that <C-Q> only works in a terminal if you disable
    ]<C-Q>  :cnfile flow control: stty -ixon)
    [t      :tprevious
    ]t      :tnext
    [T      :tfirst
    ]T      :tlast
   Ack.vim       -- ack through files (instead of grep) [help ack]
   :Ack [options] PATTERN [directory]    -- search for pattern
   :AckAdd [options] PATTERN [directory] -- add a search pattern
   :AckWindow [options] PATTERN          -- search all visible buffers"
   vim-surround  -- add quotes/parenthesis/tags [help surround]
    cs       -- change surrounding
    ys       -- yank and surround (motion, text object)
    yss      -- yank and surround current line
    ds"      -- remove double-quotes
    cs'"     -- replace single-quotes with double quotes
    cd"<q>   -- surround with <q>...<q/>
    dst      -- remove surrounding tag
   csapprox      -- adapt gvim colorschemes for terminal vim [help csapprox]
   UndoTree      -- visualize vim undotree
    <F5>     -- Toggle UndoTree (? for help)
   vim-nginx -- nginx ftdetect, indent, and syntax
   n3.vim    -- N3/Turtle RDF Syntax
   SPARQL    -- SPARQL syntax
   Python-mode       -- Python [help pymode]
    :help pymode
    [[    --  Jump to previous class or function
    ]]    --  Jump to next class or function
    [M    --  Jump to previous class or method
    ]M    --  Jump to next class or method
    aC    --  Select a class. Ex: vaC, daC, yaC, caC
    iC    --  Select inner class. Ex: viC, diC, yiC, ciC
    aM    --  Select a function or method. Ex: vaM, daM, yaM, caM
    iM    --  Select inner function or method. Ex: viM, diM, yiM, ciM
    g:pymode_python = { 'python', 'python3', 'disable' }
    set g:pymode_python 'disable' (start time, occasional completion stall)
    <leader> d    -- open pydoc
    :PymodeLintToggle    -- toggle lint checking
    :PymodeLintAuto      -- autofix current buffer pep8 errors
   - auto-show an error window
   - show lint signs
   - run lint on write
    let g:pymode_lint_ignore = ""
    let g:pymode_lint_select = ""
    Pymode lint line annotation symbols
     XX = TODO
     CC = COMMENT
     RR = VISUAL
     EE = ERROR
     II = INFO
     FF = PYFLAKES
   :PyModeLint       -- lint current buffer (once)
   :PyModeLintToggle -- toggle lint
   :PyModeLintAuto   -- auto-lint the current buffer (once)
                         (commit before and after)
    <F7>     -- set debugger breakpoints
    auto lookup breakpoint cmd (pdb, ipdb, pudb)"
    Searches upward for a .ropeproject file (that should be .vcs-ignored)
    :PymodeRopeNewProject    -- Create a new .ropeproject in CWD
    :PymodeRopeRegenerate    -- Regenerate rope project cache
    <C-c>d       -- show docs for current function w/ pymode
    rope for autocompletion
    <C-Space>    -- rope autocomplete
    <leader> j       --  :RopeGotoDefinition
    <C-c> ro     -- organize Python imports; drop unused (:PymodeRopeAutoImport)
    :PymodeRopeUndo  -- Undo last project changes
    :PymodeRopeRedo  -- Redo last project changes
    <C-c> rr     -- rope rename
   vim-virtualenv    -- Python virtualenv [help virtualenv]
    :help
    :VirtualEnvDeactivate
    :VirtualEnvList
    :VirtualEnvActivate <name>
    :VirtualEnvActivate <TAB>
   Sort python imports
    :PyFixImports    --  sort import statements
   Pytest.vim    -- py.test red/green results [help pytest]
    :Pytest clear    -- reset pytest globals
    :Pytest file     --  pytest file
    :Pytest class    --  pytest class
    :Pytest method   --  pytest method
    :Pytest {...} --pdb  -- pytest file/class/method with pdb
    <leader>tf       --  pytest file
    <leader>tc       --  pytest class
    <leader>tm       --  pytest method
    " cycle through test errors
    <leader>tn       --  pytest next error
    <leader>tp       --  pytest prev error
    <leader>te       --  pytest error
   Pyrex         -- Pyrex syntax
   Jinja         -- Jinja Templates syntax
   vim-coffee-script -- CoffeeScript syntax, indent
   vim-haml          -- HAML, SASS, SCSS
   vim-css3-syntax   -- CSS3
   vim-css-color     -- show CSS color codes
   vim-less          -- LESS CSS
   vim-jade          -- Jade templates
   os.vim   -- Operating System [help os]
   clickable.vim -- click-able links
   let g:clickable_browser = "xdg-open"
   let g:clickable_browser = "x-www-browser"
   Riv.vim   -- ReStructuredText [help riv]
    [help riv]
        https://github.com/Rykka/riv.vim/tree/master/doc
    :RivIntro
        https://github.com/Rykka/riv.vim/blob/master/doc/riv_intro.rst
    :RivQuickStart
        https://github.com/Rykka/riv.vim/blob/master/doc/riv_quickstart.rst
    :RivInstruction
        https://github.com/Rykka/riv.vim/blob/master/doc/riv_instruction.rst
    :RivCheatSheet     -- riv_cheatsheet.rst
        https://github.com/Rykka/riv.vim/blob/master/doc/riv_cheatsheet.rst
    :RivPrimer         -- riv_primer.rst
        https://github.com/Rykka/riv.vim/blob/master/doc/riv_primer.rst
        http://docutils.sourceforge.net/docs/user/rst/quickstart.html
    # Docutils "Quick reStructuredText" [quickref.rst / quickref.html]
        http://docutils.sourceforge.net/docs/user/rst/quickref.html
    :RivSpecification  -- Docutils "reStructuredText Markup Specification"
        http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html
         https://github.com/Rykka/riv.vim/blob/master/doc/riv_specification.rst
    :RivDirectives -- Docutils "Directives"
        https://github.com/Rykka/riv.vim/blob/master/doc/riv_directives.rst
         http://docutils.sourceforge.net/docs/ref/rst/directives.html
    # Docutils "Roles"
         http://docutils.sourceforge.net/docs/ref/rst/roles.html
    # Docutils "Substutution definitions"
         http://docutils.sourceforge.net/docs/ref/rst/definitions.html
    # Docutils "Doctree"
         http://docutils.sourceforge.net/docs/ref/doctree.html
    # Riv.vim Changelogs
         https://github.com/Rykka/riv.vim/blob/master/doc/riv_log.rst
    # Riv.vim Todo
         https://github.com/Rykka/riv.vim/blob/master/doc/riv_todo.rst
         - [ ] Ready
         - [o] Open
         - [X] Closed
   Salt      -- Salt syntax
   Trac      -- Trac [help trac]
   webapi-vim -- vim web API [help webapi[-{html, http, json, xml}]]
   gist-vim  -- Create a gist.github.com [help gist-vim]
   github-issues.vim     -- autocomplete, CRUD GitHub issues [help Gissues]
   html5.vim             -- HTML5, RDFa, microdata, WAI-ARIA
   vim-javascript        -- improved Javascript support
   vim-indent-guides     -- show indentation levels [help indent_guides]
   rainbow-parentheses   -- make nested parenthesis different colors
    :RainbowParenthesesActivate
    :RainbowParenthesesToggle
    :RainbowParenthesesLoadRound
    :RainbowParenthesesLoadSquare
    :RainbowParenthesesLoadBraces
    :RainbowParenthesesLoadChevrons
    :RainbowParenthesesToggleAll
       :RainbowParenthesesActivate
   l9                    -- utility library (for FuzzyFinder)
   FuzzyFinder           -- find files, buffers, tags, changes [help fuf]
    :FufBuffer
    :FufFile
    :FufDir
    :FufMruFile
    :FufMruCmd
    :FufTag
    :FufJumpList
    :FufChangeList
    :FufQuickfix
    :FufHelp
   abolish.vim           -- abbreviations, case-aware replcmnts [help abolish]
   fountain.vim          -- fountain.io syntax
   All of your Bundles must be added before the following line
   .

   
   
.. index:: etc/vim/vimrc.tinyvim.bundles.vimrc
.. _etc/vim/vimrc.tinyvim.bundles.vimrc:

etc/vim/vimrc.tinyvim.bundles.vimrc
====================================
| Src: `etc/vim/vimrc.tinyvim.bundles.vimrc <https://github.com/westurner/dotvim/tree/master/vimrc.tinyvim.bundles.vimrc>`__

.. code:: vim

   .
   Bundle            -- Vim bundle manager [help bundle]
   :BundleList          - list configured plugins
   :BundleInstall(!)    - install (update) plugins
   :BundleSearch(!) foo - search (or refresh cache first) for foo
   :BundleClean(!)      - confirm (or auto-approve) removal of unused plugins
   The Bundle URLs are intentionally complete https URLs
   * grep '^Bundle \'' vimrc.bundles
   * sed -i 's\https://github.com/\ssh://git@github.com/\g'
   Info.vim          -- vim infopages in vim [help info]
    :Info sed        --  view infopage for 'sed'
    <Space>          --  Scroll forward (page down).
    <Backspace>      --  Scroll backward (page up).
    <Tab>            --  Move cursor to next hyperlink within this node.
    <Enter>,<C-]>    --  Follow hyperlink under cursor.
    ;,<C-T>          --  Return to last seen node.
    .,>              --  Move to the "next" node of this node.
    p,<              --  Move to the "previous" node of this node.
    u                --  Move "up" from this node.
    d                --  Move to "directory" node.
    t                --  Move to the Top node.
    <C-S>            --  Search forward within current node only.
    s                --  Search forward through all nodes for a specified
    string.
    q                --  Quit browser.
   Signify   -- show git/hg file changes in gutter [help signify]
   NERDTree      -- File browser [help NERDTree]
    <Leader>e         --  toggle NERDTree
    ctrl-e            --  toggle NERDTree
    <Leader>E         --  open nerdtree to current file (:NERDTreeFind %:p:h)
    ctrl-E            --  open nerdtree to current file (:NERDTreeFind %:p:h)
    I                 --  toggle view hidden files
    B                 --  toggle view bookmarks
    cd                --  set vim CWD to selected dir
    C                 --  refocus view to selected dir
    o                 --  open
    r                 --  refresh dir
    R                 --  refresh root
    t                 --  open in new tab
    T                 --  open in new tab silently
    u                 --  up a dir
    U                 --  up a dir and leave open
    x                 --  close node
    X                 --  close all nodes recursive
    ?                 --  toggle help
   FindInNERDTree   -- NERDTRee show current file [help NERDTreeFind]
    <c-b>            --  toggle BufExplorer
    ?                --  toggle BufExplorer help
    <leader>b        --  toggle BufExplorer
   CtrlP             -- file/buffer/mru finder [help ctrlp]
    <C-p>            -- CtrlP (fuzzy matching)
   Syntastic         -- syntax highlighting [help syntastic]
   EasyMotion    -- easy visual motions [help easymotion]
    <Leader>m-w/e    --  search forward (beg/end of word)
    <Leader>m-b      --  search backward
    <Leader>m-j      --  search line down
    <Leader>m-k      --  search line up
   Jellybeans    -- a good colorscheme w/ sensible diff highlighting
    :colorscheme jellybeans -- switch to the jellybeans colorscheme
   Vim-misc      -- functions for colorscheme-switcher and vim-session
   Vim Colorscheme Switcher [help colorscheme-switcher]
    <F8>         -- cycle colors forward
    <Shift><F8>  -- cycle colors reverse
   vim-nginx -- nginx ftdetect, indent, and syntax
   n3.vim    -- N3/Turtle RDF Syntax
   SPARQL    -- SPARQL syntax
   Pyrex         -- Pyrex syntax
   Jinja         -- Jinja Templates syntax
   Salt      -- Salt syntax
   All of your Bundles must be added before the following line
   .

   
   
