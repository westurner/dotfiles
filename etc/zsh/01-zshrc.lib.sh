
funcdir=${__DOTFILES}/etc/zsh/functions/

source $funcdir/bash_source.sh

#source $funcdir/lesspipe.sh

# list all path key components leading to file
lspath () {
        if [ "$1" = "${1##/}" ]
        then
	    pathlist=(/ ${(s:/:)PWD} ${(s:/:)1})
	else
	    pathlist=(/ ${(s:/:)1})
	fi
        allpaths=()
        filepath=$pathlist[0]
        shift pathlist
        for i in $pathlist[@]
        do
                allpaths=($allpaths[@] $filepath)
                filepath="${filepath%/}/$i"
        done
        allpaths=($allpaths[@] $filepath)
        ls -ldZ "$allpaths[@]"
        if [ -n "$2" ]; then
            getfacl "$allpaths[@]"
        fi
}
