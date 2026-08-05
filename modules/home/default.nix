{ username, ... }:

{
  imports = [
    ./packages.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };
}
