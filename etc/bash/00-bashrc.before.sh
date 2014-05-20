

dotfiles_reload() {
    echo "# Reloading bash configuration..."
    conf=$__DOTFILES/etc/bash
  #source ~/.bashrc
    #source 00-bashrc.before.sh

      ## libraries: useful bash functions
      source $conf/01-bashrc.lib.sh

      ## readline
      source $conf/03-bashrc.readline.sh

      ## dotfiles
      #  $__DOTFILES (str): path to local dotfiles repository clone
      export __DOTFILES="${HOME}/.dotfiles"
      source $conf/05-bashrc.dotfiles.sh


      ## python: python: pip, virtualenv, virtualenvwrapper
      #  TODO: PYTHON_
      #  $PROJECT_HOME (str): path to project directory (~/wrk)
      #  $WORKON_HOME (str): path to virtualenvs directory (~/wrk/.ve)
      #  $VIRTUAL_ENV (str): path to current $VIRTUAL_ENV
      source $conf/07-bashrc.python.sh
      source $conf/07-bashrc.virtualenv.sh
      source $conf/07-bashrc.virtualenvwrapper.sh


      ## venv: virtualenvwrapper extensions (shell vars, cmds, aliases)
      #  $_VENVNAME (str): name of current $VIRTUAL_ENV
      #  we() -- workon a new venv (virtualenvwrapper virtualenv + venv)
      #          we() -> workon $1 && source <($_VENV --bash $@)
      #          example::
      #             we $venvname # $appname
      if [ -d /Library ]; then
          export __IS_MAC='true'
      else:
          export __IS_LINUX='true'
      fi
      source $conf/10-bashrc.venv.sh
      # test -f $__PROJECTS && source $__PROJECTS
      #  dotfiles_status() -- print dotfiles env config
      dotfiles_status

      ## venv-pyramid: pyramid development workflow
      #  workon_pyramid_add(venvname, appname)
      source $conf/11-bashrc.venv.pyramid.sh


      ## editor/pager
      #  $EDITOR (str): cmdstring to open $@ in current editor
      #  $PAGER (str): cmdstring to run pager (less/vim)
      #  less_() -- open read only in vim
      #  man_()  -- open manpage in vim
      source $conf/20-bashrc.editor.sh
      source $conf/29-bashrc.vimpagers.sh


      ## usrlog:
      #  $_USRLOG (str): path to .usrlog command log
      source $conf/30-bashrc.usrlog.sh


      ## xlck: screensaver, screen (auto) lock, suspend
      source $conf/30-bashrc.xlck.sh


      ## aliases: bash aliases and cmds
      source $conf/40-bashrc.aliases.sh


      ## bashmarks: local bookmarks
      source $conf/50-bashrc.bashmarks.sh

      ## repos: local repository set mgmt, docs hosting
      source $conf/70-bashrc.repos.sh

    ## after: cleanup
    source $conf/99-bashrc.after.sh
}

dotfiles_reload


