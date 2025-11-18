#!/bin/bash

BATTERY_LOW=25
BATTERY_CRITICAL=10
ICON_PATH=$HOME/.icons
SOUND_PATH=$HOME/.sounds

STATE_FILE="/tmp/last_battery_state"
LEVEL_FILE="/tmp/last_battery_level"

get_battery_percentage() {
  upower -i "$(upower -e | grep 'BAT')" \
  | awk -F: '/percentage/ {
      gsub(/[%[:space:]]/, "", $2);
      print $2; exit
    }'
}

get_battery_state() {
  upower -i "$(upower -e | grep 'BAT')" \
  | awk -F: '/state/ {gsub(/^[ \t]+/, "", $2); print $2}'
}

BATTERY_LEVEL=$(get_battery_percentage)
BATTERY_STATE=$(get_battery_state)

LAST_STATE="none"
[ -f "$STATE_FILE" ] && LAST_STATE=$(cat "$STATE_FILE")

LAST_LEVEL=100
[ -f "$LEVEL_FILE" ] && LAST_LEVEL=$(cat "$LEVEL_FILE")

# Save for next run
echo "$BATTERY_STATE" > "$STATE_FILE"
echo "$BATTERY_LEVEL" > "$LEVEL_FILE"

if [ $BATTERY_STATE == "discharging" ]; then
  if [ $BATTERY_LEVEL -gt $BATTERY_LOW ] && [ $LAST_STATE == "charging" ]; then
    notify-send -a gray -i $ICON_PATH/unplug.svg "Discharging" "Battery charger disconnected"
	paplay $SOUND_PATH/unplug.mp3
  fi

  if [ $BATTERY_LEVEL -le $BATTERY_CRITICAL ] && [ $LAST_LEVEL -gt $BATTERY_CRITICAL ]; then
    notify-send -u red -i $ICON_PATH/battery-critical.svg "Battery Critical" "Please plug in your device"
	paplay $SOUND_PATH/battery-critical.mp3
  elif [ $BATTERY_LEVEL -le $BATTERY_LOW ] && [ $LAST_LEVEL -gt $BATTERY_LOW ]; then
    notify-send -u yellow -i $ICON_PATH/battery-low.svg "Battery Low" "Your battery is under 30%"
	paplay $SOUND_PATH/battery-low.mp3
  fi
fi

if [ $BATTERY_STATE == "charging" ]; then
  if [ $LAST_STATE != "charging" ]; then
    notify-send -a blue -i $ICON_PATH/battery-charging.svg "Charging" "Battery charger connected"
	paplay $SOUND_PATH/plugin.mp3
  fi

  if [ $BATTERY_LEVEL -ge 95 ] && [ $LAST_LEVEL -lt 95 ]; then
    notify-send -a green -i $ICON_PATH/battery-full.svg "Battery Full" "You can unplug your device"
	paplay $SOUND_PATH/battery-full.mp3
  fi
fi
