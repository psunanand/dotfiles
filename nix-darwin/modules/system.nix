# MacOS System-wide configurations via Nix-darwin
# Run `$ man configuration.nix` for the exhaustive list of options for MacOS or
# https://nix-darwin.github.io/nix-darwin/manual/ for all the configuration options
{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
let
  homeDirectory = "/Users/${username}";
  screencaptureDirectory = "${homeDirectory}/Screenshots";
in
{
  # Required to set up for Home-manager: https://github.com/nix-community/home-manager/issues/4026
  users.users."${username}" = {
    home = homeDirectory;
  };

  # Enable touchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
  environment = {
    shells = [ pkgs.zsh ];

    # Set up pam-reattach to enable touchID for sudo inside tmux
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';
  };

  system = {
    # Required to specify for MacOS system-level options and Homebrew
    primaryUser = username;

    # Set Git commit hash for darwin-version.
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # This Activation script is executed every time after rebooting the system or running `darwin-rebuild`
    activationScripts.postActivation.text = ''
      # Reload all the settings so that we don't need to re-login to see the effect of the change
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      if [ ! -d "${screencaptureDirectory}" ]; then
          mkdir -pv "${screencaptureDirectory}"
      fi
    '';

    defaults = {
      #Customize Dock
      dock = {
        # Set icon size on the Dock to be 42 pixels
        tilesize = 42;
        # Change the Dock minimize animation
        mineffect = "scale";
        # Automatically hide the Dock
        autohide = true;
        # Don't show recently used apps on the Dock
        show-recents = false;
        # Show light indicator on open applications on the Dock
        show-process-indicators = true;
        # No Dock openning delay
        autohide-delay = 0.0;
        # Instant Dock openning and closing animation
        autohide-time-modifier = 0.0;
        # Don't reorder Spaces based on most recent use
        mru-spaces = false;
        # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
        expose-group-apps = true;
        # Apps on Dock
        persistent-apps = [
          "/Applications/Raycast.app"
          "/Applications/Zen.app"
          "/Applications/Obsidian.app"
        ];
      };

      spaces = {
        # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
        spans-displays = true;
      };

      # Customize Finder
      finder = {
        # Show all file extensions
        AppleShowAllExtensions = true;
        # Show hidden files
        AppleShowAllFiles = true;
        # Don't show icons on desktop
        CreateDesktop = false;
        # Show warning when changing the file extension type
        FXEnableExtensionChangeWarning = true;
        # Keep folders on top when sorting by name
        _FXSortFoldersFirst = true;
        # Show full path on Finder title
        _FXShowPosixPathInTitle = true;
        # Search current folder by default
        FXDefaultSearchScope = "SCcf";
        # Set Finder view = List view
        FXPreferredViewStyle = "Nlsv";
        # Allow quit on Finder
        QuitMenuItem = true;
        # Show path to file
        ShowPathbar = true;
        # Show status with disk space stats
        ShowStatusBar = true;

      };

      # Customize Trackpad
      trackpad = {
        # Enable tap to click
        Clicking = true;
        # Enable two finger right click
        TrackpadRightClick = true;
        # Enable three finger drag
        TrackpadThreeFingerDrag = true;
      };

      # Customize Menu bar
      controlcenter = {
        # Show battery %
        BatteryShowPercentage = true;
        # Don't Show a bluetooth control
        Bluetooth = false;
        # Dont' Show screen brightness control
        Display = false;
        # Show focus mode
        FocusModes = true;
        # Don't show sound control
        Sound = false;
      };

      # Customize MacOS
      NSGlobalDomain = {
        # Use 24-hour time
        AppleICUForce24HourTime = true;
        # Disable left/right swipe to navigate backward/forward
        AppleEnableMouseSwipeNavigateWithScrolls = false;
        AppleEnableSwipeNavigateWithScrolls = false;
        # Use dark mode
        AppleInterfaceStyle = "Dark";
        # Mode 3 enables full keyboard control.
        AppleKeyboardUIMode = 3;
        # Use metric system
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        # Show file extensions in Finder
        AppleShowAllExtensions = true;
        # Show hidden files
        AppleShowAllFiles = true;
        # Always show scroll bar
        AppleShowScrollBars = "Always";
        # Use celsius
        AppleTemperatureUnit = "Celsius";
        # Open a tab when openning a new document
        AppleWindowTabbingMode = "always";
        # Take 15 (225 ms) to press hold the key before it starts repeating
        InitialKeyRepeat = 15;
        # Take 2 (30 ms) to repeat once it starts
        KeyRepeat = 2;
        # Disable automatic capitalization
        NSAutomaticCapitalizationEnabled = false;
        # Disable dash substitution
        NSAutomaticDashSubstitutionEnabled = false;
        # Disable inline predictive text
        NSAutomaticInlinePredictionEnabled = false;
        # Disable period substituion
        NSAutomaticPeriodSubstitutionEnabled = false;
        # Disable quote substitution
        NSAutomaticQuoteSubstitutionEnabled = false;
        # Disable spell correction
        NSAutomaticSpellingCorrectionEnabled = false;
        # Disable animating opening/closing windows
        NSAutomaticWindowAnimationsEnabled = false;
        # Disable automatic termination of inactive apps
        NSDisableAutomaticTermination = true;
        # Disable save new documents to iCloud
        NSDocumentSaveNewDocumentsToCloud = false;
        # Use expanded save by default
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        # Don't hide menu bar
        _HIHideMenuBar = false;
        # Tap on trackpad to click
        "com.apple.mouse.tapBehavior" = 1;
        # Disable Apple "unnatural" scrolling
        "com.apple.swipescrolldirection" = false;
      };

      # Auto-update MacOS
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      ActivityMonitor = {
        # Show CPU usage on Dock
        IconType = 5;
        # Show the main window when launching Activity Monitor
        OpenMainWindow = true;
        # Show all processes hierarchally in Activity Monitor
        ShowCategory = 101;
        # Sort by CPU usage in Activity Monitor
        SortColumn = "CPUUsage";
        # Sort by descending
        SortDirection = 0;
      };

      loginwindow = {
        # Disable guest users
        GuestEnabled = false;
        # Show full name on login window
        DisableConsoleAccess = true;
      };

      screencapture = {
        show-thumbnail = true;
        location = "${screencaptureDirectory}";
        target = "file";
        type = "png";
      };

      # Customize settings that nix-darwin doesn't support
      # See: https://macos-defaults.com for an incomplete list of MacOS `defaults`
      # Otherwise run `$ defaults read` to see all custom options
      CustomUserPreferences = {

        "com.apple.screencapture" = {
          location = "${screencaptureDirectory}";
          type = "png";
          disable-shadow = true;
        };

        "com.apple.desktopservices" = {
          # Don't create .DS_Store files on either network or USB
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };

    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    # Nix-darwin pinned version for for backwards compatibility,
    # Check the changelog before changing!
    # $ darwin-rebuild changelog
    stateVersion = 6;
  };

  # Fonts
  fonts.packages = [ pkgs.nerd-fonts.sauce-code-pro ];

}
