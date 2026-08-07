#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_HOST="mksmbp"
HOST="$DEFAULT_HOST"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: scripts/darwin-switch.sh [host] [darwin-rebuild-options...]

Switch the nix-darwin system for the given host. The host defaults to mksmbp.
USAGE
  exit 0
fi

if [[ $# -gt 0 && "$1" != -* ]]; then
  HOST="$1"
  shift
fi

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

find_darwin_rebuild() {
  if command -v darwin-rebuild >/dev/null 2>&1; then
    command -v darwin-rebuild
    return
  fi

  if [[ -x /run/current-system/sw/bin/darwin-rebuild ]]; then
    printf '%s\n' /run/current-system/sw/bin/darwin-rebuild
    return
  fi

  return 1
}

if DARWIN_REBUILD="$(find_darwin_rebuild)"; then
  exec sudo -H "$DARWIN_REBUILD" switch --flake "$ROOT_DIR#$HOST" "$@"
fi

NIX="$(find_nix)" || {
  printf 'error: nix is not available. Run scripts/bootstrap-lix-darwin.sh first.\n' >&2
  exit 1
}

OUT_LINK="$ROOT_DIR/.tmp/darwin-system-$HOST"
mkdir -p "$ROOT_DIR/.tmp"

"$NIX" build "$ROOT_DIR#darwinConfigurations.$HOST.system" --out-link "$OUT_LINK"
exec sudo -H "$OUT_LINK/sw/bin/darwin-rebuild" switch --flake "$ROOT_DIR#$HOST" "$@"
