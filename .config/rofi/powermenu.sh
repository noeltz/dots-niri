#!/bin/bash

# Uptime
UPTIME=$(uptime -p | sed -e 's/up //g')

# Options
LOCK='󰌾'
LOGOUT='󰍃'
SUSPEND='󰤄'
REBOOT=''
SHUTDOWN='󰤆'

# Rofi launcher
launch_rofi() {
	rofi -dmenu \
		-mesg "Uptime: $UPTIME" \
		-theme $ROFI_PATH/powermenu.rasi
}

# Select option
OPTION=$(echo -en "$LOCK\n$LOGOUT\n$REBOOT\n$SHUTDOWN" | launch_rofi)

case ${OPTION} in
    $LOCK) sleep 0.3; hyprlock;;
    $LOGOUT) hyprctl dispatch exit;;
    $SUSPEND) systemctl sleep;;
    $REBOOT) systemctl reboot;;
    $SHUTDOWN) systemctl poweroff;;
esac
