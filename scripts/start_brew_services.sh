#!/bin/zsh

SERVICES=("borders" "sketchybar")

echo "--- Initializing UI Stack ---"

for SVC in ${SERVICES[@]}; do
  # Check if the service is already managed by brew services
  if brew services list | grep -qE "^$SVC +started"; then
    echo "✅ $SVC is already running."
  else
    echo "🚀 $SVC is down or unregistered. Initializing..."
    brew services restart $SVC
  fi
done

echo "--- Stack Initialization Complete ---"
