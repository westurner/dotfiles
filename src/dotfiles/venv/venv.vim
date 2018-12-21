
" ### venv.vim
" # Src: https://github.com/westurner/venv.vim

function! Cd_help()
" cdhelp()           -- list cd commands
    :verbose command Cd
endfunction
command! -nargs=0 Cdhelp call Cd_help()

function! ListDirsOrFiles(path, ArgLead, ...)
    let dirsonly = ((a:0 > 0) ? 1 : 0)
    let _glob = '' . a:ArgLead . ((a:0 > 0) ? '*/' : '*')
    execute 'lcd' a:path
    if dirsonly ==? 1
        "let output = map(sort(filter(globpath('.', _glob, 0, 1), 'isdirectory(v:val)'), 'i'), 'v:val[2:] . "/"')
        let output = map(sort(globpath('.', _glob, 0, 1), 'i'), 'v:val[2:]')
    elseif dirsonly ==? 0
        let output = map(sort(globpath('.', _glob, 0, 1), 'i'), 'v:val[2:] . (isdirectory(v:val) ? "/" : "")')
    endif
    execute 'lcd -'
    return output
endfunction

function! Cdhere(...)
"  :Cdhere() -- cd to here (this dir, dirname(__file__))    [cd %:p:h]
    let _path = expand('%:p:h') . (a:0 > 0 ? ('/' . a:1) : '')
    execute 'cd' _path 
    pwd
endfunction
function! Compl_Cdhere(ArgLead, ...)
    return ListDirsOrFiles(expand('%:p:h'), a:ArgLead, 1)
endfor
endfunction
command! -nargs=* -complete=customlist,Compl_Cdhere Cdhere call Cdhere(<f-args>)
command! -nargs=* -complete=customlist,Compl_Cdhere CDhere call Cdhere(<f-args>)

function! Lcdhere(...)
"  :Lcdhere() -- cd to here (this dir, dirname(__file__))  [lcd %:p:h]
    let _path = expand('%:p:h') . (a:0 > 0 ? ('/' . a:1) : '')
    execute 'lcd' _path 
    pwd
endfunction
command! -nargs=* -complete=customlist,Compl_Cdhere Lcdhere call Lcdhere(<f-args>)
command! -nargs=* -complete=customlist,Compl_Cdhere LCdhere call Lcdhere(<f-args>)


function! Cd_HOME(...)
" Cd_HOME()  -- cd $HOME/$1
    if $HOME ==? ''
        echoerr "$HOME is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$HOME, a:1], "/")
    else
       let pathname = "$HOME"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd_HOME(ArgLead, ...)
    return ListDirsOrFiles($HOME, a:ArgLead, 1)
endfunction
"   :Cdhome -- Cd_HOME()
command! -nargs=* -complete=customlist,Compl_Cd_HOME Cdhome call Cd_HOME(<f-args>)
"   :Cdh -- Cd_HOME()
command! -nargs=* -complete=customlist,Compl_Cd_HOME Cdh call Cd_HOME(<f-args>)
function! LCd_HOME(...)
" LCd_HOME()  -- cd $HOME/$1
    if $HOME ==? ''
        echoerr "$HOME is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$HOME, a:1], "/")
    else
       let pathname = "$HOME"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd_HOME(ArgLead, ...)
    return ListDirsOrFiles($HOME, a:ArgLead, 1)
endfunction
"   :LCdhome -- LCd_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_HOME LCdhome call LCd_HOME(<f-args>)
"   :LCdh -- LCd_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_HOME LCdh call LCd_HOME(<f-args>)
"   :Lcdhome -- LCd_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_HOME Lcdhome call LCd_HOME(<f-args>)
"   :Lcdh -- LCd_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_HOME Lcdh call LCd_HOME(<f-args>)

function! Cd___WRK(...)
" Cd___WRK()  -- cd $__WRK/$1
    if $__WRK ==? ''
        echoerr "$__WRK is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$__WRK, a:1], "/")
    else
       let pathname = "$__WRK"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd___WRK(ArgLead, ...)
    return ListDirsOrFiles($__WRK, a:ArgLead, 1)
endfunction
"   :Cdwrk -- Cd___WRK()
command! -nargs=* -complete=customlist,Compl_Cd___WRK Cdwrk call Cd___WRK(<f-args>)
function! LCd___WRK(...)
" LCd___WRK()  -- cd $__WRK/$1
    if $__WRK ==? ''
        echoerr "$__WRK is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$__WRK, a:1], "/")
    else
       let pathname = "$__WRK"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd___WRK(ArgLead, ...)
    return ListDirsOrFiles($__WRK, a:ArgLead, 1)
endfunction
"   :LCdwrk -- LCd___WRK()
command! -nargs=* -complete=customlist,Compl_LCd___WRK LCdwrk call LCd___WRK(<f-args>)
"   :Lcdwrk -- LCd___WRK()
command! -nargs=* -complete=customlist,Compl_LCd___WRK Lcdwrk call LCd___WRK(<f-args>)

function! Cd___DOTFILES(...)
" Cd___DOTFILES()  -- cd $__DOTFILES/$1
    if $__DOTFILES ==? ''
        echoerr "$__DOTFILES is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$__DOTFILES, a:1], "/")
    else
       let pathname = "$__DOTFILES"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd___DOTFILES(ArgLead, ...)
    return ListDirsOrFiles($__DOTFILES, a:ArgLead, 1)
endfunction
"   :Cddotfiles -- Cd___DOTFILES()
command! -nargs=* -complete=customlist,Compl_Cd___DOTFILES Cddotfiles call Cd___DOTFILES(<f-args>)
"   :Cdd -- Cd___DOTFILES()
command! -nargs=* -complete=customlist,Compl_Cd___DOTFILES Cdd call Cd___DOTFILES(<f-args>)
function! LCd___DOTFILES(...)
" LCd___DOTFILES()  -- cd $__DOTFILES/$1
    if $__DOTFILES ==? ''
        echoerr "$__DOTFILES is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$__DOTFILES, a:1], "/")
    else
       let pathname = "$__DOTFILES"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd___DOTFILES(ArgLead, ...)
    return ListDirsOrFiles($__DOTFILES, a:ArgLead, 1)
endfunction
"   :LCddotfiles -- LCd___DOTFILES()
command! -nargs=* -complete=customlist,Compl_LCd___DOTFILES LCddotfiles call LCd___DOTFILES(<f-args>)
"   :LCdd -- LCd___DOTFILES()
command! -nargs=* -complete=customlist,Compl_LCd___DOTFILES LCdd call LCd___DOTFILES(<f-args>)
"   :Lcddotfiles -- LCd___DOTFILES()
command! -nargs=* -complete=customlist,Compl_LCd___DOTFILES Lcddotfiles call LCd___DOTFILES(<f-args>)
"   :Lcdd -- LCd___DOTFILES()
command! -nargs=* -complete=customlist,Compl_LCd___DOTFILES Lcdd call LCd___DOTFILES(<f-args>)

function! Cd_PROJECT_HOME(...)
" Cd_PROJECT_HOME()  -- cd $PROJECT_HOME/$1
    if $PROJECT_HOME ==? ''
        echoerr "$PROJECT_HOME is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$PROJECT_HOME, a:1], "/")
    else
       let pathname = "$PROJECT_HOME"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd_PROJECT_HOME(ArgLead, ...)
    return ListDirsOrFiles($PROJECT_HOME, a:ArgLead, 1)
endfunction
"   :Cdprojecthome -- Cd_PROJECT_HOME()
command! -nargs=* -complete=customlist,Compl_Cd_PROJECT_HOME Cdprojecthome call Cd_PROJECT_HOME(<f-args>)
"   :Cdp -- Cd_PROJECT_HOME()
command! -nargs=* -complete=customlist,Compl_Cd_PROJECT_HOME Cdp call Cd_PROJECT_HOME(<f-args>)
"   :Cdph -- Cd_PROJECT_HOME()
command! -nargs=* -complete=customlist,Compl_Cd_PROJECT_HOME Cdph call Cd_PROJECT_HOME(<f-args>)
function! LCd_PROJECT_HOME(...)
" LCd_PROJECT_HOME()  -- cd $PROJECT_HOME/$1
    if $PROJECT_HOME ==? ''
        echoerr "$PROJECT_HOME is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$PROJECT_HOME, a:1], "/")
    else
       let pathname = "$PROJECT_HOME"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd_PROJECT_HOME(ArgLead, ...)
    return ListDirsOrFiles($PROJECT_HOME, a:ArgLead, 1)
