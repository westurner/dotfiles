export VENVPREFIX='/'
export VENVSTR=''
export HOME='/Users/W'
export __WRK='/Users/W/-wrk'
export __SRC='/Users/W/-wrk/-src'
export __DOTFILES='/Users/W/-dotfiles'
export PROJECT_HOME='/Users/W/-wrk'
export WORKON_HOME__py27='/Users/W/-wrk/-ve27'
export WORKON_HOME__py34='/Users/W/-wrk/-ve34'
export WORKON_HOME_DEFAULT='WORKON_HOME__py27'
export WORKON_HOME='/Users/W/-wrk/-ve27'
export CONDA27_ROOT='/Users/W/-wrk/-conda27'
export CONDA27_HOME='/Users/W/-wrk/-ce27'
export CONDA34_ROOT='/Users/W/-wrk/-conda34'
export CONDA34_HOME='/Users/W/-wrk/-ce34'
export CONDA_ROOT__py27='/Users/W/-wrk/-conda27'
export CONDA_HOME__py27='/Users/W/-wrk/-ce27'
export CONDA_ROOT__py34='/Users/W/-wrk/-conda34'
export CONDA_HOME__py34='/Users/W/-wrk/-ce34'
export CONDA_ROOT_DEFAULT='CONDA_ROOT__py27'
export CONDA_HOME_DEFAULT='CONDA_HOME__py27'
export CONDA_ROOT='/Users/W/-wrk/-conda27'
export CONDA_HOME='/Users/W/-wrk/-ce27'
export VENVSTRAPP=''
export VIRTUAL_ENV=''
export _BIN='/bin'
export _ETC='/etc'
export _ETCOPT='/etc/opt'
export _HOME='/home'
export _LIB='/lib'
export _PYLIB='/lib/python2.7'
export _PYSITE='/lib/python2.7/site-packages'
export _MNT='/mnt'
export _MEDIA='/media'
export _OPT='/opt'
export _ROOT='/root'
export _SBIN='/sbin'
export _SRC='/src'
export _SRV='/srv'
export _TMP='/tmp'
export _USR='/usr'
export _USRBIN='/usr/bin'
export _USRINCLUDE='/usr/include'
export _USRLIB='/usr/lib'
export _USRLOCAL='/usr/local'
export _USRSBIN='/usr/sbin'
export _USRSHARE='/usr/share'
export _USRSRC='/usr/src'
export _VAR='/var'
export _VARCACHE='/var/cache'
export _VARLIB='/var/lib'
export _VARLOCK='/var/lock'
export _LOG='/var/log'
export _VARMAIL='/var/mail'
export _VAROPT='/var/opt'
export _VARRUN='/var/run'
export _VARSPOOL='/var/spool'
export _VARTMP='/var/tmp'
export _WWW='/var/www'
export PROJECT_FILES=''
export _APP=''
export _WRD=''
export VIMBIN='/usr/bin/vim'
export GVIMBIN='/usr/local/bin/gvim'
export MVIMBIN='/usr/local/bin/mvim'
export GUIVIMBIN='/usr/local/bin/gvim'
export VIMCONF='--servername /'
export _EDIT_='/usr/local/bin/gvim --servername / --remote-tab-silent'
export EDITOR_='/usr/local/bin/gvim --servername / --remote-tab-silent'
export _NOTEBOOKS='/src/notebooks'
export _IPYSESKEY='/src/.ipyseskey'
export _IPQTLOG='.ipqt.log'
export _WRD_SETUPY='setup.py'
export _TEST_='(cdwrd && python "${_WRD_SETUPY}" test)'
export _CFG='/etc/development.ini'
export _EDITCFG_='/usr/local/bin/gvim --servername / --remote-tab-silent /etc/development.ini'
export _SHELL_='(cdwrd && "${_BIN}"/pshell "${_CFG}")'
export _SERVE_='(cdwrd && "${_BIN}"/pserve --app-name=main --reload --monitor-restart "${_CFG}")'
export _SVCFG='/etc/supervisord.conf'
export _SVCFG_=' -c "/etc/supervisord.conf"'
export __USRLOG='/Users/W/-usrlog.log'
export _USRLOG='-usrlog.log'
export _TERM_ID='#d5Mt6hRyasc'
eval '
cdhome () {
    # cdhome            -- cd $HOME /$@
    [ -z "$HOME" ] && echo "HOME is not set" && return 1
    cd "$HOME"${@:+"/${@}"}
}
_cd_HOME_complete () {
    local cur="$2";
    COMPREPLY=($(cdhome && compgen -d -- "${cur}" ))
}
cdh () {
    # cdh               -- cd $HOME
    cdhome $@
}
complete -o default -o nospace -F _cd_HOME_complete cdhome
complete -o default -o nospace -F _cd_HOME_complete cdh

