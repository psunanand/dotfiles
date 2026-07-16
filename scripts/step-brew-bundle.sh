#!/bin/zsh

DOTFILES_DIR="${0:A:h:h}"
BREWFILE_PATH="$DOTFILES_DIR/brew/Brewfile"
cleanup=false

for argument in "$@"; do
  case "$argument" in
    --cleanup)
      cleanup=true
      ;;
    *)
      print -u2 -r -- "Error: Unknown argument: $argument"
      exit 2
      ;;
  esac
done

if [[ -f "$BREWFILE_PATH" ]]; then
  echo "Action: Syncing Brewfile (this may take a while)..."
  brew_arguments=(bundle --file="$BREWFILE_PATH")
  [[ "$cleanup" == true ]] && brew_arguments+=(--cleanup)
  brew "${brew_arguments[@]}"
else
  print -u2 -r -- "Error: Brewfile not found at $BREWFILE_PATH."
  exit 1
fi
