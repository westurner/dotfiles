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

DOTFILES_GIT_REPO_URL="https://github.com/westurner/${VENVNAME}"
REPO_DEST_PATH="${VIRTUAL_ENV}/src/${VENVNAME}"
REPO_DEST_HOME=${HOME}/.dotfiles

DOTVIM_HG_REPO_URL="https://bitbucket.org/westurner/dotvim"
DOTVIM_REPO_DEST_PATH="${REPO_DEST_PATH}/etc/vim"

#PIP="${HOME}/.local/bin/pip"
PIP="pip"
PIP_INSTALL="${PIP} install"
PIP_INSTALL_USER="${PIP} install --user"

mkdir -p $WORKON_HOME



clone_dotfiles_bootstrap_repo(){
    test -d ${REPO_DEST_PATH} || \
        git clone ${DOTFILES_GIT_REPO_URL} ${REPO_DEST_PATH}
    ${PIP} install paver
    ${PIP} install -e ${REPO_DEST_PATH}

    test -e ${REPO_DEST_PATH} || \
        ln -s ${REPO_DEST_PATH} ${HOME}/.dotfiles
}

clone_dotvim_repo(){
    test -d ${DOTVIM_REPO_DEST_PATH}/.hg || \
        hg clone ${DOTVIM_HG_REPO_URL} ${DOTVIM_REPO_DEST_PATH} && \
        cd ${DOTVIM_REPO_DEST_PATH} && \
        hg pull && \
        hg branch -v && \
        hg paths
}



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
    VIRTUALENVWRAPPER_SH_NAME="virtualenvwrapper.sh"
    #VIRTUALENVWRAPPER_SH_NAME="virtualenvwrapper_lazy.sh

    VIRTUALENVWRAPPER_SH="${HOME}/.local/bin/${VIRTUALENVWRAPPER_SH_NAME}"
    #VIRTUALENVWRAPPER_SH=$(which virtualenvwrapper.sh)

    test -f ${VIRTUALENVWRAPPER_SH}

    source ${VIRTUALENVWRAPPER_SH}
    # TODO: check .bashrc.venv.sh for .local/bin path lookup
}



backup_and_symlink(){
    # Args:
    #  filename: basename of file

    # no trailing slashes

    filename=${1}
    dest=${2:-"${HOME}/${filename}"}
    src=${3:-"${REPO_DEST_HOME}/etc/${filename}"}
    (test -a ${dest} || test -h ${dest}) && \
        mv ${dest} ${dest}.bkp.${BKUPID}

    ln -s ${src} ${dest}
}

symlink_home_dotfiles() {
    backup_and_symlink "" ${REPO_DEST_HOME} ${REPO_DEST_PATH}
}

symlink_etc_vim(){
    backup_and_symlink vim/vimrc ${HOME}/.vimrc
    backup_and_symlink vim ${HOME}/.vim
}

symlink_bashrc(){
    backup_and_symlink .bashrc
    backup_and_symlink .bashrc.venv.sh
}

symlink_zshrc(){
    backup_and_symlink .zshrc
}

symlink_hgrc(){
    backup_and_symlink .hgrc
    #TODO: set name in ~/.hgrc
}

symlink_gitconfig(){
    backup_and_symlink .gitconfig
    #TODO: set name in ~/.gitconfig
}

symlink_inputrc(){
    backup_and_symlink .inputrc
}

symlink_htoprc() {
    backup_and_symlink .htoprc
}

symlink_mutt() {
    backup_and_symlink mutt ${HOME}/.mutt
}

symlink_gtk() {
    backup_and_symlink .gtkrc
    backup_and_symlink .gtkrc-2.0
    mkdir -p ${HOME}/.config/gtk-3.0
    backup_and_symlink .config/gtk-3.0
}

symlink_mimeapps() {
    mkdir -p ${HOME}/.local/share/applications
    backup_and_symlink mimeapps.list \
        ${HOME}/.local/share/applications/mimeapps.list
}

symlink_i3(){
    backup_and_symlink .i3
}

symlink_xinitrc_screensaver() {
    backup_and_symlink .xinitrc
}

symlink_python() {
    backup_and_symlink .pythonrc
    backup_and_symlink .pydistutils.cfg
    mkdir -p ${HOME}/.pip
    backup_and_symlink .pip/pip.conf
    backup_and_symlink .pdbrc
    backup_and_symlink .noserc
}

symlink_virtualenvwrapper() {
    backup_and_symlink virtualenvwrapper
}

