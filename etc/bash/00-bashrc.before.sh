

#  __DOTFILES -- local dotfiles repository clone
export __DOTFILES="${HOME}/.dotfiles"

if [ -d /Library ]; then
    export __IS_MAC='true'
else:
    export __IS_LINUX='true'
fi

dotfiles_reload() {
    echo "# Reloading bash configuration..."
    conf=$__DOTFILES/etc/bash
  #source ~/.bashrc
    #source 00-bashrc.before.sh
      source $conf/01-bashrc.lib.sh
      source $conf/05-bashrc.dotfiles.sh

      source $conf/07-bashrc.python.sh
      source $conf/07-bashrc.virtualenv.sh
      source $conf/07-bashrc.virtualenvwrapper.sh
      source $conf/10-bashrc.venv.sh
      # test -f $__PROJECTS && source $__PROJECTS
      # we() -> workon && source <($_VENV --bash $@)
      dotfiles_status

      source $conf/20-bashrc.editor.sh
      source $conf/29-bashrc.vimpagers.sh
      source $conf/30-bashrc.usrlog.sh
      source $conf/30-bashrc.xlck.sh
      source $conf/40-bashrc.aliases.sh
      source $conf/50-bashrc.bashmarks.sh
      source $conf/70-bashrc.repos.sh
    source $conf/99-bashrc.after.sh
}

dotfiles_reload


