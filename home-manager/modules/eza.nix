{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.eza = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Eza";
    };
  };

  config = lib.mkIf config.eza.enable {
    # Modern replacement for `ls`: https://github.com/eza-community/eza
    programs.eza = {
      enable = true;
      git = true;
      enableZshIntegration = true;
      colors = "auto";
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--color=always"
      ];
    };
  };
}
