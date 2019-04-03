
" ### venv.vim
" # Src: https://github.com/westurner/venv.vim

" "g:venv_list_only_dirs -- 1 -- 0 to list files in Cd* commands

let g:venv_list_only_dirs = 1

function! Cd_help()
" :Cdhelp             -- list venv.vim cdalias commands
    :verbose command Cd
endfunction
command! -nargs=0 Cdhelp call Cd_help()

function! ListDirsOrFiles(path, ArgLead, ...)
    let dirsonly = ((a:0>0) ? 1 : g:venv_list_only_dirs)
    let _glob = '' . a:ArgLead . ((g:venv_list_only_dirs>1) ? '*/' : '*')
    execute 'lcd' a:path
    if dirsonly ==? 1
        let output = map(sort(globpath('.', _glob, 0, 1), 'i'), 'v:val[2:]')
    elseif dirsonly ==? 0
        let output = map(sort(globpath('.', _glob, 0, 1), 'i'), 'v:val[2:] . (isdirectory(v:val) ? "/" : "")')
    endif
    execute 'lcd -'
    return output
endfunction

function! Cdhere(...)
"   :Cdhere  --  cd to here (this dir, dirname(__file__))    [cd %:p:h]
"   :CDhere  --  cd to here (this dir, dirname(__file__))    [cd %:p:h]
    let _path = expand('%:p:h') . ((a:0>0) ? ('/' . a:1) : '')
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
"   :Lcdhere -- lcd to here (this dir, dirname(__file__))  [lcd %:p:h]
"   :LCdhere -- lcd to here (this dir, dirname(__file__))  [lcd %:p:h]
    let _path = expand('%:p:h') . ((a:0>0) ? ('/' . a:1) : '')
    execute 'lcd' _path
    pwd
endfunction
command! -nargs=* -complete=customlist,Compl_Cdhere Lcdhere call Lcdhere(<f-args>)
command! -nargs=* -complete=customlist,Compl_Cdhere LCdhere call Lcdhere(<f-args>)


function! Cd___VAR_(varname, cmd, ...)
" Cd___VAR_()  -- cd expand('$' . a:varname)/$1
    let _VARNAME = a:varname
    let _VAR_=expand(_VARNAME)
    if _VARNAME ==? _VAR_
        echoerr _VARNAME . " is not set"
        return
    endif
    let pathname = join([_VAR_, (a:0>0) ? a:1 : ""], "/")
    execute a:cmd pathname
    pwd
endfunction



