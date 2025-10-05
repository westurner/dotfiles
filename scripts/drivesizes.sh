#!/bin/sh
drivesizes() {
set -x -e
drivesize="${1:-1T}";
drivesize_iec="$(numfmt --from=iec "$drivesize")"
drivesize_si="$(numfmt --from=si "${drivesize}")"
difference_between_si_and_iec_bytes=$(expr "$drivesize_iec" - "${drivesize_si}")
difference_between_si_and_iec_bytes_si_units=$(numfmt --to si ${difference_between_si_and_iec_bytes})
}

drivesizes "$1"
