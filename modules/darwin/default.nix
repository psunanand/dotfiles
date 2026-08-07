{
  imports = [
    ./nix.nix
    ./home-manager.nix
    ./homebrew.nix
    ./macos-defaults.nix
    ./security.nix
    ./mac-app-util.nix
  ];

  programs.zsh = {
    enableBashCompletion = false;
    enableGlobalCompInit = false;
    promptInit = "";
  };
}
