#!/usr/bin/env bash
### bashrc.conda.sh

## Conda / Anaconda

# see: 05-bashrc.dotfiles.sh
    #shell_escape_single() {
    #    # shell_escape_single()
    #    strtoescape=${1}
    #    output="$(echo "${strtoescape}" | sed "s,','\"'\"',g")"
    #    echo "'"${output}"'"
    #}

function _conda_status_core {
    # _conda_status_core()      -- echo CONDA_ROOT and CONDA_ENVS_PATH
    echo CONDA_ROOT="$(shell_escape_single "${CONDA_ROOT}")"
    echo CONDA_ENVS_PATH="$(shell_escape_single "${CONDA_ENVS_PATH}")"
}

function _conda_status_defaults {
    # _conda_status_defaults()   -- echo CONDA_ROOT__* and CONDA_ENVS_PATH_*
    echo CONDA_ROOT__py27="$(shell_escape_single "${CONDA_ROOT__py27}")"
    echo CONDA_ENVS__py27="$(shell_escape_single "${CONDA_ENVS__py27}")"

    echo CONDA_ROOT__py34="$(shell_escape_single "${CONDA_ROOT__py34}")"
    echo CONDA_ENVS__py34="$(shell_escape_single "${CONDA_ENVS__py34}")"

    echo CONDA_ROOT__py35="$(shell_escape_single "${CONDA_ROOT__py35}")"
    echo CONDA_ENVS__py35="$(shell_escape_single "${CONDA_ENVS__py35}")"

    echo CONDA_ROOT__py36="$(shell_escape_single "${CONDA_ROOT__py36}")"
    echo CONDA_ENVS__py36="$(shell_escape_single "${CONDA_ENVS__py36}")"

    echo CONDA_ROOT__py37="$(shell_escape_single "${CONDA_ROOT__py37}")"
    echo CONDA_ENVS__py37="$(shell_escape_single "${CONDA_ENVS__py37}")"

    echo CONDA_ROOT__py38="$(shell_escape_single "${CONDA_ROOT__py38}")"
    echo CONDA_ENVS__py38="$(shell_escape_single "${CONDA_ENVS__py38}")"

    echo CONDA_ROOT__py39="$(shell_escape_single "${CONDA_ROOT__py39}")"
    echo CONDA_ENVS__py39="$(shell_escape_single "${CONDA_ENVS__py39}")"

    echo CONDA_ROOT__py310="$(shell_escape_single "${CONDA_ROOT__py310}")"
    echo CONDA_ENVS__py310="$(shell_escape_single "${CONDA_ENVS__py310}")"

    echo CONDA_ROOT__py311="$(shell_escape_single "${CONDA_ROOT__py311}")"
    echo CONDA_ENVS__py311="$(shell_escape_single "${CONDA_ENVS__py311}")"

    echo CONDA_ROOT__py312="$(shell_escape_single "${CONDA_ROOT__py312}")"
    echo CONDA_ENVS__py312="$(shell_escape_single "${CONDA_ENVS__py312}")"

}

function _conda_status {
    # _conda_status()   -- echo CONDA_ROOT, CONDA_ENVS_PATH, and defaults
    _conda_status_core
    echo
    # _conda_status_defaults
}

function csc {
    # csc()             -- echo CONDA_ROOT and CONDA_ENVS_PATH
    _conda_status_core
}

