# Make Neovim configuration agnostic to Nix for portability
# Thanks to https://github.com/LitRidl/EdenVim?tab=readme-ov-file#-using-nix-or-nixos
{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.neovim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Neovim";
    };
  };

  config = lib.mkIf config.neovim.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;

      # Required but isolated in Neovim environment
      withPython3 = true;
      withNodeJs = true;
      withRuby = true;

      plugins = with pkgs; [
        vimPlugins.nvim-treesitter.withAllGrammars
      ];

      extraPackages = with pkgs; [
        # LSP servers
        bash-language-server
        lua-language-server
        nixd

        # Formatters
        stylua
        nixfmt-rfc-style
        prettierd

      ];
    };

    # Required packages for Neovim activation below
    home.extraActivationPath = with pkgs; [
      git
      gcc
      curl
      neovim
    ];

    # Ensure whenever we run `home-manager switch`, Neovim will install all plugins that are pinned in `lazy-lock.json`
    home.activation.updateNeovimState = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''run --quiet nvim --headless '+Lazy! restore' +qa'';

    # Symlink with Neovim lua configs
    # Must be an absolute path
    xdg.configFile."nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home-manager/modules/.config/nvim";
  };
}
