#!/usr/bin/env bash

UI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$UI_DIR/colors.sh"

POPUP_STYLE=(
  popup.align=right
  popup.y_offset=4
  popup.background.color="$THEME_POPUP"
  popup.background.corner_radius=10
  popup.background.border_width=1
  popup.background.border_color="$THEME_POPUP_BORDER"
  popup.blur_radius=0
)

POPUP_ROW_STYLE=(
  icon.drawing=on
  icon.font="SauceCodePro Nerd Font:Bold:13.0"
  icon.color="$THEME_MUTED"
  icon.width=24
  icon.align=center
  icon.padding_left=0
  icon.padding_right=0
  label.font="SF Pro:Semibold:12.0"
  label.color="$THEME_NORMAL"
  label.padding_left=6
  label.padding_right=0
  background.drawing=on
  background.color="$THEME_TRANSPARENT"
  background.height=28
  background.padding_left=10
  background.padding_right=10
)

ui_hover() {
  sketchybar --animate sin 9 --set "$NAME" \
    background.drawing=on \
    background.color="$THEME_HOVER"
}

ui_unhover() {
  local color="${1:-$THEME_TRANSPARENT}"
  sketchybar --animate sin 9 --set "$NAME" \
    background.drawing=on \
    background.color="$color"
}

ui_show_popup() {
  ui_hover
  sketchybar --set "$NAME" popup.drawing=on
}

ui_hide_popup() {
  sketchybar --set "$NAME" popup.drawing=off
  ui_unhover "${1:-$THEME_TRANSPARENT}"
}

ui_handle_popup_event() {
  case "${SENDER:-}" in
  mouse.entered)
    ui_show_popup
    return 0
    ;;
  mouse.exited | mouse.exited.global)
    ui_hide_popup "${1:-$THEME_TRANSPARENT}"
    return 0
    ;;
  esac
  return 1
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  case "${SENDER:-}" in
  mouse.entered)
    ui_hover
    ;;
  mouse.exited | mouse.exited.global)
    exit_color="$THEME_TRANSPARENT"
    if [[ "${NAME:-}" =~ ^space\.[1-7]$ ]]; then
      workspace="${NAME#space.}"
      workspace="${workspace%%.*}"
      state_dir="${SKETCHYBAR_STATE_DIR:-${TMPDIR:-/tmp}}"
      focused="$(cat "$state_dir/sketchybar_focused_workspace" 2>/dev/null)"
      [[ "$workspace" == "$focused" ]] && exit_color="$THEME_FOCUSED"
    fi
    ui_unhover "$exit_color"
    ;;
  esac
fi
