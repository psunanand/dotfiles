# Initialize login-shell tool paths
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
