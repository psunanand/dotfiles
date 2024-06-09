# -----------------
# Zshenv Configuration
# -----------------

# Path and variable settings
: ${XDG_CONFIG_HOME:="$HOME/.config"}

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export EDITOR=nvim
export VISUAL="$EDITOR"

export HISTFILE="$ZDOTDIR/.zhistory"
export HISTSIZE=100000
export SAVEHIST="$HISTSIZE"

