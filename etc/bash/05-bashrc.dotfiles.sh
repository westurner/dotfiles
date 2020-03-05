#!/usr/bin/env bash
### bashrc.dotfiles.sh


function dotfiles_add_path {
    # dotfiles_add_path()       -- add ${__DOTFILES}/scripts to $PATH
    if [ -d "${__DOTFILES}" ]; then
        #PATH_prepend "${__DOTFILES}/bin"  # [01-bashrc.lib.sh]
        PATH_prepend "${__DOTFILES}/scripts"
    fi
}

function shell_escape_single {
    # shell_escape_single()    -- "'" + sed "s,','\"'\"',g" + "'"
    echo "'""${1//\'/\'\"\'\"\'}""'"
}

function dotfiles_status {
    # dotfiles_status()         -- print dotfiles_status
    echo "# dotfiles_status()"
    echo HOSTNAME="$(shell_escape_single "${HOSTNAME}")"
    echo USER="$(shell_escape_single "${USER}")"
    echo __WRK="$(shell_escape_single "${__WRK}")"
    echo PROJECT_HOME="$(shell_escape_single "${PROJECT_HOME}")"
    if [ -n "${CONDA_ROOT}" ]; then
        echo CONDA_ROOT="$(shell_escape_single "${CONDA_ROOT}")"
    fi
    if [ -n "${CONDA_ENVS_PATH}" ]; then
        echo CONDA_ENVS_PATH="$(shell_escape_single "${CONDA_ENVS_PATH}")"
    fi
    echo WORKON_HOME="$(shell_escape_single "${WORKON_HOME}")"
    echo VIRTUAL_ENV_NAME="$(shell_escape_single "${VIRTUAL_ENV_NAME}")"
    echo VIRTUAL_ENV="$(shell_escape_single "${VIRTUAL_ENV}")"
    echo _SRC="$(shell_escape_single "${_SRC}")"
    echo _APP="$(shell_escape_single "${_APP}")"
    echo _WRD="$(shell_escape_single "${_WRD}")"
    #echo "__DOCSWWW=$(shell_escape_single "${_DOCS}")
    #echo "__SRC=$(shell_escape_single "${__SRC}")
    #echo "__PROJECTSRC=$(shell_escape_single "${__PROJECTSRC}")
    echo _USRLOG="$(shell_escape_single "${_USRLOG}")"
    echo _TERM_ID="$(shell_escape_single "${_TERM_ID}")"
    echo PATH="$(shell_escape_single "${PATH}")"
    echo __DOTFILES="$(shell_escape_single "${__DOTFILES}")"
    #echo $PATH | tr ':' '\n' | sed 's/\(.*\)/#     \1/g'
    echo "#"
    if [ -n "${_TODO}" ]; then
        echo _TODO="$(shell_escape_single "${_TODO}")"
    fi
    if [ -n "${_NOTE}" ]; then
        echo _NOTE="$(shell_escape_single "${_NOTE}")"
    fi
    if [ -n "${_MSG}" ]; then
        echo _MSG="$(shell_escape_single "${_MSG}")"
    fi
    echo '##'
}
function ds {
    # ds()                      -- print dotfiles_status
    dotfiles_status
}

    # source "${__DOTFILES}/scripts/cls"
# shellcheck source=../../scripts/cls
source "${__DOTFILES}/scripts/cls"
    # clr()                     -- clear scrollback
    # cls()                     -- clear scrollback and print dotfiles_status()

#function dotfiles_term_uri {
    ##dotfiles_term_uri()        -- print a URI for the current _TERM_ID
    #term_path="${HOSTNAME}/usrlog/${USER}"
    #term_key=${_APP}/${_TERM_ID}
    #TERM_URI="${term_path}/${term_key}"
    #echo "TERM_URI='${TERM_URL}'"
#}

function debug-env {
    _log=${_LOG:-"."}
    OUTPUT=${1:-"${_log}/$(date +"%FT%T%z").debug-env.env.log"}
    dotfiles_status
    echo "## export"
    export | tee "$OUTPUT"
    echo "## alias"
    alias | tee "$OUTPUT"
    # echo "## lspath"
    # lspath | tee $OUTPUT
}

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin

