{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.zoxide = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Zoxide";
    };
  };

  config = lib.mkIf config.zoxide.enable {
    # Smarter `cd`: https://github.com/ajeetdsouza/zoxide
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}
