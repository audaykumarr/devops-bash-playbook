#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../utils/common.sh
source "${REPO_ROOT}/utils/common.sh"
# shellcheck source=../utils/validators.sh
source "${REPO_ROOT}/utils/validators.sh"
# shellcheck source=../utils/retry.sh
source "${REPO_ROOT}/utils/retry.sh"
trap 'on_error $LINENO "$BASH_COMMAND"' ERR

# Rehearse dependency failover safely by validating fallback health before executing the switch.
# This helps SRE teams turn tabletop drills into repeatable, low-friction runbooks.

PRIMARY_URL=""
FALLBACK_URL=""
SWITCH_CMD=""

usage() {
  printf '%s\n' \
    "Usage: dependency-failover-drill.sh --primary-url https://primary-db-proxy/healthz --fallback-url https://dr-db-proxy/healthz --switch-cmd 'kubectl set env deploy/api DB_ENDPOINT=dr-db-proxy'"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --primary-url) PRIMARY_URL="$2"; shift 2 ;;
      --fallback-url) FALLBACK_URL="$2"; shift 2 ;;
      --switch-cmd) SWITCH_CMD="$2"; shift 2 ;;
      --dry-run) export DRY_RUN="true"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  validate_url "$PRIMARY_URL"
  validate_url "$FALLBACK_URL"
  [[ -n "$SWITCH_CMD" ]] || die "--switch-cmd is required"

  if wait_for_http_ok "$PRIMARY_URL" 1 1; then
    log INFO "primary dependency healthy before drill"
  else
    log WARN "primary dependency already unhealthy before drill"
  fi

  wait_for_http_ok "$FALLBACK_URL" 5 2
  run_cmd bash -lc "$SWITCH_CMD"
  log INFO "dependency failover drill executed"
}

main "$@"
