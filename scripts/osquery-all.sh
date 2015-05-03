#!/bin/sh -x
## osquery-all.sh - SELECT * FROM osquery.* > ./static/html/index.html + {...}
#
# Generate CSV, JSON, and HTML from all rows and columns of each table
#
# Requires:
#   pip install pyline

function osquery_init() {
    osq="${1:-"./osquery"}"
    formats='html csv json'
    tables=$(osqueryi --json '.schema' | pyline \
            'l and l.split("CREATE VIRTUAL TABLE")[-1].split(" USING ")[0]')
}

function osquery_set_facls() {
    umask 027
    mkdir -p ${osq}
}

function osquery_write_indexhtml() {
    osquery_set_facls
    osq=${osq}
    formats=${formats}
    tables=${tables}
    indexhtml=${osq}/index.html
    echo '<!DOCTYPE html>' > ${indexhtml}
    echo "<html><head><title>osquery index</title>" >> ${indexhtml}
    echo '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">' >> ${indexhtml}
    echo '<style>span.em { font-weight: bold; }</style>' >> ${indexhtml}
    echo '</head><body><div class="container">' >> ${indexhtml}
    echo "<h1>" >> ${indexhtml}
    echo "<a href=\"./\">osquery/</a>" >> ${indexhtml}
    echo "</h1>" >> ${indexhtml}
    echo "<span class=\"em\">Hostname: </span><span>$(hostname -f)</span>" >> ${indexhtml}
    echo "<span class=\"em\">Date: </span><span>$(date +'%FT%T%z')</span>" >> ${indexhtml}
    echo "<ul>" >> ${indexhtml}
    for tbl in ${tables}; do
        echo "<li>" >> ${indexhtml}
        echo "<span><a href=\"${tbl}.html\">${tbl}</a></span>" >> ${indexhtml}
        echo "(<span><a href=\"${tbl}.csv\">CSV</a></span>," >> ${indexhtml}
        echo "<span><a href=\"${tbl}.json\">JSON</a></span>)" >> ${indexhtml}
        echo "</li>" >> ${indexhtml}
    done
    echo "</ul>"
    echo "</div></body></html>" >> ${indexhtml}
}

function osquery_all() {
    osquery_set_facls
    # osquery_init
    osq=${1:-${osq}}
    formats=${formats}
    tables=${tables}

    osquery_write_indexhtml

    for tbl in ${tables}; do
        for fmt in "csv" "json"; do 
            osqueryi --header --${fmt} "SELECT * FROM ${tbl};" > ${osq}/${tbl}.${fmt}
        done
        fmt='html'
        echo '<!DOCTYPE html>' > ${osq}/${tbl}.${fmt}
        echo "<html><head><title>osquery/${tbl}</title>" >> ${osq}/${tbl}.${fmt}
        echo '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" />' >> ${osq}/${tbl}.${fmt}
        echo '<style>span.em { font-weight: bold; }</style>' >> ${osq}/${tbl}.${fmt}
        echo "</head><body><div class=\"container\">" >> ${osq}/${tbl}.${fmt}
        echo "<h1>" >> ${osq}/${tbl}.${fmt}
        echo "<a href=\"./\">osquery/</a>" >> ${osq}/${tbl}.${fmt}
        echo "<a href=\"${tbl}.${fmt}\">${tbl}</a>" >> ${osq}/${tbl}.${fmt}
        echo "</h1>" >> ${osq}/${tbl}.${fmt}
        echo "<span class=\"em\">Hostname: </span><span>$(hostname -f)</span>" >> ${osq}/${tbl}.${fmt}
        echo "<span class=\"em\">Date: </span><span>$(date +'%FT%T%z')</span>" >> ${osq}/${tbl}.${fmt}
        echo '<div class="table-responsive">' >> ${osq}/${tbl}.${fmt}
        echo "<table class=\"table table-striped table-hover table-condensed\" about=\"${tbl}\">" >> ${osq}/${tbl}.${fmt}
        osqueryi --header --${fmt} "SELECT * FROM ${tbl};" >> ${osq}/${tbl}.${fmt}
        echo "</table></div></body></html>" >> ${osq}/${tbl}.${fmt}
    done
}

function osquery_all_help() {
    echo "Usage: ${0} [<destdir=./osquery>]"
    echo
    echo "Description: SELECT * FROM osquery.* > destdir/{CSV, JSON, HTML}"
    echo 
}


function osquery_all_main() {
    while getopts "d:DsP:h" opt; do
        case "${opt}" in
            d)
                osqa_opts_destdir="${OPTARG}";
                ;;
            D)
                osqa_opts_dated=true;
                ;;
            s)
                osqa_opts_serve=true;
                ;;
            P)
                osqa_opts_port=${OPTARG}
                ;;
            h)
                osqa_opts_help=true;
                ;;
        esac
    done
    test -n "${osqa_opts_help}" && osquery_all_help && return 0

    destroot=${osqa_opts_destdir:-"./osquery"}
    destdir="${destroot}"
    if [ -n "${osqa_opts_dated}" ]; then
        datetime=$(date +'%FT%T%z')
        destdir="${destroot}/${datetime}"
    fi
    osquery_init ${destdir}
    # osquery_all ${destdir}
    if [ -z $? ]; then
        if [ -n "${osqa_opts_dated}" ]; then
            cursymlink="${destroot}/latest"
            if [ -e "${cursymlink}" ]; then
                rm "${cursymlink}"
            fi
            (cd "${destroot}"; \
                rm ./latest || true; \
                ln -s "./${datetime}" ./latest)
        fi
    fi

    if [ -n "${osqa_opts_serve}" ]; then
        port=${osqa_opts_port:-"8089"}
        pgs -p ${destroot} -P ${port}
    fi
    return $?
}

if [ "$BASH_SOURCE" == "$0" ]; then
    osquery_all_main ${@}
    exit
fi
