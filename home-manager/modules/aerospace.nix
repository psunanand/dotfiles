{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.aerospace = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Aerospace";
    };
  };

  config = lib.mkIf config.aerospace.enable {
    # Tiling Window manager for MacOS: https://github.com/nikitabobko/AeroSpace
    programs.aerospace = {
      enable = true;
      userSettings = {
        start-at-login = true;
      };
    };
  };
}