function! Cd_HOME(...)
" Cd_HOME()  -- cd $HOME/$1
    call Cd___VAR_('$HOME', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd_HOME(ArgLead, ...)
    return ListDirsOrFiles($HOME, a:ArgLead, 1)
endfunction
"   :Cdhome     -- cd $HOME/$1
command! -nargs=* -complete=customlist,Compl_Cd_HOME Cdhome call Cd_HOME(<f-args>)
"   :Cdh        -- cd $HOME/$1
command! -nargs=* -complete=customlist,Compl_Cd_HOME Cdh call Cd_HOME(<f-args>)

function! LCd_HOME(...)
" LCd_HOME()  -- cd $HOME/$1
    call Cd___VAR_('$HOME', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd_HOME(ArgLead, ...)
    return ListDirsOrFiles($HOME, a:ArgLead, 1)
endfunction
"   :LCdhome    -- cd $HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_HOME LCdhome call LCd_HOME(<f-args>)
"   :LCdh       -- cd $HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_HOME LCdh call LCd_HOME(<f-args>)
"   :Lcdhome    -- cd $HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_HOME Lcdhome call LCd_HOME(<f-args>)
"   :Lcdh       -- cd $HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_HOME Lcdh call LCd_HOME(<f-args>)

function! EHOME(...)
" EHOME()  -- e $HOME/$1
    let _path=expand("$HOME") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_EHOME(ArgLead, ...)
    return ListDirsOrFiles($HOME, a:ArgLead, 0)
endfunction
"   :Eh         -- e $HOME/$1
command! -nargs=* -complete=customlist,Compl_EHOME Eh call EHOME(<f-args>)
"   :Ehome      -- e $HOME/$1
command! -nargs=* -complete=customlist,Compl_EHOME Ehome call EHOME(<f-args>)

function! TabnewHOME(...)
" TabnewHOME()  -- e $HOME/$1
    let _path=expand("$HOME") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_TabnewHOME(ArgLead, ...)
    return ListDirsOrFiles($HOME, a:ArgLead, 0)
endfunction
"   :Tabnewh    -- e $HOME/$1
command! -nargs=* -complete=customlist,Compl_TabnewHOME Tabnewh call TabnewHOME(<f-args>)
"   :Tabnewhome -- e $HOME/$1
command! -nargs=* -complete=customlist,Compl_TabnewHOME Tabnewhome call TabnewHOME(<f-args>)



function! Cd___WRK(...)
" Cd___WRK()  -- cd $__WRK/$1
    call Cd___VAR_('$__WRK', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd___WRK(ArgLead, ...)
    return ListDirsOrFiles($__WRK, a:ArgLead, 1)
endfunction
"   :Cdwrk      -- cd $__WRK/$1
command! -nargs=* -complete=customlist,Compl_Cd___WRK Cdwrk call Cd___WRK(<f-args>)

function! LCd___WRK(...)
" LCd___WRK()  -- cd $__WRK/$1
    call Cd___VAR_('$__WRK', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd___WRK(ArgLead, ...)
    return ListDirsOrFiles($__WRK, a:ArgLead, 1)
endfunction
"   :LCdwrk     -- cd $__WRK/$1
command! -nargs=* -complete=customlist,Compl_LCd___WRK LCdwrk call LCd___WRK(<f-args>)
"   :Lcdwrk     -- cd $__WRK/$1
command! -nargs=* -complete=customlist,Compl_LCd___WRK Lcdwrk call LCd___WRK(<f-args>)

function! E__WRK(...)
" E__WRK()  -- e $__WRK/$1
    let _path=expand("$__WRK") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E__WRK(ArgLead, ...)
    return ListDirsOrFiles($__WRK, a:ArgLead, 0)
endfunction
"   :Ewrk       -- e $__WRK/$1
command! -nargs=* -complete=customlist,Compl_E__WRK Ewrk call E__WRK(<f-args>)

function! Tabnew__WRK(...)
" Tabnew__WRK()  -- e $__WRK/$1
    let _path=expand("$__WRK") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew__WRK(ArgLead, ...)
    return ListDirsOrFiles($__WRK, a:ArgLead, 0)
endfunction
"   :Tabnewwrk  -- e $__WRK/$1
command! -nargs=* -complete=customlist,Compl_Tabnew__WRK Tabnewwrk call Tabnew__WRK(<f-args>)



function! Cd___DOTFILES(...)
" Cd___DOTFILES()  -- cd $__DOTFILES/$1
    call Cd___VAR_('$__DOTFILES', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd___DOTFILES(ArgLead, ...)
    return ListDirsOrFiles($__DOTFILES, a:ArgLead, 1)
endfunction
"   :Cddotfiles -- cd $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_Cd___DOTFILES Cddotfiles call Cd___DOTFILES(<f-args>)
"   :Cdd        -- cd $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_Cd___DOTFILES Cdd call Cd___DOTFILES(<f-args>)

function! LCd___DOTFILES(...)
" LCd___DOTFILES()  -- cd $__DOTFILES/$1
    call Cd___VAR_('$__DOTFILES', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd___DOTFILES(ArgLead, ...)
    return ListDirsOrFiles($__DOTFILES, a:ArgLead, 1)
endfunction
"   :LCddotfiles -- cd $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_LCd___DOTFILES LCddotfiles call LCd___DOTFILES(<f-args>)
"   :LCdd       -- cd $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_LCd___DOTFILES LCdd call LCd___DOTFILES(<f-args>)
"   :Lcddotfiles -- cd $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_LCd___DOTFILES Lcddotfiles call LCd___DOTFILES(<f-args>)
"   :Lcdd       -- cd $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_LCd___DOTFILES Lcdd call LCd___DOTFILES(<f-args>)

function! E__DOTFILES(...)
" E__DOTFILES()  -- e $__DOTFILES/$1
    let _path=expand("$__DOTFILES") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E__DOTFILES(ArgLead, ...)
    return ListDirsOrFiles($__DOTFILES, a:ArgLead, 0)
endfunction
"   :Ed         -- e $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_E__DOTFILES Ed call E__DOTFILES(<f-args>)
"   :Edotfiles  -- e $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_E__DOTFILES Edotfiles call E__DOTFILES(<f-args>)

function! Tabnew__DOTFILES(...)
" Tabnew__DOTFILES()  -- e $__DOTFILES/$1
    let _path=expand("$__DOTFILES") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew__DOTFILES(ArgLead, ...)
    return ListDirsOrFiles($__DOTFILES, a:ArgLead, 0)
endfunction
"   :Tabnewd    -- e $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_Tabnew__DOTFILES Tabnewd call Tabnew__DOTFILES(<f-args>)
"   :Tabnewdotfiles -- e $__DOTFILES/$1
command! -nargs=* -complete=customlist,Compl_Tabnew__DOTFILES Tabnewdotfiles call Tabnew__DOTFILES(<f-args>)



function! Cd_PROJECT_HOME(...)
" Cd_PROJECT_HOME()  -- cd $PROJECT_HOME/$1
    call Cd___VAR_('$PROJECT_HOME', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd_PROJECT_HOME(ArgLead, ...)
    return ListDirsOrFiles($PROJECT_HOME, a:ArgLead, 1)
endfunction
"   :Cdprojecthome -- cd $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_Cd_PROJECT_HOME Cdprojecthome call Cd_PROJECT_HOME(<f-args>)
"   :Cdp        -- cd $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_Cd_PROJECT_HOME Cdp call Cd_PROJECT_HOME(<f-args>)
"   :Cdph       -- cd $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_Cd_PROJECT_HOME Cdph call Cd_PROJECT_HOME(<f-args>)

function! LCd_PROJECT_HOME(...)
" LCd_PROJECT_HOME()  -- cd $PROJECT_HOME/$1
    call Cd___VAR_('$PROJECT_HOME', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd_PROJECT_HOME(ArgLead, ...)
    return ListDirsOrFiles($PROJECT_HOME, a:ArgLead, 1)
endfunction
"   :LCdprojecthome -- cd $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME LCdprojecthome call LCd_PROJECT_HOME(<f-args>)
"   :LCdp       -- cd $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME LCdp call LCd_PROJECT_HOME(<f-args>)
"   :LCdph      -- cd $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME LCdph call LCd_PROJECT_HOME(<f-args>)
"   :Lcdprojecthome -- cd $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME Lcdprojecthome call LCd_PROJECT_HOME(<f-args>)
"   :Lcdp       -- cd $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME Lcdp call LCd_PROJECT_HOME(<f-args>)
"   :Lcdph      -- cd $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_PROJECT_HOME Lcdph call LCd_PROJECT_HOME(<f-args>)

function! EPROJECT_HOME(...)
" EPROJECT_HOME()  -- e $PROJECT_HOME/$1
    let _path=expand("$PROJECT_HOME") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_EPROJECT_HOME(ArgLead, ...)
    return ListDirsOrFiles($PROJECT_HOME, a:ArgLead, 0)
endfunction
"   :Ep         -- e $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_EPROJECT_HOME Ep call EPROJECT_HOME(<f-args>)
"   :Eph        -- e $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_EPROJECT_HOME Eph call EPROJECT_HOME(<f-args>)
"   :Eprojecthome -- e $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_EPROJECT_HOME Eprojecthome call EPROJECT_HOME(<f-args>)

function! TabnewPROJECT_HOME(...)
" TabnewPROJECT_HOME()  -- e $PROJECT_HOME/$1
    let _path=expand("$PROJECT_HOME") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_TabnewPROJECT_HOME(ArgLead, ...)
    return ListDirsOrFiles($PROJECT_HOME, a:ArgLead, 0)
endfunction
"   :Tabnewp    -- e $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_TabnewPROJECT_HOME Tabnewp call TabnewPROJECT_HOME(<f-args>)
"   :Tabnewph   -- e $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_TabnewPROJECT_HOME Tabnewph call TabnewPROJECT_HOME(<f-args>)
"   :Tabnewprojecthome -- e $PROJECT_HOME/$1
command! -nargs=* -complete=customlist,Compl_TabnewPROJECT_HOME Tabnewprojecthome call TabnewPROJECT_HOME(<f-args>)



function! Cd_WORKON_HOME(...)
" Cd_WORKON_HOME()  -- cd $WORKON_HOME/$1
    call Cd___VAR_('$WORKON_HOME', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd_WORKON_HOME(ArgLead, ...)
    return ListDirsOrFiles($WORKON_HOME, a:ArgLead, 1)
endfunction
"   :Cdworkonhome -- cd $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_Cd_WORKON_HOME Cdworkonhome call Cd_WORKON_HOME(<f-args>)
"   :Cdwh       -- cd $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_Cd_WORKON_HOME Cdwh call Cd_WORKON_HOME(<f-args>)
"   :Cdve       -- cd $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_Cd_WORKON_HOME Cdve call Cd_WORKON_HOME(<f-args>)

function! LCd_WORKON_HOME(...)
" LCd_WORKON_HOME()  -- cd $WORKON_HOME/$1
    call Cd___VAR_('$WORKON_HOME', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd_WORKON_HOME(ArgLead, ...)
    return ListDirsOrFiles($WORKON_HOME, a:ArgLead, 1)
endfunction
"   :LCdworkonhome -- cd $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME LCdworkonhome call LCd_WORKON_HOME(<f-args>)
"   :LCdwh      -- cd $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME LCdwh call LCd_WORKON_HOME(<f-args>)
"   :LCdve      -- cd $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME LCdve call LCd_WORKON_HOME(<f-args>)
"   :Lcdworkonhome -- cd $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME Lcdworkonhome call LCd_WORKON_HOME(<f-args>)
"   :Lcdwh      -- cd $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME Lcdwh call LCd_WORKON_HOME(<f-args>)
"   :Lcdve      -- cd $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_LCd_WORKON_HOME Lcdve call LCd_WORKON_HOME(<f-args>)

function! EWORKON_HOME(...)
" EWORKON_HOME()  -- e $WORKON_HOME/$1
    let _path=expand("$WORKON_HOME") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_EWORKON_HOME(ArgLead, ...)
    return ListDirsOrFiles($WORKON_HOME, a:ArgLead, 0)
endfunction
"   :Ewh        -- e $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_EWORKON_HOME Ewh call EWORKON_HOME(<f-args>)
"   :Eve        -- e $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_EWORKON_HOME Eve call EWORKON_HOME(<f-args>)
"   :Eworkonhome -- e $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_EWORKON_HOME Eworkonhome call EWORKON_HOME(<f-args>)

function! TabnewWORKON_HOME(...)
" TabnewWORKON_HOME()  -- e $WORKON_HOME/$1
    let _path=expand("$WORKON_HOME") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_TabnewWORKON_HOME(ArgLead, ...)
    return ListDirsOrFiles($WORKON_HOME, a:ArgLead, 0)
endfunction
"   :Tabnewwh   -- e $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_TabnewWORKON_HOME Tabnewwh call TabnewWORKON_HOME(<f-args>)
"   :Tabnewve   -- e $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_TabnewWORKON_HOME Tabnewve call TabnewWORKON_HOME(<f-args>)
"   :Tabnewworkonhome -- e $WORKON_HOME/$1
command! -nargs=* -complete=customlist,Compl_TabnewWORKON_HOME Tabnewworkonhome call TabnewWORKON_HOME(<f-args>)



function! Cd_CONDA_ENVS_PATH(...)
" Cd_CONDA_ENVS_PATH()  -- cd $CONDA_ENVS_PATH/$1
    call Cd___VAR_('$CONDA_ENVS_PATH', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd_CONDA_ENVS_PATH(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ENVS_PATH, a:ArgLead, 1)
endfunction
"   :Cdcondaenvspath -- cd $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_Cd_CONDA_ENVS_PATH Cdcondaenvspath call Cd_CONDA_ENVS_PATH(<f-args>)
"   :Cda        -- cd $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_Cd_CONDA_ENVS_PATH Cda call Cd_CONDA_ENVS_PATH(<f-args>)
"   :Cdce       -- cd $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_Cd_CONDA_ENVS_PATH Cdce call Cd_CONDA_ENVS_PATH(<f-args>)

function! LCd_CONDA_ENVS_PATH(...)
" LCd_CONDA_ENVS_PATH()  -- cd $CONDA_ENVS_PATH/$1
    call Cd___VAR_('$CONDA_ENVS_PATH', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd_CONDA_ENVS_PATH(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ENVS_PATH, a:ArgLead, 1)
endfunction
"   :LCdcondaenvspath -- cd $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH LCdcondaenvspath call LCd_CONDA_ENVS_PATH(<f-args>)
"   :LCda       -- cd $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH LCda call LCd_CONDA_ENVS_PATH(<f-args>)
"   :LCdce      -- cd $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH LCdce call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcdcondaenvspath -- cd $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH Lcdcondaenvspath call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcda       -- cd $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH Lcda call LCd_CONDA_ENVS_PATH(<f-args>)
"   :Lcdce      -- cd $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ENVS_PATH Lcdce call LCd_CONDA_ENVS_PATH(<f-args>)

function! ECONDA_ENVS_PATH(...)
" ECONDA_ENVS_PATH()  -- e $CONDA_ENVS_PATH/$1
    let _path=expand("$CONDA_ENVS_PATH") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_ECONDA_ENVS_PATH(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ENVS_PATH, a:ArgLead, 0)
endfunction
"   :Ea         -- e $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_ECONDA_ENVS_PATH Ea call ECONDA_ENVS_PATH(<f-args>)
"   :Ece        -- e $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_ECONDA_ENVS_PATH Ece call ECONDA_ENVS_PATH(<f-args>)
"   :Econdaenvspath -- e $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_ECONDA_ENVS_PATH Econdaenvspath call ECONDA_ENVS_PATH(<f-args>)

function! TabnewCONDA_ENVS_PATH(...)
" TabnewCONDA_ENVS_PATH()  -- e $CONDA_ENVS_PATH/$1
    let _path=expand("$CONDA_ENVS_PATH") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_TabnewCONDA_ENVS_PATH(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ENVS_PATH, a:ArgLead, 0)
endfunction
"   :Tabnewa    -- e $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_TabnewCONDA_ENVS_PATH Tabnewa call TabnewCONDA_ENVS_PATH(<f-args>)
"   :Tabnewce   -- e $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_TabnewCONDA_ENVS_PATH Tabnewce call TabnewCONDA_ENVS_PATH(<f-args>)
"   :Tabnewcondaenvspath -- e $CONDA_ENVS_PATH/$1
command! -nargs=* -complete=customlist,Compl_TabnewCONDA_ENVS_PATH Tabnewcondaenvspath call TabnewCONDA_ENVS_PATH(<f-args>)



function! Cd_CONDA_ROOT(...)
" Cd_CONDA_ROOT()  -- cd $CONDA_ROOT/$1
    call Cd___VAR_('$CONDA_ROOT', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd_CONDA_ROOT(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ROOT, a:ArgLead, 1)
endfunction
"   :Cdcondaroot -- cd $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_Cd_CONDA_ROOT Cdcondaroot call Cd_CONDA_ROOT(<f-args>)
"   :Cdr        -- cd $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_Cd_CONDA_ROOT Cdr call Cd_CONDA_ROOT(<f-args>)

function! LCd_CONDA_ROOT(...)
" LCd_CONDA_ROOT()  -- cd $CONDA_ROOT/$1
    call Cd___VAR_('$CONDA_ROOT', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd_CONDA_ROOT(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ROOT, a:ArgLead, 1)
endfunction
"   :LCdcondaroot -- cd $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ROOT LCdcondaroot call LCd_CONDA_ROOT(<f-args>)
"   :LCdr       -- cd $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ROOT LCdr call LCd_CONDA_ROOT(<f-args>)
"   :Lcdcondaroot -- cd $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ROOT Lcdcondaroot call LCd_CONDA_ROOT(<f-args>)
"   :Lcdr       -- cd $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_LCd_CONDA_ROOT Lcdr call LCd_CONDA_ROOT(<f-args>)

function! ECONDA_ROOT(...)
" ECONDA_ROOT()  -- e $CONDA_ROOT/$1
    let _path=expand("$CONDA_ROOT") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_ECONDA_ROOT(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ROOT, a:ArgLead, 0)
endfunction
"   :Er         -- e $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_ECONDA_ROOT Er call ECONDA_ROOT(<f-args>)
"   :Econdaroot -- e $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_ECONDA_ROOT Econdaroot call ECONDA_ROOT(<f-args>)

function! TabnewCONDA_ROOT(...)
" TabnewCONDA_ROOT()  -- e $CONDA_ROOT/$1
    let _path=expand("$CONDA_ROOT") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_TabnewCONDA_ROOT(ArgLead, ...)
    return ListDirsOrFiles($CONDA_ROOT, a:ArgLead, 0)
endfunction
"   :Tabnewr    -- e $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_TabnewCONDA_ROOT Tabnewr call TabnewCONDA_ROOT(<f-args>)
"   :Tabnewcondaroot -- e $CONDA_ROOT/$1
command! -nargs=* -complete=customlist,Compl_TabnewCONDA_ROOT Tabnewcondaroot call TabnewCONDA_ROOT(<f-args>)



function! Cd_VIRTUAL_ENV(...)
" Cd_VIRTUAL_ENV()  -- cd $VIRTUAL_ENV/$1
    call Cd___VAR_('$VIRTUAL_ENV', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd_VIRTUAL_ENV(ArgLead, ...)
    return ListDirsOrFiles($VIRTUAL_ENV, a:ArgLead, 1)
endfunction
"   :Cdvirtualenv -- cd $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_Cd_VIRTUAL_ENV Cdvirtualenv call Cd_VIRTUAL_ENV(<f-args>)
"   :Cdv        -- cd $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_Cd_VIRTUAL_ENV Cdv call Cd_VIRTUAL_ENV(<f-args>)

function! LCd_VIRTUAL_ENV(...)
" LCd_VIRTUAL_ENV()  -- cd $VIRTUAL_ENV/$1
    call Cd___VAR_('$VIRTUAL_ENV', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd_VIRTUAL_ENV(ArgLead, ...)
    return ListDirsOrFiles($VIRTUAL_ENV, a:ArgLead, 1)
endfunction
"   :LCdvirtualenv -- cd $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_LCd_VIRTUAL_ENV LCdvirtualenv call LCd_VIRTUAL_ENV(<f-args>)
"   :LCdv       -- cd $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_LCd_VIRTUAL_ENV LCdv call LCd_VIRTUAL_ENV(<f-args>)
"   :Lcdvirtualenv -- cd $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_LCd_VIRTUAL_ENV Lcdvirtualenv call LCd_VIRTUAL_ENV(<f-args>)
"   :Lcdv       -- cd $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_LCd_VIRTUAL_ENV Lcdv call LCd_VIRTUAL_ENV(<f-args>)

function! EVIRTUAL_ENV(...)
" EVIRTUAL_ENV()  -- e $VIRTUAL_ENV/$1
    let _path=expand("$VIRTUAL_ENV") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_EVIRTUAL_ENV(ArgLead, ...)
    return ListDirsOrFiles($VIRTUAL_ENV, a:ArgLead, 0)
endfunction
"   :Ev         -- e $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_EVIRTUAL_ENV Ev call EVIRTUAL_ENV(<f-args>)
"   :Evirtualenv -- e $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_EVIRTUAL_ENV Evirtualenv call EVIRTUAL_ENV(<f-args>)

function! TabnewVIRTUAL_ENV(...)
" TabnewVIRTUAL_ENV()  -- e $VIRTUAL_ENV/$1
    let _path=expand("$VIRTUAL_ENV") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_TabnewVIRTUAL_ENV(ArgLead, ...)
    return ListDirsOrFiles($VIRTUAL_ENV, a:ArgLead, 0)
endfunction
"   :Tabnewv    -- e $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_TabnewVIRTUAL_ENV Tabnewv call TabnewVIRTUAL_ENV(<f-args>)
"   :Tabnewvirtualenv -- e $VIRTUAL_ENV/$1
command! -nargs=* -complete=customlist,Compl_TabnewVIRTUAL_ENV Tabnewvirtualenv call TabnewVIRTUAL_ENV(<f-args>)



function! Cd__SRC(...)
" Cd__SRC()  -- cd $_SRC/$1
    call Cd___VAR_('$_SRC', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__SRC(ArgLead, ...)
    return ListDirsOrFiles($_SRC, a:ArgLead, 1)
endfunction
"   :Cdsrc      -- cd $_SRC/$1
command! -nargs=* -complete=customlist,Compl_Cd__SRC Cdsrc call Cd__SRC(<f-args>)
"   :Cds        -- cd $_SRC/$1
command! -nargs=* -complete=customlist,Compl_Cd__SRC Cds call Cd__SRC(<f-args>)

function! LCd__SRC(...)
" LCd__SRC()  -- cd $_SRC/$1
    call Cd___VAR_('$_SRC', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__SRC(ArgLead, ...)
    return ListDirsOrFiles($_SRC, a:ArgLead, 1)
endfunction
"   :LCdsrc     -- cd $_SRC/$1
command! -nargs=* -complete=customlist,Compl_LCd__SRC LCdsrc call LCd__SRC(<f-args>)
"   :LCds       -- cd $_SRC/$1
command! -nargs=* -complete=customlist,Compl_LCd__SRC LCds call LCd__SRC(<f-args>)
"   :Lcdsrc     -- cd $_SRC/$1
command! -nargs=* -complete=customlist,Compl_LCd__SRC Lcdsrc call LCd__SRC(<f-args>)
"   :Lcds       -- cd $_SRC/$1
command! -nargs=* -complete=customlist,Compl_LCd__SRC Lcds call LCd__SRC(<f-args>)

function! E_SRC(...)
" E_SRC()  -- e $_SRC/$1
    let _path=expand("$_SRC") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_SRC(ArgLead, ...)
    return ListDirsOrFiles($_SRC, a:ArgLead, 0)
endfunction
"   :Es         -- e $_SRC/$1
command! -nargs=* -complete=customlist,Compl_E_SRC Es call E_SRC(<f-args>)
"   :Esrc       -- e $_SRC/$1
command! -nargs=* -complete=customlist,Compl_E_SRC Esrc call E_SRC(<f-args>)

function! Tabnew_SRC(...)
" Tabnew_SRC()  -- e $_SRC/$1
    let _path=expand("$_SRC") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_SRC(ArgLead, ...)
    return ListDirsOrFiles($_SRC, a:ArgLead, 0)
endfunction
"   :Tabnews    -- e $_SRC/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_SRC Tabnews call Tabnew_SRC(<f-args>)
"   :Tabnewsrc  -- e $_SRC/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_SRC Tabnewsrc call Tabnew_SRC(<f-args>)



function! Cd__WRD(...)
" Cd__WRD()  -- cd $_WRD/$1
    call Cd___VAR_('$_WRD', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__WRD(ArgLead, ...)
    return ListDirsOrFiles($_WRD, a:ArgLead, 1)
endfunction
"   :Cdwrd      -- cd $_WRD/$1
command! -nargs=* -complete=customlist,Compl_Cd__WRD Cdwrd call Cd__WRD(<f-args>)
"   :Cdw        -- cd $_WRD/$1
command! -nargs=* -complete=customlist,Compl_Cd__WRD Cdw call Cd__WRD(<f-args>)

function! LCd__WRD(...)
" LCd__WRD()  -- cd $_WRD/$1
    call Cd___VAR_('$_WRD', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__WRD(ArgLead, ...)
    return ListDirsOrFiles($_WRD, a:ArgLead, 1)
endfunction
"   :LCdwrd     -- cd $_WRD/$1
command! -nargs=* -complete=customlist,Compl_LCd__WRD LCdwrd call LCd__WRD(<f-args>)
"   :LCdw       -- cd $_WRD/$1
command! -nargs=* -complete=customlist,Compl_LCd__WRD LCdw call LCd__WRD(<f-args>)
"   :Lcdwrd     -- cd $_WRD/$1
command! -nargs=* -complete=customlist,Compl_LCd__WRD Lcdwrd call LCd__WRD(<f-args>)
"   :Lcdw       -- cd $_WRD/$1
command! -nargs=* -complete=customlist,Compl_LCd__WRD Lcdw call LCd__WRD(<f-args>)

function! E_WRD(...)
" E_WRD()  -- e $_WRD/$1
    let _path=expand("$_WRD") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_WRD(ArgLead, ...)
    return ListDirsOrFiles($_WRD, a:ArgLead, 0)
endfunction
"   :Ew         -- e $_WRD/$1
command! -nargs=* -complete=customlist,Compl_E_WRD Ew call E_WRD(<f-args>)
"   :Ewrd       -- e $_WRD/$1
command! -nargs=* -complete=customlist,Compl_E_WRD Ewrd call E_WRD(<f-args>)

function! Tabnew_WRD(...)
" Tabnew_WRD()  -- e $_WRD/$1
    let _path=expand("$_WRD") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_WRD(ArgLead, ...)
    return ListDirsOrFiles($_WRD, a:ArgLead, 0)
endfunction
"   :Tabneww    -- e $_WRD/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_WRD Tabneww call Tabnew_WRD(<f-args>)
"   :Tabnewwrd  -- e $_WRD/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_WRD Tabnewwrd call Tabnew_WRD(<f-args>)



function! Cd__BIN(...)
" Cd__BIN()  -- cd $_BIN/$1
    call Cd___VAR_('$_BIN', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__BIN(ArgLead, ...)
    return ListDirsOrFiles($_BIN, a:ArgLead, 1)
endfunction
"   :Cdbin      -- cd $_BIN/$1
command! -nargs=* -complete=customlist,Compl_Cd__BIN Cdbin call Cd__BIN(<f-args>)
"   :Cdb        -- cd $_BIN/$1
command! -nargs=* -complete=customlist,Compl_Cd__BIN Cdb call Cd__BIN(<f-args>)

function! LCd__BIN(...)
" LCd__BIN()  -- cd $_BIN/$1
    call Cd___VAR_('$_BIN', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__BIN(ArgLead, ...)
    return ListDirsOrFiles($_BIN, a:ArgLead, 1)
endfunction
"   :LCdbin     -- cd $_BIN/$1
command! -nargs=* -complete=customlist,Compl_LCd__BIN LCdbin call LCd__BIN(<f-args>)
"   :LCdb       -- cd $_BIN/$1
command! -nargs=* -complete=customlist,Compl_LCd__BIN LCdb call LCd__BIN(<f-args>)
"   :Lcdbin     -- cd $_BIN/$1
command! -nargs=* -complete=customlist,Compl_LCd__BIN Lcdbin call LCd__BIN(<f-args>)
"   :Lcdb       -- cd $_BIN/$1
command! -nargs=* -complete=customlist,Compl_LCd__BIN Lcdb call LCd__BIN(<f-args>)

function! E_BIN(...)
" E_BIN()  -- e $_BIN/$1
    let _path=expand("$_BIN") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_BIN(ArgLead, ...)
    return ListDirsOrFiles($_BIN, a:ArgLead, 0)
endfunction
"   :Eb         -- e $_BIN/$1
command! -nargs=* -complete=customlist,Compl_E_BIN Eb call E_BIN(<f-args>)
"   :Ebin       -- e $_BIN/$1
command! -nargs=* -complete=customlist,Compl_E_BIN Ebin call E_BIN(<f-args>)

function! Tabnew_BIN(...)
" Tabnew_BIN()  -- e $_BIN/$1
    let _path=expand("$_BIN") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_BIN(ArgLead, ...)
    return ListDirsOrFiles($_BIN, a:ArgLead, 0)
endfunction
"   :Tabnewb    -- e $_BIN/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_BIN Tabnewb call Tabnew_BIN(<f-args>)
"   :Tabnewbin  -- e $_BIN/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_BIN Tabnewbin call Tabnew_BIN(<f-args>)



function! Cd__ETC(...)
" Cd__ETC()  -- cd $_ETC/$1
    call Cd___VAR_('$_ETC', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__ETC(ArgLead, ...)
    return ListDirsOrFiles($_ETC, a:ArgLead, 1)
endfunction
"   :Cdetc      -- cd $_ETC/$1
command! -nargs=* -complete=customlist,Compl_Cd__ETC Cdetc call Cd__ETC(<f-args>)
"   :Cde        -- cd $_ETC/$1
command! -nargs=* -complete=customlist,Compl_Cd__ETC Cde call Cd__ETC(<f-args>)

function! LCd__ETC(...)
" LCd__ETC()  -- cd $_ETC/$1
    call Cd___VAR_('$_ETC', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__ETC(ArgLead, ...)
    return ListDirsOrFiles($_ETC, a:ArgLead, 1)
endfunction
"   :LCdetc     -- cd $_ETC/$1
command! -nargs=* -complete=customlist,Compl_LCd__ETC LCdetc call LCd__ETC(<f-args>)
"   :LCde       -- cd $_ETC/$1
command! -nargs=* -complete=customlist,Compl_LCd__ETC LCde call LCd__ETC(<f-args>)
"   :Lcdetc     -- cd $_ETC/$1
command! -nargs=* -complete=customlist,Compl_LCd__ETC Lcdetc call LCd__ETC(<f-args>)
"   :Lcde       -- cd $_ETC/$1
command! -nargs=* -complete=customlist,Compl_LCd__ETC Lcde call LCd__ETC(<f-args>)

function! E_ETC(...)
" E_ETC()  -- e $_ETC/$1
    let _path=expand("$_ETC") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_ETC(ArgLead, ...)
    return ListDirsOrFiles($_ETC, a:ArgLead, 0)
endfunction
"   :Ee         -- e $_ETC/$1
command! -nargs=* -complete=customlist,Compl_E_ETC Ee call E_ETC(<f-args>)
"   :Eetc       -- e $_ETC/$1
command! -nargs=* -complete=customlist,Compl_E_ETC Eetc call E_ETC(<f-args>)

function! Tabnew_ETC(...)
" Tabnew_ETC()  -- e $_ETC/$1
    let _path=expand("$_ETC") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_ETC(ArgLead, ...)
    return ListDirsOrFiles($_ETC, a:ArgLead, 0)
endfunction
"   :Tabnewe    -- e $_ETC/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_ETC Tabnewe call Tabnew_ETC(<f-args>)
"   :Tabnewetc  -- e $_ETC/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_ETC Tabnewetc call Tabnew_ETC(<f-args>)



function! Cd__LIB(...)
" Cd__LIB()  -- cd $_LIB/$1
    call Cd___VAR_('$_LIB', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__LIB(ArgLead, ...)
    return ListDirsOrFiles($_LIB, a:ArgLead, 1)
endfunction
"   :Cdlib      -- cd $_LIB/$1
command! -nargs=* -complete=customlist,Compl_Cd__LIB Cdlib call Cd__LIB(<f-args>)
"   :Cdl        -- cd $_LIB/$1
command! -nargs=* -complete=customlist,Compl_Cd__LIB Cdl call Cd__LIB(<f-args>)

function! LCd__LIB(...)
" LCd__LIB()  -- cd $_LIB/$1
    call Cd___VAR_('$_LIB', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__LIB(ArgLead, ...)
    return ListDirsOrFiles($_LIB, a:ArgLead, 1)
endfunction
"   :LCdlib     -- cd $_LIB/$1
command! -nargs=* -complete=customlist,Compl_LCd__LIB LCdlib call LCd__LIB(<f-args>)
"   :LCdl       -- cd $_LIB/$1
command! -nargs=* -complete=customlist,Compl_LCd__LIB LCdl call LCd__LIB(<f-args>)
"   :Lcdlib     -- cd $_LIB/$1
command! -nargs=* -complete=customlist,Compl_LCd__LIB Lcdlib call LCd__LIB(<f-args>)
"   :Lcdl       -- cd $_LIB/$1
command! -nargs=* -complete=customlist,Compl_LCd__LIB Lcdl call LCd__LIB(<f-args>)

function! E_LIB(...)
" E_LIB()  -- e $_LIB/$1
    let _path=expand("$_LIB") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_LIB(ArgLead, ...)
    return ListDirsOrFiles($_LIB, a:ArgLead, 0)
endfunction
"   :El         -- e $_LIB/$1
command! -nargs=* -complete=customlist,Compl_E_LIB El call E_LIB(<f-args>)
"   :Elib       -- e $_LIB/$1
command! -nargs=* -complete=customlist,Compl_E_LIB Elib call E_LIB(<f-args>)

function! Tabnew_LIB(...)
" Tabnew_LIB()  -- e $_LIB/$1
    let _path=expand("$_LIB") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_LIB(ArgLead, ...)
    return ListDirsOrFiles($_LIB, a:ArgLead, 0)
endfunction
"   :Tabnewl    -- e $_LIB/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_LIB Tabnewl call Tabnew_LIB(<f-args>)
"   :Tabnewlib  -- e $_LIB/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_LIB Tabnewlib call Tabnew_LIB(<f-args>)



function! Cd__LOG(...)
" Cd__LOG()  -- cd $_LOG/$1
    call Cd___VAR_('$_LOG', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__LOG(ArgLead, ...)
    return ListDirsOrFiles($_LOG, a:ArgLead, 1)
endfunction
"   :Cdlog      -- cd $_LOG/$1
command! -nargs=* -complete=customlist,Compl_Cd__LOG Cdlog call Cd__LOG(<f-args>)

function! LCd__LOG(...)
" LCd__LOG()  -- cd $_LOG/$1
    call Cd___VAR_('$_LOG', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__LOG(ArgLead, ...)
    return ListDirsOrFiles($_LOG, a:ArgLead, 1)
endfunction
"   :LCdlog     -- cd $_LOG/$1
command! -nargs=* -complete=customlist,Compl_LCd__LOG LCdlog call LCd__LOG(<f-args>)
"   :Lcdlog     -- cd $_LOG/$1
command! -nargs=* -complete=customlist,Compl_LCd__LOG Lcdlog call LCd__LOG(<f-args>)

function! E_LOG(...)
" E_LOG()  -- e $_LOG/$1
    let _path=expand("$_LOG") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_LOG(ArgLead, ...)
    return ListDirsOrFiles($_LOG, a:ArgLead, 0)
endfunction
"   :Elog       -- e $_LOG/$1
command! -nargs=* -complete=customlist,Compl_E_LOG Elog call E_LOG(<f-args>)

function! Tabnew_LOG(...)
" Tabnew_LOG()  -- e $_LOG/$1
    let _path=expand("$_LOG") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_LOG(ArgLead, ...)
    return ListDirsOrFiles($_LOG, a:ArgLead, 0)
endfunction
"   :Tabnewlog  -- e $_LOG/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_LOG Tabnewlog call Tabnew_LOG(<f-args>)



function! Cd__PYLIB(...)
" Cd__PYLIB()  -- cd $_PYLIB/$1
    call Cd___VAR_('$_PYLIB', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__PYLIB(ArgLead, ...)
    return ListDirsOrFiles($_PYLIB, a:ArgLead, 1)
endfunction
"   :Cdpylib    -- cd $_PYLIB/$1
command! -nargs=* -complete=customlist,Compl_Cd__PYLIB Cdpylib call Cd__PYLIB(<f-args>)

function! LCd__PYLIB(...)
" LCd__PYLIB()  -- cd $_PYLIB/$1
    call Cd___VAR_('$_PYLIB', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__PYLIB(ArgLead, ...)
    return ListDirsOrFiles($_PYLIB, a:ArgLead, 1)
endfunction
"   :LCdpylib   -- cd $_PYLIB/$1
command! -nargs=* -complete=customlist,Compl_LCd__PYLIB LCdpylib call LCd__PYLIB(<f-args>)
"   :Lcdpylib   -- cd $_PYLIB/$1
command! -nargs=* -complete=customlist,Compl_LCd__PYLIB Lcdpylib call LCd__PYLIB(<f-args>)

function! E_PYLIB(...)
" E_PYLIB()  -- e $_PYLIB/$1
    let _path=expand("$_PYLIB") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_PYLIB(ArgLead, ...)
    return ListDirsOrFiles($_PYLIB, a:ArgLead, 0)
endfunction
"   :Epylib     -- e $_PYLIB/$1
command! -nargs=* -complete=customlist,Compl_E_PYLIB Epylib call E_PYLIB(<f-args>)

function! Tabnew_PYLIB(...)
" Tabnew_PYLIB()  -- e $_PYLIB/$1
    let _path=expand("$_PYLIB") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_PYLIB(ArgLead, ...)
    return ListDirsOrFiles($_PYLIB, a:ArgLead, 0)
endfunction
"   :Tabnewpylib -- e $_PYLIB/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_PYLIB Tabnewpylib call Tabnew_PYLIB(<f-args>)



function! Cd__PYSITE(...)
" Cd__PYSITE()  -- cd $_PYSITE/$1
    call Cd___VAR_('$_PYSITE', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__PYSITE(ArgLead, ...)
    return ListDirsOrFiles($_PYSITE, a:ArgLead, 1)
endfunction
"   :Cdpysite   -- cd $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_Cd__PYSITE Cdpysite call Cd__PYSITE(<f-args>)
"   :Cdsitepackages -- cd $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_Cd__PYSITE Cdsitepackages call Cd__PYSITE(<f-args>)

function! LCd__PYSITE(...)
" LCd__PYSITE()  -- cd $_PYSITE/$1
    call Cd___VAR_('$_PYSITE', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__PYSITE(ArgLead, ...)
    return ListDirsOrFiles($_PYSITE, a:ArgLead, 1)
endfunction
"   :LCdpysite  -- cd $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_LCd__PYSITE LCdpysite call LCd__PYSITE(<f-args>)
"   :LCdsitepackages -- cd $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_LCd__PYSITE LCdsitepackages call LCd__PYSITE(<f-args>)
"   :Lcdpysite  -- cd $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_LCd__PYSITE Lcdpysite call LCd__PYSITE(<f-args>)
"   :Lcdsitepackages -- cd $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_LCd__PYSITE Lcdsitepackages call LCd__PYSITE(<f-args>)

function! E_PYSITE(...)
" E_PYSITE()  -- e $_PYSITE/$1
    let _path=expand("$_PYSITE") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_PYSITE(ArgLead, ...)
    return ListDirsOrFiles($_PYSITE, a:ArgLead, 0)
endfunction
"   :Esitepackages -- e $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_E_PYSITE Esitepackages call E_PYSITE(<f-args>)
"   :Epysite    -- e $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_E_PYSITE Epysite call E_PYSITE(<f-args>)

function! Tabnew_PYSITE(...)
" Tabnew_PYSITE()  -- e $_PYSITE/$1
    let _path=expand("$_PYSITE") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_PYSITE(ArgLead, ...)
    return ListDirsOrFiles($_PYSITE, a:ArgLead, 0)
endfunction
"   :Tabnewsitepackages -- e $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_PYSITE Tabnewsitepackages call Tabnew_PYSITE(<f-args>)
"   :Tabnewpysite -- e $_PYSITE/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_PYSITE Tabnewpysite call Tabnew_PYSITE(<f-args>)



function! Cd__VAR(...)
" Cd__VAR()  -- cd $_VAR/$1
    call Cd___VAR_('$_VAR', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__VAR(ArgLead, ...)
    return ListDirsOrFiles($_VAR, a:ArgLead, 1)
endfunction
"   :Cdvar      -- cd $_VAR/$1
command! -nargs=* -complete=customlist,Compl_Cd__VAR Cdvar call Cd__VAR(<f-args>)

function! LCd__VAR(...)
" LCd__VAR()  -- cd $_VAR/$1
    call Cd___VAR_('$_VAR', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__VAR(ArgLead, ...)
    return ListDirsOrFiles($_VAR, a:ArgLead, 1)
endfunction
"   :LCdvar     -- cd $_VAR/$1
command! -nargs=* -complete=customlist,Compl_LCd__VAR LCdvar call LCd__VAR(<f-args>)
"   :Lcdvar     -- cd $_VAR/$1
command! -nargs=* -complete=customlist,Compl_LCd__VAR Lcdvar call LCd__VAR(<f-args>)

function! E_VAR(...)
" E_VAR()  -- e $_VAR/$1
    let _path=expand("$_VAR") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_VAR(ArgLead, ...)
    return ListDirsOrFiles($_VAR, a:ArgLead, 0)
endfunction
"   :Evar       -- e $_VAR/$1
command! -nargs=* -complete=customlist,Compl_E_VAR Evar call E_VAR(<f-args>)

function! Tabnew_VAR(...)
" Tabnew_VAR()  -- e $_VAR/$1
    let _path=expand("$_VAR") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_VAR(ArgLead, ...)
    return ListDirsOrFiles($_VAR, a:ArgLead, 0)
endfunction
"   :Tabnewvar  -- e $_VAR/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_VAR Tabnewvar call Tabnew_VAR(<f-args>)



function! Cd__WWW(...)
" Cd__WWW()  -- cd $_WWW/$1
    call Cd___VAR_('$_WWW', 'cd', (a:0>0)? a:1 : "")
endfunction
function! Compl_Cd__WWW(ArgLead, ...)
    return ListDirsOrFiles($_WWW, a:ArgLead, 1)
endfunction
"   :Cdwww      -- cd $_WWW/$1
command! -nargs=* -complete=customlist,Compl_Cd__WWW Cdwww call Cd__WWW(<f-args>)
"   :Cdww       -- cd $_WWW/$1
command! -nargs=* -complete=customlist,Compl_Cd__WWW Cdww call Cd__WWW(<f-args>)

function! LCd__WWW(...)
" LCd__WWW()  -- cd $_WWW/$1
    call Cd___VAR_('$_WWW', 'lcd', (a:0>0)? a:1 : "")
endfunction
function! Compl_LCd__WWW(ArgLead, ...)
    return ListDirsOrFiles($_WWW, a:ArgLead, 1)
endfunction
"   :LCdwww     -- cd $_WWW/$1
command! -nargs=* -complete=customlist,Compl_LCd__WWW LCdwww call LCd__WWW(<f-args>)
"   :LCdww      -- cd $_WWW/$1
command! -nargs=* -complete=customlist,Compl_LCd__WWW LCdww call LCd__WWW(<f-args>)
"   :Lcdwww     -- cd $_WWW/$1
command! -nargs=* -complete=customlist,Compl_LCd__WWW Lcdwww call LCd__WWW(<f-args>)
"   :Lcdww      -- cd $_WWW/$1
command! -nargs=* -complete=customlist,Compl_LCd__WWW Lcdww call LCd__WWW(<f-args>)

function! E_WWW(...)
" E_WWW()  -- e $_WWW/$1
    let _path=expand("$_WWW") . ((a:0>0)? "/" . a:1 : "")
    execute 'e' _path
endfunction
function! Compl_E_WWW(ArgLead, ...)
    return ListDirsOrFiles($_WWW, a:ArgLead, 0)
endfunction
"   :Eww        -- e $_WWW/$1
command! -nargs=* -complete=customlist,Compl_E_WWW Eww call E_WWW(<f-args>)
"   :Ewww       -- e $_WWW/$1
command! -nargs=* -complete=customlist,Compl_E_WWW Ewww call E_WWW(<f-args>)

function! Tabnew_WWW(...)
" Tabnew_WWW()  -- e $_WWW/$1
    let _path=expand("$_WWW") . ((a:0>0)? "/" . a:1 : "")
    execute 'tabnew' _path
endfunction
function! Compl_Tabnew_WWW(ArgLead, ...)
    return ListDirsOrFiles($_WWW, a:ArgLead, 0)
endfunction
"   :Tabnewww   -- e $_WWW/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_WWW Tabnewww call Tabnew_WWW(<f-args>)
"   :Tabnewwww  -- e $_WWW/$1
command! -nargs=* -complete=customlist,Compl_Tabnew_WWW Tabnewwww call Tabnew_WWW(<f-args>)


