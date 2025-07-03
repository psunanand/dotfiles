{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.tmux = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Tmux";
    };
  };

  config = lib.mkIf config.tmux.enable {
    programs.tmux = {
      enable = true;
      mouse = true;
      clock24 = true;
      prefix = "C-a";
      keyMode = "vi";
      escapeTime = 0;
      historyLimit = 1000;
      baseIndex = 1;
      terminal = "screen-256color";
      shell = "${pkgs.zsh}/bin/zsh";
      extraConfig = ''
        bind C-a send-prefix

        set -g default-command "$SHELL"

        set-option -g set-titles on 
        set-option -g set-titles-string "#{pane_title}" 

        set-option -s focus-events on
        set-option -s extended-keys on

        # Renumber the tab after closing
        set -g renumber-windows on 

        # Support true color
        set-option -a terminal-features 'screen-256color:RGB'

        # Reduce Vi <esc> delay
        set-option -sg escape-time 0

        # Bring back <Ctrl>+l to clear the screen with prefix
        bind C-l send-keys 'C-l'


        # Make the status bar on the top
        set-option -g status-position top

        # Reload the tmux config
        bind r source-file $HOME/.config/tmux/tmux.conf \; display "Reloaded tmux configuration"

        # Clear screen with prefix + l
        bind C-l send-keys 'C-l'

        # Split window to panes with <leader> like in nvim using `v` and `s`
        unbind v
        unbind s
        unbind %
        unbind '"'
        bind v split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"

        # Move between panes with hjkl
        bind -N "Select pane to the left of the active pane" h select-pane -L
        bind -N "Select pane below the active pane" j select-pane -D
        bind -N "Select pane above the active pane" k select-pane -U
        bind -N "Select pane to the right of the active pane" l select-pane -R

        # Resize the pane with the arrow keys
        bind -r -N "Resize the pane left by 5" \
          Left resize-pane -L 5
        bind -r -N "Resize the pane down by 5" \
          Down resize-pane -D 5
        bind -r -N "Resize the pane up by 5" \
          Up resize-pane -U 5
        bind -r -N "Resize the pane right by 5" \
          Right resize-pane -R 5

        # Create tabs
        unbind c
        bind t new-window -c "#{pane_current_path}"

        # Enable Yazi's image preview in tmux
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM
      '';
      plugins = with pkgs.tmuxPlugins; [
        yank
        vim-tmux-navigator
        extrakto # activate with prefix + <tab>
        {
          # https://github.com/Nybkox/tmux-kanagawa/tree/master
          plugin = kanagawa;
          extraConfig = ''
            set -g @kanagawa-theme "dragon"
            set -g @kanagawa-show-powerline true
            set -g @kanagawa-show-left-icon hostname
            set -g @kanagawa-plugins "cpu-usage ram-usage"
            set -g @kanagawa-cpu-display-load true
            set -g @kanagawa-ignore-window-colors true
          '';
        }
      ];
    };
  };
}
