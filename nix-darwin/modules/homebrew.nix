# Use Homebrew to install GUI apps/packages that are not available in nixpkgs
{
  config,
  inputs,
  ...
}:
{
  nix-homebrew = {
    taps = {
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      # Always latest version of Homebrew
      autoUpdate = true;
      # Upgrade outdated apps/packages
      upgrade = true;
      # Uninstall applications not in Brewfile
      cleanup = "zap";
    };

    # Let Homebrew know the casks from nix-homebrew
    # https://github.com/zhaofengli/nix-homebrew/issues/5#issuecomment-1878798641
    taps = builtins.attrNames config.nix-homebrew.taps;
    casks = [
      # Lightweight app to map caplocks to esc and control: https://hyperkey.app
      "hyperkey"
      # Browser that's privacy-focused with many great features: https://zen-browser.app
      "zen"
      # Spotlight replacement with more features and ease to use: https://www.raycast.com
      "raycast"
      # Note-taking app: https://obsidian.md
      "obsidian"
      # Password manager: https://bitwarden.com/
      "bitwarden"
      # Mouse control with keyboard: https://mouseless.click/
      "mouseless"
    ];
  };

  system.defaults = {
    CustomUserPreferences = {

      "com.knollsoft.Hyperkey" = {
        capsLockKeycode = 224;
        capsLockRemapped = 1;
        executeQuickHyperKey = 1;
        hyperFlags = 1966080;
        keyRemap = 1;
        launchOnLogin = 1;
        physicalKeycode = 226;
        quickHyperKeycode = 53;
        SUHasLaunchedBefore = 1;
        "NSStatusItem Preferred Position Item-0" = 5530;
      };

      "com.raycast.macos" = {
        raycastGlobalHotkey = "Command-49";
        raycastPreferredWindowMode = "compact";
      };
    };
  };
}
