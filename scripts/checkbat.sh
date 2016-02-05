#!/bin/sh -x
## 

export horiz_barchart_syms=(█▉▊▋▌▍▎▏∅)

function get_unicode_barchart_char() {
   local n=$1
   # local max=100  # TODO: ${2:-100}
   # echo "dbg: batsyms: ${horiz_barchart_syms}"
   #local n_rescaled=$(( n*10 / 120 ))
   local n_rescaled=$(echo "(${n} / 12.5)" | bc)  # 100/8 = 12.5
   echo "${horiz_barchart_syms[$n_rescaled]}"
}


function _checkbat {
    local bat=${1:-"BAT0"}
    local batthreshold=${2:-"20"}
    local status="$(cat /sys/class/power_supply/${bat}/status)"
    local batpercent=$(acpi -b | awk '{ print $4 }' | sed 's/[%,]//g')

    local statecode=""
    case $status in
        Charging)
            statecode="CHR"
            ;;
        Full)
            statcode="FUL"
            ;;
        Discharging)
            statecode="BAT"
            ;;
    esac

    echo "${batpercent}" "${status}" "${statecode}"
    get_unicode_barchart_char ${batpercent}

    if [[ "${status}" != "Charging" ]]; then
        if [[ "$batpercent" -ge "100" ]]; then
            i3-nagbar -m "Homeostasis complete: ${batpercent} % (< ${batthreshold}%)" &
            # TODO: lock / throttling
        elif [[ "$batpercent" -le "$batthreshold" ]]; then
            echo "below test level"
            i3-nagbar -m "Homeostasis status: battery needs to be charged because: (${batpercent}% < ${batthreshold}%)" &
            # TODO: lock / throttling
        fi
    fi
}


if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    _checkbat ${@}
fi