endfunction
"   :LCdprojecthome -- LCd_PROJECT_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME LCdprojecthome call LCd_PROJECT_HOME(<f-args>)
"   :LCdp -- LCd_PROJECT_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME LCdp call LCd_PROJECT_HOME(<f-args>)
"   :LCdph -- LCd_PROJECT_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME LCdph call LCd_PROJECT_HOME(<f-args>)
"   :Lcdprojecthome -- LCd_PROJECT_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME Lcdprojecthome call LCd_PROJECT_HOME(<f-args>)
"   :Lcdp -- LCd_PROJECT_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME Lcdp call LCd_PROJECT_HOME(<f-args>)
"   :Lcdph -- LCd_PROJECT_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME Lcdph call LCd_PROJECT_HOME(<f-args>)

function! Cd_WORKON_HOME(...)
" Cd_WORKON_HOME()  -- cd $WORKON_HOME/$1
    if $WORKON_HOME ==? ''
        echoerr "$WORKON_HOME is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$WORKON_HOME, a:1], "/")
    else
       let pathname = "$WORKON_HOME"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd_WORKON_HOME(ArgLead, ...)
    return ListDirsOrFiles($WORKON_HOME, a:ArgLead, 1)
endfunction
"   :Cdworkonhome -- Cd_WORKON_HOME()
command! -nargs=* -complete=customlist,Compl_Cd_WORKON_HOME Cdworkonhome call Cd_WORKON_HOME(<f-args>)
"   :Cdwh -- Cd_WORKON_HOME()
command! -nargs=* -complete=customlist,Compl_Cd_WORKON_HOME Cdwh call Cd_WORKON_HOME(<f-args>)
"   :Cdve -- Cd_WORKON_HOME()
command! -nargs=* -complete=customlist,Compl_Cd_WORKON_HOME Cdve call Cd_WORKON_HOME(<f-args>)
function! LCd_WORKON_HOME(...)
" LCd_WORKON_HOME()  -- cd $WORKON_HOME/$1
    if $WORKON_HOME ==? ''
        echoerr "$WORKON_HOME is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$WORKON_HOME, a:1], "/")
    else
       let pathname = "$WORKON_HOME"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd_WORKON_HOME(ArgLead, ...)
    return ListDirsOrFiles($WORKON_HOME, a:ArgLead, 1)
endfunction
"   :LCdworkonhome -- LCd_WORKON_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME LCdworkonhome call LCd_WORKON_HOME(<f-args>)
"   :LCdwh -- LCd_WORKON_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME LCdwh call LCd_WORKON_HOME(<f-args>)
"   :LCdve -- LCd_WORKON_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME LCdve call LCd_WORKON_HOME(<f-args>)
"   :Lcdworkonhome -- LCd_WORKON_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME Lcdworkonhome call LCd_WORKON_HOME(<f-args>)
"   :Lcdwh -- LCd_WORKON_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME Lcdwh call LCd_WORKON_HOME(<f-args>)
"   :Lcdve -- LCd_WORKON_HOME()
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME Lcdve call LCd_WORKON_HOME(<f-args>)

function! Cd_CONDA_ENVS_PATH(...)
" Cd_CONDA_ENVS_PATH()  -- cd $CONDA_ENVS_PATH/$1
    if $CONDA_ENVS_PATH ==? ''
        echoerr "$CONDA_ENVS_PATH is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$CONDA_ENVS_PATH, a:1], "/")
    else
       let pathname = "$CONDA_ENVS_PATH"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd_CONDA_ENVS_PATH(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ENVS_PATH, a:ArgLead, 1)
