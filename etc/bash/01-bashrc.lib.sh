 
function_exists() {
    declare -f $1 > /dev/null
    return $?
}

add_to_path ()
{
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
    echo $PATH | sed 's/\:/\n/g'
}

lspath() {
    #  lspath       -- list files in each directory in $PATH
    echo "PATH=$PATH"
    lightpath
    for f in $(lightpath); do
        echo "# $f";
        ls -aldZ $@ $f/*;
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

