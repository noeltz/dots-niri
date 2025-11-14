#!/bin/bash
set -e

echo -e "\n\e[32mLet's create a new web app you can start with the app launcher.\e[0m"
echo -e "\n\e[32mBefore you start you need the link and the icon image (png) on Downloads.\e[0m"

gum style --border double \
          --border-foreground "#cba6f7" \
          --margin "1 2"  \
          --padding "1 2" \
          --foreground "#cba6f7" "󰙵  Web App Installer"
           
APP_NAME=$(gum input --prompt "Enter app name: " --prompt.foreground "#cba6f7" --placeholder "(e.g. WhatsApp)")
[ -z "$APP_NAME" ] && gum style --foreground "#f38ba8" "❌ No app name entered. Exiting." && exit 1

APP_URL=$(gum input --prompt "Enter app url: " --prompt.foreground "#cba6f7" --placeholder "(e.g. https://web.whatsapp.com)")
[ -z "$APP_URL" ] && gum style --foreground "#f38ba8" "❌ No URL entered. Exiting." && exit 1

NEW_ICON=$(gum input --prompt "Enter the icon name from Downloads: " --prompt.foreground "#cba6f7" --placeholder "(e.g. YoutubeMusic.png")
[ -z "$APP_URL" ] && gum style --foreground "#f38ba8" "❌ No URL entered. Exiting." && exit 1

echo $NEW_ICON_PATH

ICON_NAME=$(echo "$APP_NAME" | tr -d ' ')
ICON_DIR=$ICON_PATH/$ICON_NAME.png

cp $HOME/Downloads/$NEW_ICON $ICON_DIR

APPLICATION=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
DESKTOP_FILE="$HOME/.local/share/applications/$APPLICATION.desktop"

# Create desktop entry
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$SCRIPT_PATH/launch-webbapp.sh $APP_URL
Icon=$ICON_DIR
Type=Application
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

# Send Mako notification
notify-send -a blue -i $ICON "Web App Installed" "$APP_NAME → $APP_URL"

gum style --foreground "#a6e3a1" "✅ Installed '$APP_NAME'!"
gum style --foreground "#89dceb" "You can now find it in your app launcher"
