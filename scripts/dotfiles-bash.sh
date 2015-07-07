#!/bin/bash
### dotfiles-bash.sh -- dotfiles_grep_shell_comments $@

dotfiles_grep_shell_comments() {
    ## dotfiles_grep_shell_comments()    -- print indented block (w/ an rst header)
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
    local paths=${@:-"etc/bash/*.sh"}
    local prefix=${__DOTFILES}
    (cd $prefix;
        for f in $(ls $paths); do
            echo "#### $f";
            cat $f | scripts/pyline.py -r '^\s*#+\s+.*' 'rgx and l';
            echo "   ";
            echo "   ";
        done
    )
}


if [[ ${BASH_SOURCE} == "${0}" ]]; then
    dotfiles_grep_shell_comments ${@}
    exit
fi
