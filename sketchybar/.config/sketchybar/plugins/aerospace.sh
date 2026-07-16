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

  if [[ "$workspace" == "$focused_workspace" ]]; then
    updates+=(
      --set "space.$workspace"
      "display=$monitor"
      drawing=on
      "label=$workspace"
      "label.color=$THEME_FOCUSED"
      --set "space.$workspace.group"
      background.drawing=on
      "background.color=$THEME_POPUP"
      background.border_width=1
      "background.border_color=$THEME_FOCUSED"
      --set "space.$workspace.gap"
      "display=$monitor"
      drawing=on
    )
  elif ((app_count > 0)); then
    updates+=(
      --set "space.$workspace"
      "display=$monitor"
      drawing=on
      "label=$workspace"
      "label.color=$THEME_MUTED"
      --set "space.$workspace.group"
      background.drawing=on
      "background.color=$THEME_POPUP"
      background.border_width=0
      "background.border_color=$THEME_TRANSPARENT"
      --set "space.$workspace.gap"
      "display=$monitor"
      drawing=on
    )
  else
    updates+=(
      --set "space.$workspace"
      "display=$monitor"
      drawing=off
      --set "space.$workspace.group"
      background.drawing=off
      --set "space.$workspace.gap"
      "display=$monitor"
      drawing=off
    )
  fi

  for index in 1 2 3 4; do
    updates+=(
      --set "space.$workspace.app$index"
      "display=$monitor"
      drawing=off
      icon.background.drawing=off
      label.drawing=off
    )
  done

  icon_count=$app_count
  ((icon_count > 3)) && icon_count=3
  for ((index = 0; index < icon_count; index++)); do
    item_index=$((index + 1))
    updates+=(
      --set "space.$workspace.app$item_index"
      "display=$monitor"
      drawing=on
      icon.background.drawing=on
      "icon.background.image=app.${apps[$index]}"
      icon.background.image.scale=0.58
      label.drawing=off
    )
  done

  if ((app_count > 3)); then
    updates+=(
      --set "space.$workspace.app4"
      "display=$monitor"
      drawing=on
      icon.background.drawing=off
      label.drawing=on
      "label=+$((app_count - 3))"
      "label.color=$THEME_MUTED"
    )
  fi
done

sketchybar "${updates[@]}"
