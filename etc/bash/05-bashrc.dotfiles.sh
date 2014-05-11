
dotfiles_status() {
    echo "#  === dotfiles config ==="
    echo "PATH=${PATH}"
    echo "## path"
    lightpath | sed 's/^\(.*\)/#  \1/g'
    echo "#  --- virtualenv ---"
    echo "VIRTUAL_ENV=${VIRTUAL_ENV}"
    echo "## virtualenvwrapper"
    echo "PROJECT_HOME=${PROJECT_HOME}"
    echo "WORKON_HOME=${WORKON_HOME}"
    echo "## venv"
    echo "VIRTUAL_ENV_NAME=${VIRTUAL_ENV_NAME}"
    echo "__DOTFILES=${__DOTFILES}"
    echo "__PROJECTS=${__PROJECTS}"
    echo "_WRD=${_WRD}"
    echo "## TODO"
    echo "__SRC=${__SRC}"
    echo "_DOCSHTML=${_DOCSHTML}"
}



if [ -d "${__DOTFILES}" ]; then
    # Add dotfiles executable directories to $PATH
    add_to_path "${__DOTFILES}/bin"
    add_to_path "${__DOTFILES}/scripts"
fi
