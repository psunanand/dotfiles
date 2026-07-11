#!/bin/zsh

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

SET_BOLD=$(tput bold)
SET_GREEN=$(tput setaf 2)
SET_RESET=$(tput sgr0)

echo "${SET_BOLD}Starting System Sync...${SET_RESET}"

execute_step() {
  local script="$SCRIPTS_DIR/$1.sh"
  if [[ -f "$script" ]]; then
    echo "${SET_BOLD}Action:${SET_RESET} Running $1..."
    zsh "$script"
  else
    echo "Error: $script not found."
  fi
}

execute_step "step-bootstrap-shell"
execute_step "step-install-homebrew"
execute_step "step-brew-bundle"
execute_step "apply-dotfiles"
execute_step "step-install-tpm"
execute_step "apply-macos-defaults"
execute_step "step-install-fonts"

echo "${SET_BOLD}${SET_GREEN}Sync Complete.${SET_RESET}"
