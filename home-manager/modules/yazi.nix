{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.yazi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Yazi";
    };
  };

  config = lib.mkIf config.yazi.enable {
    # Blazing fast terminal file manager: https://github.com/sxyazi/yazi
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;

      flavors = {
        kanagawa-dragon = pkgs.fetchFromGitHub {
          owner = "marcosvnmelo";
          repo = "kanagawa-dragon.yazi";
          rev = "49055274ff53772a13a8c092188e4f6d148d1694";
          hash = "sha256-gkzJytN0TVgz94xIY3K08JsOYG/ny63Oj2eyGWiWH4s=";
        };
      };

      theme = {
        flavor.dark = "kanagawa-dragon";
      };

      plugins = with pkgs.yaziPlugins; {
        inherit
          git
          glow
          ;
      };

      initLua = ''
        require("git"):setup()
      '';

      settings = {
        mgr = {
          sort_by = "mtime";
          linemode = "mtime";
          show_hidden = true;
          sort_dirt_first = true;
        };
        plugin = {
          prepend_previewers = [
            {
              name = "*.md";
              run = "glow";
            }
            {
              name = "*.(py|sh|java|yml|go|toml|conf|json|csv)";
              run = "bat";
            }
          ];
        };
      };

    };
  };
}
