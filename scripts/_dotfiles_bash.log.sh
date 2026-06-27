# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
if [ -z "$PS1" ]; then
    return
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


case "$TERM" in
    xterm-color)
        color_prompt=yes
        ;;
    *)
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
            # We have color support; assume it's compliant with Ecma-48
            # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
            # a case would tend to support setf rather than setaf.)
            color_prompt=yes
        else
            color_prompt=
        fi
        ;;
esac


# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

#TODO: set this on load

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='grep -F --color=auto'
    alias egrep='grep -E --color=auto'
fi
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.jxl=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:';
export LS_COLORS

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

setup_bashrc_local_before() {
    if [ -e "${HOME}/.bashrc.local.before" ]; then
        source "${HOME}/.bashrc.local.before"
    fi
}

#
setup_dotfiles() {
    ### setup_dotfiles()

    # There should be a symlink from ~/-dotfiles to the dotfiles dir
    #  ln -s ${WORKON_HOME}/dotfiles/src/dotfiles ~/-dotfiles

    __DOTFILES=${__DOTFILES:-"${HOME}/-dotfiles"}
    if [ -n "${__DOTFILES}" ] && [ -d "${__DOTFILES}" ]; then
        export __DOTFILES
        _dotfiles_bashrc="${__DOTFILES}/etc/bash/00-bashrc.before.sh"
        if [[ -f "${_dotfiles_bashrc}" ]]; then
            # shellcheck source=etc/bash/00-bashrc.before.sh
            source "${_dotfiles_bashrc}"
        else
            echo "ERROR: _dotfiles_bashrc: ${_dotfiles_bashrc}"
        fi
    fi

    if [ -e "${HOME}/.bashrc.local.after" ]; then
        source "${HOME}/.bashrc.local.after"
    fi
}



setup_conda() {
    ### setup_conda()       -- setup conda with prefix $CONDA_ROOT

    export CONDA_ROOT=$CONDA_ROOT
    if [ -z "${CONDA_ROOT}" ]; then
        echo "Notice: conda is not loading because CONDA_ROOT was not set."
        return
    fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("${CONDA_ROOT}/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${CONDA_ROOT}/etc/profile.d/conda.sh" ]; then
        . "${CONDA_ROOT}/etc/profile.d/conda.sh"
    else
        export PATH="${CONDA_ROOT}/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

}

setup_bun() {
    ### setup_bun()        -- export PATH=+${BUN_INSTALL}/bin
    BUN_INSTALL=${BUN_INSTALL:-"$HOME/.bun"}
    if [ -d "${BUN_INSTALL}/bin" ]; then
        export BUN_INSTALL
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi
}

setup_aftman() {
    ### setup_aftman()     -- source $AFTMAN_ENV
    AFTMAN_ENV=${AFTMAN_ENV:-"${HOME}/.aftman/env"}
    if [ -f "${AFTMAN_ENV}" ]; then
        export AFTMAN_ENV
        . "${AFTMAN_ENV}"
        # . "${HOME}/.aftman/env"
    fi
}

setup_cargo() {
    ### setup_cargo()      -- source $CARGO_ENV
    CARGO_ENV=${CARGO_ENV:-"${HOME}/.cargo/env"}
    if [ -f "${CARGO_ENV}" ]; then
        export CARGO_ENV
        . "${CARGO_ENV}"
        # . "${HOME}/.cargo/env"
    fi
}

setup_bashrc_package_managers() {
    test -n "${CONDA_ROOT}" && setup_conda
    setup_cargo
    setup_aftman
    setup_bun
}

setup_bashrc_local_before
setup_dotfiles
#!/usr/bin/env bash
## 00-bashrc.before.sh     -- bash dotfiles configuration root
#  source ${__DOTFILES}/etc/bash/00-bashrc.before.sh    -- dotfiles_reload()
#
function dotfiles_reload {
  #  dotfiles_reload()  -- (re)load the bash configuration
  #  $__DOTFILES (str): -- path to the dotfiles symlink (~/-dotfiles)

  echo "#"
  echo "# dotfiles_reload()"

  export __WRK="${__WRK:-"${HOME}/-wrk"}"

  if [ -n "${__DOTFILES}" ]; then
    export __DOTFILES="${__DOTFILES}"
  else
    _dotfiles_src="${WORKON_HOME}/dotfiles/src/dotfiles"
    _dotfiles_link="${HOME}/-dotfiles"

    if [ -d "${_dotfiles_link}" ]; then
        __DOTFILES="${_dotfiles_link}"
    elif [ -d "${_dotfiles_src}" ]; then
        __DOTFILES="${_dotfiles_src}"
    fi
    export __DOTFILES="${__DOTFILES}"
  fi

  conf="${__DOTFILES}/etc/bash"

  #
  ## 01-bashrc.lib.sh           -- useful bash functions (paths)
  #  lspath()           -- list every file along $PATH
  #  realpath()         -- readlink -f (python os.path.realpath)
  #  walkpath()         -- list every directory along ${1:-"."}
  # shellcheck source=./01-bashrc.lib.sh
  source "${conf}/01-bashrc.lib.sh"

  #
  ## 02-bashrc.platform.sh      -- platform things
  # shellcheck source=./02-bashrc.platform.sh
  source "${conf}/02-bashrc.platform.sh"
  detect_platform
  #  detect_platform()  -- set $__IS_MAC or $__IS_LINUX
  if [ -n "${__IS_MAC}" ]; then
      PATH="$(echo "${PATH}" | sed 's,/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin,/usr/sbin:/sbin:/bin:/usr/local/bin:/usr/bin,')"
      export PATH

  ## 03-bashrc.darwin.sh
      # shellcheck source=./03-bashrc.darwin.sh
      source "${conf}/03-bashrc.darwin.sh"
  fi

  #
  ## 04-bashrc.TERM.sh          -- set $TERM and $CLICOLOR
  # shellcheck source=./04-bashrc.TERM.sh
  source "${conf}/04-bashrc.TERM.sh"

  #
  ## 05-bashrc.dotfiles.sh      -- dotfiles
  #  $__DOTFILES (str): -- path to the dotfiles symlink (~/.dotfiles)
  #  dotfiles_status()  -- print dotfiles variables
  #  ds()               -- print dotfiles variables
  # shellcheck source=./05-bashrc.dotfiles.sh
  source "${conf}/05-bashrc.dotfiles.sh"
  dotfiles_add_path

  #
  ## 06-bashrc.completion.sh    -- configure bash completion
  # shellcheck source=./06-bashrc.completion.sh
  source "${conf}/06-bashrc.completion.sh"

  #
  ##
  #  virtualenvwrapper / virtualenv / venv constants
  #
  #  $PROJECT_HOME (str): path to project directory (~/-wrk)
  #  $WORKON_HOME  (str): path to virtualenvs directory (~/-wrk/-ve27)
  #  $VIRTUAL_ENV  (str): path to current $VIRTUAL_ENV ($WORKON_HOME/$VENVSTR)

  #
  ## 07-bashrc.python.sh            -- python
  #  _setup_python()              -- configure PYTHONSTARTUP
  #  _setup_pip()                 -- configure PIP_REQUIRE_VIRTUALENV
  #  _setup_pyenv()               -- setup pyenv PYENV_ROOT and eval (manual)
  # shellcheck source=./07-bashrc.python.sh
  source "${conf}/07-bashrc.python.sh"

  #
  ## 08-bashrc.conda.sh             -- conda
  #  _setup_conda()               -- setup conda paths (manual)
  #                                  WORKON_HOME=CONDA_ENVS_PATH
  #    $1 (str): (optional) CONDA_ENVS_PATH (WORKON_HOME)
  #    $2 (str): (optional) CONDA_ROOT_PATH (or '27' or '34')
  #  $CONDA_ROOT      (str): path to conda install (~/-wrk/-conda34)
  #  $CONDA_ENVS_PATH (str): path to condaenvs directory (~/-wrk/-ce34) [conda]
  # shellcheck source=./08-bashrc.conda.sh
  source "${conf}/08-bashrc.conda.sh"

  #
  ## 07-bashrc.virtualenvwrapper.sh -- virtualenvwrapper
  #  _setup_virtualenvwrapper     -- configure virtualenvwrapper
  #  backup_virtualenv($VENVSTR)  -- backup a venv in WORKON_HOME
  #                                  $WORKON_HOME/$VENVSTR -> ./-bkp/$VENVSTR
  #  backup_virtualenvs()         -- backup all venvs in WORKON_HOME
  #                                  $WORKON_HOME/*        -> ./-bkp/*
  #  rebuild_virtualenv($VENVSTR) -- rebuild $WORKON_HOME/$VENVSTR
  #  rebuild_virtualenvs()        -- rebuild $WORKON_HOME/*
  #  TODO: restore_virtualenv($BACKUPVENVSTR, [$NEWVENVSTR])
  # shellcheck source=./07-bashrc.virtualenvwrapper.sh
  source "${conf}/07-bashrc.virtualenvwrapper.sh"

  #
  ## 08-bashrc.gcloud.sh        -- gcloud: Google Cloud SDK
  #  _setup_google_cloud()  -- setup google cloud paths
  # shellcheck source=./08-bashrc.gcloud.sh
  source "${conf}/08-bashrc.gcloud.sh"

  #
  ## 10-bashrc.venv.sh          -- venv: virtualenvwrapper extensions
  #  _setup_venv()
  #  $__PROJECTSRC     (str): script to source (${PROJECT_HOME}/.projectsrc.sh)
  #  $VIRTUAL_ENV_NAME (str): basename of $VIRTUAL_ENV [usrlog: prompt, title]
  #  $_APP             (str): $VIRTUAL_ENV/src/${_APP}
  #  we() -- workon a new venv
  #     $1: VIRTUAL_ENV_NAME [$WORKON_HOME/${VIRTUAL_ENV_NAME}=>$VIRTUAL_ENV]
  #     $2: _APP (optional; defaults to $VIRTUAL_ENV_NAME)
  #
  #     we dotfiles
  #     we dotfiles etc/bash; cdw; ds; # ls -altr; lll; cd ~; ew etc/bash/*.sh
  #     type workon_venv; command -v venv.py; venv.py --help
  # shellcheck source=./10-bashrc.venv.sh
  source "${conf}/10-bashrc.venv.sh"
  #

  #
  ## 11-bashrc.venv.pyramid.sh  -- venv-pyramid: pyramid-specific config
  # shellcheck source=./11-bashrc.venv.pyramid.sh
  source "${conf}/11-bashrc.venv.pyramid.sh"

  #
  ## 20-bashrc.editor.sh        -- $EDITOR configuration
  #  $EDITOR  (str): cmdstring to open $@ (file list) in editor
  #  $EDITOR_ (str): cmdstring to open $@ (file list) in current editor
  #  e()        -- open paths in current EDITOR_                   [scripts/e]
  #  ew()       -- open paths relative to $_WRD in current EDITOR_ [scripts/ew]
  #                (~ cd $_WRD; $EDITOR_ ${@}) + tab completion
  # shellcheck source=./20-bashrc.editor.sh
  source "${conf}/20-bashrc.editor.sh"
  #
  ## 20-bashrc.vimpagers.sh     -- $PAGER configuration
  #  $PAGER   (str): cmdstring to run pager (less/vim)
  #  lessv()    -- open in vim with less.vim
  #                VIMPAGER_SYNTAX="python" lessv
  #  lessg()    -- open in a gvim with less.vim
  #                VIMPAGER_SYNTAX="python" lessv
  #  lesse()    -- open with $EDITOR_ (~e)
  #  manv()     -- open manpage with vim
  #  mang()     -- open manpage with gvim
  #  mane()     -- open manpage with $EDITOR_ (~e)
  #
  #  TODO: GIT_PAGER="/usr/bin/less -R | /usr/bin/cat"
  # shellcheck source=./29-bashrc.vimpagers.sh
  source "${conf}/29-bashrc.vimpagers.sh"

  #
  ## 30-bashrc.usrlog.sh        -- $_USRLOG configuration
  #  _setup_usrlog()    -- configure usrlog
  #  $_USRLOG (str): path to a -usrlog.log command log
  #                __USRLOG=~/-usrlog.log
  #                 _USRLOG=${VIRTUAL_ENV}/-usrlog.log
  #  lsusrlogs  -- ls -tr   "${__USRLOG}" "${WORKON_HOME}/*/-usrlog.log"
  #  stid       -- set $TERM_ID to a random string (e.g. "#Yt0PyyKWPro")
  #  stid $name -- set $TERM_ID to string (e.g. \#20150704, "#20150704")
  #  note       -- log a #note to $_USRLOG (histn==#note)
  #  todo       -- log a #todo to $_USRLOG (histn==#todo)
  #  usrlogv    -- open usrlog with vim:    $VIMBIN    $_USRLOG
  #  usrlogg    -- open usrlog with gmvim:  $GUIVIMBIN $_USRLOG
  #  usrloge    -- open usrlog with editor: $EDITOR    $_USRLOG
  #  ut         -- tail -n__ $_USRLOG [ #BUG workaround: see venv.py]
  #  ug         -- egrep current usrlog: egrep $@ $_USRLOG
  #  ugall      -- egrep all usrlogs [ #BUG workaround: see venv.py ]
  #                     egrep $@ "${__USRLOG}" "${WORKON_HOME}/*/-usrlog.log"
  #  ugrin      -- grin current usrlog: grin $@ ${_USRLOG}
  #  ugrinall   -- grin $@  "${__USRLOG}" "${WORKON_HOME}/*/-usrlog.log"
  # shellcheck source=./30-bashrc.usrlog.sh
  source "${conf}/30-bashrc.usrlog.sh"

  #
  ## 30-bashrc.xlck.sh          -- screensaver, (auto) lock, suspend
  #  _setup_xlck()      -- configure xlck
  # shellcheck source=./30-bashrc.xlck.sh
  source "${conf}/30-bashrc.xlck.sh"

  #
  ## 40-bashrc.aliases.sh       -- aliases
  #  _setup_venv_aliases()  -- source in e, ew, makew, ssv, hgw, gitw
  #    _setup_supervisord() -- configure _SVCFG
  #       $1 (str): path to a supervisord.conf file "${1:-${_SVCFG}"
  # shellcheck source=./40-bashrc.aliases.sh
  source "${conf}/40-bashrc.aliases.sh"

  ## 42-bashrc.commands.sh      -- example commands
  # shellcheck source=./42-bashrc.commands.sh
  source "${conf}/42-bashrc.commands.sh"

  #
  ## 50-bashrc.bashmarks.sh     -- bashmarks: local bookmarks
  # shellcheck source=./50-bashrc.bashmarks.sh
  source "${conf}/50-bashrc.bashmarks.sh"

  #
  ## 70-bashrc.repos.sh         -- repos: $__SRC repos, docs
  # shellcheck source=./70-bashrc.repos.sh
  source "${conf}/70-bashrc.repos.sh"

  #
  ## 85-bashrc.agents.sh        -- agents.sh
  source "${conf}/85-bashrc.agents.sh"

  #
  ## 99-bashrc.after.sh         -- after: cleanup
  # shellcheck source=./99-bashrc.after.sh
  source "${conf}/99-bashrc.after.sh"
}

function dr {
    # dr()  -- dotfiles_reload
    dotfiles_reload
}
    # ds()  -- print dotfiles_status()

function dotfiles_main {
    dotfiles_reload
}

dotfiles_main
#
# dotfiles_reload()
#!/usr/bin/env bash
### bashrc.lib.sh


## bash

#__THIS=$(readlink -e "$0")
#__THISDIR=$(dirname "${__THIS}")

echo_args() {
    # echo_args         -- echo $@ (for checking quoting)
    echo "$@"
}

function_exists() {
    # function_exists() -- check whether a bash function exists
    declare -f "$1" > /dev/null
    return $?
}

PATH_prepend ()
{
  # PATH_prepend()     -- prepend a directory ($1) to $PATH
    #   instead of:
    #       export PATH=$dir:$PATH
    #       PATH_prepend $dir 
    #http://superuser.com/questions/ \
    #\ 39751/add-directory-to-path-if-its-not-already-there/39840#39840
    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        return 0
    fi
    export PATH=${1}:${PATH}
}

PATH_remove() {
    # PATH_remove()  -- remove a directory from $PATH
    # note: empty path components ("::") will be stripped
    local _path=${1}
    _PATH=$(echo "${PATH}" | tr ':' '\n' \
    export PATH=${_PATH}
}

PATH_contains() {
    # PATH_contains() -- test whether $PATH contains $1
    local _path=${1}
    local _output
    _output=$(echo "${PATH}" | tr ':' '\n' \
    if [ -z "${_output}" ]; then
        return 1
    else
        echo "${_output}"
    fi
}

lightpath() {
    # lightpath()       -- display $PATH with newlines
    echo ''
    echo "$PATH" | tr ':' '\n'
}

lspath() {
    # lspath()          -- list files in each directory in $PATH
    echo "# PATH=$PATH"
    lightpath | sed 's/\(.*\)/# \1/g'
    echo '#'
    cmd=${1:-'ls -ald'}
    for f in $(lightpath); do
        echo "# $f";
        ${cmd} "$f/"*;
        echo '#'
    done
}

lspath_less() {
    # lspath_less()     -- lspath with less (color)
    if [ -n "${__IS_MAC}" ]; then
        cmd=${1:-'ls -ald -G'}
    else
        cmd=${1:-'ls -ald --color=always'}
    fi
    lspath "${cmd}" | less -R
}

## file paths

realpath () {
    # realpath()        -- print absolute path (os.path.realpath) to $1
    #                      note: OSX does not have readlink -f
    python -c "import os,sys; print(os.path.realpath(os.path.expanduser(sys.argv[1])))" "${1}"
    return
}
path () {
    # path()            -- realpath()
    realpath "${1}"
}


walkpath () {
    # walkpath()        -- walk down path $1 and $cmd each component
    #   $1: path (optional; default: pwd)
    #   $2: cmd  (optional; default: 'ls -ald --color=auto')
    #http://superuser.com/a/65076 
    dir=${1:-$(pwd)}
    if [ -n "${__IS_MAC}" ]; then
        cmd=${2:-"ls -ldaG"}
    else
        cmd=${2:-"ls -lda --color=auto"}
    fi
    dir=$(realpath "${dir}")
    parts=$(echo "${dir}" \
    paths=('/')
    unset path
    for part in $parts; do
        path="$path/$part"
        paths=("${paths[@]}" "${path}")
    done
    ${cmd} "${paths[@]}"
}


ensure_symlink() {
    # ensure_symlink()  -- create or update a symlink to $2 from $1
    #                      if $2 exists, backup with suffix $3
    _from=$1
    _to=$2
    _date=${3:-$(date +%FT%T%z)}  #  ISO8601 w/ tz
    if [ -s "${_from}" ]; then
        _to_path=$(realpath "$_to")
        _from_path=$(realpath "$_from")
        if [ "$_to_path" == "$_from_path" ]; then
            printf "%s already points to %s" "$_from" "$_to"
        else
            printf "%s points to %s" "$_from" "$_to"
            mv -v "${_from}" "${_from}.bkp.${_date}"
            ln -v -s "${_to}" "${_from}"
        fi
    else
        if [ -e "${_from}" ]; then
            printf "%s exists" "${_from}"
            mv -v "${_from}" "${_from}.bkp.${_date}"
            ln -v -s "${_to}" "${_from}"
        else
            ln -v -s "$_to" "$_from"
        fi
    fi
}

ensure_mkdir() {
    # ensure_mkdir()    -- create directory $1 if it does not yet exist
    path=$1
    test -d "${path}" || mkdir -p "${path}"
}
#!/usr/bin/env bash
### bashrc.platform.sh

detect_platform() {
    # detect_platform() -- set $__IS_MAC or $__IS_LINUX according to $(uname)
    UNAME=$(uname)
    if [ "${UNAME}" == "Darwin" ]; then
        export __IS_MAC='true'
    elif [ "${UNAME}" == "Linux" ]; then
        export __IS_LINUX='true'
    fi
}

j() {
    # j()               -- jobs
    jobs
}

f() {
    # f()               -- fg %$1
    fg %"${1}"
}

b() {
    # b()               -- bg %$1
    bg %"${1}"
}

killjob() {
    # killjob()         -- kill %$1
    kill %"${1}"
}
#!/usr/bin/env bash
### bashrc.TERM.sh

# shellcheck disable=2120
configure_TERM() {
    # configure_TERM            -- configure the $TERM variable (man terminfo)
    #   $1: (optional; autodetects if -z)
    term=$1
    if [ -n "${TERM}" ]; then
        __term=${TERM}
    fi
    if [ -n "${term}" ]; then
        export TERM="${term}"
    else
        if [ "${TERM}" == "xterm-256color" ]; then
            # xterm-256color
            configure_TERM_CLICOLOR
        elif [ -n "${TMUX}" ] ; then
            #tmux
            export TERM="screen"
            configure_TERM_CLICOLOR
        elif echo "$TERMCAP" | grep -q screen; then
            #screen
            export TERM="screen"
            configure_TERM_CLICOLOR
        elif [ -n "${ZSH_TMUX_TERM}" ]; then
            #zsh+tmux: oh-my-zsh/plugins/tmux/tmux.plugin.zsh
            export TERM="${ZSH_TMUX_TERM}"
            configure_TERM_CLICOLOR
        fi
    fi
    if [ "${TERM}" != "${__term}" ]; then
        echo "# TERM='${__term}'"
        echo "TERM='${TERM}'"
    fi
}

configure_TERM_CLICOLOR() {
    # configure_TERM_CLICOLOR   -- configure $CLICOLOR and $CLICOLOR_256
    #   CLICOLOR=1
    export CLICOLOR=1

    #todo
    #CLICOLOR_256=1
    #export CLICOLOR_256=$CLICOLOR

    if [ -n "${CLICOLOR_256}" ]; then
        (echo "$TERM" | grep -v -q 256color) && \
            export TERM="${TERM}-256color"
    fi
}


# configure_TERM when sourced
configure_TERM
#!/usr/bin/env bash
### bashrc.dotfiles.sh


function dotfiles_add_path {
    # dotfiles_add_path()       -- add ${__DOTFILES}/scripts to $PATH
    if [ -d "${__DOTFILES}" ]; then
        #PATH_prepend "${__DOTFILES}/bin"  # [01-bashrc.lib.sh]
        PATH_prepend "${__DOTFILES}/scripts"
    fi
}

function shell_escape_single {
    # shell_escape_single()    -- "'" + sed "s,','\"'\"',g" + "'"
    echo "'""${1//\'/\'\"\'\"\'}""'"
}

printvar() {
    # printvar()               -- print varname=value or varname=
    local definition=$(declare -p "$1" 2>/dev/null) || {
        echo "ERROR: variable '$1' is not set." >&2
        return 1
    }
    local _definition="${definition#declare * }"
    echo "${_definition:-"${1}="}"
}


function dotfiles_status {
    # dotfiles_status()         -- print dotfiles_status
    echo "## dotfiles_status()"

    printvar "HOSTNAME"
    printvar "USER"
    printvar "__WRK"
    printvar "PROJECT_HOME"
    printvar "WORKON_HOME"
    test -n "${CONDA_ROOT}" && printvar "CONDA_ROOT"
    test -n "${CONDA_ENVS_PATH}" && printvar "CONDA_ENVS_PATH"
    printvar "VIRTUAL_ENV_NAME"
    printvar "VIRTUAL_ENV"
    printvar "_SRC"
    printvar "_APP"
    printvar "_WRD"
    printvar "_USRLOG"
    printvar "_TERM_ID"
    printvar "PATH"
    printvar "__DOTFILES"
    echo "#"

    test -n "${_TODO}" && printvar "_TODO"
    test -n "${_NOTE}" && printvar "_NOTE"
    test -n "${_MSG}" && printvar "_MSG"
    echo '##'
}
function ds {
    # ds()                      -- print dotfiles_status
    dotfiles_status
}

    # source "${__DOTFILES}/scripts/cls"
# shellcheck source=../../scripts/cls
source "${__DOTFILES}/scripts/cls"
#!/bin/sh
### cls -- clear the terminal scrollback and print dotfiles_status
### clr -- clear the terminal scrollback

    # clr() -- clear scrollback
if [ -d '/Library' ]; then # see __IS_MAC
    function clr {
        # osascript -e 'if application "Terminal" is frontmost then tell application "System Events" to keystroke "k" using command down'
        clear && printf '\e[3J'
    }
else
    function clr {
        reset
    }
fi

#function dotfiles_status {
#   # see: westurner/dotfiles etc/bash/05-bashrc.dotfiles.sh
#}

function cls {
    # cls() -- clear scrollback and print dotfiles_status ($ clr; ds)
    clr ;
    dotfiles_status
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    progname=$(basename "${0}")
    case "${progname}" in
        clr)
            clr; exit
            ;;
        cls)
            cls; exit
            ;;
    esac
fi
    # clr()                     -- clear scrollback
    # cls()                     -- clear scrollback and print dotfiles_status()

#function dotfiles_term_uri {
    ##dotfiles_term_uri()        -- print a URI for the current _TERM_ID
    #term_path="${HOSTNAME}/usrlog/${USER}"
    #term_key=${_APP}/${_TERM_ID}
    #TERM_URI="${term_path}/${term_key}"
    #echo "TERM_URI='${TERM_URL}'"
#}

function debug_env {
    _log=${_LOG:-"."}
    OUTPUT=${1:-"${_log}/$(date +"%FT%T%z").debug-env.env.log"}
    dotfiles_status
    echo "## export"
    export | tee "$OUTPUT"
    echo "## alias"
    alias | tee "$OUTPUT"
    # echo "## lspath"
    # lspath | tee $OUTPUT
}

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin

function debug_on {
    # debug-on()                 -- set -x -v
    set -x -v
    shopt -s extdebug
}
function debug_off {
    # debug-off()                -- set +x +v
    set +x +v
    shopt -s extdebug
}

function _virtualenvwrapper_get_step_num {

    # Virtualenvwrapper numeric sequence
    # * to make logs in /var/log/venv.nnn-stepname.log naturally ordered
    #
    # * 0xx : 'initialization' actions  : [initialize]
    # * 1xx : 'creation' actions        : [pre|post]mk[virtualenv|project]
    # * 2xx : 'vation' actions          : [pre|post][activate|deactivate]
    # * 8xx : 'managment' actions       : [pre|post][cpvirtualenv|rmvirtualenv]
    # * 868 : unknown
    # * xx0 : 'pre' actions
    # * xx9 : 'post' actions
    # Source-ordered according to the virtualenvwrapper docs
    # * https://virtualenvwrapper.readthedocs.org/en/latest/scripts.html#scripts
    step=${1}
    n="868"  # unknown
    case ${step} in
        "get_env_details")
            n="800" ;;
        "initialize")
            n="010" ;;
        "premkvirtualenv")
            n="120" ;;
        "postmkvirtualenv")
            n="129" ;;
        "precpvirtualenv")
            n="820" ;;
        "postcpvirtualenv")
            n="829" ;;
        "preactivate")
            n="230" ;;
        "postactivate")
            n="239" ;;
        "predeactivate")
            n="290" ;;
        "postdeactivate")
            n="299" ;;
        "prermvirtualenv")
            n="810" ;;
        "postrmvirtualenv")
            n="819" ;;
        "premkproject")
            n="140" ;;
        "postmkproject")
            n="149" ;;
    esac
    echo "${n}"
}

