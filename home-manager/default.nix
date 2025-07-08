{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  packages = with pkgs; [
    # Improved `make` in rust: https://github.com/casey/just
    just
    # Neofetch-like tool to fetch system info: https://github.com/fastfetch-cli/fastfetch
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
  bat.enable = true;
  btop.enable = true;
  eza.enable = true;
  fd.enable = true;
  fzf.enable = true;
  git.enable = true;
  kitty.enable = true;
  neovim.enable = true;
  ripgrep.enable = true;
  tmux.enable = true;
  yazi.enable = true;
  zoxide.enable = true;
  zsh.enable = true;

}
