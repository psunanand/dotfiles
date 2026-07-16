#!/bin/zsh

emulate -L zsh
setopt PIPE_FAIL

DOTFILES_DIR="${0:A:h}"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

SET_BOLD=""
SET_GREEN=""
SET_RESET=""

if [[ -t 1 && -n "${TERM:-}" ]] && (( $+commands[tput] )); then
  SET_BOLD=$(tput bold 2>/dev/null)
  SET_GREEN=$(tput setaf 2 2>/dev/null)
  SET_RESET=$(tput sgr0 2>/dev/null)
fi

usage() {
  print -u2 -r -- "Usage: ./sync.sh [all|packages|dotfiles|macos] [--cleanup]"
}

refresh_homebrew_environment() {
  local brew_path=""
  local shell_environment=""

  if (( $+commands[brew] )); then
    brew_path="$commands[brew]"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    brew_path="/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_path="/usr/local/bin/brew"
  else
    return 1
  fi

  shell_environment=$("$brew_path" shellenv) || return
  eval "$shell_environment"
}

target="all"
target_set=false
cleanup=false

for argument in "$@"; do
  case "$argument" in
    all|packages|dotfiles|macos)
      if [[ "$target_set" == true ]]; then
        print -u2 -r -- "Error: Choose only one sync target."
        usage
        exit 2
      fi
      target="$argument"
      target_set=true
      ;;
    --cleanup)
      cleanup=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      print -u2 -r -- "Error: Unknown argument: $argument"
      usage
      exit 2
      ;;
  esac
done

if [[ "$cleanup" == true && "$target" != all && "$target" != packages ]]; then
  print -u2 -r -- "Error: --cleanup requires the all or packages target."
  usage
  exit 2
fi

refresh_homebrew_environment >/dev/null 2>&1 || true

echo "${SET_BOLD}Starting System Sync...${SET_RESET}"

execute_step() {
  local step_name="$1"
  local script="$SCRIPTS_DIR/$step_name.sh"
  shift

  if [[ ! -f "$script" ]]; then
    print -u2 -r -- "Error: $script not found."
    return 1
  fi

  echo "${SET_BOLD}Action:${SET_RESET} Running $step_name..."
  zsh "$script" "$@"
  local exit_status=$?

  if (( exit_status != 0 )); then
    print -u2 -r -- "Error: $step_name failed with status $exit_status."
    return $exit_status
  fi
}

install_homebrew_and_packages() {
  local -a bundle_arguments=()

  execute_step "step-install-homebrew" || return

  if ! refresh_homebrew_environment; then
    print -u2 -r -- "Error: Homebrew is unavailable after installation."
    return 1
  fi

  [[ "$cleanup" == true ]] && bundle_arguments+=(--cleanup)
  execute_step "step-brew-bundle" "${bundle_arguments[@]}"
}

run_all() {
  execute_step "step-bootstrap-shell" || return
  install_homebrew_and_packages || return
  execute_step "apply-dotfiles" || return
  execute_step "step-install-tpm" || return
  execute_step "apply-macos-defaults" || return
  execute_step "step-install-fonts"
}

run_packages() {
  install_homebrew_and_packages || return
  execute_step "step-install-tpm" || return
  execute_step "step-install-fonts"
}

case "$target" in
  all)
    run_all
    ;;
  packages)
    run_packages
    ;;
  dotfiles)
    execute_step "apply-dotfiles"
    ;;
  macos)
    execute_step "apply-macos-defaults"
    ;;
esac
sync_status=$?

if (( sync_status != 0 )); then
  print -u2 -r -- "System Sync failed."
  exit $sync_status
fi

echo "${SET_BOLD}${SET_GREEN}Sync Complete.${SET_RESET}"
