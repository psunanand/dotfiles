{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    eza
    fd
    ripgrep
    fzf
    zoxide
    starship
    just
    delta
    rm-improved
  ];
}
