#!/usr/bin/env bash

STATE_FILE="/tmp/sketchybar_net_state"
[[ ! -f "$STATE_FILE" ]] && echo "0 0 $(date +%s)" >"$STATE_FILE"

# 'route -n get default' to find the active gateway interface
INTERFACE=$(route -n get default 2>/dev/null | awk '/interface: / {print $2}')

if [[ -z "$INTERFACE" ]]; then
  sketchybar --set "$NAME" icon="􀙈" label="Offline"
  exit 0
fi

# Extract hardware type (Wi-Fi, Ethernet, Thunderbolt Bridge, etc.)
HW_TYPE=$(networksetup -listallhardwareports | grep -B 1 "$INTERFACE" | awk -F': ' '/Hardware Port/ {print $2}')

# Fallback for virtual or bridge interfaces
if [[ -z "$HW_TYPE" ]]; then
  [[ "$INTERFACE" == bridge* ]] && HW_TYPE="Bridge" || HW_TYPE="Virtual"
fi

SSID=""
if [[ "$HW_TYPE" == "Wi-Fi" ]]; then
  # Standard macOS utility for SSID retrieval
  SSID=$(ipconfig getsummary "$INTERFACE" | awk -F': ' '/ SSID : / {print $2}' | xargs)
fi

# Calculate the network speed using delta
NET_DATA=$(netstat -ibnI "$INTERFACE" | awk 'NR==2 {print $7, $10}')
CURR_DOWN=${NET_DATA%% *}
CURR_UP=${NET_DATA##* }
CURR_TIME=$(date +%s)

read PREV_DOWN PREV_UP PREV_TIME <"$STATE_FILE"
echo "$CURR_DOWN $CURR_UP $CURR_TIME" >"$STATE_FILE"
INTERVAL=$((CURR_TIME - PREV_TIME))
[[ $INTERVAL -le 0 ]] && INTERVAL=1

BPS_DOWN=$(((CURR_DOWN - PREV_DOWN) / INTERVAL))
BPS_UP=$(((CURR_UP - PREV_UP) / INTERVAL))

format_speed() {
  local bytes=$1
  if ((bytes > 1048576)); then
    printf "%.1f MB/s" "$(echo "$bytes / 1048576" | bc -l)"
  elif ((bytes > 1024)); then
    printf "%.1f KB/s" "$(echo "$bytes / 1024" | bc -l)"
  else
    printf "%d B/s" "$bytes"
  fi
}

DOWN_STR=$(format_speed "$BPS_DOWN")
UP_STR=$(format_speed "$BPS_UP")

if [[ "$HW_TYPE" == "Wi-Fi" ]]; then
  ICON="􀙇"
  LABEL="$SSID"
elif [[ "$HW_TYPE" == *"Ethernet"* || "$HW_TYPE" == *"Thunderbolt"* ]]; then
  ICON="􀤆"
  LABEL="Wired"
else
  ICON="􀁶"
  LABEL="Other"
fi

HOVER_LABEL="$LABEL | ↓$DOWN_STR ↑$UP_STR"

case "$SENDER" in
"mouse.entered")
  sketchybar --set "$NAME" label="$HOVER_LABEL" label.drawing=on icon.padding_right=0
  ;;
"mouse.exited")
  sketchybar --set "$NAME" label.drawing=off icon.padding_right=12
  ;;
*)
  sketchybar --set "$NAME" icon="$ICON" label="$LABEL" icon.padding_right=12
  ;;
esac
