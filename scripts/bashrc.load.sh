bash: no job control in this shell
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


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

# load local dotfiles set
__DOTFILES=${__DOTFILES-"$HOME/.dotfiles"}
_dotfiles_bashrc="${__DOTFILES}/etc/bash/00-bashrc.before.sh"
test -f $_dotfiles_bashrc && source $_dotfiles_bashrc


dotfiles_reload() {
    echo "## Reloading bash configuration..."
    conf=${__DOTFILES}/etc/bash
  #source ~/.bashrc
    #source 00-bashrc.before.sh

      ## libraries: useful bash functions
      source ${conf}/01-bashrc.lib.sh

      ## readline
      source ${conf}/03-bashrc.readline.sh

      ## TERM
      source ${conf}/04-bashrc.TERM.sh

      ## dotfiles
      #  $__DOTFILES (str): path to local dotfiles repository clone
      export __DOTFILES="${HOME}/.dotfiles"
      source ${conf}/05-bashrc.dotfiles.sh


      ## python: python: pip, virtualenv, virtualenvwrapper
      #  TODO: PYTHON_
      #  $PROJECT_HOME (str): path to project directory (~/wrk)
      #  $WORKON_HOME (str): path to virtualenvs directory (~/wrk/.ve)
      #  $VIRTUAL_ENV (str): path to current $VIRTUAL_ENV
      source ${conf}/07-bashrc.python.sh
      source ${conf}/07-bashrc.virtualenv.sh
      source ${conf}/07-bashrc.virtualenvwrapper.sh

      ## gcloud: Google Cloud SDK
      #  _setup_google_cloud
      source ${conf}/08-bashrc.gcloud.sh

      ## venv: virtualenvwrapper extensions (shell vars, cmds, aliases)
      #  $_VENVNAME (str): name of current $VIRTUAL_ENV
      #  we() -- workon a new venv (virtualenvwrapper virtualenv + venv)
      #          we() -> workon $1 && source <($_VENV --bash $@)
      #          example::
      #             we $venvname # $appname
      if [ -d /Library ]; then
          export __IS_MAC='true'
      else
          export __IS_LINUX='true'
      fi
      source ${conf}/10-bashrc.venv.sh
      # test -f $__PROJECTS && source $__PROJECTS
      #  dotfiles_status() -- print dotfiles env config
      dotfiles_status

      ## venv-pyramid: pyramid development workflow
      #  workon_pyramid_add(venvname, appname)
      source ${conf}/11-bashrc.venv.pyramid.sh


      ## editor/pager
      #  $EDITOR (str): cmdstring to open $@ in current editor
      #  $PAGER (str): cmdstring to run pager (less/vim)
      #  lessv() -- open read only in vim
      #  lessg() -- open read only in gvim/mvim
      #  man()   -- open manpage in vim
      #  mang()  -- open manpage in gvim/mvim
      source ${conf}/20-bashrc.editor.sh
      source ${conf}/29-bashrc.vimpagers.sh


      ## usrlog:
      #  $_USRLOG (str): path to .usrlog command log
      source ${conf}/30-bashrc.usrlog.sh


      ## xlck: screensaver, screen (auto) lock, suspend
      source ${conf}/30-bashrc.xlck.sh


      ## aliases: bash aliases and cmds
      source ${conf}/40-bashrc.aliases.sh


      ## bashmarks: local bookmarks
      source ${conf}/50-bashrc.bashmarks.sh

      ## repos: local repository set mgmt, docs hosting
      source ${conf}/70-bashrc.repos.sh

    ## after: cleanup
    source ${conf}/99-bashrc.after.sh
}

dr() {
    dotfiles_reload $@
}

dotfiles_reload
 
function_exists() {
    declare -f $1 > /dev/null
    return $?
}

add_to_path ()
{
    #  add_to_path  -- prepend a directory to $PATH
    ## http://superuser.com/questions/ \
    ##   39751/add-directory-to-path-if-its-not-already-there/39840#39840

    ## instead of:
    ##   export PATH=$dir:$PATH
    ##
    ##   add_to_path $dir 

    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        return 0
    fi
    export PATH=$1:$PATH
}


lightpath() {
    #  lightpath    -- display $PATH with newlines
    echo ''
    echo $PATH | tr ':' '\n'
}

