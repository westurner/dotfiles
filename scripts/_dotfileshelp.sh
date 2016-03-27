#!/usr/bin/env bash
### dotfileshelp.sh -- grep for comments in readline, bash, zsh, i3, vim cfg

_DOTFILES_GREP_NUMBER_LINES=""

#   dotfileshelp  [-n] [-h] [-v -e -d] [<cmd> [<arg1> [<argn>]]]
#
#     <cmd> may be zero or one of { all, readline, bash, zsh, i3, vim }
#
#     -n/--number-lines  -- print line numbers
#
#     -h/--help          -- print help
#     -v/--verbose       -- set -x       (print commands and arguments)
#     -e/--errexit       -- set -e       (exit if any command returns nonzero)
#     -d/--debug         -- set -x -v -e (see: ``help set``)
#        --test          -- run tests
#
#     Usage examples:
#
#         $ dotfileshelp -h
#         $ dotfileshelp -v -h
#         $ dhelp
#         $ dh
#         $ dh all
#         $ dh all -n -v
#         $ dh readline
#         $ dh bash
#         $ dh zsh
#         $ dh i3
#         $ dh vim
#
#  ### dhelp bash functions:
#
PYLINE="${PYLINE:-"${__DOTFILES}/scripts/pyline.py"}"

function dhelp_shell {
    ## dhelp_shell()             -- grep comments in a .sh file
    local _file="${1}"
    "${PYLINE}" \
        -r '^(\s*)(#+)(\s)(\s*.*)' \
        'rgx and "%s%s%s%s" % ((rgx.group(1), " " if len(rgx.group(2)) == 1 else rgx.group(2), rgx.group(3), rgx.group(4)))' \
        -f "${_file}" \
        "${_DOTFILES_GREP_NUMBER_LINES}";
}

function dhelp_help {
    ## dhelp_help() -- grep shell comments in this file ($BASH_SOURCE)
    local _file="${1:-"${BASH_SOURCE}"}"
    echo "####  ${_file} ";
    dhelp_shell "${_file}"
    return
}

function dhelp_inputrc {
    ## dhelp_inputrc()           -- grep comments in a readline .inputrc
    local _inputrc="${1}"
    dhelp_shell "${_inputrc}"
}

function dhelp_inputrc__dotfiles {
    ## dhelp_inputrc__dotfiles() -- grep comments in etc/.inputrc
    local _inputrc="${1:-${__DOTFILES:+"${__DOTFILES}/etc/.inputrc"}}"
    echo "####  ${_inputrc} ";
    dhelp_inputrc "${_inputrc}"
    return
}

