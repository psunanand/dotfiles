#!/bin/zsh

echo "Action: Applying macOS Defaults..."

# ------------------------------------------------------------------------------
# SECURITY & AUTHENTICATION
# ------------------------------------------------------------------------------

# Check if pam_reattach is already configured to avoid duplicate entries
if ! grep -q "pam_reattach.so" /etc/pam.d/sudo_local 2>/dev/null; then
  echo "Security: Enabling TouchID for sudo (including tmux support)..."
  # Creates /etc/pam.d/sudo_local to allow TouchID to persist in multiplexers
  sudo tee /etc/pam.d/sudo_local >/dev/null <<EOF
auth       optional       /opt/homebrew/lib/pam/pam_reattach.so ignore_ssh
auth       sufficient     pam_tid.so
EOF
fi

# ------------------------------------------------------------------------------
# DOCK CONFIGURATION
# ------------------------------------------------------------------------------

# Set icon size on the Dock to be 42 pixels
defaults write com.apple.dock tilesize -int 42

# Change the Dock minimize animation to 'scale' (cleaner than 'genie')
defaults write com.apple.dock mineffect -string "scale"

# Automatically hide the Dock
defaults write com.apple.dock autohide -bool true

# Don't show recently used apps on the Dock
defaults write com.apple.dock show-recents -bool false

# Show light indicator on open applications on the Dock
defaults write com.apple.dock show-process-indicators -bool true

# No Dock opening delay (instant response)
defaults write com.apple.dock autohide-delay -float 0

# Instant Dock opening and closing animation speed
defaults write com.apple.dock autohide-time-modifier -float 0

# Don't reorder Spaces based on most recent use (prevents UI jumping)
defaults write com.apple.dock mru-spaces -bool false

# Group windows by application in Mission Control
defaults write com.apple.dock expose-group-apps -bool true

# ------------------------------------------------------------------------------
# FINDER CONFIGURATION
# ------------------------------------------------------------------------------

# Show all file extensions (essential for power users)
defaults write com.apple.finder AppleShowAllExtensions -bool true

# Show hidden files by default (those starting with '.')
defaults write com.apple.finder AppleShowAllFiles -bool true

# Don't show icons on desktop (keep it minimal)
defaults write com.apple.finder CreateDesktop -bool false

# Show warning when changing the file extension type
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Show full POSIX path in Finder title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Search current folder by default (SCcf scope)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Set Finder view to List view (Nlsv)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Allow quitting Finder via Cmd+Q
defaults write com.apple.finder QuitMenuItem -bool true

# Show path bar at the bottom of Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar with disk space stats
defaults write com.apple.finder ShowStatusBar -bool true

# ------------------------------------------------------------------------------
# TRACKPAD & INPUT
# ------------------------------------------------------------------------------

# Enable tap to click for the current user and the login screen
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain "com.apple.mouse.tapBehavior" -int 1

# Enable three finger drag (highly efficient for window management)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Disable Apple "unnatural" (Natural) scrolling
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool false

# ------------------------------------------------------------------------------
# GLOBAL SYSTEM SETTINGS (NSGlobalDomain)
# ------------------------------------------------------------------------------

# Use 24-hour time format
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

# Disable left/right swipe to navigate backward/forward in browsers
defaults write NSGlobalDomain AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false

# Use dark mode system-wide
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Mode 3 enables full keyboard control (Tab through all UI elements)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use metric system (Centimeters/Celsius)
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -int 1
defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

# Always show scroll bars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Open a tab when opening a new document (vs a new window)
defaults write NSGlobalDomain AppleWindowTabbingMode -string "always"

# Keyboard: Set a blazingly fast repeat rate (15 initial delay, 2 repeat)
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2

# Disable annoying "Smart" features for terminal users
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable window opening/closing animations for perceived speed
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Don't save new documents to iCloud by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Use expanded save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# ------------------------------------------------------------------------------
# ACTIVITY MONITOR & SCREEN CAPTURE
# ------------------------------------------------------------------------------

# Show CPU usage in the Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes hierarchically and sort by CPU usage (descending)
defaults write com.apple.ActivityMonitor ShowCategory -int 101
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# Set Screenshot location and format
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"
defaults write com.apple.screencapture location -string "$SCREENSHOT_DIR"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Don't create .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ------------------------------------------------------------------------------
# CLEANUP & REFRESH
# ------------------------------------------------------------------------------

# Kill affected applications to apply changes immediately
for app in "Dock" "Finder" "SystemUIServer" "Activity Monitor"; do
  killall "$app" >/dev/null 2>&1
done

echo "Success: macOS settings deployed. Terminal-first environment active."
