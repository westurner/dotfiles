#!/usr/bin/env bash
### bashrc.virtualenvwrapper.sh
#
# Installing Virtualenvwrapper:
#   apt:
#     sudo apt-get install virtualenvwrapper
#   pip:
#     [sudo] pip install -U pip virtualenvwrapper
#

## Configure dotfiles/virtualenv root/prefix environment variables
# __WRK         workspace root
# PROJECT_HOME  virtualenvwrapper project directory (mkproject)
# WORKON_HOME   virtualenvwrapper virtualenv prefix
#               VIRTUAL_ENV=${WORKON_HOME}/${VIRTUAL_ENV_NAME}
#               _APP=${VIRTUAL_ENV_NAME}  #[/subpath]
#               _SRC=${VIRTUAL_ENV}/${_APP}
#               _WRD=${VIRTUAL_ENV}/${_APP}

function _setup_virtualenvwrapper_default_config {
    export __WRK="${__WRK:-"${HOME}/workspace"}"
    export PROJECT_HOME="${__WRK}"
    export WORKON_HOME="${HOME}/.virtualenvs"
}
function _setup_virtualenvwrapper_dotfiles_config {
    export __WRK="${__WRK:-"${HOME}/-wrk"}"
    export PROJECT_HOME="${__WRK}"
    export WORKON_HOME="${WORKON_HOME:-"${__WRK}/-ve38"}"
}

function _setup_virtualenvwrapper_dirs {
    umask 027
    mkdir -p "${__WRK}" || chmod o-rwx "${__WRK}"
    mkdir -p "${PROJECT_HOME}" || chmod o-rwx "${PROJECT_HOME}"
    mkdir -p "${WORKON_HOME}" || chmod o-rwx "${WORKON_HOME}"
}

function _setup_virtualenvwrapper_config  {
    # _setup_virtualenvwrapper_config()    -- configure $VIRTUALENVWRAPPER_*
    #export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    #export VIRTUALENVWRAPPER_SCRIPT="${HOME}/.local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_HOOK_DIR="${__DOTFILES}/etc/virtualenvwrapper"
    export VIRTUALENVWRAPPER_LOG_DIR="${PROJECT_HOME}/.virtualenvlogs"
    if [ -n "${VIRTUALENVWRAPPER_PYTHON}" ]; then
        if [ -x "/usr/local/bin/python3" ]; then
            export VIRTUALENVWRAPPER_PYTHON="/usr/local/bin/python3"
        elif [ -x "/usr/local/bin/python" ]; then
            export VIRTUALENVWRAPPER_PYTHON="/usr/local/bin/python"
        elif [ -x "${HOME}/.local/bin/python3" ]; then
            export VIRTUALENVWRAPPER_PYTHON="${HOME}/.local/bin/python3"
        elif [ -x "${HOME}/.local/bin/python" ]; then
            export VIRTUALENVWRAPPER_PYTHON="${HOME}/.local/bin/python"
        # elif "${VIRTUAL_ENV}/bin/python"  ## use extra-venv python
        elif [ -x "/usr/bin/python3" ]; then
            export VIRTUALENVWRAPPER_PYTHON="/usr/bin/python3"
        elif [ -x "/bin/python3" ]; then
            export VIRTUALENVWRAPPER_PYTHON="/bin/python3"
        fi
    fi
    if [ -x "/usr/local/bin/virtualenvwrapper.sh" ]; then
        export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    fi

    #  if [ -n "${__IS_MAC}" ]; then  # for brew python
    local _PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"
    if [ -z "${VIRTUALENVWRAPPER_SCRIPT}" ]; then
        VIRTUALENVWRAPPER_SCRIPT=$( (PATH="${_PATH}"; command -v virtualenvwrapper.sh))
        export VIRTUALENVWRAPPER_SCRIPT
    fi
    if [ -z "${VIRTUALENVWRAPPER_PYTHON}" ]; then
        VIRTUALENVWRAPPER_PYTHON=$( (PATH="${_PATH}"; command -v python))
        export VIRTUALENVWRAPPER_PYTHON
    fi
    unset VIRTUALENV_DISTRIBUTE
    if [ -n "${VIRTUALENVWRAPPER_SCRIPT}" ]; then
        # shellcheck disable=1090
        source "${VIRTUALENVWRAPPER_SCRIPT}"
    else
        echo "Err: VIRTUALENVWRAPPER_SCRIPT:=${VIRTUALENVWRAPPER_SCRIPT} # 404"
    fi

}

