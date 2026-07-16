#!/bin/zsh

DOTFILES_DIR="${0:A:h:h}"

if command -v stow &>/dev/null; then
  echo "Action: Restowing configurations..."
  cd "$DOTFILES_DIR"
  stow -vR -d "$DOTFILES_DIR" -t ~ git kitty nvim ripgrep starship tmux zsh aerospace sketchybar borders
else
  echo "Error: GNU Stow not found. Install it via Brewfile first."
fi
