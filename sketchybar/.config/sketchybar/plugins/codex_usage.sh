#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$SCRIPT_DIR/../helpers/codex_usage.py"
ICON="󰚩"

source "$SCRIPT_DIR/colors.sh"

set_unavailable() {
  sketchybar --set "$NAME" \
    icon="$ICON" \
    label="Codex ?" \
    label.color="$GREY" \
    --set "$NAME".popup.primary drawing=on label="Usage unavailable" \
    --set "$NAME".popup.primary_reset drawing=off \
    --set "$NAME".popup.secondary drawing=off \
    --set "$NAME".popup.secondary_reset drawing=off
}

case "${SENDER:-}" in
"mouse.entered")
  sketchybar --set "$NAME" popup.drawing=on
  exit 0
  ;;
"mouse.exited")
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
  ;;
esac

if ! result="$(python3 "$HELPER" 2>/dev/null)"; then
  set_unavailable
  exit 0
fi

if ! window_count="$(jq -er '.windows | length' <<<"$result" 2>/dev/null)" || (( window_count == 0 )); then
  set_unavailable
  exit 0
fi

summary="$(jq -r '[.windows[] | "\(.short_label) \(.remaining)%"] | join(" · ")' <<<"$result")"
lowest_remaining="$(jq -er '[.windows[].remaining] | min' <<<"$result")"
first_label="$(jq -r '.windows[0].label' <<<"$result")"
first_remaining="$(jq -r '.windows[0].remaining' <<<"$result")"
first_reset="$(jq -r '.windows[0].reset' <<<"$result")"
second_label="$(jq -r '.windows[1].label // empty' <<<"$result")"
second_remaining="$(jq -r '.windows[1].remaining // empty' <<<"$result")"
second_reset="$(jq -r '.windows[1].reset // empty' <<<"$result")"

if (( lowest_remaining <= 10 )); then
  color="$RED"
elif (( lowest_remaining <= 30 )); then
  color="$YELLOW"
else
  color="$GREEN"
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  label="$summary" \
  label.color="$color" \
  --set "$NAME".popup.primary drawing=on label="$first_label remaining: $first_remaining%" \
  --set "$NAME".popup.primary_reset drawing=on label="$first_label resets: $first_reset" \
  --set "$NAME".popup.secondary drawing=$([[ -n "$second_label" ]] && echo on || echo off) label="$second_label remaining: $second_remaining%" \
  --set "$NAME".popup.secondary_reset drawing=$([[ -n "$second_label" ]] && echo on || echo off) label="$second_label resets: $second_reset"