function _splitondashdash {
    # _splitondashdash()  -- split $@ into two str variables on the first "--"
    #                        (for POSIX compatiblity)
    #   $__SPLIT_BEFORE : newline-delimited part before the --
    #   $__SPLIT_AFTER : space-delimited part after the --
    after_the_dashdash=
    for arg in "${@}"; do
        if [ "${arg}" == "--" ]; then
            after_the_dashdash=1
            continue
        fi
        if [ -z "${after_the_dashdash}" ]; then
            export __SPLIT_BEFORE="${__SPLIT_BEFORE:+"${__SPLIT_BEFORE}"$'\n'}${arg}"
        else
            export __SPLIT_AFTER="${__SPLIT_AFTER:+"${__SPLIT_AFTER} "}${arg}"
        fi
    done
}

function lsvirtualenvs_print_usage {
    echo \
'lsvirtualenvs [-h] [-b|-p] [--wh <$WORKON_HOME>] [-x <command>] [-- <command>]

List virtualenvs in $WORKON_HOME

 -h/--help              print this help text to stdout

 -p/--path/-l           print the full path to each virtualenv
                        with the WORKON_HOME prefix
 -b/--brief/--basename  print only the name of each virtualenv
                        without the WORKON_HOME prefix

  --wh/--WORKON_HOME    Set WORKON_HOME=

## Usage
virtualenvwrapper manages virtualenvs/venvs in $WORKON_HOME.

```
mkvirtualenv      --help     #  pip install virtualenvwrapper
virtualenvwrapper --help     #  apt-get install -y python3-virtualenvwrapper
lsvirtualenv      --help     #  dnf install -y python3-virtualenvwrapper
lsvirtualenvs --help
lsve          --help
```

```
export WORKON_HOME="${HOME}/.virtualenvs"; mkdir -p "${WORKON_HOME}"
mkvirtualenv env123; deactivate
mkvirtualenv env345; deactivate
lsve
lsve -b      # --brief          #  env123\nenv345\n
lsve -l      # --path/--long    #  /workon/home/env123\n/workon/home/env345\n
lsve -p      # --path/--long    #  /workon/home/env123\n/workon/home/env345\n
lsve --path  # -p               #  /workon/home/env123\n/workon/home/env345\n
lsve --wh ./other/workon_home/   #  WORKON_HOME=./other/workon_home/
```
'
}

