#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

case "${SENDER:-}" in
mouse.entered)
  ui_hover
  exit 0
  ;;
mouse.exited | mouse.exited.global)
  ui_unhover "$THEME_TRANSPARENT"
  exit 0
  ;;
esac

app_name="${INFO:-}"
if [[ -z "$app_name" ]]; then
  app_name="$(
    osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null
  )"
fi
[[ -z "$app_name" ]] && exit 0

label="$app_name"
if ((${#label} > 20)); then
  label="${label:0:19}…"
fi

sketchybar --set "$NAME" \
  "label=$label" \
  "label.color=$THEME_NORMAL" \
  icon.background.drawing=on \
  "icon.background.image=app.$app_name" \
  icon.background.image.scale=0.62 \
  background.drawing=on \
  "background.color=$THEME_TRANSPARENT"
