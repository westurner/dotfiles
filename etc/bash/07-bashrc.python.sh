
### bashrc.python.sh

pypath() {
    # pypath()              -- print python sys.path and site config
    /usr/bin/env python -m site
}


_setup_python () {
    # _setup_python()       -- configure $PYTHONSTARTUP
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #export
}
_setup_python

_setup_pip () {
    # _setup_pip()          -- set $PIP_REQUIRE_VIRTUALENV=false
    export PIP_REQUIRE_VIRTUALENV=false
}
_setup_pip


## Pyenv

_setup_pyenv() {
    # _setup_pyvenv()       -- set $PYENV_ROOT, add_to_path, and pyenv venvw
    export PYENV_ROOT="${HOME}/.pyenv"
    add_to_path "${PYENV_ROOT}/bin"
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper
}

## Conda / Anaconda

_setup_conda() {
    # _setup_anaconda()     -- set $CONDA_ROOT, add_to_path
    local _conda_pyver=${1}
    source <($__VENV --prefix='.' --print-bash)
    if [ "$_conda_pyver" == "27" ]; then
        export CONDA_HOME=$CONDA_HOME__py27
        export CONDA_ROOT=$CONDA_ROOT__py27
    elif [ "$_conda_pyver" == "34" ]; then
        export CONDA_HOME=$CONDA_HOME__py34
        export CONDA_ROOT=$CONDA_ROOT__py34
    else
        export CONDA_HOME=${CONDA_HOME:-${CONDA_HOME__py27}}
        export CONDA_ROOT=${CONDA_ROOT:-${CONDA_ROOT__py27}}
    fi
    export CONDA_ENVS_PATH=$CONDA_HOME
    add_to_path "${CONDA_ROOT}/bin"
}

workon_conda() {
    # workon_conda()        -- workon a conda + venv project
    local _conda_envname=${1}
    local _conda_pyver=${2}
    local _app=${3}
    _setup_conda ${_conda_pyver}
    local CONDA_ENV=${CONDA_HOME}/${_conda_envname}
    source "${CONDA_ROOT}/bin/activate" "${CONDA_ENV}"
    source <(
      $__VENV --wh="${CONDA_HOME}" --ve="${_conda_envname}" --app="${_app}" \
      --print-bash)
    dotfiles_status
    deactivate() {
        source deactivate
        dotfiles_postdeactivate
    }
}
complete -o default -o nospace -F _virtualenvs workon_conda

wec() {
    # wec()                 -- workon a conda + venv project
    #                       note: tab-completion only shows regular virtualenvs
    workon_conda $@
}
complete -o default -o nospace -F _virtualenvs wec

mkvirtualenv_conda() {
    # mkvirtualenv_conda()  -- mkvirtualenv and conda create
    local _conda_envname=${1}
    local _conda_pyver=${2}
    shift; shift
    local _conda_pkgs=${@}
    _setup_conda ${_conda_pyver}
    if [ -z "$CONDA_HOME" ]; then
        echo "\$CONDA_HOME is not set. Exiting".
        return
    fi
    local CONDA_ENV="${CONDA_HOME}/${_conda_envname}"
    if [ "$_conda_pyver" == "27" ]; then
        conda_python="python=2"
    elif [ "$_conda_pyver" == "34" ]; then
        conda_python="python=3"
    else
        conda_python="python=2"
    fi
    conda create --mkdir --prefix "${CONDA_ENV}" --yes \
        ${conda_python} readline pip ${_conda_pkgs}

    export VIRTUAL_ENV="${CONDA_ENV}"
    workon_conda "${_conda_envname}" "${_conda_pyver}"
    export VIRTUAL_ENV="${CONDA_ENV}"
    dotfiles_postmkvirtualenv

    echo ""
    echo $(which conda)
    conda_list=${_LOG}/conda.list.no-pip.postmkvirtualenv.txt
    echo "conda_list=${conda_list}"
    conda list -e --no-pip | tee "${conda_list}"
}

rmvirtualenv_conda() {
    # rmvirtualenv_conda()  -- rmvirtualenv conda
    local _conda_envname=${1}
    local _conda_pyver=${2}
    _setup_conda ${_conda_pyver}
    local CONDA_ENV=${CONDA_HOME}/$_conda_envname
    if [ -z "$CONDA_HOME" ]; then
        echo "\$CONDA_HOME is not set. Exiting".
        return
    fi
    echo "Removing ${CONDA_ENV}"
    rm -rf "${CONDA_ENV}"
}


mkvirtualenv_conda_if_available() {
    # mkvirtualenv_conda_if_available() -- mkvirtualenv_conda OR mkvirtualenv
    (declare -f 'mkvirtualenv_conda' 2>&1 > /dev/null \
        && mkvirtualenv_conda $@) \
    || \
    (declare -f 'mkvirtualenv' 2>&1 > /dev/null \
        && mkvirtualenv $@)
}

workon_conda_if_available() {
    # workon_conda_if_available()       -- workon_conda OR we OR workon
    (declare -f 'workon_conda' 2>&1 > /dev/null \
        && workon_conda $@) \
    || \
    (declare -f 'we' 2>&1 > /dev/null \
        && we $@) \
    || \
    (declare -f 'workon' 2>&1 > /dev/null \
        && workon $@)
}