lspath() {
    #  lspath       -- list files in each directory in $PATH
    echo "PATH=$PATH"
    lightpath
    LS_OPTS=${@:'-ald'}
    # LS_OPTS="-aldZ"
    for f in $(lightpath); do
        echo "# $f";
        ls $LS_OPTS $@ $f/*;
    done
}

lspath_less() {
    #  lspath_less  -- lspath with less
    lspath --color=always $@ | less -r
}

echo_args() {
    #   echo_args   -- echo $@ (for checking quoting)
    echo $@
}


pypath() {
    #  pypath       -- print python sys.path and site config
    /usr/bin/env python -m site
}

### bashrc.readline.sh

#  vi-mode: vi(m) keyboard shortcuts
set -o vi

if [ -n "$BASH_VERSION" ]; then
    #  .         -- insert last argument (command mode)
    bind -m vi-command ".":insert-last-argument

    ## emulate default bash
    #  <ctrl> l  -- clear screen
    bind -m vi-insert "\C-l.":clear-screen
    #  <ctrl> a  -- move to beginning of line (^)
    bind -m vi-insert "\C-a.":beginning-of-line
    #  <ctrl> e  -- move to end of line ($)
    bind -m vi-insert "\C-e.":end-of-line
    #  <ctrl> w  -- delete last word
    bind -m vi-insert "\C-w.":backward-kill-word
fi
[?1034h
## set TERM [man terminfo]

configure_TERM() {
    term=$1
    if [ -n "${TERM}" ]; then
        __term=${TERM}
    fi
    if [ -n "${term}" ]; then
        export TERM="${term}"
    else
        if [ -n "${TMUX}" ] ; then
            # tmux
            export TERM="screen"
            configure_TERM_CLICOLOR
        elif [ -n "$(echo $TERMCAP | grep -q screen)" ]; then
            # screen
            export TERM="screen"
            configure_TERM_CLICOLOR
        elif [ -n "${ZSH_TMUX_TERM}" ]; then
            # zsh+tmux: oh-my-zsh/plugins/tmux/tmux.plugin.zsh
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
    #  CLICOLOR=1   # ls colors
    export CLICOLOR=1

    #  CLICOLOR_256=1
    # export CLICOLOR_256=$CLICOLOR

    if [ -n "${CLICOLOR_256}" ]; then
        (echo $TERM | grep -v -q 256color) && \
            export TERM="${TERM}-256color"
    fi
}

configure_TERM
echo $TERMCAP | grep -q screen

dotfiles_status() {
    #  dotfiles_status  -- print dotfiles_status
    #echo "## dotfiles_status()"
    #lightpath | sed 's/^\(.*\)/#  \1/g'
    echo "USER='${USER}'"
    echo "HOSTNAME='${HOSTNAME}'"
    echo "VIRTUAL_ENV_NAME='${VIRTUAL_ENV_NAME}'"
    echo "VIRTUAL_ENV='${VIRTUAL_ENV}'"
    echo "_SRC='${_SRC}'"
    echo "_WRD='${_WRD}'"
    echo "_USRLOG='${_USRLOG}'"
    echo "__DOTFILES='${__DOTFILES}'"
    echo "__DOCSWWW='${_DOCS}'"
    echo "__SRC='${__SRC}'"
    echo "__PROJECTSRC='${__PROJECTSRC}'"
    echo "PROJECT_HOME='${PROJECT_HOME}'"
    echo "WORKON_HOME='${WORKON_HOME}'"
    echo "PATH='${PATH}'"
}

ds() {
    #  ds               -- print dotfiles_status
    dotfiles_status $@
}

reload_dotfiles() {
    dotfiles_reload $@
}

if [ -d "${__DOTFILES}" ]; then
    # Add dotfiles executable directories to $PATH
    add_to_path "${__DOTFILES}/bin"
    add_to_path "${__DOTFILES}/scripts"
fi

# Generate python cmdline docs::
#
#    man python | cat | egrep 'ENVIRONMENT VARIABLES' -A 200 | egrep 'AUTHOR' -B 200 | head -n -1 | pyline -r '\s*([\w]+)$' 'rgx and rgx.group(1)'

_setup_python () {
    # Python
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #export
}
_setup_python

_setup_pip () {
    #export PIP_REQUIRE_VIRTUALENV=true
    export PIP_REQUIRE_VIRTUALENV=false
    #alias ipython="python -c 'import IPython;IPython.Shell.IPShell().mainloop()'"
}
_setup_pip


## pyvenv
_setup_pyenv() {
    export PYENV_ROOT="${HOME}/.pyenv"
    add_to_path "${PYENV_ROOT}/bin"
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper
}


_setup_anaconda() {
    export _ANACONDA_ROOT="/opt/anaconda"
    add_to_path "${_ANACONDA_ROOT}/bin"
}


__get_python_docs() {
    man_ python | cat | \
        egrep 'ENVIRONMENT VARIABLES' -A 200 | \
        egrep 'AUTHOR' -B 200 | head -n -1 | \
        pyline \
        -r '\s*([\w]+)$' \
        -R 'S' \
        -m textwrap '"\n".join(
            ("# " + l) for l in
                textwrap.wrap(\
                    ((rgx and "export " + rgx.group(1) + "=\"\"")\
                    or \
                    (line.strip())), 70))'
}
## Virtualenvwrapper
# sudo apt-get install virtualenvwrapper || easy_install virtualenvwrapper
export PROJECT_HOME="${HOME}/wrk"
export WORKON_HOME="${PROJECT_HOME}/.ve"

_setup_virtualenvwrapper () {
    #export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_SCRIPT="${HOME}/.local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_HOOK_DIR="${__DOTFILES}/etc/virtualenvwrapper" # TODO: FIXME
    export VIRTUALENVWRAPPER_LOG_DIR="${PROJECT_HOME}/.virtualenvlogs"
    export VIRTUALENVWRAPPER_PYTHON='/usr/bin/python' # TODO
    export VIRTUALENV_DISTRIBUTE='true'
    source "${VIRTUALENVWRAPPER_SCRIPT}"

    #alias cdv='cdvirtualenv'
    #alias cds='cdvirtualenv src'
    #alias cde='cdvirtualenv etc'
    #alias cdl='cdvirtualenv lib'
    #alias cde='cdvirtualenv src/$_VENVNAME'

}
_setup_virtualenvwrapper
# -*- mode: shell-script -*-
#
# Shell functions to act as wrapper for Ian Bicking's virtualenv
# (http://pypi.python.org/pypi/virtualenv)
#
#
# Copyright Doug Hellmann, All Rights Reserved
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose and without fee is hereby granted,
# provided that the above copyright notice appear in all copies and that
# both that copyright notice and this permission notice appear in
# supporting documentation, and that the name of Doug Hellmann not be used
# in advertising or publicity pertaining to distribution of the software
# without specific, written prior permission.
#
# DOUG HELLMANN DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
# EVENT SHALL DOUG HELLMANN BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
#
# Project home page: http://www.doughellmann.com/projects/virtualenvwrapper/
#
#
# Setup:
#
#  1. Create a directory to hold the virtual environments.
#     (mkdir $HOME/.virtualenvs).
#  2. Add a line like "export WORKON_HOME=$HOME/.virtualenvs"
#     to your .bashrc.
#  3. Add a line like "source /path/to/this/file/virtualenvwrapper.sh"
#     to your .bashrc.
#  4. Run: source ~/.bashrc
#  5. Run: workon
#  6. A list of environments, empty, is printed.
#  7. Run: mkvirtualenv temp
#  8. Run: workon
#  9. This time, the "temp" environment is included.
# 10. Run: workon temp
# 11. The virtual environment is activated.
#

# Locate the global Python where virtualenvwrapper is installed.
if [ "$VIRTUALENVWRAPPER_PYTHON" = "" ]
then
    VIRTUALENVWRAPPER_PYTHON="$(\which python)"
fi

# Set the name of the virtualenv app to use.
if [ "$VIRTUALENVWRAPPER_VIRTUALENV" = "" ]
then
    VIRTUALENVWRAPPER_VIRTUALENV="virtualenv"
fi

# Define script folder depending on the platorm (Win32/Unix)
VIRTUALENVWRAPPER_ENV_BIN_DIR="bin"
if [ "$OS" = "Windows_NT" ] && [ "$MSYSTEM" = "MINGW32" ]
then
    # Only assign this for msys, cygwin use standard Unix paths
    # and its own python installation
    VIRTUALENVWRAPPER_ENV_BIN_DIR="Scripts"
fi

# Let the user override the name of the file that holds the project
# directory name.
if [ "$VIRTUALENVWRAPPER_PROJECT_FILENAME" = "" ]
then
    export VIRTUALENVWRAPPER_PROJECT_FILENAME=".project"
fi

function virtualenvwrapper_expandpath {
        if [ "$1" = "" ]; then
            return 1
        else
            "$VIRTUALENVWRAPPER_PYTHON" -c "import os,sys; sys.stdout.write(os.path.realpath(os.path.expanduser(os.path.expandvars(\"$1\")))+'\n')"
            return 0
        fi
}

function virtualenvwrapper_derive_workon_home {
    typeset workon_home_dir="$WORKON_HOME"

    # Make sure there is a default value for WORKON_HOME.
    # You can override this setting in your .bashrc.
    if [ "$workon_home_dir" = "" ]
    then
        workon_home_dir="$HOME/.virtualenvs"
    fi

    # If the path is relative, prefix it with $HOME
    # (note: for compatibility)
    if echo "$workon_home_dir" | (unset GREP_OPTIONS; \grep '^[^/~]' > /dev/null)
    then
        workon_home_dir="$HOME/$WORKON_HOME"
    fi

    # Only call on Python to fix the path if it looks like the
    # path might contain stuff to expand.
    # (it might be possible to do this in shell, but I don't know a
    # cross-shell-safe way of doing it -wolever)
    if echo "$workon_home_dir" | (unset GREP_OPTIONS; \egrep '([\$~]|//)' >/dev/null)
    then
        # This will normalize the path by:
        # - Removing extra slashes (e.g., when TMPDIR ends in a slash)
        # - Expanding variables (e.g., $foo)
        # - Converting ~s to complete paths (e.g., ~/ to /home/brian/ and ~arthur to /home/arthur)
        workon_home_dir=$(virtualenvwrapper_expandpath "$workon_home_dir")
    fi

    echo "$workon_home_dir"
    return 0
}

# Check if the WORKON_HOME directory exists,
# create it if it does not
# seperate from creating the files in it because this used to just error
# and maybe other things rely on the dir existing before that happens.
function virtualenvwrapper_verify_workon_home {
    RC=0
    if [ ! -d "$WORKON_HOME/" ]
    then
        if [ "$1" != "-q" ]
        then
            echo "NOTE: Virtual environments directory $WORKON_HOME does not exist. Creating..." 1>&2
        fi
        mkdir -p "$WORKON_HOME"
        RC=$?
    fi
    return $RC
}

#HOOK_VERBOSE_OPTION="-q"

# Expects 1 argument, the suffix for the new file.
function virtualenvwrapper_tempfile {
    # Note: the 'X's must come last
    typeset suffix=${1:-hook}
    typeset file

    file="`\mktemp -t virtualenvwrapper-$suffix-XXXXXXXXXX`"
    if [ $? -ne 0 ] || [ -z "$file" ] || [ ! -f "$file" ]
    then
        echo "ERROR: virtualenvwrapper could not create a temporary file name." 1>&2
        return 1
    fi
    echo $file
    return 0
}

# Run the hooks
function virtualenvwrapper_run_hook {
    typeset hook_script
    typeset result

    hook_script="$(virtualenvwrapper_tempfile ${1}-hook)" || return 1

    if [ -z "$VIRTUALENVWRAPPER_LOG_DIR" ]
    then
        echo "ERROR: VIRTUALENVWRAPPER_LOG_DIR is not set." 1>&2
        \rm -f "$hook_script"
        return 1
    fi
    "$VIRTUALENVWRAPPER_PYTHON" -c 'from virtualenvwrapper.hook_loader import main; main()' $HOOK_VERBOSE_OPTION --script "$hook_script" "$@"
    result=$?

    if [ $result -eq 0 ]
    then
        if [ ! -f "$hook_script" ]
        then
            echo "ERROR: virtualenvwrapper_run_hook could not find temporary file $hook_script" 1>&2
            \rm -f "$hook_script"
            return 2
        fi
        # cat "$hook_script"
        source "$hook_script"
	elif [ "${1}" = "initialize" ]
	then
        cat - 1>&2 <<EOF 
virtualenvwrapper.sh: There was a problem running the initialization hooks. 

If Python could not import the module virtualenvwrapper.hook_loader,
check that virtualenv has been installed for
VIRTUALENVWRAPPER_PYTHON=$VIRTUALENVWRAPPER_PYTHON and that PATH is
set properly.
EOF
    fi
    \rm -f "$hook_script"
    return $result
}

# Set up tab completion.  (Adapted from Arthur Koziel's version at
# http://arthurkoziel.com/2008/10/11/virtualenvwrapper-bash-completion/)
function virtualenvwrapper_setup_tab_completion {
    if [ -n "$BASH" ] ; then
        _virtualenvs () {
            local cur="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W "`virtualenvwrapper_show_workon_options`" -- ${cur}) )
        }
        _cdvirtualenv_complete () {
            local cur="$2"
            COMPREPLY=( $(cdvirtualenv && compgen -d -- "${cur}" ) )
        }
        _cdsitepackages_complete () {
            local cur="$2"
            COMPREPLY=( $(cdsitepackages && compgen -d -- "${cur}" ) )
        }
        complete -o nospace -F _cdvirtualenv_complete -S/ cdvirtualenv
        complete -o nospace -F _cdsitepackages_complete -S/ cdsitepackages
        complete -o default -o nospace -F _virtualenvs workon
        complete -o default -o nospace -F _virtualenvs rmvirtualenv
        complete -o default -o nospace -F _virtualenvs cpvirtualenv
        complete -o default -o nospace -F _virtualenvs showvirtualenv
    elif [ -n "$ZSH_VERSION" ] ; then
        _virtualenvs () {
            reply=( $(virtualenvwrapper_show_workon_options) )
        }
        _cdvirtualenv_complete () {
            reply=( $(cdvirtualenv && ls -d ${1}*) )
        }
        _cdsitepackages_complete () {
            reply=( $(cdsitepackages && ls -d ${1}*) )
        }
        compctl -K _virtualenvs workon rmvirtualenv cpvirtualenv showvirtualenv
        compctl -K _cdvirtualenv_complete cdvirtualenv
        compctl -K _cdsitepackages_complete cdsitepackages
    fi
}

# Set up virtualenvwrapper properly
function virtualenvwrapper_initialize {
    export WORKON_HOME="$(virtualenvwrapper_derive_workon_home)"

    virtualenvwrapper_verify_workon_home -q || return 1

    # Set the location of the hook scripts
    if [ "$VIRTUALENVWRAPPER_HOOK_DIR" = "" ]
    then
        export VIRTUALENVWRAPPER_HOOK_DIR="$WORKON_HOME"
    fi

    # Set the location of the hook script logs
    if [ "$VIRTUALENVWRAPPER_LOG_DIR" = "" ]
    then
        export VIRTUALENVWRAPPER_LOG_DIR="$WORKON_HOME"
    fi

    virtualenvwrapper_run_hook "initialize"

    virtualenvwrapper_setup_tab_completion

    return 0
}


# Verify that virtualenv is installed and visible
function virtualenvwrapper_verify_virtualenv {
    typeset venv=$(\which "$VIRTUALENVWRAPPER_VIRTUALENV" | (unset GREP_OPTIONS; \grep -v "not found"))
    if [ "$venv" = "" ]
    then
        echo "ERROR: virtualenvwrapper could not find $VIRTUALENVWRAPPER_VIRTUALENV in your path" >&2
        return 1
    fi
    if [ ! -e "$venv" ]
    then
        echo "ERROR: Found $VIRTUALENVWRAPPER_VIRTUALENV in path as \"$venv\" but that does not exist" >&2
        return 1
    fi
    return 0
}

# Verify that the requested environment exists
function virtualenvwrapper_verify_workon_environment {
    typeset env_name="$1"
    if [ ! -d "$WORKON_HOME/$env_name" ]
    then
       echo "ERROR: Environment '$env_name' does not exist. Create it with 'mkvirtualenv $env_name'." >&2
       return 1
    fi
    return 0
}

# Verify that the active environment exists
function virtualenvwrapper_verify_active_environment {
    if [ ! -n "${VIRTUAL_ENV}" ] || [ ! -d "${VIRTUAL_ENV}" ]
    then
        echo "ERROR: no virtualenv active, or active virtualenv is missing" >&2
        return 1
    fi
    return 0
}

# Help text for mkvirtualenv
function mkvirtualenv_help {
    echo "Usage: mkvirtualenv [-a project_path] [-i package] [-r requirements_file] [virtualenv options] env_name"
    echo
    echo " -a project_path"
    echo
    echo "    Provide a full path to a project directory to associate with"
    echo "    the new environment."
    echo
    echo " -i package"
    echo
    echo "    Install a package after the environment is created."
    echo "    This option may be repeated."
    echo
    echo " -r requirements_file"
    echo
    echo "    Provide a pip requirements file to install a base set of packages"
    echo "    into the new environment."
    echo;
    echo 'virtualenv help:';
    echo;
    virtualenv $@;
}

# Create a new environment, in the WORKON_HOME.
#
# Usage: mkvirtualenv [options] ENVNAME
# (where the options are passed directly to virtualenv)
#
function mkvirtualenv {
    typeset -a in_args
    typeset -a out_args
    typeset -i i
    typeset tst
    typeset a
    typeset envname
    typeset requirements
    typeset packages

    in_args=( "$@" )

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi
    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        # echo "arg $i : $a"
        case "$a" in
            -a)
                i=$(( $i + 1 ));
                project="${in_args[$i]}";;
            -h|--help)
                mkvirtualenv_help $a;
                return;;
            -i)
                i=$(( $i + 1 ));
                packages="$packages ${in_args[$i]}";;
            -r)
                i=$(( $i + 1 ));
                requirements="${in_args[$i]}";
                requirements=$(virtualenvwrapper_expandpath "$requirements");;
            *)
                if [ ${#out_args} -gt 0 ]
                then
                    out_args=( "${out_args[@]-}" "$a" )
                else
                    out_args=( "$a" )
                fi;;
        esac
        i=$(( $i + 1 ))
    done

    set -- "${out_args[@]}"

    eval "envname=\$$#"
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_virtualenv || return 1
    (
        [ -n "$ZSH_VERSION" ] && setopt SH_WORD_SPLIT
        \cd "$WORKON_HOME" &&
        "$VIRTUALENVWRAPPER_VIRTUALENV" $VIRTUALENVWRAPPER_VIRTUALENV_ARGS "$@" &&
        [ -d "$WORKON_HOME/$envname" ] && \
            virtualenvwrapper_run_hook "pre_mkvirtualenv" "$envname"
    )
    typeset RC=$?
    [ $RC -ne 0 ] && return $RC

    # If they passed a help option or got an error from virtualenv,
    # the environment won't exist.  Use that to tell whether
    # we should switch to the environment and run the hook.
    [ ! -d "$WORKON_HOME/$envname" ] && return 0

    # If they gave us a project directory, set it up now
    # so the activate hooks can find it.
    if [ ! -z "$project" ]
    then
        setvirtualenvproject "$WORKON_HOME/$envname" "$project"
    fi

    # Now activate the new environment
    workon "$envname"

    if [ ! -z "$requirements" ]
    then
        pip install -r "$requirements"
    fi

    for a in $packages
    do
        pip install $a
    done

    virtualenvwrapper_run_hook "post_mkvirtualenv"
}

# Remove an environment, in the WORKON_HOME.
function rmvirtualenv {
    virtualenvwrapper_verify_workon_home || return 1
    if [ ${#@} = 0 ]
    then
        echo "Please specify an enviroment." >&2
        return 1
    fi

    # support to remove several environments
    typeset env_name
    for env_name in $@
    do
        echo "Removing $env_name..."
        typeset env_dir="$WORKON_HOME/$env_name"
        if [ "$VIRTUAL_ENV" = "$env_dir" ]
        then
            echo "ERROR: You cannot remove the active environment ('$env_name')." >&2
            echo "Either switch to another environment, or run 'deactivate'." >&2
            return 1
        fi

        # Move out of the current directory to one known to be
        # safe, in case we are inside the environment somewhere.
        typeset prior_dir="$(pwd)"
        \cd "$WORKON_HOME"

        virtualenvwrapper_run_hook "pre_rmvirtualenv" "$env_name"
        \rm -rf "$env_dir"
        virtualenvwrapper_run_hook "post_rmvirtualenv" "$env_name"

        # If the directory we used to be in still exists, move back to it.
        if [ -d "$prior_dir" ]
        then
            \cd "$prior_dir"
        fi
    done
}

# List the available environments.
function virtualenvwrapper_show_workon_options {
    virtualenvwrapper_verify_workon_home || return 1
    # NOTE: DO NOT use ls here because colorized versions spew control characters
    #       into the output list.
    # echo seems a little faster than find, even with -depth 3.
    (\cd "$WORKON_HOME"; for f in */$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate; do echo $f; done) 2>/dev/null | \sed 's|^\./||' | \sed "s|/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate||" | \sort | (unset GREP_OPTIONS; \egrep -v '^\*$')