function log_dotfiles_state {
    # log_dotfiles_state()      -- save current environment to logfiles
    #   $1 -- logkey (virtualenvwrapper step name)
    test -n "${DOTFILES_SKIP_LOG}" && echo '#DOTFILES_SKIP_LOG' && return
    _log=${_LOG:-"${HOME}/var/log"}
    if [ "${_log}" == "/var/log" ]; then
        _log="${HOME}/var/log"
    fi
    logkey=${1:-'log_dotfiles_state'}
    stepnum="$(_virtualenvwrapper_get_step_num "${logkey}")"
    logdir=${_log:-"var/log"}/venv..${VIRTUAL_ENV_NAME}..${stepnum}..${logkey}
    exportslogfile=${logdir}/exports.log
    envlogfile=${logdir}/exports_env.log
    test -n "${logdir}" && mkdir -p "${logdir}"
    # XXX: PRF
    export > "${exportslogfile}"
    set > "${envlogfile}"
}


function dotfiles_initialize {
    # dotfiles_initialize()     -- virtualenvwrapper initialize
    log_dotfiles_state 'initialize'
}


function dotfiles_premkvirtualenv {
    # dotfiles_premkvirtualenv -- virtualenvwrapper premkvirtualenv
    #log_dotfiles_state 'premkvirtualenv'  # PERF
    true
}

function dotfiles_postmkvirtualenv_help {
    echo '# __DOTFILES/etc/bash/10-bashrc.venv.sh sources venv.sh'
    if [ -z "${IS_CONDA_ENV}" ]; then
        echo '# __DOTFILES/etc/bash/10-bashrc.venv.sh defines workon_venv'
        echo "## to work on this virtualenv:"
        echo "# workon_venv <venvstr> [<venvappstr> [<pyver>]]"
        echo "# we          <venvstr> [<venvappstr> [<pyver>]]"
        echo "$ we '${VIRTUAL_ENV_NAME}'"
    else
        _conda_envs_path=${_conda_envs_path}
        echo '# __DOTFILES/etc/bash/08-bashrc.conda.sh defines workon_conda'
        echo "## to work on this condaenv:"
        echo "# workon_conda <venvstr> [<venvappstr> [<pyver>]]"
        echo "# wec          <venvstr> [<venvappstr> [<pyver>]]"
        echo "$ wec '${VIRTUAL_ENV_NAME}' '${VIRTUAL_ENV_NAME}' '${_conda_envs_path}'"
    fi
    echo '#   dotfiles_status                    # ds'
    echo '#   source <(venv.py -e --print-bash)  # venv.py -h'
    echo '$ venv_mkdirs  # already done in dotfiles_postmkvirtualenv   '
    # shellcheck disable=2016
    echo '$ mkdir -p "$_WRD"'
    echo '$ cdwrd; cdw'
    echo '# editwrd README; ewrd README; ew README Makefile  # edit<tab>'
    echo '# cdhelp;; cdvirtualenv; cdv;; cdbin; cdb;; cdetc; cde;; cdsrc; cds;; cdwrd; cdw'
}


function dotfiles_postmkvirtualenv {
    # dotfiles_postmkvirtualenv -- virtualenvwrapper postmkvirtualenv
    log_dotfiles_state 'postmkvirtualenv'

    if [ -z "${VIRTUAL_ENV}" ]; then
        echo 'VIRTUAL_ENV is not set? (err: 2) [dotfiles_postmkvirtualenv]'
        # shellcheck disable=2016
        echo 'we <name>; venv_mkdirs; mkdir -p "$_WRD"'
        return 2
    fi

    # NOTE: infer VIRTUAL_ENV_NAME from VIRTUAL_ENV
    VIRTUAL_ENV_NAME="${VIRTUAL_ENV_NAME:-"$(basename "${VIRTUAL_ENV}")"}"

    #declare -f 'venv_mkdirs' 2>&1 >/dev/null &&
    (set -x; venv_mkdirs)
    local _LOG="${_LOG:-"${VIRTUAL_ENV}/var/log"}"
    (set -x; test -d "${_LOG}" || mkdir -p "${_LOG}")
    echo ""

    local PIP
    PIP="$(command -v pip)"
    echo "PIP=$(shell_escape_single "${PIP}")"

    pip_freeze="${_LOG}/pip.freeze.postmkvirtualenv.txt"
    printvar pip_freeze
    (set -x; ${PIP} freeze --all | tee "${pip_freeze}")
    echo ""

    pip_list="${_LOG}/pip.list.postmkvirtualenv.txt"
    printvar pip_list
    (set -x; ${PIP} list | tee "${pip_list}")
    echo ""

    if [ -n "${IS_CONDA_ENV}" ]; then
        conda_list="${_LOG}/conda.list.no-pip.postmkvirtualenv.txt";
        printvar conda_list
        (set -x; conda list -e --no-pip | tee "${conda_list}")

        conda_environment_yml="${_LOG}/conda.environment.postmkvirtualenv.yml";
        printvar conda_environment_yml
        (set -x;
          conda env export \
              | grep -Ev '^(name|prefix): ' \
              | tee "${conda_environment_yml}"
        )

        conda_environment_fromhistory_yml="${_LOG}/conda.environment.from-history.postmkvirtualenv.yml";
        printvar conda_environment_fromhistory_yml
        (set -x;
          conda env export --from-history \
              | grep -Ev '^(name|prefix): ' \
              | tee "${conda_environment_yml}"
        )

        echo '## to work on this condaenv:'
        # shellcheck disable=2016
        echo 'workon_conda '"${VIRTUAL_ENV_NAME}"'; venv_mkdirs; mkdir -p "${_WRD}"; cdw'

        echo '+ workon_conda '"'${VIRTUAL_ENV_NAME}' '${VIRTUAL_ENV_NAME}' ${_conda_envs_path:+"${_conda_envs_path}"}"
        workon_conda "${VIRTUAL_ENV_NAME}" "${VIRTUAL_ENV_NAME}" \
            ${_conda_envs_path:+"${_conda_envs_path}"}

        echo '## to list packages installed into this condaenv with conda:'
        echo '$ conda env export --from-history | grep -Ev "^(name|prefix): "'
        echo '#'
    else
        echo '## to work on this virtualenv:'
        # shellcheck disable=2016
        echo 'workon_venv '"${VIRTUAL_ENV_NAME}"'; venv_mkdirs; mkdir -p "${_WRD}"; cdw'

        echo '+ workon_venv '"${VIRTUAL_ENV_NAME}"
        workon_venv "${VIRTUAL_ENV_NAME}"
    fi

    echo "PWD=$(path)"
    echo "#"
    dotfiles_postmkvirtualenv_help
}

function dotfiles_preactivate {
    # dotfiles_preactivate()    -- virtualenvwrapper preactivate
    log_dotfiles_state 'preactivate'
}

function dotfiles_postactivate {
    # dotfiles_postactivate()   -- virtualenvwrapper postactivate
    log_dotfiles_state 'postactivate'

    local bash_debug_output
    bash_debug_output=$(
    local venv_return_code=$?
    if [ ${venv_return_code} -eq 0 ]; then
        if [ -n "${__VENV}" ]; then
            # shellcheck disable=1090
            source <("$__VENV" -e --print-bash)
        fi
    else
        echo "${bash_debug_output}" # >2
    fi

    declare -f '_setup_usrlog' > /dev/null 2>&1 \
        && _setup_usrlog

    declare -f '_setup_venv_prompt' > /dev/null 2>&1 \
        && _setup_venv_prompt

}

function dotfiles_predeactivate {
    # dotfiles_predeactivate()  -- virtualenvwrapper predeactivate
    log_dotfiles_state 'predeactivate'
}

function dotfiles_postdeactivate {
    # dotfiles_postdeactivate() -- virtualenvwrapper postdeactivate
    log_dotfiles_state 'postdeactivate'
    unset VIRTUAL_ENV
    unset VIRTUAL_ENV_NAME
    unset VENVSTR
    unset VENVSTRAPP
    unset VENVPREFIX
    unset _APP
    unset _BIN
    unset _CFG
    unset _EDITCFG_
    # shellcheck disable=2153
    export EDITOR_="${EDITOR}"
    unset _EDIT_
    unset _ETC
    unset _ETCOPT
    unset _HOME
    unset _IPQTLOG
    unset _IPSESSKEY
    unset _LIB
    unset _LOG
    unset _MEDIA
    unset _MNT
    unset _NOTEBOOKS
    unset _OPT
    unset _PYLIB
    unset _PYSITE
    unset _ROOT
    unset _SBIN
    unset _SERVE_
    unset _SHELL_
    unset _SRC
    unset _SRV
    unset _SVCFG
    unset _SVCFG_
    unset _TEST_
    unset _TMP
    unset _USR
    unset _USRBIN
    unset _USRINCLUDE
    unset _USRLIB
    unset _USRLOCAL
    unset _USRLOG
    unset _USRSBIN
    unset _USRSHARE
    unset _USRSRC
    unset _VAR
    unset _VARCACHE
    unset _VARLIB
    unset _VARLOCK
    unset _VARMAIL
    unset _VAROPT
    unset _VARRUN
    unset _VARSPOOL
    unset _VARTMP
    unset _VENV
    unset _WRD
    unset _WRD_SETUPY
    unset _WWW

    ### usrlog.sh
    ## unset _MSG
    ## unset NOTE
    ## unset TODO

    declare -f '_usrlog_set__USRLOG' > /dev/null 2>&1 \
        && _usrlog_set__USRLOG "${__USRLOG}"

    dotfiles_reload
}
#!/usr/bin/env bash
### bashrc.completion.sh

_configure_bash_completion() {
    # _configure_bash_completion()  -- configure bash completion
    #                               note: `complete -p` lists completions

    if [ -z "${BASH}" ]; then
        return 1
    fi

    if [ -n "$__IS_MAC" ]; then
        #configure brew (brew install bash-completion)
        BREW=$(command -v brew 2>/dev/null || false)
        if [ -n "${BREW}" ]; then
            brew_prefix=$(brew --prefix)
            if [ -f "${brew_prefix}/etc/bash_completion" ]; then
                # shellcheck disable=1090
                source "${brew_prefix}/etc/bash_completion"
            fi
        fi
    else
        if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
            # shellcheck disable=1091
            source /etc/bash_completion
        elif [ -f /etc/profile.d/bash_completion.sh ] && ! shopt -oq posix; then
            source /etc/profile.d/bash_completion.sh
        fi
    fi
}
_configure_bash_completion
#!/usr/bin/env bash
### bashrc.python.sh

pypath() {
    # pypath()              -- print python sys.path and site config
    /usr/bin/env python -m site
}


_setup_python () {
    # _setup_python()       -- configure $PYTHONSTARTUP
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #export
}
_setup_python

_setup_pip () {
    # _setup_pip()          -- set $PIP_REQUIRE_VIRTUALENV=false
    export PIP_REQUIRE_VIRTUALENV=false
}
_setup_pip


## Pyenv

_setup_pyenv() {
    # _setup_pyvenv()       -- set $PYENV_ROOT, PATH_prepend, and pyenv venvw
    export PYENV_ROOT="${HOME}/.pyenv"
    PATH_prepend "${PYENV_ROOT}/bin"
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper
}

#!/usr/bin/env bash
### bashrc.conda.sh
# Shell configuration for Conda

## Global Environment Variables Configured/Used:
# CONDA_VERSIONS (str, optional): Space-separated list of Python versions to configure (e.g., "27 34 312").
# __WRK (str, optional): Default base workspace directory for dotfiles.venv + Conda setups.
#
# CONDA_ROOT (str, optional): Path to the active Conda base installation directory.
# CONDA_ENVS_PATH (str, optional): Path to the active Conda environments directory.

# see: 05-bashrc.dotfiles.sh
  # printvar() {
  # local definition=$(declare -p "$1" 2>/dev/null) || {
  #     echo "ERROR: variable '$1' is not set." >&2
  #     return 1
  # }
  # echo "${definition#declare * }"
  # }

function _conda_get_versions {
    echo "${CONDA_VERSIONS:-27 34 35 36 37 38 39 310 311 312 313 314}"
}

_conda_status() {
    if [ -n "${PATH}" ]; then
        echo PATH="$(shell_escape_single "${PATH}")";
    fi;
    if [ -n "${CONDA_ROOT}" ]; then
        echo CONDA_ROOT="$(shell_escape_single "${CONDA_ROOT}")";
    fi;
    if [ -n "${CONDA_ENVS_PATH}" ]; then
        echo CONDA_ENVS_PATH="$(shell_escape_single "${CONDA_ENVS_PATH}")";
    fi;
}
_cs() {
    _conda_status
}
cs() {
    _conda_status
}
_conda_status
PATH='/var/home/wturner/-wrk/-ve311/dsport/bin:/var/home/wturner/.local/bin:/var/home/wturner/-dotfiles/scripts:/var/home/wturner/.var/app/com.visualstudio.code/config/Code/User/globalStorage/github.copilot-chat/debugCommand:/var/home/wturner/.var/app/com.visualstudio.code/config/Code/User/globalStorage/github.copilot-chat/copilotCli:/app/bin:/app/bin:/app/bin:/usr/bin:/app/tools/podman/bin:/usr/lib/sdk/node20/bin:/var/home/wturner/.var/app/com.visualstudio.code/data/node_modules/bin:/var/home/wturner/.var/app/com.visualstudio.code/data/vscode/extensions/ms-python.debugpy-2026.6.0-linux-x64/bundled/scripts/noConfigScripts'
CONDA_ROOT='/var/home/wturner/-wrk/-conda311'
CONDA_ENVS_PATH='/var/home/wturner/-wrk/-ce37'



function _conda_status_core {
    # _conda_status_core()      -- echo CONDA_ROOT and CONDA_ENVS_PATH
    printvar CONDA_ROOT
    printvar CONDA_ENVS_PATH
}

function _conda_status_defaults {
    # _conda_status_defaults()   -- echo CONDA_ROOT__* and CONDA_ENVS_PATH_*
    local ver
    for ver in $(_conda_get_versions); do
        printvar CONDA_ROOT__py${ver}
        printvar CONDA_ENVS__py${ver}
    done
}

function _conda_status {
    # _conda_status()   -- echo CONDA_ROOT, CONDA_ENVS_PATH, and defaults
    _conda_status_core
    echo
    # _conda_status_defaults
}

function csc {
    # csc()             -- echo CONDA_ROOT and CONDA_ENVS_PATH
    _conda_status_core
}

function _setup_conda_defaults {
    # _setup_conda_defaults()   -- configure CONDA_ENVS_PATH*, CONDA_ROOT*
    #    $1 (pathstr): prefix for CONDA_ENVS_PATHS and CONDA_ROOT
    #                 (default: ${__WRK})
    local __wrk="${1:-${__WRK}}"
    local ver
    for ver in $(_conda_get_versions); do
        export CONDA_ENVS__py${ver}="${__wrk}/-ce${ver}"
        export CONDA_ROOT__py${ver}="${__wrk}/-conda${ver}"
    done

    # export CONDA_ROOT="${__wrk}/-conda37"
    # export CONDA_ENVS_PATH="${__wrk}/-ce37"
}

function __setup_conda_usage {
    echo \
'_setup_conda [CONDA_ENVS_PATH|27-312] [CONDA_ROOT]
Setup environment variables for Conda/Mamba

## Usage:
_setup_conda     # __py27

_setup_conda ~/

_setup_conda 27  # __py27
_setup_conda 34  # __py34
_setup_conda 35  # __py35
_setup_conda 36  # __py36
_setup_conda 37  # __py37
_setup_conda 312  # __py312
_setup_conda ~/envs
_setup_conda ~/envs/ /opt/conda
_setup_conda [CONDA_ENVS_PATH|27-31] [CONDA_ROOT]
'

}

function _setup_conda {
    # _setup_anaconda()     -- set CONDA_ENVS_PATH, CONDA_ROOT
    #   $1 (pathstr or {27, 34}) -- lookup($1, CONDA_ENVS_PATH,
    #                                                   CONDA_ENVS__py27)
    #   $2 (pathstr or "")       -- lookup($2, CONDA_ROOT,
    #                                                   CONDA_ROOT__py27)
    #
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help) __setup_conda_usage; return 0;;
        esac
    done

    local _conda_envs_path="${1}"
    local _conda_root_path="${2}"

    printvar _conda_envs_path
    printvar _conda_root_path


    _setup_conda_defaults "${__WRK}"
    if [ -z "${_conda_envs_path}" ]; then
        if [ -z "${CONDA_ENVS_PATH}" ] || [ -z "${CONDA_ROOT}" ]; then
            echo "" >&2
            echo "ERROR: _conda_envs_path is not provided and CONDA_ENVS_PATH / CONDA_ROOT are not set." >&2
            echo "" >&2
            echo "You can set defaults in ~/.bashrc.local." >&2
            echo "" >&2
            echo "Instructions for setting dotfiles.venv-style defaults in ~/.bashrc.local:" >&2
            echo "  export __wrk=\"\${home}/-wrk\"" >&2
            echo "  export CONDA_ROOT=\"\${__WRK}/-conda314\"" >&2
            echo "  export CONDA_ENVS_PATH=\"\${__WRK}/-ce314\"" >&2
            echo "  export PATH=\"\${CONDA_ROOT}/bin:\${PATH}\"" >&2
            echo "" >&2
            echo "Or, for standard Miniconda:" >&2
            echo "  export CONDA_ROOT=\"\${HOME}/miniconda3\"" >&2
            echo "  export CONDA_ENVS_PATH=\"\${HOME}/miniconda3/envs\"" >&2
            echo "  export PATH=\"\${CONDA_ROOT}/bin:\${PATH}\"" >&2
            echo "" >&2
            echo "Or, for Mambaforge:" >&2
            echo "  export CONDA_ROOT=\"\${HOME}/mambaforge\"" >&2
            echo "  export CONDA_ENVS_PATH=\"\${HOME}/mambaforge/envs\"" >&2
            echo "  export PATH=\"\${CONDA_ROOT}/bin:\${PATH}\"" >&2
            echo "" >&2
            echo "---" >&2
            echo "" >&2
            return 1
        fi
    else
        case "$_conda_envs_path" in
            27|34|35|36|37|38|39|310|311|312|313|314)
                local ce_var="CONDA_ENVS__py${_conda_envs_path}"
                local cr_var="CONDA_ROOT__py${_conda_envs_path}"
                export CONDA_ENVS_PATH="${!ce_var}"
                export CONDA_ROOT="${!cr_var}"
                ;;
            *)
                export CONDA_ENVS_PATH="${_conda_envs_path}"
                if [ -z "${_conda_root_path}" ] && [ -z "${CONDA_ROOT}" ]; then
                     echo "Error: _conda_root_path is not provided and CONDA_ROOT is not set." >&2
                     return 1
                fi
                export CONDA_ROOT="${_conda_root_path:-${CONDA_ROOT}}"
                ;;
        esac
    fi
    _setup_conda_path
}

function _setup_conda_path {
    # _setup_conda_path()   -- prepend CONDA_ROOT/bin to $PATH
    _unsetup_conda_path_all
    (set -x; test -n "${CONDA_ROOT}") || return 2
    PATH_prepend "${CONDA_ROOT}/bin" > /dev/null 2>&1
}

function _unsetup_conda_path_all {
    # _unsetup_conda_path_all()  -- remove CONDA_ROOT & defaults from $PATH
    local ver var_name var_val
    
    if [ -n "${CONDA_ROOT}" ]; then
        PATH_remove "${CONDA_ROOT}/bin" > /dev/null 2>&1
    fi
    
    for ver in $(_conda_get_versions); do
        var_name="CONDA_ROOT__py${ver}"
        var_val="${!var_name}"
        if [ -n "${var_val}" ]; then
            PATH_remove "${var_val}/bin" > /dev/null 2>&1
        fi
    done
    
    declare -f 'dotfiles_status' > /dev/null 2>&1 && dotfiles_status
    _conda_status
}

function deduplicate_lines {
    # deduplicate_lines()   -- deduplicate lines w/ an associative array
    #                                                 (~OrderedMap)
    local -A lines_ary
    local line
    local lines_ary_value
    while IFS= read -r line; do
        lines_ary_value=${lines_ary["${line}"]}
        if [ -z "${lines_ary_value}" ]; then
            lines_ary["${line}"]="${line}"
            echo "${line}"
        fi
    done
    unset lines_ary line lines_ary_value
}

function echo_conda_envs_paths {
    # echo_conda_envs_paths()   -- print (CONDA_ENVS_PATH & defaults)
    local envs_paths=( "${CONDA_ENVS_PATH}" )
    local ver var_name
    for ver in $(_conda_get_versions); do
        var_name="CONDA_ENVS__py${ver}"
        envs_paths+=( "${!var_name}" )
    done
    
    if [ "$(echo "${envs_paths[*]}" | sed 's/ //g')" == "" ]; then
        echo '' >&2
        # shellcheck disable=2016
        echo 'Error: $CONDA_ENVS_PATH is not set' >&2
        return 1
    fi
    printf '%s\n' "${envs_paths[@]}" \
        | deduplicate_lines
}

function lscondaenvs {
    # lscondaenvs()             -- list CONDA_ENVS_PATH/* (and _conda_status)
    #   _conda_status>2
    #   find>1
    _conda_status >&2
    while IFS= read -r line; do
        if [ -n "${line}" ]; then
            (set -x; find "${line}" -mindepth 1 -maxdepth 1 -type d)
        fi
    done < <(echo_conda_envs_paths) | sort
}

function lsce {
    # lsce()                    -- list CONDA_ENVS_PATH/* (and _conda_status)
    lscondaenvs "${@}"
}

function _condaenvs {
    # _condaenvs()              -- list conda envs for tab-completion
    local -a files
    while IFS= read -r line; do
        files+=("${line}/$2"*)
    done < <(echo_conda_envs_paths)
    echo CONDA_ENVS_PATH="$(shell_escape_single "${CONDA_ENVS_PATH}")" >&2
    [[ -e "${files[0]}" ]] && COMPREPLY=( "${files[@]##*/}" )

}

function _workon_conda_usage {
    echo \
'workon_conda [envname|envpath] [VENVSTRAPP] [CONDA_ENVS_PATH]

    Usage:

    # _setup_conda        # _setup_conda -h
    # mkcondaenv env123   # ~= CONDA_ENVS_PATH="..." conda create -n env123 -y

    _setup_conda
    workon_conda <TAB>     # lsve
    workon_conda env123
    wec env123
'
}

function workon_conda {
    # workon_conda()        -- workon a conda + venv project

    for arg in "${@}"; do
        case "${arg}" in
            -h|--help) _workon_conda_usage; return 0;;
        esac
    done

    local _conda_envname="${1}"
    local _venvstrapp="${2}"
    local _conda_envs_path="${3}"

    _setup_conda "${_conda_envs_path}"

    local CONDA_ENV="${CONDA_ENVS_PATH}/${_conda_envname}"

    # shellcheck disable=1090
    source "${CONDA_ROOT}/bin/activate" "${CONDA_ENV}"

    __VENV="${__VENV:-${__DOTFILES}/src/dotfiles/venv/venv_ipyconfig.py}"

    # shellcheck disable=1090
    source <(set -x;

    declare -f "_setup_venv_prompt" > /dev/null 2>&1 && _setup_venv_prompt

    declare -f "dotfiles_status" > /dev/null 2>&1 && dotfiles_status

    # shellcheck disable=SC2329
    function deactivate {
        # shellcheck disable=1091
        source deactivate
        declare -f "dotfiles_postdeactivate" > /dev/null 2>&1 && \
            dotfiles_postdeactivate
    }
}
complete -o default -o nospace -F _condaenvs workon_conda

function wec {
    # wec()                 -- workon a conda + venv project
    #                       note: tab-completion only shows regular virtualenvs
    workon_conda "${@}"
}
complete -o default -o nospace -F _condaenvs wec