endfunction
"   :Cdcondaenvspath -- Cd_CONDA_ENVS_PATH()
command! -nargs=* -complete=customlist,Compl_Cd_CONDA_ENVS_PATH Cdcondaenvspath call Cd_CONDA_ENVS_PATH(<f-args>)
"   :Cda -- Cd_CONDA_ENVS_PATH()
command! -nargs=* -complete=customlist,Compl_Cd_CONDA_ENVS_PATH Cda call Cd_CONDA_ENVS_PATH(<f-args>)
"   :Cdce -- Cd_CONDA_ENVS_PATH()
command! -nargs=* -complete=customlist,Compl_Cd_CONDA_ENVS_PATH Cdce call Cd_CONDA_ENVS_PATH(<f-args>)
function! LCd_CONDA_ENVS_PATH(...)
" LCd_CONDA_ENVS_PATH()  -- cd $CONDA_ENVS_PATH/$1
    if $CONDA_ENVS_PATH ==? ''
        echoerr "$CONDA_ENVS_PATH is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$CONDA_ENVS_PATH, a:1], "/")
    else
       let pathname = "$CONDA_ENVS_PATH"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd_CONDA_ENVS_PATH(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ENVS_PATH, a:ArgLead, 1)
endfunction
"   :LCdcondaenvspath -- LCd_CONDA_ENVS_PATH()
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH LCdcondaenvspath call LCd_CONDA_ENVS_PATH(<f-args>)
"   :LCda -- LCd_CONDA_ENVS_PATH()
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH LCda call LCd_CONDA_ENVS_PATH(<f-args>)
"   :LCdce -- LCd_CONDA_ENVS_PATH()
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH LCdce call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcdcondaenvspath -- LCd_CONDA_ENVS_PATH()
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH Lcdcondaenvspath call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcda -- LCd_CONDA_ENVS_PATH()
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH Lcda call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcdce -- LCd_CONDA_ENVS_PATH()
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH Lcdce call LCd_CONDA_ENVS_PATH(<f-args>)

function! Cd_VIRTUAL_ENV(...)
" Cd_VIRTUAL_ENV()  -- cd $VIRTUAL_ENV/$1
    if $VIRTUAL_ENV ==? ''
        echoerr "$VIRTUAL_ENV is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$VIRTUAL_ENV, a:1], "/")
    else
       let pathname = "$VIRTUAL_ENV"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd_VIRTUAL_ENV(ArgLead, ...)
    return ListDirsOrFiles($VIRTUAL_ENV, a:ArgLead, 1)
endfunction
"   :Cdvirtualenv -- Cd_VIRTUAL_ENV()
command! -nargs=* -complete=customlist,Compl_Cd_VIRTUAL_ENV Cdvirtualenv call Cd_VIRTUAL_ENV(<f-args>)
"   :Cdv -- Cd_VIRTUAL_ENV()
command! -nargs=* -complete=customlist,Compl_Cd_VIRTUAL_ENV Cdv call Cd_VIRTUAL_ENV(<f-args>)
function! LCd_VIRTUAL_ENV(...)
" LCd_VIRTUAL_ENV()  -- cd $VIRTUAL_ENV/$1
    if $VIRTUAL_ENV ==? ''
        echoerr "$VIRTUAL_ENV is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$VIRTUAL_ENV, a:1], "/")
    else
       let pathname = "$VIRTUAL_ENV"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd_VIRTUAL_ENV(ArgLead, ...)
    return ListDirsOrFiles($VIRTUAL_ENV, a:ArgLead, 1)
endfunction
"   :LCdvirtualenv -- LCd_VIRTUAL_ENV()
command! -nargs=* -complete=customlist,Compl_LCd_VIRTUAL_ENV LCdvirtualenv call LCd_VIRTUAL_ENV(<f-args>)
"   :LCdv -- LCd_VIRTUAL_ENV()
command! -nargs=* -complete=customlist,Compl_LCd_VIRTUAL_ENV LCdv call LCd_VIRTUAL_ENV(<f-args>)
"   :Lcdvirtualenv -- LCd_VIRTUAL_ENV()
command! -nargs=* -complete=customlist,Compl_LCd_VIRTUAL_ENV Lcdvirtualenv call LCd_VIRTUAL_ENV(<f-args>)
"   :Lcdv -- LCd_VIRTUAL_ENV()
command! -nargs=* -complete=customlist,Compl_LCd_VIRTUAL_ENV Lcdv call LCd_VIRTUAL_ENV(<f-args>)

