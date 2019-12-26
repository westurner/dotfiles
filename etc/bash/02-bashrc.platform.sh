#!/usr/bin/env bash
### bashrc.platform.sh

detect_platform() {
    # detect_platform() -- set $__IS_MAC or $__IS_LINUX according to $(uname)
    UNAME=$(uname)
    if [ "${UNAME}" == "Darwin" ]; then
        export __IS_MAC='true'
    elif [ "${UNAME}" == "Linux" ]; then
        export __IS_LINUX='true'
    fi
}

j() {
    # j()               -- jobs
    jobs
}

f() {
    # f()               -- fg %$1
    fg %"${1}"
}

b() {
    # b()               -- bg %$1
    bg %"${1}"
}

killjob() {
    # killjob()         -- kill %$1
    kill %"${1}"
}