function _mkvirtualenv_conda_usage {
    # _mkvirtualenv_conda_usage()  -- echo mkvirtualenv_conda usage information
    echo "mkvirtualenv_conda <envname|path> [CONDA_ENVS_PATH|27,34,312] [<package>+]"
    echo "mkcondaenv    [-h] <envname|path> [CONDA_ENVS_PATH|27,34,312] [<package>+]"
    echo ""
    echo "To create a condaenv named 'science':"
    echo ""
    echo "  $ mkcondaenv science    # envname=science CONDA_ENVS_PATH=='$CONDA_ENVS_PATH'"
    echo "  $ mkcondaenv science 27 # envname=science "'CONDA_ENVS_PATH="$__WRK/-ce27"'
    echo "  $ mkcondaenv science 34 # envname=science "'CONDA_ENVS_PATH="$__WRK/-ce27"'
    echo "  $ mkcondaenv science 35"
    echo "  $ mkcondaenv ~/science 37"
    echo "  $ mkcondaenv science ~/condaenvs"
    echo "  $ mkcondaenv science 37 jupyterlab matplotlib pandas"
    echo ""
    echo "To workon a condaenv named 'science':'"
    echo ""
    echo "  $ workon_conda science science 37"
    echo "  $ wec science science 37"
    echo ""
    echo "To workon a condaenv named 'science' in the (implicit) 37 condaroot:"
    echo ""
    echo "  $ _setup_conda 37"
    echo "  $ wec science"
    echo ""
}

function mkcondaenv {
    # mkcondaenv()         -- mkvirtualenv_conda "${@}"
    mkvirtualenv_conda "${@}"
}

function mkvirtualenv_conda {
    # mkvirtualenv_conda()  -- mkvirtualenv and conda create
    #   $1 (_conda_envname:str)     -- envname string (eg "dotfiles")
    #   $2 (_conda_envs_path:str)   -- path to create envname in
    #       default: CONDA_ENVS_PATH

    if [[ -z "${*}" ]]; then
        _mkvirtualenv_conda_usage
        return 0
    fi
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help)
                _mkvirtualenv_conda_usage
                return 0
        esac
    done

    local _conda_envname="${1}"
    local _conda_envs_path="${2:-${CONDA_ENVS_PATH}}"
    if [ -n "${2}" ]; then
        shift
    fi
    shift
    local _conda_pkgs=( "${@}" )

    local _conda_python="${CONDA_PYTHON}"   # CONDA_PYTHON="python=3.6"

    printvar _conda_envname
    printvar _conda_envs_path
    # shellcheck disable=2016
    #(set +x +v;
    #    echo '$1 $_conda_envname: '"${_conda_envname}";
    #    echo '$2 $_conda_envs_path: '"${_conda_envs_path}")
    if [ -z "${_conda_envname}" ] || [ -z "${_conda_envs_path}" ]; then
        return 2
    fi

    echo '_setup_conda '"${_conda_envs_path}"
    _setup_conda "${_conda_envs_path}" # scripts/venv_ipyconfig.py
    local CONDA_ENV="${CONDA_ENVS_PATH}/${_conda_envname}"

    if [ -z "${_conda_python}" ]; then
        case "${_conda_envs_path}" in
            27)
                _conda_python="python=2.7"
                ;;
            34|35|36|37|38|39|310|311|312|313|314|3*)
                _conda_python="python=3.${_conda_envs_path#3}"
                ;;
        esac
    fi
    if [ -z "${_conda_python}" ]; then     # TODO: remove these defaults?
        _conda_python_default="python=3"
        _conda_python=${_conda_python:-"${_conda_python_default}"}
    fi

#   #(CONDA_ENVS_PATH=${_conda_envs_path}
#   #    conda create --mkdir -n ${_conda_envname} -y
#   #    "${_conda_python}" readline pip ${_conda_pkgs} )

    (set -x;
        conda create --mkdir --prefix "${CONDA_ENV}" --yes \
            "${_conda_python}" readline pip "${_conda_pkgs[@]}")

    unset VIRTUAL_ENV_NAME
    unset _APP

    export VIRTUAL_ENV="${CONDA_ENV}"   # TODO: is this necessary?
    # shellcheck disable=2016
    echo "+ workon_conda '${_conda_envname}' '${_conda_envname}' '${_conda_envs_path}'"
    workon_conda "${_conda_envname}" "${_conda_envname}" "${_conda_envs_path}"
    export VIRTUAL_ENV="${CONDA_ENV}"

    # if there is a function named 'dotfiles_postmkvirtualenv',
    # then run 'dotfiles_postmkvirtualenv'
    # (defined in 08-bashrc.dotfiles.sh)
    declare -f 'dotfiles_postmkvirtualenv' > /dev/null 2>&1 && \
        IS_CONDA_ENV="${CONDA_ENV}" \
        _conda_envs_path="${_conda_envs_path}" \
        dotfiles_postmkvirtualenv

}

function rmvirtualenv_conda {
    # rmvirtualenv_conda()  -- rmvirtualenv conda
    local _conda_envname="${1}"
    local _conda_envs_path="${2:-${CONDA_ENVS_PATH}}"

    # shellcheck disable=2016
    if [ -z "${_conda_envname}" ] || [ -z "${_conda_envs_path}" ]; then
        echo '$1 $_conda_envname: '"${_conda_envname}";
        echo '$2 $_conda_envs_path: '"${_conda_envs_path}" ;
        echo '$conda_env="${_conda_envs_path}/{$_conda_envname}"'
        return 2
    fi

    local conda_env="${_conda_envs_path}/$_conda_envname"

    echo "Removing ${conda_env}"
    local _prmpt='_y_to_remove__n_to_cancel_'
    (set -x; \
        (touch "${_prmpt}" && \
         rm -fi "${_prmpt}") && \
        rm -rf "${conda_env}")
}


function mkvirtualenv_conda_if_available {
    # mkvirtualenv_conda_if_available() -- mkvirtualenv_conda OR mkvirtualenv
    (declare -f 'mkvirtualenv_conda' > /dev/null 2>&1 \
        && mkvirtualenv_conda "${@}") \
    || \
    (declare -f 'mkvirtualenv' > /dev/null 2>&1 \
        && mkvirtualenv "${@}")
}

function workon_conda_if_available {
    # workon_conda_if_available()       -- workon_conda OR we OR workon
    (declare -f 'workon_conda' > /dev/null 2>&1 \
        && workon_conda "${@}") \
    || \
    (declare -f 'we' > /dev/null 2>&1 \
        && we "${@}") \
    || \
    (declare -f 'workon' > /dev/null 2>&1 \
        && workon "${@}")
}
#!/usr/bin/env bash
### bashrc.virtualenvwrapper.sh
#
# Installing Virtualenvwrapper:
#   apt:
#     sudo apt-get install virtualenvwrapper
#   pip:
#     [sudo] pip install -U pip virtualenvwrapper
#

## Configure dotfiles/virtualenv root/prefix environment variables
# __WRK         workspace root
# PROJECT_HOME  virtualenvwrapper project directory (mkproject)
# WORKON_HOME   virtualenvwrapper virtualenv prefix
#               VIRTUAL_ENV=${WORKON_HOME}/${VIRTUAL_ENV_NAME}
#               _APP=${VIRTUAL_ENV_NAME}  #[/subpath]
#               _SRC=${VIRTUAL_ENV}/${_APP}
#               _WRD=${VIRTUAL_ENV}/${_APP}

function _setup_virtualenvwrapper_default_config {
    export __WRK="${__WRK:-"${HOME}/workspace"}"
    export PROJECT_HOME="${__WRK}"
    export WORKON_HOME="${HOME}/.virtualenvs"
}
function _setup_virtualenvwrapper_dotfiles_config {
    export __WRK="${__WRK:-"${HOME}/-wrk"}"
    export PROJECT_HOME="${__WRK}"
    export WORKON_HOME="${WORKON_HOME:-"${__WRK}/-ve38"}"
}

function _setup_virtualenvwrapper_dirs {
    umask 027
    mkdir -p "${__WRK}" || chmod o-rwx "${__WRK}"
    mkdir -p "${PROJECT_HOME}" || chmod o-rwx "${PROJECT_HOME}"
    mkdir -p "${WORKON_HOME}" || chmod o-rwx "${WORKON_HOME}"
}

function _setup_virtualenvwrapper_config  {
    # _setup_virtualenvwrapper_config()    -- configure $VIRTUALENVWRAPPER_*
    #export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    #export VIRTUALENVWRAPPER_SCRIPT="${HOME}/.local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_HOOK_DIR="${__DOTFILES}/etc/virtualenvwrapper"
    export VIRTUALENVWRAPPER_LOG_DIR="${PROJECT_HOME}/.virtualenvlogs"
    if [ -n "${VIRTUALENVWRAPPER_PYTHON}" ]; then
        if [ -x "/usr/local/bin/python3" ]; then
            export VIRTUALENVWRAPPER_PYTHON="/usr/local/bin/python3"
        elif [ -x "/usr/local/bin/python" ]; then
            export VIRTUALENVWRAPPER_PYTHON="/usr/local/bin/python"
        elif [ -x "${HOME}/.local/bin/python3" ]; then
            export VIRTUALENVWRAPPER_PYTHON="${HOME}/.local/bin/python3"
        elif [ -x "${HOME}/.local/bin/python" ]; then
            export VIRTUALENVWRAPPER_PYTHON="${HOME}/.local/bin/python"
        # elif "${VIRTUAL_ENV}/bin/python"  ## use extra-venv python
        elif [ -x "/usr/bin/python3" ]; then
            export VIRTUALENVWRAPPER_PYTHON="/usr/bin/python3"
        elif [ -x "/bin/python3" ]; then
            export VIRTUALENVWRAPPER_PYTHON="/bin/python3"
        fi
    fi
    if [ -x "/usr/local/bin/virtualenvwrapper.sh" ]; then
        export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    fi

    #  if [ -n "${__IS_MAC}" ]; then  # for brew python
    local _PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"
    if [ -z "${VIRTUALENVWRAPPER_SCRIPT}" ]; then
        VIRTUALENVWRAPPER_SCRIPT=$( (PATH="${_PATH}"; command -v virtualenvwrapper.sh))
        export VIRTUALENVWRAPPER_SCRIPT
    fi
    if [ -z "${VIRTUALENVWRAPPER_PYTHON}" ]; then
        VIRTUALENVWRAPPER_PYTHON=$( (PATH="${_PATH}"; command -v python))
        export VIRTUALENVWRAPPER_PYTHON
    fi
    unset VIRTUALENV_DISTRIBUTE
    if [ -n "${VIRTUALENVWRAPPER_SCRIPT}" ]; then
        # shellcheck disable=1090
        source "${VIRTUALENVWRAPPER_SCRIPT}"
    else
        echo "Err: VIRTUALENVWRAPPER_SCRIPT:=${VIRTUALENVWRAPPER_SCRIPT} # 404"
    fi

}

function _splitondashdash {
    # _splitondashdash()  -- split $@ into two str variables on the first "--"
    #                        (for POSIX compatiblity)
    #   $__SPLIT_BEFORE : newline-delimited part before the --
    #   $__SPLIT_AFTER : space-delimited part after the --
    after_the_dashdash=
    for arg in "${@}"; do
        if [ "${arg}" == "--" ]; then
            after_the_dashdash=1
            continue
        fi
        if [ -z "${after_the_dashdash}" ]; then
            export __SPLIT_BEFORE="${__SPLIT_BEFORE:+"${__SPLIT_BEFORE}"$'\n'}${arg}"
        else
            export __SPLIT_AFTER="${__SPLIT_AFTER:+"${__SPLIT_AFTER} "}${arg}"
        fi
    done
}

function lsvirtualenvs_print_usage {
    echo \
'lsvirtualenvs [-h] [-b|-p] [--wh <$WORKON_HOME>] [-x <command>] [-- <command>]

List virtualenvs in $WORKON_HOME

 -h/--help              print this help text to stdout

 -p/--path/-l           print the full path to each virtualenv
                        with the WORKON_HOME prefix
 -b/--brief/--basename  print only the name of each virtualenv
                        without the WORKON_HOME prefix

  --wh/--WORKON_HOME    Set WORKON_HOME=

## Usage
virtualenvwrapper manages virtualenvs/venvs in $WORKON_HOME.

```
mkvirtualenv      --help     #  pip install virtualenvwrapper
virtualenvwrapper --help     #  apt-get install -y python3-virtualenvwrapper
lsvirtualenv      --help     #  dnf install -y python3-virtualenvwrapper
lsvirtualenvs --help
lsve          --help
```

```
export WORKON_HOME="${HOME}/.virtualenvs"; mkdir -p "${WORKON_HOME}"
mkvirtualenv env123; deactivate
mkvirtualenv env345; deactivate
lsve
lsve -b      # --brief          #  env123\nenv345\n
lsve -l      # --path/--long    #  /workon/home/env123\n/workon/home/env345\n
lsve -p      # --path/--long    #  /workon/home/env123\n/workon/home/env345\n
lsve --path  # -p               #  /workon/home/env123\n/workon/home/env345\n
lsve --wh ./other/workon_home/   #  WORKON_HOME=./other/workon_home/
```
'
}

function lsvirtualenvs {
    # lsvirtualenvs()       -- list virtualenvs in $WORKON_HOME
    #                           if $1 is specified, run that command
    #                           with each virtualenv path
    #                           (Must be POSIX compatible)
    _WORKON_HOME=

    # Split the $@ arguments array into __SPLIT_BEFORE and __SPLIT_AFTER
    __SPLIT_BEFORE=
    __SPLIT_AFTER=
    _splitondashdash "${@}"

    _next_arg_is_workon_home=
    _print_venv_basename=
    _print_venv_path=
    _list_all_venvs=
    _print0=

    # POSIX doesn't support `read` -a to read into $@ or another ary,
    # or bash regex
    while IFS=$'\n' read -r arg
    do
        #printf "ARG: %s\n" "$(shell_escape_single "${arg}")" > &2
        if [ -n "${_next_arg_is_workon_home}" ]; then
            _WORKON_HOME="${arg}";
            echo "WORKON_HOME=$(shell_escape_single "${_WORKON_HOME}")" >&2
            _next_arg_is_workon_home=
            continue
        fi
        if [ -n "${arg}" ]; then
            case "${arg}" in
                -h|--help)
                    lsvirtualenvs_print_usage;
                    return
                    ;;

                --WORKON_HOME|--wh)
                    _next_arg_is_workon_home=1
                    ;;

                -b|--basename|--brief)
                    _print_venv_basename=1
                    ;;
                -p|--path|-l)
                    _print_venv_path=1
                    ;;

                -a|--all)
                    _list_all_venvs=1
                    ;;

                -0|-print0)
                    _print0=1
                    ;;

                *)
                    echo "Unhandled arg in __SPLIT_BEFORE: $(shell_escape_single "${arg}")"
                    ;;
            esac
        fi
    done < <(echo "${__SPLIT_BEFORE}")
    _CMD="${__SPLIT_AFTER}"

    if [ -z "${_WORKON_HOME}" ]; then
        _WORKON_HOME="${WORKON_HOME}";
        echo "WORKON_HOME=$(shell_escape_single "${_WORKON_HOME}")" >&2
    fi
    if [ -n "${_list_all_venvs}" ]; then
        _envs_path=${__WRK}
        mindepth=2
        maxdepth=2
        wholename_args='*/-?e*/*'
        #args='find ~/-wrk -mindepth 2 -maxdepth 2 -wholename '*/-?e*/*' \( -type d -or -type l \)'
    else
        _envs_path=${_WORKON_HOME}
        mindepth=1
        maxdepth=1
        wholename_args=
    fi
    if [ -n "${_print0}" ]; then
        find "${_envs_path}" -mindepth ${mindepth} -maxdepth ${maxdepth} ${wholename_args:+-wholename "${wholename_args}"}  \( -type d -or -type l \) ${_print0:+"-print0"}
    else
        for _VIRTUAL_ENV in $(set -x; find "${_envs_path}" -mindepth ${mindepth} -maxdepth ${maxdepth} ${wholename_args:+-wholename "${wholename_args}"}  \( -type d -or -type l \) ); do
            # _libpython_dirs="$(ls -adtr "${_VIRTUAL_ENV}/lib/python"*.*)"
            # echo "libpython_dirs=(${_libpython_dirs})"
            if [ -n "${_CMD}" ]; then
                ${_CMD} "${_VIRTUAL_ENV}"
            else
                if [ -n "${_print_venv_basename}" ]; then
                    basename "${_VIRTUAL_ENV}"
                elif [ -n "${_print_venv_path}" ]; then
                    echo "${_VIRTUAL_ENV}"
                else
                    echo "${_VIRTUAL_ENV}"
                fi
            fi
        done
    fi
}
function lsve {
    # lsve()                -- list virtualenvs in $WORKON_HOME
    lsvirtualenvs "${@}"
}

function _test_lsvirtualenvs {
    lsvirtualenvs
    lsve
    lsve -h | grep -v "${WORKON_HOME}" || false
    lsve --help
}
function test_lsvirtualenvs {
    (set -x; _test_lsvirtualenvs)
}

function backup_virtualenv {
    # backup_virtualenv()   -- backup VIRTUAL_ENV_NAME $1 to [$2]
    local venvstr="${1}"
    local _date
    _date="$(date +'%FT%T%z')"
    bkpdir="${2:-"${WORKON_HOME}/_venvbkps/${_date}"}"
    test -d "${bkpdir}" || mkdir -p "${bkpdir}"
    archivename="venvstrbkp.${venvstr}.${_date}.tar.gz"
    archivepath="${bkpdir}/${archivename}"
    (cd "${WORKON_HOME}" || return; \
        ( tar czf "${archivepath}" "${venvstr}" \
        && echo "# archivename=${archivename}" ) \
            || (echo "err: ${venvstr} (${archivename})" >&2; return 2))
    return $?
}

function backup_virtualenvs {
    # backup_virtualenvs()  -- backup all virtualenvs in $WORKON_HOME to [$1]
    date=$(date +'%FT%T%z')
    bkpdir=${1:-"${WORKON_HOME}/_venvbkps/${date}"}
    echo BKPDIR="${bkpdir}"
    test -d "${bkpdir}" || mkdir -p "${bkpdir}"
    lsvirtualenvs
    venvs=$(lsvirtualenvs)
    (cd "${WORKON_HOME}" || return; \
    for venv in ${venvs}; do
        backup_virtualenv "${venv}" "${bkpdir}" \
        2>> "${bkpdir}/venvbkps.err" \
        | tee -a "${bkpdir}/venvbkps.list"
    done)
    cat "${bkpdir}/venvbkps.err"
    echo BKPDIR="${bkpdir}"
}

function dx {
    # dx()                      -- 'deactivate'
    (declare -f 'deactivate' > /dev/null 2>&1 \
        && deactivate) || \
    (declare -f 'dotfiles_postdeactivate' > /dev/null 2>&1 \
        && dotfiles_postdeactivate)
}

function _rebuild_virtualenv {
    # rebuild_virtualenv()      -- rebuild a virtualenv, leaving pkgs in place
    #    $1="$VENVSTR"
    #    $2="$VIRTUAL_ENV"
    echo "rebuild_virtualenv()"
    VENVSTR="${1}"
    VIRTUAL_ENV=${2:-"${WORKON_HOME}/${VENVSTR}"}
    _test_path_is_not_root "${VIRTUAL_ENV}" || \
        echo "ERROR: VIRTUAL_ENV may not be ~='/'; VIRTUAL_ENV='$VIRTUAL_ENV'" && \
        return 2
    _BIN="${VIRTUAL_ENV}/bin"
    #rm -fv ${_BIN}/python ${_BIN}/python2 ${_BIN}/python2.7 \
        #${_BIN}/pip ${_BIN}/pip-2.7 \
        #${_BIN}/easy_install ${_BIN}/easy_install-2.7 \
        #${_BIN}/activate*
    pyver=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
    _PYSITE="${VIRTUAL_ENV}/lib/python${pyver}/site-packages"
    declare -f 'deactivate' > /dev/null 2>&1 && deactivate
    if [ -n "${VIRTUAL_ENV}" ]; then 
        find -E "${_PYSITE}" -iname 'activate*' -delete
        find -E "${_PYSITE}" -iname 'pip*' -delete
        find -E "${_PYSITE}" -iname 'setuptools*' -delete
        find -E "${_PYSITE}" -iname 'distribute*' -delete
        find -E "${_PYSITE}" -iname 'easy_install*' -delete
        find -E "${_PYSITE}" -iname 'python*' -delete
    fi
    mkvirtualenv -i setuptools -i wheel -i pip "${VENVSTR}"
    #mkvirtualenv --clear would delete ./lib/python<pyver>/site-packages
    workon "${VENVSTR}" && \
    we "${VENVSTR}"
    _BIN="${VIRTUAL_ENV}/bin"

    if [ "${_BIN}" == "/bin" ]; then
        echo "err: _BIN=${_BIN}"
        return 1
    fi

    find "${_BIN}" -type f | grep -v '.bak$' | grep -v 'python*$' \
        | xargs head -n1
    find "${_BIN}" -type f | grep -v '.bak$' | grep -v 'python*$' \
        | LC_ALL=C xargs  sed -i.bak -E 's,^#!.*python.*,#!'"${_BIN}"'/python,'
    find "${_BIN}" -name '*.bak' -delete

    find "${_BIN}" -type f | grep -v '.bak$' | grep -v 'python*$' \
        | xargs head -n1
    echo "
    # TODO: adjust paths beyond the shebang
    #${_BIN}/pip install -v -v -r <(${_BIN}/pip freeze)
    #${_BIN}/pip install -r ${_WRD}/requirements.txt
    "
}

function rebuild_virtualenv {
    #  rebuild_virtualenv()     -- rebuild a virtualenv
    #    $1="$VENVSTR"
    #    $2="$VIRTUAL_ENV"
    (set -x; _rebuild_virtualenv "${@}")
}

function rebuild_virtualenvs {
    # rebuild_virtualenvs()     -- rebuild all virtualenvs in $WORKON_HOME
    lsve rebuild_virtualenv
}


_setup_virtualenvwrapper_dotfiles_config  # ~/-wrk/-ve37 {-ve27,-ce27,-ce37}

function _setup_virtualenvwrapper {
  # _setup_virtualenvwrapper_default_config # ~/.virtualenvs/
  _setup_virtualenvwrapper_config
  _setup_virtualenvwrapper_dirs
}



if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  _setup_virtualenvwrapper
else
  #if [ -z "${VIRTUALENVWRAPPER_SCRIPT}" ]; then
  _setup_virtualenvwrapper
  #fi
fi
bash: /usr/bin/virtualenvwrapper.sh: No such file or directory
#!/usr/bin/env bash
### bashrc.gcloud.sh

function _get_GCLOUDSDK_PREFIX {
    ## _get_GCLOUDSDK_PREFIX()   -- get GCLOUDSDK_PREFIX
    #   $1 (str): default:~/google-cloud-sdk (GCLOUDSDK_PREFIX)
    local _GCLOUDSDK_PREFIX=${1:-${GCLOUDSDK_PREFIX:-"${HOME}/google-cloud-sdk"}}
    echo "${_GCLOUDSDK_PREFIX}"
}

function _setup_GCLOUDSDK_PREFIX {
    ## _setup_GCLOUDSDK_PREFIX() -- configure gcloud $PATH and bash completions
    #   $1 (str): default:~/google-cloud-sdk (GCLOUDSDK_PREFIX)
    export GCLOUDSDK_PREFIX="${1:-"$(_get_GCLOUDSDK_PREFIX ${1:+"${1}"})"}"
}

function _setup_gcloudsdk {
    ## _setup_gcloudsdk() -- configure gcloud $PATH and bash completions
    #   $1 (str): default:~/google-cloud-sdk (GCLOUDSDK_PREFIX)
    _setup_GCLOUDSDK_PREFIX "${1:+"${1}"}"

    #The next line updates PATH for the Google Cloud SDK.
    # shellcheck disable=1090
    source "${GCLOUDSDK_PREFIX}/path.bash.inc"

    #The next line enables bash completion for gcloud.
    # shellcheck disable=1090
    source "${GCLOUDSDK_PREFIX}/completion.bash.inc"
}

function _unsetup_gcloudsdk {
    ## _unsetup_gcloudsdk() -- unset GCLOUDSDK_PREFIX
    unset GCLOUDSDK_PREFIX
    # XXX: PATH_remove <...>
}


function _get_APPENGINESDK_PREFIX {
    ## _get_APPENGINESDK_PREFIX()  -- get APPENGINESDK_PREFIX
    local _APPENGINESDK_PREFIX=
    if [ -n "${APPENGINESDK_PREFIX}" ]; then
        _APPENGINESDK_PREFIX="${APPENGINESDK_PREFIX}"
    else
        local _APPENGINESDK_BASEPATH
        local _GCLOUDSDK_PREFIX
        _GCLOUDSDK_PREFIX="$(_get_GCLOUDSDK_PREFIX)"
        if [ -n "${_GCLOUDSDK_PREFIX}" ]; then
            _APPENGINESDK_BASEPATH="${_GCLOUDSDK_PREFIX}/platform"
        else
            _APPENGINESDK_BASEPATH="/usr/local"
        fi
        _APPENGINESDK_PREFIX="${_APPENGINESDK_BASEPATH}/google_appengine"
    fi
    echo "${_APPENGINESDK_PREFIX}"
}

function _setup_APPENGINESDK_PREFIX {
    ## _setup_APPENGINESDK_PREFIX() -- configure gcloud $PATH and completion
    #   $1 (str): default:~/google-cloud-sdk (APPENGINESDK_PREFIX)
    local _APPENGINESDK_PREFIX=
    if [ -n "${1}" ]; then
        _APPENGINESDK_PREFIX="${1}"
    else
        local _GCLOUDSDK_PREFIX
        _GCLOUDSDK_PREFIX="$(_get_GCLOUDSDK_PREFIX)"
        if [ -d "${_GCLOUDSDK_PREFIX}" ]; then
            _setup_GCLOUDSDK_PREFIX
        fi
        _APPENGINESDK_PREFIX="$(_get_APPENGINESDK_PREFIX)"
    fi
    export APPENGINESDK_PREFIX="${_APPENGINESDK_PREFIX}"
}

function _setup_appenginesdk {
    ## _setup_appenginesdk() -- config GCLOUDSDK*, APPENGINESDK_PREFIX, PATH
    #   $1 (str): default: ~/google-cloud-sdk/platform/google_appengine
    #             default: /usr/local/google_appengine
    #             ${APPENGINESDK_PREFIX}
    _setup_APPENGINESDK_PREFIX ${1:+"${1}"}
    PATH_prepend "${APPENGINESDK_PREFIX}"
}

