# Must stay first to avoid keybinding conflict between zsh-vi-mode and fzf
function zvm_after_init() {
  source <(fzf --zsh)
}

# PATH & COMPLETION INIT
typeset -U path cdpath fpath manpath
autoload -Uz compinit
compinit

# COMPLETION STYLING
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:history-words' list-colors '=(#b) #(.+)=38;5;06'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^f' vi-forward-word
bindkey '^ ' autosuggest-accept

# FZF-TAB
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -a1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-y:accept' 'ctrl-t:toggle-all'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 30 10
zstyle ':fzf-tab:*' popup-pad 0 0
zstyle ':fzf-tab:*' popup-fit-preview yes
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'case "$group" in "modified file") git diff $word | delta ;; "recent commit object name") git show --color=always $word | delta ;; *) git log --color=always $word ;; esac'

# HISTORY SETTINGS
setopt HIST_FCNTL_LOCK
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt EXTENDED_HISTORY
unsetopt APPEND_HISTORY

# INTERACTIVE SHELL BEHAVIOR
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt RM_STAR_WAIT
setopt CORRECT

# ANTIDOTE BOOTSTRAPPING
zsh_plugins="$HOME/.zsh_plugins"
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt
fpath=("$(brew --prefix)/opt/antidote/share/antidote/functions" $fpath)
autoload -Uz antidote
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi
[[ -f ${zsh_plugins}.zsh ]] && source ${zsh_plugins}.zsh

# VI MODE
export ZVM_INIT_MODE="sourcing"
export VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
export VI_MODE_SET_CURSOR=true
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# ALIASES
alias afk='pmset displaysleepnow'
alias cat='bat --plain --color=always'
alias cp='cp -iv'
alias diff='delta --diff-so-fancy --side-by-side'
alias eza='eza --icons auto --color auto --git --group-directories-first'
alias ls='eza'
alias ll='eza -l'
alias la='eza -a'
alias lla='eza -la'
alias lt='eza --tree'
alias fd='fd --hidden'
alias grep='grep --color=auto'
alias mv='mv -iv'
alias reload='exec -l $SHELL'
alias rip='rip --graveyard $HOME/.local/share/Trash'
alias vi='nvim'
alias uistack-reload='brew services restart borders && aerospace reload-config && brew services restart sketchybar'

# TOOL INITIALIZATION
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"

# CONDITIONAL INTEGRATIONS
if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
  export KITTY_SHELL_INTEGRATION="no-rc"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi
source "$(brew --prefix)/etc/profile.d/zsh_command_not_found.sh" 2>/dev/null

# TOOL EXPORTS
export BAT_STYLE="numbers,changes,header"
export BAT_THEME="Monokai Extended Bright"
export FD_OPTIONS="--hidden --exclude .git --exclude .DS_Store"

# LOCAL COMPLETIONS
source "/Users/psunanand/.openclaw/completions/openclaw.zsh"
export PATH=$PATH:$HOME/.maestro/bin
