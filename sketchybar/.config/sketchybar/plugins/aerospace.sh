#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/colors.sh"

if ! command -v aerospace &>/dev/null; then
  exit 0
fi

# $1 is the workspace ID passed from sketchybarrc of the item being updated
# $FOCUSED_WORKSPACE is passed from the Aerospace trigger

# Fallback: If FOCUSED_WORKSPACE is empty, ask AeroSpace directly
if [ -z "$FOCUSED_WORKSPACE" ]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
fi

# Determine display dynamically. Try Aerospace query first, fall back to heuristic.
DISPLAY_ID=$(aerospace list-workspaces --format "%{workspace} %{monitor-appkit-nsscreen-screens-id}" 2>/dev/null | awk -v ws="$1" '$1 == ws {print $2}')
if [ -z "$DISPLAY_ID" ]; then
  DISPLAY_ID=1
  [ "$1" -ge 8 ] && DISPLAY_ID=2
fi
sketchybar --set "$NAME" display="$DISPLAY_ID"

COMMON_PROPS=(
  label.font="sketchybar-app-font:Regular:16.0"
  label.padding_right=20
  background.drawing=on
)

# Query windows once (single atomic call)
APPS_LIST=$(aerospace list-windows --workspace "$1" --format "%{app-name}")

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
elif [ -n "$APPS_LIST" ]; then
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

# Update Icons
ICON_STRIP=""
if [ -n "$APPS_LIST" ]; then
  while read -r app; do
    ICON_STRIP+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
  done <<<"$APPS_LIST"
fi
sketchybar --set "$NAME" label="$ICON_STRIP"
