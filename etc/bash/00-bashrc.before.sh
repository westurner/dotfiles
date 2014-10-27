
#source ~/.bashrc
  #source 00-bashrc.before.sh  # <-- THIS FILE

dotfiles_reload() {
    ## dotfiles_reload()    -- (re)load the bash configuration tree
    #                          from ${__DOTFILES}/etc/bash
    #  __DOTFILES (str)     -- path to this dotfiles repository (~/.dotfiles)

    echo "## Reloading bash configuration..."
    conf=${__DOTFILES}/etc/bash

      ## 01-bashrc.lib.sh  -- libraries: useful bash functions
      source ${conf}/01-bashrc.lib.sh
      detect_platform
      #  detect_platform() -- set __IS_MAC, __IS_LINUX vars [01-bashrc.lib.sh]
      #                       egrep -nr -C 3 '__IS_MAC|__IS_LINUX'

      ## 03-bashrc.readline.sh  -- readline config
      source ${conf}/03-bashrc.readline.sh

      ## 04-bashrc.TERM.sh      -- TERM, CLICOLOR
      source ${conf}/04-bashrc.TERM.sh

      ## 05-bashrc.dotfiles.sh  -- dotfiles
      #  $__DOTFILES (str): path to local dotfiles repository clone
      #  dotfiles_status(): print dotfiles env config
      export __DOTFILES="${HOME}/.dotfiles"
      source ${conf}/05-bashrc.dotfiles.sh


      ### python: python: pip, virtualenv, virtualenvwrapper
      #  $PROJECT_HOME (str): path to project directory (~/wrk)
      #  $WORKON_HOME  (str): path to virtualenvs directory (~/wrk/.ve)
      #  $VIRTUAL_ENV  (str): path to current $VIRTUAL_ENV

      ## 07-bashrc.python.sh            -- python
      #  _setup_anaconda()      -- setup anaconda paths (manual)
      #  _setup_pyenv()         -- setup pyenv paths (manual)
      source ${conf}/07-bashrc.python.sh

      ## 07-bashrc.virtualenv.sh        -- virtualenv
      source ${conf}/07-bashrc.virtualenv.sh

      ## 07-bashrc.virtualenvwrapper.sh -- virtualenvwrapper
      source ${conf}/07-bashrc.virtualenvwrapper.sh


      ## 08-bashrc.gcloud.sh    -- gcloud: Google Cloud SDK
      #  _setup_google_cloud()  -- setup google cloud paths
      source ${conf}/08-bashrc.gcloud.sh

      ## 10-bashrc.venv.sh      -- venv: virtualenvwrapper extensions
      #  $_VENVNAME (str): name of current $VIRTUAL_ENV
      #  we() -- workon a new venv (source bin/activate; update ENVIRON)
      #          we() -> workon $1 [$_APP] && source <($_VENV --bash $@)
      #          example::
      #             we dotfiles
      #             we dotfiles etc/bash; ls -al; git status
      source ${conf}/10-bashrc.venv.sh
      # test -f $__PROJECTS && source $__PROJECTS
      dotfiles_status

      ## 11-bashrc.venv.pyramid.sh  -- venv-pyramid: pyramid-specific config
      source ${conf}/11-bashrc.venv.pyramid.sh


      ## 20-bashrc.editor.sh        -- $EDITOR configuration
      #  $_EDIT_ (str): cmdstring to open $@ (file list) in current editor
      #  $EDITOR (str): cmdstring to open $@ (file list) in current editor
      source ${conf}/20-bashrc.editor.sh
      ## 20-bashrc.vimpagers.sh     -- $PAGER configuration
      #  $PAGER (str): cmdstring to run pager (less/vim)
      source ${conf}/29-bashrc.vimpagers.sh


      ## 30-bashrc.usrlog.sh        -- $_USRLOG configuration
      #  $_USRLOG (str): path to .usrlog command log
      #  stid           -- set $TERM_ID to a random string
      #  stid $name     -- set $TERM_ID to string
      #  note           -- add a dated note to $_USRLOG [_usrlog_append]
      #  usrlogv        -- open usrlog with vim:   $VIMBIN + $_USRLOG
      #  usrlogg        -- open usrlog with gmvim: $GUIVIMBIN + $_USRLOG
      #  usrloge        -- open usrlog with editor:$EDITOR + $_USRLOG
      source ${conf}/30-bashrc.usrlog.sh


      ## 30-bashrc.xlck.sh          -- screensaver, (auto) lock, suspend
      source ${conf}/30-bashrc.xlck.sh


      ## 40-bashrc.aliases.sh       -- bash aliases and cmds
      source ${conf}/40-bashrc.aliases.sh


      ## 50-bashrc.bashmarks.sh     -- bashmarks: local bookmarks
      source ${conf}/50-bashrc.bashmarks.sh

      ## 70-bashrc.repos.sh         -- repos: $__SRC repos, docs
      source ${conf}/70-bashrc.repos.sh

    ### 99-bashrc.after.sh          -- after: cleanup
    source ${conf}/99-bashrc.after.sh
}

dr() {
    ## dr               -- dotfiles_reload
    dotfiles_reload $@
}


## dotfiles_reload()    -- called when source-ing in 00-bashrc.before.sh
dotfiles_reload


