#!/bin/bash
### install.sh
# Create a directory, clone, install, and source the dotfiles
# https://github.com/westurner/dotfiles

_SRC="./-wrk/-ve27/dotfiles/src"; mkdir -p "${_SRC}"
_WRD="${_SRC}/dotfiles"
git clone https://github.com/westurner/dotfiles -b develop "${_WRD}"
bash "${_WRD}"/scripts/bootstrap_dotfiles -S
bash "${_WRD}"/scripts/bootstrap_dotfiles -C
#bash "${_WRD}"/scripts/bootstrap_dotfiles -I -U
ls -ald ~/-dotfiles
ls -ald ~/.bashrc
source ~/.bashrc
