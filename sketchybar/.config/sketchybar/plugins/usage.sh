#!/usr/bin/env bash

# CPU Usage
CORE_COUNT=$(sysctl -n hw.logicalcpu)
CPU_USAGE=$(ps -A -o %cpu | awk -v cores="$CORE_COUNT" '{s+=$1} END {printf "%.0f", s/cores}')

# RAM Pressure
MEM_STATS=$(vm_stat)
PAGESIZE=$(pagesize)
WIRED=$(echo "$MEM_STATS" | awk '/Pages wired/ {print $4}' | sed 's/\.//')
COMPRESSED=$(echo "$MEM_STATS" | awk '/Pages occupied by compressor/ {print $5}' | sed 's/\.//')
TOTAL_RAM=$(sysctl -n hw.memsize)
RAM_PRESSURE=$(((WIRED + COMPRESSED) * PAGESIZE * 100 / TOTAL_RAM))

# Disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

ICON="􀫥"
LABEL="CPU:${CPU_USAGE}% RAM:${RAM_PRESSURE}% DISK:${DISK_USAGE}"

case "$SENDER" in
"mouse.entered")
  sketchybar --set "$NAME" label.drawing=on icon.padding_right=0
  ;;
"mouse.exited")
  sketchybar --set "$NAME" label.drawing=off icon.padding_right=12
  ;;
*)
  sketchybar --set "$NAME" icon="$ICON" label="$LABEL" icon.padding_right=12
  ;;
esac
