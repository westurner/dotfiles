### venv.sh         -- Generated venv.sh

# generate with:
# venv.py

## cd functions
cdb () {
    # cdb()     -- cd $_BIN
    cd "${_BIN}"/$@
}
cdd () {
    # cdd()     -- cd $__DOTFILES
    cd "${__DOTFILES}"/$@
}
cde () {
    # cde()     -- cd $_ETC
    cd "${_ETC}"/$@
}
cdh () {
    # cdh()     -- cd $HOME
    cd "${HOME}"/$@
}
cdl () {
    # cdl()     -- cd $_LIB
    cd "${_LIB}"/$@
}
cdlog () {
    # cdlog()   -- cd $_LOG
    cd "${_LOG}"/$@
}
cdprojecthome () {
    # cdprojecthome()   -- cd $PROJECT_HOME
    cd "${PROJECT_HOME}"/$@
}
cdp () {
    # cdp()             -- cd $PROJECT_HOME
    cd "${PROJECT_HOME}"/$@
}
cdph () {
    # cdph()            -- cd $PROJECT_HOME
    cd "${PROJECT_HOME}"/$@
}
cdpylib () {
    # cdpylib() -- cd $_PYLIB
    cd "${_PYLIB}"/$@
}
cdpysite () {
    # cdpysite()-- cd $_PYSITE
    cd "${_PYSITE}"/$@
}
cds () {
    # cds()     -- cd $_SRC
    cd "${_SRC}"/$@
}
cdv () {
    # cdv()     -- cd $VIRTUAL_ENV
    cd "${VIRTUAL_ENV}"/$@
}
cdve () {
    # cdve()    -- cd $VIRTUAL_ENV
    cd "${VIRTUAL_ENV}"/$@
}
cdvar () {
    # cdvar()   -- cd $_VAR
    cd "${_VAR}"/$@
}
cdworkonhome () {
   # cdworkonhome()  -- cd $WORKON_HOME
   cd "${WORKON_HOME}"/$@
}
cdwh () {
    # cdwh      -- cd $WORKON_HOME
    cd "${WORKON_HOME}"/$@
}
cdwrd () {
    # cdwrd     -- cd $_WRD
    cd "${_WRD}"/$@
}
cdw () {
    # cdw()     -- cd $_WRD
    cd "${_WRD}"/$@
}
cdwrk () {
    # cdwrk()   -- cd $PROJECT_HOME
    cd "${PROJECT_HOME}/$@"
}
cdww () {
    # cdww()    -- cd $_WWW
    cd "${_WWW}"/$@
}
cdwww () {
    # cdwww()   -- cd $_WWW
    cd "${_WWW}"/$@
}

   ## cd function bash completion


_cd__WRK_complete () 
{ 
   local cur="$2";
   COMPREPLY=($(cdwrk && compgen -d -- "${cur}" ))
}
complete -o default -o nospace -F _cd__WRK_complete cdwrk

_cd___DOTFILES_complete () 
{ 
   local cur="$2";
   COMPREPLY=($(cdd && compgen -d -- "${cur}" ))
}
complete -o default -o nospace -F _cd___DOTFILES_complete cdd

_cd_PROJECT_HOME_complete () 
{ 
   local cur="$2";
   COMPREPLY=($(cdprojecthome && compgen -d -- "${cur}" ))
}
complete -o default -o nospace -F _cd_PROJECT_HOME_complete cdprojecthome
complete -o default -o nospace -F _cd_PROJECT_HOME_complete cdph
complete -o default -o nospace -F _cd_PROJECT_HOME_complete cdp

_cd_WORKON_HOME_complete () 
{ 
   local cur="$2";
   COMPREPLY=($(cdprojecthome && compgen -d -- "${cur}" ))
}
complete -o default -o nospace -F _cd_WORKON_HOME_complete cdworkonhome
complete -o default -o nospace -F _cd_WORKON_HOME_complete cdwh

_cd_VIRTUAL_ENV_complete () {
   local cur="$2";
   local venv="$VIRTUAL_ENV";
   if [ -z "${venv}" ]; then
      echo -e "\n# !ERR: VIRTUAL_ENV=\"\""
      COMPREPLY=(echo "")
      return 124
   else
      COMPREPLY=($(cdv && compgen -d -- "${cur}" ))
   fi
}
#complete -o default -o nospace -F _cdvirtualenv_complete cdvirtualenv
complete -o default -o nospace -F _cd_VIRTUAL_ENV_complete cdve
complete -o default -o nospace -F _cd_VIRTUAL_ENV_complete cdv


cdhelp() {
   echo "cdhelp"
}

_cdhelp_complete () {
   local cur="$2"
   echo $@
   COMPREPLY=($(cd ~ && compgen -d -- "${cur}" ))
}
complete -o default -o nospace -F _cdhelp_complete cdhelp
