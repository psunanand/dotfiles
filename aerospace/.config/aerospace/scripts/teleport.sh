#!/usr/bin/env bash

set -u

APP_ID=""
WORKSPACE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-id) APP_ID="$2"; shift 2 ;;
    --workspace) WORKSPACE="$2"; shift 2 ;;
    *) echo "Usage: $0 --app-id <bundle-id> [--workspace <N>]"; exit 1 ;;
  esac
done

if [[ -z "$APP_ID" ]]; then
  echo "Error: --app-id is required"
  exit 1
fi

if ! command -v aerospace &>/dev/null; then
  echo "Error: aerospace binary not found"
  exit 1
fi

WINDOW_IDS=$(aerospace list-windows --app-id "$APP_ID" --format "%{window-id}" 2>/dev/null)

if [[ -z "$WINDOW_IDS" ]]; then
  exit 0
fi

while IFS= read -r wid || [[ -n "$wid" ]]; do
  [[ -n "$wid" ]] || continue
  if [[ -n "$WORKSPACE" ]]; then
    aerospace move-node-to-workspace "$WORKSPACE" --window-id "$wid"
  else
    aerospace move-node-to-workspace current --window-id "$wid"
  fi
done <<< "$WINDOW_IDS"
