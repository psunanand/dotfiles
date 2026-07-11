#!/bin/zsh

if [[ "$SHELL" != "/bin/zsh" && "$SHELL" != "/opt/homebrew/bin/zsh" ]]; then
  echo "Action: Setting default shell to zsh..."
  sudo chsh -s /bin/zsh "$USER"
fi
