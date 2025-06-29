{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.fzf = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Fzf";
    };
  };

  config = lib.mkIf config.fzf.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      # FZF_DEFAULT_COMMAND
      defaultCommand = "${lib.getExe pkgs.fd} --type file --hidden --exclude=.git";
      # FZF_DEFAULT_OPTS
      defaultOptions = [
        "--ansi"
        "--height 60%"
        "--reverse"
        "--bind=ctrl-t:toggle-preview"
      ];
      # FZF_CTRL_T_COMMAND
      fileWidgetCommand = config.programs.fzf.defaultCommand;
      # FZF_CTRL_T_OPTS
      fileWidgetOptions = [
        "--preview 'if [ -d {} ]; then ${lib.getExe pkgs.eza} --tree --color=always {} | head -200; else ${lib.getExe pkgs.bat} -n --color=always --line-range :350 {}; fi'"
      ];
      # FZF_ALT_C_COMMAND
      changeDirWidgetCommand = "${lib.getExe pkgs.fd} --type=d --hidden --strip-cwd-prefix --exclude .git";
      # FZF_ALT_C_OPTS
      changeDirWidgetOptions = [
        "--preview '${lib.getExe pkgs.eza} --tree --color=always {} | head -200'"
      ];
      historyWidgetOptions = [
        "--sort"
        "--exact"
        "--preview 'echo {}'"
        "--preview-window=up:3:hidden:wrap"
        "--bind ctrl-t:toggle-preview"
      ];
    };
  };
}
