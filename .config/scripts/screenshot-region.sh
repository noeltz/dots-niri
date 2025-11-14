#!/bin/bash

pkill satty 2>/dev/null

hyprshot -m "${1:-region}" --raw | \
  satty --filename - \
  --early-exit \
  --actions-on-enter save-to-clipboard \
  --copy-command 'wl-copy'

paplay "$SOUND_PATH/screen-capture.ogg"
