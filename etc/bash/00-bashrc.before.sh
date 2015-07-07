#!/bin/bash
## 00-bashrc.before.sh     -- bash dotfiles configuration root
#  source ${__DOTFILES}/etc/bash/00-bashrc.before.sh    -- dotfiles_reload()
#
dotfiles_reload() {
  #  dotfiles_reload()  -- (re)load the bash configuration
  #  $__DOTFILES (str): -- path to the dotfiles symlink (~/-dotfiles)

  echo "#"
  echo "# dotfiles_reload()"

  export __WRK="${HOME}/-wrk"

  if [ -n $__DOTFILES ]; then
    export __DOTFILES=${__DOTFILES}
  else
    _dotfiles_src=${WORKON_HOME}/dotfiles/src/dotfiles
    _dotfiles_link=${HOME}/-dotfiles

    if [ -d $_dotfiles_link ]; then
        __DOTFILES=${_dotfiles_link}
    elif [ -d $_dotfiles_src ]; then
        __DOTFILES=${_dotfiles_src}
    fi
    export __DOTFILES=${__DOTFILES}
  fi

  conf=${__DOTFILES}/etc/bash

  #
  ## 01-bashrc.lib.sh           -- useful bash functions (paths)
  #  lspath()           -- list every file along $PATH
  #  realpath()         -- readlink -f (python os.path.realpath)
  #  walkpath()         -- list every directory along ${1:-"."}
  source ${conf}/01-bashrc.lib.sh

  #
  ## 02-bashrc.platform.sh      -- platform things
  source ${conf}/02-bashrc.platform.sh
  detect_platform
  #  detect_platform()  -- set $__IS_MAC or $__IS_LINUX
  if [ -n "${__IS_MAC}" ]; then
      export PATH=$(echo ${PATH} | sed 's,/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin,/usr/sbin:/sbin:/bin:/usr/local/bin:/usr/bin,')

  ## 03-bashrc.darwin.sh
      source ${conf}/03-bashrc.darwin.sh
  fi

  #
  ## 04-bashrc.TERM.sh          -- set $TERM and $CLICOLOR
  source ${conf}/04-bashrc.TERM.sh

  #
  ## 05-bashrc.dotfiles.sh      -- dotfiles
  #  $__DOTFILES (str): -- path to the dotfiles symlink (~/.dotfiles)
  #  dotfiles_status()  -- print dotfiles variables
  #  ds()               -- print dotfiles variables
  source ${conf}/05-bashrc.dotfiles.sh
  dotfiles_add_path

  #
  ## 06-bashrc.completion.sh    -- configure bash completion
  source ${conf}/06-bashrc.completion.sh

  #
  ##
  #  virtualenvwrapper / virtualenv / venv constants
  #
  #  $PROJECT_HOME (str): path to project directory (~/-wrk)
  #  $WORKON_HOME  (str): path to virtualenvs directory (~/-wrk/-ve27)
  #  $VIRTUAL_ENV  (str): path to current $VIRTUAL_ENV ($WORKON_HOME/$VENVSTR)

  #
  ## 07-bashrc.python.sh            -- python
  #  _setup_python()              -- configure PYTHONSTARTUP
  #  _setup_pip()                 -- configure PIP_REQUIRE_VIRTUALENV
  #  _setup_pyenv()               -- setup pyenv PYENV_ROOT and eval (manual)
  source ${conf}/07-bashrc.python.sh

  #
  ## 08-bashrc.conda.sh             -- conda
  #  _setup_conda()               -- setup conda paths (manual)
  #                                  WORKON_HOME=CONDA_ENVS_PATH
  #    $1 (str): (optional) CONDA_ENVS_PATH (WORKON_HOME)
  #    $2 (str): (optional) CONDA_ROOT_PATH (or '27' or '34')
  #  $CONDA_ROOT      (str): path to conda install (~/-wrk/-conda34)
  #  $CONDA_ENVS_PATH (str): path to condaenvs directory (~/-wrk/-ce34) [conda]
  source ${conf}/08-bashrc.conda.sh

  #
  ## 07-bashrc.virtualenvwrapper.sh -- virtualenvwrapper
  #  _setup_virtualenvwrapper     -- configure virtualenvwrapper
  #  backup_virtualenv($VENVSTR)  -- backup a venv in WORKON_HOME
  #                                  $WORKON_HOME/$VENVSTR -> ./-bkp/$VENVSTR
  #  backup_virtualenvs()         -- backup all venvs in WORKON_HOME
  #                                  $WORKON_HOME/*        -> ./-bkp/*
  #  rebuild_virtualenv($VENVSTR) -- rebuild $WORKON_HOME/$VENVSTR
  #  rebuild_virtualenvs()        -- rebuild $WORKON_HOME/*
  #  TODO: restore_virtualenv($BACKUPVENVSTR, [$NEWVENVSTR])
  source ${conf}/07-bashrc.virtualenvwrapper.sh

  #
  ## 08-bashrc.gcloud.sh        -- gcloud: Google Cloud SDK
  #  _setup_google_cloud()  -- setup google cloud paths
  source ${conf}/08-bashrc.gcloud.sh

  #
  ## 10-bashrc.venv.sh          -- venv: virtualenvwrapper extensions
  #  _setup_venv()
  #  $__PROJECTSRC     (str): script to source (${PROJECT_HOME}/.projectsrc.sh)
  #  $VIRTUAL_ENV_NAME (str): basename of $VIRTUAL_ENV [usrlog: prompt, title]
  #  $_APP             (str): $VIRTUAL_ENV/src/${_APP}
  #  we() -- workon a new venv
  #     $1: VIRTUAL_ENV_NAME [$WORKON_HOME/${VIRTUAL_ENV_NAME}=>$VIRTUAL_ENV]
  #     $2: _APP (optional; defaults to $VIRTUAL_ENV_NAME)
  #
  #     we dotfiles
  #     we dotfiles etc/bash; cdw; ds; # ls -altr; lll; cd ~; ew etc/bash/*.sh
  #     type workon_venv; which venv.py; venv.py --help
  source ${conf}/10-bashrc.venv.sh
  #

  #
  ## 11-bashrc.venv.pyramid.sh  -- venv-pyramid: pyramid-specific config
  source ${conf}/11-bashrc.venv.pyramid.sh

  #
  ## 20-bashrc.editor.sh        -- $EDITOR configuration
  #  $EDITOR  (str): cmdstring to open $@ (file list) in editor
  #  $EDITOR_ (str): cmdstring to open $@ (file list) in current editor
  #  e()        -- open paths in current EDITOR_                   [scripts/e]
  #  ew()       -- open paths relative to $_WRD in current EDITOR_ [scripts/ew]
  #                (~ cd $_WRD; $EDITOR_ ${@}) + tab completion
  source ${conf}/20-bashrc.editor.sh
  #
  ## 20-bashrc.vimpagers.sh     -- $PAGER configuration
  #  $PAGER   (str): cmdstring to run pager (less/vim)
  #  lessv()    -- open in vim with less.vim
  #                VIMPAGER_SYNTAX="python" lessv
  #  lessg()    -- open in a gvim with less.vim
  #                VIMPAGER_SYNTAX="python" lessv
  #  lesse()    -- open with $EDITOR_
  source ${conf}/29-bashrc.vimpagers.sh

  #
  ## 30-bashrc.usrlog.sh        -- $_USRLOG configuration
  #  _setup_usrlog()    -- configure usrlog
  #  $_USRLOG (str): path to a -usrlog.log command log
  #                __USRLOG=~/-usrlog.log
  #                 _USRLOG=${VIRTUAL_ENV}/-usrlog.log
  #  lsusrlogs  -- ls -tr   "${__USRLOG}" "${WORKON_HOME}/*/-usrlog.log"
  #  stid       -- set $TERM_ID to a random string (e.g. "#Yt0PyyKWPro")
  #  stid $name -- set $TERM_ID to string (e.g. \#20150704, "#20150704")
  #  note       -- log a #note to $_USRLOG (histn==#note)
  #  todo       -- log a #todo to $_USRLOG (histn==#todo)
  #  usrlogv    -- open usrlog with vim:    $VIMBIN    $_USRLOG
  #  usrlogg    -- open usrlog with gmvim:  $GUIVIMBIN $_USRLOG
  #  usrloge    -- open usrlog with editor: $EDITOR    $_USRLOG
  #  ut         -- tail -n__ $_USRLOG [ #BUG workaround: see venv.py]
  #  ug         -- egrep current usrlog: egrep $@ $_USRLOG
  #  ugall      -- egrep all usrlogs [ #BUG workaround: see venv.py ]
  #                     egrep $@ "${__USRLOG}" "${WORKON_HOME}/*/-usrlog.log"
  #  ugrin      -- grin current usrlog: grin $@ ${_USRLOG}
  #  ugrinall   -- grin $@  "${__USRLOG}" "${WORKON_HOME}/*/-usrlog.log"
  source ${conf}/30-bashrc.usrlog.sh

  #
  ## 30-bashrc.xlck.sh          -- screensaver, (auto) lock, suspend
  #  _setup_xlck()      -- configure xlck
  source ${conf}/30-bashrc.xlck.sh

  #
  ## 40-bashrc.aliases.sh       -- aliases
  #  _setup_venv_aliases()  -- source in e, ew, makew, ssv, hgw, gitw
  #    _setup_supervisord() -- configure _SVCFG
  #       $1 (str): path to a supervisord.conf file "${1:-${_SVCFG}"
  source ${conf}/40-bashrc.aliases.sh
  ## 42-bashrc.commands.sh      -- example commands
  source ${conf}/42-bashrc.commands.sh

  #
  ## 50-bashrc.bashmarks.sh     -- bashmarks: local bookmarks
  source ${conf}/50-bashrc.bashmarks.sh

  #
  ## 70-bashrc.repos.sh         -- repos: $__SRC repos, docs
  source ${conf}/70-bashrc.repos.sh

  #
  ## 99-bashrc.after.sh         -- after: cleanup
  source ${conf}/99-bashrc.after.sh
}

dr() {
    # dr()  -- dotfiles_reload
    dotfiles_reload $@
}
    # ds()  -- print dotfiles_status()

dotfiles_main() {
    dotfiles_reload
}

dotfiles_main
