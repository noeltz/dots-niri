#!/bin/bash

# Kill instances
pkill -f "dbus-monitor.*org.freedesktop.UPower" 2>/dev/null  

dbus-monitor --system "type='signal',sender='org.freedesktop.UPower'" |
grep --line-buffered -E "Percentage|State" |
while read -r _; do
    ~/.config/scripts/monitor-bat.sh
done