';
eval '
cdwrk () {
    # cdwrk             -- cd $__WRK /$@
    [ -z "$__WRK" ] && echo "__WRK is not set" && return 1
    cd "$__WRK"${@:+"/${@}"}
}
_cd___WRK_complete () {
    local cur="$2";
    COMPREPLY=($(cdwrk && compgen -d -- "${cur}" ))
}
complete -o default -o nospace -F _cd___WRK_complete cdwrk

';
eval '
cddotfiles () {
    # cddotfiles        -- cd $__DOTFILES /$@
    [ -z "$__DOTFILES" ] && echo "__DOTFILES is not set" && return 1
    cd "$__DOTFILES"${@:+"/${@}"}
}
_cd___DOTFILES_complete () {
    local cur="$2";
    COMPREPLY=($(cddotfiles && compgen -d -- "${cur}" ))
}
cdd () {
    # cdd               -- cd $__DOTFILES
    cddotfiles $@
}
complete -o default -o nospace -F _cd___DOTFILES_complete cddotfiles
complete -o default -o nospace -F _cd___DOTFILES_complete cdd

';
eval '
cdprojecthome () {
    # cdprojecthome     -- cd $PROJECT_HOME /$@
    [ -z "$PROJECT_HOME" ] && echo "PROJECT_HOME is not set" && return 1
    cd "$PROJECT_HOME"${@:+"/${@}"}
}
_cd_PROJECT_HOME_complete () {
    local cur="$2";
    COMPREPLY=($(cdprojecthome && compgen -d -- "${cur}" ))
}
cdp () {
    # cdp               -- cd $PROJECT_HOME
    cdprojecthome $@
}
cdph () {
    # cdph              -- cd $PROJECT_HOME
    cdprojecthome $@
}
complete -o default -o nospace -F _cd_PROJECT_HOME_complete cdprojecthome
complete -o default -o nospace -F _cd_PROJECT_HOME_complete cdp
complete -o default -o nospace -F _cd_PROJECT_HOME_complete cdph

';
eval '
cdworkonhome () {
    # cdworkonhome      -- cd $WORKON_HOME /$@
    [ -z "$WORKON_HOME" ] && echo "WORKON_HOME is not set" && return 1
    cd "$WORKON_HOME"${@:+"/${@}"}
}
_cd_WORKON_HOME_complete () {
    local cur="$2";
    COMPREPLY=($(cdworkonhome && compgen -d -- "${cur}" ))
}
cdwh () {
    # cdwh              -- cd $WORKON_HOME
    cdworkonhome $@
}
cdve () {
    # cdve              -- cd $WORKON_HOME
    cdworkonhome $@
}
complete -o default -o nospace -F _cd_WORKON_HOME_complete cdworkonhome
complete -o default -o nospace -F _cd_WORKON_HOME_complete cdwh
complete -o default -o nospace -F _cd_WORKON_HOME_complete cdve

';
eval '
cdcondahome () {
    # cdcondahome       -- cd $CONDA_HOME /$@
    [ -z "$CONDA_HOME" ] && echo "CONDA_HOME is not set" && return 1
    cd "$CONDA_HOME"${@:+"/${@}"}
}
_cd_CONDA_HOME_complete () {
    local cur="$2";
    COMPREPLY=($(cdcondahome && compgen -d -- "${cur}" ))
}
cda () {
    # cda               -- cd $CONDA_HOME
    cdcondahome $@
}
cdce () {
    # cdce              -- cd $CONDA_HOME
    cdcondahome $@
}
complete -o default -o nospace -F _cd_CONDA_HOME_complete cdcondahome
complete -o default -o nospace -F _cd_CONDA_HOME_complete cda
complete -o default -o nospace -F _cd_CONDA_HOME_complete cdce

