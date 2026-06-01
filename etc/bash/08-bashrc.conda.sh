#!/usr/bin/env bash
### bashrc.conda.sh
# Shell configuration for Conda

## Global Environment Variables Configured/Used:
# CONDA_VERSIONS (str, optional): Space-separated list of Python versions to configure (e.g., "27 34 312").
# __WRK (str, optional): Default base workspace directory for dotfiles.venv + Conda setups.
#
# CONDA_ROOT (str, optional): Path to the active Conda base installation directory.
# CONDA_ENVS_PATH (str, optional): Path to the active Conda environments directory.

# see: 05-bashrc.dotfiles.sh
  # printvar() {
  # local definition=$(declare -p "$1" 2>/dev/null) || {
  #     echo "ERROR: variable '$1' is not set." >&2
  #     return 1
  # }
  # echo "${definition#declare * }"
  # }

function _conda_get_versions {
    echo "${CONDA_VERSIONS:-27 34 35 36 37 38 39 310 311 312 313 314}"
}

_conda_status() {
    if [ -n "${PATH}" ]; then
        echo PATH="$(shell_escape_single "${PATH}")";
    fi;
    if [ -n "${CONDA_ROOT}" ]; then
        echo CONDA_ROOT="$(shell_escape_single "${CONDA_ROOT}")";
    fi;
    if [ -n "${CONDA_ENVS_PATH}" ]; then
        echo CONDA_ENVS_PATH="$(shell_escape_single "${CONDA_ENVS_PATH}")";
    fi;
}
_cs() {
    _conda_status
}
cs() {
    _conda_status
}
_conda_status



function _conda_status_core {
    # _conda_status_core()      -- echo CONDA_ROOT and CONDA_ENVS_PATH
    printvar CONDA_ROOT
    printvar CONDA_ENVS_PATH
}

function _conda_status_defaults {
    # _conda_status_defaults()   -- echo CONDA_ROOT__* and CONDA_ENVS_PATH_*
    local ver
    for ver in $(_conda_get_versions); do
        printvar CONDA_ROOT__py${ver}
        printvar CONDA_ENVS__py${ver}
    done
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
    local ver
    for ver in $(_conda_get_versions); do
        export CONDA_ENVS__py${ver}="${__wrk}/-ce${ver}"
        export CONDA_ROOT__py${ver}="${__wrk}/-conda${ver}"
    done

    # export CONDA_ROOT="${__wrk}/-conda37"
    # export CONDA_ENVS_PATH="${__wrk}/-ce37"
}

function __setup_conda_usage {
    echo \
'_setup_conda [CONDA_ENVS_PATH|27-312] [CONDA_ROOT]
Setup environment variables for Conda/Mamba

## Usage:
_setup_conda     # __py27

_setup_conda ~/

_setup_conda 27  # __py27
_setup_conda 34  # __py34
_setup_conda 35  # __py35
_setup_conda 36  # __py36
_setup_conda 37  # __py37
_setup_conda 312  # __py312
_setup_conda ~/envs
_setup_conda ~/envs/ /opt/conda
_setup_conda [CONDA_ENVS_PATH|27-31] [CONDA_ROOT]
'

}

