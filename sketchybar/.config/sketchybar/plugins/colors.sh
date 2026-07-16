#!/usr/bin/env bash

# --- EVERFOREST PALETTE (HARD) ---
# Format: 0xff + hex_code (Sketchybar requires the alpha channel)

export USER="${USER:-$(id -un)}"

export BAR_COLOR=0xff2b3339
export ITEM_BG_COLOR=0xff3a4248
export ACCENT_COLOR=0xffa7c080 # Everforest Green

# Functional Colors
export WHITE=0xffd3c6aa
export GREY=0xff859289
export BLACK=0xff1e2326

# Status Colors
export RED=0xffe67e80
export ORANGE=0xffe69875
export YELLOW=0xffdbbc7f
export GREEN=0xffa7c080
export BLUE=0xff7fbbb3
export PURPLE=0xffd699b6
export CYAN=0xff83c092

# Component Mapping
export ICON_COLOR=$WHITE
export LABEL_COLOR=$WHITE
export POPUP_BACKGROUND_COLOR=$ITEM_BG_COLOR
export POPUP_BORDER_COLOR=$GREY

# Semantic UI colors
export THEME_NORMAL=$WHITE
export THEME_MUTED=$GREY
export THEME_HOVER=0xff465159
export THEME_FOCUSED=$GREEN
export THEME_HEALTHY=$GREEN
export THEME_WARNING=$YELLOW
export THEME_CRITICAL=$RED
export THEME_POPUP=$ITEM_BG_COLOR
export THEME_POPUP_BORDER=$GREY
export THEME_TRANSPARENT=0x00000000
