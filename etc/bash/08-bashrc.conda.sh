#!/bin/bash

### bashrc.conda.sh

## Conda / Anaconda
#

function _setup_conda_help {

    echo ' Usage:'
    echo '   _setup_conda <CONDA_ENVS_PATH[_DEFAULT]> <CONDA_ROOT[_DEFAULT]>'
    echo '   wec <envname> ; workon_conda <envname>'
    echo ''
    echo '   _setup_conda 27   #[ 27 | 34 | 35 ]'
    echo '   _setup_conda 2.7  #[ 2.7 | 3.4 | 3.5 ]'
    echo '   _setup_conda ~/-wrk/-ce27 ~/wrk/-conda27'


    echo '   mkvirtualenv_conda dotfiles 2.7'
    echo '   wec dotfiles             # _WRD=~/-wrk/-ce27/dotfiles'
    echo '   wec dotfiles etc/bash    # _WRD=~/-wrk/-ce27/dotfiles/etc/bash'
    echo '   wec dotfiles etc/bash 2.7 # _WRD=~/-wrk/-ce27/dotfiles/etc/bash'
    echo '   wec dotfiles etc/bash 3.5 # _WRD=~/-wrk/-ce35/dotfiles/etc/bash'
}

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
}

function _conda_status {
    # _conda_status()   -- echo CONDA_ROOT, CONDA_ENVS_PATH, and defaults
    _conda_status_core
    echo
    _conda_status_defaults
}

function csc {
    # csc()             -- echo CONDA_ROOT and CONDA_ENVS_PATH
    _conda_status_core
}

function _setup_conda_defaults {
    # _setup_conda_defaults()   -- set CONDA_ROOT[*] and CONDA_ENVS_PATH[*]
    #    $1 (pathstr): prefix for CONDA_ENVS_PATHS and CONDA_ROOT
    #                 (default: ${__WRK})
    #   $1/-ce27
    #   $1/-conda27
    local __wrk=${1:-${__WRK}}
    export CONDA_ENVS__py27="${__wrk}/-ce27"
    export CONDA_ENVS__py34="${__wrk}/-ce34"
    export CONDA_ENVS__py35="${__wrk}/-ce35"
    export CONDA_ENVS_PATH_DEFAULT="CONDA_ENVS__py27"
    export CONDA_ENVS_PATH="${__wrk}/-ce27"

    export CONDA_ROOT__py27="${__wrk}/-conda27"
    export CONDA_ROOT__py34="${__wrk}/-conda34"
    export CONDA_ROOT__py35="${__wrk}/-conda35"

    #export CONDA_ROOT_DEFAULT="CONDA_ROOT__py27"
    #export CONDA_ENVS_DEFAULT="CONDA_ENVS__py27"
    export CONDA_ROOT="${__wrk}/-conda27"
    export CONDA_ENVS_PATH="${__wrk}/-ce27"
}

function _unsetup_conda {
    # _unsetup_conda() -- unset CONDA_ROOT[*] and CONDA_ENVS_PATH[*] vars
    unset CONDA_ENVS_PATH_DEFAULT
    unset CONDA_ENVS_PATH
    unset CONDA_ENVS_PATH__py27
    unset CONDA_ENVS_PATH__py34
    unset CONDA_ENVS_PATH__py35

    unset CONDA_ROOT_DEFAULT
    unset CONDA_ROOT
    unset CONDA_ROOT__py27
    unset CONDA_ROOT__py34
    unset CONDA_ROOT__py35
}

function _setup_conda {
    # _setup_conda()     -- set CONDA_ENVS_PATH, CONDA_ROOT
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
    #   _setup_conda ~/envs             # __py27
    #   _setup_conda ~/envs/ /opt/conda # /opt/conda
    #   _setup_conda <conda_envs_path> <conda_root>  # conda_root
    #
    local _conda_envs_path="${1}"
    local _conda_root_path="${2}"
    _setup_conda_defaults "${__WRK}"
    case "${_conda_envs_path}" in
        27|2.7)
            export CONDA_ENVS_PATH=$CONDA_ENVS__py27
            export CONDA_ROOT=$CONDA_ROOT__py27
            ;;
        34|3.4)
            export CONDA_ENVS_PATH=$CONDA_ENVS__py34
            export CONDA_ROOT=$CONDA_ROOT__py34
            ;;
        35|3.5)
            export CONDA_ENVS_PATH=$CONDA_ENVS__py35
            export CONDA_ROOT=$CONDA_ROOT__py35
            ;;
        *)
            export CONDA_ENVS_PATH=(
                ${_conda_envs_path:-${CONDA_ENVS_PATH:-${CONDA_ENVS__py27}}})
            export CONDA_ROOT=(
                ${_conda_root_path:-${CONDA_ROOT:-${CONDA_ROOT__py27}}})
            ;;
    esac
    _setup_conda_path
}

