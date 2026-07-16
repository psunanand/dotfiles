#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ui.sh"

state_dir="${SKETCHYBAR_STATE_DIR:-${TMPDIR:-/tmp}}"
mkdir -p "$state_dir"
state_file="$state_dir/sketchybar_network_state"
current_time="$(date +%s)"
interface="$(route -n get default 2>/dev/null | awk '/interface: / { print $2; exit }')"

if [[ -z "$interface" ]]; then
  printf 'offline 0 0 %s\n' "$current_time" >"$state_file"
  sketchybar --set "$NAME" icon="􀙈" "icon.color=$THEME_CRITICAL" \
    --set "$NAME.popup.ssid" label="Offline" \
    --set "$NAME.popup.speed" label="↓0 B/s  ↑0 B/s"
  ui_handle_popup_event && exit 0
  exit 0
fi

hardware_type="$(
  networksetup -listallhardwareports 2>/dev/null |
    awk -v interface="$interface" '
      /^Hardware Port:/ { port = substr($0, index($0, ":") + 2) }
      /^Device:/ && $2 == interface { print port; exit }
    '
)"
[[ -z "$hardware_type" && "$interface" == bridge* ]] && hardware_type="Bridge"
[[ -z "$hardware_type" ]] && hardware_type="Virtual"

ssid=""
if [[ "$hardware_type" == "Wi-Fi" ]]; then
  ssid="$(ipconfig getsummary "$interface" 2>/dev/null | awk -F ': ' '/ SSID : / { print $2; exit }')"
fi

network_data="$(netstat -ibnI "$interface" 2>/dev/null | awk 'NR == 2 { print $7, $10; exit }')"
current_down=${network_data%% *}
current_up=${network_data##* }
[[ "$current_down" =~ ^[0-9]+$ ]] || current_down=0
[[ "$current_up" =~ ^[0-9]+$ ]] || current_up=0

previous_interface=none
previous_down=0
previous_up=0
previous_time=$current_time
if [[ -f "$state_file" ]]; then
  read -r previous_interface previous_down previous_up previous_time <"$state_file"
fi
printf '%s %s %s %s\n' "$interface" "$current_down" "$current_up" "$current_time" >"$state_file"

interval=$((current_time - previous_time))
((interval <= 0)) && interval=1
if [[ "$interface" != "$previous_interface" ]]; then
  bytes_down=0
  bytes_up=0
else
  bytes_down=$(((current_down - previous_down) / interval))
  bytes_up=$(((current_up - previous_up) / interval))
  ((bytes_down < 0)) && bytes_down=0
  ((bytes_up < 0)) && bytes_up=0
fi

format_speed() {
  awk -v bytes="$1" 'BEGIN {
    if (bytes >= 1048576) printf "%.1f MB/s", bytes / 1048576
    else if (bytes >= 1024) printf "%.1f KB/s", bytes / 1024
    else printf "%d B/s", bytes
  }'
}

down_label="$(format_speed "$bytes_down")"
up_label="$(format_speed "$bytes_up")"
color="$THEME_NORMAL"

if [[ "$hardware_type" == "Wi-Fi" ]]; then
  icon="􀙇"
  network_label="${ssid:-Wi-Fi}"
elif [[ "$hardware_type" == *Ethernet* || "$hardware_type" == *Thunderbolt* ]]; then
  icon="􀤆"
  network_label="Wired"
else
  icon="􀁶"
  network_label="$hardware_type"
fi

sketchybar --set "$NAME" icon="$icon" "icon.color=$color" \
  --set "$NAME.popup.ssid" "label=$network_label" \
  --set "$NAME.popup.speed" "label=↓$down_label  ↑$up_label"

ui_handle_popup_event && exit 0
