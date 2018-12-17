
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
    echo CONDA_ROOT=$(shell_escape_single "${CONDA_ROOT}")
    echo CONDA_ENVS_PATH=$(shell_escape_single "${CONDA_ENVS_PATH}")
}

function _conda_status_defaults {
    # _conda_status_defaults()   -- echo CONDA_ROOT__* and CONDA_ENVS_PATH_*
    echo CONDA_ROOT__py27=$(shell_escape_single "${CONDA_ROOT__py27}")
    echo CONDA_ENVS__py27=$(shell_escape_single "${CONDA_ENVS__py27}")
    echo CONDA_ROOT__py34=$(shell_escape_single "${CONDA_ROOT__py34}")
    echo CONDA_ENVS__py34=$(shell_escape_single "${CONDA_ENVS__py34}")
    echo CONDA_ROOT__py35=$(shell_escape_single "${CONDA_ROOT__py35}")
    echo CONDA_ENVS__py35=$(shell_escape_single "${CONDA_ENVS__py35}")
    echo CONDA_ROOT__py36=$(shell_escape_single "${CONDA_ROOT__py36}")
    echo CONDA_ENVS__py36=$(shell_escape_single "${CONDA_ENVS__py36}")
    echo CONDA_ROOT__py37=$(shell_escape_single "${CONDA_ROOT__py37}")
    echo CONDA_ENVS__py37=$(shell_escape_single "${CONDA_ENVS__py37}")
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

    export CONDA_ROOT__py27="${__wrk}/-conda27"
    export CONDA_ROOT__py34="${__wrk}/-conda34"
    export CONDA_ROOT__py35="${__wrk}/-conda35"
    export CONDA_ROOT__py36="${__wrk}/-conda36"
    export CONDA_ROOT__py37="${__wrk}/-conda37"

    #export CONDA_ROOT_DEFAULT="CONDA_ROOT__py27"
    #export CONDA_ENVS_DEFAULT="CONDA_ENVS__py27"
    export CONDA_ROOT="${__wrk}/-conda27"
    export CONDA_ENVS_PATH="${__wrk}/-ce27"
}

function _setup_conda {
    # _setup_anaconda()     -- set CONDA_ENVS_PATH, CONDA_ROO
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
    #   _setup_conda ~/envs             # __py27
    #   _setup_conda ~/envs/ /opt/conda # /opt/conda
    #   _setup_conda <conda_envs_path> <conda_root>  # conda_root
    #
    local _conda_envs_path="${1}"
    local _conda_root_path="${2}"
    _setup_conda_defaults "${__WRK}"
    if [ -z "${_conda_envs_path}" ]; then
        export CONDA_ENVS_PATH="${CONDA_ENVS_PATH:-${CONDA_ENVS__py27}}"
        export CONDA_ROOT="${CONDA_ROOT:-${CONDA_ROOT__py27}}"
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
        else
            export CONDA_ENVS_PATH="${_conda_envs_path}"
            export CONDA_ROOT=(
            "${_conda_root_path:-${CONDA_ROOT:-${CONDA_ROOT__py27}}}")
            # CONDA_ROOT_DEFAULT=CONDA_ROOT__py27
        fi
    fi
    _setup_conda_path
}

function _setup_conda_path {
    # _setup_conda_path()   -- prepend CONDA_ROOT/bin to $PATH
    _unsetup_conda_path_all
    (set -x; test -n "${CONDA_ROOT}") || return 2
    PATH_prepend "${CONDA_ROOT}/bin" 2>&1 > /dev/null
}

function _unsetup_conda_path_all {
    # _unsetup_conda_path_all()  -- remove CONDA_ROOT & defaults from $PATH
    (set -x; test -n "${CONDA_ROOT}") || return 2
    PATH_remove "${CONDA_ROOT}/bin" 2>&1 > /dev/null
    if [ -n "${CONDA_ROOT__py27}" ]; then
        PATH_remove "${CONDA_ROOT__py27}/bin" 2>&1 > /dev/null
    fi
    if [ -n "${CONDA_ROOT__py34}" ]; then
        PATH_remove "${CONDA_ROOT__py34}/bin" 2>&1 > /dev/null
    fi
    if [ -n "${CONDA_ROOT__py35}" ]; then
        PATH_remove "${CONDA_ROOT__py35}/bin" 2>&1 > /dev/null
    fi
    if [ -n "${CONDA_ROOT__py36}" ]; then
        PATH_remove "${CONDA_ROOT__py36}/bin" 2>&1 > /dev/null
    fi
    if [ -n "${CONDA_ROOT__py37}" ]; then
        PATH_remove "${CONDA_ROOT__py37}/bin" 2>&1 > /dev/null
    fi
    declare -f 'dotfiles_status' 2>&1 > /dev/null && dotfiles_status
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
    )
    printf '%s\n' "${envs_paths[@]}" \
        | deduplicate_lines
}

function lscondaenvs {
    # lscondaenvs()             -- list CONDA_ENVS_PATH/* (and _conda_status)
    #   _conda_status>2
    #   find>1
    _conda_status >&2
    while IFS= read -r line; do
        if [ -n ${line} ]; then
            find "${line}" -maxdepth 1 -type d
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
    source "${CONDA_ROOT}/bin/activate" "${CONDA_ENV}"

    __VENV=${__DOTFILES}/src/dotfiles/venv/venv_ipyconfig.py
    source <(set -x;
      $__VENV \
        --ve="${CONDA_ENV}" --venvstrapp="${_venvstrapp}" \
        --CONDA_ROOT="${CONDA_ROOT}" \
        --CONDA_ENVS_PATH="${CONDA_ENVS_PATH}" \
        --print-bash)
    declare -f "_setup_venv_prompt" 2>&1 > /dev/null && _setup_venv_prompt
    declare -f "dotfiles_status" 2>&1 > /dev/null && dotfiles_status
    function deactivate {
        source deactivate
        declare -f "dotfiles_postdeactivate" 2>&1 > /dev/null && \
            dotfiles_postdeactivate
    }
}
complete -o default -o nospace -F _condaenvs workon_conda