function _setup_conda_path {
    # _setup_conda_path()   -- prepend CONDA_ROOT/bin to $PATH
    _unsetup_conda_path_all
    (set -x; test -n "${CONDA_ROOT}") || return 2
    PATH_prepend "${CONDA_ROOT}/bin" 2>&1 > /dev/null
    # [ conda activate script then TODO ]
}

function _unsetup_conda_path_all {
    # _unsetup_conda_path_all()  -- remove CONDA_ROOT & defaults from $PATH
    #       (This aggressively avoids layering/nesting conda envs)
    echo PATH="$(shell_escape_single "$PATH")"
    if [ -n "${CONDA_ROOT}" ]; then
        PATH_remove "${CONDA_ROOT}/bin" 2>&1 > /dev/null
    fi
    if [ -n "${CONDA_ROOT__py27}" ]; then
        PATH_remove "${CONDA_ROOT__py27}/bin" 2>&1 > /dev/null
    fi
    if [ -n "${CONDA_ROOT__py34}" ]; then
        PATH_remove "${CONDA_ROOT__py34}/bin" 2>&1 > /dev/null
    fi
    if [ -n "${CONDA_ROOT__py35}" ]; then
        PATH_remove "${CONDA_ROOT__py35}/bin" 2>&1 > /dev/null
    fi
    declare -f 'dotfiles_status' 2>&1 > /dev/null && dotfiles_status
    _conda_status
}

function deduplicate_lines {
    # deduplicate_lines()   -- deduplicate lines with a bash array and echo
    local -A lines_ary
    local line
    local lines_ary_value
    while IFS= read -r line; do
        if [ -n "${line}" ]; then
            lines_ary_value="${lines_ary[$line]}"
            if [ -z "${lines_ary_value}" ]; then
                lines_ary[$line]="${line}"
                echo "${line}"
            fi
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
    )
    echo "${envs_paths}" | deduplicate_lines
}

function lscondaenvs {
    # lscondaenvs()             -- list CONDA_ENVS_PATH/* (and _conda_status)
    #   _conda_status>2
    #   find>1
    _conda_status >&2
    while IFS= read -r line; do
        find "${line}" -maxdepth 1 -type d |
        sort
    done < <(echo_conda_envs_paths)
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
    [[ -e "${files[0]}" ]] && COMPREPLY=( "${files[@]##*/}" )
}

function lscondaenvs_pyvers {
    lscondaenvs | xargs -I % "%"/bin/python -V
}

function workon_conda_help {

    echo "workon_conda [<env name/path> [<venvstrapp> [<CONDA_ENVS_PATH>]]]"
    echo "wec -- workon_conda"

    echo ' workon_conda()        -- workon a conda + venv project'
    echo '  $1 _conda_envname (pathstr) -- e.g. "dotfiles"'
    echo '  $2 _venvstrapp (pathstr) -- e.g. "dotfiles" or "dotfiles/src/dotfiles"'
    echo '  $3 _conda_envs_path (pathstr) -- e.g. "~/-wrk/-ce27"  (${__WRK}/-ce27)'
    echo ''
    echo ''
    _setup_conda_help  # TODO

}

function workon_conda {
    # workon_conda()        -- workon a conda + venv project
    #  $1 _conda_envname (pathstr) -- e.g. "dotfiles"
    #  $2 _venvstrapp (pathstr) -- e.g. "dotfiles" or "dotfiles/src/dotfiles"
    #  $3 _conda_envs_path (pathstr) -- e.g. "~/-wrk/-ce27"  (${__WRK}/-ce27)
    local _conda_envname=${1}
    local _venvstrapp=${2:-${1}}
    local _conda_envs_path=${3}

    if [[ "${@}" == "" ]]; then
        workon_conda_help
        return 1
    fi

    _setup_conda ${_conda_envs_path}

    local CONDA_ENV="${CONDA_ENVS_PATH}/${_conda_envname}"

    source "${CONDA_ROOT}/bin/activate" "${CONDA_ENV}"

    source <(set -x;
      $__VENV \
        --WRK="${__WRK}" \
        --WORKON_HOME="${CONDA_ENVS_PATH}" \
        --VIRTUAL_ENV="${CONDA_ENV}" \
        --venvstrapp="${_venvstrapp}" \
        --print-bash)

    # if declared, run _setup_venv_prompt
    declare -f "_setup_venv_prompt" 2>&1 > /dev/null && _setup_venv_prompt

    # print dotfiles_status
    declare -f "dotfiles_status" 2>&1 > /dev/null && dotfiles_status

    # declare a 'deactivate' function, like virtualenv
    function deactivate {
        source deactivate
        declare -f "dotfiles_postdeactivate" 2>&1 > /dev/null && \
            dotfiles_postdeactivate
    }
    function dx {
        deactivate
    }
}
complete -o default -o nospace -F _condaenvs workon_conda

