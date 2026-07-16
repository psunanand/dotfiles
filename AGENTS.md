# Repository agent guide

This repository contains macOS dotfiles installed with GNU Stow, with system
packages managed by Homebrew through `brew/Brewfile`.

## Work in the source tree

- Treat the tracked package directories as the source of truth. Edit files in
  this repository, not the generated symlinks or copies under `$HOME`.
- Leave ignored runtime and third-party content, including `tmux/.config/tmux/plugins/`, unchanged unless the task explicitly targets it.
- Preserve the existing language boundaries: Zsh for `sync.sh`, setup scripts,
  and Zsh configuration; Bash for SketchyBar and Borders; Python standard
  library and `unittest` for SketchyBar helpers and tests.

## Protect host state

Inspect and syntax-check scripts freely. Get explicit user approval before
running commands that change the host, including:

- `sync.sh` or scripts that install or remove Homebrew packages.
- GNU Stow operations that change links under `$HOME`.
- Scripts that apply macOS defaults, install fonts, or restart services.
- `scripts/test_vm.sh`, which deletes and recreates its named Tart VM.

## Verification

Run the checks relevant to the changed files:

```sh
python3 -m unittest discover -s sketchybar/.config/sketchybar/tests -p 'test_*.py'
zsh scripts/tests/test_sync.sh
zsh -n sync.sh scripts/*.sh scripts/tests/*.sh scripts/tests/fixtures/*.sh \
  zsh/.zprofile zsh/.zshrc zsh/.zshenv
bash -n sketchybar/.config/sketchybar/sketchybarrc \
  sketchybar/.config/sketchybar/plugins/*.sh \
  borders/.config/borders/bordersrc
git diff --check
```

For UI changes, inspect the rendered result after an explicitly authorized
reload. If live verification is not authorized or available, report that it was
skipped.

Do not create commits unless the user explicitly requests one. When asked to
commit, follow the repository template in `git/.gitmessage`.
