#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../utils/common.sh
source "${REPO_ROOT}/utils/common.sh"
# shellcheck source=../utils/validators.sh
source "${REPO_ROOT}/utils/validators.sh"
trap 'on_error $LINENO "$BASH_COMMAND"' ERR

# Detect drift between the current compose definition and the last approved render.
# Teams can store the hash after deployment and compare future config changes before rollout.

COMPOSE_FILE="docker-compose.yml"
STATE_FILE="state/compose.sha256"

usage() {
  printf '%s\n' \
    "Usage: docker-compose-drift-check.sh [--compose-file docker-compose.yml] [--state-file state/compose.sha256]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --compose-file) COMPOSE_FILE="$2"; shift 2 ;;
      --state-file) STATE_FILE="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  require_file "$COMPOSE_FILE"
  require_cmd docker sha256sum dirname
  ensure_dir "$(dirname "$STATE_FILE")"
  current_hash="$(docker compose -f "$COMPOSE_FILE" config | sha256sum | awk '{print $1}')"
  recorded_hash="$(cat "$STATE_FILE" 2>/dev/null || true)"

  if [[ -z "$recorded_hash" ]]; then
    printf '%s\n' "$current_hash" > "$STATE_FILE"
    log WARN "state file was missing; initialized with current compose hash"
    exit 0
  fi

  log INFO "current_hash=$current_hash recorded_hash=$recorded_hash"
  [[ "$current_hash" == "$recorded_hash" ]] || die "docker compose drift detected"
}

main "$@"