#    (\cd "$WORKON_HOME"; find -L . -depth 3 -path '*/bin/activate') | sed 's|^\./||' | sed 's|/bin/activate||' | sort
}

function _lsvirtualenv_usage {
    echo "lsvirtualenv [-blh]"
    echo "  -b -- brief mode"
    echo "  -l -- long mode"
    echo "  -h -- this help message"
}

# List virtual environments
#
# Usage: lsvirtualenv [-l]
function lsvirtualenv {

    typeset long_mode=true
    if command -v "getopts" &> /dev/null
    then
        # Use getopts when possible
        OPTIND=1
        while getopts ":blh" opt "$@"
        do
            case "$opt" in
                l) long_mode=true;;
                b) long_mode=false;;
                h)  _lsvirtualenv_usage;
                    return 1;;
                ?) echo "Invalid option: -$OPTARG" >&2;
                    _lsvirtualenv_usage;
                    return 1;;
            esac
        done
    else
        # fallback on getopt for other shell
        typeset -a args
        args=($(getopt blh "$@"))
        if [ $? != 0 ]
        then
            _lsvirtualenv_usage
            return 1
        fi
        for opt in $args
        do
            case "$opt" in
                -l) long_mode=true;;
                -b) long_mode=false;;
                -h) _lsvirtualenv_usage;
                    return 1;;
            esac
        done
    fi

    if $long_mode
    then
        for env_name in $(virtualenvwrapper_show_workon_options)
        do
            showvirtualenv "$env_name"
        done
    else
        virtualenvwrapper_show_workon_options
    fi
}

# Show details of a virtualenv
#
# Usage: showvirtualenv [env]
function showvirtualenv {
    typeset env_name="$1"
    if [ -z "$env_name" ]
    then
        if [ -z "$VIRTUAL_ENV" ]
        then
            echo "showvirtualenv [env]"
            return 1
        fi
        env_name=$(basename $VIRTUAL_ENV)
    fi

    echo -n "$env_name"
    virtualenvwrapper_run_hook "get_env_details" "$env_name"
    echo
}

# List or change working virtual environments
#
# Usage: workon [environment_name]
#
function workon {
    typeset env_name="$1"
    if [ "$env_name" = "" ]
    then
        lsvirtualenv -b
        return 1
    fi

    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_workon_environment $env_name || return 1

    activate="$WORKON_HOME/$env_name/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate"
    if [ ! -f "$activate" ]
    then
        echo "ERROR: Environment '$WORKON_HOME/$env_name' does not contain an activate script." >&2
        return 1
    fi

    # Deactivate any current environment "destructively"
    # before switching so we use our override function,
    # if it exists.
    type deactivate >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        deactivate
        unset -f deactivate >/dev/null 2>&1
    fi

    virtualenvwrapper_run_hook "pre_activate" "$env_name"

    source "$activate"

    # Save the deactivate function from virtualenv under a different name
    virtualenvwrapper_original_deactivate=`typeset -f deactivate | sed 's/deactivate/virtualenv_deactivate/g'`
    eval "$virtualenvwrapper_original_deactivate"
    unset -f deactivate >/dev/null 2>&1

    # Replace the deactivate() function with a wrapper.
    eval 'deactivate () {

        # Call the local hook before the global so we can undo
        # any settings made by the local postactivate first.
        virtualenvwrapper_run_hook "pre_deactivate"

        env_postdeactivate_hook="$VIRTUAL_ENV/$VIRTUALENVWRAPPER_ENV_BIN_DIR/postdeactivate"
        old_env=$(basename "$VIRTUAL_ENV")

        # Call the original function.
        virtualenv_deactivate $1

        virtualenvwrapper_run_hook "post_deactivate" "$old_env"

        if [ ! "$1" = "nondestructive" ]
        then
            # Remove this function
            unset -f virtualenv_deactivate >/dev/null 2>&1
            unset -f deactivate >/dev/null 2>&1
        fi

    }'

    virtualenvwrapper_run_hook "post_activate"

    return 0
}