';
eval '
cdvirtualenv () {
    # cdvirtualenv      -- cd $VIRTUAL_ENV /$@
    [ -z "$VIRTUAL_ENV" ] && echo "VIRTUAL_ENV is not set" && return 1
    cd "$VIRTUAL_ENV"${@:+"/${@}"}
}
_cd_VIRTUAL_ENV_complete () {
    local cur="$2";
    COMPREPLY=($(cdvirtualenv && compgen -d -- "${cur}" ))
}
cdv () {
    # cdv               -- cd $VIRTUAL_ENV
    cdvirtualenv $@
}
complete -o default -o nospace -F _cd_VIRTUAL_ENV_complete cdvirtualenv
complete -o default -o nospace -F _cd_VIRTUAL_ENV_complete cdv

';
eval '
cdsrc () {
    # cdsrc             -- cd $_SRC /$@
    [ -z "$_SRC" ] && echo "_SRC is not set" && return 1
    cd "$_SRC"${@:+"/${@}"}
}
_cd__SRC_complete () {
    local cur="$2";
    COMPREPLY=($(cdsrc && compgen -d -- "${cur}" ))
}
cds () {
    # cds               -- cd $_SRC
    cdsrc $@
}
complete -o default -o nospace -F _cd__SRC_complete cdsrc
complete -o default -o nospace -F _cd__SRC_complete cds

';
eval '
cdwrd () {
    # cdwrd             -- cd $_WRD /$@
    [ -z "$_WRD" ] && echo "_WRD is not set" && return 1
    cd "$_WRD"${@:+"/${@}"}
}
_cd__WRD_complete () {
    local cur="$2";
    COMPREPLY=($(cdwrd && compgen -d -- "${cur}" ))
}
cdw () {
    # cdw               -- cd $_WRD
    cdwrd $@
}
complete -o default -o nospace -F _cd__WRD_complete cdwrd
complete -o default -o nospace -F _cd__WRD_complete cdw

';
eval '
cdbin () {
    # cdbin             -- cd $_BIN /$@
    [ -z "$_BIN" ] && echo "_BIN is not set" && return 1
    cd "$_BIN"${@:+"/${@}"}
}
_cd__BIN_complete () {
    local cur="$2";
    COMPREPLY=($(cdbin && compgen -d -- "${cur}" ))
}
cdb () {
    # cdb               -- cd $_BIN
    cdbin $@
}
complete -o default -o nospace -F _cd__BIN_complete cdbin
complete -o default -o nospace -F _cd__BIN_complete cdb

';
eval '
cdetc () {
    # cdetc             -- cd $_ETC /$@
    [ -z "$_ETC" ] && echo "_ETC is not set" && return 1
    cd "$_ETC"${@:+"/${@}"}
}
_cd__ETC_complete () {
    local cur="$2";
    COMPREPLY=($(cdetc && compgen -d -- "${cur}" ))
}
cde () {
    # cde               -- cd $_ETC
    cdetc $@
}
complete -o default -o nospace -F _cd__ETC_complete cdetc
complete -o default -o nospace -F _cd__ETC_complete cde

';
eval '
cdlib () {
    # cdlib             -- cd $_LIB /$@
    [ -z "$_LIB" ] && echo "_LIB is not set" && return 1
    cd "$_LIB"${@:+"/${@}"}
}
_cd__LIB_complete () {
    local cur="$2";
    COMPREPLY=($(cdlib && compgen -d -- "${cur}" ))
}
cdl () {
    # cdl               -- cd $_LIB
    cdlib $@
}
complete -o default -o nospace -F _cd__LIB_complete cdlib
complete -o default -o nospace -F _cd__LIB_complete cdl

';
eval '
cdlog () {
    # cdlog             -- cd $_LOG /$@
    [ -z "$_LOG" ] && echo "_LOG is not set" && return 1
    cd "$_LOG"${@:+"/${@}"}
}
_cd__LOG_complete () {
    local cur="$2";
    COMPREPLY=($(cdlog && compgen -d -- "${cur}" ))
}
complete -o default -o nospace -F _cd__LOG_complete cdlog

';
eval '
cdpylib () {
    # cdpylib           -- cd $_PYLIB /$@
    [ -z "$_PYLIB" ] && echo "_PYLIB is not set" && return 1
    cd "$_PYLIB"${@:+"/${@}"}
}
_cd__PYLIB_complete () {
    local cur="$2";
    COMPREPLY=($(cdpylib && compgen -d -- "${cur}" ))
}
complete -o default -o nospace -F _cd__PYLIB_complete cdpylib

