{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.ripgrep = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Ripgrep";
    };
  };

  config = lib.mkIf config.ripgrep.enable {
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--glob"
        "!git/*"
        "--glob"
        "!.git/*"
        "--smart-case"
        "--color=always"
      ];
    };
  };
}
