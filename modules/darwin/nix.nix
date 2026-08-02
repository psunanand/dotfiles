{ pkgs, username, ... }:

{
  nix = {
    package = pkgs.lix;

    settings = {
      trusted-users = [ username ];
      experimental-features = "nix-command flakes";
      warn-dirty = false;
      connect-timeout = 5;
      log-lines = 25;
      auto-optimise-store = false;
    };

    gc.automatic = false;
    optimise.automatic = false;
  };
}