function _setup_conda_defaults {
    # _setup_conda_defaults()   -- configure CONDA_ENVS_PATH*, CONDA_ROOT*
    #    $1 (pathstr): prefix for CONDA_ENVS_PATHS and CONDA_ROOT
    #                 (default: ${__WRK})
    local __wrk="${1:-${__WRK}}"
    export CONDA_ENVS__py27="${__wrk}/-ce27"
    export CONDA_ENVS__py34="${__wrk}/-ce34"
    export CONDA_ENVS__py35="${__wrk}/-ce35"
    export CONDA_ENVS__py36="${__wrk}/-ce36"
    export CONDA_ENVS__py37="${__wrk}/-ce37"
    export CONDA_ENVS__py38="${__wrk}/-ce38"
    export CONDA_ENVS__py39="${__wrk}/-ce39"
    export CONDA_ENVS__py310="${__wrk}/-ce310"
    export CONDA_ENVS__py311="${__wrk}/-ce311"
    export CONDA_ENVS__py312="${__wrk}/-ce312"

    export CONDA_ROOT__py27="${__wrk}/-conda27"
    export CONDA_ROOT__py34="${__wrk}/-conda34"
    export CONDA_ROOT__py35="${__wrk}/-conda35"
    export CONDA_ROOT__py36="${__wrk}/-conda36"
    export CONDA_ROOT__py37="${__wrk}/-conda37"
    export CONDA_ROOT__py38="${__wrk}/-conda38"
    export CONDA_ROOT__py39="${__wrk}/-conda39"
    export CONDA_ROOT__py310="${__wrk}/-conda310"
    export CONDA_ROOT__py311="${__wrk}/-conda311"
    export CONDA_ROOT__py312="${__wrk}/-conda312"

    #export CONDA_ROOT_DEFAULT="CONDA_ROOT__py37"
    #export CONDA_ENVS_DEFAULT="CONDA_ENVS__py37"
    export CONDA_ROOT="${__wrk}/-conda37"
    export CONDA_ENVS_PATH="${__wrk}/-ce37"
}

