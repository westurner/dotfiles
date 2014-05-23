
dotfiles_status() {
    #echo "## dotfiles_status()"
    #lightpath | sed 's/^\(.*\)/#  \1/g'
    echo "USER='${USER}'"
    echo "HOSTNAME='${HOSTNAME}'"
    echo "VIRTUAL_ENV_NAME='${VIRTUAL_ENV_NAME}'"
    echo "VIRTUAL_ENV='${VIRTUAL_ENV}'"
    echo "_SRC='${_SRC}'"
    echo "_WRD='${_WRD}'"
    echo "_USRLOG='${_USRLOG}'"
    echo "__DOTFILES='${__DOTFILES}'"
    echo "__DOCSWWW='${_DOCS}'"
    echo "__SRC='${__SRC}'"
    echo "__PROJECTSRC='${__PROJECTSRC}'"
    echo "PROJECT_HOME='${PROJECT_HOME}'"
    echo "WORKON_HOME='${WORKON_HOME}'"
    echo "PATH='${PATH}'"
}

reload_dotfiles() {
    dotfiles_reload $@
}

if [ -d "${__DOTFILES}" ]; then
    # Add dotfiles executable directories to $PATH
    add_to_path "${__DOTFILES}/bin"
    add_to_path "${__DOTFILES}/scripts"
fi
