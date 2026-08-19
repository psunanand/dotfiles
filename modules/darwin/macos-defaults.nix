{ username, ... }:

let
  homeDirectory = "/Users/${username}";
  screenshotDirectory = "${homeDirectory}/Pictures/Screenshots";
in
{
  system = {
    activationScripts.postActivation.text = ''
      /usr/bin/install -d -o ${username} -g staff -m 0755 "${screenshotDirectory}"
    '';

    defaults = {
      # Dock behavior that supports a keyboard/window-manager workflow.
      dock = {
        tilesize = 42;
        mineffect = "scale";
        autohide = true;
        show-recents = false;
        show-process-indicators = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        mru-spaces = false;
        expose-group-apps = true;
      };

      # Finder defaults for a source-tree-heavy workflow.
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = true;
        _FXSortFoldersFirst = true;
        _FXShowPosixPathInTitle = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
      };

      # Trackpad preferences that are stable enough to declare.
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };

      # Global UI and text-input defaults.
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleEnableMouseSwipeNavigateWithScrolls = false;
        AppleEnableSwipeNavigateWithScrolls = false;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";
        AppleShowScrollBars = "Always";
        AppleWindowTabbingMode = "always";
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSDisableAutomaticTermination = true;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = true;
        "com.apple.mouse.tapBehavior" = 1;
      };

      # Activity Monitor defaults.
      ActivityMonitor = {
        IconType = 5;
        ShowCategory = 101;
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };

      # Screenshot output location and format.
      screencapture = {
        location = screenshotDirectory;
        type = "png";
        disable-shadow = true;
      };

      # Keep each display as a separate Space for Aerospace/SketchyBar.
      spaces = {
        spans-displays = false;
      };

      # Preferences without first-class nix-darwin options.
      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.knollsoft.Hyperkey" = {
          capsLockKeycode = 224;
          capsLockRemapped = 1;
          executeQuickHyperKey = 1;
          hyperFlags = 1966080;
          # Hyperkey is disabled so it does not capture the left Option key,
          # which AeroSpace uses for workspace bindings.
          keyRemap = 2;
          launchOnLogin = 1;
          physicalKeycode = 226;
          quickHyperKeycode = 53;
        };
      };
    };
  };
}
