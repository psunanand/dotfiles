{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.bat = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Bat";
    };
  };

  config = lib.mkIf config.bat.enable {
    # `cat` clone with syntax highlighting and git integration: https://github.com/sharkdp/bat
    programs.bat = {
      enable = true;
      config = {
        # Show line numbers, Git modifications and file header (but no grid)
        style = "numbers,changes,header";
      };
    };
  };
}
