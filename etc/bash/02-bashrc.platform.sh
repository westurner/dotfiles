
### bashrc.platform.sh

detect_platform() {
    #  detect_platform()    -- set __IS_MAC, __IS_LINUX according to $(uname)
    UNAME=$(uname)
    if [ ${UNAME} == "Darwin" ]; then
        export __IS_MAC='true'
    elif [ ${UNAME} == "Linux" ]; then
        export __IS_LINUX='true'
    fi
}