function _unsetup_appenginesdk {
    ## _unsetup_appenginesdk() -- PATH_remove ${APPENGINESDK_PREFIX}
    if [ -n "${APPENGINESDK_PREFIX}" ]; then
        PATH_remove "${APPENGINESDK_PREFIX}"
    fi
    unset APPENGINESDK_PREFIX
}
#!/usr/bin/env bash
### bashrc.venv.sh
#   note: most of these aliases and functions are overwritten by `we` 
## Variables


function _setup_venv {
    # _setup_venv()    -- configure __PROJECTSRC, PATH, __VENV, _setup_venv_SRC()
    #  __PROJECTSRC (str): path to local project settings script to source
    export __PROJECTSRC="${__WRK}/.projectsrc.sh"
    # shellcheck disable=1090
    [ -f "$__PROJECTSRC" ] && source "$__PROJECTSRC"

    # PATH="~/.local/bin:$PATH" (if not already there)
    PATH_prepend "${HOME}/.local/bin"

    # __VENV      -- path to local venv config script (executable)
    export __VENV="${__DOTFILES}/scripts/venv.py"

    # CdAlias functions and completions
    # shellcheck source=../venv/scripts/venv.sh
    source "${__DOTFILES}/etc/venv/scripts/venv.sh"
    if [ "${VENVPREFIX}" == "/" ]; then
        # shellcheck source=../venv/scripts/venv_root_prefix.sh
        source "${__DOTFILES}/etc/venv/scripts/venv_root_prefix.sh"
    fi

    # You must run this manually if you want a default src venv
    # _setup_venv_SRC
}


function _setup_venv_SRC {
    # _setup_venv_SRC() -- configure __SRCVENV and __SRC global virtualenv
    # __SRCVENV (str): global 'src' venv symlink (~/-wrk/src)
    #                  (e.g. ln -s ~/-wrk/-ve27/src ~/-wrk/src)
    export __SRCVENV="${__WRK}/src"
    # __SRC     (str): global 'src' venv ./src directory path (~/-wrk/src/src)
    export __SRC="${__SRCVENV}/src"

    if [ ! -e "${__SRCVENV}" ]; then
        if [ ! -d "${WORKON_HOME}/src" ]; then
            mkvirtualenv -p "$(command -v python)" \
                -i pyrpo -i pyline -i pgs src
        fi
        ln -s "${WORKON_HOME}/src" "${__SRCVENV}"
    fi

    #               ($__SRC/git $__SRC/git)
    if [ ! -d "$__SRC" ]; then
        mkdir -p \
            "${__SRC}/git/github.com" \
            "${__SRC}/git/gitlab.com" \
            "${__SRC}/git/bitbucket.org" \
            "${__SRC}/hg/bitbucket.org"
    fi
}

_setup_venv
#!/bin/sh
## venv.sh
# generated from $(venv --print-bash --prefix=/)


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

eval '
cdcondaenvspath () {
    # cdcondaenvspath   -- cd $CONDA_ENVS_PATH /$@
    [ -z "$CONDA_ENVS_PATH" ] && echo "CONDA_ENVS_PATH is not set" && return 1
    cd "$CONDA_ENVS_PATH"${@:+"/${@}"}
}
_cd_CONDA_ENVS_PATH_complete () {
    local cur="$2";
    COMPREPLY=($(cdcondaenvspath && compgen -d -- "${cur}" ))
}
cda () {
    # cda               -- cd $CONDA_ENVS_PATH
    cdcondaenvspath $@
}
cdce () {
    # cdce              -- cd $CONDA_ENVS_PATH
    cdcondaenvspath $@
}
complete -o default -o nospace -F _cd_CONDA_ENVS_PATH_complete cdcondaenvspath
complete -o default -o nospace -F _cd_CONDA_ENVS_PATH_complete cda
complete -o default -o nospace -F _cd_CONDA_ENVS_PATH_complete cdce

';

cdcondaenvspath () {
    # cdcondaenvspath   -- cd $CONDA_ENVS_PATH /$@
    [ -z "$CONDA_ENVS_PATH" ] && echo "CONDA_ENVS_PATH is not set" && return 1
    cd "$CONDA_ENVS_PATH"${@:+"/${@}"}
}
_cd_CONDA_ENVS_PATH_complete () {
    local cur="$2";
    COMPREPLY=($(cdcondaenvspath && compgen -d -- "${cur}" ))
}
cda () {
    # cda               -- cd $CONDA_ENVS_PATH
    cdcondaenvspath $@
}
cdce () {
    # cdce              -- cd $CONDA_ENVS_PATH
    cdcondaenvspath $@
}
complete -o default -o nospace -F _cd_CONDA_ENVS_PATH_complete cdcondaenvspath
complete -o default -o nospace -F _cd_CONDA_ENVS_PATH_complete cda
complete -o default -o nospace -F _cd_CONDA_ENVS_PATH_complete cdce

eval '
cdcondaroot () {
    # cdcondaroot       -- cd $CONDA_ROOT /$@
    [ -z "$CONDA_ROOT" ] && echo "CONDA_ROOT is not set" && return 1
    cd "$CONDA_ROOT"${@:+"/${@}"}
}
_cd_CONDA_ROOT_complete () {
    local cur="$2";
    COMPREPLY=($(cdcondaroot && compgen -d -- "${cur}" ))
}
cdr () {
    # cdr               -- cd $CONDA_ROOT
    cdcondaroot $@
}
complete -o default -o nospace -F _cd_CONDA_ROOT_complete cdcondaroot
complete -o default -o nospace -F _cd_CONDA_ROOT_complete cdr

';

cdcondaroot () {
    # cdcondaroot       -- cd $CONDA_ROOT /$@
    [ -z "$CONDA_ROOT" ] && echo "CONDA_ROOT is not set" && return 1
    cd "$CONDA_ROOT"${@:+"/${@}"}
}
_cd_CONDA_ROOT_complete () {
    local cur="$2";
    COMPREPLY=($(cdcondaroot && compgen -d -- "${cur}" ))
}
cdr () {
    # cdr               -- cd $CONDA_ROOT
    cdcondaroot $@
}
complete -o default -o nospace -F _cd_CONDA_ROOT_complete cdcondaroot
complete -o default -o nospace -F _cd_CONDA_ROOT_complete cdr

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

eval 'cdls () {
    set | grep "^cd.*()" | cut -f1 -d" " #${@}
}';
cdls () {
    set | grep "^cd.*()" | cut -f1 -d" " #${@}
}
alias cdhelp="cat ${__DOTFILES}/''scripts/venv_cdaliases.sh | pyline.py -r '^\\s*#+\\s+.*' 'rgx and l'" ;

## Functions

function venv {
    # venv $@   -- call $_VENV $@
    # venv -h   -- print venv --help
    # venv --print-bash   -- print bash configuration
    # venv --print-json   -- print IPython configuration as JSON
    (set -x; $__VENV "${@}")
}
function venvw {
    # venvw $@ -- venv -E $@ (for the current environment)
    (set -x; $__VENV -e "${@}")
}

function workon_venv {
    # workon_venv() -- workon a virtualenv and load venv (TAB-completion)
    #  param $1: $VIRTUAL_ENV_NAME ("dotfiles")
    #  param $2: $_APP ("dotfiles") [default: $1)
    #   ${WORKON_HOME}/${VIRTUAL_ENV_NAME}  # == $VIRTUAL_ENV
    #   ${VIRTUAL_ENV}/src                  # == $_SRC
    #   ${_SRC}/${VIRTUAL_ENV_NAME}         # == $_WRD
    #  examples:
    #   we dotfiles
    #   we dotfiles dotfiles

    if [ -n "${1}" ]; then
        local _venvstr
        local _workon_home
        if [ -d "${WORKON_HOME}/${1}" ]; then
           _venvstr="${1}"
           _workon_home="${WORKON_HOME}"
           shift
        elif [ -d "${1}" ]; then
           _venvstr="$(basename "${1}")"
           _workon_home="$(dirname "${1}")"
           shift
        else
           echo "err: venv not found: ${1}"
           return 1
        fi

        #append to shell history
        history -a

        # shellcheck disable=1090
        workon "${_venvstr}" && \
            source <($__VENV \
            dotfiles_status && \
            declare -f '_setup_venv_prompt' > /dev/null 2>&1 \
            && _setup_venv_prompt "${_TERM_ID:-${_venvstr}}"
    else
        #if no arguments are specified, list virtual environments
        lsvirtualenvs
        return 1
    fi
}
function we {
    # we()          -- workon_venv
    workon_venv "${@}"
}
complete -o default -o nospace -F _virtualenvs workon_venv
complete -o default -o nospace -F _virtualenvs we


function _setup_venv_aliases {
    # _setup_venv_aliases()  -- load venv aliases
    #   note: these are overwritten by `we` [`source <(venv -b)`]

    # shellcheck source=../../scripts/_ewrd.sh
    source "${__DOTFILES}/scripts/_ewrd.sh"

    # shellcheck source=../../scripts/_grinwrd.sh
    source "${__DOTFILES}/scripts/_grinwrd.sh"

    # makew     -- make -C "${WRD}" ${@}    [scripts/makew <TAB>]
    # shellcheck source=../../scripts/makew
    source "${__DOTFILES}/scripts/makew"

    # shellcheck source=../../scripts/ssv
    source "${__DOTFILES}/scripts/ssv"
    # shellcheck disable=2119
    _setup_supervisord

    # hgw       -- hg -R  ${_WRD}   [scripts/hgw <TAB>]
    # shellcheck source=../../scripts/hgw
    source "${__DOTFILES}/scripts/hgw"

    # gitw      -- git -C ${_WRD}   [scripts/gitw <TAB>]
    # shellcheck source=../../scripts/gitw
    source "${__DOTFILES}/scripts/gitw"

    # serve-()  -- ${_SERVE_}
    # alias serve-='${_SERVE_}'
    # shell-()  -- ${_SHELL_}
    # alias shell-='${_SHELL_}'
    # test-()   -- cd ${_WRD} && python setup.py test
    alias testpyw='(cd ${_WRD} && python "${_WRD_SETUPY}" test)'
    # testr-()  -- reset; cd ${_WRD} && python setup.py test
    alias testpywr='(reset; cd ${_WRD} && python "${_WRD_SETUPY}" test)'

}
_setup_venv_aliases
#!/usr/bin/env bash

###   _ewrd.sh  -- convenient editor shortcuts
#     # setup edit[*] and e[*] symlinks:
#     $ ln -s ./_ewrd.sh _ewrd-setup.sh && ./_ewrd-setup.sh

##    e, edit         -- edit a file, list editors, or set editor
function e {
    # e() -- Default editor wrapper with support for listing and setting editors.
    # e <file>             -- Edit file with $EDITOR (default: vim)
    # e -- <file>          -- Edit a file (use -- to edit files named -l, set, etc.)
    #
    # e -l/--list          -- List available editors and current settings
    # e -s/--set <name>       -- Print shell export command for setting $EDITOR
    #
    # e -h/--help          -- Show this help and editor's help
  
    POSSIBLE_EDITORS="code.sh code gvim nvim mvim vim nano vi emacs gedit kate spyder flatpak gvim-venv nvim-venv"

    if [[ "$1" == "-l" || "$1" == "--list" ]]; then
        echo "## Current settings:"
        echo "  EDITOR=${EDITOR}"
        echo "  EDITOR_=${EDITOR_}"
        echo ""
        echo "  VIMCONF=${VIMCONF}"
        echo "  GUIVIMBIN=${GUIVIMBIN}"
        echo "  GVIMBIN=${GVIMBIN}"
        echo "  MVIMBIN=${MVIMBIN}"
        echo ""
        echo "## Available editors:"
        echo ""
        for ed in ${POSSIBLE_EDITORS}; do
            if type "$ed" >/dev/null 2>&1; then
                (set -x; type -a "$ed")
            else
                echo "+ type -a ${ed}"
            fi
            echo ""
        done
        echo "## Current settings:"
        echo "  EDITOR=${EDITOR}"
        echo "  EDITOR_=${EDITOR_}"
        return 0
    elif [[ "$1" == "-s" ]] || [[ "$1" == "--set" ]]; then
        local editor_choice="$2"
        echo "#xport EDITOR=\"$EDITOR\"" >&2  # current value of EDITOR"
        case "$editor_choice" in
            nano) _editor="nano" ;;

            vi)   _editor="vi" ;;
            vim)  _editor="vim" ;;
            gvim) _editor="gvim" ;;
            gvim-venv) _editor="gvim \${VIMCONF}" ;;
            mvim) _editor="mvim" ;;
            nvim) _editor="nvim" ;;
            nvim-venv) _editor="nvim \${VIMCONF/--servername/--server}" ;;

            gedit) _editor="gedit" ;;
            kate) _editor="kate" ;;

            spyder) _editor="spyder" ;;

            code) _editor="code" ;;
            code.sh) _editor="code.sh" ;;
            com.visualstudio.code) _editor="flatpak run com.visualstudio.code" ;;
            
            org.gnome.TextEditor|TextEditor) _editor="flatpak run org.gnome.TextEditor" ;;


            "")   echo "Error: Must specify editor name (e.g., code, vim)" >&2; return 1 ;;
            *)    _editor="$editor_choice" ;;
        esac
        echo "export EDITOR=\"${_editor}\""
        export EDITOR="${_editor}"
        return 0
    elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
        # print function docstring
        grep -E '^    # e' "${BASH_SOURCE[0]:-${__DOTFILES}/scripts/_ewrd.sh}" || true
        echo ""
        local _editor="${EDITOR:-vim}"
        echo "Help for configured editor: $_editor"
        (set -x; $_editor "$1")
        return 0

    # Otherwise, pass through to the editor
    # else  
    #     echo "ERR: Unknown argument '$1'"

    fi

    local _editor="${EDITOR:-vim}"
    
    if [[ "$1" == "--" ]]; then
        shift
    fi

    # Expand default aliases if necessary, otherwise just run directly
    $_editor "${@}"
}

function _e__complete {
    local cur=${2}
    local prev=${3}
    if [[ "$prev" == "set" ]] || [[ "$prev" == "-s" ]]; then
        COMPREPLY=( $(compgen -W "code.sh code com.visualstudio.code vim gvim gvim-venv nvim nvim-venv mvim vi nano gedit kate spyder org.gnome.TextEditor TextEditor" -- "$cur") )
    else
        COMPREPLY=( $(compgen -W "-l --list set -h --help --" -- "$cur") )
        # Also include files/directories as fallback
        COMPREPLY+=( $(compgen -f -- "$cur") )
    fi
}
complete -o bashdefault -o default -o nospace -F _e__complete e
complete -o bashdefault -o default -o nospace -F _e__complete edit


##    editdotfiles, edotfiles -- cd $__DOTFILES and run edit w/ each arg
function editdotfiles {
    # editdotfiles() -- cd $__DOTFILES and run edit w/ each arg
    (cd "${__DOTFILES}"; e "${@}")
    return
}

function edotfiles {
    # edotfiles()    -- cd $__DOTFILES and run edit w/ each arg
    editdotfiles "${@}"
    return
}

function _edotfiles__complete {
    local cur=${2};
    COMPREPLY=($(cd "${__DOTFILES}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _edotfiles__complete editdotfiles
complete -o default -o nospace -F _edotfiles__complete edotfiles


##    editwrk, ewrk   --- cd $__WRK and run edit w/ each arg
function editwrk {
    # editwrk()      -- cd $__WRK and run edit w/ each arg
    (cd "${__WRK}"; e "${@}")
    return
}

function ewrk {
    # ewrk()         -- cd $__WRK and run edit w/ each arg
    editwrk "${@}"
    return
}

function _ewrk__complete {
    local cur=${2};
    COMPREPLY=($(cd "${__WRK}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _ewrk__complete editwrk
complete -o default -o nospace -F _ewrk__complete ewrk


##    editworkonhome, eworkonhome --- cd $WORKON_HOME and run edit w/ each arg
function editworkonhome {
    # editworkonhome() -- cd $WORKON_HOME and run edit w/ each arg
    (cd "${WORKON_HOME}"; e "${@}")
    return
}

function eworkonhome {
    # eworkonhome()    -- cd $WORKON_HOME and run edit w/ each arg
    editworkonhome "${@}"
    return
}

function ewh {
    # ewh()            -- cd $WORKON_HOME and run edit w/ each arg
    editworkonhome "${@}"
    return
}

function _eworkonhome__complete {
    local cur=${2};
    COMPREPLY=($(cd "${WORKON_HOME}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _eworkonhome__complete editworkonhome
complete -o default -o nospace -F _eworkonhome__complete eworkonhome
complete -o default -o nospace -F _eworkonhome__complete ewh



##    editvirtualenv, evirtualenv, ev  --- cd $VIRTUAL_ENV and run edit w/ each arg
function editvirtualenv {
    # editvirtualenv() -- cd $VIRTUAL_ENV and run edit w/ each arg
    (cd "${VIRTUAL_ENV}"; e "${@}")
    return
}

function evirtualenv {
    # evirtualenv()    -- cd $VIRTUAL_ENV and run edit w/ each arg
    editvirtualenv "${@}"
    return
}

function ev {
    # ev()             -- cd $VIRTUAL_ENV and run edit w/ each arg
    editvirtualenv "${@}"
    return
}

function _evirtualenv__complete {
    local cur=${2};
    COMPREPLY=($(cd "${VIRTUAL_ENV}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _evirtualenv__complete editvirtualenv
complete -o default -o nospace -F _evirtualenv__complete evirtualenv
complete -o default -o nospace -F _evirtualenv__complete ev


##    editsrc, esrc, es  --- cd $_SRC and run edit w/ each arg
function editsrc {
    # editsrc() -- cd $_SRC and run edit w/ each arg
    (cd "${_SRC}"; e "${@}")
    return
}

function esrc {
    # esrc()    -- cd $_SRC and run edit w/ each arg
    editsrc "${@}"
    return
}

function es {
    # es()      -- cd $_SRC and run edit w/ each arg
    editsrc "${@}"
    return
}

function _esrc__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_SRC}" || return; compgen -f -- ${cur}));
    #COMPREPLY=("$(cd "${_SRC}" || return; compgen -f -- "${cur}")");
}
complete -o default -o nospace -F _esrc__complete editsrc
complete -o default -o nospace -F _esrc__complete esrc
complete -o default -o nospace -F _esrc__complete es


##    editwrd, ewrd, ew  --- cd $_WRD and run edit w/ each arg
function editwrd {
    # editwrd() -- cd $_WRD and run edit w/ each arg
    (cd "${_WRD}"; e "${@}")
    return
}

function ewrd {
    # ewrd()    -- cd $_WRD and run edit w/ each arg
    editwrd "${@}"
    return
}

function ew {
    # ew()      -- cd $_WRD and run edit w/ each arg
    editwrd "${@}"
    return
}

function _ewrd__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_WRD}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _ewrd__complete editwrd
complete -o default -o nospace -F _ewrd__complete ewrd
complete -o default -o nospace -F _ewrd__complete ew


##    editetc, eetc      --- cd $_ETC and run edit w/ each arg
function editetc {
    # editetc() -- cd $_ETC and run edit w/ each arg
    (cd "${_ETC}"; e "${@}")
    return
}

function eetc {
    # eetc()    -- cd $_ETC and run edit w/ each arg
    editetc "${@}"
    return
}

function _eetc__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_ETC}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _eetc__complete editetc
complete -o default -o nospace -F _eetc__complete eetc


##    editwww, ewww      --- cd $_WWW and run edit w/ each arg
function editwww {
    # editwww() -- cd $_WWW and run edit w/ each arg
    (cd "${_WWW}"; e "${@}")
    return
}

function ewww {
    # ewww()    -- cd $_WWW and run edit w/ each arg
    editwww "${@}"
    return
}

function _ewww__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_WWW}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _ewww__complete editwww
complete -o default -o nospace -F _ewww__complete ewww



function _create_ewrd_symlinks {
    local scriptname='_ewrd.sh'
    local scriptnames=(
        "e"
        "edit"

        "editdotfiles"
        "edotfiles"

        "editwrk"
        "ewrk"

        "editworkonhome"
        "eworkonhome"
        "ewh"

        "editvirtualenv"
        "evirtualenv"
        "ev"

        "editsrc"
        "esrc"
        "es"

        "editwrd"
        "ewrd"
        "ew"

        "editetc"
        "eetc"

        "editwww"
        "ewww"
    )
    for symlinkname in "${scriptnames[@]}"; do
        test -L "${symlinkname}" && rm "${symlinkname}"
        ln -s "${scriptname}" "${symlinkname}"
    done
}

#_ewrd.sh main()
if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    set -x
    declare -r progname="$(basename "${BASH_SOURCE}")"
    case "${progname}" in
        e|edit)
            e "${@}"
            exit
            ;;

        editdotfiles|edotfiles)
            editdotfiles "${@}"
            exit
            ;;

        editwrk|ewrk)
            editwrk "${@}"
            exit
            ;;

        editworkonhome|eworkonhome|ewh)
            editworkonhome "${@}"
            exit
            ;;

        editvirtualenv|evirtualenv|ev)
            editvirtualenv "${@}"
            exit
            ;;
        editsrc|esrc|es)
            editsrc "${@}"
            exit
            ;;
        editwrd|ewrd|ew)
            editwrd "${@}"
            exit
            ;;
        editetc|eetc)
            editetc "${@}"
            exit
            ;;
        editwww|ewww)
            editwww "${@}"
            exit
            ;;

        _ewrd.sh|edithelp|ehelp)
            #cat "${BASH_SOURCE}" | \
            #    pyline.py -r '^\s*#+\s+.*' 'rgx and l';
            cat "${BASH_SOURCE}" | \
                grep -E '^\s*#+\s+.*'
            exit
            ;;

        _ewrd-setup.sh)
            _create_ewrd_symlinks
            exit
            ;;
        *)
            echo "Err"
            echo '${BASH_SOURCE}: '"'${BASH_SOURCE}'"
            echo '${progname}: '"'${BASH_SOURCE}'"
            exit 2
            ;;
    esac
    exit
fi
#

## seeAlso ##
# * https://westurner.org/dotfiles/venv
#
# .. code:: bash
#
#    type cdhelp; cdhelp 
#    less scripts/venv_cdaliases.sh
#    venv.py --prefix=/ --print-bash-cdaliases

#!/usr/bin/env bash

### _grinwrd.sh --- Grin search functions

# TODO:
#  - [ ] TST: *
#  - [ ] Normalize pass-through argument handling (e.g. ``grin -C 10``)

## seeAlso ##
#* https://westurner.org/dotfiles/venv

function grinwrk {
    # grinwrk()   -- grin $__WRK
    grin --follow "$@" "${__WRK}"
}

function grindwrk {
    # grindwrk()  -- grind $__WRK
    grind --follow "$@" --dirs "${__WRK}"
}

function grinph {
    # grinph()   -- grin $PROJECT_HOME
    grin --follow "$@" "${PROJECT_HOME}"
}

function grindph {
    # grindph()  -- grind $PROJECT_HOME
    grind --follow "$@" --dirs "${PROJECT_HOME}"
}

function grinwh {
    # grinwh()   -- grin $WORKON_HOME
    grin --follow "$@" "${WORKON_HOME}"
}

function grindwh {
    # grindwh()  -- grind $WORKON_HOME
    grind --follow "$@" --dirs "${WORKON_HOME}"
}

function grincr {
    # grincr()   -- grin $CONDA_ROOT
    grin --follow "$@" "${CONDA_ROOT}"
}

function grindcr {
    # grindcr()  -- grind $CONDA_ROOT
    grind --follow "$@" --dirs "${CONDA_ROOT}"
}

function grince {
    # grince()   -- grin $CONDA_ENVS_PATH
    grin --follow "$@" "${CONDA_ENVS_PATH}"
}

function grindce {
    # grindce()  -- grind $CONDA_ENVS_PATH
    grind --follow "$@" --dirs "${CONDA_ENVS_PATH}"
}

# virtualenv & virtualenvwrapper
function grinv {
    # grinv()   -- grin $VIRTUAL_ENV
    grin --follow "$@" "${VIRTUAL_ENV}"
}

function grindv {
    # grindv()  -- grind $VIRTUAL_ENV
    grind --follow "$@" --dirs "${VIRTUAL_ENV}"
}

# venv
function grins {
    # grins()   -- grin $_SRC
    grin --follow "$@" "${_SRC}"
}

function grinds {
    # grinds()  -- grind $_SRC
    grind --follow "$@" --dirs "${_SRC}"
}

function grinw {
    # grinw()   -- grin $_WRD
    grin --follow "$@" "${_WRD}"
}

function grindw {
    # grindw()  -- grind $_WRD
    grind --follow $@ --dirs "${_WRD}"
}

function edit_grin_w {
    # edit_grin_w() -- edit $(grinw -l $@)
    edit $(grinw -l "$@")
}

function egw {
    # egw           -- edit $(grinw -l $@)
    edit_grin_w "$@"
}

function edit_grind_wrd {
    (IFS='\n' edit $(grind "${@}" --follow --dirs "${_WRD}"))
    grindw "${@}" | el -v -e
}

## ctags (exuberant ctags)
# brew install ctags
# apt-get install exuberant-ctags
# dnf install ctags ctags-etags
function grindctags {
    # grindctags()      -- generate ctags from grind (in ./tags)
    local ctagsbin=
    local path=${1:-'.'}
    shift
    # local grindargs=${@}
    if [ -n "${__IS_MAC}" ]; then
        if [ -x "/usr/local/bin/ctags" ]; then
            # brew install ctags
            ctagsbin="/usr/local/bin/ctags"
        else
            ctagsbin=$(which ctags)
        fi
    else
        ctagsbin=$(which ctags)
    fi
    (set -x -v;
    cd "${path}";
    grind --follow "${@}" --dirs "${path}" \
        | grep -v 'min.js$' \
        | ${ctagsbin} -L - 2>"${path}/tags.err" \
        && wc -l "${path}/tags.err";
    ls -alhtr "${path}/tags"* ;)
}

