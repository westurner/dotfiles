#!/bin/sh

cmd0() {
journalctl --help
man journalctl

vim -c ':Man journalctl'
}

cmd1() {
journalctl -o json | jq
}

cmd2() {
journalctl
journalctl --user

journalctl --system

sudo journalctl
}

cmd3__merge() {
journalctl -m
journalctl --merge
}


cmd4__since_until() {
# journalctl -S
# journalctl --since
#
# journactl -U
# journalctl --until
journalctl -S today
journalctl --since today

journalctl -S yesterday
journalctl -S yesterday --output=short-full

journalctl -S 1970-01-01 01:01:00
journalctl -S 1970-01-01 01:01


man systemd.time

journalctl -S -1h   # since 1 hour ago
journalctl -S -1hr  # since 1 hour ago
journalctl -S -1hr20m  # since 1 hour and 20 minutes ago
journalctl -S '1hr20m ago'  # since 1 hour and 20 minutes ago
journalctl -S '1h ago'

man systemd.time  # :
# > When parsing, systemd will accept a similar syntax, but some fields can be omitted, and the space between the date and time can be replaced with a "T" (à la the RFC3339[1] profile of ISO 8601); thus, in CET, the following are all identical: "Fri 2012-11-23 23:02:15 CET", "Fri 2012-11-23T23:02:15", "2012-11-23T23:02:15 CET", "2012-11-23 23:02:15".
journalctl -S 1980-01-01T00:00:00-05:00
journalctl -S 1980-01-01T00:00:00+05:00
journalctl -S 1980-01-01T00:00:00Z
}


cmd5__boot() {
journalctl -b 1  # the first boot in the journal
journalctl -b -0  # the last boot
journalctl -b -1  # the boot before last
journalctl -b all
journalctl --boot all
}

cmd6__unit() {
# journalctl -u UNIT|PATTERN
# journalctl --unit=UNIT|PATTERN
journalctl -u
}
