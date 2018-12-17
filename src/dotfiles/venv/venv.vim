
" ### venv.vim
" # Src: https://github.com/westurner/venv.vim

function! Cd_help()
" cdhelp()           -- list cd commands
    :verbose command Cd
endfunction
command! -nargs=0 Cdhelp call Cd_help()


function! Cd_HOME(...)
" Cd_HOME()  -- cd $HOME/$1
    if a:0 > 0
       let pathname = join([$HOME, a:1], "/")
    else
       let pathname = "$HOME"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdhome -- Cd_HOME()
command! -nargs=1 Cdhome call Cd_HOME(<f-args>)
"   :Cdh -- Cd_HOME()
command! -nargs=1 Cdh call Cd_HOME(<f-args>)
function! LCd_HOME(...)
" LCd_HOME()  -- cd $HOME/$1
    if a:0 > 0
       let pathname = join([$HOME, a:1], "/")
    else
       let pathname = "$HOME"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdhome -- LCd_HOME()
command! -nargs=1 LCdhome call LCd_HOME(<f-args>)
"   :LCdh -- LCd_HOME()
command! -nargs=1 LCdh call LCd_HOME(<f-args>)
"   :Lcdhome -- LCd_HOME()
command! -nargs=1 Lcdhome call LCd_HOME(<f-args>)
"   :Lcdh -- LCd_HOME()
command! -nargs=1 Lcdh call LCd_HOME(<f-args>)

function! Cd___WRK(...)
" Cd___WRK()  -- cd $__WRK/$1
    if a:0 > 0
       let pathname = join([$__WRK, a:1], "/")
    else
       let pathname = "$__WRK"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdwrk -- Cd___WRK()
command! -nargs=1 Cdwrk call Cd___WRK(<f-args>)
function! LCd___WRK(...)
" LCd___WRK()  -- cd $__WRK/$1
    if a:0 > 0
       let pathname = join([$__WRK, a:1], "/")
    else
       let pathname = "$__WRK"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdwrk -- LCd___WRK()
command! -nargs=1 LCdwrk call LCd___WRK(<f-args>)
"   :Lcdwrk -- LCd___WRK()
command! -nargs=1 Lcdwrk call LCd___WRK(<f-args>)

function! Cd___DOTFILES(...)
" Cd___DOTFILES()  -- cd $__DOTFILES/$1
    if a:0 > 0
       let pathname = join([$__DOTFILES, a:1], "/")
    else
       let pathname = "$__DOTFILES"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cddotfiles -- Cd___DOTFILES()
command! -nargs=1 Cddotfiles call Cd___DOTFILES(<f-args>)
"   :Cdd -- Cd___DOTFILES()
command! -nargs=1 Cdd call Cd___DOTFILES(<f-args>)
function! LCd___DOTFILES(...)
" LCd___DOTFILES()  -- cd $__DOTFILES/$1
    if a:0 > 0
       let pathname = join([$__DOTFILES, a:1], "/")
    else
       let pathname = "$__DOTFILES"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCddotfiles -- LCd___DOTFILES()
command! -nargs=1 LCddotfiles call LCd___DOTFILES(<f-args>)
"   :LCdd -- LCd___DOTFILES()
command! -nargs=1 LCdd call LCd___DOTFILES(<f-args>)
"   :Lcddotfiles -- LCd___DOTFILES()
command! -nargs=1 Lcddotfiles call LCd___DOTFILES(<f-args>)
"   :Lcdd -- LCd___DOTFILES()
command! -nargs=1 Lcdd call LCd___DOTFILES(<f-args>)

function! Cd_PROJECT_HOME(...)
" Cd_PROJECT_HOME()  -- cd $PROJECT_HOME/$1
    if a:0 > 0
       let pathname = join([$PROJECT_HOME, a:1], "/")
    else
       let pathname = "$PROJECT_HOME"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdprojecthome -- Cd_PROJECT_HOME()
command! -nargs=1 Cdprojecthome call Cd_PROJECT_HOME(<f-args>)
"   :Cdp -- Cd_PROJECT_HOME()
command! -nargs=1 Cdp call Cd_PROJECT_HOME(<f-args>)
"   :Cdph -- Cd_PROJECT_HOME()
command! -nargs=1 Cdph call Cd_PROJECT_HOME(<f-args>)
function! LCd_PROJECT_HOME(...)
" LCd_PROJECT_HOME()  -- cd $PROJECT_HOME/$1
    if a:0 > 0
       let pathname = join([$PROJECT_HOME, a:1], "/")
    else
       let pathname = "$PROJECT_HOME"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdprojecthome -- LCd_PROJECT_HOME()