function grindctagssys {
    # grindctagssys()   -- generate ctags from grind --sys-path ($_WRD/tags)
    grindctags "${_WRD}" "--sys-path"
}

function grindctagswrd {
    # grindctagswrd()   -- generate ctags from (cd $_WRD; grind) ($_WRD/tags)
    grindctags "${_WRD}"
}

function grindctagsssrc {
    # grindctagssrc()   -- generate ctags from (cd $_SRC; grind) ($_SRC/tags)
    grindctags "${_SRC}"
}


function _create_grinwrd_symlinks {
    local scriptname='_grinwrd.sh'
    local scriptnames=(

        "grinwrk"
        "grindwrk"

        "grinph"
        "grinprojecthome"
        "grindph"
        "grindprojecthome"

        "grinwh"
        "grinworkonhome"
        "grindwh"
        "grindworkonhome"

        "grincr"
        "grincondaroot"
        "grindcr"
        "grindcondaroot"

        "grince"
        "grincondaenvspath"
        "grindce"
        "grindcondaenvspath"

        "grinvirtualenv"
        "grinv"
        "grindvirtualenv"
        "grindv"

        "grinsrc"
        "grins"
        "grindsrc"
        "grinds"

        "grinwrd"
        "grinw"
        "grindwrd"
        "grindw"

        "editgrinw"
        "egrinw"
        "egw"

        "editgrindw"
        "egrindw"

        "grindctags"

        "grindctagssys"

        "grindctagswrd"
        "grindctagsw"

        "grindctagssrc"
        "grindctagss"

        "grinwrdhelp"
        "grindwrdhelp"
    )
    for symlinkname in ${scriptnames[@]}; do
        test -L "${symlinkname}" && rm "${symlinkname}"
        ln -s "${scriptname}" "${symlinkname}"
    done
}

#_grinwrd.sh main()
if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    set -x
    declare -r progname="$(basename ${BASH_SOURCE})"
    case "${progname}" in
        grinwrk)
            grinwrk "${@}"
            exit
            ;;
        grindwrk)
            grindwrk "${@}"
            exit
            ;;

        grinprojecthome|grinph)
            grinph "${@}";
            exit
            ;;
        grindprojecthome|grindph)
            grindph "${@}"
            exit
            ;;

        grinworkonhome|grinwh)
            grinwh "${@}";
            exit
            ;;
        grindworkonhome|grindwh)
            grindwh "${@}"
            exit
            ;;

        grincondaroot|grincr)
            grincr "${@}"
            exit
            ;;
        grindcondaroot|grindcr)
            grindcr "${@}"
            exit
            ;;

        grincondaenvs|grince)
            grince "${@}"
            exit
            ;;
        grindcondaenvs|grindce)
            grindce "${@}"
            exit
            ;;

        grinvirtualenv|grinv)
            grinv "${@}"
            exit
            ;;
        grindvirtualenv|grindv)
            grindv "${@}"
            exit
            ;;

        grinsrc|grins)
            grinv "${@}"
            exit
            ;;
        grindsrc|grinds)
            grinds "${@}"
            exit
            ;;

        grinwrd|grinw)
            grinw "${@}"
            exit
            ;;
        grindwrd|grindw)
            grindw "${@}"
            exit
            ;;

        editgrinw|egrinw|egw)
            edit_grin_w "${@}"
            exit
            ;;

        editgrindw|egrindw)
            edit_grind_w "${@}"
            exit
            ;;

        grindctags)
            grindctags "${@}"
            exit
            ;;

        grindctagssys)
            grindctagssys "${@}"
            exit
            ;;

        grindctagssrc|grindctagss)
            grindctagssrc "${@}"
            exit
            ;;

        grindctagswrd|grindctagsw)
            grindctagswrd "${@}"
            exit
            ;;

        _grinwrd.sh|grinwrdhelp|grindwrdhelp)
            cat "${BASH_SOURCE}" | \
                pyline.py -r '^\s*#+\s+.*' 'rgx and l';
            exit
            ;;

        _grinwrd-setup.sh)
            _create_grinwrd_symlinks
            exit
            ;;
        *)
            echo "Err"
            echo '${BASH_SOURCE}: '"'${BASH_SOURCE}'"
            echo '${progname}: '"'${BASH_SOURCE}'"
            exit 2
            ;;
    esac
    exit
fi
#

## seeAlso ##
# * https://westurner.org/dotfiles/venv
# * _ewrd.sh
#!/usr/bin/env bash
## 

_makew() {
    # makew()   -- cd "$_WRD" && make "$@"
    if [ -z "${_WRD}" ]; then
        echo '_WRD= must be set' >&2
	return 2
    fi
    if [ ! -e "${_WRD}" ]; then
        echo '_WRD='"$_WRD doesn't exist" >&2
	return 2
    fi
    (make -C "${_WRD}" "${@}")
}
_makew_complete() {
    local cur=${2}
    # see: /usr/local/etc/bash_completion.d/make (brew)
    COMPREPLY=( $( compgen -W "$( make -C "${_WRD}" -qp 2>/dev/null | \
}
complete -F _makew_complete makew

if [[ "${BASH_SOURCE}" == "${0}" ]]; then
    echo '_WRD='"$_WRD"
    _makew "${@}"
fi
#!/bin/sh

##
#  ssv -- a command wrapper for common supervisord commands
#  
#  Variables
#    _SVCFG     -- absolute path to a supervisord.conf file
#      _SVCFG="${VIRTUAL_ENV}/etc/supervisord.conf"  # (default)
#      _SVCFG="${_WRD}/supervisord.conf"
#
#  .. note::  supervisord paths containing ``%(here)s`` evaluate
#      to the (TODO verify) os.realpath of the file.
#      if symlinked from _WRD/supervisord.conf to _ETC/supervisord.conf,
#      paths require an additional upward traversal. 
#      For example::
#
#         # Relative to VIRTUAL_ENV/etc
#         program=%(here)s/../bin/theprogramtorun

#         # Relative to VIRTUAL_ENV/src/<dotfiles>
#         program=%(here)s/../../bin/theprogramtorun
#
#
#  These functions can be utilized in a number of ways:
#
#  * As shell scripts (symlinked to ssv)
#  * As shell functions (``source $__DOTFILES/scripts/ssv``)


function supervisord_sv_create_symlinks() {
    src="${BASH_SOURCE}"
    test -e sv  || ln -s ${src} sv    # supervisorctl $@
    test -e svs || ln -s ${src} svs   # supervisorctl status $@
    test -e svr || ln -s ${src} svr   # supervisorctl restart $@
    test -e svt || ln -s ${src} svt   # supervisorctl tail $@
    test -e svd || ln -s ${src} svd   # sv restart $1:-"dev" && sv tail 'dev'
    test -e sve || ln -s ${src} sve   # EDITOR[_] $_SVCFG
}

function _setup_supervisord() {
    #  _setup_supervisord()      -- set _SVCFG to a supervisord.conf
    local svcfg=${1:-${_SVCFG}}
    if [ -z "${svcfg}" ]; then
        if [ -n "${VIRTUAL_ENV}" ]; then
            local _svcfg="${VIRTUAL_ENV}/etc/supervisord.conf"
        else
            local _svcfg="supervisord.conf"
        fi
        if [ -n "${_svcfg}" ]; then
            svcfg="${_svcfg}"
        fi
    fi
    export _SVCFG="${svcfg}"
}

## 
function supervisord_start() {
    #  supervisord_start()      -- start supervisord -c $_SVCFG
    supervisord -c "${_SVCFG}"
    return
}
function ssv() {
    #  ssv()                    -- start supervisord -c $_SVCFG
    supervisord_start $@
    return
}
function sv() {
    #  sv()                     -- supervisorctl -c $_SVCFG
    supervisorctl -c "${_SVCFG}" ${@}
    return
}
function svs() {
    #  svs()                    -- sv status $@
    sv status ${@}
    return
}
function svr() {
    #  svr()                    -- sv restart $@
    sv restart ${@}
    return
}

function svd() {
    # svd()                     -- sv restart ${1:-"dev"} && sv tail -f ${1:-"dev"}
    name=${1:-"dev"}
    sv restart "${name}" && sv tail -f "${name}"
}

function svt() {
    # svt()                     -- sv tail -f
    name=${1}
    sv tail -f ${name}
}

function sve() {
    #  sve()                    -- $EDITOR[_] $_SVCFG
    ${EDITOR_:-${EDITOR}} ${1:-${_SVCFG}}
}



function supervisord_stop() {
    #  supervisord_start()      -- start supervisord
    supervisorctl -c "${_SVCFG}" "shutdown"
    return
}

# echo "${BASH_SOURCE}"
# echo "${0}"

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    _setup_supervisord

    cmd=$(basename "${0}")
    echo "cmd: ${cmd}"

    case "${cmd}" in
        sve)
            sve ${@}
            ;;
        ssv)
            supervisord_start ${@}
            ;;
        sv)
            sv ${@}
            ;;
        svd)
            svd ${@}
            ;;
        svt)
            svt ${@}
            ;;
        svs)
            svs ${@}
            ;;
    esac
    exit
fi
#!/bin/sh
## 
function __hgw() {
    #  hgw()                    -- hg -R "${_WRD}" $@
    hg -R "${_WRD}" $@
}

# see: /mercurial/contrib/bash_completion
complete -o bashdefault -o default -o nospace -F _hg hgw \
    || complete -o default -o nospace -F _hg hgw

if [[ ${BASH_SOURCE} == "${0}" ]]; then
    __hgw ${@}
fi
#!/bin/
## 
function gitw () {
    #  gitw()                    -- git -C "${_WRD}" $@
    git -C "${_WRD}" "${@}"
}
declare -f '__git_complete' 2>&1 >/dev/null && __git_complete gitw __git_main
declare -f '__git_complete' 2>&1 >/dev/null && __git_complete gitkw __gitk_main

if [[ ${BASH_SOURCE} == "${0}" ]]; then
    gitw "${@}"
fi


function _setup_venv_prompt {
    # _setup_venv_prompt()    -- set PS1 with $WINDOW_TITLE, $VIRTUAL_ENV_NAME,
    #                          and ${debian_chroot}
    #           "WINDOW_TITLE (venvprompt) [debian_chroot]"
    # try: _APP, VIRTUAL_ENV_NAME, $(basename VIRTUAL_ENV)
    local venvprompt=""
    venvprompt=${_APP:-${VIRTUAL_ENV_NAME:-${VIRTUAL_ENV:+"$(basename "$VIRTUAL_ENV")"}}}
    # TODO: CONDA
    # shellcheck disable=2154
    export VENVPROMPT="${venvprompt:+"($venvprompt) "}${debian_chroot:+"[$debian_chroot] "}${WINDOW_TITLE:+"$WINDOW_TITLE "}"
    if [ -n "$BASH_VERSION" ]; then
        # shellcheck disable=2154
        if [ "$color_prompt" == yes ]; then
            PS1='${VENVPROMPT}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
        else
            PS1='${VENVPROMPT}\u@\h:\w\n\$ '
            unset color_prompt
        fi
    fi
}
_setup_venv_prompt



function venv_ls {
    # venv_ls()     -- list virtualenv directories
    prefix=${1:-${VIRTUAL_ENV}}
    lsargs=${2:-${lsargs:-"-ld"}}
    if [ -z "${prefix}" ]; then
        return
    fi
    #ls -ld ${prefix}/**
    find "${prefix}" "${prefix}/lib" -maxdepth 2 -type d -print0 \
        | xargs -0 ls --color=auto ${lsargs}
}
function lsvenv {
    # lsvenv()      -- venv_ls()
    venv_ls "${@}"
}

function venv_mkdirs {
    # venv_mkdirs()  -- create FSH paths in ${1} or ${VIRTUAL_ENV} 
    prefix=${1:-${VIRTUAL_ENV}}
    if [ -z "${prefix}" ]; then
        return
    fi
    ensure_mkdir "${prefix}"
    ensure_mkdir "${prefix}/bin"
    ensure_mkdir "${prefix}/etc"
    #ensure_mkdir  "${prefix}/home"
    ensure_mkdir "${prefix}/lib"
    #ensure_mkdir  "${prefix}/opt"
    #ensure_mkdir  "${prefix}/sbin"
    #ensure_mkdir  "${prefix}/share/doc"
    ensure_mkdir "${prefix}/src"
    #ensure_mkdir  "${prefix}/srv"
    ensure_mkdir "${prefix}/tmp"
    ensure_mkdir "${prefix}/usr/share/doc"
    ensure_mkdir "${prefix}/var/cache"
    ensure_mkdir "${prefix}/var/log"
    ensure_mkdir "${prefix}/var/run"
    ensure_mkdir "${prefix}/var/www"

    venv_ls "${prefix}"
}

#!/usr/bin/env sh
### bashrc.venv.pyramid.sh

workon_pyramid_app() {
    # workon_pyramid_app()  -- $VIRTUAL_ENV_NAME [$_APP] [open_terminals]
    _VENVNAME=$1
    _APP=$2

    _OPEN_TERMS=${3:-""}

    we "${_VENVNAME}" "${_APP}"

    # shellcheck disable=2034
    {
    # _VENVCMD="workon ${_VENVNAME}"
    _EGGSETUPPY="${_WRD}/setup.py"
    _EGGCFG="${_WRD}/development.ini"
    _EDITCFGCMD="${_EDITCMD} ${_EGGCFG}"
    _SHELLCMD="${_BIN}/pshell ${_EGGCFG}"
    _SERVECMD="${_BIN}/pserve --reload --monitor-restart ${_EGGCFG}"
    _TESTCMD="python ${_EGGSETUPPY} nosetests"
    }

    alias _serve='${_SERVECMD}'
    alias _shell='${_SHELLCMD}'
    alias _test='${_TESTCMD}'
    alias _editcfg='${_EDITCFGCMD}'
    alias _glog='hgtk -R "${_WRD}" log'
    alias _log='hg -R "${_WRD}" log'

    if [ -n "${_OPEN_TERMS}" ]; then
        ${EDITOR} "${_WRD}" &
        #open tabs
        #gnome-terminal \
        #--working-directory="${_WRD}" \
        #--tab -t "${_APP} serve" -e "bash -c \"${_SERVECMD}; bash -c \"workon_pyramid_app $VIRTUAL_ENV_NAME $_APP 1\"\"" \
        #--tab -t "${_APP} shell" -e "bash -c \"${_SHELLCMD}; bash\"" \
        #--tab -t "${_APP} bash" -e "bash"
    fi
}


#!/usr/bin/env sh
### bashrc.editor.sh

_setup_editor() {
    # setup_editor()    -- configure ${EDITOR}
    #   VIMBIN  (str):   /usr/bin/vim
    #   GVIMBIN (str):   /usr/bin/gvim
    #   MVIMBIN (str):   /usr/local/bin/mvim
    #   GUIVIMBIN (str): $GVIMBIN || $MVIMBIN || ""
    #   EDITOR  (str):   $VIMBIN -f || $GUIVIMBIN -f
    #   EDITOR_ (str):   $EDITOR || $GUIVIMBIN $VIMCONF --remote-tab-silent
    #   VIMCONF (str):   --servername ${VIRTUAL_ENV_NAME:-'EDITOR'}
    #   SUDO_EDITOR (str): $EDITOR
    export VIMBIN="/usr/bin/vim"
    export GVIMBIN="/usr/bin/gvim"
    export MVIMBIN="/usr/local/bin/mvim"
    export GUIVIMBIN=""
    if [ -x ${GVIMBIN} ]; then
        export GUIVIMBIN=$GVIMBIN
    elif [ -x ${MVIMBIN} ]; then
        export GUIVIMBIN=$MVIMBIN
    fi

    export EDITOR="${VIMBIN} -f"
    export EDITOR_="${EDITOR}"
    export SUDO_EDITOR="${VIMBIN} -f"

    if [ -n "${GUIVIMBIN}" ]; then
        export VIMCONF="--servername ${VIRTUAL_ENV_NAME:-"/"}"
        export EDITOR="${GUIVIMBIN} -f"
        export EDITOR_="${GUIVIMBIN} ${VIMCONF} --remote-tab-silent"
        export SUDO_EDITOR="${GUIVIMBIN} -f"
        alias gvim='${GUIVIMBIN}'
    else
        unset -f "$GVIMBIN"
        unset -f "$MVIMBIN"
        unset -f "$USEGVIM"
    fi

    export _EDITOR="${EDITOR}"
}
_setup_editor


_setup_pager() {
    # _setup_pager()    -- set PAGER='less'
    export PAGER='/usr/bin/less -R'
}
_setup_pager


ggvim() {
    # ggvim()   -- ${EDITOR} $@ 2>&1 >/dev/null
    ${EDITOR} "${@}" >/dev/null 2>&1
}


edits() {
    # edits()   -- open $@ in ${GUIVIMBIN} --servername $1
    servername=$1
    shift
    ${GUIVIMBIN} --servername "${servername}" --remote-tab "${@}"
}


editcfg() {
    # editcfg() -- ${EDITOR_} ${_CFG} [ --servername $VIRTUAL_ENV_NAME ]
    e "${_CFG}"
}

sudoe() {
    # sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
    EDITOR="${SUDO_EDITOR}" sudo -e "${@}"
}
sudovim() {
    # sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
    sudoe "${@}"
}

# e() {
    # e() -- see $__DOTFILES/scripts/_ewrd.sh
# }

egitstatus() {
    # egitstatus() -- git status --short | sed | xargs e
    git status --short | sed 's/^ .* //' | xargs e
}


code() {
   # code()   -- run deactivate before calling `code` (vscode)
   { type deactivate >/dev/null 2>&1 && deactivate; } || true;

   _vscode=
   if [ -n "${container}" ]; then
        _vscode=$(unset -f code 2>/dev/null; command -v code)
   else
        _vscode="code.sh"
   fi
   (set -x; "${_vscode}" "${@}")
}
#!/usr/bin/env bash
### bashrc.vimpagers.sh

function _configure_lesspipe {
    # _configure_lesspipe() -- (less <file.zip> | lessv)
    lesspipe="$(command -v lesspipe.sh 2>/dev/null)"
    if [ -n "${lesspipe}" ]; then
        eval "$(${lesspipe})"
    fi
}
_configure_lesspipe


function vimpager {
    # vimpager() -- call vimpager
    # _PAGER=$(command -v vimpager)
    if [ -x "${_PAGER}" ]; then
        "${_PAGER}" "${@}"
    else
        echo "error: vimpager not found. Calling lessv instead..."
        lessv "${@}"
    fi
}


