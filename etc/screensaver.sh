_setup_screensaver () {
    xset +dpms
    xset dpms 600
    xset s blank
    xset s expose
    xset s 300
    #xset s on
    #xset s activate
}
_setup_screensaver

_i3lock () {
    /usr/bin/i3lock -d -c 202020
}

_xlock () {
    /usr/bin/xlock -mode blank -bg black -fg white -lockdelay 3
}

_xautolock () {
    _LOCK_BIN="/usr/bin/xlock"
    _LOCK_DELAY="1"  # mins
    if [ $DESKTOP_SESSION == "i3" ] && [ -x "/usr/bin/i3lock" ]; then
      _LOCK_CMD="/usr/bin/i3lock -d -c 202020"
    else
       if [ ! -x $_LOCK_BIN ]; then
           echo "NOT FOUND: $_LOCK_BIN" >&2
       fi
      _LOCK_CMD="$_LOCK_BIN -mode blank -bg black -fg white -lockdelay 3"
    fi
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

lock () {
    if [ $DESKTOP_SESSION == "i3" ]; then
        _i3lock
    else
        _xlock
    fi
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
    lock && _suspend_to_ram
}

_lock_suspend_disk () {
    sudo bash -c 'whoami'
    lock && _suspend_to_disk
}

suspend () {
    _lock_suspend_ram
}
