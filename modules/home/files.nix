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

  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/home/aerospace/.aerospace.toml";

  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/home/git/.gitconfig";

  home.file.".gitignore_global".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/home/git/.gitignore_global";

  home.file.".gitmessage".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/home/git/.gitmessage";

  home.file.".ssh/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/home/ssh/config";

  home.file.".zsh_plugins.txt".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/home/zsh/.zsh_plugins.txt";
}
