#!/bin/bash
## 00-bashrc.before.sh     -- bash dotfiles configuration root
#  source ${__DOTFILES}/etc/bash/00-bashrc.before.sh    -- dotfiles_reload()
#
dotfiles_reload() {
  #  dotfiles_reload()  -- (re)load the bash configuration
  #  $__DOTFILES (str): -- path to the dotfiles symlink (~/.dotfiles)

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
  #  python: pip, virtualenv, virtualenvwrapper
  #  $PROJECT_HOME (str): path to project directory (~/wrk)
  #  $WORKON_HOME  (str): path to virtualenvs directory (~/wrk/.ve)
  #  $VIRTUAL_ENV  (str): path to current $VIRTUAL_ENV

  #
  ## 07-bashrc.python.sh        -- python
  #  _setup_pyenv()     -- setup pyenv paths (manual)
  source ${conf}/07-bashrc.python.sh

  #
  ## 08-bashrc.conda.sh         -- conda
  #  _setup_conda()     -- setup conda paths (manual)
  source ${conf}/08-bashrc.conda.sh

  #
  ## 07-bashrc.virtualenvwrapper.sh -- virtualenvwrapper
  # backup_virtualenv($VENVSTR)  -- backup $WORKON_HOME/$VENVSTR -> ./-bkp/$VENVSTR
  # backup_virtualenvs()         -- backup $WORKON_HOME/* -> ./-bkp/*
  # rebuild_virtualenv($VENVSTR) -- rebuild $WORKON_HOME/$VENVSTR
  # rebuild_virtualenvs()        -- rebuild $WORKON_HOME/*
  # TODO: restore
  source ${conf}/07-bashrc.virtualenvwrapper.sh

  #
  ## 08-bashrc.gcloud.sh        -- gcloud: Google Cloud SDK
  #  _setup_google_cloud()  -- setup google cloud paths
  source ${conf}/08-bashrc.gcloud.sh

  #
  ## 10-bashrc.venv.sh          -- venv: virtualenvwrapper extensions
  #  $__PROJECTSRC     (str): script to source (${PROJECT_HOME}/.projectsrc.sh)
  #  $VIRTUAL_ENV_NAME (str): basename of current $VIRTUAL_ENV
  #  $_APP             (str): $VIRTUAL_ENV/src/${_APP}
  #  we() -- workon a new venv
  #     $1: VIRTUAL_ENV_NAME [$WORKON_HOME/${VIRTUAL_ENV_NAME}=$VIRTUAL_ENV]
  #     $2: _APP (optional; defaults to $VIRTUAL_ENV_NAME)
  #     we dotfiles
  #     we dotfiles etc/bash; cdw; ds; ls
  source ${conf}/10-bashrc.venv.sh
  #

  #
  ## 11-bashrc.venv.pyramid.sh  -- venv-pyramid: pyramid-specific config
  source ${conf}/11-bashrc.venv.pyramid.sh

  #
  ## 20-bashrc.editor.sh        -- $EDITOR configuration
  #  $_EDIT_  (str): cmdstring to open $@ (file list) in current editor
  #  $EDITOR_ (str): cmdstring to open $@ (file list) in current editor
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
  #  $_USRLOG (str): path to .usrlog command log
  #  stid       -- set $TERM_ID to a random string
  #  stid $name -- set $TERM_ID to string
  #  note       -- add a dated note to $_USRLOG [_usrlog_append]
  #  usrlogv    -- open usrlog with vim:   $VIMBIN + $_USRLOG
  #  usrlogg    -- open usrlog with gmvim: $GUIVIMBIN + $_USRLOG
  #  usrloge    -- open usrlog with editor:$EDITOR + $_USRLOG
  #  ut         -- tail $_USRLOG
  #  ug         -- egrep current usrlog: egrep $@ $_USRLOG
  #  ugall      -- egrep $@ $__USRLOG ${WORKON_HOME}/*/.usrlog
  #  ugrin      -- grin current usrlog: grin $@ $_USRLOG
  #  ugrinall   -- grin $@  $__USRLOG ${WORKON_HOME}/*/.usrlog
  #  lsusrlogs  -- ls -tr   $__USRLOG ${WORKON_HOME}/*/.usrlog
  source ${conf}/30-bashrc.usrlog.sh

  #
  ## 30-bashrc.xlck.sh          -- screensaver, (auto) lock, suspend
  source ${conf}/30-bashrc.xlck.sh

  #
  ## 40-bashrc.aliases.sh       -- aliases
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
