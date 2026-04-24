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

# Probe a canary route through ingress before expanding traffic beyond the test slice.
# Expected status and body checks make the script useful in rollout gates and manual verification.

URL=""
HOST_HEADER=""
EXPECTED_STATUS=200
EXPECTED_SUBSTRING=""
ATTEMPTS=5

usage() {
  printf '%s\n' \
    "Usage: ingress-canary-check.sh --url https://1.2.3.4/healthz --host-header app.example.com [--expected-status 200] [--expected-substring ok] [--attempts 5]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --url) URL="$2"; shift 2 ;;
      --host-header) HOST_HEADER="$2"; shift 2 ;;
      --expected-status) EXPECTED_STATUS="$2"; shift 2 ;;
      --expected-substring) EXPECTED_SUBSTRING="$2"; shift 2 ;;
      --attempts) ATTEMPTS="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  validate_url "$URL"
  [[ -n "$HOST_HEADER" ]] || die "--host-header is required"
  validate_positive_int "$ATTEMPTS"
  require_cmd curl grep

  for attempt in $(seq 1 "$ATTEMPTS"); do
    response_file="$(mktemp)"
    status_code="$(curl -ksS -H "Host: $HOST_HEADER" -o "$response_file" -w '%{http_code}' "$URL" || true)"
    if [[ "$status_code" == "$EXPECTED_STATUS" ]]; then
      if [[ -z "$EXPECTED_SUBSTRING" || "$(grep -c -- "$EXPECTED_SUBSTRING" "$response_file" || true)" -gt 0 ]]; then
        rm -f "$response_file"
        log INFO "canary ingress healthy on attempt=${attempt}"
        exit 0
      fi
    fi
    rm -f "$response_file"
    log WARN "canary ingress check failed on attempt=${attempt} status=${status_code:-n/a}"
    sleep 2
  done

  die "canary ingress never returned the expected response"
}

main "$@"