# Prints the Python version string for the current interpreter.
function virtualenvwrapper_get_python_version {
    # Uses the Python from the virtualenv rather than
    # VIRTUALENVWRAPPER_PYTHON because we're trying to determine the
    # version installed there so we can build up the path to the
    # site-packages directory.
    "$VIRTUAL_ENV/bin/python" -V 2>&1 | cut -f2 -d' ' | cut -f-2 -d.
}

# Prints the path to the site-packages directory for the current environment.
function virtualenvwrapper_get_site_packages_dir {
    "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_ENV_BIN_DIR/python" -c "import distutils; print(distutils.sysconfig.get_python_lib())"
}

# Path management for packages outside of the virtual env.
# Based on a contribution from James Bennett and Jannis Leidel.
#
# add2virtualenv directory1 directory2 ...
#
# Adds the specified directories to the Python path for the
# currently-active virtualenv. This will be done by placing the
# directory names in a path file named
# "virtualenv_path_extensions.pth" inside the virtualenv's
# site-packages directory; if this file does not exist, it will be
# created first.
function add2virtualenv {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1

    site_packages="`virtualenvwrapper_get_site_packages_dir`"

    if [ ! -d "${site_packages}" ]
    then
        echo "ERROR: currently-active virtualenv does not appear to have a site-packages directory" >&2
        return 1
    fi

    # Prefix with _ to ensure we are loaded as early as possible,
    # and at least before easy_install.pth.
    path_file="$site_packages/_virtualenv_path_extensions.pth"

    if [ "$*" = "" ]
    then
        echo "Usage: add2virtualenv dir [dir ...]"
        if [ -f "$path_file" ]
        then
            echo
            echo "Existing paths:"
            cat "$path_file" | grep -v "^import"
        fi
        return 1
    fi

    remove=0
    if [ "$1" = "-d" ]
    then
        remove=1
        shift
    fi

    if [ ! -f "$path_file" ]
    then
        echo "import sys; sys.__plen = len(sys.path)" >> "$path_file"
        echo "import sys; new=sys.path[sys.__plen:]; del sys.path[sys.__plen:]; p=getattr(sys,'__egginsert',0); sys.path[p:p]=new; sys.__egginsert = p+len(new)" >> "$path_file"
    fi

    for pydir in "$@"
    do
        absolute_path=$("$VIRTUALENVWRAPPER_PYTHON" -c "import os,sys; sys.stdout.write(os.path.abspath(\"$pydir\")+'\n')")
        if [ "$absolute_path" != "$pydir" ]
        then
            echo "Warning: Converting \"$pydir\" to \"$absolute_path\"" 1>&2
        fi

        if [ $remove -eq 1 ]
        then
            sed -i.tmp "\:^$absolute_path$: d" "$path_file"
        else
            sed -i.tmp '1 a\
'"$absolute_path"'
' "$path_file"
        fi
        rm -f "${path_file}.tmp"
    done
    return 0
}

# Does a ``cd`` to the site-packages directory of the currently-active
# virtualenv.
function cdsitepackages {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    typeset site_packages="`virtualenvwrapper_get_site_packages_dir`"
    \cd "$site_packages"/$1
}

# Does a ``cd`` to the root of the currently-active virtualenv.
function cdvirtualenv {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    \cd $VIRTUAL_ENV/$1
}

# Shows the content of the site-packages directory of the currently-active
# virtualenv
function lssitepackages {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    typeset site_packages="`virtualenvwrapper_get_site_packages_dir`"
    ls $@ "$site_packages"

    path_file="$site_packages/_virtualenv_path_extensions.pth"
    if [ -f "$path_file" ]
    then
        echo
        echo "_virtualenv_path_extensions.pth:"
        cat "$path_file"
    fi
}

# Toggles the currently-active virtualenv between having and not having
# access to the global site-packages.
function toggleglobalsitepackages {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    typeset no_global_site_packages_file="`virtualenvwrapper_get_site_packages_dir`/../no-global-site-packages.txt"
    if [ -f $no_global_site_packages_file ]; then
        rm $no_global_site_packages_file
        [ "$1" = "-q" ] || echo "Enabled global site-packages"
    else
        touch $no_global_site_packages_file
        [ "$1" = "-q" ] || echo "Disabled global site-packages"
    fi
}

# Duplicate the named virtualenv to make a new one.
function cpvirtualenv {
    typeset env_name="$1"
    if [ "$env_name" = "" ]
    then
        virtualenvwrapper_show_workon_options
        return 1
    fi
    typeset new_env="$2"
    if [ "$new_env" = "" ]
    then
        echo "Please specify target virtualenv"
        return 1
    fi
    if echo "$WORKON_HOME" | (unset GREP_OPTIONS; \grep "/$" > /dev/null)
    then
        typeset env_home="$WORKON_HOME"
    else
        typeset env_home="$WORKON_HOME/"
    fi
    typeset source_env="$env_home$env_name"
    typeset target_env="$env_home$new_env"

    if [ ! -e "$source_env" ]
    then
        echo "$env_name virtualenv doesn't exist"
        return 1
    fi

    \cp -r "$source_env" "$target_env"
    for script in $( \ls $target_env/$VIRTUALENVWRAPPER_ENV_BIN_DIR/* )
    do
        newscript="$script-new"
        \sed "s|$source_env|$target_env|g" < "$script" > "$newscript"
        \mv "$newscript" "$script"
        \chmod a+x "$script"
    done

    "$VIRTUALENVWRAPPER_VIRTUALENV" "$target_env" --relocatable
    \sed "s/VIRTUAL_ENV\(.*\)$env_name/VIRTUAL_ENV\1$new_env/g" < "$source_env/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate" > "$target_env/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate"

    (\cd "$WORKON_HOME" && (
        virtualenvwrapper_run_hook "pre_cpvirtualenv" "$env_name" "$new_env";
        virtualenvwrapper_run_hook "pre_mkvirtualenv" "$new_env"
        ))
    workon "$new_env"
    virtualenvwrapper_run_hook "post_mkvirtualenv"
    virtualenvwrapper_run_hook "post_cpvirtualenv"
}

#
# virtualenvwrapper project functions
#

# Verify that the PROJECT_HOME directory exists
function virtualenvwrapper_verify_project_home {
    if [ -z "$PROJECT_HOME" ]
    then
        echo "ERROR: Set the PROJECT_HOME shell variable to the name of the directory where projects should be created." >&2
        return 1
    fi
    if [ ! -d "$PROJECT_HOME" ]
    then
        [ "$1" != "-q" ] && echo "ERROR: Project directory '$PROJECT_HOME' does not exist.  Create it or set PROJECT_HOME to an existing directory." >&2
        return 1
    fi
    return 0
}

# Given a virtualenv directory and a project directory,
# set the virtualenv up to be associated with the
# project
function setvirtualenvproject {
    typeset venv="$1"
    typeset prj="$2"
    if [ -z "$venv" ]
    then
        venv="$VIRTUAL_ENV"
    fi
    if [ -z "$prj" ]
    then
        prj="$(pwd)"
    fi
    echo "Setting project for $(basename $venv) to $prj"
    echo "$prj" > "$venv/$VIRTUALENVWRAPPER_PROJECT_FILENAME"
}

# Show help for mkproject
function mkproject_help {
    echo "Usage: mkproject [-t template] [virtualenv options] project_name"
    echo ""
    echo "Multiple templates may be selected.  They are applied in the order"
    echo "specified on the command line."
    echo;
    echo "mkvirtualenv help:"
    echo
    mkvirtualenv -h;
    echo
    echo "Available project templates:"
    echo
    "$VIRTUALENVWRAPPER_PYTHON" -c 'from virtualenvwrapper.hook_loader import main; main()' -l project.template
}

# Create a new project directory and its associated virtualenv.
function mkproject {
    typeset -a in_args
    typeset -a out_args
    typeset -i i
    typeset tst
    typeset a
    typeset t
    typeset templates

    in_args=( "$@" )

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi
    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        # echo "arg $i : $a"
        case "$a" in
            -h)
                mkproject_help;
                return;;
            -t)
                i=$(( $i + 1 ));
                templates="$templates ${in_args[$i]}";;
            *)
                if [ ${#out_args} -gt 0 ]
                then
                    out_args=( "${out_args[@]-}" "$a" )
                else
                    out_args=( "$a" )
                fi;;
        esac
        i=$(( $i + 1 ))
    done

    set -- "${out_args[@]}"

    # echo "templates $templates"
    # echo "remainder $@"
    # return 0

    eval "typeset envname=\$$#"
    virtualenvwrapper_verify_project_home || return 1

    if [ -d "$PROJECT_HOME/$envname" ]
    then
        echo "Project $envname already exists." >&2
        return 1
    fi

    mkvirtualenv "$@" || return 1

    cd "$PROJECT_HOME"

    virtualenvwrapper_run_hook "project.pre_mkproject" $envname

    echo "Creating $PROJECT_HOME/$envname"
    mkdir -p "$PROJECT_HOME/$envname"
    setvirtualenvproject "$VIRTUAL_ENV" "$PROJECT_HOME/$envname"

    cd "$PROJECT_HOME/$envname"

    for t in $templates
    do
        echo
        echo "Applying template $t"
        # For some reason zsh insists on prefixing the template
        # names with a space, so strip them out before passing
        # the value to the hook loader.
        virtualenvwrapper_run_hook --name $(echo $t | sed 's/^ //') "project.template" $envname
    done

    virtualenvwrapper_run_hook "project.post_mkproject"
}

# Change directory to the active project
function cdproject {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    if [ -f "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME" ]
    then
        typeset project_dir=$(cat "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME")
        if [ ! -z "$project_dir" ]
        then
            cd "$project_dir"
        else
            echo "Project directory $project_dir does not exist" 1>&2
            return 1
        fi
    else
        echo "No project set in $VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME" 1>&2
        return 1
    fi
    return 0
}

#
# Temporary virtualenv
#
# Originally part of virtualenvwrapper.tmpenv plugin
#
mktmpenv() {
    typeset tmpenvname
    typeset RC

    # Generate a unique temporary name
    tmpenvname=$("$VIRTUALENVWRAPPER_PYTHON" -c 'import uuid,sys; sys.stdout.write(uuid.uuid4()+"\n")' 2>/dev/null)
    if [ -z "$tmpenvname" ]
    then
        # This python does not support uuid
        tmpenvname=$("$VIRTUALENVWRAPPER_PYTHON" -c 'import random,sys; sys.stdout.write(hex(random.getrandbits(64))[2:-1]+"\n")' 2>/dev/null)
    fi

    # Create the environment
    mkvirtualenv "$@" "$tmpenvname"
    RC=$?
    if [ $RC -ne 0 ]
    then
        return $RC
    fi

    # Change working directory
    cdvirtualenv

    # Create the tmpenv marker file
    echo "This is a temporary environment. It will be deleted when you run 'deactivate'." | tee "$VIRTUAL_ENV/README.tmpenv"

    # Update the postdeactivate script
    cat - >> "$VIRTUAL_ENV/bin/postdeactivate" <<EOF
if [ -f "$VIRTUAL_ENV/README.tmpenv" ]
then
    echo "Removing temporary environment:" $(basename "$VIRTUAL_ENV")
    rmvirtualenv $(basename "$VIRTUAL_ENV")
fi
EOF
}


#
# Invoke the initialization functions
#
virtualenvwrapper_initialize
virtualenvwrapper_derive_workon_home
virtualenvwrapper_tempfile ${1}-hook
\mktemp -t virtualenvwrapper-$suffix-XXXXXXXXXX
# initialize
# user_scripts
#
# Run user-provided scripts
#
[ -f "$VIRTUALENVWRAPPER_HOOK_DIR/initialize" ] && source "$VIRTUALENVWRAPPER_HOOK_DIR/initialize"
#!/bin/bash
# This hook is run during the startup phase when loading virtualenvwrapper.sh.


# TODO: ?
lsvirtualenv() {
    cmd=${1:-"echo"}
    for venv in $(ls -adtr "${WORKON_HOME}"/**/lib/python?.? | \
        sed "s:$WORKON_HOME/\(.*\)/lib/python[0-9]\.[0-9]:\1:g"); do
        $cmd $venv/
    done
}
lsve() {
    lsvirtualenv $@
}


