{ config
, lib
, pkgs
, ...
}:

{
  home = {
    sessionPath = [
      "$HOME/.local/bin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      FD_OPTIONS = "--hidden --exclude .git --exclude .DS_Store";
    };
  };

  programs = {
    bat = {
      enable = true;

      config = {
        style = "numbers,changes,header";
        theme = "Monokai Extended Bright";
      };
    };

    btop = {
      enable = true;

      settings = {
        vim_keys = true;
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      colors = "auto";
      git = true;
      icons = "auto";
      extraOptions = [ "--group-directories-first" ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = false;
      defaultCommand = "fd --type file --hidden --exclude=.git";
      defaultOptions = [
        "--ansi"
        "--height 60%"
        "--reverse"
        "--bind=ctrl-t:toggle-preview"
      ];

      fileWidget = {
        command = "fd --type file --hidden --exclude=.git";
        options = [
          "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
        ];
      };

      changeDirWidget = {
        command = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
        options = [
          "--preview 'eza --tree --color=always {} | head -200'"
        ];
      };

      historyWidget.options = [
        "--sort"
        "--exact"
        "--preview 'echo {}'"
        "--preview-window=up:3:hidden:wrap"
        "--bind ctrl-t:toggle-preview"
      ];
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = false;
    };

    mise = {
      enable = true;
      enableZshIntegration = false;
      enableMutableConfig = true;
    };

    ripgrep = {
      enable = true;
      arguments = [
        "--glob"
        "!git/*"
        "--glob"
        "!.git/*"
        "--smart-case"
        "--color=always"
        "--hidden"
      ];
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };

    zsh = {
      enable = true;
      dotDir = config.home.homeDirectory;
      autocd = true;

      history = {
        size = 50000;
        save = 50000;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
        append = false;
      };

      setOptions = [
        "AUTO_PUSHD"
        "PUSHD_IGNORE_DUPS"
        "INTERACTIVE_COMMENTS"
        "NO_BEEP"
        "RM_STAR_WAIT"
        "CORRECT"
      ];

      shellAliases = {
        afk = "pmset displaysleepnow";
        cat = "bat --plain --color=always";
        cp = "cp -iv";
        diff = "delta --diff-so-fancy --side-by-side";
        fd = "fd --hidden";
        grep = "grep --color=auto";
        mv = "mv -iv";
        reload = "exec -l /run/current-system/sw/bin/zsh";
        rip = "rip --graveyard $HOME/.local/share/Trash";
        vi = "nvim";
        uistack-reload = "env -u TMUX brew services restart felixkratz/formulae/borders && /opt/homebrew/bin/aerospace reload-config && env -u TMUX brew services restart felixkratz/formulae/sketchybar";
      };

      profileExtra = ''
        # Keep unmanaged toolchains available without putting Homebrew before Nix.
        typeset -U path

        path+=(
          "$HOME/.cargo/bin"
          /opt/homebrew/bin
          /opt/homebrew/sbin
        )
      '';

      initContent = lib.mkMerge [
        (lib.mkOrder 600 ''
          # Must stay before zsh-vi-mode loads so fzf keybindings initialize after it.
          function zvm_after_init() {
            source <(${lib.getExe config.programs.fzf.package} --zsh)
          }

          path+=("$HOME/.maestro/bin")

          zstyle ':completion:*:descriptions' format '[%d]'
          zstyle ':completion:*:history-words' list-colors '=(#b) #(.+)=38;5;06'
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' menu no
          zstyle ':completion:*' verbose yes

          export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
          export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -a1 --color=always $realpath'
          zstyle ':fzf-tab:*' fzf-bindings 'ctrl-y:accept' 'ctrl-t:toggle-all'
          zstyle ':fzf-tab:*' switch-group '<' '>'
          zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
          zstyle ':fzf-tab:*' popup-min-size 30 10
          zstyle ':fzf-tab:*' popup-pad 0 0
          zstyle ':fzf-tab:*' popup-fit-preview yes
          zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
          zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'case "$group" in "modified file") git diff $word | delta ;; "recent commit object name") git show --color=always $word | delta ;; *) git log --color=always $word ;; esac'

          export ZVM_INIT_MODE="sourcing"
          export VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
          export VI_MODE_SET_CURSOR=true
        '')

        (lib.mkOrder 850 ''
          zsh_plugins="$HOME/.zsh_plugins"
          [[ -f "$zsh_plugins.txt" ]] || touch "$zsh_plugins.txt"
          antidote_functions="''${XDG_DATA_HOME:-$HOME/.local/share}/antidote/functions"
          if [[ -d "$antidote_functions" ]]; then
            fpath=("$antidote_functions" $fpath)
            autoload -Uz antidote
            if [[ ! "$zsh_plugins.zsh" -nt "$zsh_plugins.txt" ]]; then
              antidote bundle <"$zsh_plugins.txt" >|"$zsh_plugins.zsh"
            fi
          fi
          [[ -f "$zsh_plugins.zsh" ]] && source "$zsh_plugins.zsh"
          unset antidote_functions

          autoload -U edit-command-line
          zle -N edit-command-line
          bindkey '\C-x\C-e' edit-command-line
          bindkey '^f' vi-forward-word
          bindkey '^ ' autosuggest-accept
        '')

        (lib.mkOrder 950 ''
          if command -v mise >/dev/null 2>&1; then
            eval "$(mise activate zsh)"
          fi
        '')

        (lib.mkOrder 1100 ''
          if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
            export KITTY_SHELL_INTEGRATION="no-rc"
            autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
            kitty-integration
            unfunction kitty-integration
          fi

          homebrew_prefix="/opt/homebrew"
          [[ -r "$homebrew_prefix/etc/profile.d/zsh_command_not_found.sh" ]] && source "$homebrew_prefix/etc/profile.d/zsh_command_not_found.sh"
          unset homebrew_prefix

          [[ -r "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"

          # Added by LM Studio CLI (lms)
          export PATH="$PATH:$HOME/.lmstudio/bin"
          # End of LM Studio CLI section
        '')
      ];
    };
  };
}
