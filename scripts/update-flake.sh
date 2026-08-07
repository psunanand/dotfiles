#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_HOST="mksmbp"
HOST="$DEFAULT_HOST"
RUN_CHECKS=1
RUN_BUILD=1

HOMEBREW_INPUTS=(
  brew-src
  nix-homebrew
  homebrew-core
  homebrew-cask
  homebrew-bundle
  felixkratz-homebrew-formulae
  nikitabobko-homebrew-tap
)

usage() {
  cat <<'USAGE'
Usage: scripts/update-flake.sh [options] [input...]

Update flake.lock inputs, then verify the nix-darwin system still evaluates.
With no inputs, all flake inputs are updated.

Options:
  --homebrew       Update only pinned Homebrew tap inputs.
  --host HOST      Build the given darwin host after updating. Defaults to mksmbp.
  --no-check       Skip nix flake check.
  --no-build       Skip the darwin system build.
  -h, --help       Show this help.

Examples:
  scripts/update-flake.sh
  scripts/update-flake.sh nixpkgs
  scripts/update-flake.sh --homebrew
USAGE
}

source_nix_profile() {
  local profile="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

  if [[ -r "$profile" ]]; then
    # shellcheck source=/dev/null
    . "$profile"
  fi
}

find_nix() {
  if command -v nix >/dev/null 2>&1; then
    command -v nix
    return
  fi

  source_nix_profile

  if command -v nix >/dev/null 2>&1; then
    command -v nix
    return
  fi

  if [[ -x /nix/var/nix/profiles/default/bin/nix ]]; then
    printf '%s\n' /nix/var/nix/profiles/default/bin/nix
    return
  fi

  return 1
}

INPUTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    --homebrew)
      INPUTS+=("${HOMEBREW_INPUTS[@]}")
      shift
      ;;
    --host)
      if [[ $# -lt 2 || "$2" == -* ]]; then
        printf 'error: --host requires a host name.\n' >&2
        exit 1
      fi
      HOST="$2"
      shift 2
      ;;
    --no-check)
      RUN_CHECKS=0
      shift
      ;;
    --no-build)
      RUN_BUILD=0
      shift
      ;;
    --)
      shift
      INPUTS+=("$@")
      break
      ;;
    -*)
      printf 'error: unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
    *)
      INPUTS+=("$1")
      shift
      ;;
  esac
done

NIX="$(find_nix)" || {
  printf 'error: nix is not available. Run scripts/bootstrap-lix-darwin.sh first.\n' >&2
  exit 1
}

cd "$ROOT_DIR"

"$NIX" flake update "${INPUTS[@]}"

if [[ "$RUN_CHECKS" -eq 1 ]]; then
  "$NIX" flake check --option eval-cache false
fi

if [[ "$RUN_BUILD" -eq 1 ]]; then
  "$NIX" build --no-link --option eval-cache false ".#darwinConfigurations.$HOST.system"
fi
