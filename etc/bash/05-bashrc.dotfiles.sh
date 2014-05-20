
dotfiles_status() {
    echo "### dotfiles_status()"
    echo "## path"
    echo "PATH=${PATH}"
    #lightpath | sed 's/^\(.*\)/#  \1/g'
    echo "## virtualenv"
    echo "VIRTUAL_ENV=${VIRTUAL_ENV}"
    echo "## virtualenvwrapper"
    echo "PROJECT_HOME=${PROJECT_HOME}"
    echo "WORKON_HOME=${WORKON_HOME}"
    echo "## venv"
    echo "_SRC=${_SRC}"
    echo "_WRD=${_WRD}"
    echo "VIRTUAL_ENV_NAME=${VIRTUAL_ENV_NAME}"
    echo "__DOTFILES=${__DOTFILES}"
    echo "__PROJECTS=${__PROJECTS}"
    echo "## TODO"
    echo "__SRC=${__SRC}"
    echo "_DOCSHTML=${_DOCSHTML}"
    echo "_USRLOG=${_USRLOG}"
}



if [ -d "${__DOTFILES}" ]; then
    # Add dotfiles executable directories to $PATH
    add_to_path "${__DOTFILES}/bin"
    add_to_path "${__DOTFILES}/scripts"
fi
