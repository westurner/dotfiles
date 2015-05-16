#!/bin/sh
## new.sh

function _new_sh () {
    # new_sh()          -- create and open a new shell script at $1
    file=$1
    if [ -e $1 ]; then
        echo "$1 exists"
    else
        touch $1
        echo "#!/bin/sh" >> ${1}
        echo "## " >> ${1}
        echo "" >> ${1}
        echo 'if [ "${BASH_SOURCE}" == "${0}" ]; then' >> ${1}
        echo '    echo ${@}' >> ${1}
        echo 'fi' >> ${1}
        chmod 700 ${1}
        ${EDITOR_} +3 ${1}
    fi
    return
}

function new_sh() {
    (set -x; _new_sh ${@}; return)
    return
}


if [ "${BASH_SOURCE}" == "${0}" ]; then
    new_sh ${@}
    exit
fi
