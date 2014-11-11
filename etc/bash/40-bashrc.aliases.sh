
### bashrc.aliases.sh

_loadaliases () {
    #  _load_aliases()  -- load aliases
    alias chmodr='chmod -R'
    alias chownr='chown -R'

    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'

    alias grindp='grind --sys.path'
    alias grinp='grin --sys-path'

    alias fumnt='fusermount -u'

    alias ga='git add'
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

    if [ -n "${__IS_MAC}" ]; then
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

    if [ -n "${__IS_LINUX}" ]; then
        alias psx='ps uxaw'
        alias psf='ps uxawf'
        alias psxs='ps uxawf --sort=tty,ppid,pid'
        alias psxh='ps uxawf --sort=tty,ppid,pid | head'

        alias psh='ps uxaw | head'

        alias psc='ps uxaw --sort=-pcpu'
        alias psch='ps uxaw --sort=-pcpu | head'

        alias psm='ps uxaw --sort=-pmem'
        alias psmh='ps uxaw --sort=-pmem | head'
    elif [ -n "${__IS_MAC}" ]; then
        alias psx='ps uxaw'
        alias psf='ps uxaw' # no -f

        alias psh='ps uxaw | head'

        alias psc='ps uxaw -c'
        alias psch='ps uxaw -c | head'

        alias psm='ps uxaw -m'
        alias psmh='ps uxaw -m | head'
    fi
    
    alias shtop='sudo htop'
    alias t='tail'
    alias tf='tail -f'
    alias xclipc='xclip -selection c'
}
_loadaliases


