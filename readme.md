# MK's dotfiles (macOS)

![showcase](./assets/showcase.png)

## System setup

Bootstrap a new Mac with Lix and the nix-darwin configuration:

```sh
./scripts/bootstrap-lix-darwin.sh
```

After the first setup, rebuild from this repository with:

```sh
./scripts/darwin-switch.sh
```

Both scripts default to the `mksmbp` host. Pass another host name as the first
argument if needed.

Rollback to the previous nix-darwin generation with:

```sh
sudo -H darwin-rebuild --rollback
```

Homebrew is managed through nix-darwin and nix-homebrew. Native application
configs live in `.config/` and home-root dotfiles live in `home/`, with Home
Manager creating the final links.
