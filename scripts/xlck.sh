#!/usr/bin/env bash

### xlck.sh -- script wrapper for xautolock, xlock, and/or i3lock
##             as well as issuing suspend, shutdown, and restart commands


function xlck {
    # xlck()            -- xlck $@
    _XLCK=$(readlink -e "$BASH_SOURCE")
    echo "# ${_XLCK}"
    bash $_XLCK $@
}

function _xlck_install  {
    # _xlck_install()   -- install xlck dependencies
    # xlck requires: bash, pgrep, ps, kill, xautolock, xlock, i3lock, xset

    function _xlck_install_apt {
        sudo apt-get install -y bash procps x11-server-utils \
            xautolock xlockmore i3lock
    }
    function _xlck_install_yum {
        local YUM="${1:-"yum"}"  # yum, dnf
        sudo $YUM install -y bash procps-ng xorg-x11-server-utils \
            xautolock xlockmore i3lock
    }

    _xlck_install_apt
    _xlck_install_yum
    _xlck_install_yum "dnf"

    ln -s ~/.dotfiles/etc/.xinitrc ~/.xinitrc
}

function _xlck_setup_dpms {
    # _xlck_setup_dpms() -- configure display with xset and dpms
    xset +dpms
    xset dpms 600
    xset s blank
    xset s expose
    xset s 300
    #xset s on
    #xset s activate
}

function _xlck_setup  {
    # _xlck_setup()     -- setup xlck (export _XLCK=(this) && _xlck_setup_dpms)
    export _XLCK=$(readlink -e "$BASH_SOURCE")

    #XSET=$(type 'xset' 2>/dev/null)
    if [ -n "$DISPLAY" ]; then
        _xlck_setup_dpms
    fi
}

function _xlck_xlock  {
    # _xlck_xlck()      -- start xlock (white on black w/ a 3 second delay)
    /usr/bin/xlock -mode blank -bg black -fg white -lockdelay 3
}

function _xlck_i3lock  {
    # _xlck_i3lock()    -- start i3lock with a dark gray background
    /usr/bin/i3lock -d -c 202020
}
function xlck_gnome_screensaver_status {
    # xlck_gnome_screensaver_status()  -- gnome-screensaver PIDs on $DISPLAY
    xlck_pgrep_display "gnome-screensaver" "$DISPLAY"
    return
}

function xlck_gnome_screensaver_start {
    # xlck_gnome_screensaver_start() -- start gnome-screensaver
    xlck_gnome_screensaver_status
    gnome-screensaver --display="$DISPLAY"
    xlck_gnome_screensaver_status
}

function xlck_gnome_screensaver_lock {
    # xlck_gnome_screensaver_lock() -- lock gnome-screensaver
    xlck_gnome_screensaver_status
    gnome-screensaver-command --lock
}


function _xlck_which_lock {
    if [[ -x /usr/bin/i3lock ]]; then
        echo "i3lock"
        _xlck_i3lock
    elif [[ -x /usr/bin/xlock ]]; then
        echo "xlock"
        _xlck_xlock
    elif [[ -x /usr/bin/gnome-screensaver ]]; then
        echo "gnome-screensaver"
        xlck_gnome_screensaver_lock
    fi
}

function xlck_lock  {
    # xlock_lock()      -- lock the current display
    #   $1 {i3lock|i3, xlock|x, gnome-screensaver|gnome|g}
    #   note: this will be run before suspend to RAM and Disk.
    local lockfn="${1:-"$(_xlck_which_lock)"}"
    case $lockfn in
        i3lock|i3)
            _xlck_i3lock
            return
            ;;
        xlock|x)
            _xlck_xlock
            return
            ;;
        gnome-screensaver|gnome|g)
            xlck_gnome_screensaver_start
            xlck_gnome_screensaver_lock
            return
            ;;
        *)
            echo "Found neither i3lock nor xlock"
            return -1
    esac
}

function _suspend_to_ram  {
    # _suspend_to_ram()     -- echo mem > /sys/power/state
    sudo bash -c 'echo mem > /sys/power/state'
}

function _suspend_to_disk  {
    # _suspend_to_disk()    -- echo disk > /sys/power/state
    #  note: this does not work on many machines
    sudo bash -c 'echo disk > /sys/power/state'
}

function _dbus_halt {
    # _dbus_halt()      -- send a dbus stop msg to ConsoleKit
    dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop
}

function _dbus_reboot {
    # _dbus_reboot()    -- send a dbus reboot msg to ConsoleKit
    dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart
}

function _dbus_suspend {
    # _dbus_suspend()   -- send a dbus suspend msg to ConsoleKit
    dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend
}

function _dbus_hibernate  {
    # _dbus_hibernate() -- send a dbus hibernate msg to ConsoleKit
    dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate
}

function xlck_lock_suspend_ram  {
    # xlck_lock_suspend_ram()   -- lock and suspend to RAM
    sudo bash -c 'whoami'
    xlck_lock && _suspend_to_ram
}

function xlck_lock_suspend_disk  {
    # xlck_lock_suspend_disk()  -- lock and suspend to disk
    sudo bash -c 'whoami'
    xlck_lock && _suspend_to_disk
}

