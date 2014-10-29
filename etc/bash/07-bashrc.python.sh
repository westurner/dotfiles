
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


_setup_pyenv() {
    ## _setup_pyvenv()  -- set $PYENV_ROOT, add_to_path, and pyenv venvw
    export PYENV_ROOT="${HOME}/.pyenv"
    add_to_path "${PYENV_ROOT}/bin"
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper
}


_setup_anaconda() {
    ## _setup_anaconda  -- set $ANACONDA_ROOT, add_to_path
    export _ANACONDA_ROOT="/opt/anaconda"
    add_to_path "${_ANACONDA_ROOT}/bin"
}