function lessv {
    # lessv()   -- less with less.vim and vim (g:tinyvim=1)
    if [ -t 1 ]; then
        if [ $# -eq 0 ]; then
            if [ -n "$VIMPAGER_SYNTAX" ]; then
                #read stdin
                "${VIMBIN}" --cmd "let g:tinyvim=1" \
                    --cmd "runtime! macros/less.vim" \
                    --cmd "set nomod" \
                    --cmd "set noswf" \
                    -c "set colorcolumn=0" \
                    -c "map <C-End> <Esc>G" \
                    -c "set syntax=${VIMPAGER_SYNTAX}" \
                    -c "set cursorline nocursorcolumn" \
                    -
            else
                "${VIMBIN}" --cmd "let g:tinyvim=1" \
                    --cmd "runtime! macros/less.vim" \
                    --cmd "set nomod" \
                    --cmd "set noswf" \
                    -c "set colorcolumn=0" \
                    -c "map <C-End> <Esc>G" \
                    -c "set cursorline nocursorcolumn" \
                    -
            fi
        elif [ -n "$VIMPAGER_SYNTAX" ]; then
            "${VIMBIN}" \
                --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                -c "set syntax=${VIMPAGER_SYNTAX}" \
                -c "set cursorline nocursorcolumn" \
                "${@}"

        else
            "${VIMBIN}" \
                --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                -c "set cursorline nocursorcolumn" \
                "${@}"
        fi
    else
        #Output is not a terminal, cat arguments or stdin
        if [ $# -eq 0 ]; then
            less
        else
            less "${@}"
        fi
    fi
}

function lessg {
    # lessg()   -- less with less.vim and gvim / mvim
    VIMBIN="${GUIVIMBIN}" lessv "${@}"
}

function lesse {
    # lesse()   -- less with current venv's vim server
    "${GUIVIMBIN}" --servername "${VIRTUAL_ENV_NAME:-"/"}" --remote-tab "${@}";
}

function manv {
    # manv()    -- view manpages in vim
    alias man_="/usr/bin/man"
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #/usr/bin/whatis "$@" >/dev/null
        "$(command -v vim)" \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0' \
            -c "set cursorline nocursorcolumn"
    fi
}

function mang {
    # mang()    -- view manpages in gvim / mvim
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        "${GUIVIMBIN}" \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0' \
            -c "set cursorline nocursorcolumn"
    fi
}

function mane {
    # mane()    -- open manpage with venv's vim server
    # shellcheck disable=2086
    ${GUIVIMBIN} ${VIMCONF} --remote-send "<ESC>:Man ${*}<CR>"
}

function gitpager {
    # gitpager()    -- export GIT_PAGER to $1 or GIT_PAGER_DEFAULT or
    export GIT_PAGER="${1:-${GIT_PAGER:-${GIT_PAGER_DEFAULT}}}"
    if [ "${GIT_PAGER}" == "" ]; then
        unset GIT_PAGER
    fi
    echo "GIT_PAGER=$(shell_escape_single "${GIT_PAGER}")"
}

function nogitpager {
    # nogitpager()  -- export GIT_PAGER=""
    export GIT_PAGER=""
    echo "GIT_PAGER=$(shell_escape_single "${GIT_PAGER}")"
}
#!/usr/bin/env bash
### bashrc.usrlog.sh
    # _USRLOG (str): path to .usrlog userspace shell command log
    # stid()      -- set $TERM_ID to a random string
    # stid $name  -- set $TERM_ID to string
    # note()      -- add a dated note to $_USRLOG [_usrlog_append]
    # usrlogv()   -- open usrlog with vim:   $VIMBIN + $_USRLOG
    # usrlogg()   -- open usrlog with gmvim: $GUIVIMBIN + $_USRLOG
    # usrloge()   -- open usrlog with editor:$EDITOR + $_USRLOG
    # ut()        -- tail $_USRLOG
    # ug()        -- egrep current usrlog: egrep $@ $_USRLOG
    # ugall()     -- egrep $@ $__USRLOG ${WORKON_HOME}/*/.usrlog
    # ugrin()     -- grin current usrlog: grin $@ $_USRLOG
    # ugrinall()  -- grin $@  $__USRLOG ${WORKON_HOME}/*/.usrlog
    # lsusrlogs() -- ls -tr   $__USRLOG ${WORKON_HOME}/*/.usrlog

_setup_usrlog() {
    # _setup_usrlog()   -- source ${__DOTFILES}/etc/usrlog.sh
    # shellcheck source=../../scripts/usrlog.sh
    source "${__DOTFILES}/scripts/usrlog.sh"
    #calls _usrlog_setup when sourced
}
# shellcheck disable=2119
_setup_usrlog
#!/usr/bin/env bash
### usrlog.sh -- Shell CLI REPL command logs in userspace (per $VIRTUAL_ENV)
#
#  Log shell commands with metadata as tab-separated lines to ${_USRLOG}
#  with a shell identifier to differentiate between open windows,
#  testing/screencast flows, etc
#
#  By default, _TERM_ID will be set to a random string prefixed with '#'
#  by the `stid()` bash function (`_usrlog_set__TERM_ID()`)
#
#  * _TERM_ID can be set to any string;
#  * _TERM_ID is displayed in the PS1 prompt
#  * _TERM_ID is displayed in the window title
#  * _TERM_ID is reset to __TERM_ID upon 'deactivate'
#    (westurner/dotfiles//etc/bash/07-bashrc.virtualenvwrapper.sh:
#     TODO: virtualenvwrapper, conda)
#
#  Environment Variables:
#
#   __USRLOG (str): default -usrlog.log file (~/-usrlog.log)
#   _USRLOG  (str): current -usrlog.log file to append REPL command strings to
#   _TERM_ID (str): a terminal identifier with which command loglines will
#                   be appended (default: _usrlog_randstr)
#

function _usrlog_get_prefix  {
    #  _usrlog_get_prefix()    -- get a dirpath for the current usrlog
    #                             (VIRTUAL_ENV or HOME)
    local prefix="${VENVPREFIX:-${VIRTUAL_ENV:-${HOME}}}"
    if [ "${prefix}" == "/" ]; then
        prefix=$HOME
    fi
    echo "$prefix"
}

function _usrlog_set__USRLOG  {
    #  _usrlog_set__USRLOG()    -- set $_USRLOG (and $__USRLOG)
    export __USRLOG="${HOME}/-usrlog.log"
    prefix="$(_usrlog_get_prefix)"
    export _USRLOG="${prefix}/-usrlog.log"

}

function _usrlog_set_HISTFILE  {
    #  _usrlog_set_HISTFILE()   -- configure shell history
    local prefix="$(_usrlog_get_prefix)"

    if [ -n "${BASH}" ]; then
        #   history -a   -- append any un-flushed lines to $HISTFILE
        history -a
    fi

    # set/touch HISTFILE
    set HISTFILE
    #   history -c && history -r $HISTFILE   -- clear; reload $HISTFILE

    if [ -n "${ZSH_VERSION}" ]; then
        # ZSH_VERSION
        export HISTFILE="${prefix}/.zsh_history"
    elif [ -n "${BASH}" ]; then
        export HISTFILE="${prefix}/.bash_history"
    else
        export HISTFILE="${prefix}/.history"
    fi

    if [ -n "${BASH}" ]; then
        history -c && history -r "${HISTFILE}"
    fi
}

function _usrlog_set_HIST {
    #  _usrlog_set_HIST()    -- set shell $HIST<...> variables

    #  see HISTSIZE and HISTFILESIZE in bash(1)
    HISTSIZE=1000
    HISTFILESIZE=1000000

    #avoid duplicating datetimes in .usrlog
    #HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S%z" (iso8601)
    #HISTTIMEFORMAT="%t%Y-%m-%dT%H:%M:%S%z%t"
    #  note that HOSTNAME and USER come from the environ
    #  and MUST be evaluated at the time HISTTIMEFORMAT is set.
    HISTTIMEFORMAT="%t%Y-%m-%dT%H:%M:%S%z%t${HOSTNAME}%t${USER}%t\$\$%t"  #  %n  "

    #don't put duplicate lines in the history. See bash(1) for more options
    #  ... or force ignoredups and ignorespace
    #  HISTCONTROL=ignoredups:ignorespace
    HISTCONTROL=ignoredups:ignorespace

    _usrlog_set_HISTFILE

    if [ -n "$ZSH_VERSION" ]; then
        setopt APPEND_HISTORY
        setopt EXTENDED_HISTORY
    elif [ -n "$BASH" ] ; then
        #  append current lines to history
        history -a

        #  append to the history file, don't overwrite it
        #  https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin
        shopt -s histappend > /dev/null 2>&1
        #  replace newlines with semicolons
        shopt -s cmdhist > /dev/null 2>&1
        shopt -s lithist > /dev/null 2>&1

        #  enable autocd (if available)
        shopt -s autocd > /dev/null 2>&1
    fi
}

function _usrlog_randstr {
    #  _usrlog_randstr      -- Generate a random string
    #    $1: number of characters

    if [[ `uname -s` == "Darwin" ]]; then
        echo "$(dd if=/dev/urandom bs=1 count=$1 2>/dev/null |
    else
        echo "$(dd if=/dev/urandom bs=1 count=$1 2>/dev/null |
    fi
}

function _usrlog_get__TERM_ID {
    #  _usrlog_get__TERM_ID()   -- echo the current _TERM_ID and $_USRLOG
    echo "#  _TERM_ID="$_TERM_ID" # [ $_USRLOG ]" >&2
    echo "$_TERM_ID"
}

function _usrlog_set__TERM_ID  {
    #  _usrlog_Set__TERM_ID     -- set or randomize the $_TERM_ID key
    #    $1: _term_id value for _TERM_ID
    local new_term_id="${@}"
    if [ -z "${new_term_id}" ]; then
        new_term_id="#$(_usrlog_randstr 8)"
    fi
    if [[ "${new_term_id}" != "${_TERM_ID}" ]]; then
        #TODO: _usrlog_append_echo
        if [ -z "${_TERM_ID}" ]; then
            _usrlog_append "#ntid  _TERM_ID=\"${new_term_id}\"  #_USRLOG=\"${_USRLOG}\""
        else
            _usrlog_append "#stid  _TERM_ID=\"${new_term_id}\"  #_TERM_ID__=\"${_TERM_ID}\"  #_USRLOG=\"${_USRLOG}\""
        fi
        export _TERM_ID="${new_term_id}"
        _usrlog_set_title

    fi
}


function _usrlog_echo_title  {
    #  _usrlog_echo_title   -- set window title (by echo'ing escape codes)
    local title="${WINDOW_TITLE:+"$WINDOW_TITLE "}"
    local venvtitle="${_APP:-${VIRTUAL_ENV_NAME}}"
    if [ -n "${venvtitle}" ]; then
        title="($venvtitle) ${title}"
    fi
    title="${title} ${USER}@${HOSTNAME}:${PWD}${venvtitle:+" - [${venvtitle^^}]"}"
    local USRLOG_WINDOW_TITLE=${title:-"$@"}
    #local USRLOG_WINDOW_TITLE=${title}
    if [ -n "$CLICOLOR" ]; then
        echo -ne "\033]0;${USRLOG_WINDOW_TITLE}\007"
    #  else
    #     echo -ne "${USRLOG_WINDOW_TITLE}"
    fi
}

function _usrlog_set_title {
    #  _usrlog_set_title()  --  set xterm title
    #   $1: _window_title (defaults to ${_TERM_ID})
    export WINDOW_TITLE=${1:-"$_TERM_ID"}
    _usrlog_echo_title
    declare -F '_setup_venv_prompt' > /dev/null 2>&1 \
        && _setup_venv_prompt
}


function _usrlog_log_cmd_and_update_prompt() {
    #  _usrlog_log_cmd_and_update_prompt() -- set +x; cmd; then restore +/-x

    ## This adds three (3) lines of output to every command when set -x is on
    _usrlog_log_cmd_and_update_prompt_setxstate=${-//[^x]/}
    set +x

    ## This would add four (4) lines of output to every cmd when set -x is on:
    #_usrlog_log_cmd_and_update_prompt_setxstate=${USRLOG_SETX:-${-//[^x]/}}
    #test "${_usrlog_log_cmd_and_update_prompt_setxstate}" != "${USRLOG_SETX}" && \
    #    set +x

    _usrlog_writecmd
    _usrlog_echo_title

    if [[ -n "${_usrlog_log_cmd_and_update_prompt_setxstate}" ]]; then
        set -x
    fi
}

function _usrlog_setup {
    #  _usrlog_setup()      -- configure usrlog for the current shell
    local _usrlog="${1:-$_USRLOG}"
    local term_id="${2:-$_TERM_ID}"

    _usrlog_set_HIST

    _usrlog_set__USRLOG "$_usrlog"

    #TERM_SED_STR='s/^\s*[0-9]*\s\(.*\)/$_TERM_ID: \1/'
    TERM_SED_STR='s/^\s*[0-9]*\s*//'

    _usrlog_set__TERM_ID "$term_id"
    touch "$_USRLOG"

    _usrlog_set_title "$_TERM_ID"

    #  setup bash
    if [ -n "$BASH" ]; then
        PROMPT_COMMAND="_usrlog_log_cmd_and_update_prompt"
    fi

    #  setup zsh
    if [ -n "$ZSH_VERSION" ]; then
        precmd_functions=(_usrlog_log_cmd_and_update_prompt)
    fi
}

function _usrlog_append {
    #  _usrlog_append()  -- Write a line to $_USRLOG w/ an ISO8601 timestamp
    #    $1: text (command) to log
    #    note: _TERM_ID must not contain a tab character (tr '\t' ' ')
    #    note: _TERM_ID can be a URN, URL, URL, or simple \w+ str key
    #  example:
    #    2014-11-15T06:42:00-0600	dotfiles	 8311  ls
      #  (pwd -p)?
       #  this from HISTORY
    local cmd="${*}";
    local prefix="${VENVPREFIX:-${VIRTUAL_ENV}}"
    (printf "#  %s\t%s\t%s\t%s\t%s\n" \
        "$(date +%Y-%m-%dT%H:%M:%S%z)" \
        "$(echo "${_TERM_ID}" | tr $'\t' ' ')" \
        "$(echo "${prefix}" | tr $'\t' ' ')" \
        "$(echo "${PWD}" | tr $'\t' ' ')" \
        "$(echo "${cmd}" | tr $'\n' ' ')" \
        ) >> "${_USRLOG:-${__USRLOG}}" 2>/dev/null
    printf "%s\n" \
        "$(echo "${cmd}" | sed 's|.*	$$	\(.*\)|#  \1|g')"
}

#function _usrlog_append_oldstyle {
#    #  _usrlog_append_oldstype -- Write a line to $_USRLOG
#    #    $1: text (command) to log
#    #  examples:
#    #    # qMZwZSGvJv8: 10/28/14 17:25.54 :::   522  histgrep BUG
#    #    #ZbH08n8unY8	2014-11-11T12:27:22-0600	 2238  ls
#    printf "#  %-11s: %s : %s" \
#        "$_TERM_ID" \
#        "$(date +'%D %R.%S')" \
#        "${1:-'\n'}" \
#            | tee -a $_USRLOG >&2
#}


function _usrlog_writecmd {
    #  _usrlog_writecmd()    -- write the most recent command to $_USRLOG
    _usrlog_set_HISTFILE

    if [ -n "$ZSH_VERSION" ]; then
        id 2>&1 > /dev/null
        _cmd=$(fc -l -1 | sed -e "${TERM_SED_STR}")
    elif [ -n "$BASH" ]; then
        _cmd=$(history 1 | sed -e "${TERM_SED_STR}")
    else
        _cmd=$(history 1 | sed -e "${TERM_SED_STR}")
    fi
    _usrlog_append "${_cmd}"
}


## usrlog parsing

function _usrlog_parse_newstyle {
    #  _usrlog_parse_newstyle -- Parse a -usrlog.log with pyline
    #    NOTE: handle when HISTTIMEFORMAT=""
    #    NOTE: this is approxmte (see: venv.py)
    local usrlog="${1}"
    if [ -n "${usrlog}" ]; then
        if [ "${usrlog}" != "-" ]; then
            usrlog="-f ${usrlog}"
        fi
    fi
    pyline.py "${usrlog}" \
        -m collections \
        '[collections.OrderedDict((
            ("l", [l]),
            ("date", w[0].lstrip("#  ")),
            ("id", w[1]),
            ("path", w[2]),
            ("virtualenv", w[3]),
            ("histstr", w[4:]),
            ("histn", w[4].strip()),    #  int or {#NOTE, #TODO, #_MSG}
            ("histdate", (w[5] if len(w) > 5 else None)),
            ("histhostname", (w[6] if len(w) > 6 else None)),
            ("histuser", (w[7] if len(w) > 7 else None)),
            ("histcmd", (w[9:] if len(w) > 9 else None)),
            ))
            for w in [ line.split("\t", 9) ]
                if len(w) >= 4]' \
                    -O json
}


function _usrlog_parse_cmds {
    #  _usrlog_parse_cmds -- Show histcmd or histstr from HISTTIMEFORMAT usrlog
    #  with pyline
    #  TODO: handle HISTTIMEFORMAT="" (" histn  <cmd>")
    #  TODO: handle newlines (commands that start on the next line)  (venv.py)
    #  NOTE: HISTTIMEFORMAT histn (OSX  ) [ 8 ]
    #  NOTE: HISTTIMEFORMAT histn (Linux) [ 7 ]
    local usrlog="${1}"
    sed 's,.*\t\$\$\t\(.*\),\1,g' ${usrlog:+"${usrlog}"}

    #if [ -n "${usrlog}" ]; then
    #    if [ "${usrlog}" != "-" ]; then
    #        usrlog="-f ${usrlog}"
    #    fi
    #fi
    #pyline.py ${usrlog} \
    #    'list((
    #        (" ".join(w[10:]).rstrip() if len(w) > 10 else None)
    #        or (" ".join(w[9:]).rstrip() if len(w) > 9 else None)
    #        or (" ".join(w[8:]).rstrip() if len(w) > 8 else None)
    #        or (" ".join(w[7:]).rstrip() if len(w) > 7 else None)
    #        or (" ".join(w[3:]).rstrip() if len(w) > 3 else None)
    #        or " ".join(w).rstrip())
    #        for w in [ line and line.startswith("#") and line.split("\t",9) or [line] ]
    #        )'
    #if try_grep:
    #
    #pyline.py ${usrlog} -r '(\d+:|#\s+) ' \'l and (l.startswith("#" or rgx.groups())) and l.split("\t$$\t", 1)[-1]'
    #pyline.py ${usrlog}  'l and (l.startswith("#")) and l.split("\t$$\t", 1)[-1]'
    # usrlog.py -p${usrlog:-'-'}${usrlog:+"${usrlog}"} --cmd
    #
    # grep -n "usrlog_" "$_USRLOG" | pyline.py -r '^(?P<grep_n>\d+\:)?(?P<start>#\s+)(?P<_words>.*)\t\$\$\t(?P<cmd>.*)' 'l and rgx and (rgx.groups(), rgx.groupdict(), (rgx.groupdict().get("_words","") or "").split("\t"))'  -O json
    #
}
function ugp {
    _usrlog_parse_cmds "${@}"
}

## usrlog.sh API

### usrlog _TERM_ID commands

function termid {
    #  termid()      -- echo $_TERM_ID
    _usrlog_get__TERM_ID
}


function set_term_id {
    #  set_term_id() -- set $_TERM_ID to a randomstr or $1
    _usrlog_set__TERM_ID "$@"
}

function stid {
    #  stid()        -- set $_TERM_ID to a randomstr or $1
    _usrlog_set__TERM_ID "$@"
}
function st {
    #  st()          -- set $_TERM_ID to a randomstr or $1
    _usrlog_set__TERM_ID "$@"
}

### usrlog tail commands
function ut {
    #  ut()  -- show recent commands
    usrlog_tail "${@}"
}

function usrlog_tail_all {
    #  usrlog_tail_all()  -- tail all usrlogs from lsusrlogs
    usrlog_tail "$(lsusrlogs)"
}
function uta {
    #  uta()              -- tail all usrlogs from lsusrlogs
    usrlog_tail_all "${@}"
}

function usrlog_tail_all_and_parse {
    #  usrlog_tail_all_and_parse()  -- tail all lsusrlogs and parse
    (set -x; usrlog_tail "${@:+"${@}"}" "$(lsusrlogs)" | ugp)   # TODO: headers
}
function utap {
    #  utap()                       -- tail all lsusrlogs and parse
    usrlog_tail_all_and_parse "${@}"
}

function usrlog_tail_and_parse {
    #  usrlog_tail_and_parse()   -- show recent commands
    usrlog_tail "${@}" | _usrlog_parse_cmds
}
function utp {
    #  utp()                     -- show recent commands
    usrlog_tail_and_parse "${@}"
}

function usrlog_tail {
    (_usrlog_tail "${@}")
}

function _usrlog_tail {
    #  usrlog_tail()     -- tail -n20 $_USRLOG
    local _args=("${@}")
    #local follow="${_USRLOG_TAIL_FOLLOW}"
    local _usrlog="${_USRLOG}"
    if [ -n "${_args[*]}" ]; then
        for _arg in ${_args}; do
            case "${_arg}" in
                -*)
                    case "${_arg}" in
                        -n)
                            shift;
                            local count=${1}
                            shift
                            continue
                            ;;
                        -n*)
                            local count=${_arg#"-n"} # less the initial '-n'
                            shift
                            continue
                            ;;
                        -f)
                            local follow=1
                            ;;
                        -v)
                            shift
                            local verbose=1
                            ;;
                        *)
                            # shift
                            echo "_arg: ${_arg}" # TODO: 
                            ;;
                    esac
                    ;;
            esac
        done
        if [ -z $# ]; then
            _args=($_args "${_usrlog}")
        fi
        (set -x; tail "${_args[@]}" "${_usrlog}")

    else
        (set -x; tail ${follow:+"-f"} "${_usrlog}")
    fi
}
function usrlog_tail_follow {
    #  usrlog_tail_follow()    -- tail -f -n20 $_USRLOG
    _USRLOG_TAIL_FOLLOW=true usrlog_tail "${@}"
}
function utf {
    #  utf()                   -- tail -f -n20 $_USRLOG
    usrlog_tail_follow "${@}"
}


### usrlog grep commands

function usrlog_grep {
    #  usrlog_grep() -- grep -E -n $_USRLOG
    #local _args="${@}"
    local _paths="${_USRLOG_GREP_PATHS:-"${_USRLOG}"}"
    if [ -z "${@}" ]; then
        (set -x; cat "${_paths}")
    else
        (set -x; grep -E --text -n "${@}" ${_paths})
    fi
}
function ug {
    #  ug()          -- grep -E -n $_USRLOG
    #    Usage:
    #      ug 'pip' | ugp
    #      ug | ugp | grep -C 20 'pip'
    #      ug | usrlog.py -
    usrlog_grep "${@}"
}

function uga2 {
    #  uga2()
    _USRLOG_GREP_PATHS="$(lsusrlogs)" usrlog_grep "${@}"
}

#function usrlog_grep_session_id {
#     # usrlog_grep_session_id()  -- grep -E ".*\t${1:-$_TERM_ID}"
#     (set -x;
#     local _term_id=${1:-"${_TERM_ID}"};
#     local _usrlog=${2:-"${_USRLOG}"};
#     grep -E "# [\d-T:Z ]+\t${_term_id}\t" ${_USRLOG} )
#}

function _usrlog_grep_venvs {
    grep -E "${@}" '((we[c]?)|workon_venv|workon_conda|workon|mkvirtualenv|mkvirtualenv_conda|rmvirtualenv|rmvirtualenv_conda)[ ;]'

}
function usrlog_grep_venvs {
    #  usrlog_grev_venv() -- grep for virtualenv[wrapper] cmds in $@||$_USRLOG
    cat "${@:-${_USRLOG}}" | _usrlog_grep_venvs
}
function ugv {
    #  ugv()              -- grep for virtualenv[wrapper] cmds in $@||$_USRLOG
    usrlog_grep_venvs "${@}"
}
function usrlog_grep_venvs_all {
    #  usrlog_grep_venvs_all()  -- grep venvs TODO without spaces in
    #                              filenames and sort
    usrlog_grep_venvs $(lsusrlogs) | sort -n
}
function ugva {
    #  ugva()                   -- usrlog_grep_venvs_all()
    usrlog_grep_venvs_all "${@}"
}

function _usrlog_grep_todo_fixme_xxx {
    grep --text -E -i '(todo|fixme|xxx)'
}
function _usrlog_grep_todos {
    grep --text '$$'$'\t''#\(TODO\|NOTE\|_MSG\)'
}
function usrlog_grep_todos {
    #  usrlog_grep_todos()   -- grep for TODO|NOTE|_MSG lines in a usrlog.log
    cat "${@:-${_USRLOG}}" | _usrlog_grep_todos
}
function uggt {
    #  uggt()                -- grep for TODO|NOTE|_MSG lines in a usrlog.log
    usrlog_grep_todos "${@}"
}

function usrlog_grep_todos_parse {
    #  usrlog_grep_todos_parse() -- grep for TODO|NOTE|_MSG lines and parse
    usrlog_grep_todos "${@}" | _usrlog_parse_cmds
}

function ugtp {
    #  ugtp()                    -- grep for TODO|NOTE|_MSG lines and parse
    usrlog_grep_todos "${@}" | _usrlog_parse_cmds
}

function ugtptodo {
    # usrlog_grep_todos | _usrlog_parse_cmds
    usrlog_grep_todos_parse "${@}" | grep --text --color=never '^#TODO'
}
function ugtptodonote {
    # usrlog_grep_todos | _usrlog_parse_cmds
    usrlog_grep_todos_parse "${@}" | grep --text --color=never '^#\(TODO\|NOTE\)'
}

function usrlog_format_todonotemsg_as_txt {
    sed 's/^#TODO: /- /' \
        | sed 's/^#NOTE: /- NOTE: /' \
        | sed 's/^#_MSG: /- _MSG: /'
    # pyline '(l.replace("#TODO: ", "- [ ] ", 1).replace("#NOTE:", "- ", 1) if l.startswith("#TODO: ", "#NOTE: ") else l)'
}

function ugft {
    usrlog_format_todonotemsg_as_txt "${@}"
}

function usrlog_grep_todos_as_txt {
    #  usrlog_grep_todos_as_txt() -- grep TODO|NOTE|MSG and format as txt
    #ugtp "${@}" | ugft
    usrlog_grep_todos_parse "${@}" | usrlog_format_todonotemsg_as_txt
}

function ugtodo {
    usrlog_grep_todos_as_txt "${@}"
}

function ugt {
    usrlog_grep_todos_as_txt "${@}"
}

function usrlog_grep_todos_as_txt_all {
    #  usrlog_grep_todos_as_txt_all() -- grep for TODO|NOTE|_MSG in lsusrlogs
    usrlog_grep_todos_parse "${@}" $(lsusrlogs)
}
function ugtodoall {
    #  ugtodoall()                    -- grep for TODO|NOTE|_MSG in lsusrlogs
    usrlog_grep_tods_as_txt_all "${@}"
}
function ugta {
    #  ugta()                         -- grep for TODO|NOTE|_MSG in lsusrlogs
    usrlog_grep_tods_as_txt_all "${@}"
}

function usrlog_grin {
    #  usrlog_grin() -- grin -s $@ $_USRLOG
    local args="${@}"
    (set -x;
    grin -s "${args}" "${_USRLOG}")
}
function ugrin  {
    #  ugrin()       -- grin -s $@ $_USRLOG
    usrlog_grin "${@}"
}


function usrlog_grin_session_id {
    #  usrlog_grin_session_id()  -- grep -E ".*\t${1:-$_TERM_ID}"
    (set -x;
    local _term_id="${1:-"${_TERM_ID}"}";
    local _usrlog="${2:-"${_USRLOG}"}";
    grin -s '#  [\d\-:TZ\s]+\t'"${_term_id}"'\t(.*)$' "${_usrlog}" --no-color;);
}


function usrlog_grin_session_id_cmds {
    #  usrlog_grin_session_id()  -- grep -E ".*\t${1:-$_TERM_ID}"
    (set -x;
    local _term_id="${1:-"${_TERM_ID}"}";
    local _usrlog="${2:-"${_USRLOG}"}";
    grin -N --no-color --without-filename -s \
        '#  [\d\-:TZ\s]+\t'"${_term_id}"'\t(.*)$' \
        "${_usrlog}" \
            | _usrlog_parse_cmds -  ;
    );
}


function usrlog_grin_session_id_all {
    #  usrlog_grin_session_id_all()  -- grep $2:-$_USRLOG for $1:-$_TERM_ID
    #                                   in column position
    #    :returns: unsorted list of log entries in files
    #              listed by mtime and then cat
    #
    #  .. warning:: output lines are in file sequence but otherwise
    #                unsorted
    #
    (set -x;
    local _term_id=${1:-"${_TERM_ID}"}; \
    local _usrlog=${2:-"${_USRLOG}"}; \
    local _usrlogs=$(lsusrlogs_date_desc);  # TODO: file filenames to stdin?
    grin -s     '#  [\d\-:TZ\s]+\t'${_term_id}'\t' ${_usrlogs} --no-color;)
}
function ugrins  {
    #  ugrins()  -- grep $2:-$_USRLOG for $1:-$_TERM_ID in column position
    usrlog_grin_session_id_all "${@}"
}

function usrlog_grin_session_id_all_cmds {
    #  usrlog_grin_session_id_all_cmds()  -- grep $2:-$_USRLOG for $1:-$_TERM_ID
    #                                        in column position
    (set -x;
    local _term_id=${1:-"${_TERM_ID}"}; \
    local _usrlog=${2:-"${_USRLOG}"}; \
    local _usrlogs=$(lsusrlogs_date_asc);
    grin -N --no-color --without-filename -s \
        '#  [\d\-:TZ\s]+\t'"${_term_id}"'\t' \
        "${_usrlogs}" \
        | _usrlog_parse_cmds -  ;
    );
}

function deduplicate_lines {
    # deduplicate_lines()   -- deduplicate lines w/ an associative array
    #                                                 (~OrderedMap)
    local -A lines_ary
    local line
    local lines_ary_value
    while IFS= read -r line; do
        lines_ary_value=${lines_ary["${line}"]}
        if [ -z "${lines_ary_value}" ]; then
            lines_ary["${line}"]="${line}"
            echo "${line}"
        fi
    done
    unset lines_ary line lines_ary_value
}


# USRLOG_INCLUDE_LEGACYLOGS
# USRLOG_INCLUDE_ALLUSRLOGS

function _usrlog_set_usrlog_paths {
    declare -ga _USRLOG_PATHS
    declare -a _usrlog_paths
    _USRLOG_PATHS=( )
    _usrlog_paths=( )
    _usrlog_paths+=(
        "${_USRLOG}"
        "${__USRLOG}"
    )
    test -n "${USRLOG_INCLUDE_LEGACYLOGS}" && \
        _usrlog_paths+=(
            "${WORKON_HOME}"/*/.usrlog )
    test -n "${WORKON_HOME}" && \
        _usrlog_paths+=(
            "${WORKON_HOME}"/*/-usrlog.log ) 
    test -n "${CONDA_ENVS_PATH}" && \
        _usrlog_paths+=(
            "${CONDA_ENVS_PATH}"/*/-usrlog.log ) 
    test -z "${USRLOG_INCLUDE_ALLUSRLOGS}" && \
        test -n "${__WRK}" && \
            _usrlog_paths+=(
                "${__WRK}"/-*/*/-usrlog.log )  # TODO: lsusrlogs
    declare -A uniques
    for pth in "${_usrlog_paths[@]}"; do
        exists=${uniques["${pth}"]}
        if [ -z "${exists}" ]; then
            uniques["${pth}"]="${pth}"
            _USRLOG_PATHS+=("${pth}")
        fi
    done
    export _USRLOG_PATHS
}

function _usrlog_echo_paths {
    _usrlog_set_usrlog_paths
    printf '%s\n' "${_USRLOG_PATHS[@]}"
}

function lsusrlogs_date_desc {
    #  lsusrlogs_date_desc()   -- ls $__USRLOG ${WORKON_HOME}/*/.usrlog
    #                             (oldest first)
    _usrlog_set_usrlog_paths
    ls -tr "${_USRLOG_PATHS[@]}" "${@}" 2>/dev/null
}
function lsusrlogs_date_asc {
    #  lsusrlogs_date_desc()   -- ls $__USRLOG ${WORKON_HOME}/*/.usrlog
    #                             (newest first)
    _usrlog_set_usrlog_paths
    ls -t "${_USRLOG_PATHS[@]}" "${@}" 2>/dev/null
}
function lsusrlogs {
    #  lsusrlogs()             -- list usrlogs (oldest first)
    lsusrlogs_date_desc "${@}"
}

function usrlog_lately {
    #  usrlog_lately()      -- lsusrlogs by mtime
    lsusrlogs_date_desc "${@}" | xargs ls -ltr
}
function ull {
    #  ull()                -- usrlog_lately() (lsusrlogs by mtime)
    usrlog_lately "${@}"
}

