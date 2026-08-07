#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

core_count="$(sysctl -n hw.logicalcpu 2>/dev/null)"
[[ "$core_count" =~ ^[0-9]+$ ]] || core_count=1
cpu_usage="$(ps -A -o %cpu | awk -v cores="$core_count" '{ total += $1 } END { printf "%.0f", total / cores }')"

memory_stats="$(vm_stat)"
page_size="$(pagesize)"
wired="$(awk '/Pages wired/ { gsub(/\./, "", $4); print $4 }' <<<"$memory_stats")"
compressed="$(awk '/Pages occupied by compressor/ { gsub(/\./, "", $5); print $5 }' <<<"$memory_stats")"
total_ram="$(sysctl -n hw.memsize 2>/dev/null)"
wired=${wired:-0}
compressed=${compressed:-0}
page_size=${page_size:-4096}
total_ram=${total_ram:-1}
ram_pressure=$(((wired + compressed) * page_size * 100 / total_ram))

disk_usage="$(df -Pk / | awk 'NR == 2 { gsub(/%/, "", $5); print $5 }')"
disk_usage=${disk_usage:-0}

severity=$cpu_usage
((ram_pressure > severity)) && severity=$ram_pressure
((disk_usage > severity)) && severity=$disk_usage

color="$THEME_NORMAL"
if ((severity >= 90)); then
  color="$THEME_CRITICAL"
elif ((severity >= 70)); then
  color="$THEME_WARNING"
fi

sketchybar --set "$NAME" icon="􀫥" "icon.color=$color" \
  --set "$NAME.popup.cpu" "label=CPU: $cpu_usage%" \
  --set "$NAME.popup.ram" "label=RAM pressure: $ram_pressure%" \
  --set "$NAME.popup.disk" "label=Disk: $disk_usage%"

ui_handle_popup_event && exit 0
