#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

read_volume() {
  osascript -e 'output volume of (get volume settings)' 2>/dev/null
}

volume=""
case "${SENDER:-}" in
volume_change)
  volume="${INFO:-}"
  ;;
mouse.entered)
  ui_show_popup
  exit 0
  ;;
mouse.exited | mouse.exited.global)
  ui_hide_popup
  exit 0
  ;;
*)
  volume="$(read_volume)"
  ;;
esac

[[ "$volume" =~ ^[0-9]+$ ]] || exit 0

case "$volume" in
6[0-9] | 7[0-9] | 8[0-9] | 9[0-9] | 100) icon="󰕾" ;;
3[0-9] | 4[0-9] | 5[0-9]) icon="󰖀" ;;
0) icon="󰖁" ;;
*) icon="󰕿" ;;
esac

color="$THEME_NORMAL"
((volume == 0)) && color="$THEME_MUTED"

sketchybar --set "$NAME" icon="$icon" "icon.color=$color" \
  --set "$NAME.popup.level" "label=Volume: $volume%"
