
### bashrc.lib.sh

function_exists() {
    #  function_exists()    -- check whether a bash function exists
    declare -f $1 > /dev/null
    return $?
}

add_to_path ()
{
    #  add_to_path  -- prepend a directory to $PATH
    ##http://superuser.com/questions/ \
    ##\ 39751/add-directory-to-path-if-its-not-already-there/39840#39840

    ## instead of:
    ##   export PATH=$dir:$PATH
    ##
    ##   add_to_path $dir 

    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        return 0
    fi
    export PATH=$1:$PATH
}

detect_platform() {
    #  detect_platform()    -- set __IS_MAC, __IS_LINUX according to $(uname)
    UNAME=$(uname)
    if [ ${UNAME} == "Darwin" ]; then
        export __IS_MAC='true'
    elif [ ${UNAME} == "Linux" ]; then
        export __IS_LINUX='true'
    fi
}