function! Cd__SRC(...)
" Cd__SRC()  -- cd $_SRC/$1
    if $_SRC ==? ''
        echoerr "$_SRC is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_SRC, a:1], "/")
    else
       let pathname = "$_SRC"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__SRC(ArgLead, ...)
    return ListDirsOrFiles($_SRC, a:ArgLead, 1)
endfunction
"   :Cdsrc -- Cd__SRC()
command! -nargs=* -complete=customlist,Compl_Cd__SRC Cdsrc call Cd__SRC(<f-args>)
"   :Cds -- Cd__SRC()
command! -nargs=* -complete=customlist,Compl_Cd__SRC Cds call Cd__SRC(<f-args>)
function! LCd__SRC(...)
" LCd__SRC()  -- cd $_SRC/$1
    if $_SRC ==? ''
        echoerr "$_SRC is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_SRC, a:1], "/")
    else
       let pathname = "$_SRC"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__SRC(ArgLead, ...)
    return ListDirsOrFiles($_SRC, a:ArgLead, 1)
endfunction
"   :LCdsrc -- LCd__SRC()
command! -nargs=* -complete=customlist,Compl_LCd__SRC LCdsrc call LCd__SRC(<f-args>)
"   :LCds -- LCd__SRC()
command! -nargs=* -complete=customlist,Compl_LCd__SRC LCds call LCd__SRC(<f-args>)
"   :Lcdsrc -- LCd__SRC()
command! -nargs=* -complete=customlist,Compl_LCd__SRC Lcdsrc call LCd__SRC(<f-args>)
"   :Lcds -- LCd__SRC()
command! -nargs=* -complete=customlist,Compl_LCd__SRC Lcds call LCd__SRC(<f-args>)

function! Cd__WRD(...)
" Cd__WRD()  -- cd $_WRD/$1
    if $_WRD ==? ''
        echoerr "$_WRD is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_WRD, a:1], "/")
    else
       let pathname = "$_WRD"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__WRD(ArgLead, ...)
    return ListDirsOrFiles($_WRD, a:ArgLead, 1)
endfunction
"   :Cdwrd -- Cd__WRD()
command! -nargs=* -complete=customlist,Compl_Cd__WRD Cdwrd call Cd__WRD(<f-args>)
"   :Cdw -- Cd__WRD()
command! -nargs=* -complete=customlist,Compl_Cd__WRD Cdw call Cd__WRD(<f-args>)
function! LCd__WRD(...)
" LCd__WRD()  -- cd $_WRD/$1
    if $_WRD ==? ''
        echoerr "$_WRD is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_WRD, a:1], "/")
    else
       let pathname = "$_WRD"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__WRD(ArgLead, ...)
    return ListDirsOrFiles($_WRD, a:ArgLead, 1)
endfunction
"   :LCdwrd -- LCd__WRD()
command! -nargs=* -complete=customlist,Compl_LCd__WRD LCdwrd call LCd__WRD(<f-args>)
"   :LCdw -- LCd__WRD()
command! -nargs=* -complete=customlist,Compl_LCd__WRD LCdw call LCd__WRD(<f-args>)
"   :Lcdwrd -- LCd__WRD()
command! -nargs=* -complete=customlist,Compl_LCd__WRD Lcdwrd call LCd__WRD(<f-args>)
"   :Lcdw -- LCd__WRD()
command! -nargs=* -complete=customlist,Compl_LCd__WRD Lcdw call LCd__WRD(<f-args>)

function! Cd__BIN(...)
" Cd__BIN()  -- cd $_BIN/$1
    if $_BIN ==? ''
        echoerr "$_BIN is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_BIN, a:1], "/")
    else
       let pathname = "$_BIN"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__BIN(ArgLead, ...)
    return ListDirsOrFiles($_BIN, a:ArgLead, 1)
