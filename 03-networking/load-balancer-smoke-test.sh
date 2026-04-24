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

# Validate that a load balancer is serving healthy responses and spreading traffic.
# Response headers can reveal whether more than one backend is actually answering requests.

URL=""
REQUESTS=8
EXPECTED_STATUS=200
BACKEND_HEADER="X-Served-By"

usage() {
  printf '%s\n' \
    "Usage: load-balancer-smoke-test.sh --url https://app.example.com/healthz [--requests 8] [--expected-status 200] [--backend-header X-Served-By]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --url) URL="$2"; shift 2 ;;
      --requests) REQUESTS="$2"; shift 2 ;;
      --expected-status) EXPECTED_STATUS="$2"; shift 2 ;;
      --backend-header) BACKEND_HEADER="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  validate_url "$URL"
  validate_positive_int "$REQUESTS"
  require_cmd curl awk sort uniq

  tmp_file="$(mktemp)"
  for _ in $(seq 1 "$REQUESTS"); do
    curl -ksS -D - -o /dev/null "$URL" >> "$tmp_file"
    printf '%s\n' "--" >> "$tmp_file"
  done

  bad_statuses="$(awk -v expected="$EXPECTED_STATUS" '/^HTTP/ && $2 != expected {print $2}' "$tmp_file" | wc -l)"
  backends_seen="$(awk -v header="${BACKEND_HEADER}:" '$1 == header {print $2}' "$tmp_file" | sort -u | wc -l)"
  log INFO "requests=${REQUESTS} bad_statuses=${bad_statuses} backends_seen=${backends_seen}"
  rm -f "$tmp_file"

  (( bad_statuses == 0 )) || die "load balancer returned unexpected status codes"
  (( backends_seen >= 1 )) || die "backend distribution header not observed"
}

main "$@"
