{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  xdg.dataFile."antidote".source = "${pkgs.antidote}/share/antidote";

  xdg.configFile."ripgrep".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/ripgrep/.config/ripgrep";

  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/starship/.config/starship.toml";

  xdg.configFile."kitty".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/kitty/.config/kitty";

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/nvim/.config/nvim";

  xdg.configFile."borders".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/borders/.config/borders";

  xdg.configFile."sketchybar".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/sketchybar/.config/sketchybar";

  xdg.configFile."tmux".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/tmux/.config/tmux";

  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/aerospace/.aerospace.toml";

  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/git/.gitconfig";

  home.file.".zprofile".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/zsh/.zprofile";

  home.file.".zshenv".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/zsh/.zshenv";

  home.file.".zshrc".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/zsh/.zshrc";

  home.file.".zsh_plugins.txt".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/zsh/.zsh_plugins.txt";
}
