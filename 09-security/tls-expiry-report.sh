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

# Produce a report of certificate expiry dates for services that need security review evidence.
# Unlike the simple health gate, this script captures the actual expiry date and days remaining.

TARGETS=""
REPORT_FILE="reports/tls-expiry-report.tsv"

usage() {
  printf '%s\n' \
    "Usage: tls-expiry-report.sh --targets api.example.com:443,cdn.example.com:443 [--report reports/tls-expiry-report.tsv]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --targets) TARGETS="$2"; shift 2 ;;
      --report) REPORT_FILE="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  [[ -n "$TARGETS" ]] || die "--targets is required"
  require_cmd openssl python dirname
  ensure_dir "$(dirname "$REPORT_FILE")"
  printf 'target\texpires_at\tremaining_days\n' > "$REPORT_FILE"

  IFS=',' read -r -a target_array <<< "$TARGETS"
  for target in "${target_array[@]}"; do
    host="${target%%:*}"
    port="${target##*:}"
    expiry="$(openssl s_client -connect "${host}:${port}" -servername "$host" </dev/null 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2-)"
    remaining_days="$(python - <<'PY' "$expiry"
import datetime
import sys
expiry = datetime.datetime.strptime(sys.argv[1], "%b %d %H:%M:%S %Y %Z")
now = datetime.datetime.utcnow()
print((expiry - now).days)
PY
)"
    printf '%s\t%s\t%s\n' "$target" "$expiry" "$remaining_days" >> "$REPORT_FILE"
  done

  log INFO "tls expiry report written to $REPORT_FILE"
}

main "$@"
