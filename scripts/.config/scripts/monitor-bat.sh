#!/bin/bash
LOW=25
CRITICAL=10
TOP=95

ICON_PATH=$HOME/.icons
SOUND_PATH=$HOME/.sounds

BAT_PATH="/sys/class/power_supply/BAT1"
BATTERY_LEVEL=$(cat $BAT_PATH/capacity)
BATTERY_STATE=$(cat $BAT_PATH/status)

LAST_STATE_FILE="/tmp/last_battery_state"
LAST_LEVEL_FILE="/tmp/last_battery_level"

send() {  
  local app=$1 icon=$2 title=$3 body=$4 sound=$5

  notify-send -a "${app}" \
              -i $ICON_PATH/"${icon}.svg" \
              "$title" "$body"
  paplay $SOUND_PATH/$sound
}

LAST_STATE="none"
[ -f "$LAST_STATE_FILE" ] && LAST_STATE=$(cat "$LAST_STATE_FILE")

LAST_LEVEL=100
[ -f "$LAST_LEVEL_FILE" ] && LAST_LEVEL=$(cat "$LAST_LEVEL_FILE")

# Save for next
echo "$BATTERY_STATE" > "$LAST_STATE_FILE"
echo "$BATTERY_LEVEL" > "$LAST_LEVEL_FILE"

if [ $BATTERY_STATE == "Discharging" ]; then
	if [ $LAST_STATE != "Discharging" ]; then
	 	send gray unplug "Discharging" "Battery charger disconnected" unplug.mp3
	fi
    
	if [[ $BATTERY_LEVEL -le $CRITICAL && 
	    ( $LAST_LEVEL -gt $CRITICAL || $LAST_STATE != "Discharging" ) ]]; then
		send red battery-warning "Battery Critical" "Please plug in your device" battery-critical.mp3
	fi

	if [[ $BATTERY_LEVEL -le $LOW && $BATTERY_LEVEL -gt $CRITICAL && 
	    ( $LAST_LEVEL -gt $LOW || $LAST_STATE != "Discharging" ) ]]; then
	    send yellow battery-low "Battery Low" "Your battery is low" battery-low.mp3
	fi
fi

if [ $BATTERY_STATE == "Charging" ]; then
	if [ $LAST_STATE != "Charging" ]; then
	    send blue battery-charging "Charging" "Battery charger connected" plugin.mp3
	fi

	if [ $BATTERY_LEVEL -ge $TOP ] && [ $LAST_LEVEL -lt $TOP ]; then
	    send green battery-full "Battery Full" "You can unplug your device" battery-full.mp3
	fi
fi
