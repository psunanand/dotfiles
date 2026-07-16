#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

time_label="$(date +%-I:%M)"
date_label="$(date '+%A, %B %-d')"
time_detail="$(date '+%-I:%M %p')"

sketchybar --set "$NAME" icon="" "label=$time_label" \
  --set "$NAME.popup.date" "label=$date_label" \
  --set "$NAME.popup.time" "label=$time_detail"

ui_handle_popup_event && exit 0
exit 0
