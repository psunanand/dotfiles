{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  xdg.dataFile."antidote".source = "${pkgs.antidote}/share/antidote";

  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/starship.toml";

  xdg.configFile."kitty".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/kitty";

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/nvim";

  xdg.configFile."borders".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/borders";

  xdg.configFile."sketchybar".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/sketchybar";

  xdg.configFile."tmux".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/tmux";

  xdg.configFile."git/hooks/commit-msg".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/git/hooks/commit-msg";

  xdg.configFile."git/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/git/config";

  xdg.configFile."git/ignore".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/git/ignore";

  xdg.configFile."git/message".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/.config/git/message";

  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/home/aerospace/.aerospace.toml";

  home.file.".ssh/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/home/ssh/config";

  home.file.".zsh_plugins.txt".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/home/zsh/.zsh_plugins.txt";
}
