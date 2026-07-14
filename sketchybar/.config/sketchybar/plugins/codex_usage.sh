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
    --set "$NAME".popup.primary label="5-hour remaining: unavailable" \
    --set "$NAME".popup.primary_reset label="5-hour resets: unknown" \
    --set "$NAME".popup.secondary label="Weekly remaining: unavailable" \
    --set "$NAME".popup.secondary_reset label="Weekly resets: unknown"
}

remaining_text() {
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    printf '%s%%' "$1"
  else
    printf '?'
  fi
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

primary="$(jq -r '.primary.remaining // empty' <<<"$result" 2>/dev/null)"
secondary="$(jq -r '.secondary.remaining // empty' <<<"$result" 2>/dev/null)"
primary_reset="$(jq -r '.primary.reset // "unknown"' <<<"$result" 2>/dev/null)"
secondary_reset="$(jq -r '.secondary.reset // "unknown"' <<<"$result" 2>/dev/null)"

if [[ ! "$primary" =~ ^[0-9]+$ && ! "$secondary" =~ ^[0-9]+$ ]]; then
  set_unavailable
  exit 0
fi

if [[ "$primary" =~ ^[0-9]+$ && "$secondary" =~ ^[0-9]+$ ]]; then
  lowest_remaining=$((primary < secondary ? primary : secondary))
elif [[ "$primary" =~ ^[0-9]+$ ]]; then
  lowest_remaining=$primary
else
  lowest_remaining=$secondary
fi

if (( lowest_remaining <= 10 )); then
  color="$RED"
elif (( lowest_remaining <= 30 )); then
  color="$YELLOW"
else
  color="$GREEN"
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  label="5h $(remaining_text "$primary") · W $(remaining_text "$secondary")" \
  label.color="$color" \
  --set "$NAME".popup.primary label="5-hour remaining: $(remaining_text "$primary")" \
  --set "$NAME".popup.primary_reset label="5-hour resets: $primary_reset" \
  --set "$NAME".popup.secondary label="Weekly remaining: $(remaining_text "$secondary")" \
  --set "$NAME".popup.secondary_reset label="Weekly resets: $secondary_reset"