endfunction
"   :Cdbin -- Cd__BIN()
command! -nargs=* -complete=customlist,Compl_Cd__BIN Cdbin call Cd__BIN(<f-args>)
"   :Cdb -- Cd__BIN()
command! -nargs=* -complete=customlist,Compl_Cd__BIN Cdb call Cd__BIN(<f-args>)
function! LCd__BIN(...)
" LCd__BIN()  -- cd $_BIN/$1
    if $_BIN ==? ''
        echoerr "$_BIN is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_BIN, a:1], "/")
    else
       let pathname = "$_BIN"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__BIN(ArgLead, ...)
    return ListDirsOrFiles($_BIN, a:ArgLead, 1)
endfunction
"   :LCdbin -- LCd__BIN()
command! -nargs=* -complete=customlist,Compl_LCd__BIN LCdbin call LCd__BIN(<f-args>)
"   :LCdb -- LCd__BIN()
command! -nargs=* -complete=customlist,Compl_LCd__BIN LCdb call LCd__BIN(<f-args>)
"   :Lcdbin -- LCd__BIN()
command! -nargs=* -complete=customlist,Compl_LCd__BIN Lcdbin call LCd__BIN(<f-args>)
"   :Lcdb -- LCd__BIN()
command! -nargs=* -complete=customlist,Compl_LCd__BIN Lcdb call LCd__BIN(<f-args>)

function! Cd__ETC(...)
" Cd__ETC()  -- cd $_ETC/$1
    if $_ETC ==? ''
        echoerr "$_ETC is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_ETC, a:1], "/")
    else
       let pathname = "$_ETC"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__ETC(ArgLead, ...)
    return ListDirsOrFiles($_ETC, a:ArgLead, 1)
endfunction
"   :Cdetc -- Cd__ETC()
command! -nargs=* -complete=customlist,Compl_Cd__ETC Cdetc call Cd__ETC(<f-args>)
"   :Cde -- Cd__ETC()
command! -nargs=* -complete=customlist,Compl_Cd__ETC Cde call Cd__ETC(<f-args>)
function! LCd__ETC(...)
" LCd__ETC()  -- cd $_ETC/$1
    if $_ETC ==? ''
        echoerr "$_ETC is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_ETC, a:1], "/")
    else
       let pathname = "$_ETC"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__ETC(ArgLead, ...)
    return ListDirsOrFiles($_ETC, a:ArgLead, 1)
endfunction
"   :LCdetc -- LCd__ETC()
command! -nargs=* -complete=customlist,Compl_LCd__ETC LCdetc call LCd__ETC(<f-args>)
"   :LCde -- LCd__ETC()
command! -nargs=* -complete=customlist,Compl_LCd__ETC LCde call LCd__ETC(<f-args>)
"   :Lcdetc -- LCd__ETC()
command! -nargs=* -complete=customlist,Compl_LCd__ETC Lcdetc call LCd__ETC(<f-args>)
"   :Lcde -- LCd__ETC()
command! -nargs=* -complete=customlist,Compl_LCd__ETC Lcde call LCd__ETC(<f-args>)

function! Cd__LIB(...)
" Cd__LIB()  -- cd $_LIB/$1
    if $_LIB ==? ''
        echoerr "$_LIB is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_LIB, a:1], "/")
    else
       let pathname = "$_LIB"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__LIB(ArgLead, ...)
    return ListDirsOrFiles($_LIB, a:ArgLead, 1)
endfunction
"   :Cdlib -- Cd__LIB()
command! -nargs=* -complete=customlist,Compl_Cd__LIB Cdlib call Cd__LIB(<f-args>)
"   :Cdl -- Cd__LIB()
command! -nargs=* -complete=customlist,Compl_Cd__LIB Cdl call Cd__LIB(<f-args>)
function! LCd__LIB(...)
" LCd__LIB()  -- cd $_LIB/$1
    if $_LIB ==? ''
        echoerr "$_LIB is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_LIB, a:1], "/")
    else
       let pathname = "$_LIB"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__LIB(ArgLead, ...)
    return ListDirsOrFiles($_LIB, a:ArgLead, 1)
