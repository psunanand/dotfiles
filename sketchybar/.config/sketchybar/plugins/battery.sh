#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

battery_data="$(pmset -g batt 2>/dev/null)"
percentage="$(grep -Eo '[0-9]+%' <<<"$battery_data" | head -n 1 | tr -d '%')"
[[ "$percentage" =~ ^[0-9]+$ ]] || exit 0

power_source="$(sed -n "s/^Now drawing from '\([^']*\)'.*/\1/p" <<<"$battery_data")"
status="$(sed -n 's/.*%; *\([^;]*\);.*/\1/p' <<<"$battery_data" | head -n 1)"
estimate="$(grep -Eo '([0-9]+:[0-9]+ remaining|\(no estimate\))' <<<"$battery_data" | head -n 1)"
[[ -z "$power_source" ]] && power_source="Unknown power"
[[ -z "$status" ]] && status="Unknown state"

if [[ "$estimate" =~ ^([0-9]+):([0-9]+)\ remaining$ ]]; then
  estimate="${BASH_REMATCH[1]}h ${BASH_REMATCH[2]}m remaining"
else
  estimate="Estimate unavailable"
fi

case "$percentage" in
9[0-9] | 100) icon="" ;;
[6-8][0-9]) icon="" ;;
[3-5][0-9]) icon="" ;;
[1-2][0-9]) icon="" ;;
*) icon="" ;;
esac

color="$THEME_NORMAL"
if [[ "$status" == "charging" ]]; then
  icon="􀢋"
  color="$THEME_HEALTHY"
elif ((percentage <= 20)); then
  color="$THEME_CRITICAL"
elif ((percentage <= 40)); then
  color="$THEME_WARNING"
fi

if [[ "$status" != "Unknown state" ]]; then
  status="$(awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }' <<<"$status")"
fi

sketchybar --set "$NAME" icon="$icon" "icon.color=$color" \
  "label=$percentage%" "label.color=$color" \
  --set "$NAME.popup.power" "label=$power_source · $status" \
  --set "$NAME.popup.estimate" "label=$estimate"

ui_handle_popup_event && exit 0
exit 0
