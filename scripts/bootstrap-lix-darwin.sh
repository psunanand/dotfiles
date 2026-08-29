#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_HOST="mksmbp"
HOST="$DEFAULT_HOST"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: scripts/bootstrap-lix-darwin.sh [host] [darwin-rebuild-options...]

Install Lix when nix is missing, load the Nix daemon environment, and switch
the nix-darwin system for the given host. The host defaults to mksmbp.
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

source_nix_profile

if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix |
    sh -s -- install --no-confirm
  source_nix_profile
fi

if ! command -v nix >/dev/null 2>&1; then
  printf 'error: nix is not available after Lix installation.\n' >&2
  exit 1
fi

"$ROOT_DIR/scripts/darwin-switch.sh" "$HOST" "$@"

# Home Manager declares npm-based CLI tools in mise, but mise installs them
# outside the Nix activation. Ensure Node exists for mise's npm backend, then
# install the declared tools (including Pi).
find_mise() {
  if command -v mise >/dev/null 2>&1; then
    command -v mise
    return
  fi

  local candidate="/etc/profiles/per-user/${USER}/bin/mise"
  if [[ -x "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return
  fi

  return 1
}

MISE="$(find_mise)" || {
  printf 'error: mise is not available after nix-darwin activation. Open a new shell and run: mise install\n' >&2
  exit 1
}

"$MISE" use --global node@lts
"$MISE" install