_setup_google_cloud() {
    _GCLOUD_PREFIX="/srv/wrk/google-cloud-sdk"
    #  _setup_google_cloud  -- configure PATH and bash completions for
    #   Google Cloud"

    # The next line updates PATH for the Google Cloud SDK.
    source "${_GCLOUD_PREFIX}/path.bash.inc"

    # The next line enables bash completion for gcloud.
    source "${_GCLOUD_PREFIX}/completion.bash.inc"
}
## .bashrc.venv.sh
#
# sh configuration
# intended to be sourced from (after) ~/.bashrc
## Variables

#  __PROJECTSRC -- path to local project settings script
export __PROJECTSRC="${PROJECT_HOME}/.projectsrc.sh"
[ -f $__PROJECTSRC ] && source $__PROJECTSRC

#  __SRC        -- path/symlink to local repository ($__SRC/hg $__SRC/git)
export __SRC="${HOME}/src"  # TODO: __SRC_HG, __SRC_GIT
[ ! -d $__SRC ] && mkdir -p $__SRC/hg $__SRC/git


#  PATH="~/.local/bin:$PATH" (if not already there)
add_to_path "${HOME}/.local/bin"

#  _VENV       -- path to local venv config script (executable)
export _VENV="${__DOTFILES}/etc/ipython/ipython_config.py"

## Functions

venv() {
#  venv <args>  -- call $_VENV $@
    $_VENV  $@
}

_venv() {
#  _venv <args> -- call $_VENV -E $@
    venv -E $@
}

we () {   
#  we <virtualenv_name> [working_dir] -- workon a virtualenv and load venv
#
#  # $WORKON_HOME/${virtualenv_name}  # == $_VIRTUAL_ENV
#  # $WORKON_HOME/${virtualenv_name}/src/${virtualenv_name | $2}  # == $_WRD
    workon $1 && source <(venv --bash $@)
}

## CD shortcuts

cdb () {
#  cdb      -- cd $_BIN
    cd "${_BIN}"/$@
}
cde () {
#  cde      -- cd $_ETC
    cd "${_ETC}"/$@
}
cdv () {
#  cdv      -- cd $VIRTUAL_ENV
    cd "${VIRTUAL_ENV}"/$@
}
cdve () {
#  cdve     -- cd $WORKON_HOME
    cd "${WORKON_HOME}"/$@
}
cdvar () {
#  cdvar    -- cd $_VAR
    cd "${_VAR}"/$@
}
cdlog () {
#  cdlog    -- cd $_LOG
    cd "${_LOG}"/$@
}
cdww () {
#  cdww     -- cd $_WWW
    cd "${_WWW}"/$@
}
cdl () {
#  cdl      -- cd $_LIB
    cd "${_LIB}"/$@
}
cdpylib () {
#  cdpylib  -- cd $_PYLIB
    cd "${_PYLIB}"/$@
}
cdpysite () {
#  cdpysite -- cd $_PYSITE
    cd "${_PYSITE}"/$@
}
cds () {
#  cds      -- cd $_SRC
    cd "${_SRC}"/$@
}
cdw () {
#  cdw      -- cd $_WRD
    cd "${_WRD}"/$@
}

## Grin search
# virtualenv / virtualenvwrapper
grinv() {
#  grinv    -- grin $VIRTUAL_ENV
    grin --follow $@ "${VIRTUAL_ENV}"
}
grindv() {
#  grindv   -- grind $VIRTUAL_ENV
    grind --follow $@ --dirs "${VIRTUAL_ENV}"
}

# venv
grins() {
#  grins    -- grin $_SRC
    grin --follow $@ "${_SRC}"
}
grinds() {
#  grinds   -- grind $_SRC
    grind --follow $@ --dirs "${_SRC}"
}
grinw() {
#  grinw    -- grin $_WRD
    grin --follow $@ "${_WRD}"
}
grindw() {
#  grindw   -- grind $_WRD
    grind --follow $@ --dirs "${_WRD}"
}

grindctags() {
#  grindctags   -- generate ctags from grind expression (*.py by default)
    args="$@"
    if [ -z $args ]; then
        args='*.py'
    fi
    grind --follow "$args" | ctags -L -
}


_loadaliases() {
#  _loadaliases -- load shell aliases
    alias chmodr='chmod -R'
    alias chownr='chown -R'

    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'

    alias grindp='grind --sys.path'
    alias grinp='grin --sys-path'

    alias fumnt='fusermount -u'

    alias gl='git log --pretty=format:"%h : %an : %s" --topo-order --graph'
    alias gs='git status'
    alias gd='git diff'
    alias gds='git diff -p --stat'
    alias gc='git commit'
    alias gco='git checkout'
    alias gdc='git diff --cached'
    alias gsl='git stash list'
    alias gsn='git stash save'
    alias gss='git stash save'
    alias gitr='git remote -v'


    alias hgl='hg glog --pager=yes'
    alias hgs='hg status'
    alias hgd='hg diff'
    alias hgds='hg diff --stat'
    alias hgdl='hg diff --color=always | less -R'
    alias hgc='hg commit'
    alias hgu='hg update'
    alias hgq='hg qseries'
    alias hgqd='hg qdiff'
    alias hgqs='hg qseries'
    alias hgqn='hg qnew'
    alias hgr='hg paths'

    if [ -n "$__IS_MAC" ]; then
        alias la='ls -A -G'
        alias ll='ls -alF -G'
        alias ls='ls -G'
        alias lt='ls -altr -G'
    else
        alias la='ls -A --color=auto'
        alias ll='ls -alF --color=auto'
        alias ls='ls --color=auto'
        alias lt='ls -altr --color=auto'
    fi

    alias man_='/usr/bin/man'

    alias pfx='ps aufxw'
    alias pfxs='ps aufxw --sort=tty,ppid,pid'

    alias t='tail'
    alias xclip='xclip -selection c'

    alias ssv='supervisord -c "${_SVCFG}"'
    alias sv='supervisorctl -c "${_SVCFG}"'
    alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
    alias svt='sv tail -f'

    alias _glog='hgtk -R "${_WRD}" log'
    alias _log='hg -R "${_WRD}" log'
    alias _make='cd "${_WRD}" && make'
    alias _serve='${_SERVE_}'
    alias _shell='${_SHELL_}'
    alias _test='python "${_WRD_SETUPY}" test'

}
_loadaliases

hgst() {
    repo=${1:-"$(pwd)"}
    shift

    hgopts="-R '${repo}' --pager=no"

    if [ -n "$(echo "$@" | grep "color")" ]; then
        hgopts="${hgopts} --color=always"
    fi
    echo "###"
    echo "## $(pwd)"
    echo '###'
    hg ${hgopts} diff --stat | sed 's/^/## /' -
    echo '###'
    hg ${hgopts} status | sed 's/^/## /' -
    echo '###'
    hg ${hgopts} diff
    echo '###'
}

