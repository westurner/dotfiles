

#  __DOTFILES -- local dotfiles repository clone
export __DOTFILES="${HOME}/.dotfiles"

if [ -d /Library ]; then
    export __IS_MAC='true'
else:
    export __IS_LINUX='true'
fi

dotfiles_zsh_reload() {
    echo "# Reloading zsh configuration..."
    _zsh_conf=$__DOTFILES/etc/zsh
  #source ~/.zshrc
    #source 00-zshrc.before.sh

      ## lib: zsh functions
      source $_zsh_conf/01-zshrc.lib.sh

      ## bash: read bash config with bash_source function
      source $_zsh_conf/05-zshrc.bashrc.sh

    ## after:
    source $_zsh_conf/99-zshrc.after.sh
}

dotfiles_zsh_reload


