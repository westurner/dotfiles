reload() {
    conf=$__DOTFILES/etc/bash
  #source ~/.bashrc
    #source 00-bashrc.before.sh
      source $conf/10-bashrc.venv.sh
      # source .dotfiles/etc/usrlog.sh
      # source .dotfiles/etc/xlck.sh
      # source .dotfiles/etc/bashmarks/bashmarks.sh
      # source ~/.local/bin/virtualenvwrapper.sh
      # test -f $__PROJECTS && source $__PROJECTS
      # we() -> workon && source <($_VENV --bash $@)
      source $conf/20-bashrc.vim.sh
      source $conf/40-bashrc.aliases.sh
      source $conf/70-bashrc.repos.sh
    source $conf/99-bashrc.after.sh
}

reload


