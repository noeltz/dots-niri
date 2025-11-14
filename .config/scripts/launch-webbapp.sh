#!/bin/bash

$BROWSER --new-window "$1" --kiosk
sleep 0.3
hyprctl dispatch setfloating
hyprctl dispatch centerwindow
