#!/usr/bin/env bash

# Screensaver.sh

_install_xlck () {
    sudo apt-get install xautolock xlockmore
    ln -s ~/.dotfiles/etc/.xinitrc ~/.xinitrc
}

_xlck_setup () {
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

_xlck_i3lock () {
    /usr/bin/i3lock -d -c 202020
}

_xlck_xlock () {
    /usr/bin/xlock -mode blank -bg black -fg white -lockdelay 3
}

_xlck_xautolock () {
    _LOCK_BIN="/usr/bin/xlock"
    _LOCK_DELAY="1"  # mins
    _LOCK_CMD="$_LOCK_BIN -mode blank -bg black -fg white -lockdelay 3"
    NOTIFY_CMD='/usr/bin/zenity --warning \
        --title "Screensaver starts in 10s" \
        --text "OK to cancel\n\nNOTE: Mouse Corners:\n⬉ to prevent\n⬋ to start"\
        --timeout=10'
    /usr/bin/xautolock \
        -secure \
        -detectsleep \
        -time $_LOCK_DELAY \
        -notify 10 \
        -notifier "$NOTIFY_CMD" \
        -corners -0+0 \
        -cornerdelay 10 \
        -cornerredelay 10 \
        -locker "$_LOCK_CMD"
}



_suspend_to_ram () {
    sudo bash -c 'echo mem > /sys/power/state'
}

_suspend_to_disk () {
    # NOTE: error prone
    sudo bash -c 'echo disk > /sys/power/state'
}

_lock_suspend_ram () {
    sudo bash -c 'whoami'
    _i3lock && _suspend_to_ram
}

_lock_suspend_disk () {
    sudo bash -c 'whoami'
    _i3lock && _suspend_to_disk
}

xlck_suspend () {
    _lock_suspend_ram
}


xlck_lock () {
    _xlock
}

xlck_start() {
    if [ -n "$DISPLAY" ]; then
        _xlck_setup
        _xlck_xautolock &
    fi
}

xlck_stop() {
    #pkill -9 xlck.sh
    pkill -9 -u $USER xlock
    pkill -9 -u $USER -f /usr/bin/xautolock
}


xlck_restart() {
    xautolock -restart
    #xlck_stop
    #xlck_start
}

xlck_status() {
    #TODO
    ps ufx | egrep 'xlock|xautolock' -C 7
    ps -ufx -p $(ps eww | grep " DISPLAY=$DISPLAY" | pycut -f0)
}


xlck_status_this_display(){
    pids=$(ps eww | grep " DISPLAY=$DISPLAY" | awk '{ print $1 }')
    for p in $pids; do
        ps fx $p
    done
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
    exit 1;
}

xlck_main () {
    while getopts "SPRMDLX" o; do
        case "${o}" in
            S)
                s=${OPTARG};
                xlck_start;
                ;;
            P)
                k=${OPTARG};
                xlck_stop;
                ;;
            R)
                r=${OPTARG};
                xlck_restart;
                ;;
            M)
                _lock_suspend_ram;
                ;;
            D)
                d=${OPTARG};
                _lock_suspend_disk;
                ;;
            L)
                l=${OPTARG};
                xlck_lock;
                ;;
            X)
                x=${OPTARG};
                sudo shutdown -h now;
                ;;
            *)
                xlck_usage
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


