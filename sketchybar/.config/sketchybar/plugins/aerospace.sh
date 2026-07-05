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

# Determine display dynamically. Query Aerospace for workspace-to-monitor mapping.
DISPLAY_ID=$(aerospace list-workspaces --monitor all --format "%{workspace} %{monitor-appkit-nsscreen-screens-id}" 2>/dev/null | awk -v ws="$1" '$1 == ws {print $2}')
if [ -z "$DISPLAY_ID" ]; then
  DISPLAY_ID=1
  [ "$1" -ge 8 ] && DISPLAY_ID=2
fi

# Only update display if it changed (avoids unnecessary sketchybar IPC)
DISPLAY_CACHE="/tmp/sketchybar_display_${NAME}"
CACHED_DISPLAY=$(cat "$DISPLAY_CACHE" 2>/dev/null || echo "")
if [ "$DISPLAY_ID" != "$CACHED_DISPLAY" ]; then
  sketchybar --set "$NAME" display="$DISPLAY_ID"
  echo "$DISPLAY_ID" > "$DISPLAY_CACHE"
fi

COMMON_PROPS=(
  label.drawing=off
  background.drawing=on
)

# Query unique app names (deduplicate for apps with multiple windows)
APPS=$(aerospace list-windows --workspace "$1" --format "%{app-name}" 2>/dev/null | sort -u)

# Count unique apps and get the first one
FIRST_APP=""
APP_COUNT=0
if [ -n "$APPS" ]; then
  APP_COUNT=$(echo "$APPS" | wc -l | tr -d ' ')
  FIRST_APP=$(echo "$APPS" | head -n 1)
fi

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
    "${COMMON_PROPS[@]}" \
    background.color=$BAR_COLOR \
    background.border_color=$ACCENT_COLOR \
    background.border_width=3 \
    drawing=on
elif [ -n "$APPS" ]; then
  sketchybar --set "$NAME" \
    "${COMMON_PROPS[@]}" \
    background.color=$ITEM_BG_COLOR \
    background.border_width=0 \
    drawing=on
else
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

# Show native app icon (no workspace number to avoid overlap)
if [ -n "$FIRST_APP" ]; then
  sketchybar --set "$NAME" \
    icon.background.drawing=on \
    icon.background.image="app.$FIRST_APP" \
    icon.background.image.scale=0.65 \
    icon.padding_left=10 \
    icon.padding_right=5

  # Show "+N" badge for additional apps
  if [ "$APP_COUNT" -gt 1 ]; then
    EXTRA=$((APP_COUNT - 1))
    sketchybar --set "$NAME" \
      label.drawing=on \
      label="+${EXTRA}" \
      label.color=$GREY \
      label.font="SF pro:Semibold:12.0" \
      label.padding_left=2 \
      label.padding_right=8
  fi
else
  sketchybar --set "$NAME" \
    icon.background.drawing=off
fi