function dhelp_bash__dotfiles {
    ## dhelp_bash__dotfiles()    -- grep comments in etc/bash/*.sh
    local prefix=${__DOTFILES}
    local -a paths=${@:-$(cd "${prefix}"; find etc/bash/*)}
    (cd "${prefix}";
        for _file in ${paths}; do
            if [ -f "${_file}" ]; then
                echo "####  ${_file} ";
                dhelp_shell "${_file}"
                echo "   ";
                echo "   ";
            fi
        done
    )
}

function dhelp_zsh__dotfiles {
    ## dhelp_zsh__dotfiles()     -- grep comments in etc/zsh/*.sh
    local -a paths=${@}
    local prefix=${__DOTFILES}
    (cd "${prefix}";
        for _file in ${paths:-$(ls etc/zsh/*.sh)}; do
            echo "####  ${_file} ";
            dhelp_shell "${_file}"
            echo "   ";
            echo "   ";
        done
    )
}

function dhelp_i3 {
    ## dhelp_i3()                -- grep comments in an i3/config
    local _i3cfg="${1}"
    echo "####  ${_i3cfg} ";
    if [ -f "$_i3cfg" ]; then
        "${PYLINE}" \
            -r '^(\s*)(#+)(\s)(\s*.*)' \
            'rgx and "%s%s%s%s" % ((rgx.group(1), "" if len(rgx.group(2)) == 1 else rgx.group(2), rgx.group(3), rgx.group(4)))' \
            -f "${_i3cfg}" \
            "${_DOTFILES_GREP_NUMBER_LINES}" ;
    fi
}

function dhelp_i3__dotfiles {
    ## dhelp_i3__dotfiles()      -- grep comments in etc/i3/config
    local _i3cfg="${1:-${__DOTFILES:+"${__DOTFILES}/etc/i3/config"}}"
    if [ -z "${_i3cfg}" ]; then
        echo "# dotfileshelp: ERR: ${__DOTFILES} is unset"
        return 1
    fi
    dhelp_i3 "${_i3cfg}"
    return
}

function dhelp_vimrc {
    ## dhelp_vimrc()             -- grep comments in a .vim / vimrc file
    local _file="${1}"
    "${PYLINE}" \
        -r '^(\s*)"\s(\s*.*)' \
        'rgx and "{}{}".format(rgx.group(1), rgx.group(2))' \
        -f "${_file}" \
        "${_DOTFILES_GREP_NUMBER_LINES}" ;
}

function dhelp_vimrc__dotfiles {
    ## dhelp_vimrc__dotfiles()   -- grep comments in etc/vim/vimrc*
    (cd "$__DOTFILES";
        for f in $(ls etc/vim/vimrc*); do
            echo "####  $f ";
            dhelp_vimrc "${f}"
            echo "   ";
            echo "   ";
        done
    )
}


function dhelp_test {
    ## dhelp_test() -- test dhelp (--test [--debug])
    function dhelp_test_each {
        ## dhelp_test_each() -- test dhelp functions
        #_setup_dotfiles_help_symlinks
        #_setup_dotfiles
        dhelp_help
        local dhelp="${BASH_SOURCE}"
        "${dhelp}" -h -v
        "${dhelp}" -v -h
        "${dhelp}" -h
        "${dhelp}" -d all
        "${dhelp}" -v all
        "${dhelp}" -e all
        "${dhelp}" all
        "${dhelp}" -d inputrc
        "${dhelp}" inputrc
        "${dhelp}" -d readline
        "${dhelp}" readline
        "${dhelp}" -d bash
        "${dhelp}" bash
        "${dhelp}" -d zsh
        "${dhelp}" zsh
        "${dhelp}" -d i3
        "${dhelp}" i3
        "${dhelp}" -d vim
        "${dhelp}" vim
        dhelp__command
        dhelp_shell
        dhelp_shell ~/.bashrc
        dhelp_inputrc
        dhelp_inputrc ~/.inputrc
        dhelp_inputrc__dotfiles
        dhelp_inputrc__dotfiles ~/.inputrc
        dhelp_bash__dotfiles
        dhelp_bash__dotfiles ~/.bashrc
        dhelp_zsh__dotfiles
        dhelp_zsh__dotfiles ~/.zshrc
        dhelp_i3
        dhelp_i3 ~/.i3/config
        dhelp_i3__dotfiles ~/.i3/config
        dhelp_vimrc
        dhelp_vimrc ~/.vimrc
        dhelp_vimrc__dotfiles
        dhelp_vimrc__dotfiles ~/.vimrc
    }
    (set -e; dhelp_test_each)
    return
}

function _setup_dotfiles_help_symlinks {
    local scriptname='_dotfileshelp.sh'
    local scriptnames=(
        "dotfileshelp"
            "dhelp"
            "dh"
        "dotfileshelp-all"
        "dotfileshelp-readline"
        "dotfileshelp-bash" "dotfiles-bash.sh" #bwcompat
        "dotfileshelp-vim" "dotfiles-vim.sh"
        "dotfileshelp-i3" "dotfiles-i3.sh"
        "dotfileshelp-zsh"
    )
    test -e "${scriptname}" \
        || (echo "ERR: _dotfileshelp.sh not found" \
            && return 1)
    for symlinkname in ${scriptnames[@]}; do
        test -e "${symlinkname}" \
            && test -L "${symlinkname}" \
            && rm "${symlinkname}"
        ln -s "${scriptname}" "${symlinkname}"
    done
}

function _setup_dotfileshelp {
    _setup_dotfiles_help_symlinks
}

#_dotfileshelp.sh main()
if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    declare -r progname="$(basename ${BASH_SOURCE})"
    declare -a _cmdsrun
    function dhelp__command {
        local arg="${1}"
        shift
        case "${arg}" in
            all|dotfileshelp-all)
                _cmdsrun+=("${arg}")
                dhelp_help
                dhelp_inputrc__dotfiles
                dhelp_bash__dotfiles
                dhelp_zsh__dotfiles
                dhelp_i3__dotfiles
                dhelp_vimrc__dotfiles
                ;;

            readline|inputrc|dotfileshelp-readline)
                _cmdsrun+=("${arg}")
                dhelp_inputrc__dotfiles ${@}
                ;;
            bash|dotfiles-bash.sh|dotfileshelp-bash)
                _cmdsrun+=("${arg}")
                dhelp_bash__dotfiles ${@}
                ;;
            zsh|dotfileshelp-zsh)
                _cmdsrun+=("${arg}")
                dhelp_zsh__dotfiles ${@}
                ;;
            vim|vimrc|dotfiles-vim.sh|dotfileshelp-vim)
                _cmdsrun+=("${arg}")
                dhelp_vimrc__dotfiles ${@}
                ;;
            i3|i3wm|dotfiles-i3.sh|dotfileshelp-i3)
                _cmdsrun+=("${arg}")
                dhelp_i3__dotfiles ${@}
                ;;

            -h|--help|help|_dotfileshelp.sh|dotfileshelp)
                _cmdsrun+=("${arg}")
                dhelp_help
                exit
                ;;

            _dotfileshelp-setup.sh)
                _cmdsrun+=("${arg}")
                _setup_dotfiles_help_symlinks
                exit
                ;;
        esac
        return
    }
    declare -a _args
    for arg in ${@}; do
        case "${arg}" in
            -h|--help|help)
                dhelp__command -h
                exit
                ;;
            -v|--verbose)
                set -x
                ;;
            -d|--debug)
                set -x -v -e
                ;;
            -e|--errexit)
                set -e
                ;;
            -n|--number-lines)
                _DOTFILES_GREP_NUMBER_LINES='-n'
                ;;
            --test)
                dhelp_test
                _cmdsrun+=("${arg}")
                retcode_tests=$?
                ;;
            *)
                _args+=("${arg}")
                ;;
        esac
    done
    case "${progname}" in
        dotfileshelp|_dotfileshelp.sh|dhelp|dh)
            dhelp__command ${_args[@]}
            retcode_args=$?
            ;;
        *)
            dhelp__command "${progname}" ${_args}
            retcode_progname=$?
    esac

    if [ -z "${_cmdsrun}" ]; then
        dhelp__command -h  # --help | help
    fi

    exit
fi
#
