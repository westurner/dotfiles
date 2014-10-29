#!/bin/bash

print_bash_comments() {
    ## print_bash_comments()    -- print indented block (w/ an rst header)
    # examples:
    # ## comment    -- description
    # # cmd     -- description
    #      # xy -- description
    # #           (more description)
    #
    # regex:
    # \s*   # 0 or more initial spaces
    # #+    # 1 or more comment characters
    # \s    # 1 space
    # (     # rgx.group(1)
    #  \s*  # 0 or more initial spaces
    #  .*   # 0 or more additional characters
    # )
    #
    # output:
    # 
    # "   ## %s".format(filename)
    # "    %s".format(line)
    (cd $__DOTFILES;
    for f in $(ls etc/bash/*.sh); do
        echo "#### $f";
        cat $f | scripts/pyline.py -r '^\s*#+\s+.*' 'rgx and l';
        echo "   ";
        echo "   ";
    done)
}

print_bash_comments
