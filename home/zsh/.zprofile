# Keep unmanaged toolchains available without putting Homebrew before Nix.
typeset -U path

path+=(
  "$HOME/.cargo/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
)
