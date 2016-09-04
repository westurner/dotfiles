
" ### venv.vim
" # Src: https://github.com/westurner/venv.vim

function! Cd_help()
" cdhelp()           -- list cd commands
    :verbose command Cd
endfunction
command! -nargs=* Cdhelp call Cd_help()


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
command! -nargs=* Cdhome call Cd_HOME(<f-args>)
"   :Cdh -- Cd_HOME()
command! -nargs=* Cdh call Cd_HOME(<f-args>)
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
command! -nargs=* LCdhome call LCd_HOME(<f-args>)
"   :LCdh -- LCd_HOME()
command! -nargs=* LCdh call LCd_HOME(<f-args>)
"   :Lcdhome -- LCd_HOME()
command! -nargs=* Lcdhome call LCd_HOME(<f-args>)
"   :Lcdh -- LCd_HOME()
command! -nargs=* Lcdh call LCd_HOME(<f-args>)

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
command! -nargs=* Cdwrk call Cd___WRK(<f-args>)
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
command! -nargs=* LCdwrk call LCd___WRK(<f-args>)
"   :Lcdwrk -- LCd___WRK()
command! -nargs=* Lcdwrk call LCd___WRK(<f-args>)

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
command! -nargs=* Cddotfiles call Cd___DOTFILES(<f-args>)
"   :Cdd -- Cd___DOTFILES()
command! -nargs=* Cdd call Cd___DOTFILES(<f-args>)
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
command! -nargs=* LCddotfiles call LCd___DOTFILES(<f-args>)
"   :LCdd -- LCd___DOTFILES()
command! -nargs=* LCdd call LCd___DOTFILES(<f-args>)
"   :Lcddotfiles -- LCd___DOTFILES()
command! -nargs=* Lcddotfiles call LCd___DOTFILES(<f-args>)
"   :Lcdd -- LCd___DOTFILES()
command! -nargs=* Lcdd call LCd___DOTFILES(<f-args>)

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
command! -nargs=* Cdprojecthome call Cd_PROJECT_HOME(<f-args>)
"   :Cdp -- Cd_PROJECT_HOME()
command! -nargs=* Cdp call Cd_PROJECT_HOME(<f-args>)
"   :Cdph -- Cd_PROJECT_HOME()
command! -nargs=* Cdph call Cd_PROJECT_HOME(<f-args>)
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
command! -nargs=* LCdprojecthome call LCd_PROJECT_HOME(<f-args>)
"   :LCdp -- LCd_PROJECT_HOME()
command! -nargs=* LCdp call LCd_PROJECT_HOME(<f-args>)
"   :LCdph -- LCd_PROJECT_HOME()
command! -nargs=* LCdph call LCd_PROJECT_HOME(<f-args>)
"   :Lcdprojecthome -- LCd_PROJECT_HOME()
command! -nargs=* Lcdprojecthome call LCd_PROJECT_HOME(<f-args>)
"   :Lcdp -- LCd_PROJECT_HOME()
command! -nargs=* Lcdp call LCd_PROJECT_HOME(<f-args>)
"   :Lcdph -- LCd_PROJECT_HOME()
command! -nargs=* Lcdph call LCd_PROJECT_HOME(<f-args>)

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
command! -nargs=* Cdworkonhome call Cd_WORKON_HOME(<f-args>)
"   :Cdwh -- Cd_WORKON_HOME()
command! -nargs=* Cdwh call Cd_WORKON_HOME(<f-args>)
"   :Cdve -- Cd_WORKON_HOME()
command! -nargs=* Cdve call Cd_WORKON_HOME(<f-args>)
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
command! -nargs=* LCdworkonhome call LCd_WORKON_HOME(<f-args>)
"   :LCdwh -- LCd_WORKON_HOME()
command! -nargs=* LCdwh call LCd_WORKON_HOME(<f-args>)
"   :LCdve -- LCd_WORKON_HOME()
command! -nargs=* LCdve call LCd_WORKON_HOME(<f-args>)
"   :Lcdworkonhome -- LCd_WORKON_HOME()
command! -nargs=* Lcdworkonhome call LCd_WORKON_HOME(<f-args>)
"   :Lcdwh -- LCd_WORKON_HOME()
command! -nargs=* Lcdwh call LCd_WORKON_HOME(<f-args>)
"   :Lcdve -- LCd_WORKON_HOME()
command! -nargs=* Lcdve call LCd_WORKON_HOME(<f-args>)

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
command! -nargs=* Cdcondaenvspath call Cd_CONDA_ENVS_PATH(<f-args>)
"   :Cda -- Cd_CONDA_ENVS_PATH()
command! -nargs=* Cda call Cd_CONDA_ENVS_PATH(<f-args>)
"   :Cdce -- Cd_CONDA_ENVS_PATH()
command! -nargs=* Cdce call Cd_CONDA_ENVS_PATH(<f-args>)
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
command! -nargs=* LCdcondaenvspath call LCd_CONDA_ENVS_PATH(<f-args>)
"   :LCda -- LCd_CONDA_ENVS_PATH()
command! -nargs=* LCda call LCd_CONDA_ENVS_PATH(<f-args>)
"   :LCdce -- LCd_CONDA_ENVS_PATH()
command! -nargs=* LCdce call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcdcondaenvspath -- LCd_CONDA_ENVS_PATH()
command! -nargs=* Lcdcondaenvspath call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcda -- LCd_CONDA_ENVS_PATH()
command! -nargs=* Lcda call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcdce -- LCd_CONDA_ENVS_PATH()
command! -nargs=* Lcdce call LCd_CONDA_ENVS_PATH(<f-args>)

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
command! -nargs=* Cdvirtualenv call Cd_VIRTUAL_ENV(<f-args>)
"   :Cdv -- Cd_VIRTUAL_ENV()
command! -nargs=* Cdv call Cd_VIRTUAL_ENV(<f-args>)
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
command! -nargs=* LCdvirtualenv call LCd_VIRTUAL_ENV(<f-args>)
"   :LCdv -- LCd_VIRTUAL_ENV()
command! -nargs=* LCdv call LCd_VIRTUAL_ENV(<f-args>)
"   :Lcdvirtualenv -- LCd_VIRTUAL_ENV()
command! -nargs=* Lcdvirtualenv call LCd_VIRTUAL_ENV(<f-args>)
"   :Lcdv -- LCd_VIRTUAL_ENV()
command! -nargs=* Lcdv call LCd_VIRTUAL_ENV(<f-args>)

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
command! -nargs=* Cdsrc call Cd__SRC(<f-args>)
"   :Cds -- Cd__SRC()
command! -nargs=* Cds call Cd__SRC(<f-args>)
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
command! -nargs=* LCdsrc call LCd__SRC(<f-args>)
"   :LCds -- LCd__SRC()
command! -nargs=* LCds call LCd__SRC(<f-args>)
"   :Lcdsrc -- LCd__SRC()
command! -nargs=* Lcdsrc call LCd__SRC(<f-args>)
"   :Lcds -- LCd__SRC()
command! -nargs=* Lcds call LCd__SRC(<f-args>)

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
command! -nargs=* Cdwrd call Cd__WRD(<f-args>)
"   :Cdw -- Cd__WRD()
command! -nargs=* Cdw call Cd__WRD(<f-args>)
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
command! -nargs=* LCdwrd call LCd__WRD(<f-args>)
"   :LCdw -- LCd__WRD()
command! -nargs=* LCdw call LCd__WRD(<f-args>)
"   :Lcdwrd -- LCd__WRD()
command! -nargs=* Lcdwrd call LCd__WRD(<f-args>)
"   :Lcdw -- LCd__WRD()
command! -nargs=* Lcdw call LCd__WRD(<f-args>)

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
command! -nargs=* Cdbin call Cd__BIN(<f-args>)
"   :Cdb -- Cd__BIN()
command! -nargs=* Cdb call Cd__BIN(<f-args>)
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
command! -nargs=* LCdbin call LCd__BIN(<f-args>)
"   :LCdb -- LCd__BIN()
command! -nargs=* LCdb call LCd__BIN(<f-args>)
"   :Lcdbin -- LCd__BIN()
command! -nargs=* Lcdbin call LCd__BIN(<f-args>)
"   :Lcdb -- LCd__BIN()
command! -nargs=* Lcdb call LCd__BIN(<f-args>)

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
command! -nargs=* Cdetc call Cd__ETC(<f-args>)
"   :Cde -- Cd__ETC()
command! -nargs=* Cde call Cd__ETC(<f-args>)
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
command! -nargs=* LCdetc call LCd__ETC(<f-args>)
"   :LCde -- LCd__ETC()
command! -nargs=* LCde call LCd__ETC(<f-args>)
"   :Lcdetc -- LCd__ETC()
command! -nargs=* Lcdetc call LCd__ETC(<f-args>)
"   :Lcde -- LCd__ETC()
command! -nargs=* Lcde call LCd__ETC(<f-args>)

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
command! -nargs=* Cdlib call Cd__LIB(<f-args>)
"   :Cdl -- Cd__LIB()
command! -nargs=* Cdl call Cd__LIB(<f-args>)
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
command! -nargs=* LCdlib call LCd__LIB(<f-args>)
"   :LCdl -- LCd__LIB()
command! -nargs=* LCdl call LCd__LIB(<f-args>)
"   :Lcdlib -- LCd__LIB()
command! -nargs=* Lcdlib call LCd__LIB(<f-args>)
"   :Lcdl -- LCd__LIB()
command! -nargs=* Lcdl call LCd__LIB(<f-args>)

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
command! -nargs=* Cdlog call Cd__LOG(<f-args>)
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
command! -nargs=* LCdlog call LCd__LOG(<f-args>)
"   :Lcdlog -- LCd__LOG()
command! -nargs=* Lcdlog call LCd__LOG(<f-args>)

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
command! -nargs=* Cdpylib call Cd__PYLIB(<f-args>)
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
command! -nargs=* LCdpylib call LCd__PYLIB(<f-args>)
"   :Lcdpylib -- LCd__PYLIB()
command! -nargs=* Lcdpylib call LCd__PYLIB(<f-args>)

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
command! -nargs=* Cdpysite call Cd__PYSITE(<f-args>)
"   :Cdsitepackages -- Cd__PYSITE()
command! -nargs=* Cdsitepackages call Cd__PYSITE(<f-args>)
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
command! -nargs=* LCdpysite call LCd__PYSITE(<f-args>)
"   :LCdsitepackages -- LCd__PYSITE()
command! -nargs=* LCdsitepackages call LCd__PYSITE(<f-args>)
"   :Lcdpysite -- LCd__PYSITE()
command! -nargs=* Lcdpysite call LCd__PYSITE(<f-args>)
"   :Lcdsitepackages -- LCd__PYSITE()
command! -nargs=* Lcdsitepackages call LCd__PYSITE(<f-args>)

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
command! -nargs=* Cdvar call Cd__VAR(<f-args>)
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
command! -nargs=* LCdvar call LCd__VAR(<f-args>)
"   :Lcdvar -- LCd__VAR()
command! -nargs=* Lcdvar call LCd__VAR(<f-args>)

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
command! -nargs=* Cdwww call Cd__WWW(<f-args>)
"   :Cdww -- Cd__WWW()
command! -nargs=* Cdww call Cd__WWW(<f-args>)
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
command! -nargs=* LCdwww call LCd__WWW(<f-args>)
"   :LCdww -- LCd__WWW()
command! -nargs=* LCdww call LCd__WWW(<f-args>)
"   :Lcdwww -- LCd__WWW()
command! -nargs=* Lcdwww call LCd__WWW(<f-args>)
"   :Lcdww -- LCd__WWW()
command! -nargs=* Lcdww call LCd__WWW(<f-args>)