';
eval '
cdpysite () {
    # cdpysite          -- cd $_PYSITE /$@
    [ -z "$_PYSITE" ] && echo "_PYSITE is not set" && return 1
    cd "$_PYSITE"${@:+"/${@}"}
}
_cd__PYSITE_complete () {
    local cur="$2";
    COMPREPLY=($(cdpysite && compgen -d -- "${cur}" ))
}
cdsitepackages () {
    # cdsitepackages    -- cd $_PYSITE
    cdpysite $@
}
complete -o default -o nospace -F _cd__PYSITE_complete cdpysite
complete -o default -o nospace -F _cd__PYSITE_complete cdsitepackages

';
eval '
cdvar () {
    # cdvar             -- cd $_VAR /$@
    [ -z "$_VAR" ] && echo "_VAR is not set" && return 1
    cd "$_VAR"${@:+"/${@}"}
}
_cd__VAR_complete () {
    local cur="$2";
    COMPREPLY=($(cdvar && compgen -d -- "${cur}" ))
}
complete -o default -o nospace -F _cd__VAR_complete cdvar

';
eval '
cdwww () {
    # cdwww             -- cd $_WWW /$@
    [ -z "$_WWW" ] && echo "_WWW is not set" && return 1
    cd "$_WWW"${@:+"/${@}"}
}
_cd__WWW_complete () {
    local cur="$2";
    COMPREPLY=($(cdwww && compgen -d -- "${cur}" ))
}
cdww () {
    # cdww              -- cd $_WWW
    cdwww $@
}
complete -o default -o nospace -F _cd__WWW_complete cdwww
complete -o default -o nospace -F _cd__WWW_complete cdww

';
eval 'cdls () {
    set | grep "^cd.*()" | cut -f1 -d" " #$@
}';
alias cdhelp="cat $__DOTFILES/etc/venv/venv.sh | pyline.py -r '^\\s*#+\\s+.*' 'rgx and l'"
eval 'edit- () {
    ${_EDIT_} $@
}';
alias gvim-='/usr/local/bin/gvim --servername / --remote-tab-silent'
eval 'ipskey () {
    (python -c "import os; print os.urandom(128).encode(\"base64\")" > "${_IPYSESKEY}" ) && chmod 0600 "${_IPYSESKEY}"; # $@
}';
eval 'ipnb () {
    ipython notebook --secure --Session.keyfile="${_IPYSESKEY}" --notebook-dir="${_NOTEBOOKS}" --deep-reload $@
}';
eval 'ipqt () {
    ipython qtconsole --secure --Session.keyfile="${_IPYSESKEY}" --logappend="${_IPQTLOG}" --deep-reload --pprint --colors=linux --ConsoleWidget.font_family="Monaco" --ConsoleWidget.font_size=11 $@
}';
eval 'grinv () {
    grin --follow $@ "${VIRTUAL_ENV}"
}';
eval 'grindv () {
    grind --follow $@ --dirs "${VIRTUAL_ENV}"
}';
eval 'grins () {
    grin --follow $@ "${_SRC}"
}';
eval 'grinds () {
    grind --follow $@ --dirs "${_SRC}"
}';
alias test-='(cdwrd && python "${_WRD_SETUPY}" test)'
alias testr-='reset && (cdwrd && python "${_WRD_SETUPY}" test)'
alias nose-='(cdwrd && nosetests)'
eval 'grinw () {
    grin --follow $@ "${_WRD}"
}';
eval 'grin- () {
    grin --follow $@ "${_WRD}"
}';
eval 'grindw () {
    grind --follow $@ --dirs "${_WRD}"
}';
eval 'grind- () {
    grind --follow $@ --dirs "${_WRD}"
}';
alias hgv-='hg view -R "${_WRD}"'
alias hgl-='hg -R "${_WRD}" log'
eval 'editcfg () {
    "${_EDITCFG_}" $@
}';
alias serve-='(cdwrd && "${_BIN}"/pserve --app-name=main --reload --monitor-restart "${_CFG}")'
alias shell-='(cdwrd && "${_BIN}"/pshell "${_CFG}")'
eval 'e () {
    ${_EDIT_} $@
}';
eval 'editp () {
    $GUIVIMBIN $VIMCONF $PROJECT_FILES $@
}';
eval 'makewrd () {
    (cdwrd && make $@)
}';
eval 'makew () {
    (cdwrd && make $@)
}';
eval 'make- () {
    (cdwrd && make $@)
}';
eval 'mw () {
    (cdwrd && make $@)
}';
alias ssv='supervisord -c "${_SVCFG}"'
alias sv='supervisorctl -c "${_SVCFG}"'
alias svt='sv tail -f'
alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
