#!/usr/bin/env bash

# --- Configuration ---
INIT_SCRIPT="$HOME/.config/scripts/theme-sync.sh"
FILE_TO_CHECK="$HOME/.config/waybar/colors.css"
MAX_RETRIES=10  # Maximum seconds to wait
# ---------------------

# --- Init default theme ---
if ! [ -f $HOME/.cache/theme-sync-state ]; then
    swww img $HOME/.local/share/wallpaper/Material/Dark/default.jpg
    sleep 1
    if [[ -x "$INIT_SCRIPT" ]]; then
        bash -c "$INIT_SCRIPT"
    else
        echo "Warning: $INIT_SCRIPT not found or not executable."
    fi
    count=0
    while [[ $count -lt $MAX_RETRIES ]]; do
        if [[ -f "$FILE_TO_CHECK" ]]; then
            exit 0
        fi
        sleep 1
        ((count++))
    done
    touch $FILE_TO_CHECK
    exit 0
fi