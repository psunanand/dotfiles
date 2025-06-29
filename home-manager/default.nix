{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  packages = with pkgs; [
    # Improved `make` in rust
    just
    # Syntax-highlighting for gitdiff: https://github.com/dandavison/delta
    delta
    fastfetch
  ];
in
{
  imports = [ ./modules ];

  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    packages = packages;
    stateVersion = "25.05";
  };

  # Which module to enable
  # aerospace.enable = true;
  bat.enable = true;
  btop.enable = true;
  eza.enable = true;
  fd.enable = true;
  fzf.enable = true;
  git.enable = true;
  kitty.enable = true;
  neovim.enable = true;
  tmux.enable = true;
  yazi.enable = true;
  zoxide.enable = true;
  zsh.enable = true;
}
