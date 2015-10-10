#!/bin/sh -x

### whyquote.sh
# why shell quoting matters

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
