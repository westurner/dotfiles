
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
    # _setup_pyvenv()       -- set $PYENV_ROOT, PATH_prepend, and pyenv venvw
    export PYENV_ROOT="${HOME}/.pyenv"
    PATH_prepend "${PYENV_ROOT}/bin"
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper
}

## Conda / Anaconda

_setup_conda() {
    # _setup_anaconda()     -- set $CONDA_ROOT, PATH_prepend
    # $1 -- conda python version (27|34)
    local _conda_envs_path=${1}
    source <($__VENV --prefix='.' --print-bash)
    if [ -z "${_conda_envs_path}" ]; then
        export CONDA_ENVS_PATH=${CONDA_ENVS_PATH:-${CONDA_ENVS_PATH__py27}}
        export CONDA_ROOT=${CONDA_ROOT:-${CONDA_ROOT__py27}}
    else
        if [ "$_conda_envs_path" == "27" ]; then
            export CONDA_ENVS_PATH=$CONDA_ENVS_PATH__py27
            export CONDA_ROOT=$CONDA_ROOT__py27
        elif [ "$_conda_envs_path" == "34" ]; then
            export CONDA_ENVS_PATH=$CONDA_ENVS_PATH__py34
            export CONDA_ROOT=$CONDA_ROOT__py34
        else
            export CONDA_ENVS_PATH=${_conda_envs_path}
            export CONDA_ROOT=${CONDA_ROOT:-${CONDA_ROOT__py27}}
        fi
    fi
    _setup_conda_path
}

_setup_conda_path() {
    PATH_prepend "${CONDA_ROOT}/bin"
}

lscondaenvs() {
    (cd ${CONDA_ENVS_PATH}; find . -maxdepth 1 -type d)
}

_condaenvs() {
    local files=("${CONDA_ENVS_PATH}/$2"*)
    [[ -e ${files[0]} ]] && COMPREPLY=( "${files[@]##*/}" )
}

workon_conda() {
    # workon_conda()        -- workon a conda + venv project
    local _conda_envname=${1}
    local _conda_envs_path=${2}
    local _app=${3}
    _setup_conda ${_conda_envs_path}
    local CONDA_ENV=${CONDA_ENVS_PATH}/${_conda_envname}
    source "${CONDA_ROOT}/bin/activate" "${CONDA_ENV}"
    source <(
      $__VENV --wh="${CONDA_ENVS_PATH}" --ve="${_conda_envname}" --app="${_app}" \
      --print-bash)
    declare -f "_setup_venv_prompt" 2>&1 > /dev/null && _setup_venv_prompt
    dotfiles_status
    deactivate() {
        source deactivate
        dotfiles_postdeactivate
    }
}
complete -o default -o nospace -F _condaenvs workon_conda

wec() {
    # wec()                 -- workon a conda + venv project
    #                       note: tab-completion only shows regular virtualenvs
    workon_conda $@
}
complete -o default -o nospace -F _condaenvs wec

mkvirtualenv_conda() {
    # mkvirtualenv_conda()  -- mkvirtualenv and conda create
    local _conda_envname=${1}
    local _conda_envs_path=${2}
    shift; shift
    local _conda_pkgs=${@}
    _setup_conda ${_conda_envs_path}
    if [ -z "$CONDA_ENVS_PATH" ]; then
        echo "\$CONDA_ENVS_PATH is not set. Exiting".
        return
    fi
    local CONDA_ENV="${CONDA_ENVS_PATH}/${_conda_envname}"
    if [ "$_conda_envs_path" == "27" ]; then
        conda_python="python=2"
    elif [ "$_conda_envs_path" == "34" ]; then
        conda_python="python=3"
    else
        conda_python="python=2"
    fi
    conda create --mkdir --prefix "${CONDA_ENV}" --yes \
        ${conda_python} readline pip ${_conda_pkgs}

    export VIRTUAL_ENV="${CONDA_ENV}"
    workon_conda "${_conda_envname}" "${_conda_envs_path}"
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
    local _conda_envs_path=${2}
    _setup_conda ${_conda_envs_path}
    local CONDA_ENV=${CONDA_ENVS_PATH}/$_conda_envname
    if [ -z "$CONDA_ENVS_PATH" ]; then
        echo "\$CONDA_ENVS_PATH is not set. Exiting".
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
