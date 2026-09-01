#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

ui_handle_popup_event && exit 0

read_volume() {
  osascript -e 'output volume of (get volume settings)' 2>/dev/null
}

volume=""
if [[ "${SENDER:-}" == "volume_change" ]]; then
  volume="${INFO:-}"
else
  volume="$(read_volume)"
fi

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
