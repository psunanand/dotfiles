#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"

command -v aerospace >/dev/null 2>&1 || exit 0

focused_workspace="${FOCUSED_WORKSPACE:-}"
if [[ -z "$focused_workspace" ]]; then
  focused_workspace="$(aerospace list-workspaces --focused 2>/dev/null)"
fi

workspace_monitors="$(
  aerospace list-workspaces --monitor all \
    --format '%{workspace} %{monitor-appkit-nsscreen-screens-id}' 2>/dev/null
)"
all_windows="$(
  aerospace list-windows --monitor all \
    --format $'%{workspace}\t%{app-name}' 2>/dev/null
)"

state_dir="${SKETCHYBAR_STATE_DIR:-${TMPDIR:-/tmp}}"
mkdir -p "$state_dir"
printf '%s\n' "$focused_workspace" >"$state_dir/sketchybar_focused_workspace"

updates=()

for workspace in {1..7}; do
  monitor="$(awk -v workspace="$workspace" '$1 == workspace { print $2; exit }' <<<"$workspace_monitors")"
  [[ -z "$monitor" ]] && monitor=1

  apps=()
  while IFS= read -r app; do
    [[ -n "$app" ]] && apps+=("$app")
  done < <(
    awk -F '\t' -v workspace="$workspace" \
      '$1 == workspace && !seen[$2]++ { print $2 }' <<<"$all_windows"
  )

  app_count=${#apps[@]}
  updates+=(--set "space.$workspace" "display=$monitor")

  if [[ "$workspace" == "$focused_workspace" ]]; then
    updates+=(
      drawing=on
      "label=$workspace"
      "label.color=$BAR_COLOR"
      background.drawing=on
      "background.color=$THEME_FOCUSED"
    )
  elif ((app_count > 0)); then
    updates+=(
      drawing=on
      "label=$workspace"
      "label.color=$THEME_MUTED"
      background.drawing=on
      "background.color=$THEME_TRANSPARENT"
    )
  else
    updates+=(drawing=off)
  fi

  for index in 1 2 3; do
    updates+=(
      --set "space.$workspace.app$index"
      "display=$monitor"
      drawing=off
    )
  done

  icon_count=$app_count
  ((icon_count > 2)) && icon_count=2
  for ((index = 0; index < icon_count; index++)); do
    item_index=$((index + 1))
    updates+=(
      --set "space.$workspace.app$item_index"
      "display=$monitor"
      drawing=on
      icon.background.drawing=on
      "icon.background.image=app.${apps[$index]}"
      icon.background.image.scale=0.62
      label.drawing=off
    )
  done

  if ((app_count > 2)); then
    updates+=(
      --set "space.$workspace.app3"
      "display=$monitor"
      drawing=on
      icon.background.drawing=off
      label.drawing=on
      "label=+$((app_count - 2))"
      "label.color=$THEME_MUTED"
    )
  fi
done

sketchybar "${updates[@]}"