function debug-on {
    # debug-on()                 -- set -x -v
    set -x -v
    shopt -s extdebug
}
function debug-off {
    # debug-off()                -- set +x +v
    set +x +v
    shopt -s extdebug
}

function _virtualenvwrapper_get_step_num {

    # Virtualenvwrapper numeric sequence
    # * to make logs in /var/log/venv.nnn-stepname.log naturally ordered
    #
    # * 0xx : 'initialization' actions  : [initialize]
    # * 1xx : 'creation' actions        : [pre|post]mk[virtualenv|project]
    # * 2xx : 'vation' actions          : [pre|post][activate|deactivate]
    # * 8xx : 'managment' actions       : [pre|post][cpvirtualenv|rmvirtualenv]
    # * 868 : unknown
    # * xx0 : 'pre' actions
    # * xx9 : 'post' actions
    # Source-ordered according to the virtualenvwrapper docs
    # * https://virtualenvwrapper.readthedocs.org/en/latest/scripts.html#scripts
    step=${1}
    n="868"  # unknown
    case ${step} in
        "get_env_details")
            n="800" ;;
        "initialize")
            n="010" ;;
        "premkvirtualenv")
            n="120" ;;
        "postmkvirtualenv")
            n="129" ;;
        "precpvirtualenv")
            n="820" ;;
        "postcpvirtualenv")
            n="829" ;;
        "preactivate")
            n="230" ;;
        "postactivate")
            n="239" ;;
        "predeactivate")
            n="290" ;;
        "postdeactivate")
            n="299" ;;
        "prermvirtualenv")
            n="810" ;;
        "postrmvirtualenv")
            n="819" ;;
        "premkproject")
            n="140" ;;
        "postmkproject")
            n="149" ;;
    esac
    echo "${n}"
}

function log_dotfiles_state {
    # log_dotfiles_state()      -- save current environment to logfiles
    #   $1 -- logkey (virtualenvwrapper step name)
    test -n "${DOTFILES_SKIP_LOG}" && echo '#DOTFILES_SKIP_LOG' && return
    _log=${_LOG:-"${HOME}/var/log"}
    if [ "${_log}" == "/var/log" ]; then
        _log="${HOME}/var/log"
    fi
    logkey=${1:-'log_dotfiles_state'}
    stepnum="$(_virtualenvwrapper_get_step_num "${logkey}")"
    logdir=${_log:-"var/log"}/venv..${VIRTUAL_ENV_NAME}..${stepnum}..${logkey}
    exportslogfile=${logdir}/exports.log
    envlogfile=${logdir}/exports_env.log
    test -n "${logdir}" && mkdir -p "${logdir}"
    # XXX: PRF
    export > "${exportslogfile}"
    set > "${envlogfile}"
}


function dotfiles_initialize {
    # dotfiles_initialize()     -- virtualenvwrapper initialize
    log_dotfiles_state 'initialize'
}


function dotfiles_premkvirtualenv {
    # dotfiles_premkvirtualenv -- virtualenvwrapper premkvirtualenv
    #log_dotfiles_state 'premkvirtualenv'  # PERF
    true
}

