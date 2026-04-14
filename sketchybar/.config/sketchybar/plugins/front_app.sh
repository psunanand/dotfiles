#!/usr/bin/env zsh

source "$CONFIG_DIR/plugins/colors.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set $NAME \
    label="${INFO:u}" \
    label.color=$GREY \
    label.font="SF Pro:Semibold:13.0" \
    label.y_offset=0 \
    icon.background.drawing=on \
    icon.background.image="app.$INFO" \
    icon.background.image.scale=0.65 \
    icon.padding_right=5 \
    background.drawing=off
fi
