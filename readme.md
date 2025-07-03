**MacOS:**

```bash
  # Install Xcode
  xcode-select --install

  # Install Nix (Say "No" to install `Determinate`)
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  # Activate Nix shell
  nix-shell -p git just

  # Clone this dotfiles repository
  git clone https://github.com/psunanand/dotfiles.git

  # Install nix-darwin using <profile> and apply its configurations/settings
  just install-darwin <profile>
```
