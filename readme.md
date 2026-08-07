# MK's Dotfiles

macOS dotfiles managed with Nix flakes, nix-darwin, Home Manager, and
nix-homebrew.

This repo is Nix-first, not Nix-only. Nix owns the machine shape, package
inventory, Home Manager links, and stable macOS defaults. Native application
configuration stays in the app's own format when that is easier to read and
edit.

![showcase](./assets/showcase.png)

## What Lives Here

```text
.
|-- flake.nix                 # flake entry point and pinned inputs
|-- hosts/mksmbp/             # host-specific nix-darwin configuration
|-- modules/darwin/           # macOS, Homebrew, Nix, security, HM integration
|-- modules/home/             # Home Manager packages, programs, and links
|-- .config/                  # XDG native config sources
|-- home/                     # home-root dotfile sources
|-- scripts/                  # bootstrap and rebuild helpers
`-- wallpapers/               # wallpapers used by macOS defaults
```

## Ownership Model

Use `modules/home/packages.nix` for CLI packages installed by Nix.

Use `modules/home/programs.nix` when a Home Manager program module owns both
the install/integration and a small, stable configuration. This repo currently
uses it for `mise`.

Use `modules/home/files.nix` for out-of-store symlinks. The source files live
in `.config/` for XDG configs and `home/` for home-root files like `.zshrc`,
`.gitconfig`, and `.aerospace.toml`.

Use `modules/darwin/homebrew.nix` for nix-homebrew taps plus nix-darwin
Homebrew formulae, casks, and Mac App Store entries.

Use `modules/darwin/macos-defaults.nix` for stable macOS defaults and
wallpaper setup. Use `modules/darwin/security.nix` for sudo Touch ID settings.

Keep secrets, credentials, local backups, and private agent material outside
this public repo.

## Bootstrap A New Mac

Clone this repository to the path expected by `modules/home/files.nix`:

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
```

Install Lix when `nix` is missing, then switch the `mksmbp` nix-darwin host:

```sh
./scripts/bootstrap-lix-darwin.sh
```

The script defaults to `mksmbp`. To use another host, pass it as the first
argument:

```sh
./scripts/bootstrap-lix-darwin.sh other-host
```

## Rebuild This Mac

After the first bootstrap, use:

```sh
./scripts/darwin-switch.sh
```

That is the short form for switching the default `mksmbp` host. You can pass a
host name and normal `darwin-rebuild` options:

```sh
./scripts/darwin-switch.sh mksmbp --show-trace
```

The helper uses an installed `darwin-rebuild` when available. If it is missing,
it builds the pinned local darwin system first and then runs the generated
`darwin-rebuild`.

The direct command is also fine:

```sh
sudo -H darwin-rebuild switch --flake .#mksmbp
```

## Update Inputs

Update all pinned flake inputs, then run the default Nix checks:

```sh
./scripts/update-flake.sh
```

Update only Nix packages:

```sh
./scripts/update-flake.sh nixpkgs
```

Update only the Homebrew runtime and pinned taps:

```sh
./scripts/update-flake.sh --homebrew
```

The update script only changes and verifies `flake.lock`. Activate the new
generation separately with `./scripts/darwin-switch.sh`.

## Verify Changes

For Nix changes:

```sh
nix flake check --option eval-cache false
nix build --option eval-cache false .#darwinConfigurations.mksmbp.system
```

For shell and script changes:

```sh
bash -n scripts/*.sh .config/sketchybar/sketchybarrc \
  .config/sketchybar/plugins/*.sh .config/borders/bordersrc
```

Zsh startup files are generated from `modules/home/programs.nix`; use the Nix
checks above for changes there.

For SketchyBar helper changes:

```sh
python3 -m unittest discover -s .config/sketchybar/tests -p 'test_*.py'
```

Always run:

```sh
git diff --check
```

## Roll Back

Roll back to the previous nix-darwin generation with:

```sh
sudo -H darwin-rebuild --rollback
```

Do not run Homebrew cleanup, Nix garbage collection, or broad file deletion as
part of early migration work unless the exact affected items have been reviewed.
