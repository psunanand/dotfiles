#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/colors.sh"

STATE=$(blueutil --power)
# Fetch all paired devices to see, not just what is active
DEVICES=$(blueutil --paired | grep "address:")

if [ "$STATE" = "1" ]; then
  # Check if at least one device is actually connected
  if blueutil --connected | grep -q "address"; then
    ICON="󰂱"
  else
    ICON="󰂯"
  fi
else
  ICON="󰂲"
fi

# update_popup() {
#
#   # Wipe the old to remove duplicates
#   sketchybar --remove '/bluetooth.device\..*/'
#
#   if [ -z "$DEVICES" ]; then
#     sketchybar --add item bluetooth.device.none popup."$NAME" \
#       --set bluetooth.device.none label="No Paired Devices" \
#       label.color=$GREY
#   else
#     # Counter for unique naming
#     COUNTER=0
#     echo "$DEVICES" | while read -r line; do
#       NAME_CLEAN=$(echo "$line" | sed -n 's/.*name: "\(.*\)", address.*/\1/p')
#       # Check if the specific device is connected
#       IS_CONNECTED=$(echo "$line" | grep "connected: 1")
#
#       [ -z "$NAME_CLEAN" ] && continue
#
#       ITEM_NAME="bluetooth.device.$COUNTER"
#
#       # Determine row styling based on connection status
#       if [ -n "$IS_CONNECTED" ]; then
#       else
#       fi
#
#       sketchybar --add item "$ITEM_NAME" popup.$NAME \
#         --set "$ITEM_NAME" \
#         icon="$STATUS_ICON" \
#         label="$NAME_CLEAN" \
#         background.color=$BAR_COLOR \
#         background.corner_radius=4 \
#         background.drawing=on \
#         margin=4 \
#         label.padding_right=10
#
#       COUNTER=$((COUNTER + 1))
#     done
#   fi
# }

update_popup() {
  # Wipe the graveyard to prevent duplicates
  sketchybar --remove '/bluetooth.device\..*/'

  if [ -z "$DEVICES" ]; then
    sketchybar --add item bluetooth.device.none popup."$NAME" \
      --set bluetooth.device.none \
      label="No Devices Found" \
      label.color="$WHITE" \
      label.padding_left=10 \
      label.padding_right=10
  else
    COUNTER=0
    while read -r line; do
      NAME_CLEAN=$(echo "$line" | sed -E 's/.*name: "([^"]*)".*/\1/')
      [ -z "$NAME_CLEAN" ] && continue

      if echo "$line" | grep -q "connected" && ! echo "$line" | grep -q "not connected"; then
        STATUS_ICON="􀖀"
      else
        STATUS_ICON="􁅒"
      fi

      ITEM_NAME="bluetooth.device.$COUNTER"
      sketchybar --add item "$ITEM_NAME" popup."$NAME" \
        --set "$ITEM_NAME" \
        icon="$STATUS_ICON" \
        icon.padding_left=10 \
        label="$NAME_CLEAN" \
        label.padding_right=10 \
        background.corner_radius=12 \
        background.drawing=on \
        background.height=35

      COUNTER=$((COUNTER + 1))
    done <<<"$DEVICES"
  fi
}

case "$SENDER" in
"mouse.entered")
  update_popup
  sketchybar --set "$NAME" popup.drawing=on
  ;;
"mouse.exited")
  sketchybar --set $NAME popup.drawing=off icon.padding_left=20
  ;;
*)
  sketchybar --set $NAME icon="$ICON" icon.padding_left=20
  ;;
esac
