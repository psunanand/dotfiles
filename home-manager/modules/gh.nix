{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.gh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Github CLI";
    };
  };

  config = lib.mkIf config.gh.enable {
    programs.gh = {
      enable = true;
    };
  };
}