function usrlog_grep_all {
    #  usrlog_grep_all()    -- grep $(lsusrlogs) (drop filenames with -h)
    if [ -n "${@}" ]; then
        (set -x;
        args="${@}"
        usrlogs=$(lsusrlogs)
        grep -E "${@}" --text ${usrlogs} \
            | sed 's/:/'$'\t''/')
        #| pyline.py 'l.replace(":","\t",1)'  # grep filename output
    else
        # cat $(lsusrlogs)    # dangerous and wrong
        # cat "$(lsusrlogs)"  # wrong
        lsusrlogs | xargs cat # requires xargs, may be too long
    fi
}
function ugall {
    #  ugall()              -- grep $(lsusrlogs) (drop filenames with -h)
    usrlog_grep_all "${@}"
}
function uga {
    #  uga()                -- grep $(lsusrlogs) (drop filenames with -h)
    usrlog_grep_all "${@}"
}

function usrlog_grin_all {
    #  usrlog_grin_all()    -- grin usrlogs
    (set -x;
    args="${@}"
    usrlogs=$(lsusrlogs)
    lsusrlogs | \
        grin --no-skip-hidden-files "${@}" -f - \
        | sed 's/:/'$'\t''/' \
        | grin "${@}" -)
}
function ugrinall {
    #  usrlog_grin_all()    -- grin usrlogs
    usrlog_grin_all "${@}"
}

function todo {
    #  todo()   -- _usrlog_append a #TODO and set _TODO ('-' unsets, '' prints)
    #      see: usrlog_grep_todos_parse (ugt, ugtp) 
    local _todo="${@}"
    if [ -z "${_todo}" ]; then
        echo "_TODO=${_TODO}"
        return
    elif [[ "${_todo}" = "-" ]]; then
        unset _TODO
        echo "_TODO=${_TODO}"
        return
    else
        export _TODO="${_todo}"
        echo "_TODO=${_TODO}"
        startstr="#TODO	$(date +'%FT%T%z')	${HOSTNAME}	${USER}	\$$	"
        #_usrlog_append "#note  #note: $@"
        _usrlog_append "${startstr}#TODO: [ ] ${_todo}"
        return
    fi
}
function note {
    #  note()   -- _usrlog_append a #NOTE and set _NOTE ('-' unsets, '' prints)
    local _note="${@}"
    if [ -z "${_note}" ]; then
        echo "_NOTE=${_NOTE}"
        return
    elif [[ "${_note}" = "-" ]]; then
        unset _NOTE
        echo "_NOTE=${_NOTE}"
        return
    else
        export _NOTE="${_note}"
        echo "_NOTE=${_NOTE}"
        startstr="#NOTE	$(date +'%FT%T%z')	${HOSTNAME}	${USER}	\$$	"
        _usrlog_append "${startstr}#NOTE: ${_note}"
        return
    fi
}
function msg {
    #  msg()   -- _usrlog_append a #_MSG and set __MSG ('-' unsets, '' prints)
    local _msg="${@}"
    if [ -z "${_msg}" ]; then
        echo "_MSG=${_MSG}"
        return
    elif [[ "${_msg}" == "-" ]]; then
        unset _MSG
        echo "_MSG=${_MSG}"
        return
    else
        export _MSG="${_msg}"
        echo "_MSG=${_MSG}"
        startstr="#_MSG	$(date +'%FT%T%z')	${HOSTNAME}	${USER}	\$$	"
        _usrlog_append "${startstr}#_MSG: ${_msg}"
        return
    fi
}

 
function add {
    #  add()   -- add a line to _add_file or DEFAULT_ADD_FILE or ./add.log   
    local _file="${_add_file:-${DEFAULT_ADD_FILE:-"./add.log"}}"
    echo "${@}" >> "${_file?_add_file or $DEFAULT_ADD_FILE must be specified}"
}


function usrlog_screenrec_ffmpeg {
    #  usrlog_screenrec_ffmpeg() -- record a screencast
    #    $1: destination directory (use /tmp if possible)
    #    $2: video name to append to datestamp
    #    - Press "q" to stop recording
    DATESTR=$(date +%Y%m%d-%H%M)
    FILEBASE="screenrec-${DATESTR}"
    if [ -z "$2" ]; then
        FILENAME="$1/${FILEBASE}_unnamed.mpg"
    else
        FILENAME="$1/${FILEBASE}_${2}.mpg"
    fi
    SCREENDIM="$(xdpyinfo | grep 'dimensions:'| awk '{print $2}')"
    ffmpeg \
        -f x11grab \
        -s "$SCREENDIM" \
        -r 25
        -i 0:0 \
        -sameq "$FILENAME" \
            2>&1 | tee "$FILENAME.log"
}

function usrlogw {
    #  usrlogw()       -- usrlog.py -p ${_USRLOG} ${@}
    (set -x; usrlog.py -p "${_USRLOG}" ${@})
}

function _setup_usrlog {
    #  _setup_usrlog() -- call _usrlog_setup $@
    _usrlog_setup "$@"
}

function usrlog_help() {
    (set -x; grep -E '^\s*#+\s+' $0;)
    #grep -E '^\s*function ' $0;
    (set -x; grep -E '^\s*function u' $0;)
}

for arg in "${@}"; do
    case "$arg" in
        -h|--help|help)
            usrlog_help;
            ;;
    esac
done

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
## calls _usrlog_setup when sourced
    _usrlog_setup
else
    _usrlog_setup
fi
]0;#testing  wturner@ab3:/var/home/wturner/-wrk/-ve311/dotfiles/src/dotfiles

usrlogv() {
    # usrlogv() -- open $_USRLOG w/ $VIMBIN (and skip to end)
    file=${1:-$_USRLOG}
    lessv + "${file}"
}

usrlogg() {
    # usrlogg() -- open $_USRLOG w/ $GUIVIMBIN (and skip to end)
    file=${1:-$_USRLOG}
    lessg + "${file}"
}

usrloge() {
    # usrloge() -- open $_USRLOG w/ $EDITOR_ [ --servername $VIRTUAL_ENV_NAME ]
    file=${1:-$_USRLOG}
    if [ -n "${VIMCONF}" ]; then
        ${GUIVIMBIN} ${VIMCONF} --remote-send ":tabnew + ${file}<CR>"
    else
        usrlogg "${file}"
    fi
}
#!/usr/bin/env bash
### 30-bashrc.xlck.sh
## xlck     -- minimal X screensaver
    # xlck 
    # xlck -I  --  (I)nstall xlck (apt-get)
    # xlck -U  --  check stat(U)s (show xautolock processes on this $DISPLAY)
    # xlck -S  --  (S)tart xlck (start xautolock on this $DISPLAY)
    # xlck -P  --  sto(P) xlck (stop xautolock on this $DISPLAY)
    # xlck -R  --  (R)estart xlck
    # xlck -M  --  suspend to ra(M) (and lock)
    # xlck -D  --  suspend to (D)isk (and lock)
    # xlck -L  --  (L)ock
    # xlck -X  --  shutdown -h now
    # xlck -h  --  help
    # xlck_status_all()             -- pgrep 'xautolock|xlock|i3lock', ps ufw
    # xlck_status_this_display()    -- show status for this $DISPLAY

_setup_xlck() {
    # _setup_xlck() -- source ${__DOTFILES}/etc/xlck.sh (if -z __IS_MAC)
    if [ -z "${__IS_MAC}" ]; then
        # shellcheck source=../../scripts/xlck.sh
        source "${__DOTFILES}/scripts/xlck.sh"
    fi
}

#!/usr/bin/env bash
### bashrc.aliases.sh

#annotate this file with comments
#cat ./40-bashrc.aliases.sh | pyline -r '(\s*?)alias\s(.*?)=(.*)' '(rgx and "{}# {:<8} -- {}\n{}".format(rgx.groups()[0], rgx.groups()[1], rgx.groups()[2], l)) or l'

_loadaliases () {
    #  _load_aliases()  -- load aliases
    # chmodr   -- 'chmod -R'
    alias chmodr='chmod -R'
    # chownr   -- 'chown -R'
    alias chownr='chown -R'

    # grep     -- 'grep --color=auto'
    alias grep='grep --color=auto'
    # egrep    -- 'egrep --color=auto'
    alias egrep='egrep --color=auto'
    # fgrep    -- 'fgrep --color=auto'
    alias fgrep='fgrep --color=auto'

    # grindp   -- 'grind --sys.path'
    alias grindp='grind --sys-path'
    # grinp    -- 'grin --sys-path'
    alias grinp='grin --sys-path'

    # fumnt    -- 'fusermount -u'
    alias fumnt='fusermount -u'

    # ga       -- 'git add'
    alias ga='git add'

    gac () {
        __doc="
    # gac()    -- 'git add ${files}; git commit -m "${1}" ${files}'
    #   $1 (str): quoted commit message
    #   $2-$@ (list): file paths"
        local msg=${1:-""}
        shift
        local files=( "${@}" )
        git diff "${files[@]}"
        if [ -n "${msg}" ]; then
            git commit "${files[@]}" -m "${msg}"
        else
            # shellcheck disable=2016
            echo 'No message specified in $1, not comitting'
        fi
    }
    # gb       -- 'git branch -v'
    alias gb='git branch -v'
    # gd       -- 'git diff'
    alias gd='git diff'
    # gds      -- 'git diff -p --stat'
    alias gds='git diff -p --stat'
    # gc       -- 'git commit'
    alias gc='git commit'
    # gca      -- 'git commit --amend'
    alias gca='git commit --amend'
    # gco      -- 'git checkout'
    alias gco='git checkout'
    # gdc      -- 'git diff --cached'
    alias gdc='git diff --cached'
    # gl       -- 'git log --pretty=format:"%h : %an : %s" --topo-order --graph'
    alias gl='git log --pretty=format:"%h : %an : %s" --topo-order --graph'
    # gr       -- 'git remote -v'
    alias gr='git remote -v'
    # gs       -- 'git status'
    alias gs='git status -sb'
    # gsi      -- 'git is; git diff; git diff --cached'
    alias gsi='(set -x; git is; git diff; git diff --cached)'
    # gsiw      -- 'git -C $_WRD gsi'
    alias gsiw='(cd $_WRD; gsi)'
    # gsl      -- 'git stash list'
    alias gsl='git stash list'
    # gsn      -- 'git stash save'
    alias gsn='git stash save'
    # gss      -- 'git stash save'
    alias gss='git stash save'
    # gitr     -- 'git remote -v'
    alias gitr='git remote -v'

    # hga      -- 'hg add'
    alias hga='hg add'

    hgac () {
    # hgac()   -- 'hg add $@[1:]; hg commit $1'
    #   $1 (str): quoted commit message
    #   $2- (list): file paths
        local msg=${1:-""}
        shift
        local files=( "${@}" )
        hg diff "${files[@]}"
        if [ -n "${msg}" ]; then
            hg commit -m "${msg}" "${files[@]}"
        else
            # shellcheck disable=2016
            echo 'No message specified in $1, not comitting'
        fi
    }
    # hgl      -- 'hg glog --pager=yes'
    alias hgl='hg glog --pager=yes'
    # hgs      -- 'hg status'
    alias hgs='hg status'
    # hgd      -- 'hg diff'
    alias hgd='hg diff'
    # hgds     -- 'hg diff --stat'
    alias hgds='hg diff --stat'
    # hgdl     -- 'hg diff --color=always | less -R'
    alias hgdl='hg diff --color=always | less -R'
    # hgc      -- 'hg commit'
    alias hgc='hg commit'
    # hgu      -- 'hg update'
    alias hgu='hg update'
    # hgq      -- 'hg qseries'
    alias hgq='hg qseries'
    # hgqd     -- 'hg qdiff'
    alias hgqd='hg qdiff'
    # hgqs     -- 'hg qseries'
    alias hgqs='hg qseries'
    # hgqn     -- 'hg qnew'
    alias hgqn='hg qnew'
    # hgr      -- 'hg paths'
    alias hgr='hg paths'

    # __IS_MAC
    if [ -n "${__IS_MAC}" ]; then
        # la       -- 'ls -A -G'
        alias la='ls -A -G'
        # ll       -- 'ls -alF -G'
        alias ll='ls -alF -G'
        # ls       -- 'ls -G'
        alias ls='ls -G'
        # lt       -- 'ls -altr -G'
        alias lt='ls -altr -G'
        # lll      -- 'ls -altr -G'
        alias lll='ls -altr -G'
    # else
    else
        # la       -- 'ls -A --color=auto'
        alias la='ls -A --color=auto'
        # ll       -- 'ls -alF --color=auto'
        alias ll='ls -alF --color=auto'
        # ls       -- 'ls --color=auto'
        alias ls='ls --color=auto'
        # lt       -- 'ls -altr --color=auto'
        alias lt='ls -altr --color=auto'
        # lll      -- 'ls -altr --color=auto'
        alias lll='ls -altr --color=auto'
    fi

    # __IS_LINUX
    if [ -n "${__IS_LINUX}" ]; then
        # psx      -- 'ps uxaw'
        alias psx='ps uxaw'
        # psf      -- 'ps uxawf'
        alias psf='ps uxawf'
        # psxs     -- 'ps uxawf --sort=tty,ppid,pid'
        alias psxs='ps uxawf --sort=tty,ppid,pid'
        # psxh     -- 'ps uxawf --sort=tty,ppid,pid | head'
        alias psxh='ps uxawf --sort=tty,ppid,pid | head'

        # psh      -- 'ps uxaw | head'
        alias psh='ps uxaw | head'

        # psc      -- 'ps uxaw --sort=-pcpu'
        alias psc='ps uxaw --sort=-pcpu'
        # psch     -- 'ps uxaw --sort=-pcpu | head'
        alias psch='ps uxaw --sort=-pcpu | head'

        # psm      -- 'ps uxaw --sort=-pmem'
        alias psm='ps uxaw --sort=-pmem'
        # psmh     -- 'ps uxaw --sort=-pmem | head'
        alias psmh='ps uxaw --sort=-pmem | head'
    # __IS_MAC
    elif [ -n "${__IS_MAC}" ]; then
        # psx      -- 'ps uxaw'
        alias psx='ps uxaw'
        # psf      -- 'ps uxaw' # no -f
        alias psf='ps uxaw' # no -f

        # psh      -- 'ps uxaw | head'
        alias psh='ps uxaw | head'

        # psc      -- 'ps uxaw -c'
        alias psc='ps uxaw -c'
        # psch     -- 'ps uxaw -c | head'
        alias psch='ps uxaw -c | head'

        # psm      -- 'ps uxaw -m'
        alias psm='ps uxaw -m'
        # psmh     -- 'ps uxaw -m | head'
        alias psmh='ps uxaw -m | head'
    fi

    # pyg      -- pygmentize [pip install --user pygments]
    alias pyg='pygmentize -P style=native'
    alias pygp='pyg -l python'
    alias pygj='pyg -l javascript'
    alias pygh='pyg -l html'

    # catp     -- pygmentize [pip install --user pygments]
    alias catp='pyg'
    alias catpp='pyg -l python'
    alias catpj='pyg -l javascript'
    alias catph='pyg -l html'

    # shtop   -- 'sudo htop' [apt-get/yum install -y htop]
    alias shtop='sudo htop'

    # t       -- 'task'
    alias t='task'

    #t       -- 'tail'
    #alias t='tail'
    
    # tf      -- 'tail -f'
    alias tf='tail -f'

    # xclipc  -- 'xclip -selection c'
    alias xclipc='xclip -selection c'

    # dnf     -- 'python -m dnf.cli.main'
    # REQUIRES: `dnf install python3-dnf`
    # TODO: add tab-completion 
    alias dnfpy='/usr/bin/python3 -m dnf.cli.main'
}
_loadaliases



#!/usr/bin/env bash
### bashrc.commands.sh
# usage: bash -c 'source bashrc.commands.sh; funcname <args>'

chown-me () {
    # chown-me()        -- chown -Rv user
    (set -x; \
    chown -Rv "$(id -un)" "${@}" )
}

chown-me-mine () {
    # chown-me-mine()   -- chown -Rv user:user && chmod -Rv go-rwx
    (set -x; \
    chown -Rv "$(id -un):$(id -un)" "${@}" ; \
    chmod -Rv go-rwx "${@}" )
}

chown-sme () {
    # chown-sme()       -- sudo chown -Rv user
    (set -x; \
    sudo chown -Rv "$(id -un)" "${@}" )
}

chown-sme-mine () {
    # chown-sme-mine()  -- sudo chown -Rv user:user && chmod -Rv go-rwx
    (set -x; \
    sudo chown -Rv "$(id -un):$(id -un)" "${@}" ; \
    sudo chmod -Rv go-rwx "${@}" )
}

chmod-unumask () {
    # chmod-unumask()   -- recursively add other+r (files) and other+rx (dirs)
    path=$1
    sudo find "${path}" -type f -exec chmod -v o+r {} \;
    sudo find "${path}" -type d -exec chmod -v o+rx {} \;
}

#!/usr/bin/env bash
### bashrc.bashmarks.sh
## bashmarks
    # l()  -- list bashmarks
    # s()  -- save bashmarks as $1
    # g()  -- goto bashmark $1
    # p()  -- print bashmark $1
    # d()  -- delete bashmark $1
# shellcheck source=../bashmarks/bashmarks.sh
source "${__DOTFILES}/etc/bashmarks/bashmarks.sh"
# Copyright (c) 2010, Huy Nguyen, http://www.huyng.com
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided 
# that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, this list of conditions 
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors
#       may be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#       
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.


# USAGE: 
# s bookmarkname - saves the curr dir as bookmarkname
# g bookmarkname - jumps to the that bookmark
# g b[TAB] - tab completion is available
# p bookmarkname - prints the bookmark
# p b[TAB] - tab completion is available
# d bookmarkname - deletes the bookmark
# d [TAB] - tab completion is available
# l - list all bookmarks

# setup file to store bookmarks
if [ ! -n "$SDIRS" ]; then
    SDIRS=~/.sdirs
fi
touch $SDIRS

RED="0;31m"
GREEN="0;33m"

# save current directory to bookmarks
function s {
    check_help $1
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$1="
        CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
        echo "export DIR_$1=\"$CURDIR\"" >> $SDIRS
    fi
}

# jump to bookmark
function g {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        cd "$target"
    elif [ ! -n "$target" ]; then
        echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
    else
        echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
    fi
}

# print bookmark
function p {
    check_help $1
    source $SDIRS
    echo "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# delete bookmark
function d {
    check_help $1
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$1="
        unset "DIR_$1"
    fi
}

# print out help for the forgetful
function check_help {
    if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] ; then
        echo ''
        echo 's <bookmark_name> - Saves the current directory as "bookmark_name"'
        echo 'g <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
        echo 'p <bookmark_name> - Prints the directory associated with "bookmark_name"'
        echo 'd <bookmark_name> - Deletes the bookmark'
        echo 'l                 - Lists all available bookmarks'
        kill -SIGINT $$
    fi
}

# list bookmarks with dirnam
function l {
    check_help $1
    source $SDIRS
        
    # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
    env | sort | awk '/DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
    
    # uncomment this line if color output is not working with the line above
    # env | grep "^DIR_" | cut -c5- | sort |grep "^.*=" 
}
# list bookmarks without dirname
function _l {
    source $SDIRS
    env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "=" 
}

# validate bookmark name
function _bookmark_name_valid {
    exit_message=""
    if [ -z $1 ]; then
        exit_message="bookmark name required"
        echo $exit_message
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="bookmark name is not valid"
        echo $exit_message
    fi
}

# completion command
function _comp {
    local curw
    COMPREPLY=()
    curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '`_l`' -- $curw))
    return 0
}

# ZSH completion command
function _compzsh {
    reply=($(_l))
}

# safe delete line from sdirs
function _purge_line {
    if [ -s "$1" ]; then
        # safely create a temp file
        t=$(mktemp -t bashmarks.XXXXXX) || exit 1
        trap "rm -f -- '$t'" EXIT

        # purge line
        sed "/$2/d" "$1" > "$t"
        mv "$t" "$1"

        # cleanup temp file
        rm -f -- "$t"
        trap - EXIT
    fi
}

# bind completion command for g,p,d to _comp
if [ $ZSH_VERSION ]; then
    compctl -K _compzsh g
    compctl -K _compzsh p
    compctl -K _compzsh d
else
    shopt -s progcomp
    complete -F _comp g
    complete -F _comp p
    complete -F _comp d
fi
lsbashmarks () {
    # lsbashmarks() -- list Bashmarks (e.g. for NERDTree)
    export -p | grep -E 'DIR_\w+="' | pyline "line[15:].replace('\"','').split('=',1)"
}

    # see also: ${__DOTFILES}/scripts/nerdtree_to_bashmarks.py


#!/usr/bin/env bash
### 70-bashrc.repos.sh


function git_commit() {
    #  git-commit()   -- git commit ${2:} -m ${1}; git log -n1
    (set -x;
    msg="${1}";
    shift;
    files=( "${@}" );
    git commit "${files[@]}" -m "${msg}" && \
    git log -n1 --stat --decorate=full --color=always;
    )
}

function gc() {
    #  gc()             -- git-commit() <files> -m <log> ; log log -n1
    git_commit "${@}"
}

function git_add_commit() {
    #  git-add-commit()   -- git add ${2:}; git commit ${2} -m ${1}; git log -n1
    (set -x;
    msg="${1}";
    shift;
    files=( "${@}" );
    git add "${files[@]}";
    git commit "${files[@]}" -m "${msg}" && \
    git log -n1 --stat --decorate=full --color=always;
    )
}

function gac() {
    #  gac()            -- git-add-commit $@
    git_add_commit "${@}"
}

# function msg {
#   export _MSG="${@}"
#   see: usrlog.sh
# }

function git_commit_msg() {
    #  gitcmsg()    -- gitc "${_MSG}" "${@}"
    git_commit "${_MSG}" "${@}"
    msg -
}

function git_add_commit_msg() {
    #  gitcaddmsg()    -- gitc "${_MSG}" "${@}"
    git_add_commit "${_MSG}" "${@}"
    msg -
}


#objectives:
#* [ ] create a dotfiles venv (should already be created by dotfiles install)
#* [ ] create a src venv (for managing a local set of repositories)
#
#* [x] create Hg_ methods for working with a local repo set
#* [ ] create Git_ methods for working with a local repo set
#
#* [-] host docs locally with a one-shot command (host_docs)
#
# Use Cases
# * Original: a bunch of commands that i was running frequently
#   before readthedocs (and hostthedocs)
# * local mirrors (manual, daily?)
#   * no internet, outages
#   * push -f
#   * (~offline) Puppet/Salt source installs
#     * bandwidth: testing a recipe that pulls a whole repositor(ies)
# * what's changed in <project>'s source dependencies, since i looked last
#
# Justification
# * very real risks for all development projects
#   * we just assume that GitHub etc. are immutable and forever
#
# Features (TODO) [see: pyrpo]
# * Hg <subcommands>
# * Git <subcommands>
# * Bzr <subcommands>
# * periodic backups / mirroring
# * gitweb / hgweb
# * mirror_and_backup <URL>
# * all changes since <date> for <set_of_hg-git-bzr-svn_repositories>
# * ideally: transparent proxy
#   * +1: easiest
#   * -1: pushing upstream
#
# Caveats
# * pasting / referencing links which are local paths
# * synchronization lag
# * duplication: $__SRC/hg/<pkg> AND $VIRTUAL_ENV/src/<pkg>
#

setup_dotfiles_docs_venv() {
    #  setup_dotfiles_docs_venv -- create default 'docs' venv
    deactivate

    __DOCSENV="docs"
    export __DOCS="${WORKON_HOME}/${__DOCSENV}"
    export __DOCSWWW="${__DOCS}/var/www"
    mkvirtualenv_conda_if_available "$__DOCSENV"
    venv_mkdirs "$__DOCS"
    workon_conda_if_available "$__DOCS"
}

setup_dotfiles_src_venv() {
    #  setup_dotfiles_src_venv -- create default 'src' venv
    #
    #   __SRC_HG=${WORKON_HOME}/src/src/hg
    #   __SRC_GIT=${WORKON_HOME}/src/src/git
    #
    #  Hg runs hg commands as user hg
    #  Git runs git commands as user git
    #
    #  Hgclone will mirror to $__SRC_HG
    #  Gitclone will mirror to $__SRC_GIT
    #
    #
    deactivate
    __SRCENV="src"
    export __SRC=${WORKON_HOME}/${__SRCENV}/src
    export __SRC_HG=${__SRC}/hg
    export __SRC_GIT=${__SRC_GIT}/git
    mkvirtualenv_conda_if_available $__SRCENV
    workon_conda_if_available $__SRCENV
    _VIRTUAL_ENV="${WORKON_HOME}/${__SRCENV}"

    venv_mkdirs "${_VIRTUAL_ENV}"
    ensure_mkdir "$__SRC"
    ensure_mkdir "$__SRC/git"
    ensure_mkdir "$__SRC/hg"
    ensure_mkdir "${_VIRTUAL_ENV}/var/www"
}


fixperms () {
    #fix permissions for hgweb? TODO
    __PATH=$1
    sudo chown -R hg:hgweb "$__PATH"
    sudo chmod -R g+rw "$__PATH"
}

# __SRC_GIT_REMOTE_URI_PREFIX   -- default git remote uri prefix
# __SRC_GIT_REMOTE_URI_PREFIX="ssh://git@git.create.wrd.nu"
# __SRC_GIT_REMOTE_NAME         -- name for git remote v
# __SRC_GIT_REMOTE_NAME="create"
# __SRC_HG_REMOTE_URI_PREFIX    -- default hg remote uri prefix
# __SRC_HG_REMOTE_URI_PREFIX="ssh://hg@hg.create.wrd.nu"
# __SRC_HG_REMOTE_NAME          -- name for hg paths
# __SRC_HG_REMOTE_NAME="create"

# __SRC_GIT_GITOLITE_ADMIN=$HOME/gitolite-admin

Git_create_new_repo(){
    ## Create a new hosted repository with gitolite-admin
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1  # (e.g. westurner/dotfiles)
    cd "$__SRC_GIT_GITOLITE_ADMIN_REPO" && \
        ./add_repo.sh "$reponame"
}

