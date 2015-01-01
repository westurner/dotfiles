#!/bin/bash -i

RETURN_TRUE=0
RETURN_FALSE=1
RETURN_ERR=2

cleanup() {
    declare -f 'deactivate' 2>&1 > /dev/null && (deactivate || source deactivate) || return 0
}

tearDown() {
    cleanup
}


assertEqual() {
   if [ "$1" != "$2" ]; then
       echo "$3: $1 != $2";
       retval=$RETURN_FALSE
   else
       retval=$RETURN_TRUE
   fi
   return $retval
   #exit $retval
}

setUp() {
    export __DOTFIlES="${HOME}/-dotfiles"
    bashrc="${__DOTFILES}/etc/.bashrc"
    if [ ! -f "$bashrc" ]; then
        echo "err: .bashrc not found: $bashrc"
        exit 1
    fi
    source "$bashrc"

    export VENVSTR="testenv"
}



test_dotfiles_status() {
    dotfiles_status
    ds
    cdd
}
test_mkvirtualenv() {
    VENVSTR="testenv"
    mkvirtualenv $VENVSTR
    workon $VENVSTR
    assertEqual "$VIRTUAL_ENV" "${WORKON_HOME}/${VENVSTR}"
    ds
    cdv
    assertEqual "$PWD" "$VIRTUAL_ENV" "PWD"
    deactivate
    assertEqual "$VIRTUAL_ENV" "" "VIRTUAL_ENV"

    we $VENVSTR
    assertEqual "$_WRD" "${WORKON_HOME}/${VENVSTR}" "_WRD"
    ds
    cdw
    assertEqual "$PWD" "$_WRD" "PWD"
    rmvirtualenv $VENVSTR
}
test_mkvirtualenv_conda() {
    VENVSTR="testenv"
    mkvirtualenv_conda $VENVSTR
    wec $VENVSTR
    assertEqual "$_WRD" "${WORKON_HOME}/${VENVSTR}" "_WRD"
    ds
    conda list
    [ -f "$_WRD" ] || echo "$_WRD is not set" && return 1
    cdw
    assertEqual "$PWD" "$_WRD" "PWD"
    rmvirtualenv_conda $VENVSTR
}
test_workon_VENVSTR() {
    VENVSTR="testenv"
    mkvirtualenv $VENVSTR
    we $VENVSTR
    assertEqual "$_WRD" "${WORKON_HOME}/${VENVSTR}" "_WRD"
    ds
    pip list
    cdw
    assertEqual "$PWD" "$_WRD" "PWD"
    rmvirtualenv $VENVSTR
}

testfunc_() {
    echo $1
    $1
}

run_tests() {
    setUp
    set -E 

    $testfunc_ test_dotfiles_status

    $testfunc_ test_mkvirtualenv

    $testfunc_ test_mkvirtualenv_conda

    $testfunc_ test_workon_VENVSTR
}

main() {
    setUp
    run_tests
    tearDown
}
main
