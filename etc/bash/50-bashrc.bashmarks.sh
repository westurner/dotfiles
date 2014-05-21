## bashmarks
#  l    -- list bashmarks
#  s    -- save bashmarks as $1
#  g    -- goto bashmark $1
#  p    -- print bashmark $1
#  d    -- delete bashmark $1
source "${__DOTFILES}/etc/bashmarks/bashmarks.sh"
#  lsbashmarks -- list Bashmarks (e.g. for NERDTree)
lsbashmarks () {
    export | grep 'DIR_' | pyline "line[15:].replace('\"','').split('=',1)"
}

# ~/.dotfiles/bin/nerdtree_to_bashmarks.py