command! -nargs=1 LCdprojecthome call LCd_PROJECT_HOME(<f-args>)
"   :LCdp -- LCd_PROJECT_HOME()
command! -nargs=1 LCdp call LCd_PROJECT_HOME(<f-args>)
"   :LCdph -- LCd_PROJECT_HOME()
command! -nargs=1 LCdph call LCd_PROJECT_HOME(<f-args>)
"   :Lcdprojecthome -- LCd_PROJECT_HOME()
command! -nargs=1 Lcdprojecthome call LCd_PROJECT_HOME(<f-args>)
"   :Lcdp -- LCd_PROJECT_HOME()
command! -nargs=1 Lcdp call LCd_PROJECT_HOME(<f-args>)
"   :Lcdph -- LCd_PROJECT_HOME()
command! -nargs=1 Lcdph call LCd_PROJECT_HOME(<f-args>)

function! Cd_WORKON_HOME(...)
" Cd_WORKON_HOME()  -- cd $WORKON_HOME/$1
    if a:0 > 0
       let pathname = join([$WORKON_HOME, a:1], "/")
    else
       let pathname = "$WORKON_HOME"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdworkonhome -- Cd_WORKON_HOME()
command! -nargs=1 Cdworkonhome call Cd_WORKON_HOME(<f-args>)
"   :Cdwh -- Cd_WORKON_HOME()
command! -nargs=1 Cdwh call Cd_WORKON_HOME(<f-args>)
"   :Cdve -- Cd_WORKON_HOME()
command! -nargs=1 Cdve call Cd_WORKON_HOME(<f-args>)
function! LCd_WORKON_HOME(...)
" LCd_WORKON_HOME()  -- cd $WORKON_HOME/$1
    if a:0 > 0
       let pathname = join([$WORKON_HOME, a:1], "/")
    else
       let pathname = "$WORKON_HOME"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdworkonhome -- LCd_WORKON_HOME()
command! -nargs=1 LCdworkonhome call LCd_WORKON_HOME(<f-args>)
"   :LCdwh -- LCd_WORKON_HOME()
command! -nargs=1 LCdwh call LCd_WORKON_HOME(<f-args>)
"   :LCdve -- LCd_WORKON_HOME()
command! -nargs=1 LCdve call LCd_WORKON_HOME(<f-args>)
"   :Lcdworkonhome -- LCd_WORKON_HOME()
command! -nargs=1 Lcdworkonhome call LCd_WORKON_HOME(<f-args>)
"   :Lcdwh -- LCd_WORKON_HOME()
command! -nargs=1 Lcdwh call LCd_WORKON_HOME(<f-args>)
"   :Lcdve -- LCd_WORKON_HOME()
command! -nargs=1 Lcdve call LCd_WORKON_HOME(<f-args>)

function! Cd_CONDA_ENVS_PATH(...)
" Cd_CONDA_ENVS_PATH()  -- cd $CONDA_ENVS_PATH/$1
    if a:0 > 0
       let pathname = join([$CONDA_ENVS_PATH, a:1], "/")
    else
       let pathname = "$CONDA_ENVS_PATH"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdcondaenvspath -- Cd_CONDA_ENVS_PATH()
command! -nargs=1 Cdcondaenvspath call Cd_CONDA_ENVS_PATH(<f-args>)
"   :Cda -- Cd_CONDA_ENVS_PATH()
command! -nargs=1 Cda call Cd_CONDA_ENVS_PATH(<f-args>)
"   :Cdce -- Cd_CONDA_ENVS_PATH()
command! -nargs=1 Cdce call Cd_CONDA_ENVS_PATH(<f-args>)
function! LCd_CONDA_ENVS_PATH(...)
" LCd_CONDA_ENVS_PATH()  -- cd $CONDA_ENVS_PATH/$1
    if a:0 > 0
       let pathname = join([$CONDA_ENVS_PATH, a:1], "/")
    else
       let pathname = "$CONDA_ENVS_PATH"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdcondaenvspath -- LCd_CONDA_ENVS_PATH()
