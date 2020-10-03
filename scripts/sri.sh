#!/bin/sh

# SRI encode a binary checksum
#
# References:
# - https://blog.starryvoid.com/archives/334.html

sri_encode() {
    awk '{ print $1 }' | xxd -r -p | base64
}

print_usage() {
    echo "${0} [-h]"
    echo 'Usage:'
    echo '  $ sha384sum -b ./bootstrap.min.css | sri.sh'
    echo ''
    echo '  $ sri.sh --css bootstrap.min.js'
    echo '  $ SRIURLPATH="./static/js" sri.sh --css bootstrap.min.js'
    echo ''
    echo ''
    echo 'Subresource Integrity (SRI) References:'
    echo '- https://www.w3.org/TR/SRI/'
    echo '- https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity'
}

print_css_tag() {
    f=$1
    path=${SRIURLPATH}
    echo "<link rel=\"stylesheet\" src=\"${SRIURLPATH}/${f}\" integrity=\"sha384-$(sha384sum "${f}" | sri_encode )\" crossorigin=\"anonymous\">"
}

print_js_tag() {
    f=$1
    path=${SRIURLPATH}
    echo "<script src=\"${SRIURLPATH}/${f}\" integrity=\"sha384-$(sha384sum "${f}" | sri_encode )\" crossorigin=\"anonymous\"></script>"
}


main() {
    for arg in "${@}"; do
      case "${arg}" in
        -h|--help)
          print_usage;
          exit
          ;;
        --css)
          shift;
          print_css_tag "${1}"
          shift
          exit
          ;;
        --js)
          shift;
          print_js_tag "${1}"
          shift
          exit
          ;;
      esac
    done
    sri_encode
}

main "${@}"
