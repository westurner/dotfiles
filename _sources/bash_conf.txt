
::

   # etc/bash/00-bashrc.before.sh
                            from ${__DOTFILES}/etc/bash
    __DOTFILES (str)     -- path to this dotfiles repository (~/.dotfiles)
    detect_platform() -- set __IS_MAC, __IS_LINUX vars [01-bashrc.lib.sh]
                         egrep -nr -C 3 '__IS_MAC|__IS_LINUX'
    $__DOTFILES (str): path to local dotfiles repository clone
    dotfiles_status(): print dotfiles env config
    $PROJECT_HOME (str): path to project directory (~/wrk)
    $WORKON_HOME  (str): path to virtualenvs directory (~/wrk/.ve)
    $VIRTUAL_ENV  (str): path to current $VIRTUAL_ENV
    _setup_anaconda()      -- setup anaconda paths (manual)
    _setup_pyenv()         -- setup pyenv paths (manual)
    _setup_google_cloud()  -- setup google cloud paths
    $_VENVNAME (str): name of current $VIRTUAL_ENV
    we() -- workon a new venv (source bin/activate; update ENVIRON)
            we() -> workon $1 [$_APP] && source <($_VENV --bash $@)
            example::
               we dotfiles
               we dotfiles etc/bash; ls -al; git status
   test -f $__PROJECTS && source $__PROJECTS
    $_EDIT_ (str): cmdstring to open $@ (file list) in current editor
    $EDITOR (str): cmdstring to open $@ (file list) in current editor
    $PAGER (str): cmdstring to run pager (less/vim)
    $_USRLOG (str): path to .usrlog command log
    stid           -- set $TERM_ID to a random string
    stid $name     -- set $TERM_ID to string
    note           -- add a dated note to $_USRLOG [_usrlog_append]
    usrlogv        -- open usrlog with vim:   $VIMBIN + $_USRLOG
    usrlogg        -- open usrlog with gmvim: $GUIVIMBIN + $_USRLOG
    usrloge        -- open usrlog with editor:$EDITOR + $_USRLOG
   
   
   # etc/bash/01-bashrc.lib.sh
    add_to_path  -- prepend a directory to $PATH
    lightpath    -- display $PATH with newlines
    lspath       -- list files in each directory in $PATH
   LS_OPTS="-aldZ"
    lspath_less  -- lspath with less
     echo_args   -- echo $@ (for checking quoting)
    pypath       -- print python sys.path and site config
   
   
   # etc/bash/03-bashrc.readline.sh
    vi-mode: vi(m) keyboard shortcuts
    .         -- insert last argument (command mode)
    <ctrl> l  -- clear screen
    <ctrl> a  -- move to beginning of line (^)
    <ctrl> e  -- move to end of line ($)
    <ctrl> w  -- delete last word
   
   
   # etc/bash/04-bashrc.TERM.sh
   configure_term [#term] -- screen, xterm, 
   tmux
   screen
   zsh+tmux: oh-my-zsh/plugins/tmux/tmux.plugin.zsh
    CLICOLOR=1   # ls colors
    CLICOLOR_256=1
   export CLICOLOR_256=$CLICOLOR
   
   
   # etc/bash/05-bashrc.dotfiles.sh
    dotfiles_status  -- print dotfiles_status
    ds               -- print dotfiles_status
   Add dotfiles executable directories to $PATH
   
   
   # etc/bash/07-bashrc.python.sh
   Generate python cmdline docs::
   
      man python | cat | egrep 'ENVIRONMENT VARIABLES' -A 200 | egrep 'AUTHOR' -B 200 | head -n -1 | pyline -r '\s*([\w]+)$' 'rgx and rgx.group(1)'
   Python
   
   
   # etc/bash/07-bashrc.virtualenv.sh
   
   
   # etc/bash/07-bashrc.virtualenvwrapper.sh
   sudo apt-get install virtualenvwrapper || easy_install virtualenvwrapper
   TODO: ?
   
   
   # etc/bash/08-bashrc.gcloud.sh
    _setup_google_cloud  -- configure PATH and bash completions for
     Google Cloud"
   The next line updates PATH for the Google Cloud SDK.
   The next line enables bash completion for gcloud.
   
   
   # etc/bash/10-bashrc.venv.sh
   
   sh configuration
   intended to be sourced from (after) ~/.bashrc
    __PROJECTSRC -- path to local project settings script
    __SRC        -- path/symlink to local repository ($__SRC/hg $__SRC/git)
    PATH="~/.local/bin:$PATH" (if not already there)
    _VENV       -- path to local venv config script (executable)
    venv <args>  -- call $_VENV $@
    _venv <args> -- call $_VENV -E $@
    we <virtualenv_name> [working_dir] -- workon a virtualenv and load venv
   
    # $WORKON_HOME/${virtualenv_name}  # == $_VIRTUAL_ENV
    # $WORKON_HOME/${virtualenv_name}/src/${virtualenv_name | $2}  # == $_WRD
    cdb      -- cd $_BIN
    cde      -- cd $_ETC
    cdv      -- cd $VIRTUAL_ENV
    cdve     -- cd $WORKON_HOME
    cdvar    -- cd $_VAR
    cdlog    -- cd $_LOG
    cdww     -- cd $_WWW
    cdl      -- cd $_LIB
    cdpylib  -- cd $_PYLIB
    cdpysite -- cd $_PYSITE
    cds      -- cd $_SRC
    cdw      -- cd $_WRD
   virtualenv / virtualenvwrapper
    grinv    -- grin $VIRTUAL_ENV
    grindv   -- grind $VIRTUAL_ENV
   venv
    grins    -- grin $_SRC
    grinds   -- grind $_SRC
    grinw    -- grin $_WRD
    grindw   -- grind $_WRD
    grindctags   -- generate ctags from grind expression (*.py by default)
    _loadaliases -- load shell aliases
   
   
   # etc/bash/11-bashrc.venv.pyramid.sh
   
   
   # etc/bash/20-bashrc.editor.sh
   
    VIRTUAL_ENV_NAME
    _CFG = 
   
   Configure ${EDITOR}
   
   
   # etc/bash/29-bashrc.vimpagers.sh
   TODO: lesspipe
   Read stdin if no arguments were given.
   Output is not a terminal, cat arguments or stdin
      exit 0
   
   
   # etc/bash/30-bashrc.usrlog.sh
    
   
   
   # etc/bash/30-bashrc.xlck.sh
   
   
   # etc/bash/40-bashrc.aliases.sh
   .bashrc commands
   print absolute path to file
   Enumerate files from PATH
   walk upwards from a path
   see: http://superuser.com/a/65076  
   Create and open a new shell script
   List differences between directories
   Diff the output of two commands
   open in new tab
   time_epoch \t size \t user \t type \t path
      repos -s $p
   apt-get install libnss3-tools
   checks filesystem against dpkg's md5sums 
   
   Author: Filippo Giunchedi <filippo@esaurito.net>
   Version: 0.1
   
   this file is public domain 
   TODO
   walk down a path
   see: http://superuser.com/a/65076 
   FIXME
   TODO
   
   
   # etc/bash/50-bashrc.bashmarks.sh
    l    -- list bashmarks
    s    -- save bashmarks as $1
    g    -- goto bashmark $1
    p    -- print bashmark $1
    d    -- delete bashmark $1
    lsbashmarks -- list Bashmarks (e.g. for NERDTree)
   ~/.dotfiles/bin/nerdtree_to_bashmarks.py
   
   
   # etc/bash/70-bashrc.repos.sh
   __SRC_GIT_REMOTE_URI_PREFIX   -- default git remote uri prefix
   __SRC_GIT_REMOTE_NAME         -- name for git remote v
   __SRC_HG_REMOTE_URI_PREFIX    -- default hg remote uri prefix
   __SRC_HG_REMOTE_NAME          -- name for hg paths
    $1   -- repo [user/]name (e.g. westurner/dotfiles)
    $1   -- repo [user/]name (e.g. westurner/dotfiles) 
    $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
    $1   -- repo [user/]name (e.g. westurner/dotfiles)
    $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
      fixperms ${path}
   host_docs <project_name> <path> <docs/Makefile> <docs/conf.py>
   * log documentation builds
   * build a sphinx documentation set with a Makefile and a conf.py
   * rsync to docs webserver
   * set permissions
   this is not readthedocs.org
   note: you must manually install packages into the
   local 'docs' virtualenv'
   TODO: prompt?
   TODO: prompt?
   TODO
   >> 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default -Dother '
   << 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default'
   >> 'html_theme = "_-_"
   << 'html_theme = 'default'
   
   
   # etc/bash/99-bashrc.after.sh
   
   