command! -nargs=1 LCdcondaenvspath call LCd_CONDA_ENVS_PATH(<f-args>)
"   :LCda -- LCd_CONDA_ENVS_PATH()
command! -nargs=1 LCda call LCd_CONDA_ENVS_PATH(<f-args>)
"   :LCdce -- LCd_CONDA_ENVS_PATH()
command! -nargs=1 LCdce call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcdcondaenvspath -- LCd_CONDA_ENVS_PATH()
command! -nargs=1 Lcdcondaenvspath call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcda -- LCd_CONDA_ENVS_PATH()
command! -nargs=1 Lcda call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcdce -- LCd_CONDA_ENVS_PATH()
command! -nargs=1 Lcdce call LCd_CONDA_ENVS_PATH(<f-args>)

function! Cd_VIRTUAL_ENV(...)
" Cd_VIRTUAL_ENV()  -- cd $VIRTUAL_ENV/$1
    if a:0 > 0
       let pathname = join([$VIRTUAL_ENV, a:1], "/")
    else
       let pathname = "$VIRTUAL_ENV"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdvirtualenv -- Cd_VIRTUAL_ENV()
command! -nargs=1 Cdvirtualenv call Cd_VIRTUAL_ENV(<f-args>)
"   :Cdv -- Cd_VIRTUAL_ENV()
command! -nargs=1 Cdv call Cd_VIRTUAL_ENV(<f-args>)
function! LCd_VIRTUAL_ENV(...)
" LCd_VIRTUAL_ENV()  -- cd $VIRTUAL_ENV/$1
    if a:0 > 0
       let pathname = join([$VIRTUAL_ENV, a:1], "/")
    else
       let pathname = "$VIRTUAL_ENV"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdvirtualenv -- LCd_VIRTUAL_ENV()
command! -nargs=1 LCdvirtualenv call LCd_VIRTUAL_ENV(<f-args>)
"   :LCdv -- LCd_VIRTUAL_ENV()
command! -nargs=1 LCdv call LCd_VIRTUAL_ENV(<f-args>)
"   :Lcdvirtualenv -- LCd_VIRTUAL_ENV()
command! -nargs=1 Lcdvirtualenv call LCd_VIRTUAL_ENV(<f-args>)
"   :Lcdv -- LCd_VIRTUAL_ENV()
command! -nargs=1 Lcdv call LCd_VIRTUAL_ENV(<f-args>)

function! Cd__SRC(...)
" Cd__SRC()  -- cd $_SRC/$1
    if a:0 > 0
       let pathname = join([$_SRC, a:1], "/")
    else
       let pathname = "$_SRC"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdsrc -- Cd__SRC()
command! -nargs=1 Cdsrc call Cd__SRC(<f-args>)
"   :Cds -- Cd__SRC()
command! -nargs=1 Cds call Cd__SRC(<f-args>)
function! LCd__SRC(...)
" LCd__SRC()  -- cd $_SRC/$1
    if a:0 > 0
       let pathname = join([$_SRC, a:1], "/")
    else
       let pathname = "$_SRC"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdsrc -- LCd__SRC()
command! -nargs=1 LCdsrc call LCd__SRC(<f-args>)
"   :LCds -- LCd__SRC()
command! -nargs=1 LCds call LCd__SRC(<f-args>)
"   :Lcdsrc -- LCd__SRC()
command! -nargs=1 Lcdsrc call LCd__SRC(<f-args>)
"   :Lcds -- LCd__SRC()
command! -nargs=1 Lcds call LCd__SRC(<f-args>)

function! Cd__WRD(...)
" Cd__WRD()  -- cd $_WRD/$1
    if a:0 > 0
       let pathname = join([$_WRD, a:1], "/")
    else
       let pathname = "$_WRD"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdwrd -- Cd__WRD()
command! -nargs=1 Cdwrd call Cd__WRD(<f-args>)
"   :Cdw -- Cd__WRD()
command! -nargs=1 Cdw call Cd__WRD(<f-args>)
function! LCd__WRD(...)
" LCd__WRD()  -- cd $_WRD/$1
    if a:0 > 0
       let pathname = join([$_WRD, a:1], "/")
    else
       let pathname = "$_WRD"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdwrd -- LCd__WRD()
