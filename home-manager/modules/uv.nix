{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.uv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable UV";
    };
  };

  config = lib.mkIf config.uv.enable {
    # Fast Python and project manager: https://docs.astral.sh/uv/
    programs.uv = {
      enable = true;
    };
  };
}
