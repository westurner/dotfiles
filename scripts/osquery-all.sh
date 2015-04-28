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
    echo "<html><head><title>osquery index</title></head><body>" > ${indexhtml}
    echo "<ul>" >> ${indexhtml}
    for tbl in ${tables}; do
        echo "<li>" >> ${indexhtml}
        echo "<ul style=\"list-style-type:none\">" >> ${indexhtml}
        for fmt in ${formats}; do 
            echo "<li style=\"display:inline\"><a href=\"${tbl}.${fmt}\">${tbl}.${fmt}</a></li>" >> ${indexhtml}
        done
        echo "</ul>" >> ${indexhtml}
        echo "</li>" >> ${indexhtml}
    done
    echo "</ul>"
    echo "</body></html>" >> ${indexhtml}
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
        echo "<html><head><title>osquery/${tbl}</title></head><body><h1>osquery/${tbl}</h1><table about=\"${tbl}\">" > ${osq}/${tbl}.${fmt}
        osqueryi --header --${fmt} "SELECT * FROM ${tbl};" >> ${osq}/${tbl}.${fmt}
        echo "</table></body></html>" >> ${osq}/${tbl}.${fmt}
    done
}

main() {
    write_indexhtml
    do_osquery_all
}


if [[ "$BASH_SOURCE" == "$0" ]]; then
    main $@
fi
