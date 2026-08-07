{ config, inputs, username, ... }:

{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    user = username;
    package = inputs.brew-src // {
      name = "brew-6.0.15";
      version = "6.0.15";
    };
    enableRosetta = true;
    autoMigrate = true;
    mutableTaps = false;
    enableZshIntegration = false;

    extraEnv = {
      # Don't see the usage info to any analytics
      HOMEBREW_NO_ANALYTICS = "1";
    };

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "FelixKratz/homebrew-formulae" = inputs.felixkratz-homebrew-formulae;
      "nikitabobko/homebrew-tap" = inputs.nikitabobko-homebrew-tap;
    };

    trust = {
      taps = [
        "FelixKratz/formulae"
        "nikitabobko/tap"
      ];
    };
  };

  homebrew = {
    enable = true;

    taps =
      let
        trustedTaps = [
          "FelixKratz/homebrew-formulae"
          "nikitabobko/homebrew-tap"
        ];

        mkTap = name:
          if builtins.elem name trustedTaps then
            {
              inherit name;
              trusted = true;
            }
          else
            name;
      in
      map mkTap (builtins.attrNames config.nix-homebrew.taps);

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "uninstall";
    };

    brews = [
      "llama.cpp"
      "ollama"
      "openjdk"
      "FelixKratz/formulae/borders"
      "FelixKratz/formulae/sketchybar"
    ];
    casks = [
      "aerospace"
      "android-commandlinetools"
      "android-platform-tools"
      "bitwarden"
      "caffeine"
      "db-browser-for-sqlite"
      "discord"
      "font-sauce-code-pro-nerd-font"
      "font-sf-pro"
      "google-drive"
      "hyperkey"
      "kitty"
      "obsidian"
      "raycast"
      "telegram"
      "visual-studio-code"
    ];
  };
}
