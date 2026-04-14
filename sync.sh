#!/bin/zsh

# This finds the directory where sync.sh is located,
# regardless of whether it is
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BREWFILE_PATH="$DOTFILES_DIR/brew/Brewfile"
MACOS_CONFIG_SCRIPT="$DOTFILES_DIR/macos_setup.sh"

# Set colors for verbose output
SET_BOLD=$(tput bold)
SET_GREEN=$(tput setaf 2)
SET_RESET=$(tput sgr0)

echo "${SET_BOLD}Starting System Sync...${SET_RESET}"

# ------------------------------------------------------------------------------
# 0. BOOTSTRAP: SHELL CHECK
# ------------------------------------------------------------------------------
if [[ "$SHELL" != "/bin/zsh" && "$SHELL" != "/opt/homebrew/bin/zsh" ]]; then
  echo "Action: Setting default shell to zsh..."
  sudo chsh -s /bin/zsh "$USER"
fi

# ------------------------------------------------------------------------------
# 1. HOMEBREW INSTALLATION / INITIALIZATION
# ------------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  echo "${SET_BOLD}Action:${SET_RESET} Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Ensure brew is in the current shell session path for Apple Silicon Macs
  if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "${SET_GREEN}✓${SET_RESET} Homebrew is already installed. Updating..."
  brew update
fi

# ------------------------------------------------------------------------------
# 2. SOFTWARE PROVISIONING (Brewfile)
# ------------------------------------------------------------------------------
if [[ -f "$BREWFILE_PATH" ]]; then
  echo "${SET_BOLD}Action:${SET_RESET} Syncing Brewfile (this may take a while)..."
  # --cleanup ensures apps NOT in Brewfile are removed (replaces Nix 'zap')
  brew bundle --file="$BREWFILE_PATH" --cleanup
else
  echo "Error: Brewfile not found at $BREWFILE_PATH. Skipping software sync."
fi

# ------------------------------------------------------------------------------
# 3. DOTFILE MANAGEMENT (GNU Stow)
# ------------------------------------------------------------------------------
if command -v stow &>/dev/null; then
  echo "${SET_BOLD}Action:${SET_RESET} Restowing configurations..."
  cd "$DOTFILES_DIR"

  # Restow standard packages
  stow -vR -d "$DOTFILES_DIR" -t ~ git kitty nvim ripgrep starship tmux zsh aerospace sketchybar borders
else
  echo "Error: GNU Stow not found. Install it via Brewfile first."
fi

# ------------------------------------------------------------------------------
# 4. TMUX PLUGIN MANAGER (TPM)
# ------------------------------------------------------------------------------
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
  echo "Action: Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# ------------------------------------------------------------------------------
# 5. MACOS SYSTEM DEFAULTS
# ------------------------------------------------------------------------------
if [[ -f "$MACOS_CONFIG_SCRIPT" ]]; then
  echo "${SET_BOLD}Action:${SET_RESET} Running macOS system configuration..."
  chmod +x "$MACOS_CONFIG_SCRIPT"
  zsh "$MACOS_CONFIG_SCRIPT"
else
  echo "Error: macos_setup.sh not found at $MACOS_CONFIG_SCRIPT."
fi

# ------------------------------------------------------------------------------
# 6. MISCELLEANEOUS
# ------------------------------------------------------------------------------

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.47/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

echo "${SET_BOLD}${SET_GREEN}Sync Complete.${SET_RESET}"