function xlck_suspend_ram  {
    # xlck_suspend_ram()        -- lock and suspend to RAM
    xlck_lock_suspend_ram
}

function xlck_suspend_disk  {
    # xlck_suspend_disk()       -- lock and suspend to disk
    xlck_lock_suspend_disk
}

function xlck_start {
    # xlck_start()              -- start xlck
    echo "Starting xlck ..."
    if [ -n "$DISPLAY" ]; then
        _xlck_setup
        _xlck_xautolock & disown
        echo "Started xlck ..."
        sleep 1
        xlck_status
    fi
}

function xlck_stop {
    # xlck_stop()               -- stop xlck
    echo "Stopping xlck ..."
    xlck_xautolock_stop
    echo "xlck stopped"
}

function xlck_restart {
    # xlck_restart()            -- stop and start xlck
    #xautolock -restart  # does not work with xautolock -secure
    xlck_stop
    xlck_start
}


function xlck_pgrep_display {
    # xlck_pgrep_display()-- find xautolock on this display
    procname="${1}"
    display="${2:-$DISPLAY}"
    if [ -z "${@}" ]; then
        echo "usage: <procname> [<display>]"
        return 2
    fi
    pids=$(pgrep "$procname")
    if [ -n "$pids" ]; then
        ps eww -p ${pids} \
        | grep " DISPLAY=$display" \
        | awk '{ print $1 }'
    fi
}

function xlck_xautolock_pgrep_display {
    # xlck_xautolock_pgrep_display()-- find xautolock on this display
    display=${1:-$DISPLAY}
    pids=$(pgrep xautolock)
    if [ -n "$pids" ]; then
        ps eww -p ${pids} \
        | grep " DISPLAY=$display" \
        | awk '{ print $1 }'
    fi
}

function xlck_xautolock_status {
    # xlck_xautolock_status()       -- show xlck status 
    echo "# Checking autolock status where DISPLAY=$DISPLAY"
    _xautolock_actual_pids=$(xlck_xautolock_pgrep_display)
    if [ -n "$_xautolock_actual_pids" ]; then
        ps ufw -p $_xautolock_actual_pids
    else
        echo "no autolock processes found on this \$DISPLAY"
    fi
}

function xlck_xautolock_stop {
    # xlck_autolock_stop()          -- stop autolock on the current $DISPLAY
    echo "# Stopping xautolock where DISPLAY=$DISPLAY ..."
    _xautolock_actual_pids=$(xlck_xautolock_pgrep_display)
    if [ -n "$_xautolock_actual_pids" ]; then
        kill -9 $_xautolock_actual_pids
        echo "# Stopped xautolock"
    else
        echo "# xautolock not found"
    fi
    xlck_xautolock_status
}

function xlck_status {
    # xlck_status()     -- xlck_xautolock_status
    xlck_xautolock_status
}

function xlck_status_all {
    # xlck_status_all() -- pgrep 'xautolock|xlock|i3lock', ps ufw
    _xlck_pgrep="pgrep 'xautolock|xlock|i3lock'"
    _xlck_pids=$(pgrep 'xautolock|xlock|i3lock')
    if [ -n "$_xlck_pids" ]; then
        echo "_xlck_pids=${_xlck_pids}"
        ps ufw -p $_xlck_pids
    else
        echo "\"${_xlck_pgrep}\" did not find any process ids"
    fi
}

function xlck_status_this_display {
    # xlck_status_this_display()  -- show status for this $DISPLAY
    display=${1:-$DISPLAY}
    ps ufx -p
    _pids=$(ps eww | grep "DISPLAY=$display" | awk '{ print $1 }')
}

function _xlck_xautolock {
    # _xlck_xautolock()           -- start xautolock (see: xlck_start)
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

function xlck_usage {
    echo "# $0"
    echo "$(basename $0) [-h] [-I|-U|-S|-P|-R|-M|-N|-D|-L|-X]";
    echo ""
    echo "  a script for working with xautolock and xlock, i3lock;"
    echo "  as well as issuing suspend, shutdown, and restart commands."
    echo ""
    echo "  -I  --  (I)nstall xlck (apt-get)"
    echo "  -U  --  check stat(U)s (show xautolock processes on this \$D"
    echo "  -S  --  (S)tart xlck (start xautolock on this \$DISPLAY)"
    echo "  -P  --  sto(P) xlck (stop xautolock on this \$DISPLAY)"
    echo "  -R  --  (R)estart xlck"
    echo "  -M  --  suspend to ra(M) (and lock)"
    echo "  -D  --  suspend to (D)isk (and lock)"
    echo "  -L  --  (L)ock"
    echo ""
    echo "  -X  --  shutdown -h now"
    echo ""
    echo "  -h  --  help"
    echo ""
}

function xlck_main {
    if [ -z "${@}" ]; then
        xlck_usage
        # return nonzero if no args
        return 86
    fi
    while getopts "USPRMDLXh" opt; do
        case "${opt}" in
            I)
                _xlck_install;
                ;;
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
                xlck_lock_suspend_ram;
                ;;
            D)
                xlck_lock_suspend_disk;
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
  xlck_main "$@"
  exit
fi
