#!/bin/bash -i -e -x
### test_venv.sh

function deactivate_if {
    #  deactivate_if()  -- deactivate if defined, else stderr
    (declare -f 'deactivate' 2>&1 >/dev/null && deactivate) ||
        echo '# deactivate is not defined' >&2
}

function _test_venv_mkdirs {
    #  _test_venv_mkdirs()  -- check virtualenv[wrapper]/venv paths
    local VIRTUAL_ENV="${1:-"${VIRTUAL_ENV}"}"
    test -d "$VIRTUAL_ENV/etc"
    test -d "$VIRTUAL_ENV/bin"
    test -d "$VIRTUAL_ENV/include"
    test -d "$VIRTUAL_ENV/lib"
    test -d "$VIRTUAL_ENV/lib/python?.?"
    test -d "$VIRTUAL_ENV/src"
    test -d "$VIRTUAL_ENV/tmp"
    test -d "$VIRTUAL_ENV/usr"
    test -d "$VIRTUAL_ENV/usr/share"
    test -d "$VIRTUAL_ENV/var"
    test -d "$VIRTUAL_ENV/var/log"
    test -d "$VIRTUAL_ENV/var/cache"
    test -d "$VIRTUAL_ENV/var/run"
    test -d "$VIRTUAL_ENV/var/www"
}

function test_venv_test_main {
    #  test_venv_test_main() -- tests and test runner
    function _setUp {
        export WORKON_HOME="${WORKON_HOME}/-tests"
        local _pwd="${1:-"${WORKON_HOME}"}"
        local _virtualenvwrappersh="${2:-"$(which virtualenvwrapper.sh)"}"
        source "${_virtualenvwrappersh}"
        ## bash -i
        #source ~/.bashrc
        # source "${__DOTFILES}/etc/bash/00-bashrc.before.sh"
        #   source "${__DOTFILES}/etc/bash/05-bashrc.dotfiles.sh"
        #   source "${__DOTFILES}/etc/bash/10-bashrc.venv.sh"
        #   source "${__DOTFILES}/etc/bash/30-bashrc.usrlog.sh"
        deactivate_if
        cd "${_pwd}"
    }

    function test_venv_dotfiles_status {
        ##
        dotfiles_status; ds
        # TODO: assertcontains([_VARS])
    }

    function test_venv_dotfiles_reload {
        ##
        dotfiles_reload; dr
    }

    function test_venv_mkvirtualenv_dirs {
        ##
        deactivate_if
        local _venvstr="_test_mkvirtualenv_dirs"
        local _virtual_env="${WORKON_HOME}/${_venvstr}"
        local _activate="${_virtual_env}/bin/activate"
        mkvirtualenv "${_venvstr}";
        test -d "${_virtual_env}"
        test -f "${_activate}"
        source ${_activate}
        test "${_virtual_env}" = "${VIRTUAL_ENV}"
        deactivate_if
        rmvirtualenv "${_venvstr}";
        test ! -d "${_virtual_env}"
    }

    function test_venv_mkvirtualenv_rmvirtualenv {
        ##
        deactivate_if
        local _venvstr="_test_mkvirtualenv_rmvirtualenv"
        local _virtual_env="${WORKON_HOME}/${_venvstr}"
        local _activate="${_virtual_env}/bin/activate"
        mkvirtualenv "${_venvstr}";
        test -f "${_activate}"
        workon_venv "${_venvstr}"
        deactivate_if
        rmvirtualenv "${_venvstr}";
    }

    function test_venv_rebuild_virtualenv {
        ##
        local _venvstr="_test_venv_rebuild_virtualenv"
        deactivate_if
        mkvirtualenv "${_venvstr}"
        deactivate_if
        rebuild_virtualenv "${_venvstr}"
        deactivate_if
        rmvirtualenv "${_venvstr}"
    }

    function test_venv_mkdirs {
        ##
        local _venvstr="_test_venv_mkdirs"
        local _virtual_env="${WORKON_HOME}/${_venvstr}"
        deactivate_if
        mkvirtualenv "${_venvstr}";
        workon_venv "${_venvstr}"; we "${_venvstr}"
        test "${_virtual_env}" = "${VIRTUAL_ENV}"
        _test_venv_mkdirs "${_virtual_env}"
        deactivate_if
        rmvirtualenv "${_venvstr}";
    }

    _setUp
    test_venv_dotfiles_status
    test_venv_dotfiles_reload

    test_venv_mkvirtualenv_dirs
    test_venv_mkvirtualenv_rmvirtualenv
    test_venv_rebuild_virtualenv

    test_venv_mkdirs
    
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    echo "${@}"
    test_venv_test_main "${@}"
fi