function lsvirtualenvs {
    # lsvirtualenvs()       -- list virtualenvs in $WORKON_HOME
    #                           if $1 is specified, run that command
    #                           with each virtualenv path
    #                           (Must be POSIX compatible)
    _WORKON_HOME=

    # Split the $@ arguments array into __SPLIT_BEFORE and __SPLIT_AFTER
    __SPLIT_BEFORE=
    __SPLIT_AFTER=
    _splitondashdash "${@}"

    _next_arg_is_workon_home=
    _print_venv_basename=
    _print_venv_path=
    _list_all_venvs=
    _print0=

    # POSIX doesn't support `read` -a to read into $@ or another ary,
    # or bash regex
    while IFS=$'\n' read -r arg
    do
        #printf "ARG: %s\n" "$(shell_escape_single "${arg}")" > &2
        if [ -n "${_next_arg_is_workon_home}" ]; then
            _WORKON_HOME="${arg}";
            echo "WORKON_HOME=$(shell_escape_single "${_WORKON_HOME}")" >&2
            _next_arg_is_workon_home=
            continue
        fi
        if [ -n "${arg}" ]; then
            case "${arg}" in
                -h|--help)
                    lsvirtualenvs_print_usage;
                    return
                    ;;

                --WORKON_HOME|--wh)
                    _next_arg_is_workon_home=1
                    ;;

                -b|--basename|--brief)
                    _print_venv_basename=1
                    ;;
                -p|--path|-l)
                    _print_venv_path=1
                    ;;

                -a|--all)
                    _list_all_venvs=1
                    ;;

                -0|-print0)
                    _print0=1
                    ;;

                *)
                    echo "Unhandled arg in __SPLIT_BEFORE: $(shell_escape_single "${arg}")"
                    ;;
            esac
        fi
    done < <(echo "${__SPLIT_BEFORE}")
    _CMD="${__SPLIT_AFTER}"

    if [ -z "${_WORKON_HOME}" ]; then
        _WORKON_HOME="${WORKON_HOME}";
        echo "WORKON_HOME=$(shell_escape_single "${_WORKON_HOME}")" >&2
    fi
    if [ -n "${_list_all_venvs}" ]; then
        _envs_path=${__WRK}
        mindepth=2
        maxdepth=2
        wholename_args='*/-?e*/*'
        #args='find ~/-wrk -mindepth 2 -maxdepth 2 -wholename '*/-?e*/*' \( -type d -or -type l \)'
    else
        _envs_path=${_WORKON_HOME}
        mindepth=1
        maxdepth=1
        wholename_args=
    fi
    (set -x -v;
    if [ -n "${_print0}" ]; then
        find "${_envs_path}" -mindepth ${mindepth} -maxdepth ${maxdepth} ${wholename_args:+-wholename "${wholename_args}"}  \( -type d -or -type l \) ${_print0:+"-print0"}
    else
        for _VIRTUAL_ENV in $(set -x; find "${_envs_path}" -mindepth ${mindepth} -maxdepth ${maxdepth} ${wholename_args:+-wholename "${wholename_args}"}  \( -type d -or -type l \) ); do
            # _libpython_dirs="$(ls -adtr "${_VIRTUAL_ENV}/lib/python"*.*)"
            # echo "libpython_dirs=(${_libpython_dirs})"
            if [ -n "${_CMD}" ]; then
                ${_CMD} "${_VIRTUAL_ENV}"
            else
                if [ -n "${_print_venv_basename}" ]; then
                    basename "${_VIRTUAL_ENV}"
                elif [ -n "${_print_venv_path}" ]; then
                    echo "${_VIRTUAL_ENV}"
                else
                    echo "${_VIRTUAL_ENV}"
                fi
            fi
        done)
    fi;
}
function lsve {
    # lsve()                -- list virtualenvs in $WORKON_HOME
    lsvirtualenvs "${@}"
}

function _test_lsvirtualenvs {
    lsvirtualenvs
    lsve
    lsve -h | grep -v "${WORKON_HOME}" || false
    lsve --help
}
function test_lsvirtualenvs {
    (set -x; _test_lsvirtualenvs)
}

function backup_virtualenv {
    # backup_virtualenv()   -- backup VIRTUAL_ENV_NAME $1 to [$2]
    local venvstr="${1}"
    local _date
    _date="$(date +'%FT%T%z')"
    bkpdir="${2:-"${WORKON_HOME}/_venvbkps/${_date}"}"
    test -d "${bkpdir}" || mkdir -p "${bkpdir}"
    archivename="venvstrbkp.${venvstr}.${_date}.tar.gz"
    archivepath="${bkpdir}/${archivename}"
    (cd "${WORKON_HOME}" || return; \
        ( tar czf "${archivepath}" "${venvstr}" \
        && echo "# archivename=${archivename}" ) \
            || (echo "err: ${venvstr} (${archivename})" >&2; return 2))
    return $?
}

function backup_virtualenvs {
    # backup_virtualenvs()  -- backup all virtualenvs in $WORKON_HOME to [$1]
    date=$(date +'%FT%T%z')
    bkpdir=${1:-"${WORKON_HOME}/_venvbkps/${date}"}
    echo BKPDIR="${bkpdir}"
    test -d "${bkpdir}" || mkdir -p "${bkpdir}"
    lsvirtualenvs
    venvs=$(lsvirtualenvs)
    (cd "${WORKON_HOME}" || return; \
    for venv in ${venvs}; do
        backup_virtualenv "${venv}" "${bkpdir}" \
        2>> "${bkpdir}/venvbkps.err" \
        | tee -a "${bkpdir}/venvbkps.list"
    done)
    cat "${bkpdir}/venvbkps.err"
    echo BKPDIR="${bkpdir}"
}

