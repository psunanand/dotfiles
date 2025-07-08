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
          "zsh-users/zsh-completions"
          "MichaelAquilina/zsh-you-should-use"
          "zdharma-continuum/fast-syntax-highlighting" # must be last
        ];
      };

      initContent = ''
        # No completion menu as we have fzf-tab
        zstyle ':completion:*' menu no

        # Use eza to preview directory
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -a1 --color=always $realpath'

        # Bind ctrl-y to accept, and ctrl-t to toggle
        zstyle ':fzf-tab:*' fzf-bindings 'ctrl-y:accept' 'ctrl-t:toggle-all'

        # Switch group using `<` and `>`
        zstyle ':fzf-tab:*' switch-group '<' '>'

        # Pop up window to select in tmux
        zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
        zstyle ':fzf-tab:*' popup-min-size 30 10
        zstyle ':fzf-tab:*' popup-pad 0 0
        zstyle ':fzf-tab:*' popup-fit-preview yes

        # Preview diff files in git
        zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
        zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'case "$group" in "modified file") git diff $word | delta ;; "recent commit object name") git show --color=always $word | delta ;; *) git log --color=always $word ;; esac'
      '';

      shellAliases = {
        # Put to sleep when away from keyboard
        afk = "pmset displaysleepnow";
        # Reload shell
        reload = "exec -l $SHELL";
        # Safe rm: https://github.com/nivekuil/rip
        rip = "${lib.getExe pkgs.rm-improved} --graveyard ${config.home.homeDirectory}/.local/share/Trash";
        # Another shortcut for Neovim
        v = lib.getExe config.programs.neovim.finalPackage;
        # Interactive/informative copy
        cp = "cp -iv";
        # Interactive/informative move
        mv = "mv -iv";
        # Replace cat with bat
        cat = "${lib.getExe pkgs.bat} --plain --color=always";
        # Diff files
        diff = "${lib.getExe pkgs.delta} --diff-so-fancy --side-by-side";
        # Grep with colors
        grep = "grep --color=auto";
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
