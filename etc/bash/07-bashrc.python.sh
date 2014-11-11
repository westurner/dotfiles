
### bashrc.python.sh

pypath() {
    #  pypath       -- print python sys.path and site config
    /usr/bin/env python -m site
}

# Generate python cmdline docs::
#
#    man python | cat | egrep 'ENVIRONMENT VARIABLES' -A 200 | egrep 'AUTHOR' -B 200 | head -n -1 | pyline -r '\s*([\w]+)$' 'rgx and rgx.group(1)'

_setup_python () {
    ## _setup_python() -- configure $PYTHONSTARTUP
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #export
}
_setup_python

_setup_pip () {
    ## _setup_pip()     -- set $PIP_REQUIRE_VIRTUALENV=false
    export PIP_REQUIRE_VIRTUALENV=false
}
_setup_pip


## Pyenv

_setup_pyenv() {
    ## _setup_pyvenv()  -- set $PYENV_ROOT, add_to_path, and pyenv venvw
    export PYENV_ROOT="${HOME}/.pyenv"
    add_to_path "${PYENV_ROOT}/bin"
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper
}

## Conda / Anaconda

_setup_anaconda() {
    ## _setup_anaconda  -- set $ANACONDA_ROOT, add_to_path
    export _ANACONDA_ROOT="/opt/anaconda"
    add_to_path "${_ANACONDA_ROOT}/bin"
}

workon_conda() {
    #  workon_conda()    -- workon a conda + venv project
    _conda_envname=${1}
    _app=${2}
    we ${_conda_envname} ${_app}
    _setup_anaconda && \
        source activate ${WORKON_HOME}/.conda/${_conda_envname}
}
complete -o default -o nospace -F _virtualenvs workon_conda

wec() {
    #  wec()              -- workon a conda + venv project
    #                       NOTE: tab-completion only shows all regular
    #                       virtualenvs
    workon_conda $@
}
complete -o default -o nospace -F _virtualenvs wec

mkvirtualenv_conda() {
    #  mkvirtualenv_conda() -- mkvirtualenv and conda create
    mkvirtualenv $@
    _conda_envname=${1}
    conda create --mkdir --prefix ${WORKON_HOME}/.conda/${_conda_envname} \
        readline
    workon_conda ${_conda_envname}
}

rmvirtualenv_conda() {
    # rmvirtualenv_conda()  -- rmvirtualenv conda
    rmvirtualenv $@
    _conda_envname=${1}
    # TODO
}


mkvirtualenv_conda_if_available() {
    #  mkvirtualenv_conda_if_available -- do mkvirtualenv_conda, mkvirtualenv
    (declare -f 'mkvirtualenv_conda' 2>&1 > /dev/null \
        && mkvirtualenv_conda $@) \
    || \
    (declare -f 'mkvirtualenv' 2>&1 > /dev/null \
        && mkvirtualenv $@)
}

workon_conda_if_available() {
    #  mkvirtualenv_conda_if_available -- do mkvirtualenv_conda, mkvirtualenv
    (declare -f 'workon_conda' 2>&1 > /dev/null \
        && workon_conda $@) \
    || \
    (declare -f 'we' 2>&1 > /dev/null \
        && we $@) \
    || \
    (declare -f 'workon' 2>&1 > /dev/null \
        && workon $@)
}
