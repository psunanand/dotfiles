#!/usr/bin/env zsh

STATE_FILE="/tmp/sketchybar_net_state"
[[ ! -f "$STATE_FILE" ]] && echo "0 0 $(date +%s)" >"$STATE_FILE"

# Interface & SSID Detection
INTERFACE=$(netstat -rn -f inet | awk '/default/ {print $4; exit}')

if [[ -z "$INTERFACE" ]]; then
  sketchybar --set "$NAME" icon="􀙈" label="Offline"
fi
SSID=$(ipconfig getsummary "$INTERFACE" | awk -F': ' '/ SSID : / {print $2}')

# Speed Calculation using delta interval
# Grab Ibytes (col 7) and Obytes (col 10)
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
    printf "%.1f MB/s" $((bytes / 1048576.0))
  elif ((bytes > 1024)); then
    printf "%.1f KB/s" $((bytes / 1024.0))
  else
    printf "%d B/s" $bytes
  fi
}

DOWN_STR=$(format_speed $BPS_DOWN)
UP_STR=$(format_speed $BPS_UP)

# 3. Dynamic UI Logic
if [[ -n "$SSID" ]]; then
  ICON="􀙇"
  LABEL="$SSID"
else
  ICON="􀤆"
  LABEL="Ethernet"
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
  sketchybar --set "$NAME" icon="$ICON" label="$HOVER_LABEL" icon.padding_right=12
  ;;
esac
