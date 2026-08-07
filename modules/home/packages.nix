{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    just
    delta
    rm-improved

    git
    uv
    go

    btop
    fastfetch

    zsh-completions
    antidote
    tmux
    neovim
  ];
}
