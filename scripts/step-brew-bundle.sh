#!/bin/zsh

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
BREWFILE_PATH="$DOTFILES_DIR/brew/Brewfile"

if [[ -f "$BREWFILE_PATH" ]]; then
  echo "Action: Syncing Brewfile (this may take a while)..."
  brew bundle --file="$BREWFILE_PATH" --cleanup
else
  echo "Error: Brewfile not found at $BREWFILE_PATH. Skipping software sync."
fi
