# Repository Agent Guide

This repo manages MK's macOS dotfiles with Nix flakes, nix-darwin, Home
Manager, and nix-homebrew.

Use this file as guardrails. Use `readme.md` for the fuller bootstrap,
rebuild, rollback, and verification workflow.

## Source Layout

- `.config/`: native XDG config sources linked by Home Manager
- `home/`: home-root dotfile sources linked by Home Manager
- `modules/home/packages.nix`: Nix CLI packages
- `modules/home/programs.nix`: Home Manager program modules
- `modules/home/files.nix`: out-of-store symlink declarations
- `modules/darwin/homebrew.nix`: nix-homebrew taps and Homebrew apps
- `modules/darwin/macos-defaults.nix`: stable macOS defaults
- `hosts/`: host-specific nix-darwin configuration

## Rules

- Edit files in this repo, not generated links under `$HOME`.
- Keep native app configs native when that is clearer than Nix options.
- Do not install the same executable through multiple managers without a
  documented reason.
- Keep secrets, private agent content, credentials, and local backups out of
  this repo.
- Leave ignored runtime and third-party content alone unless explicitly asked.
- Ask before running host-changing commands like `darwin-rebuild switch`,
  Homebrew cleanup, Nix garbage collection, service reloads, macOS defaults, or
  bulk file deletion.

## Checks

Run only checks relevant to the changed files. At minimum:

```sh
git diff --check
```

For Nix changes, prefer:

```sh
nix flake check --option eval-cache false
nix build --option eval-cache false .#darwinConfigurations.mksmbp.system
```

Do not claim activation, cleanup, or rollback succeeded unless the exact command
was run. Do not commit unless the user explicitly asks.
