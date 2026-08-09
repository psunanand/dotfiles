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

    fastfetch

    zsh-completions
    antidote
    tmux
    neovim
  ];
}