function _setup_conda {
    # _setup_anaconda()     -- set CONDA_ENVS_PATH, CONDA_ROOT
    #   $1 (pathstr or {27, 34}) -- lookup($1, CONDA_ENVS_PATH,
    #                                                   CONDA_ENVS__py27)
    #   $2 (pathstr or "")       -- lookup($2, CONDA_ROOT,
    #                                                   CONDA_ROOT__py27)
    #
    #  Usage:
    #   _setup_conda     # __py27
    #   _setup_conda 27  # __py27
    #   _setup_conda 34  # __py34
    #   _setup_conda 35  # __py35
    #   _setup_conda 36  # __py36
    #   _setup_conda 37  # __py37
    #   _setup_conda 312  # __py312
    #   _setup_conda ~/envs             # __py37
    #   _setup_conda ~/envs/ /opt/conda # /opt/conda
    #   _setup_conda <conda_envs_path> <conda_root>  # conda_root
    #
    local _conda_envs_path="${1}"
    local _conda_root_path="${2}"
    _setup_conda_defaults "${__WRK}"
    if [ -z "${_conda_envs_path}" ]; then
        export CONDA_ENVS_PATH="${CONDA_ENVS_PATH:-${CONDA_ENVS__py37}}"
        export CONDA_ROOT="${CONDA_ROOT:-${CONDA_ROOT__py37}}"
    else
        if [ "$_conda_envs_path" == "27" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py27"
            export CONDA_ROOT="$CONDA_ROOT__py27"
        elif [ "$_conda_envs_path" == "34" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py34"
            export CONDA_ROOT="$CONDA_ROOT__py34"
        elif [ "$_conda_envs_path" == "35" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py35"
            export CONDA_ROOT="$CONDA_ROOT__py35"
        elif [ "$_conda_envs_path" == "36" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py36"
            export CONDA_ROOT="$CONDA_ROOT__py36"
        elif [ "$_conda_envs_path" == "37" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py37"
            export CONDA_ROOT="$CONDA_ROOT__py37"
        elif [ "$_conda_envs_path" == "38" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py38"
            export CONDA_ROOT="$CONDA_ROOT__py38"
        elif [ "$_conda_envs_path" == "39" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py39"
            export CONDA_ROOT="$CONDA_ROOT__py39"
        elif [ "$_conda_envs_path" == "310" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py310"
            export CONDA_ROOT="$CONDA_ROOT__py310"
        elif [ "$_conda_envs_path" == "311" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py311"
            export CONDA_ROOT="$CONDA_ROOT__py311"
        elif [ "$_conda_envs_path" == "312" ]; then
            export CONDA_ENVS_PATH="$CONDA_ENVS__py312"
            export CONDA_ROOT="$CONDA_ROOT__py312"
        else
            export CONDA_ENVS_PATH="${_conda_envs_path}"
            export CONDA_ROOT="${_conda_root_path:-${CONDA_ROOT:-${CONDA_ROOT__py37}}}"
        fi
    fi
    _setup_conda_path
}

function _setup_conda_path {
    # _setup_conda_path()   -- prepend CONDA_ROOT/bin to $PATH
    _unsetup_conda_path_all
    (set -x; test -n "${CONDA_ROOT}") || return 2
    PATH_prepend "${CONDA_ROOT}/bin" > /dev/null 2>&1
}

function _unsetup_conda_path_all {
    # _unsetup_conda_path_all()  -- remove CONDA_ROOT & defaults from $PATH
    (set -x; test -n "${CONDA_ROOT}") || return 2
    PATH_remove "${CONDA_ROOT}/bin" > /dev/null 2>&1
    if [ -n "${CONDA_ROOT__py27}" ]; then
        PATH_remove "${CONDA_ROOT__py27}/bin" > /dev/null 2>&1
    fi
    if [ -n "${CONDA_ROOT__py34}" ]; then
        PATH_remove "${CONDA_ROOT__py34}/bin" > /dev/null 2>&1
    fi
    if [ -n "${CONDA_ROOT__py35}" ]; then
        PATH_remove "${CONDA_ROOT__py35}/bin" > /dev/null 2>&1
    fi
    if [ -n "${CONDA_ROOT__py36}" ]; then
        PATH_remove "${CONDA_ROOT__py36}/bin" > /dev/null 2>&1
    fi
    if [ -n "${CONDA_ROOT__py37}" ]; then
        PATH_remove "${CONDA_ROOT__py37}/bin" > /dev/null 2>&1
    fi
    if [ -n "${CONDA_ROOT__py38}" ]; then
        PATH_remove "${CONDA_ROOT__py38}/bin" > /dev/null 2>&1
    fi
    if [ -n "${CONDA_ROOT__py39}" ]; then
        PATH_remove "${CONDA_ROOT__py39}/bin" > /dev/null 2>&1
    fi
    if [ -n "${CONDA_ROOT__py310}" ]; then
        PATH_remove "${CONDA_ROOT__py310}/bin" > /dev/null 2>&1
    fi
    if [ -n "${CONDA_ROOT__py311}" ]; then
        PATH_remove "${CONDA_ROOT__py311}/bin" > /dev/null 2>&1
    fi
    if [ -n "${CONDA_ROOT__py312}" ]; then
        PATH_remove "${CONDA_ROOT__py312}/bin" > /dev/null 2>&1
    fi
    declare -f 'dotfiles_status' > /dev/null 2>&1 && dotfiles_status
    _conda_status
}

function deduplicate_lines {
    # deduplicate_lines()   -- deduplicate lines w/ an associative array
    #                                                 (~OrderedMap)
    local -A lines_ary
    local line
    local lines_ary_value
    while IFS= read -r line; do
        lines_ary_value=${lines_ary["${line}"]}
        if [ -z "${lines_ary_value}" ]; then
            lines_ary["${line}"]="${line}"
            echo "${line}"
        fi
    done
    unset lines_ary line lines_ary_value
}

function echo_conda_envs_paths {
    # echo_conda_envs_paths()   -- print (CONDA_ENVS_PATH & defaults)
    local envs_paths=(
        "${CONDA_ENVS_PATH}"
        "${CONDA_ENVS__py27}"
        "${CONDA_ENVS__py34}"
        "${CONDA_ENVS__py35}"
        "${CONDA_ENVS__py36}"
        "${CONDA_ENVS__py37}"
        "${CONDA_ENVS__py38}"
        "${CONDA_ENVS__py39}"
        "${CONDA_ENVS__py310}"
        "${CONDA_ENVS__py311}"
        "${CONDA_ENVS__py312}"
    )
    if [ "$(echo "${envs_paths[*]}" | sed 's/ //g')" == "" ]; then
        echo '' >&2
        # shellcheck disable=2016
        echo 'Error: $CONDA_ENVS_PATH is not set' >&2
        return 1
    fi
    printf '%s\n' "${envs_paths[@]}" \
        | deduplicate_lines
}

function lscondaenvs {
    # lscondaenvs()             -- list CONDA_ENVS_PATH/* (and _conda_status)
    #   _conda_status>2
    #   find>1
    _conda_status >&2
    while IFS= read -r line; do
        if [ -n "${line}" ]; then
            (set -x; find "${line}" -maxdepth 1 -type d)
        fi
    done < <(echo_conda_envs_paths) | sort
}

function lsce {
    # lsce()                    -- list CONDA_ENVS_PATH/* (and _conda_status)
    lscondaenvs "${@}"
}

function _condaenvs {
    # _condaenvs()              -- list conda envs for tab-completion
    local -a files
    while IFS= read -r line; do
        files+=("${line}/$2"*)
    done < <(echo_conda_envs_paths)
    [[ -e ${files[0]} ]] && COMPREPLY=( "${files[@]##*/}" )
}

function workon_conda {
    # workon_conda()        -- workon a conda + venv project
    local _conda_envname="${1}"
    local _venvstrapp="${2}"
    local _conda_envs_path="${3}"

    _setup_conda "${_conda_envs_path}"
    local CONDA_ENV="${CONDA_ENVS_PATH}/${_conda_envname}"
    # shellcheck disable=1090
    source "${CONDA_ROOT}/bin/activate" "${CONDA_ENV}"

    __VENV="${__VENV:-${__DOTFILES}/src/dotfiles/venv/venv_ipyconfig.py}"
    # shellcheck disable=1090
    source <(set -x;
      $__VENV \
        --ve="${CONDA_ENV}" --venvstrapp="${_venvstrapp}" \
        --CONDA_ROOT="${CONDA_ROOT}" \
        --CONDA_ENVS_PATH="${CONDA_ENVS_PATH}" \
        --print-bash)
    declare -f "_setup_venv_prompt" > /dev/null 2>&1 && _setup_venv_prompt
    declare -f "dotfiles_status" > /dev/null 2>&1 && dotfiles_status
    function deactivate {
        # shellcheck disable=1091
        source deactivate
        declare -f "dotfiles_postdeactivate" > /dev/null 2>&1 && \
            dotfiles_postdeactivate
    }
}
complete -o default -o nospace -F _condaenvs workon_conda

function wec {
    # wec()                 -- workon a conda + venv project
    #                       note: tab-completion only shows regular virtualenvs
    workon_conda "${@}"
}
complete -o default -o nospace -F _condaenvs wec


function _mkvirtualenv_conda_usage {
    # _mkvirtualenv_conda_usage()  -- echo mkvirtualenv_conda usage information
    echo "mkvirtualenv_conda <envname|path> [CONDA_ENVS_PATH|<27,34,35,36,37,38>] [<pkg>+]"
    echo ""
    echo "To create a condaenv named 'science':"
    echo ""
    echo "  $ mkvirtualenv_conda science # 27"
    echo "  $ mkvirtualenv_conda science 27"
    echo "  $ mkvirtualenv_conda science 34"
    echo "  $ mkvirtualenv_conda science 35"
    echo "  $ mkvirtualenv_conda ~/science 37"
    echo "  $ mkvirtualenv_conda science ~/condaenvs"
    echo "  $ mkvirtualenv_conda science 37 jupyterlab matplotlib pandas"
    echo ""
    echo "To workon a condaenv named 'science':'"
    echo ""
    echo "  $ workon_conda science science 37"
    echo "  $ wec science science 37"
    echo ""
    echo "To workon a condaenv named 'science' in the (implicit) 37 condaroot:"
    echo ""
    echo "  $ _setup_conda 37"
    echo "  $ wec science"
    echo ""
}

function mkvirtualenv_conda {
    # mkvirtualenv_conda()  -- mkvirtualenv and conda create
    #   $1 (_conda_envname:str)     -- envname string (eg "dotfiles")
    #   $2 (_conda_envs_path:str)   -- path to create envname in
    #       default: CONDA_ENVS_PATH
    if [[ -z "${*}" ]]; then
        _mkvirtualenv_conda_usage
        return 0
    fi
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help)
                _mkvirtualenv_conda_usage
                return 0
        esac
    done

    local _conda_envname="${1}"
    local _conda_envs_path="${2:-${CONDA_ENVS_PATH}}"
    if [ -n "${2}" ]; then
        shift
    fi
    shift
    local _conda_pkgs=( "${@}" )

    local _conda_python="${CONDA_PYTHON}"   # CONDA_PYTHON="python=3.6"

    # shellcheck disable=2016
    (set +x +v;
        echo '$1 $_conda_envname: '"${_conda_envname}";
        echo '$2 $_conda_envs_path: '"${_conda_envs_path}")
    if [ -z "${_conda_envname}" ] || [ -z "${_conda_envs_path}" ]; then
        return 2
    fi

    echo '_setup_conda '"${_conda_envs_path}"
    _setup_conda "${_conda_envs_path}" # scripts/venv_ipyconfig.py
    local CONDA_ENV="${CONDA_ENVS_PATH}/${_conda_envname}"
    if [ -z "${_conda_python}" ]; then
        case "${_conda_envs_path}" in
            27)
                _conda_python="python=2.7"
                ;;
            34)
                _conda_python="python=3.4"
                ;;
            35)
                _conda_python="python=3.5"
                ;;
            36)
                _conda_python="python=3.6"
                ;;
            37)
                _conda_python="python=3.7"
                ;;
            38)
                _conda_python="python=3.8"
                ;;
        esac
    fi
    if [ -z "${_conda_python}" ]; then
        _conda_python_default="python=2"
        _conda_python=${_conda_python:-"${_conda_python_default}"}
    fi
#   #(CONDA_ENVS_PATH=${_conda_envs_path}
#   #    conda create --mkdir -n ${_conda_envname} -y
#   #    "${_conda_python}" readline pip ${_conda_pkgs} )
    (set -x;
        conda create --mkdir --prefix "${CONDA_ENV}" --yes \
            "${_conda_python}" readline pip "${_conda_pkgs[@]}")

    unset VIRTUAL_ENV_NAME
    unset _APP
    export VIRTUAL_ENV="${CONDA_ENV}"
    # shellcheck disable=2016
    echo "+ workon_conda '${_conda_envname}' '${_conda_envname}' '${_conda_envs_path}'"
    workon_conda "${_conda_envname}" "${_conda_envname}" "${_conda_envs_path}"
    export VIRTUAL_ENV="${CONDA_ENV}"

    # if there is a function named 'dotfiles_postmkvirtualenv',
    # then run 'dotfiles_postmkvirtualenv'
    # (defined in 08-bashrc.dotfiles.sh)
    declare -f 'dotfiles_postmkvirtualenv' > /dev/null 2>&1 && \
        IS_CONDA_ENV="${CONDA_ENV}" \
        _conda_envs_path="${_conda_envs_path}" \
        dotfiles_postmkvirtualenv

}

function rmvirtualenv_conda {
    # rmvirtualenv_conda()  -- rmvirtualenv conda
    local _conda_envname="${1}"
    local _conda_envs_path="${2:-${CONDA_ENVS_PATH}}"
    # shellcheck disable=2016
    if [ -z "${_conda_envname}" ] || [ -z "${_conda_envs_path}" ]; then
        echo '$1 $_conda_envname: '"${_conda_envname}";
        echo '$2 $_conda_envs_path: '"${_conda_envs_path}" ;
        echo '$conda_env="${_conda_envs_path}/{$_conda_envname}"'
        return 2
    fi
    local conda_env="${_conda_envs_path}/$_conda_envname"
    echo "Removing ${conda_env}"
    local _prmpt='_y_to_remove__n_to_cancel_'
    (set -x; (touch "${_prmpt}" && rm -fi "${_prmpt}") && \
        rm -rf "${conda_env}")
}


function mkvirtualenv_conda_if_available {
    # mkvirtualenv_conda_if_available() -- mkvirtualenv_conda OR mkvirtualenv
    (declare -f 'mkvirtualenv_conda' > /dev/null 2>&1 \
        && mkvirtualenv_conda "${@}") \
    || \
    (declare -f 'mkvirtualenv' > /dev/null 2>&1 \
        && mkvirtualenv "${@}")
}

function workon_conda_if_available {
    # workon_conda_if_available()       -- workon_conda OR we OR workon
    (declare -f 'workon_conda' > /dev/null 2>&1 \
        && workon_conda "${@}") \
    || \
    (declare -f 'we' > /dev/null 2>&1 \
        && we "${@}") \
    || \
    (declare -f 'workon' > /dev/null 2>&1 \
        && workon "${@}")
}
