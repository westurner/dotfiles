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
    export WORKON_HOME="${WORKON_HOME:-"${__WRK}/-ve37"}"
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
        if [ -x "/usr/local/bin/python" ]; then
            export VIRTUALENVWRAPPER_PYTHON="/usr/local/bin/python"
        elif [ -x "${HOME}/.local/bin/python" ]; then
            export VIRTUALENVWRAPPER_PYTHON="${HOME}/.local/bin/python"
        # elif "${VIRTUAL_ENV}/bin/python"  ## use extra-venv python
        fi
    fi
    if [ -x "/usr/local/bin/virtualenvwrapper.sh" ]; then
        export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    fi

    #  if [ -n "${__IS_MAC}" ]; then  # for brew python
    local _PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"
    if [ -z "${VIRTUALENVWRAPPER_SCRIPT}" ]; then
        export VIRTUALENVWRAPPER_SCRIPT=$( (PATH="${_PATH}"; which virtualenvwrapper.sh))
    fi
    if [ -z "${VIRTUALENVWRAPPER_PYTHON}" ]; then
        export VIRTUALENVWRAPPER_PYTHON=$( (PATH="${_PATH}"; which python))
    fi
    unset VIRTUALENV_DISTRIBUTE
    if [ -n "${VIRTUALENVWRAPPER_SCRIPT}" ]; then
        source "${VIRTUALENVWRAPPER_SCRIPT}"
    else
        echo "Err: VIRTUALENVWRAPPER_SCRIPT:=${VIRTUALENVWRAPPER_SCRIPT} # 404"
    fi

}

function lsvirtualenvs {
    # lsvirtualenvs()       -- list virtualenvs in $WORKON_HOME
    cmd=${@:-""}
    (cd ${WORKON_HOME} &&
    for venv in $(ls -adtr ${WORKON_HOME}/**/lib/python?.? | \
        sed "s:$WORKON_HOME/\(.*\)/lib/python[0-9]\.[0-9]:\1:g"); do
        if [ -n "${cmd}" ]; then
            $cmd $venv ;
        else
            echo "${venv}" ;
        fi
    done)
}
function lsve {
    # lsve()                -- list virtualenvs in $WORKON_HOME
    lsvirtualenvs "${@}"
}

function backup_virtualenv {
    # backup_virtualenv()   -- backup VIRTUAL_ENV_NAME $1 to [$2]
    local venvstr="${1}"
    local _date="$(date +'%FT%T%z')"
    bkpdir="${2:-"${WORKON_HOME}/_venvbkps/${_date}"}"
    test -d "${bkpdir}" || mkdir -p "${bkpdir}"
    archivename="venvstrbkp.${venvstr}.${_date}.tar.gz"
    archivepath="${bkpdir}/${archivename}"
    (cd "${WORKON_HOME}" \
        tar czf "${archivepath}" "${venvstr}" \
            && echo "${archivename}" \
            || (echo "err: ${venvstr} (${archivename})" >&2))
}

function backup_virtualenvs {
    # backup_virtualenvs()  -- backup all virtualenvs in $WORKON_HOME to [$1]
    date=$(date +'%FT%T%z')
    bkpdir=${1:-"${WORKON_HOME}/_venvbkps/${date}"}
    echo BKPDIR="${bkpdir}"
    test -d "${bkpdir}" || mkdir -p "${bkpdir}"
    lsvirtualenvs
    venvs=$(lsvirtualenvs)
    (cd "${WORKON_HOME}"; \
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
    (declare -f 'deactivate' 2>&1 > /dev/null \
        && deactivate) || \
    (declare -f 'dotfiles_postdeactivate' 2>&1 > /dev/null \
        && dotfiles_postdeactivate)
}

function _rebuild_virtualenv {
    # rebuild_virtualenv()      -- rebuild a virtualenv, leaving pkgs in place
    #    $1="$VENVSTR"
    #    $2="$VIRTUAL_ENV"
    echo "rebuild_virtualenv()"
    VENVSTR="${1}"
    VIRTUAL_ENV=${2:-"${WORKON_HOME}/${VENVSTR}"}
    _BIN="${VIRTUAL_ENV}/bin"
    #rm -fv ${_BIN}/python ${_BIN}/python2 ${_BIN}/python2.7 \
        #${_BIN}/pip ${_BIN}/pip-2.7 \
        #${_BIN}/easy_install ${_BIN}/easy_install-2.7 \
        #${_BIN}/activate*
    pyver=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
    _PYSITE="${VIRTUAL_ENV}/lib/python${pyver}/site-packages"
    find -E "${_PYSITE}" -iname 'activate*' -delete
    find -E "${_PYSITE}" -iname 'pip*' -delete
    find -E "${_PYSITE}" -iname 'setuptools*' -delete
    find -E "${_PYSITE}" -iname 'distribute*' -delete
    find -E "${_PYSITE}" -iname 'easy_install*' -delete
    find -E "${_PYSITE}" -iname 'python*' -delete
    declare -f 'deactivate' 2>&1 > /dev/null && deactivate
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
        | LC_ALL=C xargs  sed -i.bak -E 's,^#!.*python.*,#!'${_BIN}'/python,'
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



if [[ "${BASH_SOURCE}" == "$0" ]]; then
  _setup_virtualenvwrapper
else
  #if [ -z "${VIRTUALENVWRAPPER_SCRIPT}" ]; then
  _setup_virtualenvwrapper
  #fi
fi
