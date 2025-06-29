{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.btop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Btop";
    };
  };

  config = lib.mkIf config.btop.enable {

    # More user-friendly and beautiful UI `htop` replacement: https://github.com/aristocratos/btop
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        rounded_corners = false;
      };
    };
  };
}
