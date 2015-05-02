
### bashrc.conda.sh

## Conda / Anaconda

_setup_conda_defaults() {
    # _setup_conda_defaults()   -- configure CONDA_ENVS_PATH*, CONDA_ROOT*
    #    $1 (pathstr): prefix for CONDA_ENVS_PATHS and CONDA_ROOT
    #                 (default: ${__WRK})
    local __wrk=${1:-${__WRK}}
    export CONDA_ENVS_PATH__py27="${__wrk}/-ce27"
    export CONDA_ENVS_PATH__py34="${__wrk}/-ce34"
    export CONDA_ENVS_PATH_DEFAULT="CONDA_ENVS_PATH__py27"
    export CONDA_ENVS_PATH="${__wrk}/-ce27"

    export CONDA_ROOT__py27="${__wrk}/-conda27"
    export CONDA_ROOT__py34="${__wrk}/-conda34"
    export CONDA_ROOT_DEFAULT="CONDA_ROOT__py27"
    export CONDA_ROOT="${__wrk}/-conda27"
}

_setup_conda() {
    # _setup_anaconda()     -- set CONDA_ENVS_PATH, CONDA_ROO
    #   $1 (pathstr or {27, 34}) -- lookup($1, CONDA_ENVS_PATH,
    #                                                   CONDA_ENVS_PATH__py27)
    #   $2 (pathstr or "")       -- lookup($2, CONDA_ROOT,
    #                                                   CONDA_ROOT__py27)
    #
    #  Usage:
    #   _setup_conda    # __py27
    #   _setup_conda 27 # __py27
    #   _setup_conda 34 # __py34
    #   _setup_conda ~/envs             # __py27
    #   _setup_conda ~/envs/ /opt/conda # /opt/conda
    #
    local _conda_envs_path=${1}
    local _conda_root_path=${2}
    _setup_conda_defaults "${__WRK}"
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
            export CONDA_ROOT=(
            ${_conda_root_path:-${CONDA_ROOT:-${CONDA_ROOT__py27}}})
        fi
    fi
    _setup_conda_path
}

_setup_conda_path() {
    _unsetup_conda_path_all
    PATH_prepend "${CONDA_ROOT}/bin" 2>&1> /dev/null
}

_unsetup_conda_path_all() {
    PATH_remove "${CONDA_ROOT}/bin" 2>&1 > /dev/null
    PATH_remove "${CONDA_ROOT__py27}/bin" 2>&1> /dev/null
    PATH_remove "${CONDA_ROOT__py34}/bin" 2>&1> /dev/null
    declare -f 'dotfiles_status' 2>&1 > /dev/null && dotfiles_status
}

lscondaenvs() {
    paths=$(  \
    ( echo "${CONDA_ENVS_PATH}"; \
    echo "${CONDA_ENVS_PATH__py27}";  \
    echo "${CONDA_ENVS_PATH__py34}";) | uniq)
    (set -x; find ${paths} -maxdepth 1 -type d)
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
