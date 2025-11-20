#!/usr/bin/env bash
set -euo pipefail

# --- Init default theme ---
if ! [ -f $HOME/.cache/theme-sync-state ]; then
    swww img $HOME/.local/share/wallpaper/Material/Dark/default.jpg
    sleep 1
    bash $HOME/.config/scripts/theme-sync.sh
fi