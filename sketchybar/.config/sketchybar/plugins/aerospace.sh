#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/colors.sh"

# $1 is the workspace ID passed from sketchybarrc of the item being updated
# $FOCUSED_WORKSPACE is passed from the Aerospace trigger

# Fallback: If FOCUSED_WORKSPACE is empty, ask AeroSpace directly
if [ -z "$FOCUSED_WORKSPACE" ]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
fi

COMMON_PROPS=(
  # background.corner_radius=5
  label.font="sketchybar-app-font:Regular:16.0"
  label.padding_right=20
  background.drawing=on
)

# Check if this specific item is the one that should be focused
if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
    "${COMMON_PROPS[@]}" \
    background.color=$BAR_COLOR \
    background.border_color=$ACCENT_COLOR \
    background.border_width=3 \
    icon.color=$ACCENT_COLOR \
    label.color=$WHITE \
    drawing=on
else
  # Check if it has windows to decide if it should be drawn
  WIN_COUNT=$(aerospace list-windows --workspace "$1" --count)
  if [ "$WIN_COUNT" -gt 0 ]; then
    sketchybar --set "$NAME" \
      "${COMMON_PROPS[@]}" \
      background.color=$ITEM_BG_COLOR \
      background.border_width=0 \
      icon.color=$GREY \
      label.color=$GREY \
      drawing=on
  else
    sketchybar --set "$NAME" drawing=off
  fi
fi

# Update Icons (optional but recommended here)
# This ensures icons are correct on startup too
APPS_LIST=$(aerospace list-windows --workspace "$1" --format "%{app-name}")
ICON_STRIP=""
if [ -n "$APPS_LIST" ]; then
  while read -r app; do
    ICON_STRIP+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
  done <<<"$APPS_LIST"
fi
sketchybar --set "$NAME" label="$ICON_STRIP"
