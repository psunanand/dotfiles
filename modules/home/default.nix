{ pkgs, username, ... }:

{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
    packages = [ ];
  };
}
