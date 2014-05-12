
print_dotvim_comments() {
    echo "\n::\n" > docs/dotvim_conf.rst
    cat etc/vim/vimrc etc/vim/vimrc.bundles \
        | pyline -r '^\s*"\s(\s*.*)' 'rgx and "   " + rgx.group(1)'
}

print_dotvim_comments