symlink_venv() {
    #backup_and_symlink .ipython/profile_default
    #backup_and_symlink .ipython/profile_default/ipython_config.py
    mkdir -p ${HOME}/.ipython/profile_default/
    backup_and_symlink ipython/ipython_config.py \
        ${HOME}/.ipython/profile_default/ipython_config.py
}


symlink_ruby() {
    backup_and_symlink .gemrc
}

symlink_all() {
    symlink_home_dotfiles

    symlink_inputrc
    symlink_bashrc
    symlink_zshrc
    symlink_htoprc
    symlink_etc_vim

    symlink_python
    symlink_virtualenvwrapper
    symlink_venv

    symlink_ruby

    symlink_gtk
    symlink_i3
    symlink_xinitrc_screensaver

    # {{ full_name }}
    symlink_gitconfig
    symlink_hgrc
    symlink_mutt


}

activate_virtualenv() {
    #workon ${VENVNAME}
    source ${WORKON_HOME}/dotfiles/bin/activate
}

deactivate_virtualenv() {
    type 'virtualenv_deactivate' 2>/dev/null && virtualenv_deactivate || true
}

install_dotfiles_bootstrap() {
    activate_virtualenv
    pip install --upgrade -e ${REPO_DEST_PATH}
}

install_dotfiles_bootstrap_user() {
    #TODO: subshell
    deactivate_virtualenv
    pip install --user -e ${REPO_DEST_PATH}
}

dotfiles_bootstrap_env() {
    # Upgrade system pip
    #pip_bootstrap_pip
    ###pip_upgrade_local_pip
    #pip_upgrade_system_pip
    #pip_upgrade_system_setuptools

    # Install virtualenv and virtualenvwrapper into ~/.local/
    deactivate_virtualenv
    pip_install_virtualenv
    pip_install_virtualenvwrapper
    pip_setup_virtualenvwrapper

}

dotfiles_bootstrap_upgrade() {
    # Clone the dotfiles repository
    clone_dotfiles_bootstrap_repo
    # Clone the dotvim repository
    clone_dotvim_repo

    # Install dotfiles into ${HOME}
    install_dotfiles_bootstrap

    # Install dotfiles into ~/.local/
    #(install_dotfiles_bootstrap_user)

}

dotfiles_bootstrap_install() {
    dotfiles_bootstrap_env
    # Create a new virtualenv
    mkvirtualenv ${VENVNAME} || true
    #workon ${VENVNAME}
    # ${VIRTUAL_ENV} = ${WORKON_HOME}/${VENVNAME}
    # cdvirtualenv == cd ${VIRTUAL_ENV}

    dotfiles_bootstrap_upgrade

    # Symlink dotfiles into ${HOME}
    symlink_all
}

dotfiles_bootstrap_install_requirements() {
    $PIP_INSTALL -r ${REPO_DEST_PATH}/requirements-all.txt
    #$PIP_INSTALL -r ${REPO_DEST_PATH}/requirements-all.txt
}

dotfiles_bootstrap_install_requirements_user() {
    $PIP_INSTALL_USER -r ${REPO_DEST_PATH}/requirements-all.txt
    #$PIP_INSTALL -r ${REPO_DEST_PATH}/requirements-all.txt
}

dotfiles_bootstrap_usage() {
    echo ""
    echo "dotfiles_bootstrap -- a shell wrapper for cloning and installing"

    echo "Usage: $0 <-I|-S|-U> [-h]";
    echo "#  -I   --  dotfiles_bootstrap install";
    echo "#  -S   --  symlink dotfiles into place";
    echo "#  -U   --  update and upgrade dotfiles";
    echo "#  -R   --  pip install -r requirements-all.txt"
    exit 1;
}


dotfiles_bootstrap_main () {
    while getopts "ISUR" o; do
        case "${o}" in
            I)
                i=${OPTARG};
                dotfiles_bootstrap_install;
                ;;
            S)
                s=${OPTARG};
                symlink_all;
                ;;
            U)
                u=${OPTARG};
                dotfiles_bootstrap_upgrade;
                symlink_all;
                ;;
            R)
                u=${OPTARG};
                dotfiles_bootstrap_install_requirements;
                dotfiles_bootstrap_install_requirements_user;
                ;;
            *)
                dotfiles_bootstrap_usage
                ;;
        esac
    done
}

if [[ "$BASH_SOURCE" == $0 ]]; then
    dotfiles_bootstrap_main $@
fi

