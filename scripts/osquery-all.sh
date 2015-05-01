#!/bin/sh -x
## 
osq="./osquery"
formats='html csv json'
tables=$(osqueryi --json '.schema' | pyline 'l and l.split("CREATE VIRTUAL TABLE")[-1].split(" USING ")[0]')


set_facls() {
    umask 027
    mkdir -p ${osq}
}

write_indexhtml() {
    set_facls
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

do_osquery_all() {
    set_facls
    osq=${osq}
    formats=${formats}
    tables=${tables}

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

main() {
    write_indexhtml
    do_osquery_all
}


if [[ "$BASH_SOURCE" == "$0" ]]; then
    main $@
fi
