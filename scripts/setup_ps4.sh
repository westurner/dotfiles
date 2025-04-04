#export PS4='#+\e[0;30m${BASH_SOURCE:+${BASH_SOURCE##*/}}:${LINENO}\e[m$'\t' \e[0;32m${FUNCNAME[0]:+"${FUNCNAME[0]}():"}\e[m  \n+';
export PS4='\e[0;30m#'$'\t''${BASH_SOURCE:+${BASH_SOURCE##*/}}:${LINENO}$'\t' ${FUNCNAME[0]:+"${FUNCNAME[0]}():"}\e[m  \n+';
