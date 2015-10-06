#!/bin/sh -x

### whyquote.sh
# why shell quoting matters

a="; echo '!$!'"


echo $a
echo ${a}
echo "$a"
echo "${a}"


echo "one" $a
echo "one" ${a}
echo "one" "$a"
echo "one" "${a}"

# ..

cmd="echo 'one'; ${a}"
echo ${cmd}
echo "${cmd}"
${cmd}
"${cmd}"


example2=$(pwd)
echo $example2
echo "$example2"


example3="$(pwd)"
echo $example3
echo "$example3"


example3="-e \nthis"
echo $example3
echo "$example3"
