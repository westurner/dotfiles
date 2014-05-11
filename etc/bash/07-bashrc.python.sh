
# Generate python cmdline docs::
#
#    man python | cat | egrep 'ENVIRONMENT VARIABLES' -A 200 | egrep 'AUTHOR' -B 200 | head -n -1 | pyline -r '\s*([\w]+)$' 'rgx and rgx.group(1)'

_setup_python () {
    # Python
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #export
}
_setup_python

_setup_pip () {
    #export PIP_REQUIRE_VIRTUALENV=true
    export PIP_REQUIRE_VIRTUALENV=false
    #alias ipython="python -c 'import IPython;IPython.Shell.IPShell().mainloop()'"
}
_setup_pip


## pyvenv
_setup_pyenv() {
    export PYENV_ROOT="${HOME}/.pyenv"
    add_to_path "${PYENV_ROOT}/bin"
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper
}


_setup_anaconda() {
    export _ANACONDA_ROOT="/opt/anaconda"
    add_to_path "${_ANACONDA_ROOT}/bin"
}


__get_python_docs() {
    man_ python | cat | \
        egrep 'ENVIRONMENT VARIABLES' -A 200 | \
        egrep 'AUTHOR' -B 200 | head -n -1 | \
        pyline \
        -r '\s*([\w]+)$' \
        -R 'S' \
        -m textwrap '"\n".join(
            ("# " + l) for l in
                textwrap.wrap(\
                    ((rgx and "export " + rgx.group(1) + "=\"\"")\
                    or \
                    (line.strip())), 70))'
}
