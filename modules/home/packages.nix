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
    docker
    docker-buildx
    docker-compose
    mas

    btop
    fastfetch

    zsh-completions
    antidote
    tmux
    neovim
  ];
}
