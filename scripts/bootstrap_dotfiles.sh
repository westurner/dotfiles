#!/bin/bash

## westurner/dotfiles bootstrap script

# Stop (exit) on error
set -e
set -x

# Bootstrap a dotfiles instance from source
BKUPID=$(date +%Y%m%d-%H%M%S~)

WORKON_HOME=${WORKON_HOME:-"${HOME}/wrk/.ve"}
VENVNAME="dotfiles"
VIRTUAL_ENV="${WORKON_HOME}/${VENVNAME}"

REPO_GIT_URL="https://github.com/westurner/${VENVNAME}"
REPO_DEST_PATH="${VIRTUAL_ENV}/src/${VENVNAME}"

#PIP="${HOME}/.local/bin/pip"
PIP="pip"
PIP_INSTALL="${PIP} install"
PIP_INSTALL_USER="${PIP} install --user"

mkdir -p $WORKON_HOME

pip_upgrade_system_setuptools(){
    sudo pip install --upgrade setuptools
}

pip_upgrade_system_pip(){
    sudo pip install --upgrade pip
}

pip_upgrade_local_pip(){
    ${PIP_INSTALL_USER} --force-reinstall --upgrade pip  # seems to error out
}

pip_bootstrap_pip() {
    # Install pip (and setuptools)
    wget --continue https://bootstrap.pypa.io/get-pip.py
    python get-pip.py --user
}

bootstrap_setuptools() {
# Install setuptools
    wget --continue https://bootstrap.pypa.io/ez_setup.py
    python ez_setup.py --user
}

pip_install_virtualenv() {
    ${PIP_INSTALL_USER} --upgrade --no-use-wheel virtualenv
}

pip_install_virtualenvwrapper() {
    ${PIP_INSTALL_USER} --upgrade --no-use-wheel virtualenvwrapper
}


pip_setup_virtualenvwrapper(){
    VIRTUALENVWRAPPER_SH="${HOME}/.local/bin/virtualenvwrapper.sh"
    #VIRTUALENVWRAPPER_SH=$(which virtualenvwrapper.sh)

    test -f ${VIRTUALENVWRAPPER_SH}
    source ${VIRTUALENVWRAPPER_SH}
    # Optionally, instead load virtualenvwrapper lazily:
    #  source ${HOME}/.local/bin/virtualenvwrapper_lazy.sh
}



clone_dotfiles_repo(){
    test -d ${REPO_DEST_PATH} || \
        git clone ${REPO_GIT_URL} ${REPO_DEST_PATH}
    ${PIP} install paver
    ${PIP} install -e ${REPO_DEST_PATH}

    test -e ${REPO_DEST_PATH} || \
        ln -s ${REPO_DEST_PATH} ${HOME}/.dotfiles
}

clone_dotvim_repo(){
    DOTVIM_GIT_REPO_URL="https://bitbucket.org/westurner/dotvim"
    DOTVIM_REPO_DEST_PATH="${REPO_DEST_PATH}/etc/vim"
    test -d ${DOTVIM_REPO_DEST_PATH}/.hg || \
        hg clone ${DOTVIM_GIT_REPO_URL} ${DOTVIM_REPO_DEST_PATH} && \
        cd ${DOTVIM_REPO_DEST_PATH} && \
        hg pull && \
        hg branch -v && \
        hg paths
}

symlink_etc_vim(){
    test -a ${HOME}/.vimrc && \
        mv ${HOME}/.vimrc ${HOME}/.vimrc.bkp.${BKUPID}
    test -a ${HOME}/.vim && \
        mv ${HOME}/.vim ${HOME}/.vim.bkp.${BKUPID}

    ln -s ${REPO_DEST_PATH}/etc/vim ~/.vim
    ln -s ${HOME}/.vim/vimrc ${HOME}/.vimrc
}

install_dotfiles_user() {
    #TODO: subshell
    type 'deactivate' 2>/dev/null && deactivate
    pip install --user -e ${REPO_DEST_PATH}
}

main() {
    #pip_bootstrap_pip
    ###pip_upgrade_local_pip
    #pip_upgrade_system_pip
    #pip_upgrade_system_setuptools
    pip_install_virtualenv
    pip_install_virtualenvwrapper
    pip_setup_virtualenvwrapper

    mkvirtualenv ${VENVNAME} || true
    #workon ${VENVNAME}
    # ${VIRTUAL_ENV} = ${WORKON_HOME}/${VENVNAME}
    # cdvirtualenv == cd ${VIRTUAL_ENV}

    clone_dotfiles_repo
    clone_dotvim_repo

    install_dotfiles_user
    symlink_etc_vim
}

main
