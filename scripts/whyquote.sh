#!/bin/sh -x


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
