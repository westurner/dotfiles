
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

