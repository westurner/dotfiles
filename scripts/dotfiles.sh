#!/bin/sh

# Run bash in a dotfiles.venv

# 

__VENV=$(which venv)
__HERE=$(cd $(dirname $0) && pwd) # TODO FIXME XXX 
_dotfiles=${__DOTFILES:-"${HOME}/-dotfiles"}  # ~/-dotfiles
if [ -z $__VENV ]; then
   #readlink $0
    __VENV=${_dotfiles}/src/dotfiles/venv/ipython_config.py
fi

# venv <name|path|-E> -x "bash -c ${dotfiles}/etc/.bashrc"

run_venv() {
   # run_venv()      -- run bash in a venv
   venv_uri=$1
   shift
   bash_args=$@
   bash_cfg="${_dotfiles}/etc/.bashrc"
   (set -x -v;
   $__VENV "${venv_uri}" -x "bash --init-file ${bash_cfg} ${bash_args}" )
}

# TODO: if bash-source

run_venv $@