Git_pushtocreate() {
    ## push a git repository to local git storage
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1
    repo_uri="${__SRC_GIT_URI}/${reponame}"
    username="westurner"
    here=$(pwd)
    #  $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
    repo_local_path=$2
    remote_name=${__SRC_GIT_REMOTE_NAME}

    Git_create_new_repo "$reponame"
    (cd "$repo_local_path" || return;  \
        git remote add "$remote_name" "$repo_uri"  \
            "${__SRC_GIT_URI}/${username}/${reponame}" && \
        git push --all "$remote_name" && \
        cd "$here" || return)
}

Hg_create_new_repo() {
    ## Create a new hosted repository with mercurial-ssh
    reponame=$1
    (cd "$__SRC_HG_SERVER_REMOTE_ADMIN" || return && \
        ./add_repo.sh "$reponame")  # TODO: create add_repo.sh
}

Hg_pushtocreate() {
    ## push a hg repository to local git storage
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1
    repo_uri="${__SRC_HG_URI}/${reponame}"
    here=$(pwd)
    #  $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
    repo_local_path=$2
    remote_name=${__SRC_HG_REMOTE_NAME}
}


Hgclone () {
    url=$1
    shift
    path="${__SRC}/hg/$1"
    if [ -d "$path" ]; then
        echo "$path exists. Exiting." >&2
        echo "see: update_repo $1"
        return 0
    fi
    sudo -u hg -i /usr/bin/hg clone "$url" "$path"
    fixperms "$path"
}

Hg() {
    path="${__SRC}/hg/$1"
    path=${path:-'.'}
    shift
    cmd=( "${@}" )
    sudo -H -u hg -i /usr/bin/hg -R "${path}" "${cmd[@]}"

    #if [ $? -eq 0 ]; then
    #    fixperms ${path}
    #fi
}

Hgcheck() {
    path="${__SRC}/$1"
    path=${path:-'.'}
    shift
    Hg "$path" tags
    Hg "$path" id -n
    Hg "$path" id
    Hg "$path" branch

    #TODO: last pulled time
}

Hgupdate() {
    path=$1
    shift
    Hg "$path" update "${@}"
}

Hgstatus() {
    path=$1
    shift
    Hg "$path" update "${@}"
}

Hgpull() {
    path=$1
    shift
    Hg "$path" pull "${@}"
    Hgcheck "$path"
}

Hglog() {
    path=$1
    shift
    Hg -R "$path" log "${@}"
}

Hgcompare () {
    one=$1
    two=$2
    diff -Naur \
        <(hg -R "${one}" log) \
        <(hg -R "${two}" log)
}
#!/bin/bash
## 85-bashrc.agents.sh

remove_venvprompt_prefix() {

    ps1_extra_prefix="\[\](dotfiles) \[\]${VENVPROMPT}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ \[\]\[\]"
    ps1_expected="\[\]${VENVPROMPT}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ \[\]\[\]"

    ps1="${ps1_extra_prefix}"

    if [ ! "${ps1}" = "${ps1_expected}" ]; then
        printf "ERROR: ps1 != ps2 \n"
        printf "ps1=%s\n" "${ps1}"
        printf "pse=%s\n" "${ps1_expected}"
    fi

    unset ps1_extra_prefix ps1_expected ps1
}

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    echo "INFO: bashrc.agents.sh Running in vscode"
    vscode_shell_integration_sh="$(code --locate-shell-integration-path bash)"
    source "${vscode_shell_integration_sh}"
    export GIT_PAGER=
    #export GIT_PAGER=sh -x -c -- GIT_CONFIG_PARAMETERS="'color.ui=never'" GIT_PAGER=code\ --wait\ -
    if type -a code.sh.stdin.sh; then
        export GIT_PAGER=code.sh.stdin.sh
    fi
    export EDITOR=code
    export GIT_EDITOR=code\ --wait

    if [ -n "${VIRTUAL_ENV}" ]; then
        workon "${VIRTUAL_ENV}"
    else
        remove_venvprompt_prefix
    fi

fi
INFO: bashrc.agents.sh Running in vscode
++++ /app/bin/code --locate-shell-integration-path bash
flatpak-vscode: Adding /app/tools/podman/bin to PATH
flatpak-vscode: Enabling SDK extension "node20"
[88171 zypak-helper] Using spawn strategy test 1 as set by environment
# ---------------------------------------------------------------------------------------------
#   Copyright (c) Microsoft Corporation. All rights reserved.
#   Licensed under the MIT License. See License.txt in the project root for license information.
# ---------------------------------------------------------------------------------------------

# Prevent the script recursing when setting up
if [[ -n "${VSCODE_SHELL_INTEGRATION:-}" ]]; then
	builtin return
fi

VSCODE_SHELL_INTEGRATION=1

vsc_env_keys=()
vsc_env_values=()
use_associative_array=0
bash_major_version=${BASH_VERSINFO[0]}

__vscode_shell_env_reporting="${VSCODE_SHELL_ENV_REPORTING:-}"
unset VSCODE_SHELL_ENV_REPORTING

envVarsToReport=()
IFS=',' read -ra envVarsToReport <<< "$__vscode_shell_env_reporting"

if (( BASH_VERSINFO[0] >= 4 )); then
	use_associative_array=1
	# Associative arrays are only available in bash 4.0+
	declare -A vsc_aa_env
fi

# Run relevant rc/profile only if shell integration has been injected, not when run manually
if [ "$VSCODE_INJECTION" == "1" ]; then
	if [ -z "$VSCODE_SHELL_LOGIN" ]; then
		if [ -r ~/.bashrc ]; then
			. ~/.bashrc
		fi
	else
		# Imitate -l because --init-file doesn't support it:
		# run the first of these files that exists
		if [ -r /etc/profile ]; then
			. /etc/profile
		fi
		# execute the first that exists
		if [ -r ~/.bash_profile ]; then
			. ~/.bash_profile
		elif [ -r ~/.bash_login ]; then
			. ~/.bash_login
		elif [ -r ~/.profile ]; then
			. ~/.profile
		fi
		builtin unset VSCODE_SHELL_LOGIN

		# Apply any explicit path prefix (see #99878)
		if [ -n "${VSCODE_PATH_PREFIX:-}" ]; then
			export PATH="$VSCODE_PATH_PREFIX$PATH"
			builtin unset VSCODE_PATH_PREFIX
		fi
	fi
	builtin unset VSCODE_INJECTION
fi

if [ -z "$VSCODE_SHELL_INTEGRATION" ]; then
	builtin return
fi

# Prevent AI-executed commands from polluting shell history
if [ "${VSCODE_PREVENT_SHELL_HISTORY:-}" = "1" ]; then
	export HISTCONTROL="ignorespace"
	builtin unset VSCODE_PREVENT_SHELL_HISTORY
fi

# Apply EnvironmentVariableCollections if needed
if [ -n "${VSCODE_ENV_REPLACE:-}" ]; then
	IFS=':' read -ra ADDR <<< "$VSCODE_ENV_REPLACE"
	for ITEM in "${ADDR[@]}"; do
		VARNAME="$(echo $ITEM | cut -d "=" -f 1)"
		VALUE="$(echo -e "$ITEM" | cut -d "=" -f 2-)"
		export $VARNAME="$VALUE"
	done
	builtin unset VSCODE_ENV_REPLACE
fi
if [ -n "${VSCODE_ENV_PREPEND:-}" ]; then
	IFS=':' read -ra ADDR <<< "$VSCODE_ENV_PREPEND"
	for ITEM in "${ADDR[@]}"; do
		VARNAME="$(echo $ITEM | cut -d "=" -f 1)"
		VALUE="$(echo -e "$ITEM" | cut -d "=" -f 2-)"
		export $VARNAME="$VALUE${!VARNAME}"
	done
	builtin unset VSCODE_ENV_PREPEND
fi
if [ -n "${VSCODE_ENV_APPEND:-}" ]; then
	IFS=':' read -ra ADDR <<< "$VSCODE_ENV_APPEND"
	for ITEM in "${ADDR[@]}"; do
		VARNAME="$(echo $ITEM | cut -d "=" -f 1)"
		VALUE="$(echo -e "$ITEM" | cut -d "=" -f 2-)"
		export $VARNAME="${!VARNAME}$VALUE"
	done
	builtin unset VSCODE_ENV_APPEND
fi

# Register Python shell activate hooks
# Prevent multiple activation with guard
if [ -z "${VSCODE_PYTHON_AUTOACTIVATE_GUARD:-}" ]; then
	export VSCODE_PYTHON_AUTOACTIVATE_GUARD=1
	if [ -n "${VSCODE_PYTHON_BASH_ACTIVATE:-}" ] && [ "$TERM_PROGRAM" = "vscode" ]; then
		# Prevent crashing by negating exit code
		if ! builtin eval "$VSCODE_PYTHON_BASH_ACTIVATE"; then
			__vsc_activation_status=$?
			builtin printf '\x1b[0m\x1b[7m * \x1b[0;103m VS Code Python bash activation failed with exit code %d \x1b[0m' "$__vsc_activation_status"
		fi
	fi
	# Remove any leftover Python activation env vars.
	for var in "${!VSCODE_PYTHON_@}"; do
		case "$var" in
			VSCODE_PYTHON_*_ACTIVATE)
				unset "$var"
				;;
		esac
	done
fi

__vsc_get_trap() {
	# 'trap -p DEBUG' outputs a shell command like `trap -- '…shellcode…' DEBUG`.
	# The terms are quoted literals, but are not guaranteed to be on a single line.
	# (Consider a trap like $'echo foo\necho \'bar\'').
	# To parse, we splice those terms into an expression capturing them into an array.
	# This preserves the quoting of those terms: when we `eval` that expression, they are preserved exactly.
	# This is different than simply exploding the string, which would split everything on IFS, oblivious to quoting.
	builtin local -a terms
	builtin eval "terms=( $(trap -p "${1:-DEBUG}") )"
	#                    |________________________|
	#                            |
	#        \-------------------*--------------------/
	# terms=( trap  --  '…arbitrary shellcode…'  DEBUG )
	#        |____||__| |_____________________| |_____|
	#          |    |            |                |
	#          0    1            2                3
	#                            |
	#                   \--------*----/
	builtin printf '%s' "${terms[2]:-}"
}

__vsc_escape_value_fast() {
	builtin local LC_ALL=C out
	out=${1//\\/\\\\}
	out=${out//;/\\x3b}
	builtin printf '%s\n' "${out}"
}

# The property (P) and command (E) codes embed values which require escaping.
# Backslashes are doubled. Non-alphanumeric characters are converted to escaped hex.
__vsc_escape_value() {
	# If the input being too large, switch to the faster function
	if [ "${#1}" -ge 2000 ]; then
		__vsc_escape_value_fast "$1"
		builtin return
	fi

	# Process text byte by byte, not by codepoint.
	builtin local -r LC_ALL=C
	builtin local -r str="${1}"
	builtin local -ir len="${#str}"

	builtin local -i i
	builtin local -i val
	builtin local byte
	builtin local token
	builtin local out=''

	for (( i=0; i < "${#str}"; ++i )); do
		# Escape backslashes, semi-colons specially, then special ASCII chars below space (0x20).
		byte="${str:$i:1}"
		builtin printf -v val '%d' "'$byte"
		if  (( val < 31 )); then
			builtin printf -v token '\\x%02x' "'$byte"
		elif (( val == 92 )); then # \
			token="\\\\"
		elif (( val == 59 )); then # ;
			token="\\x3b"
		else
			token="$byte"
		fi

		out+="$token"
	done

	builtin printf '%s\n' "$out"
}

# Send the IsWindows property if the environment looks like Windows
__vsc_regex_environment="^CYGWIN*|MINGW*|MSYS*"
if [[ "$(uname -s)" =~ $__vsc_regex_environment ]]; then
	builtin printf '\e]633;P;IsWindows=True\a'
	__vsc_is_windows=1
else
	__vsc_is_windows=0
fi

# Allow verifying $BASH_COMMAND doesn't have aliases resolved via history when the right HISTCONTROL
# configuration is used
__vsc_regex_histcontrol=".*(erasedups|ignoreboth|ignoredups|ignorespace).*"
if [[ "${HISTCONTROL:-}" =~ $__vsc_regex_histcontrol ]]; then
	__vsc_history_verify=0
else
	__vsc_history_verify=1
fi

builtin unset __vsc_regex_environment
builtin unset __vsc_regex_histcontrol

__vsc_initialized=0
__vsc_original_PS1="$PS1"
__vsc_original_PS2="$PS2"
__vsc_custom_PS1=""
__vsc_custom_PS2=""
__vsc_in_command_execution="1"
__vsc_current_command=""

# It's fine this is in the global scope as it getting at it requires access to the shell environment
__vsc_nonce="$VSCODE_NONCE"
unset VSCODE_NONCE

# Some features should only work in Insiders
__vsc_stable="$VSCODE_STABLE"
unset VSCODE_STABLE

# Report continuation prompt
if [ "$__vsc_stable" = "0" ]; then
	builtin printf "\e]633;P;ContinuationPrompt=$(echo "$PS2" | sed 's/\x1b/\\\\x1b/g')\a"
fi

if [ -n "$STARSHIP_SESSION_KEY" ]; then
	builtin printf '\e]633;P;PromptType=starship\a'
elif [ -n "$POSH_SESSION_ID" ]; then
	builtin printf '\e]633;P;PromptType=oh-my-posh\a'
fi

# Report this shell supports rich command detection
builtin printf '\e]633;P;HasRichCommandDetection=True\a'
]633;P;HasRichCommandDetection=True
__vsc_report_prompt() {
	# Expand the original PS1 similarly to how bash would normally
	# See https://stackoverflow.com/a/37137981 for technique
	if ((BASH_VERSINFO[0] >= 5 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4))); then
		__vsc_prompt=${__vsc_original_PS1@P}
	else
		__vsc_prompt=${__vsc_original_PS1}
	fi

	__vsc_prompt="$(builtin printf "%s" "${__vsc_prompt//[$'\001'$'\002']}")"
	builtin printf "\e]633;P;Prompt=%s\a" "$(__vsc_escape_value "${__vsc_prompt}")"
}

__vsc_prompt_start() {
	builtin printf '\e]633;A\a'
}

__vsc_prompt_end() {
	builtin printf '\e]633;B\a'
}

__vsc_update_cwd() {
	if [ "$__vsc_is_windows" = "1" ]; then
		__vsc_cwd="$(cygpath -m "$PWD")"
	else
		__vsc_cwd="$PWD"
	fi
	builtin printf '\e]633;P;Cwd=%s\a' "$(__vsc_escape_value "$__vsc_cwd")"
}

__updateEnvCacheAA() {
	local key="$1"
	local value="$2"
	if [ "$use_associative_array" = 1 ]; then
		if [[ "${vsc_aa_env[$key]}" != "$value" ]]; then
			vsc_aa_env["$key"]="$value"
			builtin printf '\e]633;EnvSingleEntry;%s;%s;%s\a' "$key" "$(__vsc_escape_value "$value")" "$__vsc_nonce"
		fi
	fi
}

__updateEnvCache() {
	local key="$1"
	local value="$2"

	for i in "${!vsc_env_keys[@]}"; do
		if [[ "${vsc_env_keys[$i]}" == "$key" ]]; then
			if [[ "${vsc_env_values[$i]}" != "$value" ]]; then
				vsc_env_values[$i]="$value"
				builtin printf '\e]633;EnvSingleEntry;%s;%s;%s\a' "$key" "$(__vsc_escape_value "$value")" "$__vsc_nonce"
			fi
			return
		fi
	done

	vsc_env_keys+=("$key")
	vsc_env_values+=("$value")
	builtin printf '\e]633;EnvSingleEntry;%s;%s;%s\a' "$key" "$(__vsc_escape_value "$value")" "$__vsc_nonce"
}

__vsc_update_env() {
	if [[ ${#envVarsToReport[@]} -gt 0 ]]; then
		builtin printf '\e]633;EnvSingleStart;%s;%s\a' 0 $__vsc_nonce

		if [ "$use_associative_array" = 1 ]; then
			if [ ${#vsc_aa_env[@]} -eq 0 ]; then
				# Associative array is empty, do not diff, just add
				for key in "${envVarsToReport[@]}"; do
					if [ -n "${!key+x}" ]; then
						local value="${!key}"
						vsc_aa_env["$key"]="$value"
						builtin printf '\e]633;EnvSingleEntry;%s;%s;%s\a' "$key" "$(__vsc_escape_value "$value")" "$__vsc_nonce"
					fi
				done
			else
				# Diff approach for associative array
				for key in "${envVarsToReport[@]}"; do
					if [ -n "${!key+x}" ]; then
						local value="${!key}"
						__updateEnvCacheAA "$key" "$value"
					fi
				done
				# Track missing env vars not needed for now, as we are only tracking pre-defined env var from terminalEnvironment.
			fi

		else
			if [[ -z ${vsc_env_keys[@]} ]] && [[ -z ${vsc_env_values[@]} ]]; then
				# Non associative arrays are both empty, do not diff, just add
				for key in "${envVarsToReport[@]}"; do
					if [ -n "${!key+x}" ]; then
						local value="${!key}"
						vsc_env_keys+=("$key")
						vsc_env_values+=("$value")
						builtin printf '\e]633;EnvSingleEntry;%s;%s;%s\a' "$key" "$(__vsc_escape_value "$value")" "$__vsc_nonce"
					fi
				done
			else
				# Diff approach for non-associative arrays
				for key in "${envVarsToReport[@]}"; do
					if [ -n "${!key+x}" ]; then
						local value="${!key}"
						__updateEnvCache "$key" "$value"
					fi
				done
				# Track missing env vars not needed for now, as we are only tracking pre-defined env var from terminalEnvironment.
			fi
		fi
		builtin printf '\e]633;EnvSingleEnd;%s;\a' $__vsc_nonce
	fi
}

__vsc_command_output_start() {
	if [[ -z "${__vsc_first_prompt-}" ]]; then
		builtin return
	fi
	builtin printf '\e]633;E;%s;%s\a' "$(__vsc_escape_value "${__vsc_current_command}")" $__vsc_nonce
	builtin printf '\e]633;C\a'
}

__vsc_continuation_start() {
	builtin printf '\e]633;F\a'
}

__vsc_continuation_end() {
	builtin printf '\e]633;G\a'
}

__vsc_command_complete() {
	if [[ -z "${__vsc_first_prompt-}" ]]; then
		__vsc_update_cwd
		builtin return
	fi
	if [ "$__vsc_current_command" = "" ]; then
		builtin printf '\e]633;D\a'
	else
		builtin printf '\e]633;D;%s\a' "$__vsc_status"
	fi
	__vsc_update_cwd
}
__vsc_update_prompt() {
	# in command execution
	if [ "$__vsc_in_command_execution" = "1" ]; then
		# Wrap the prompt if it is not yet wrapped, if the PS1 changed this this was last set it
		# means the user re-exported the PS1 so we should re-wrap it
		if [[ "$__vsc_custom_PS1" == "" || "$__vsc_custom_PS1" != "$PS1" ]]; then
			__vsc_original_PS1=$PS1
			__vsc_custom_PS1="\[$(__vsc_prompt_start)\]$__vsc_original_PS1\[$(__vsc_prompt_end)\]"
			PS1="$__vsc_custom_PS1"
		fi
		if [[ "$__vsc_custom_PS2" == "" || "$__vsc_custom_PS2" != "$PS2" ]]; then
			__vsc_original_PS2=$PS2
			__vsc_custom_PS2="\[$(__vsc_continuation_start)\]$__vsc_original_PS2\[$(__vsc_continuation_end)\]"
			PS2="$__vsc_custom_PS2"
		fi
		__vsc_in_command_execution="0"
	fi
}

__vsc_precmd() {
	__vsc_command_complete "$__vsc_status"
	__vsc_current_command=""
	# Report prompt is a work in progress, currently encoding is too slow
	if [ "$__vsc_stable" = "0" ]; then
		__vsc_report_prompt
	fi
	__vsc_first_prompt=1
	__vsc_update_prompt
	__vsc_update_env
}

__vsc_preexec() {
	__vsc_initialized=1
	if [[ ! $BASH_COMMAND == __vsc_prompt* ]]; then
		# Use history if it's available to verify the command as BASH_COMMAND comes in with aliases
		# resolved
		if [ "$__vsc_history_verify" = "1" ]; then
			__vsc_current_command="$(builtin history 1 | sed 's/ *[0-9]* *//')"
		else
			__vsc_current_command=$BASH_COMMAND
		fi
	else
		__vsc_current_command=""
	fi
	__vsc_command_output_start
}

# Debug trapping/preexec inspired by starship (ISC)
if [[ -n "${bash_preexec_imported:-}" ]]; then
	__vsc_preexec_only() {
		if [ "$__vsc_in_command_execution" = "0" ]; then
			__vsc_in_command_execution="1"
			__vsc_preexec
		fi
	}
	precmd_functions+=(__vsc_prompt_cmd)
	preexec_functions+=(__vsc_preexec_only)
else
	__vsc_dbg_trap="$(__vsc_get_trap DEBUG)"

	if [[ -z "$__vsc_dbg_trap" ]]; then
		__vsc_preexec_only() {
			if [ "$__vsc_in_command_execution" = "0" ]; then
				__vsc_in_command_execution="1"
				__vsc_preexec
			fi
		}
		trap '__vsc_preexec_only "$_"' DEBUG
	elif [[ "$__vsc_dbg_trap" != '__vsc_preexec "$_"' && "$__vsc_dbg_trap" != '__vsc_preexec_all "$_"' ]]; then
		__vsc_preexec_all() {
			if [ "$__vsc_in_command_execution" = "0" ]; then
				__vsc_in_command_execution="1"
				__vsc_preexec
				builtin eval "${__vsc_dbg_trap}"
			fi
		}
		trap '__vsc_preexec_all "$_"' DEBUG
	fi
fi

__vsc_update_prompt
__vsc_preexec_only "$_"

__vsc_restore_exit_code() {
	return "$1"
}

__vsc_prompt_cmd_original() {
	__vsc_status="$?"
	builtin local cmd
	__vsc_restore_exit_code "${__vsc_status}"
	# Evaluate the original PROMPT_COMMAND similarly to how bash would normally
	# See https://unix.stackexchange.com/a/672843 for technique
	for cmd in "${__vsc_original_prompt_command[@]}"; do
		eval "${cmd:-}"
	done
	__vsc_precmd
}

__vsc_prompt_cmd() {
	__vsc_status="$?"
	__vsc_precmd
}

# PROMPT_COMMAND arrays and strings seem to be handled the same (handling only the first entry of
# the array?)
__vsc_original_prompt_command=${PROMPT_COMMAND:-}
__vsc_preexec_only "$_"

if [[ -z "${bash_preexec_imported:-}" ]]; then
	if [[ -n "${__vsc_original_prompt_command:-}" && "${__vsc_original_prompt_command:-}" != "__vsc_prompt_cmd" ]]; then
		PROMPT_COMMAND=__vsc_prompt_cmd_original
	else
		PROMPT_COMMAND=__vsc_prompt_cmd
	fi
fi
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"
code.sh.stdin.sh is /var/home/wturner/-dotfiles/scripts/code.sh.stdin.sh
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"
bash: workon: command not found

export __AGENT=1
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"

dotfiles_status
## dotfiles_status()
HOSTNAME="ab3"
USER="wturner"
__WRK="/var/home/wturner/-wrk"
PROJECT_HOME="/var/home/wturner/-wrk"
WORKON_HOME="/var/home/wturner/-wrk/-ve311"
CONDA_ROOT="/var/home/wturner/-wrk/-conda311"
CONDA_ENVS_PATH="/var/home/wturner/-wrk/-ce37"
VIRTUAL_ENV_NAME=
VIRTUAL_ENV="/var/home/wturner/-wrk/-ve311/dsport"
_SRC=
_APP=
_WRD=
_USRLOG="/var/home/wturner/-wrk/-ve311/dsport/-usrlog.log"
_TERM_ID="#testing"
PATH="/var/home/wturner/-wrk/-ve311/dsport/bin:/var/home/wturner/.local/bin:/var/home/wturner/-dotfiles/scripts:/var/home/wturner/.var/app/com.visualstudio.code/config/Code/User/globalStorage/github.copilot-chat/debugCommand:/var/home/wturner/.var/app/com.visualstudio.code/config/Code/User/globalStorage/github.copilot-chat/copilotCli:/app/bin:/app/bin:/app/bin:/usr/bin:/app/tools/podman/bin:/usr/lib/sdk/node20/bin:/var/home/wturner/.var/app/com.visualstudio.code/data/node_modules/bin:/var/home/wturner/.var/app/com.visualstudio.code/data/vscode/extensions/ms-python.debugpy-2026.6.0-linux-x64/bundled/scripts/noConfigScripts"
__DOTFILES="/var/home/wturner/-dotfiles"
#
##
__vsc_preexec_only "$_"
__vsc_preexec_only "$_"

export WORKON_HOME=$__WRK/-ve311
export CONDA_ROOT=$__WRK/-conda311
setup_bashrc_package_managers
__vsc_preexec_only "$_"
#!/bin/sh
# rustup shell setup
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.cargo/bin":*)
        ;;
    *)
        # Prepending path in case a system-installed rustc needs to be overridden
        export PATH="$HOME/.cargo/bin:$PATH"
        ;;
esac
#!/bin/sh

# This script adds Aftman to the user's PATH and is run via the user's
# shell-specific profile.
#
# This is adapted from Rustup:
# https://github.com/rust-lang/rustup/blob/feec94b6e0203cb6ad023b1e2c953d058e5c3acd/src/cli/self_update/env.sh

case ":${PATH}:" in
    *:"$HOME/.aftman/bin":*)
        ;;

    *)
        export PATH="$HOME/.aftman/bin:$PATH"
        ;;
esac

exit
__vsc_preexec_only "$_"
exit