function dx {
    # dx()                      -- 'deactivate'
    (declare -f 'deactivate' > /dev/null 2>&1 \
        && deactivate) || \
    (declare -f 'dotfiles_postdeactivate' > /dev/null 2>&1 \
        && dotfiles_postdeactivate)
}

function _rebuild_virtualenv {
    # rebuild_virtualenv()      -- rebuild a virtualenv, leaving pkgs in place
    #    $1="$VENVSTR"
    #    $2="$VIRTUAL_ENV"
    echo "rebuild_virtualenv()"
    VENVSTR="${1}"
    VIRTUAL_ENV=${2:-"${WORKON_HOME}/${VENVSTR}"}
    _test_path_is_not_root "${VIRTUAL_ENV}" || \
        echo "ERROR: VIRTUAL_ENV may not be ~='/'; VIRTUAL_ENV='$VIRTUAL_ENV'" && \
        return 2
    _BIN="${VIRTUAL_ENV}/bin"
    #rm -fv ${_BIN}/python ${_BIN}/python2 ${_BIN}/python2.7 \
        #${_BIN}/pip ${_BIN}/pip-2.7 \
        #${_BIN}/easy_install ${_BIN}/easy_install-2.7 \
        #${_BIN}/activate*
    pyver=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
    _PYSITE="${VIRTUAL_ENV}/lib/python${pyver}/site-packages"
    declare -f 'deactivate' > /dev/null 2>&1 && deactivate
    if [ -n "${VIRTUAL_ENV}" ]; then 
        find -E "${_PYSITE}" -iname 'activate*' -delete
        find -E "${_PYSITE}" -iname 'pip*' -delete
        find -E "${_PYSITE}" -iname 'setuptools*' -delete
        find -E "${_PYSITE}" -iname 'distribute*' -delete
        find -E "${_PYSITE}" -iname 'easy_install*' -delete
        find -E "${_PYSITE}" -iname 'python*' -delete
    fi
    mkvirtualenv -i setuptools -i wheel -i pip "${VENVSTR}"
    #mkvirtualenv --clear would delete ./lib/python<pyver>/site-packages
    workon "${VENVSTR}" && \
    we "${VENVSTR}"
    _BIN="${VIRTUAL_ENV}/bin"

    if [ "${_BIN}" == "/bin" ]; then
        echo "err: _BIN=${_BIN}"
        return 1
    fi

    find "${_BIN}" -type f | grep -v '.bak$' | grep -v 'python*$' \
        | xargs head -n1
    find "${_BIN}" -type f | grep -v '.bak$' | grep -v 'python*$' \
        | LC_ALL=C xargs  sed -i.bak -E 's,^#!.*python.*,#!'"${_BIN}"'/python,'
    find "${_BIN}" -name '*.bak' -delete

    find "${_BIN}" -type f | grep -v '.bak$' | grep -v 'python*$' \
        | xargs head -n1
    echo "
    # TODO: adjust paths beyond the shebang
    #${_BIN}/pip install -v -v -r <(${_BIN}/pip freeze)
    #${_BIN}/pip install -r ${_WRD}/requirements.txt
    "
}

function rebuild_virtualenv {
    #  rebuild_virtualenv()     -- rebuild a virtualenv
    #    $1="$VENVSTR"
    #    $2="$VIRTUAL_ENV"
    (set -x; _rebuild_virtualenv "${@}")
}

function rebuild_virtualenvs {
    # rebuild_virtualenvs()     -- rebuild all virtualenvs in $WORKON_HOME
    lsve rebuild_virtualenv
}


_setup_virtualenvwrapper_dotfiles_config  # ~/-wrk/-ve37 {-ve27,-ce27,-ce37}

function _setup_virtualenvwrapper {
  # _setup_virtualenvwrapper_default_config # ~/.virtualenvs/
  _setup_virtualenvwrapper_config
  _setup_virtualenvwrapper_dirs
}



if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  _setup_virtualenvwrapper
else
  #if [ -z "${VIRTUALENVWRAPPER_SCRIPT}" ]; then
  _setup_virtualenvwrapper
  #fi
fi