function wec {
    # wec()                 -- workon a conda + venv project
    #                           note: tab-completion depends on
    #                           CONDA_ENVS_PATH
    #  $1 _conda_envname (pathstr) -- e.g. "dotfiles"
    #  $2 _venvstrapp (pathstr) -- e.g. "dotfiles" or "dotfiles/src/dotfiles"
    #  $3 _conda_envs_path (pathstr) -- e.g. "~/-wrk/-ce27"  (${__WRK}/-ce27)
    workon_conda $@
}
complete -o default -o nospace -F _condaenvs wec

function mkvirtualenv_conda_help {
    # _mkvirtualenv_conda_help()  -- echo mkvirtualenv_conda usage information
    echo "mkvirtualenv_conda <envname|envpath> <CONDA_ENVS_PATH|{27,34,35}> [pkg+]"
    echo '  $1 _conda_envname (pathstr) -- e.g. "dotfiles"'
    echo '  $2 _conda_envs_path (pathstr) -- e.g. "~/-wrk/-ce27"  (${__WRK}/-ce27)'
    echo '       27, 2.7 --> "python=2.7"'
    echo '       34, 3.4 --> "python=3.4"'
    echo '       35, 3.5 --> "python=3.5"'
    echo '  $3+ _conda_pkgs: zero or more additional packages to install'
    echo ''
    echo ' Usage:'
    echo ''
    echo '  $ mkvirtualenv_conda science'
    echo '  $ mkvirtualenv_conda science 27'
    echo '  $ mkvirtualenv_conda science 34'
    echo '  $ mkvirtualenv_conda science 35'
    echo '  $ mkvirtualenv_conda ~/science 35'
}

function mkvirtualenv_conda {
    # mkvirtualenv_conda()  -- mkvirtualenv and conda create
    #  $1 _conda_envname (pathstr) -- e.g. "dotfiles"
    #  $2 _conda_envs_path (pathstr) -- e.g. "~/-wrk/-ce27"  (${__WRK}/-ce27)
    #       27, 2.7 --> "python=2.7"
    #       34, 3.4 --> "python=3.4"
    #       35, 3.5 --> "python=3.5"
    #  $3+ _conda_pkgs: zero or more additional packages to install
    if [ -n "${@}" ]; then
        mkvirtualenv_conda_help
        return 1
    fi
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
    case "${_conda_envs_path}" in
        27|2.7)
            conda_python="python=2.7"
            ;;
        34|3.4)
            conda_python="python=3.4"
            ;;
        35|3.5)
            conda_python="python=3.5"
            ;;
        *)
            conda_python="python=2.7"
            ;;
    esac
    conda create --mkdir --prefix "${CONDA_ENV}" --yes \
        ${conda_python} readline pip ${_conda_pkgs}

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
    conda list -e --no-pip | tee "${conda_list}"
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
        && mkvirtualenv_conda $@) \
    || \
    (declare -f 'mkvirtualenv' 2>&1 > /dev/null \
        && mkvirtualenv $@)
}

function workon_conda_if_available {
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


function test_setup_conda {

    local envname="test_setup_conda__default"
    rmvirtualenv_conda "${envname}"
    mkvirtualenv_conda "${envname}"
    workon_conda "${envname}"
    deactivate
    workon_conda "${envname}"
    #rmvirtualenv_conda "${envname}"


    local envpyver="34"

    function test_setup_conda_env {
        local envpyver="${1:-"34"}"
        local envname="test_setup_conda__${envpyver}"
        rmvirtualenv_conda "${envname}"
        mkvirtualenv_conda "${envname}" "${envpyver}"
        workon_conda "${envname}" '' "${envpyver}"
        deactivate
        workon_conda "${envname}" '' "${envpyver}"
        deactivate
    }

    test_setup_conda_env 27
    test_setup_conda_env 34
    test_setup_conda_env 35


}
