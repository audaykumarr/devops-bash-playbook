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

# Warm cache-heavy endpoints ahead of traffic spikes or post-deploy cutovers.
# This reduces cold-start latency for APIs that build expensive cache entries on demand.

URLS=""
HEADER=""

usage() {
  printf '%s\n' \
    "Usage: cache-warmup-runbook.sh --urls https://app.example.com/warm/users,https://app.example.com/warm/catalog [--header 'Authorization: Bearer <token>']"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --urls) URLS="$2"; shift 2 ;;
      --header) HEADER="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  [[ -n "$URLS" ]] || die "--urls is required"
  require_cmd curl

  IFS=',' read -r -a url_array <<< "$URLS"
  for url in "${url_array[@]}"; do
    validate_url "$url"
    if [[ -n "$HEADER" ]]; then
      with_retry 3 3 curl -fsSL -H "$HEADER" "$url" >/dev/null
    else
      with_retry 3 3 curl -fsSL "$url" >/dev/null
    fi
    log INFO "cache warmup completed for $url"
  done
}

main "$@"
