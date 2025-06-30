{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.zsh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Zsh";
    };
  };

  config = lib.mkIf config.zsh.enable {

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
    programs.zsh = {
      enable = true;
      defaultKeymap = "viins";
      dotDir = ".config/zsh";
      history = {
        # Append cmd entries from history lists into one history file
        append = true;
        # No duplicates
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        ignoreDups = true;
        # Don't enter cmd entries into history file if 1st char is space
        ignoreSpace = true;
        # Path to history file
        path = "${config.home.homeDirectory}/.local/share/zsh/zsh_history";
        # No. line to save
        save = 50000;
        # No. line to keep
        size = 50000;
        # Share history file between sessions
        share = true;
      };
      # Use other source of completion
      enableCompletion = false;
      autosuggestion = {
        enable = true;
        strategy = [
          "completion"
          "match_prev_cmd"
          "history"
        ];
      };
      localVariables = {
        # Resolve conflicting shortcuts (like Ctrl-R) with fzf: https://github.com/jeffreytse/zsh-vi-mode/issues/24#issuecomment-873029329
        ZVM_INIT_MODE = "sourcing";
        VI_MODE_RESET_PROMPT_ON_MODE_CHANGE = true;
        VI_MODE_SET_CURSOR = true;
      };
      # Use Antidote as zsh plugin manager
      antidote = {
        enable = true;
        plugins = [
          "Aloxaf/fzf-tab" # must be first
          "ohmyzsh/ohmyzsh path:plugins/colored-man-pages"
          "ohmyzsh/ohmyzsh path:plugins/fancy-ctrl-z"
          "jeffreytse/zsh-vi-mode"
          "hlissner/zsh-autopair"
          "MichaelAquilina/zsh-you-should-use"
          "zdharma-continuum/fast-syntax-highlighting" # must be last
        ];
      };

      shellAliases = {
        # Put to sleep when away from keyboard
        afk = "pmset displaysleepnow";
        # Reload shell
        reload = "exec -l $SHELL";
        # Safe rm: https://github.com/nivekuil/rip
        rm = "${lib.getExe pkgs.rm-improved} --graveyard ${config.home.homeDirectory}/.local/share/Trash";
        # Another shortcut for Neovim
        v = lib.getExe config.programs.neovim.finalPackage;
        # Interactive/informative copy
        cp = "cp -iv";
        # Interactive/informative move
        mv = "mv -iv";
        # Replace cat with bat
        cat = "${lib.getExe pkgs.bat} --plain --color=always";
      };
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        username = {
          disabled = false;
          show_always = true;
        };
        hostname = {
          ssh_only = false;
          disabled = false;
        };
      };
    };
  };
}
