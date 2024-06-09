# -----------------
# Zshrc Configuration
# -----------------

# Append "functions" to the fpath
typeset -U fpath=(
    "${ZDOTDIR}/functions"
    $fpath
)


#
# Options
#

setopt AUTO_MENU                        # Show completion menu on tab press
setopt ALWAYS_TO_END                    # Move cursor after completion
setopt COMPLETE_ALIASES                 # Allow autocompletion for aliases
setopt COMPLETE_IN_WORD                 # Allow completion from middle of word
setopt LIST_PACKED                      # Smallest completion menu
setopt AUTO_PARAM_KEYS                  # Intelligent handling of characters
setopt AUTO_PARAM_SLASH                 # after a completion
setopt AUTO_REMOVE_SLASH                # Remove trailing slash when needed

#
# Vi Mode
#

# Activate Vi Mode
bindkey -v

# Load Vi flavor to the cursor
autoload -Uz vicursor; vicursor

# Add "surround" feature to Vi mode
autoload -Uz select-quoted select-bracketed surround
zle -N select-quoted
zle -N select-bracketed
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done
bindkey -a sr change-surround
bindkey -a sd delete-surround
bindkey -a sa add-surround
bindkey -M visual S add-surround

# Add latency for "surround"
export KEYTIMEOUT=20

# Restore some keymaps removed by Vi keybind mode
bindkey -M viins '^k' up-history
bindkey -M viins '^j' down-history
bindkey -M viins '^h' backward-delete-char
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^w' backward-kill-word

# Use Vi-like history search keys
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search

# Use Vi keys in tab complete menu
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Edit line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Jump to any level of parent directories
autoload -Uz bd; bd

# Ctrl-z to jump between fg and bg job
autoload -Uz fancy-ctrl-z; zle -N fancy-ctrl-z
bindkey '^z' fancy-ctrl-z

# Man with colors
autoload -Uz man

# Run programs in background
autoload -Uz background

# Initialize FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# -------------------
# ZIM framework setup
# -------------------

# Module setup before initialized

zstyle ':zim:zmodule' use 'degit'

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Bootstrap zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
    if (( ${+commands[curl]} )); then
        curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    else
        mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    fi
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
    source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules
source ${ZIM_HOME}/init.zsh

# Keymap after intialized

# Double tab to autocomplete the suggestion
bindkey '\t\t' autosuggest-accept

# vim: set filetype=zsh:
