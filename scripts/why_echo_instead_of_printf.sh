#!/bin/sh
cat << EOF
# why_echo_instead_of_printf.sh
Because 'printf' and 'echo -e' print chars like \n and \r literally
but 'echo' does not.

Both 'printf' and 'echo' are both shell builtins and also bins';

    $ type -a echo
    echo is a shell builtin
    echo is /usr/sbin/echo
    echo is /usr/bin/echo

    $ type -a printf
    printf is a shell builtin
    printf is /usr/sbin/printf
    printf is /usr/bin/printf

In the following shell commands,
Watch for whether the *newline* shell control characters print or dont.

Notice how it's easy to lose track of
whether a variable specified elsewhere in the code contains shell control characters.

First without a string variable containing shell control characters, and then with:

EOF

# NOTE: Here we create a closure with a shell subcommand `( )`
#  such that the commands within the parentheses run
#  with `set -x -v` to print commands with a '+ ' line prefix as they run,
#  but the `set -x -v` state does not leak into the calling context;)
# For example, note the absence of the letters x and v in the output
# from the final echo $-; here:
#
# (echo $-; (set -x -v; echo $-); echo $-;)

(set -x -v;

printf '1\n\n'
echo -e '1\n\n'
echo '1\n\n'

x='1\n\n'; printf "$x"
x='1\n\n'; echo -e "$x"
x='1\n\n'; echo "$x"

)
