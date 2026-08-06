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

    git
    gh
    uv
    go

    btop
    fastfetch

    zsh
    zsh-completions
    antidote
    tmux
    neovim
  ];

  xdg.dataFile."antidote".source = "${pkgs.antidote}/share/antidote";
}
