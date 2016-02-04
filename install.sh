#!/bin/bash
### install.sh
# Create a directory, clone, install, and source the dotfiles
# https://github.com/westurner/dotfiles


WORKON_HOME="${WORKON_HOME:-"${HOME}/-wrk/-ve27"}" # ~/-wrk/-ve27
VIRTUAL_ENV="${WORKON_HOME}/dotfiles"              # ~/-wrk/-ve27/dotfiles
_SRC="${VIRTUAL_ENV}/src"; mkdir -p "${_SRC}"      # ~/-wrk/-ve27/dotfiles/src
_WRD="${_SRC}/dotfiles"                   # ~/-wrk/-ve27/dotfiles/src/dotfiles

GITURL='https://github.com/westurner/dotfiles'
GITBRANCH="${GITBRANCH:-'develop'}"

git clone --depth=3 "${GITURL}" -b "${GITBRANCH}" "${_WRD}"
bash "${_WRD}"/scripts/bootstrap_dotfiles.sh -S -C # create symlinks, check

test -n "${INSTALL_INTO_USER}" && \
    bash "${_WRD}"/scripts/bootstrap_dotfiles.sh -I -R -u  # install w/ --user

ls -ald ~/-dotfiles
ls -ald ~/.bashrc
source ~/.bashrc