function wec {
    # wec()                 -- workon a conda + venv project
    #                       note: tab-completion only shows regular virtualenvs
    workon_conda $@
}
complete -o default -o nospace -F _condaenvs wec


function _mkvirtualenv_conda_usage {
    # _mkvirtualenv_conda_usage()  -- echo mkvirtualenv_conda usage information
    echo "mkvirtualenv_conda <envname|envpath> <CONDA_ENVS_PATH|<27,34,35,36,37>>"
    echo ""
    echo "  $ mkvirtualenv_conda science # 27"
    echo "  $ mkvirtualenv_conda science 27"
    echo "  $ mkvirtualenv_conda science 34"
    echo "  $ mkvirtualenv_conda science 35"
    echo "  $ mkvirtualenv_conda ~/science 37"
    echo ""
    echo "workon_conda science science 37"
    echo "wec science science 37"
}

function mkvirtualenv_conda {
    # mkvirtualenv_conda()  -- mkvirtualenv and conda create
    #   $1 (_conda_envname:str)     -- envname string (eg "dotfiles")
    #   $2 (_conda_envs_path:str)   -- path to create envname in
    #       default: CONDA_ENVS_PATH
    local _conda_python="${CONDA_PYTHON}"   # CONDA_PYTHON="python=3.6"

    local _conda_envname="${1}"
    local _conda_envs_path="${2:-${CONDA_ENVS_PATH}}"
    shift; shift
    local _conda_pkgs=${@}

    local _conda_="conda"

    echo '$1 $_conda_envname: '"${_conda_envname}";
    echo '$2 $_conda_envs_path: '"${_conda_envs_path}" ;
    if [ -z "${_conda_envname}" ] || [ -z "${_conda_envs_path}" ]; then
        return 2
    fi

    echo '_setup_conda '"${_conda_envs_path}"
    _setup_conda "${_conda_envs_path}" # scripts/venv_ipyconfig.py
    local CONDA_ENV="${CONDA_ENVS_PATH}/${_conda_envname}"
    if [ -z "${_conda_python}" ]; then
        case $_conda_envs_path in
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
        esac
    fi
    if [ -z "${_conda_python}" ]; then
        _conda_python_default="python=2"
        _conda_python=${_conda_python:-"${_conda_python_default}"}
    fi
#   #(CONDA_ENVS_PATH=${_conda_envs_path} 
#   #    conda create --mkdir -n ${_conda_envname} -y
#   #    "${_conda_python}" readline pip ${_conda_pkgs} )
    "${_conda_}" create --mkdir --prefix "${CONDA_ENV}" --yes \
       "${_conda_python}" readline pip ${_conda_pkgs}

    export VIRTUAL_ENV="${CONDA_ENV}"
    workon_conda "${_conda_envname}" "${_conda_envs_path}"
    export VIRTUAL_ENV="${CONDA_ENV}"

    # if there is a function named 'dotfiles_postmkvirtualenv',
    # then run 'dotfiles_postmkvirtualenv'
    declare -f 'dotfiles_postmkvirtualenv' 2>&1 >/dev/null && \
        dotfiles_postmkvirtualenv

    echo ""
    echo "$(which conda)"
    conda_list="${_LOG}/conda.list.no-pip.postmkvirtualenv.txt"
    echo "conda_list: ${conda_list}"
    "${_conda_}" list -e --no-pip | tee "${conda_list}"
}

function rmvirtualenv_conda {
    # rmvirtualenv_conda()  -- rmvirtualenv conda
    local _conda_envname="${1}"
    local _conda_envs_path="${2:-${CONDA_ENVS_PATH}}"
    if [ -z "${_conda_envname}" ] || [ -z "${_conda_envs_path}" ]; then
        echo '$1 $_conda_envname: '"${_conda_envname}";
        echo '$2 $_conda_envs_path: '"${_conda_envs_path}" ;
        echo '$conda_env="${_conda_envs_path}/{$_conda_envname}"'
        return 2
    fi
    local conda_env="${conda_envs_path}/$_conda_envname"
    echo "Removing ${conda_env}"
    local _prmpt='_y_to_remove__n_to_cancel_'
    (set -x; (touch "${_prmpt}" && rm -fi "${_prmpt}") && \
        rm -rf "${conda_env}")
}


function mkvirtualenv_conda_if_available {
    # mkvirtualenv_conda_if_available() -- mkvirtualenv_conda OR mkvirtualenv
    (declare -f 'mkvirtualenv_conda' 2>&1 > /dev/null \
        && mkvirtualenv_conda "${@}") \
    || \
    (declare -f 'mkvirtualenv' 2>&1 > /dev/null \
        && mkvirtualenv "${@}")
}

function workon_conda_if_available {
    # workon_conda_if_available()       -- workon_conda OR we OR workon
    (declare -f 'workon_conda' 2>&1 > /dev/null \
        && workon_conda "${@}") \
    || \
    (declare -f 'we' 2>&1 > /dev/null \
        && we "${@}") \
    || \
    (declare -f 'workon' 2>&1 > /dev/null \
        && workon "${@}")
}
