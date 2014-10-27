 
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

detect_platform() {
    if [ -d /Library ]; then
        export __IS_MAC='true'
    else
        export __IS_LINUX='true'
    fi
}

