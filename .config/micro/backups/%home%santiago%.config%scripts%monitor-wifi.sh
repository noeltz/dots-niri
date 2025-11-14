#!/usr/bin/env bash
# Wi-Fi notifier via dbus-monitor + NetworkManager

ICON_PATH="$HOME/.icons"
STATE_FILE="/tmp/wifi_last_state"

LINE="$1"

# We only care about "StateChanged" signals from NetworkManager
if [[ "$LINE" != *"StateChanged"* ]]; then
    exit 0
fi

# States (numeric codes from NM):
# 10 = disconnected
# 20 = disconnecting
# 30 = connecting
# 40 = connected (local only)
# 50 = connected (site)
# 70 = connected (global/online)

STATE=$(echo "$LINE" | grep -o '[0-9]\+' | tail -n1)
LAST_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

# Prevent duplicate notifications
if [[ "$STATE" == "$LAST_STATE" ]]; then
    exit 0
fi
echo "$STATE" > "$STATE_FILE"

# Notify depending on state
case "$STATE" in
    10|20)
        notify-send -i "$ICON_PATH/wifi-off.svg" "Wi-Fi Disconnected" "You are offline"
        ;;
    30)
        notify-send -i "$ICON_PATH/wifi-connecting.svg" "Wi-Fi Connecting" "Attempting to connect..."
        ;;
    40|50|70)
        notify-send -i "$ICON_PATH/wifi-on.svg" "Wi-Fi Connected" "You are online"
        ;;
esac
