{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.go = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GoLang";
    };
  };

  config = lib.mkIf config.go.enable {
    programs.go = {
      enable = true;
      goPath = "go";
      goBin = "go/bin";
    };
    home.sessionPath = [
      "$HOME/go/bin"
    ];
  };
}
