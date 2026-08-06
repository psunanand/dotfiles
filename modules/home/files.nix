{ config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
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

  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/aerospace/.aerospace.toml";

  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfiles}/git/.gitconfig";
}
