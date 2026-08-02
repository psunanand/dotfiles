{
  description = "MK's macOS dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    felixkratz-homebrew-formulae = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
    nikitabobko-homebrew-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

    # Fix app launching/Spotlight behavior for Nix-installed GUI apps.
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      username = "psunanand";
      hostname = "mksmbp";
      system = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system pkgs;

        specialArgs = {
          inherit inputs self username hostname system;
        };

        modules = [
          ./hosts/mksmbp
        ];
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