endfunction
"   :LCdlib -- LCd__LIB()
command! -nargs=* -complete=customlist,Compl_LCd__LIB LCdlib call LCd__LIB(<f-args>)
"   :LCdl -- LCd__LIB()
command! -nargs=* -complete=customlist,Compl_LCd__LIB LCdl call LCd__LIB(<f-args>)
"   :Lcdlib -- LCd__LIB()
command! -nargs=* -complete=customlist,Compl_LCd__LIB Lcdlib call LCd__LIB(<f-args>)
"   :Lcdl -- LCd__LIB()
command! -nargs=* -complete=customlist,Compl_LCd__LIB Lcdl call LCd__LIB(<f-args>)

function! Cd__LOG(...)
" Cd__LOG()  -- cd $_LOG/$1
    if $_LOG ==? ''
        echoerr "$_LOG is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_LOG, a:1], "/")
    else
       let pathname = "$_LOG"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__LOG(ArgLead, ...)
    return ListDirsOrFiles($_LOG, a:ArgLead, 1)
endfunction
"   :Cdlog -- Cd__LOG()
command! -nargs=* -complete=customlist,Compl_Cd__LOG Cdlog call Cd__LOG(<f-args>)
function! LCd__LOG(...)
" LCd__LOG()  -- cd $_LOG/$1
    if $_LOG ==? ''
        echoerr "$_LOG is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_LOG, a:1], "/")
    else
       let pathname = "$_LOG"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__LOG(ArgLead, ...)
    return ListDirsOrFiles($_LOG, a:ArgLead, 1)
endfunction
"   :LCdlog -- LCd__LOG()
command! -nargs=* -complete=customlist,Compl_LCd__LOG LCdlog call LCd__LOG(<f-args>)
"   :Lcdlog -- LCd__LOG()
command! -nargs=* -complete=customlist,Compl_LCd__LOG Lcdlog call LCd__LOG(<f-args>)

function! Cd__PYLIB(...)
" Cd__PYLIB()  -- cd $_PYLIB/$1
    if $_PYLIB ==? ''
        echoerr "$_PYLIB is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_PYLIB, a:1], "/")
    else
       let pathname = "$_PYLIB"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__PYLIB(ArgLead, ...)
    return ListDirsOrFiles($_PYLIB, a:ArgLead, 1)
endfunction
"   :Cdpylib -- Cd__PYLIB()
command! -nargs=* -complete=customlist,Compl_Cd__PYLIB Cdpylib call Cd__PYLIB(<f-args>)
function! LCd__PYLIB(...)
" LCd__PYLIB()  -- cd $_PYLIB/$1
    if $_PYLIB ==? ''
        echoerr "$_PYLIB is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_PYLIB, a:1], "/")
    else
       let pathname = "$_PYLIB"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__PYLIB(ArgLead, ...)
    return ListDirsOrFiles($_PYLIB, a:ArgLead, 1)
endfunction
"   :LCdpylib -- LCd__PYLIB()
command! -nargs=* -complete=customlist,Compl_LCd__PYLIB LCdpylib call LCd__PYLIB(<f-args>)
"   :Lcdpylib -- LCd__PYLIB()
command! -nargs=* -complete=customlist,Compl_LCd__PYLIB Lcdpylib call LCd__PYLIB(<f-args>)

function! Cd__PYSITE(...)
" Cd__PYSITE()  -- cd $_PYSITE/$1
    if $_PYSITE ==? ''
        echoerr "$_PYSITE is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_PYSITE, a:1], "/")
    else
       let pathname = "$_PYSITE"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__PYSITE(ArgLead, ...)
    return ListDirsOrFiles($_PYSITE, a:ArgLead, 1)
endfunction
"   :Cdpysite -- Cd__PYSITE()
command! -nargs=* -complete=customlist,Compl_Cd__PYSITE Cdpysite call Cd__PYSITE(<f-args>)
"   :Cdsitepackages -- Cd__PYSITE()
command! -nargs=* -complete=customlist,Compl_Cd__PYSITE Cdsitepackages call Cd__PYSITE(<f-args>)
function! LCd__PYSITE(...)
" LCd__PYSITE()  -- cd $_PYSITE/$1
    if $_PYSITE ==? ''
        echoerr "$_PYSITE is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_PYSITE, a:1], "/")
    else
       let pathname = "$_PYSITE"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__PYSITE(ArgLead, ...)
    return ListDirsOrFiles($_PYSITE, a:ArgLead, 1)
