#!/bin/zsh

step_name="${0:t:r}"
print -r -- "$step_name|${(j: :)@}|${HOMEBREW_PREFIX:-}" >> "$SYNC_TEST_LOG"

if [[ "$step_name" == "${SYNC_TEST_FAIL_STEP:-}" ]]; then
  exit 42
fi
