#!/bin/sh
### new.sh -- generate a templated shell script
# see also: etc/vim/snippets-ulti/sh.snippets
#   vim: :w file.sh
#   vim "bashscript"<ctrl><enter>  -- expand the template
#   # <ctrl> j -- next tmplfield
#   # <ctrl> k -- prev tmplfield


function new_sh {
    ## new_sh()          -- create and open a new shell script at $1
    #  $1 (path)   -- path
    function _new_sh {
        local file="${1}"
        if [ -e "${1}" ]; then
            echo "${1} exists"
            return 1
        fi
        touch "${1}"
        echo "#!/usr/bin/env bash" >> "${1}"
        echo "### ${1} ## description_commentline" >> "${1}"
        echo '' >> "${1}"
        echo 'function main {' >> "${1}"
        echo '    ## main()     ## call main' >> "${1}"
        echo '    echo "${@}"' >> "${1}"
        echo '    ' >> "${1}"
        echo '}' >> "${1}"
        echo '' >> "${1}"
        echo 'if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then' >> "${1}"
        echo '    echo ${@}' >> "${1}"
        echo 'fi' >> "${1}"
        chmod 700 "${1}"

        function _edit {
            local edit="$(which edit 2>/dev/null)"
            if [ -n "${edit}" ]; then
                edit ${@}
            else
                ${EDITOR_:-${EDITOR}} ${@}
            fi
            return
        }
        _edit +7 "${file}"
        return
    }
    (set -x; _new_sh ${@})
    return
}


if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    new_sh ${@}
    exit
fi
