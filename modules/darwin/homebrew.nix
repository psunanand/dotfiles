{ config, inputs, username, ... }:

{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    user = username;
    package = inputs.brew-src // {
      name = "brew-7.0.11";
      version = "7.0.11";
    };
    enableRosetta = true;
    autoMigrate = true;
    mutableTaps = false;
    enableZshIntegration = false;

    extraEnv = {
      # Don't see the usage info to any analytics
      HOMEBREW_NO_ANALYTICS = "1";
      # The pinned Homebrew runtime requires this; nix-homebrew does not export it.
      # The wrapper substitutes @prefix@ for each native/Rosetta installation.
      HOMEBREW_ORIGINAL_BREW_FILE = "@prefix@/bin/brew";
    };

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "raine/homebrew-workmux" = inputs.raine-homebrew-workmux;
      "automic-vault/homebrew-isotopes" = inputs.automic-vault-homebrew-isotopes;
    };

    trust = {
      casks = [
        "automic-vault/isotopes/automic-vault"
      ];
    };
  };

  homebrew = {
    enable = true;

    taps = builtins.attrNames config.nix-homebrew.taps;

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "uninstall";
    };

    brews = [
      "typescript-language-server"
      "llama.cpp"
      "ollama"
      "openjdk"
      "mongosh"
      "raine/workmux/workmux"
    ];
    casks = [
      "omniwm"
      "android-commandlinetools"
      "android-platform-tools"
      "bitwarden"
      "db-browser-for-sqlite"
      "discord"
      "font-jetbrains-mono-nerd-font"
      "font-sauce-code-pro-nerd-font"
      "font-sf-pro"
      "google-drive"
      "hyperkey"
      "kitty"
      "obsidian"
      "raycast"
      "telegram"
      "visual-studio-code"
      "brave-browser"
      "codex"
      {
        name = "automic-vault/isotopes/automic-vault";
        trusted = true;
      }
      "vorssaint"
    ];
  };
}
