{ username, ... }:

{
  imports = [
    ./packages.nix
    ./files.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };
}
