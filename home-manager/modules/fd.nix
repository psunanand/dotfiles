{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.fd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Fd";
    };
  };

  config = lib.mkIf config.fd.enable {

    # Fast and user-friendly alternative to `find`: https://github.com/sharkdp/fd
    programs.fd = {
      enable = true;
    };

  };
}
