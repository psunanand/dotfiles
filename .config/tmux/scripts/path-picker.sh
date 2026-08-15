#!/usr/bin/env bash
set -euo pipefail

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf "tmux path picker: required command not found: %s\n" "$1" >&2
    exit 1
  fi
}

preview_command='if [ -d {} ]; then eza --tree --level=2 --color=always {} 2>/dev/null | head -n 200; else bat --style=numbers --color=always --line-range=:500 {}; fi'

main() {
  require_command tmux
  require_command fd
  require_command fzf
  require_command bat
  require_command eza

  local target_pane
  target_pane=$(tmux display-message -p '#{pane_id}')
  if [[ -z "$target_pane" ]]; then
    printf 'tmux path picker: unable to determine the active pane\n' >&2
    exit 1
  fi

  local selected
  selected=$(fd --hidden --exclude .git . | fzf --multi --reverse --bind 'ctrl-y:accept' --preview "$preview_command") || exit 0
  [[ -n "$selected" ]] || exit 0

  local path output=""
  while IFS= read -r path; do
    output+="@$path "
  done <<<"$selected"

  tmux send-keys -t "$target_pane" -l -- "$output"
}

main "$@"
