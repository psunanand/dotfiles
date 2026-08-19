{ username, ... }:

{
  imports = [
    ./packages.nix
    ./programs.nix
    ./files.nix
    ./wallpaper.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };
}
