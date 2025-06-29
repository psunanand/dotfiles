{
  description = "mk's nix configurations";

  inputs = {
    # Nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # MacOS system configurations
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Fix Trampoline(Application Launcher) on Mac so that we can launch nix-installed applications from Spotlight
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    let
      forPackages =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
        };

      mkDarwin =
        username: hostname: system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          pkgs = forPackages system;
          specialArgs = {
            inherit
              self
              inputs
              username
              hostname
              system
              ;
          };
          modules = [
            ./nix-darwin
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs username; };
                verbose = true;
                users."${username}".imports = [ ./home-manager ];
              };
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = username;
                enable = true;
                enableRosetta = true; # Enable Rosetta to support Intel binaries
                mutableTaps = false;
                autoMigrate = true;
                extraEnv = {
                  HOMEBREW_NO_ANALYTICS = "1"; # Don't send usage info to Google Analytics
                };
              };
            }
          ];
        };
    in
    {
      # First build darwin flake using:
      # $ sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#<profile>
      # After first build, update darwin flake using:
      # $ sudo darwin-rebuild build --flake .#<profile>
      darwinConfigurations = {
        mksmbp = mkDarwin "psunanand" "mksmbp" "aarch64-darwin";
      };
    };
}
