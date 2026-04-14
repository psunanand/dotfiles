#!/usr/bin/env zsh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

LABEL_DATA=$(date +'%a %b %d %-I:%M %p')
sketchybar --set "$NAME" icon= label="$LABEL_DATA"
