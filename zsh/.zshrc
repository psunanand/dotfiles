typeset -U path cdpath fpath manpath
autoload -Uz compinit
compinit
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:history-words' list-colors '=(#b) #(.+)=38;5;06'

# Antidote boostrapping
zsh_plugins="$HOME/.zsh_plugins"
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

fpath=("$(brew --prefix)/opt/antidote/share/antidote/functions" $fpath)
autoload -Uz antidote

if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

# Edit command line in neovim with Ctrl-x Ctrl-e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Zsh History Settings
setopt HIST_FCNTL_LOCK
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

# Fzf-tab styling
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

# Aliases
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

bindkey '^R' fzf-history-widget

# Tool initialization
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
source <(fzf --zsh)

# Kitty integration (If running in Kitty)
if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
  export KITTY_SHELL_INTEGRATION="no-rc"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi
