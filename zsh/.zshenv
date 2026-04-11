# Ensure Homebrew is ready before anything else
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export EDITOR="nvim"
export VISUAL="nvim"

export FZF_DEFAULT_COMMAND="fd --type file --hidden --exclude=.git"
export FZF_DEFAULT_OPTS="--ansi --height 60% --reverse --bind=ctrl-t:toggle-preview"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
export FZF_CTRL_R_OPTS="--sort --exact --preview 'echo {}' --preview-window=up:3:hidden:wrap --bind ctrl-t:toggle-preview"

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

export HISTFILE="$HOME/.local/share/zsh/zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
[[ -d "$(dirname "$HISTFILE")" ]] || mkdir -p "$(dirname "$HISTFILE")"
