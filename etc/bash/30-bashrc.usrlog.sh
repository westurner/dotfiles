

## usrlog   -- Userspace shell logging
## stid()   -- set or regenerate shell session id
#  
source "${__DOTFILES}/etc/usrlog.sh"
_usrlog_setup

note() {
    ## note()   -- _usrlog_append # $@
    _usrlog_append "## " $@
}

usrlogv() {
    ## usrlog() -- open $_USRLOG with vim (skip to end)
    file=${1:-$_USRLOG}
    lessv + ${file}
}

usrlogg() {
    ## usrlogv()    -- open $_USRLOG with gvim / mvim
    file=${1:-$_USRLOG}
    lessg + ${file}
}

usrloge() {
    ## usrloge()    -- open $_USRLOG with venv's vim server
    file=${1:-$_USRLOG}
    lesse "+ ${file}"
}