function dotfiles_postmkvirtualenv_help {
    echo '# __DOTFILES/etc/bash/10-bashrc.venv.sh sources venv.sh'
    if [ -z "${IS_CONDA_ENV}" ]; then
        echo '# __DOTFILES/etc/bash/10-bashrc.venv.sh defines workon_venv'
        echo "## to work on this virtualenv:"
        echo "# workon_venv <venvstr> [<venvappstr> [<pyver>]]"
        echo "# we          <venvstr> [<venvappstr> [<pyver>]]"
        echo "$ we '${VIRTUAL_ENV_NAME}'"
    else
        _conda_envs_path=${_conda_envs_path}
        echo '# __DOTFILES/etc/bash/08-bashrc.conda.sh defines workon_conda'
        echo "## to work on this condaenv:"
        echo "# workon_conda <venvstr> [<venvappstr> [<pyver>]]"
        echo "# wec          <venvstr> [<venvappstr> [<pyver>]]"
        echo "$ wec '${VIRTUAL_ENV_NAME}' '${VIRTUAL_ENV_NAME}' '${_conda_envs_path}'"
    fi
    echo '#   dotfiles_status                    # ds'
    echo '#   source <(venv.py -e --print-bash)  # venv.py -h'
    echo '$ venv_mkdirs  # already done in dotfiles_postmkvirtualenv   '
    # shellcheck disable=2016
    echo '$ mkdir -p "$_WRD"'
    echo '$ cdwrd; cdw'
    echo '# editwrd README; ewrd README; ew README Makefile  # edit<tab>'
    echo '# cdhelp;; cdvirtualenv; cdv;; cdbin; cdb;; cdetc; cde;; cdsrc; cds;; cdwrd; cdw'
}


function dotfiles_postmkvirtualenv {
    # dotfiles_postmkvirtualenv -- virtualenvwrapper postmkvirtualenv
    log_dotfiles_state 'postmkvirtualenv'

    if [ -z "${VIRTUAL_ENV}" ]; then
        echo 'VIRTUAL_ENV is not set? (err: 2) [dotfiles_postmkvirtualenv]'
        # shellcheck disable=2016
        echo 'we <name>; venv_mkdirs; mkdir -p "$_WRD"'
        return 2
    fi

    # NOTE: infer VIRTUAL_ENV_NAME from VIRTUAL_ENV
    VIRTUAL_ENV_NAME="${VIRTUAL_ENV_NAME:-"$(basename "${VIRTUAL_ENV}")"}"

    #declare -f 'venv_mkdirs' 2>&1 >/dev/null &&
    (set -x; venv_mkdirs)
    local _LOG="${_LOG:-"${VIRTUAL_ENV}/var/log"}"
    (set -x; test -d "${_LOG}" || mkdir -p "${_LOG}")
    echo ""

    local PIP
    PIP="$(command -v pip)"
    echo "PIP=$(shell_escape_single "${PIP}")"

    pip_freeze="${_LOG}/pip.freeze.postmkvirtualenv.txt"
    echo "#pip_freeze=$(shell_escape_single "${pip_freeze}")"
    (set -x; ${PIP} freeze --all | tee "${pip_freeze}")
    echo ""

    pip_list="${_LOG}/pip.list.postmkvirtualenv.txt"
    echo "#pip_list=$(shell_escape_single "${pip_list}")"
    (set -x; ${PIP} list | tee "${pip_list}")
    echo ""

    if [ -n "${IS_CONDA_ENV}" ]; then
        conda_list="${_LOG}/conda.list.no-pip.postmkvirtualenv.txt";
        echo "#conda_list=$(shell_escape_single "${conda_list}")"
        (set -x; conda list -e --no-pip | tee "${conda_list}")

        conda_environment_yml="${_LOG}/conda.environment.postmkvirtualenv.yml";
        echo "#conda_environment_yml=$(shell_escape_single "${conda_environment_yml}")"
        (set -x;
          conda env export \
              | grep -Ev '^(name|prefix): ' \
              | tee "${conda_environment_yml}"
        )

        conda_environment_fromhistory_yml="${_LOG}/conda.environment.from-history.postmkvirtualenv.yml";
        echo "#conda_environment_fromhistory_yml=$(shell_escape_single "${conda_environment_fromhistory_yml}")"
        (set -x;
          conda env export --from-history \
              | grep -Ev '^(name|prefix): ' \
              | tee "${conda_environment_yml}"
        )

        echo '## to work on this condaenv:'
        # shellcheck disable=2016
        echo 'workon_conda '"${VIRTUAL_ENV_NAME}"'; venv_mkdirs; mkdir -p "${_WRD}"; cdw'

        echo '+ workon_conda '"'${VIRTUAL_ENV_NAME}' '${VIRTUAL_ENV_NAME}' ${_conda_envs_path:+"${_conda_envs_path}"}"
        workon_conda "${VIRTUAL_ENV_NAME}" "${VIRTUAL_ENV_NAME}" \
            ${_conda_envs_path:+"${_conda_envs_path}"}

        echo '## to list packages installed into this condaenv with conda:'
        echo '$ conda env export --from-history | grep -Ev "^(name|prefix): "'
        echo '#'
    else
        echo '## to work on this virtualenv:'
        # shellcheck disable=2016
        echo 'workon_venv '"${VIRTUAL_ENV_NAME}"'; venv_mkdirs; mkdir -p "${_WRD}"; cdw'

        echo '+ workon_venv '"${VIRTUAL_ENV_NAME}"
        workon_venv "${VIRTUAL_ENV_NAME}"
    fi

    echo "PWD=$(path)"
    echo "#"
    dotfiles_postmkvirtualenv_help
}

