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
    echo 'Subresource Integrity (SRI) References:'
    echo '- https://www.w3.org/TR/SRI/'
    echo '- https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity'
}


main() {
    for arg in "${@}"; do
      case "${arg}" in
        -h|--help)
          print_usage;
          exit
      esac
    done
    sri_encode
}

main "${@}"
