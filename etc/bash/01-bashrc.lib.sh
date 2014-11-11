
### bashrc.lib.sh


## bash

#__THIS=$(readlink -e "$0")
#__THISDIR=$(dirname "${__THIS}")

echo_args() {
    #  echo_args    -- echo $@ (for checking quoting)
    echo $@
}

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


lightpath() {
    #  lightpath()  -- display $PATH with newlines
    echo ''
    echo $PATH | tr ':' '\n'
}

lspath() {
    #  lspath()     -- list files in each directory in $PATH
    echo "# PATH=$PATH"
    lightpath | sed 's/\(.*\)/# \1/g'
    echo '#'
    cmd=${1:-'ls -ald'}
    for f in $(lightpath); do
        echo "# $f";
        ${cmd} $f/*;
        echo '#'
    done
}

lspath-less() {
    #  lspath_less()    -- lspath with less (color)
    if [ -n "${__IS_MAC}" ]; then
        cmd=${1:-'ls -ald -G'}
    else
        cmd=${1:-'ls -ald --color=always'}
    fi
    lspath "${cmd}" | less -R
}

## file paths

realpath () {
    #  realpath()    -- print absolute path (os.path.realpath) to path $1
    #                  note: OSX does not have readlink -f
    python -c "import os,sys; print(os.path.realpath(os.path.expanduser(sys.argv[1])))" "${1}"
    return
}
path () {
    #  path()        -- realpath()
    realpath ${1}
}


walkpath () {
    #  walkpath()    -- walk down a path
    #   $1 : path (optional; default: pwd)
    #   $2 : cmd  (optional; default: ls -ald --color=auto)
    #   see: http://superuser.com/a/65076 
    dir=${1:-$(pwd)}
    if [ -n "${__IS_MAC}" ]; then
        cmd=${2:-"ls -ldaG"}
    else
        cmd=${2:-"ls -lda --color=auto"}
    fi
    dir=$(realpath ${dir})
    parts=$(echo ${dir} \
        | awk 'BEGIN{FS="/"}{for (i=1; i < NF+2; i++) print $i}')
    paths=('/')
    unset path
    for part in $parts; do
        path="$path/$part"
        paths=("${paths[@]}" $path)
    done
    ${cmd} ${paths[@]}
}


ensure_symlink() {
    #  ensure_symlink   -- create or update a symlink to $_to from _from
    #    ln -s $_to $_from
    _from=$1
    _to=$2
    _date=${3:-$(date +%FT%T%z)}  #  ISO8601 w/ tz
    # if symlink $_from already exists
    if [ -s $_from ]; then
        # compare the actual paths
        _to_path=(realpath $_to)
        _from_path=(realpath $_from)
        if [ $_to_path == $_from_path ]; then
            printf "%s already points to %s" "$_from" "$_to"
        else
            printf "%s points to %s" "$_from" "$_to"
            mv -v ${_from} "${_from}.bkp.${_date}"
            ln -v -s ${_to} ${_from}
        fi
    else
        # if a file or folder exists return an errorcode
        if [ -e ${_from} ]; then
            printf "%s exists" "${_from}"
            mv -v ${_from} "${_from}.bkp.${_date}"
            ln -v -s ${_to} ${_from}
        else
            # otherwise, create the symlink
            ln -v -s $_to $_from
        fi
    fi
}

ensure_mkdir() {
    #  ensure_mkdir -- create a directory if it does not yet exist
    prefix=$1
    test -d ${prefix} || mkdir -p ${prefix}
}
