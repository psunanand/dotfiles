#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/colors.sh"

if ! command -v aerospace &>/dev/null; then
  exit 0
fi

# $1 is the workspace ID passed from sketchybarrc
# $FOCUSED_WORKSPACE is passed from the Aerospace trigger

if [ -z "$FOCUSED_WORKSPACE" ]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
fi

# Determine display dynamically
DISPLAY_ID=$(aerospace list-workspaces --monitor all --format "%{workspace} %{monitor-appkit-nsscreen-screens-id}" 2>/dev/null | awk -v ws="$1" '$1 == ws {print $2}')
if [ -z "$DISPLAY_ID" ]; then
  DISPLAY_ID=1
  [ "$1" -ge 8 ] && DISPLAY_ID=2
fi

# Only update display if it changed
DISPLAY_CACHE="/tmp/sketchybar_display_${NAME}"
CACHED_DISPLAY=$(cat "$DISPLAY_CACHE" 2>/dev/null || echo "")
if [ "$DISPLAY_ID" != "$CACHED_DISPLAY" ]; then
  sketchybar --set "$NAME" display="$DISPLAY_ID"
  echo "$DISPLAY_ID" > "$DISPLAY_CACHE"
fi

# Query unique app names (deduplicated)
APPS=$(aerospace list-windows --workspace "$1" --format "%{app-name}" 2>/dev/null | sort -u)

APP_COUNT=0
APP_LIST=()
if [ -n "$APPS" ]; then
  while IFS= read -r app; do
    APP_LIST+=("$app")
  done <<< "$APPS"
  APP_COUNT=${#APP_LIST[@]}
fi

IS_FOCUSED=false
[ "$1" = "$FOCUSED_WORKSPACE" ] && IS_FOCUSED=true
WS=$1

# --- Update the number pill ---
if $IS_FOCUSED; then
  sketchybar --set space."$1" \
    label.drawing=on \
    background.color=$BAR_COLOR \
    background.border_color=$ACCENT_COLOR \
    background.border_width=2 \
    drawing=on
elif [ "$APP_COUNT" -gt 0 ]; then
  sketchybar --set space."$1" \
    label.drawing=on \
    background.color=$BAR_COLOR \
    background.border_width=0 \
    drawing=on
else
  sketchybar --set space."$1" drawing=off
  for idx in 1 2 3; do
    sketchybar --set space."$WS".app$idx drawing=off
  done
  exit 0
fi

# All pills use bar color background; focused ones get accent border
if $IS_FOCUSED; then
  BORDER_COLOR=$ACCENT_COLOR
  BORDER_WIDTH=2
else
  BORDER_COLOR=$BAR_COLOR
  BORDER_WIDTH=0
fi

# --- Update the app pills ---
if [ "$APP_COUNT" -eq 0 ]; then
  for idx in 1 2 3; do
    sketchybar --set space."$WS".app$idx drawing=off
  done
elif [ "$APP_COUNT" -le 3 ]; then
  for ((i=0; i<3; i++)); do
    idx=$((i+1))
    if [ "$i" -lt "$APP_COUNT" ]; then
      APP="${APP_LIST[$i]}"
      sketchybar --set space."$WS".app$idx \
        drawing=on \
        display="$DISPLAY_ID" \
        background.color=$BAR_COLOR \
        background.border_color=$BORDER_COLOR \
        background.border_width=$BORDER_WIDTH \
        icon.background.drawing=on \
        icon.background.image="app.$APP" \
        icon.background.image.scale=0.65 \
        icon.padding_left=8 \
        icon.padding_right=8 \
        label.drawing=off
    else
      sketchybar --set space."$WS".app$idx drawing=off
    fi
  done
else
  for ((i=0; i<2; i++)); do
    APP="${APP_LIST[$i]}"
    sketchybar --set space."$WS".app$((i+1)) \
      drawing=on \
      display="$DISPLAY_ID" \
      background.color=$BAR_COLOR \
      background.border_color=$BORDER_COLOR \
      background.border_width=$BORDER_WIDTH \
      icon.background.drawing=on \
      icon.background.image="app.$APP" \
      icon.background.image.scale=0.65 \
      icon.padding_left=8 \
      icon.padding_right=8 \
      label.drawing=off
  done

  EXTRA=$((APP_COUNT - 2))
  sketchybar --set space."$WS".app3 \
    drawing=on \
    display="$DISPLAY_ID" \
    background.color=$BAR_COLOR \
    background.border_color=$BORDER_COLOR \
    background.border_width=$BORDER_WIDTH \
    icon.background.drawing=off \
    icon.padding_left=0 \
    icon.padding_right=0 \
    label.drawing=on \
    label="+${EXTRA}" \
    label.color=$GREY \
    label.font="SF pro:Semibold:12.0" \
    label.padding_left=8 \
    label.padding_right=8
fi
