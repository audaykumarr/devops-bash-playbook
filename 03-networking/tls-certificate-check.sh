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

# Catch certificate expiry before traffic breaks by checking multiple endpoints in one sweep.
# The script exits nonzero if any certificate expires inside the warning window.

TARGETS=""
WARNING_DAYS=14

usage() {
  printf '%s\n' \
    "Usage: tls-certificate-check.sh --targets api.example.com:443,cdn.example.com:443 [--warning-days 14]"
}

check_target() {
  local target="$1"
  local host="${target%%:*}"
  local port="${target##*:}"
  local warning_seconds=$(( WARNING_DAYS * 86400 ))

  validate_port "$port"
  if openssl s_client -connect "${host}:${port}" -servername "$host" </dev/null 2>/dev/null \
    | openssl x509 -noout -checkend "$warning_seconds" >/dev/null 2>&1; then
    log INFO "certificate healthy for ${host}:${port}"
    return 0
  fi

  log ERROR "certificate inside warning window for ${host}:${port}"
  return 1
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --targets) TARGETS="$2"; shift 2 ;;
      --warning-days) WARNING_DAYS="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  [[ -n "$TARGETS" ]] || die "--targets is required"
  validate_positive_int "$WARNING_DAYS"
  require_cmd openssl

  IFS=',' read -r -a target_array <<< "$TARGETS"
  failures=0
  for target in "${target_array[@]}"; do
    check_target "$target" || failures=$(( failures + 1 ))
  done

  (( failures == 0 )) || die "tls certificate checks failed for ${failures} target(s)"
}

main "$@"
