#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

case "${SENDER:-}" in
mouse.entered)
  ui_hover
  exit 0
  ;;
mouse.exited | mouse.exited.global)
  ui_unhover "$THEME_POPUP"
  exit 0
  ;;
esac

app_name="${INFO:-}"
if [[ -z "$app_name" ]]; then
  aerospace_bin="${AEROSPACE_BIN:-/opt/homebrew/bin/aerospace}"
  app_name="$(
    "$aerospace_bin" list-windows --focused --format '%{app-name}' 2>/dev/null | head -n 1
  )"
fi
[[ -z "$app_name" ]] && exit 0

label="$app_name"
if ((${#label} > 18)); then
  label="${label:0:17}…"
fi

sketchybar --set "$NAME" \
  "label=$label" \
  "label.color=$THEME_NORMAL" \
  icon.background.drawing=on \
  "icon.background.image=app.$app_name" \
  icon.background.image.scale=0.58 \
  background.drawing=on \
  "background.color=$THEME_POPUP"
