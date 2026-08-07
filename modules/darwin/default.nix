{ pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./home-manager.nix
    ./homebrew.nix
    ./macos-defaults.nix
    ./security.nix
    ./mac-app-util.nix
  ];

  environment.shells = [ pkgs.zsh ];

  # Keep zsh in the system profile for /etc/shells while Home Manager owns the
  # user's startup files and completion initialization.
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableBashCompletion = false;
    enableGlobalCompInit = false;
    promptInit = "";
  };
}