command! -nargs=1 LCdwrd call LCd__WRD(<f-args>)
"   :LCdw -- LCd__WRD()
command! -nargs=1 LCdw call LCd__WRD(<f-args>)
"   :Lcdwrd -- LCd__WRD()
command! -nargs=1 Lcdwrd call LCd__WRD(<f-args>)
"   :Lcdw -- LCd__WRD()
command! -nargs=1 Lcdw call LCd__WRD(<f-args>)

function! Cd__BIN(...)
" Cd__BIN()  -- cd $_BIN/$1
    if a:0 > 0
       let pathname = join([$_BIN, a:1], "/")
    else
       let pathname = "$_BIN"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdbin -- Cd__BIN()
command! -nargs=1 Cdbin call Cd__BIN(<f-args>)
"   :Cdb -- Cd__BIN()
command! -nargs=1 Cdb call Cd__BIN(<f-args>)
function! LCd__BIN(...)
" LCd__BIN()  -- cd $_BIN/$1
    if a:0 > 0
       let pathname = join([$_BIN, a:1], "/")
    else
       let pathname = "$_BIN"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdbin -- LCd__BIN()
command! -nargs=1 LCdbin call LCd__BIN(<f-args>)
"   :LCdb -- LCd__BIN()
command! -nargs=1 LCdb call LCd__BIN(<f-args>)
"   :Lcdbin -- LCd__BIN()
command! -nargs=1 Lcdbin call LCd__BIN(<f-args>)
"   :Lcdb -- LCd__BIN()
command! -nargs=1 Lcdb call LCd__BIN(<f-args>)

function! Cd__ETC(...)
" Cd__ETC()  -- cd $_ETC/$1
    if a:0 > 0
       let pathname = join([$_ETC, a:1], "/")
    else
       let pathname = "$_ETC"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdetc -- Cd__ETC()
command! -nargs=1 Cdetc call Cd__ETC(<f-args>)
"   :Cde -- Cd__ETC()
command! -nargs=1 Cde call Cd__ETC(<f-args>)
function! LCd__ETC(...)
" LCd__ETC()  -- cd $_ETC/$1
    if a:0 > 0
       let pathname = join([$_ETC, a:1], "/")
    else
       let pathname = "$_ETC"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdetc -- LCd__ETC()
command! -nargs=1 LCdetc call LCd__ETC(<f-args>)
"   :LCde -- LCd__ETC()
command! -nargs=1 LCde call LCd__ETC(<f-args>)
"   :Lcdetc -- LCd__ETC()
command! -nargs=1 Lcdetc call LCd__ETC(<f-args>)
"   :Lcde -- LCd__ETC()
command! -nargs=1 Lcde call LCd__ETC(<f-args>)

function! Cd__LIB(...)
" Cd__LIB()  -- cd $_LIB/$1
    if a:0 > 0
       let pathname = join([$_LIB, a:1], "/")
    else
       let pathname = "$_LIB"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdlib -- Cd__LIB()
command! -nargs=1 Cdlib call Cd__LIB(<f-args>)
"   :Cdl -- Cd__LIB()
command! -nargs=1 Cdl call Cd__LIB(<f-args>)
function! LCd__LIB(...)
" LCd__LIB()  -- cd $_LIB/$1
    if a:0 > 0
       let pathname = join([$_LIB, a:1], "/")
    else
       let pathname = "$_LIB"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdlib -- LCd__LIB()
command! -nargs=1 LCdlib call LCd__LIB(<f-args>)
"   :LCdl -- LCd__LIB()
command! -nargs=1 LCdl call LCd__LIB(<f-args>)
"   :Lcdlib -- LCd__LIB()
command! -nargs=1 Lcdlib call LCd__LIB(<f-args>)
"   :Lcdl -- LCd__LIB()
command! -nargs=1 Lcdl call LCd__LIB(<f-args>)

function! Cd__LOG(...)
" Cd__LOG()  -- cd $_LOG/$1
    if a:0 > 0
       let pathname = join([$_LOG, a:1], "/")
    else
       let pathname = "$_LOG"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdlog -- Cd__LOG()
command! -nargs=1 Cdlog call Cd__LOG(<f-args>)
function! LCd__LOG(...)
" LCd__LOG()  -- cd $_LOG/$1
    if a:0 > 0
       let pathname = join([$_LOG, a:1], "/")
    else
       let pathname = "$_LOG"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdlog -- LCd__LOG()
command! -nargs=1 LCdlog call LCd__LOG(<f-args>)
"   :Lcdlog -- LCd__LOG()
command! -nargs=1 Lcdlog call LCd__LOG(<f-args>)

