#!/bin/zsh

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
  echo "Action: Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