function _setup_conda {
    # _setup_anaconda()     -- set CONDA_ENVS_PATH, CONDA_ROOT
    #   $1 (pathstr or {27, 34}) -- lookup($1, CONDA_ENVS_PATH,
    #                                                   CONDA_ENVS__py27)
    #   $2 (pathstr or "")       -- lookup($2, CONDA_ROOT,
    #                                                   CONDA_ROOT__py27)
    #
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help) __setup_conda_usage; return 0;;
        esac
    done

    local _conda_envs_path="${1}"
    local _conda_root_path="${2}"

    printvar _conda_envs_path
    printvar _conda_root_path


    _setup_conda_defaults "${__WRK}"
    if [ -z "${_conda_envs_path}" ]; then
        if [ -z "${CONDA_ENVS_PATH}" ] || [ -z "${CONDA_ROOT}" ]; then
            echo "" >&2
            echo "ERROR: _conda_envs_path is not provided and CONDA_ENVS_PATH / CONDA_ROOT are not set." >&2
            echo "" >&2
            echo "You can set defaults in ~/.bashrc.local." >&2
            echo "" >&2
            echo "Instructions for setting dotfiles.venv-style defaults in ~/.bashrc.local:" >&2
            echo "  export __wrk=\"\${home}/-wrk\"" >&2
            echo "  export CONDA_ROOT=\"\${__WRK}/-conda314\"" >&2
            echo "  export CONDA_ENVS_PATH=\"\${__WRK}/-ce314\"" >&2
            echo "  export PATH=\"\${CONDA_ROOT}/bin:\${PATH}\"" >&2
            echo "" >&2
            echo "Or, for standard Miniconda:" >&2
            echo "  export CONDA_ROOT=\"\${HOME}/miniconda3\"" >&2
            echo "  export CONDA_ENVS_PATH=\"\${HOME}/miniconda3/envs\"" >&2
            echo "  export PATH=\"\${CONDA_ROOT}/bin:\${PATH}\"" >&2
            echo "" >&2
            echo "Or, for Mambaforge:" >&2
            echo "  export CONDA_ROOT=\"\${HOME}/mambaforge\"" >&2
            echo "  export CONDA_ENVS_PATH=\"\${HOME}/mambaforge/envs\"" >&2
            echo "  export PATH=\"\${CONDA_ROOT}/bin:\${PATH}\"" >&2
            echo "" >&2
            echo "---" >&2
            echo "" >&2
            return 1
        fi
    else
        case "$_conda_envs_path" in
            27|34|35|36|37|38|39|310|311|312|313|314)
                local ce_var="CONDA_ENVS__py${_conda_envs_path}"
                local cr_var="CONDA_ROOT__py${_conda_envs_path}"
                export CONDA_ENVS_PATH="${!ce_var}"
                export CONDA_ROOT="${!cr_var}"
                ;;
            *)
                export CONDA_ENVS_PATH="${_conda_envs_path}"
                if [ -z "${_conda_root_path}" ] && [ -z "${CONDA_ROOT}" ]; then
                     echo "Error: _conda_root_path is not provided and CONDA_ROOT is not set." >&2
                     return 1
                fi
                export CONDA_ROOT="${_conda_root_path:-${CONDA_ROOT}}"
                ;;
        esac
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
    local ver var_name var_val
    
    if [ -n "${CONDA_ROOT}" ]; then
        PATH_remove "${CONDA_ROOT}/bin" > /dev/null 2>&1
    fi
    
    for ver in $(_conda_get_versions); do
        var_name="CONDA_ROOT__py${ver}"
        var_val="${!var_name}"
        if [ -n "${var_val}" ]; then
            PATH_remove "${var_val}/bin" > /dev/null 2>&1
        fi
    done
    
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
    local envs_paths=( "${CONDA_ENVS_PATH}" )
    local ver var_name
    for ver in $(_conda_get_versions); do
        var_name="CONDA_ENVS__py${ver}"
        envs_paths+=( "${!var_name}" )
    done
    
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
            (set -x; find "${line}" -mindepth 1 -maxdepth 1 -type d)
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
    echo CONDA_ENVS_PATH="$(shell_escape_single "${CONDA_ENVS_PATH}")" >&2
    [[ -e "${files[0]}" ]] && COMPREPLY=( "${files[@]##*/}" )

}

function _workon_conda_usage {
    echo \
'workon_conda [envname|envpath] [VENVSTRAPP] [CONDA_ENVS_PATH]

    Usage:

    # _setup_conda        # _setup_conda -h
    # mkcondaenv env123   # ~= CONDA_ENVS_PATH="..." conda create -n env123 -y

    _setup_conda
    workon_conda <TAB>     # lsve
    workon_conda env123
    wec env123
'
}

function workon_conda {
    # workon_conda()        -- workon a conda + venv project

    for arg in "${@}"; do
        case "${arg}" in
            -h|--help) _workon_conda_usage; return 0;;
        esac
    done

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
        --ve="${CONDA_ENV}" \
        --venvstrapp="${_venvstrapp}" \
        --CONDA_ROOT="${CONDA_ROOT}" \
        --CONDA_ENVS_PATH="${CONDA_ENVS_PATH}" \
        --print-bash)

    declare -f "_setup_venv_prompt" > /dev/null 2>&1 && _setup_venv_prompt

    declare -f "dotfiles_status" > /dev/null 2>&1 && dotfiles_status

    # shellcheck disable=SC2329
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
    echo "mkvirtualenv_conda <envname|path> [CONDA_ENVS_PATH|27,34,312] [<package>+]"
    echo "mkcondaenv    [-h] <envname|path> [CONDA_ENVS_PATH|27,34,312] [<package>+]"
    echo ""
    echo "To create a condaenv named 'science':"
    echo ""
    echo "  $ mkcondaenv science    # envname=science CONDA_ENVS_PATH=='$CONDA_ENVS_PATH'"
    echo "  $ mkcondaenv science 27 # envname=science "'CONDA_ENVS_PATH="$__WRK/-ce27"'
    echo "  $ mkcondaenv science 34 # envname=science "'CONDA_ENVS_PATH="$__WRK/-ce27"'
    echo "  $ mkcondaenv science 35"
    echo "  $ mkcondaenv ~/science 37"
    echo "  $ mkcondaenv science ~/condaenvs"
    echo "  $ mkcondaenv science 37 jupyterlab matplotlib pandas"
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

function mkcondaenv {
    # mkcondaenv()         -- mkvirtualenv_conda "${@}"
    mkvirtualenv_conda "${@}"
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

    printvar _conda_envname
    printvar _conda_envs_path
    # shellcheck disable=2016
    #(set +x +v;
    #    echo '$1 $_conda_envname: '"${_conda_envname}";
    #    echo '$2 $_conda_envs_path: '"${_conda_envs_path}")
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
            34|35|36|37|38|39|310|311|312|313|314|3*)
                _conda_python="python=3.${_conda_envs_path#3}"
                ;;
        esac
    fi
    if [ -z "${_conda_python}" ]; then     # TODO: remove these defaults?
        _conda_python_default="python=3"
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

    export VIRTUAL_ENV="${CONDA_ENV}"   # TODO: is this necessary?
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
    (set -x; \
        (touch "${_prmpt}" && \
         rm -fi "${_prmpt}") && \
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