function! Cd__PYLIB(...)
" Cd__PYLIB()  -- cd $_PYLIB/$1
    if a:0 > 0
       let pathname = join([$_PYLIB, a:1], "/")
    else
       let pathname = "$_PYLIB"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdpylib -- Cd__PYLIB()
command! -nargs=1 Cdpylib call Cd__PYLIB(<f-args>)
function! LCd__PYLIB(...)
" LCd__PYLIB()  -- cd $_PYLIB/$1
    if a:0 > 0
       let pathname = join([$_PYLIB, a:1], "/")
    else
       let pathname = "$_PYLIB"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdpylib -- LCd__PYLIB()
command! -nargs=1 LCdpylib call LCd__PYLIB(<f-args>)
"   :Lcdpylib -- LCd__PYLIB()
command! -nargs=1 Lcdpylib call LCd__PYLIB(<f-args>)

function! Cd__PYSITE(...)
" Cd__PYSITE()  -- cd $_PYSITE/$1
    if a:0 > 0
       let pathname = join([$_PYSITE, a:1], "/")
    else
       let pathname = "$_PYSITE"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdpysite -- Cd__PYSITE()
command! -nargs=1 Cdpysite call Cd__PYSITE(<f-args>)
"   :Cdsitepackages -- Cd__PYSITE()
command! -nargs=1 Cdsitepackages call Cd__PYSITE(<f-args>)
function! LCd__PYSITE(...)
" LCd__PYSITE()  -- cd $_PYSITE/$1
    if a:0 > 0
       let pathname = join([$_PYSITE, a:1], "/")
    else
       let pathname = "$_PYSITE"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdpysite -- LCd__PYSITE()
command! -nargs=1 LCdpysite call LCd__PYSITE(<f-args>)
"   :LCdsitepackages -- LCd__PYSITE()
command! -nargs=1 LCdsitepackages call LCd__PYSITE(<f-args>)
"   :Lcdpysite -- LCd__PYSITE()
command! -nargs=1 Lcdpysite call LCd__PYSITE(<f-args>)
"   :Lcdsitepackages -- LCd__PYSITE()
command! -nargs=1 Lcdsitepackages call LCd__PYSITE(<f-args>)

function! Cd__VAR(...)
" Cd__VAR()  -- cd $_VAR/$1
    if a:0 > 0
       let pathname = join([$_VAR, a:1], "/")
    else
       let pathname = "$_VAR"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdvar -- Cd__VAR()
command! -nargs=1 Cdvar call Cd__VAR(<f-args>)
function! LCd__VAR(...)
" LCd__VAR()  -- cd $_VAR/$1
    if a:0 > 0
       let pathname = join([$_VAR, a:1], "/")
    else
       let pathname = "$_VAR"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdvar -- LCd__VAR()
command! -nargs=1 LCdvar call LCd__VAR(<f-args>)
"   :Lcdvar -- LCd__VAR()
command! -nargs=1 Lcdvar call LCd__VAR(<f-args>)

function! Cd__WWW(...)
" Cd__WWW()  -- cd $_WWW/$1
    if a:0 > 0
       let pathname = join([$_WWW, a:1], "/")
    else
       let pathname = "$_WWW"
    endif
    execute 'cd' pathname 
    pwd
endfunction
"   :Cdwww -- Cd__WWW()
command! -nargs=1 Cdwww call Cd__WWW(<f-args>)
"   :Cdww -- Cd__WWW()
command! -nargs=1 Cdww call Cd__WWW(<f-args>)
function! LCd__WWW(...)
" LCd__WWW()  -- cd $_WWW/$1
    if a:0 > 0
       let pathname = join([$_WWW, a:1], "/")
    else
       let pathname = "$_WWW"
    endif
    execute 'lcd' pathname 
    pwd
endfunction
"   :LCdwww -- LCd__WWW()
command! -nargs=1 LCdwww call LCd__WWW(<f-args>)
"   :LCdww -- LCd__WWW()
command! -nargs=1 LCdww call LCd__WWW(<f-args>)
"   :Lcdwww -- LCd__WWW()
command! -nargs=1 Lcdwww call LCd__WWW(<f-args>)
"   :Lcdww -- LCd__WWW()
command! -nargs=1 Lcdww call LCd__WWW(<f-args>)

