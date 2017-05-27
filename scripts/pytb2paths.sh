#!/bin/bash

function pytb2paths_help {
    echo "pytb2paths - transform traceback lines from stdin to file:line:"
}

function pytb2paths {
    # python traceback
    local sep=${1:-':'}     # file:line
    #local     sep=" +"     # file +lineno

    # 'rgx and rgx.groupdict() or None and sep.join(operator.itemgetter("file", "lineno")(rgx.groupdict()))' \
    pyline \
        --regex='\s+File "(?P<file>.*)", line (?P<lineno>\d+), in (?P<modulestr>.*)$' \
        -m 'operator' \
        'rgx and ("'"$sep"'".join(operator.itemgetter("file", "lineno")(rgx.groupdict())), rgx.groupdict())' \
        -O json
        # pyline -I json
    # TODO: if file.startswith('<')   <stdin>
    # TODO: [ ] ENH: pytest
    # TODO: [ ] ENH: nose
    # TODO: pyline -O json | pyline -I json
    # TODO: pyline: rgx.groupdict.get([keys))
}

function _test_pytb2paths {
    # Traceback:
    #   Traceback (most recent call last):
    #   File "./here.py", line 6, in <module>
    #       print(func2())
    #   File "./here.py", line 5, in func2
    #       func()
    #   File "./here.py", line 3, in func
    #       return 1/0
    #   ZeroDivisionError: integer division or modulo by zero

    local _=$(( \
          tee ./-here.py \
        | python -v ./-here.py 2>&1 \
        | pytb2paths) << EOF
def func():
    return 1/0
def func2():
    func()
print(func2())
EOF
)
    cat './-here.py' | nl | pygmentize -l python
    rm './-here.py'
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    set -x
    declare -r progname="$(basename ${BASH_SOURCE})"
    declare -r progargs="${@}"
    case "${progname}" in
        pytb2paths|pytb2paths.sh)
            pytb2paths
            ;;
        _pytb2paths_test.sh)
            _test_pytb2paths
            ;;
        *)
            pytb2paths_help
            ;;
    esac
fi
