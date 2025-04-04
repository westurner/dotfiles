#!/bin/sh -x

### whyquote.sh
# why shell quoting matters

# %%
function example {
    echo ""
    echo "###: $@"
}

a="; echo '!$!'"

example 1
echo $a
echo ${a}
echo "$a"
echo "${a}"

# %%
example one
echo "one" $a
echo "one" ${a}
echo "one" "$a"
echo "one" "${a}"

# ..
example echo_one
cmd="echo 'one'; ${a}"
echo ${cmd}
echo "${cmd}"
${cmd}
"${cmd}"

example 10
example10=$(pwd)
echo $example10
echo "$example10"

example 11
example11="$(pwd)"
echo $example11
echo "$example11"

example 20
example20="-e \nthis"
echo $example20
echo "$example20"

example 21
example21="-e \n#this"
echo $example21
echo "$example21"


# %%

###

function example22 {
    # $1: arg1
    # $2: arg1
    echo $@ ".A"
    echo "$@" ".B"
}

echo "22"
example22 $@
echo "23"
example22 "$@"


# %%

function example24 {
    # $1: arg1
    # $2: arg1
    exec echo $@ ".A"
    exec echo "$@" ".B"
}

echo "24"
example24 $@
echo "25"
example24 "$@"

echo "26"
example24 "./path to the file.txt"

# %%
function whyquote__why_echo_or_printf {  # TODO: run this fn
    printf "123\n"
    echo "123"
    printf "1234 %s \n" "hello world" 
    echo "1234 %s"
}

# %%
function whyquote__varname_q_errmsg {
    ## ${varname?errmsg}
    (export a='here'; echo "${a?erroring because a in unset}")
    (a='here' echo "${a?erroring because a in unset}")
}
whyquote__varname_q_errmsg


# %%
function whyquote__echo_newlines_example1 {
    ## with echo and newlines, again
    cmdopts="'\n\n'";    outputcmd="echo $cmdopts"; echo "${outputcmd}"; (set -x; $outputcmd)
    cmdopts="-e '\n\n'"; outputcmd="echo $cmdopts"; echo "${outputcmd}"; (set -x; $outputcmd)
    cmdopts="-e '\n\n'"; outputcmd="echo \"$cmdopts\""; echo "${outputcmd}"; (set -x; $outputcmd)
}
whyquote__echo_newlines_example1
