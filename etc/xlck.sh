#!/usr/bin/env bash

# xlck.sh

export XAUTOLOCK_PID="~/.xautolock.${DISPLAY}.pid"

xlck() {
    _XLCK=$(readlink -e "$BASH_SOURCE")
    echo $_XLCK
    bash $_XLCK $@
}

_xlck_install () {
    sudo apt-get install xautolock xlockmore
    ln -s ~/.dotfiles/etc/.xinitrc ~/.xinitrc
}

_xlck_setup () {
    export _XLCK=$(readlink -e "$BASH_SOURCE")

    #XSET=$(type 'xset' 2>/dev/null)
    if [ -n "$DISPLAY" ]; then
        xset +dpms
        xset dpms 600
        xset s blank
        xset s expose
        xset s 300
        #xset s on
        #xset s activate
    fi
}

_xlck_xlock () {
    /usr/bin/xlock -mode blank -bg black -fg white -lockdelay 3
}

_xlck_i3lock () {
    /usr/bin/i3lock -d -c 202020
}

xlck_lock () {
    # lock the current display
    # note: this will be run before suspend to RAM and Disk.
    _xlck_i3lock
}

_suspend_to_ram () {
    sudo bash -c 'echo mem > /sys/power/state'
}

_suspend_to_disk () {
    # NOTE: error prone
    sudo bash -c 'echo disk > /sys/power/state'
}

xlck_lock_suspend_ram () {
    sudo bash -c 'whoami'
    xlck_lock && _suspend_to_ram
}

xlck_lock_suspend_disk () {
    sudo bash -c 'whoami'
    xlck_lock && _suspend_to_disk
}

xlck_suspend_ram () {
    xlck_lock_suspend_ram
}

xlck_suspend_disk () {
    xlck_lock_suspend_disk
}

xlck_start() {
    echo "Starting xlck ..."
    if [ -n "$DISPLAY" ]; then
        _xlck_setup
        _xlck_xautolock & disown
        echo "Started xlck ..."
        sleep 1
        xlck_status
    fi
}

xlck_stop() {
    echo "Stopping xlck ..."
    xlck_xautolock_stop
    echo "xlck stopped"
}

xlck_restart() {
    # xautolock -restart  # does not work with xautolock -secure
    xlck_stop
    xlck_start
}

xlck_pgrep_autolock_this_display() {
    pids=$(pgrep xautolock)
    if [ -n "$pids" ]; then
        ps eww -p ${pids} \
        | grep " DISPLAY=$DISPLAY" \
        | awk '{ print $1 }'
    fi
}

xlck_xautolock_status() {
    echo "Checking autolock status where DISPLAY=$DISPLAY"
    _xautolock_actual_pids=$(xlck_pgrep_autolock_this_display)
    if [ -n "$_xautolock_actual_pids" ]; then
        ps ufw -p $_xautolock_actual_pids
    else
        echo "no autolock processes found on this \$DISPLAY"
    fi
}

xlck_xautolock_stop() {
    echo "Stopping xautolock where DISPLAY=$DISPLAY ..."
    _xautolock_actual_pids=$(xlck_pgrep_autolock_this_display)
    if [ -n "$_xautolock_actual_pids" ]; then
        kill -9 $_xautolock_actual_pids
        echo "Stopped xautolock"
    else
        echo "xautolock not running"
    fi
    xlck_xautolock_status
}

xlck_status() {
    echo "Checking xlck status..."

    xlck_xautolock_status

}

xlck_status_all() {
    _xlck_pgrep="pgrep 'xautolock|xlock|i3lock'"
    _xlck_pids=$(pgrep 'xautolock|xlock|i3lock')
    if [ -n "$_xlck_pids" ]; then
        echo "_xlck_pids=${_xlck_pids}"
        ps ufw -p $_xlck_pids
    else
        echo "\"${_xlck_pgrep}\" did not find any process ids" 
    fi
}

xlck_status_this_display(){
    display=${1:-$DISPLAY}
    ps ufx -p
    _pids=$(ps eww | grep "DISPLAY=$display" | pyline 'w[0]')
}

_xlck_xautolock () {
    _LOCK_DELAY=${1:-"1"}  # mins
    _NOTIFY_DELAY=${2:-"10"}  # seconds
    _LOCK_CMD="/bin/bash $_XLCK -L"
    NOTIFY_CMD="/usr/bin/zenity --warning \
        --title '${_NOTIFY_DELAY}s to screensaver' \
        --text 'OK to cancel\n\nNOTE: Mouse Corners:\n⬉ to prevent\n⬋ to start'\
        --timeout=${_NOTIFY_DELAY}"
    /usr/bin/xautolock \
        -secure \
        -detectsleep \
        -time $_LOCK_DELAY \
        -notify ${_NOTIFY_DELAY} \
        -notifier "$NOTIFY_CMD" \
        -corners -0+0 \
        -cornerdelay ${_NOTIFY_DELAY} \
        -cornerredelay ${_NOTIFY_DELAY} \
        -locker "$_LOCK_CMD" \
        -nowlocker "$_LOCK_CMD"
}

xlck_usage() {
    echo ""
    echo "xlck -- a shell wrapper for xlock, i3lock, and xautolock"

    echo "Usage: $0 <-U|-S|-P|-R|-M|-N|-D|-L|-X>]";
    echo "#  -U   --  xlck status"
    echo "#  -S   --  start xlck"
    echo "#  -P   --  stop xlck"
    echo "#  -R   --  restart xlck"
    echo "#  -M   --  suspend to ram (and lock)"
    echo "#  -D   --  suspend to disk (and lock)"
    echo "#  -L   --  lock"
    echo "#  -X   --  halt"
    echo "#  -h   --  help"
}

xlck_main () {
    while getopts "USPRMDLXh" opt; do
        case "${opt}" in
            U)
                xlck_status;
                ;;
            S)
                xlck_start;
                ;;
            P)
                xlck_stop;
                ;;
            R)
                xlck_restart;
                ;;
            M)
                _lock_suspend_ram;
                ;;
            D)
                _lock_suspend_disk;
                ;;
            L)
                xlck_lock;
                ;;
            X)
                sudo shutdown -h now;
                ;;
            *|h)
                xlck_usage;
                ;;
        esac
    done
}

if [[ "$BASH_SOURCE" == "$0" ]]; then
  _xlck_setup
  xlck_main $@
fi

# TODO:
# -notifier -> logger -> syslog