function dotfiles_preactivate {
    # dotfiles_preactivate()    -- virtualenvwrapper preactivate
    log_dotfiles_state 'preactivate'
}

function dotfiles_postactivate {
    # dotfiles_postactivate()   -- virtualenvwrapper postactivate
    log_dotfiles_state 'postactivate'

    local bash_debug_output
    bash_debug_output=$(
        "$__VENV" -e --verbose --diff --print-bash 2>&1 /dev/null)
    local venv_return_code=$?
    if [ ${venv_return_code} -eq 0 ]; then
        if [ -n "${__VENV}" ]; then
            # shellcheck disable=1090
            source <("$__VENV" -e --print-bash)
        fi
    else
        echo "${bash_debug_output}" # >2
    fi

    declare -f '_setup_usrlog' > /dev/null 2>&1 \
        && _setup_usrlog

    declare -f '_setup_venv_prompt' > /dev/null 2>&1 \
        && _setup_venv_prompt

}

function dotfiles_predeactivate {
    # dotfiles_predeactivate()  -- virtualenvwrapper predeactivate
    log_dotfiles_state 'predeactivate'
}

function dotfiles_postdeactivate {
    # dotfiles_postdeactivate() -- virtualenvwrapper postdeactivate
    log_dotfiles_state 'postdeactivate'
    unset VIRTUAL_ENV
    unset VIRTUAL_ENV_NAME
    unset VENVSTR
    unset VENVSTRAPP
    unset VENVPREFIX
    unset _APP
    unset _BIN
    unset _CFG
    unset _EDITCFG_
    # shellcheck disable=2153
    export EDITOR_="${EDITOR}"
    unset _EDIT_
    unset _ETC
    unset _ETCOPT
    unset _HOME
    unset _IPQTLOG
    unset _IPSESSKEY
    unset _LIB
    unset _LOG
    unset _MEDIA
    unset _MNT
    unset _NOTEBOOKS
    unset _OPT
    unset _PYLIB
    unset _PYSITE
    unset _ROOT
    unset _SBIN
    unset _SERVE_
    unset _SHELL_
    unset _SRC
    unset _SRV
    unset _SVCFG
    unset _SVCFG_
    unset _TEST_
    unset _TMP
    unset _USR
    unset _USRBIN
    unset _USRINCLUDE
    unset _USRLIB
    unset _USRLOCAL
    unset _USRLOG
    unset _USRSBIN
    unset _USRSHARE
    unset _USRSRC
    unset _VAR
    unset _VARCACHE
    unset _VARLIB
    unset _VARLOCK
    unset _VARMAIL
    unset _VAROPT
    unset _VARRUN
    unset _VARSPOOL
    unset _VARTMP
    unset _VENV
    unset _WRD
    unset _WRD_SETUPY
    unset _WWW

    ### usrlog.sh
    ## unset _MSG
    ## unset NOTE
    ## unset TODO

    declare -f '_usrlog_set__USRLOG' > /dev/null 2>&1 \
        && _usrlog_set__USRLOG "${__USRLOG}"

    dotfiles_reload
}
