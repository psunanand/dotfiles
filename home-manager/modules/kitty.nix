{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.kitty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Kitty";
    };
  };

  config = lib.mkIf config.kitty.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "SauceCodePro Nerd Font Mono";
        size = 16;
      };
      themeFile = "kanagawa_dragon";
      settings = {
        hide_window_decorations = "yes";
      };
    };
  };
}