_set_prompt() {
    if [ -n "$VIRTUAL_ENV_NAME" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            export VIRTUAL_ENV_NAME="$(basename $VIRTUAL_ENV)" # TODO
        else
            unset -v VIRTUAL_ENV_NAME
        fi
    fi

    if [ -n "$BASH_VERSION" ]; then
        if [ "$color_prompt" == yes ]; then
            PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
        else
            PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n\$ '
            unset color_prompt
        fi
    fi
}
_set_prompt
basename $VIRTUAL_ENV


workon_pyramid_app() {
    _VENVNAME=$1
    _APPNAME=$2

    _OPEN_TERMS=${3:-""}

    _VENVCMD="workon ${_VENVNAME}"
    we "${_VENVNAME}" "${_APPNAME}"
    _VENV="${VIRTUAL_ENV}"

    export _SRC="${_VENV}/src"
    export _BIN="${_VENV}/bin"
    export _EGGSRC="${_SRC}/${_APPNAME}"
    export _EGGSETUPPY="${_EGGSRC}/setup.py"
    export _EGGCFG="${_EGGSRC}/development.ini"

    _EDITCFGCMD="${_EDITCMD} ${_EGGCFG}"
    _SHELLCMD="${_BIN}/pshell ${_EGGCFG}"
    _SERVECMD="${_BIN}/pserve --reload --monitor-restart ${_EGGCFG}"
    _TESTCMD="python ${_EGGSETUPPY} nosetests"

    # aliases
    alias _serve="${_SERVECMD}"
    alias _shell="${_SHELLCMD}"
    alias _test="${_TESTCMD}"
    alias _editcfg="${_EDITCFGCMD}"
    alias _glog="hgtk -R "${_EGGSRC}" log"
    alias _log="hg -R "${_EGGSRC}" log"

    alias cdsrc="cd ${_SRC}"
    alias cdbin="cd ${_BIN}"
    alias cdeggsrc="cd ${_EGGSRC}"


    # cd to $_PATH
    cd "${_EGGSRC}"

    if [ "${_OPEN_TERMS}" != "" ]; then
        # open editor
        ${_EDITCMD} "${_EGGSRC}" &
        # open tabs
        #gnome-terminal \
        #    --working-directory="${_EGGSRC}" \
        #    --tab -t "${_APPNAME} serve" -e "bash -c \"${_SERVECMD}; bash -c \"workon_pyramid_app $_VENVNAME $_APPNAME 1\"\"" \
        #    --tab -t "${_APPNAME} shell" -e "bash -c \"${_SHELLCMD}; bash\"" \
        #    --tab -t "${_APPNAME} bash" -e "bash"
    fi
}


## ${EDITOR} configuration
#
#  VIRTUAL_ENV_NAME
#  _CFG = 
#

## Editor
#export USEGVIM=""
_setup_editor() {
    # Configure ${EDITOR}
    export VIMBIN="/usr/bin/vim"
    export GVIMBIN="/usr/bin/gvim"
    export MVIMBIN="/usr/local/bin/mvim"
    export GUIVIMBIN=""
    if [ -x ${GVIMBIN} ]; then
        export GUIVIMBIN=$GVIMBIN
    elif [ -x ${MVIMBIN} ]; then
        export GUIVIMBIN=$MVIMBIN
    fi

    export EDITOR="${VIMBIN}"
    export SUDO_EDITOR="${VIMBIN}"

    if [ -n "${GUIVIMBIN}" ]; then
        VIMCONF="--servername ${VIRTUAL_ENV_NAME:-'EDITOR'} --remote-tab-silent"
        SUDOCONF="--servername sudo.${VIRTUAL_ENV_NAME:-'EDITOR'} --remote-tab-wait-silent"
        export EDITOR="${GUIVIMBIN} ${VIMCONF}"
        export SUDO_EDITOR="${GUIVIMBIN} ${SUDOCONF}"
        alias vim='${VIMBIN}'
        alias gvim="${GUIMVINBIN} ${VIMCONF}"
    else
        unset -f $GVIMBIN
        unset -f $MVIMBIN
        unset -f $USEGVIM
    fi

    export _EDITOR="${EDITOR}"
}
_setup_editor


ggvim() {
    ${EDITOR} $@ 2>&1 > /dev/null
}


e() {
    ${EDITOR} $@
}

edit() {
    ${EDITOR} $@
}

editcfg() {
    ${EDITOR} $_CFG
}

sudoe() {
    EDITOR=${SUDO_EDITOR} sudo -e
}

sudogvim() {
    EDITOR=${SUDO_EDITOR} sudo -e
}


## ViM

vimpager() {
    # TODO: lesspipe
    _PAGER="${HOME}/bin/vimpager"
    if [ -x $_PAGER ]; then
        export PAGER=$_PAGER
    else
        _PAGER="/usr/local/bin/vimpager"
        if [ -x $_PAGER ]; then
            export PAGER=$_PAGER
        fi
    fi
}


## lessv    -- less with less.vim and regular vim
lessv () {

    ## start Vim with less.vim.
    # Read stdin if no arguments were given.
    if [ -t 1 ]; then
        if [ $# -eq 0 ]; then
            ${VIMBIN} --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                -
        else
            ${VIMBIN} \
                --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                $@
        fi
    else
        # Output is not a terminal, cat arguments or stdin
        if [ $# -eq 0 ]; then
            less
        else
            less "$@"
        fi
    fi
}

less_() {
    less $@
}

## lessv    -- less with less.vim and gvim
lessg() {
    VIMBIN=${GUIVIMBIN} lessv $@
}

# view manpages in vim
man() {
    alias man_="/usr/bin/man"
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #if [ "$1" == "man" ]; then
        #    exit 0
        #fi

        #/usr/bin/whatis "$@" >/dev/null
        $(which vim) \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0'
    fi
}

## mang()   -- view manpages in GViM, MacVim
mang() {
    alias man_="/usr/bin/man"
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #if [ "$1" == "man" ]; then
        #    exit 0
        #fi

        #/usr/bin/whatis "$@" >/dev/null
        $GVIMBIN \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0'
    fi
}


## usrlog   -- Userspace shell logging
#  stid -- set or regenerate shell session id
#  
source "${__DOTFILES}/etc/usrlog.sh"
##  usrlog -- REPL command logs in userspace (per $VIRTUAL_ENV)
#
#  _USRLOG (str): path to .usrlog file to which REPL commands are appended
#
#  TERM_ID (str): a terminal identifier with which command loglines will
#  be appended (default: _usrlog_randstr)


_usrlog_set__USRLOG () {
    #_USRLOG=${1:${_USRLOG}}
    if [ -n "$VIRTUAL_ENV" ]; then
        prefix=${VIRTUAL_ENV}
    else
        prefix=${HOME}
    fi

    export _USRLOG="${prefix}/.usrlog"
}

_usrlog_set_HISTFILE () {
    if [ -n "$VIRTUAL_ENV" ]; then
        prefix=${VIRTUAL_ENV}
    else
        prefix=${HOME}
    fi

    if [ -n "$ZSH_VERSION" ]; then
        export HISTFILE="${prefix}/.zsh_history"
    elif [ -n "$BASH" ]; then
        export HISTFILE="${prefix}/.bash_history"
    else
        export HISTFILE="${prefix}/.history"
    fi
}

_usrlog_set_HIST() {
    # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
    HISTSIZE=1000
    HISTFILESIZE=1000000

    # avoid duplicating datetimes in .usrlog
    HISTTIMEFORMAT=""

    # don't put duplicate lines in the history. See bash(1) for more options
    # ... or force ignoredups and ignorespace
    HISTCONTROL=ignoredups:ignorespace

    if [ -n "$BASH" ] ; then
        # append to the history file, don't overwrite it
        shopt -s histappend
    elif [ -n "$ZSH_VERSION" ]; then
        setopt APPEND_HISTORY
        setopt EXTENDED_HISTORY
    fi

    _usrlog_set_HISTFILE
}

_usrlog_randstr() {
    # Generate a random string
    # param $1: number of characters

    if [[ `uname -s` == "Darwin" ]]; then
        echo $(dd if=/dev/urandom bs=1 count=$1 2>/dev/null |
                base64 -b 0 |
                rev |
                cut -b 2- |
                tr '/+' '0' |
                rev)
    else
        echo $(dd if=/dev/urandom bs=1 count=$1 2>/dev/null |
                base64 -w 0 |
                rev |
                cut -b 2- |
                tr '/+' '0' |
                rev)
            fi
}

_usrlog_get_TERM_ID() {
    echo "# TERM_ID="$TERM_ID" [ $_USRLOG ]" >&2
    echo $TERM_ID
}


_usrlog_set_TERM_ID () {
    # Set an explicit terminal name
    # param $1: terminal name
    new_term_id="${1}"
    if [ -z "${new_term_id}" ]; then
        new_term_id=$(_usrlog_randstr 8)
    fi
    if [[ "${new_term_id}" != "${TERM_ID}" ]]; then
        if [ -z "${TERM_ID}" ]; then
            RENAME_MSG="# new_term_id ::: ${new_term_id} [ ${_USRLOG} ]"
        else
            RENAME_MSG="# set_term_id ::: ${TERM_ID} -> ${new_term_id} [ ${_USRLOG} ]"
        fi
        echo $RENAME_MSG
        _usrlog_append "$RENAME_MSG"
        export TERM_ID="${new_term_id}"
        _usrlog_set_title
    fi
}


_usrlog_echo_title () {
    # TODO: VIRTUAL_ENV_NAME / VIRTUAL_ENV
    echo -ne "\033]0;${WINDOW_TITLE:+"$WINDOW_TITLE "}${VIRTUAL_ENV_NAME:+"($VIRTUAL_ENV_NAME) "}${USER}@${HOSTNAME}:${PWD}\007"
}

_usrlog_set_title() {
    ## set xterm title
    export WINDOW_TITLE=${1:-"$TERM_ID"}
    _usrlog_echo_title
}

_usrlog_setup() {
    # Bash profile setup for logging unique console sessions
    _usrlog="${1:-$_USRLOG}"
    term_id="${2:-$TERM_ID}"

    _usrlog_set_HIST

    _usrlog_set__USRLOG $_usrlog

    #TERM_SED_STR='s/^\s*[0-9]*\s\(.*\)/$TERM_ID: \1/'
    TERM_SED_STR='s/^\s*[0-9]*\s*//'

    _usrlog_set_TERM_ID $term_id
    touch $_USRLOG

    _usrlog_set_title $TERM_ID

    # setup bash
    if [ -n "$BASH" ]; then
        PROMPT_COMMAND="_usrlog_writecmd; _usrlog_echo_title;"
    fi

    # setup zsh
    if [ -n "$ZSH_VERSION" ]; then
        precmd_functions=(_usrlog_writecmd _usrlog_echo_title)
    fi
}


_usrlog_append() {
    # Write a line to the _USRLOG file
    # param $1: text (command) to log
    printf "# %-11s: %s ::: %s\n" \
        "$TERM_ID" \
        "$(date +'%D %R.%S')" \
        "${1:-'\n'}" | tee -a $_USRLOG >&2
}

_usrlog_writecmd() {
    _usrlog_set_HISTFILE

    if [ -n "$ZSH_VERSION" ]; then
        id 2>&1 > /dev/null
        _cmd=$(fc -l -1 | sed -e $TERM_SED_STR)
    elif [ -n "$BASH" ]; then
        _cmd=$(history 1 | sed -e $TERM_SED_STR)
    else
        _cmd=$(history 1 | sed -e $TERM_SED_STR)
    fi
    _usrlog_append "${_cmd}"
}



# usrlog shell command "API"

termid() {
    _usrlog_get_TERM_ID
}

stid () {
    # Shortcut alias to _usrlog_set_TERM_ID
    _usrlog_set_TERM_ID $@
}


hist() {
    # Alias to less the current session log
    less $_USRLOG
}


histgrep () {
    egrep "$@" $_USRLOG 
}

histgrep_session () {
    # Grep for specific sessions
    # param $1: session name
    # param $2: don't strip the line prefix
    NO_STRIP_LINE_PREFIX=$2
    #echo $_USRLOG >&2
    cat $_USRLOG | egrep "$1 .* \:\:\:|Renaming .* to $1" | \
        if [ -n $NO_STRIP_LINE_PREFIX ]; then
            sed -e 's/^\s*.*\:\:\:\s\(.*\)/\1/'
        else
            cat
        fi
}

usrlog_screenrec() {
    # Record the screen
    # param $1: destination directory (use /tmp if possible)
    # param $2: video name to append to datestamp

    # Press "q" to stop recording

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

_usrlog_setup
_usrlog_setup


## xlck     -- screensaver
if [ ! -d '/Library' ]; then  # not on OSX
    source "${__DOTFILES}/etc/xlck.sh"
fi

# .bashrc commands

## file paths

#__THIS=$(readlink -e "$0")
#__THISDIR=$(dirname "${__THIS}")

path () {
    # print absolute path to file
    echo "$PWD/"$1""
}

expandpath () {
    # Enumerate files from PATH

    COMMAND=${1-"ls -alZ"}
    PATHS=$(echo $PATH | tr ':' ' ')

    for p in $PATHS; do
        find "$p" -type f -print0 | xargs -0 $COMMAND
    done

    echo "#" $PATH
    for p in $PATHS; do
        echo "# " $p
    done
}


_trail () {
    # walk upwards from a path
    # see: http://superuser.com/a/65076  
    unset path
    _pwd=${1:-$(pwd)}
    parts=$(echo ${_pwd} | awk 'BEGIN{FS="/"}{for (i=1; i < NF; i++) print $i}')

    for part in $parts; do
        path="$path/$part"
        ls -ldZ $path
    done

}

chown-me () {
    set -x
    chown -Rv $(id -un):$(id -un) $@
    chmod -Rv go-rwx $@
    set +x

}
chown-sme () {
    set -x
    sudo chown -Rv $(id -un):$(id -un) $@
    sudo chmod -Rv go-rwx $@
    set +x

}
chown-user () {
    set -x
    chown -Rv $(id -un):$(id -un) $@
    chmod -Rv go-rwx $@
    set +x
}

new-sh () {
    # Create and open a new shell script
    file=$1
    if [ -e $1 ]
        then echo "$1 exists"
        else
        touch $1
        echo "#!/bin/sh" >> $1
        echo "" >> $1
        chmod 700 $1
        $EDITOR +2 $1
    fi
}

diff-dirs () {
    # List differences between directories
    F1=$1
    F2=$2

    #FIND="find . -printf '%T@\t%s\t%u\t%Y\t%p\n'"
    diff -Naur \
        <(cd $F1; find . | sort ) \
        <(cd $F2; find . | sort )
}

diff-stdin () {
    # Diff the output of two commands
    DIFFBIN='diff'
    $DIFFBIN -u <($1) <($2)
}

wopen () {
    # open in new tab
    python -m webbrowser -t $@
}

find_largefiles () {
    SIZE=${1:-"+10M"}
    find . -xdev -type f -size "${SIZE}" -exec ls -alh {} \;
}
find_pdf () {
    SPATH='.'
    files=$(find "$SPATH" -type f -iname '*.pdf' -printf "%T+||%p\n" | sort -n)
    for f in $files; do
        echo '\n==============='$f;
        fname="$(echo "$f" | pycut -d'||' -f1)";
        echo "FNAME" $fname
        ls -l "$fname"
        pdfinfo "$fname" | egrep --color=none 'Title|Keywords|Author';
    done
}
find_lately () {
    set -x
    paths=$@
    lately="lately.$(date +'%Y%m%d%H%M%S')"

    find $paths -printf "%T@\t%s\t%u\t%Y\t%p\n" | tee $lately
    # time_epoch \t size \t user \t type \t path
    sort $lately > $lately.sorted

    less $lately.sorted
    set +x
    #for p in $paths; do
    #    repos -s $p
    #done
}

find_setuid () {
    find /  -type f \( -perm -4000 -o -perm -2000 \) -exec ls -ld '{}' \;
}
find_startup () {
    cmd=${@:-"ls"}
    paths='/etc/rc?.d /etc/init.d /etc/init /etc/xdg/autostart /etc/dbus-1'
    paths="$paths ~/.config/autostart /usr/share/gnome/autostart"
    for p in $paths; do
        if [ -d $p ]; then
            find $p -type f | xargs $cmd
        fi
    done
}

find_ssl() {
    # apt-get install libnss3-tools
    _runcmd(){
        cmd="${1}"
        desc="${2}"
        echo "#######"
        echo "'${cmd}' : ${desc}"
        echo "#------"
        echo -e "$($cmd)"
        echo -e "\n#."
    }

    for cert in $(locate *.pem); do
        echo "-- $cert --"
        openssl x509 -in $cert -text
    done
    for d in $(locate '*.db' | egrep 'key[[:digit:]].db'); do  
        kpath=$(dirname $d) 
        _runcmd "certutil  -L -d sql:${kpath}"  "${kpath}"
    done
}

find_pkgfile () {
    apt-file search $@
}

find_pkgfiles () {
    cat /var/lib/dpkg/info/$1.list | sort
}

deb_chksums () {
    # checks filesystem against dpkg's md5sums 
    #
    # Author: Filippo Giunchedi <filippo@esaurito.net>
    # Version: 0.1
    #
    # this file is public domain 

    exclude="usr/share/locale/"
    include="bin/"

    pushd .
    cd /

    for f in /var/lib/dpkg/info/*.md5sums; do
        package=$( basename "$f" | cut -d. -f1 )
        tmpfile=$( mktemp /tmp/dpkgcheck.XXXXXX )
        egrep "$include" "$f" | egrep -v "$exclude" > $tmpfile
        if [ -z "$(head $tmpfile)" ]; then continue; fi
        md5sum -c "$tmpfile"
        if [ $? -gt 0 ]; then
            echo "md5sum for $package has failed!"
            rm "$tmpfile"
            break
        fi
        rm "$tmpfile"
    done

    popd
}

deb_mkrepo () {
    REPODIR=${1:-"/var/www/nginx-default/"}
    cd $REPODIR
    dpkg-scanpackages . /dev/null | gzip -9c > $REPODIR/Packages.gz
    dpkg-scansources . /dev/null | gzip -9c > $REPODIR/Sources.gz
}

mnt_bind () {
    DEST=$1
    mount -o bind /dev ${DEST}/dev
    mount -o bind /proc ${DEST}/proc
    mount -o bind /sys ${DEST}/sys
    # TODO
}
mnt_cifs () {
    URI="$1" # //host/share
    MNTPT="$2"
    OPTIONS="-o user=$3,password=$4"
    mount -t cifs $OPTIONS $URI $MNTPT
}
mnt_davfs () {
    #!/bin/sh
    URL="$1"
    MNTPT="$2"
    OPTIONS="-o rw,user,noauto"
    mount -t davfs $OPTIONS $URL $MNTPT
}

lsof_ () {
    #!/bin/bash 

    processes=$(find /proc -regextype egrep -maxdepth 1 -type d -readable -regex '.*[[:digit:]]+')

    for p in $processes; do
        cmdline=$(cat $p/cmdline)
        cmd=$(echo $cmdline | sed 's/\(.*\)\s.*/\1/g' | sed 's/\//\\\//g')
        pid=$(echo $p | sed 's/\/proc\/\([0-9]*\)/\1/')
        echo $pid $cmdline 
        #maps=$(cat $p/maps )
        sed_pattern="s/\(.*\)/$pid \1\t$cmd/g"
        cat $p/maps | sed "$sed_pattern"

    done

    #~ lsof_ | grep 'fb' | pycut -f 6,5,0,2,1,7 -O '%s' | sort -n 
}


lsof_net () {
    ARGS=${@:-''}
    for pid in `lsof -n -t -U -i4 2>/dev/null`; do
        echo "-----------";
        ps $pid;
        lsof -n -a $ARGS -p $pid 2>/dev/null;
    done
}


net_stat () {
    echo "# net_stat:"  `date`
    echo "#####################################################"
    set -x
    sudo ip a 2>&1
    sudo ip r 2>&1
    sudo ifconfig -a 2>&1
    sudo route -n 2>&1
    sudo iptables -L -n 2>&1
    sudo netstat -ntaup 2>&1 | sort -n
    set +x
}



ssh_prx () {
    RUSERHOST=$1
    RPORT=$2

    LOCADDR=${3:-"10.10.10.10"}
    PRXADDR="$LOCADDR:1080"
    sudo ip addr add $LOCADDR dev lo netmask 255.255.255.0
    ssh -ND $PRXADDR $RUSERHOST -p $RPORT

    echo "$PRXADDR"
}

strace_ () {
    strace -ttt -f -F $@ 2>&1
}
strace_f () {
    strace_ -e trace=file $@
}

strace_f_noeno () {
    strace_ -e trace=file $@ 2>&1 \
        | grep -v '-1 ENOENT (No such file or directory)$' 
}



unumask() {
    path=$1
    sudo find "${path}" -type f -exec chmod -v o+r {} \;
    sudo find "${path}" -type d -exec chmod -v o+rx {} \;
}

_rro_find_repo() {
    [ -d $1/.hg ] || [ -d $1/.git ] || [ -d $1/.bzr ] && cd $path
}

rro () {
    # walk down a path
    # see: http://superuser.com/a/65076 
    # FIXME
    # TODO
    unset path
    _pwd=$(pwd)
    parts=$(pwd | awk 'BEGIN{FS="/"}{for (i=1; i < NF+1; i++) print "/"$i}')

    _rro_find_repo $_pwd
    for part in $parts; do
        path="$path/$part"
       
        ls -ld $path
        _rro_find_repo $path

    done
}

## bashmarks
#  l    -- list bashmarks
#  s    -- save bashmarks as $1
#  g    -- goto bashmark $1
#  p    -- print bashmark $1
#  d    -- delete bashmark $1
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
#  lsbashmarks -- list Bashmarks (e.g. for NERDTree)
lsbashmarks () {
    export | grep 'DIR_' | pyline "line[15:].replace('\"','').split('=',1)"
}

# ~/.dotfiles/bin/nerdtree_to_bashmarks.py




export __DOCSWWW="${HOME}/docs"
[ ! -d $__DOCSWWW ] && mkdir -p $__DOCSWWW

fixperms () {
    __PATH=$1
    sudo chown -R hg:hgweb "$__PATH"
    sudo chmod -R g+rw "$__PATH"
}

# __SRC_GIT_REMOTE_URI_PREFIX   -- default git remote uri prefix
__SRC_GIT_REMOTE_URI_PREFIX="ssh://git@git.create.wrd.nu"
# __SRC_GIT_REMOTE_NAME         -- name for git remote v
__SRC_GIT_REMOTE_NAME="create"
# __SRC_HG_REMOTE_URI_PREFIX    -- default hg remote uri prefix
__SRC_HG_REMOTE_URI_PREFIX="ssh://hg@hg.create.wrd.nu"
# __SRC_HG_REMOTE_NAME          -- name for hg paths
__SRC_HG_REMOTE_NAME="create"

__SRC_GIT_GITOLITE_ADMIN=$HOME/gitolite-admin

Git_create_new_repo(){
    ## Create a new hosted repository with gitolite-admin
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1  # (e.g. westurner/dotfiles)
    cd $__SRC_GIT_GITOLITE_ADMIN_REPO && \
    ./add_repo.sh "$reponame" 
}

Git_pushtocreate() {
    ## push a git repository to local git storage
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles) 
    reponame=$1
    repo_uri="${__SRC_GIT_URI}/${reponame}"
    here=$(pwd)
    #  $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
    repo_local_path=$2
    remote_name=${__SRC_GIT_REMOTE_NAME}

    Git_create_new_repo $reponame
    (cd $repo_local_path;  \
        git remote add $remote_name $repo_uri  \
            "${__SRC_GIT_URI}/${username}/${reponame}" && \
        git push --all $remote_name && \
        cd $here)
}

Hg_create_new_repo() {
    ## Create a new hosted repository with mercurial-ssh
    reponame=$1
    cd $__SRC_HG_SERVER_REMOTE_ADMIN && \
        ./add_repo.sh "$reponame"  # TODO: create add_repo.sh
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
    if [ -d $path ]; then
        echo "$path existing. Exiting." >&2
        echo "see: update_repo $1"
        return 0
    fi
    sudo -u hg -i /usr/bin/hg clone $url $path
    fixperms $path
}

Hg() {
    path="${__SRC}/hg/$1"
    path=${path:-'.'}
    shift
    cmd=$@
    sudo -H -u hg -i /usr/bin/hg -R "${path}" $cmd

    #if [ $? -eq 0 ]; then
    #    fixperms ${path}
    #fi
}

Hgcheck() {
    path="${__SRC}/$1"
    path=${path:-'.'}
    shift
    Hg $path tags
    Hg $path id -n
    Hg $path id
    Hg $path branch

    #TODO: last pulled time
}

Hgupdate() {
    path=$1
    shift
    Hg $path update $@
}

Hgstatus() {
    path=$1
    shift
    Hg $path update $@
}

Hgpull() {
    path=$1
    shift
    Hg $path pull $@
    Hgcheck $path
}

Hglog() {
    path=$1
    shift
    Hg -R $path log $@
}

Hgcompare () {
    one=$1
    two=$2
    diff -Naur \
        <(hg -R "${one}" log) \
        <(hg -R "${two}" log)
}

host_docs () {
    # host_docs <project_name> <path> <docs/Makefile> <docs/conf.py>
    # * log documentation builds
    # * build a sphinx documentation set with a Makefile and a conf.py
    # * rsync to docs webserver
    # * set permissions

    # this is not readthedocs.org

    # note: you must manually install packages into the
    # local 'docs' virtualenv'
    set -x
    pushd .
    #workon docs
    name=${1}

    if [ -z "${name}" ]; then
        echo "must specify an application name"
        return 1
    fi

    path=${2:-"${__SRC}/${name}"}
    _makefile=${3}
    _confpy=${4}
    _default_makefile="${path}/docs/Makefile"
    _default_confpy="${path}/docs/conf.py"

    _default_builddir="${path}/_build"

    dest="${__DOCSWWW}/${name}"
    group="www-data"

    if [ -z "${_makefile}" ]; then
        if [ -f $_default_makefile ]; then
            _makefile=$_default_makefile;
        else
            echo "404: default_makefile: $_default_makefile" >&2
            __makefiles=$(find "${path}" -maxdepth 2 -type f -name Makefile)
            for __makefile in ${__makefiles[@]}; do
                if [ -n "${__makefile}" ]; then
                    grep -n -H 'sphinx-build' ${__makefile}
                    if [ $? -eq 0 ]; then
                        echo 'found sphinx-build Makefile: $__makefile'
                        # TODO: prompt?
                        _makefile=$__makefile
                    fi
                fi
            done
        fi

        if [ -f "${_makefile}" ]; then
            _builddir=$(dirname $_makefile)
        fi
    fi

    if [ -z "${_confpy}" ]; then
        if [ -f $_default_confpy ]; then
            _confpy=$_default_confpy;
        else
            echo "404: default_confpy: $_default_confpy" >&2
            confpys=$(find "${path}" -maxdepth 2 -type f -name conf.py)
            for __confpy in ${confpys[@]}; do
                grep -n -H 'sphinx-build' ${__confpy}
                if [ $? -eq 0 ]; then
                    echo 'found conf.py: $__confpy'
                    # TODO: prompt?
                    _confpy=$__confpy
                fi
            done
        fi

        if [ ! -f $_makefile ]; then
            _builddir=$(dirname $__confpy)
        fi

    fi

    _builddir=${_builddir:-${_default_builddir}}
    _buildlog="${_builddir}/build.log"
    _currentbuildlog="${_builddir}/build.current.log"


    cd $path
    rm -f $_currentbuildlog
    html_path=""
    echo '#' $(date) | tee -a $_buildlog | tee $_currentbuildlog

    if [ -n "$_makefile" ]; then
        # TODO
        # >> 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default -Dother '
        # << 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default'
        #sed -i -r 's/(^SPHINXBUILD)( *= *)(sphinx-build)(.*)/\1\2\3 -Dhtml_theme="default"/g' $_makefile

        cd $(dirname $_makefile)
        make \
            SPHINXBUILD="sphinx-build -Dhtml_theme=\"default\"" \
            html | \
            tee -a $_buildlog | tee $_currentbuildlog
        html_path=$(tail -n 1 $_currentbuildlog | \
            sed -r 's/(.*)The HTML pages are in (.*).$/\2/g')
        echo $html_path

    elif [ -n "$_confpy" ]; then
        # >> 'html_theme = "_-_"
        # << 'html_theme = 'default'
        sed -i -r 's/(^ *html_theme)( *= *)(.*)/\1\2"default"' $_confpy
        sourcedir=$(dirname $_confpy)
        html_path="${sourcedir}/_build/html"
        mkdir -p $html_path
        sphinx-build \
            -b html \
            -D html_theme="default" \
            -c "${_confpy}" \
            $sourcedir \
            $html_path
    fi

    if [ -n "${html_path}" ]; then
        echo "html-path:" ${html_path}
        echo "dest:" ${dest}
        set -x
        rsync -avr "${html_path}/" "${dest}/" | tee -a $_buildlog | tee $_currentbuildlog
        set +x
        sudo chgrp -R $group "${dest}" | tee -a $_buildlog | tee $_currentbuildlog
    else
        echo "### ${_currentbuildlog}"
        cat $_currentbuildlog
    fi

    popd

    set +x
    deactivate
}




exit
exit
