#!/bin/zsh

if [[ "$1" == "shellenv" ]]; then
  [[ "${SYNC_TEST_BREW_SHELLENV_FAIL:-}" == true ]] && exit 43
  print -r -- "export HOMEBREW_PREFIX=$SYNC_TEST_HOMEBREW_PREFIX"
  print -r -- "export PATH=${0:A:h}:\$PATH"
else
  print -r -- "brew|${(j: :)@}" >> "$SYNC_TEST_LOG"
fi
