#!/bin/zsh

emulate -L zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL

REPO_DIR="${0:A:h:h:h}"
FIXTURES_DIR="${0:A:h}/fixtures"
STEP_NAMES=(
  step-bootstrap-shell
  step-install-homebrew
  step-brew-bundle
  apply-dotfiles
  step-install-tpm
  apply-macos-defaults
  step-install-fonts
)
TEST_DIRS=()

fail() {
  print -u2 -r -- "FAIL: ${1//\\n/$'\n'}"
  exit 1
}

cleanup_test_dirs() {
  local test_dir

  for test_dir in $TEST_DIRS; do
    [[ -d "$test_dir" ]] && rm -rf -- "$test_dir"
  done
}

trap cleanup_test_dirs EXIT

assert_equal() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  [[ "$actual" == "$expected" ]] || fail "$message\nExpected:\n$expected\nActual:\n$actual"
}

assert_contains() {
  local output="$1"
  local expected="$2"
  local message="$3"

  [[ "$output" == *"$expected"* ]] || fail "$message\nMissing: $expected\nOutput:\n$output"
}

assert_not_contains() {
  local output="$1"
  local unexpected="$2"
  local message="$3"

  [[ "$output" != *"$unexpected"* ]] || fail "$message\nUnexpected: $unexpected\nOutput:\n$output"
}

setup_fixture() {
  TEST_DIR=$(mktemp -d)
  TEST_DIR="${TEST_DIR:A}"
  TEST_DIRS+=("$TEST_DIR")
  mkdir -p "$TEST_DIR/scripts" "$TEST_DIR/bin" "$TEST_DIR/home"
  cp "$REPO_DIR/sync.sh" "$TEST_DIR/sync.sh"
  ln -s "$FIXTURES_DIR/brew-stub.sh" "$TEST_DIR/bin/brew"

  local step_name
  for step_name in $STEP_NAMES; do
    ln -s "$FIXTURES_DIR/sync-step-stub.sh" "$TEST_DIR/scripts/$step_name.sh"
  done

  TEST_LOG="$TEST_DIR/steps.log"
  TEST_OUTPUT="$TEST_DIR/output.log"
  TEST_ERROR="$TEST_DIR/error.log"
  : > "$TEST_LOG"
}

run_sync() {
  PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    HOME="$TEST_DIR/home" \
    TERM= \
    HOMEBREW_PREFIX= \
    SYNC_TEST_LOG="$TEST_LOG" \
    SYNC_TEST_FAIL_STEP="${SYNC_TEST_FAIL_STEP:-}" \
    SYNC_TEST_BREW_SHELLENV_FAIL="${SYNC_TEST_BREW_SHELLENV_FAIL:-}" \
    SYNC_TEST_HOMEBREW_PREFIX="$TEST_DIR/homebrew" \
    zsh "$TEST_DIR/sync.sh" "$@" >"$TEST_OUTPUT" 2>"$TEST_ERROR"
}

setup_fixture
run_sync
homebrew_prefix="$TEST_DIR/homebrew"
assert_equal \
  "step-bootstrap-shell||$homebrew_prefix
step-install-homebrew||$homebrew_prefix
step-brew-bundle||$homebrew_prefix
apply-dotfiles||$homebrew_prefix
step-install-tpm||$homebrew_prefix
apply-macos-defaults||$homebrew_prefix
step-install-fonts||$homebrew_prefix" \
  "$(<"$TEST_LOG")" \
  "all runs every step in order without cleanup"
assert_contains "$(<"$TEST_OUTPUT")" "Sync Complete." "all reports success"
assert_equal "" "$(<"$TEST_ERROR")" "non-interactive output does not emit terminal errors"

setup_fixture
run_sync packages --cleanup
homebrew_prefix="$TEST_DIR/homebrew"
assert_equal \
  "step-install-homebrew||$homebrew_prefix
step-brew-bundle|--cleanup|$homebrew_prefix
step-install-tpm||$homebrew_prefix
step-install-fonts||$homebrew_prefix" \
  "$(<"$TEST_LOG")" \
  "packages runs package steps and forwards cleanup"

setup_fixture
run_sync dotfiles
assert_equal "apply-dotfiles||$TEST_DIR/homebrew" "$(<"$TEST_LOG")" "dotfiles runs only GNU Stow"

setup_fixture
run_sync macos
assert_equal "apply-macos-defaults||$TEST_DIR/homebrew" "$(<"$TEST_LOG")" "macos runs only defaults"

setup_fixture
SYNC_TEST_FAIL_STEP=step-brew-bundle
if run_sync all; then
  fail "a failed step returns nonzero"
fi
assert_equal \
  "step-bootstrap-shell||$TEST_DIR/homebrew
step-install-homebrew||$TEST_DIR/homebrew
step-brew-bundle||$TEST_DIR/homebrew" \
  "$(<"$TEST_LOG")" \
  "execution stops at the failed step"
assert_not_contains "$(<"$TEST_OUTPUT")" "Sync Complete." "failure does not report success"
assert_contains "$(<"$TEST_ERROR")" "step-brew-bundle failed" "failure names the step"

setup_fixture
SYNC_TEST_FAIL_STEP=""
SYNC_TEST_BREW_SHELLENV_FAIL=true
if run_sync packages; then
  fail "a failed Homebrew environment refresh returns nonzero"
fi
assert_equal \
  "step-install-homebrew||" \
  "$(<"$TEST_LOG")" \
  "Homebrew environment failure stops before Brew bundle"
assert_contains "$(<"$TEST_ERROR")" "Homebrew is unavailable" "Homebrew failure is explained"
SYNC_TEST_BREW_SHELLENV_FAIL=""

setup_fixture
if run_sync unknown; then
  fail "an unknown target returns nonzero"
fi
assert_contains "$(<"$TEST_ERROR")" "Usage:" "invalid input prints usage"

setup_fixture
if run_sync dotfiles --cleanup; then
  fail "cleanup with a non-package target returns nonzero"
fi
assert_contains "$(<"$TEST_ERROR")" "--cleanup requires" "invalid cleanup target explains the constraint"

setup_fixture
mkdir -p "$TEST_DIR/brew"
unlink "$TEST_DIR/scripts/step-brew-bundle.sh"
cp "$REPO_DIR/scripts/step-brew-bundle.sh" "$TEST_DIR/scripts/step-brew-bundle.sh"
touch "$TEST_DIR/brew/Brewfile"
PATH="$TEST_DIR/bin:/usr/bin:/bin" \
  SYNC_TEST_LOG="$TEST_LOG" \
  zsh "$TEST_DIR/scripts/step-brew-bundle.sh" >"$TEST_OUTPUT" 2>"$TEST_ERROR"
assert_equal \
  "brew|bundle --file=$TEST_DIR/brew/Brewfile" \
  "$(<"$TEST_LOG")" \
  "Brewfile cleanup is disabled by default"

: > "$TEST_LOG"
PATH="$TEST_DIR/bin:/usr/bin:/bin" \
  SYNC_TEST_LOG="$TEST_LOG" \
  zsh "$TEST_DIR/scripts/step-brew-bundle.sh" --cleanup >"$TEST_OUTPUT" 2>"$TEST_ERROR"
assert_equal \
  "brew|bundle --file=$TEST_DIR/brew/Brewfile --cleanup" \
  "$(<"$TEST_LOG")" \
  "Brewfile cleanup is enabled explicitly"

print -r -- "PASS: sync.sh behavior"