endfunction
"   :LCdpysite -- LCd__PYSITE()
command! -nargs=* -complete=customlist,Compl_LCd__PYSITE LCdpysite call LCd__PYSITE(<f-args>)
"   :LCdsitepackages -- LCd__PYSITE()
command! -nargs=* -complete=customlist,Compl_LCd__PYSITE LCdsitepackages call LCd__PYSITE(<f-args>)
"   :Lcdpysite -- LCd__PYSITE()
command! -nargs=* -complete=customlist,Compl_LCd__PYSITE Lcdpysite call LCd__PYSITE(<f-args>)
"   :Lcdsitepackages -- LCd__PYSITE()
command! -nargs=* -complete=customlist,Compl_LCd__PYSITE Lcdsitepackages call LCd__PYSITE(<f-args>)

function! Cd__VAR(...)
" Cd__VAR()  -- cd $_VAR/$1
    if $_VAR ==? ''
        echoerr "$_VAR is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_VAR, a:1], "/")
    else
       let pathname = "$_VAR"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__VAR(ArgLead, ...)
    return ListDirsOrFiles($_VAR, a:ArgLead, 1)
endfunction
"   :Cdvar -- Cd__VAR()
command! -nargs=* -complete=customlist,Compl_Cd__VAR Cdvar call Cd__VAR(<f-args>)
function! LCd__VAR(...)
" LCd__VAR()  -- cd $_VAR/$1
    if $_VAR ==? ''
        echoerr "$_VAR is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_VAR, a:1], "/")
    else
       let pathname = "$_VAR"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__VAR(ArgLead, ...)
    return ListDirsOrFiles($_VAR, a:ArgLead, 1)
endfunction
"   :LCdvar -- LCd__VAR()
command! -nargs=* -complete=customlist,Compl_LCd__VAR LCdvar call LCd__VAR(<f-args>)
"   :Lcdvar -- LCd__VAR()
command! -nargs=* -complete=customlist,Compl_LCd__VAR Lcdvar call LCd__VAR(<f-args>)

function! Cd__WWW(...)
" Cd__WWW()  -- cd $_WWW/$1
    if $_WWW ==? ''
        echoerr "$_WWW is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_WWW, a:1], "/")
    else
       let pathname = "$_WWW"
    endif
    execute 'cd' pathname
    pwd
endfunction

function! Compl_Cd__WWW(ArgLead, ...)
    return ListDirsOrFiles($_WWW, a:ArgLead, 1)
endfunction
"   :Cdwww -- Cd__WWW()
command! -nargs=* -complete=customlist,Compl_Cd__WWW Cdwww call Cd__WWW(<f-args>)
"   :Cdww -- Cd__WWW()
command! -nargs=* -complete=customlist,Compl_Cd__WWW Cdww call Cd__WWW(<f-args>)
function! LCd__WWW(...)
" LCd__WWW()  -- cd $_WWW/$1
    if $_WWW ==? ''
        echoerr "$_WWW is not set"
        return
    endif
    if a:0 > 0
       let pathname = join([$_WWW, a:1], "/")
    else
       let pathname = "$_WWW"
    endif
    execute 'lcd' pathname
    pwd
endfunction

function! Compl_LCd__WWW(ArgLead, ...)
    return ListDirsOrFiles($_WWW, a:ArgLead, 1)
endfunction
"   :LCdwww -- LCd__WWW()
command! -nargs=* -complete=customlist,Compl_LCd__WWW LCdwww call LCd__WWW(<f-args>)
"   :LCdww -- LCd__WWW()
command! -nargs=* -complete=customlist,Compl_LCd__WWW LCdww call LCd__WWW(<f-args>)
"   :Lcdwww -- LCd__WWW()
command! -nargs=* -complete=customlist,Compl_LCd__WWW Lcdwww call LCd__WWW(<f-args>)
"   :Lcdww -- LCd__WWW()
command! -nargs=* -complete=customlist,Compl_LCd__WWW Lcdww call LCd__WWW(<f-args>)

