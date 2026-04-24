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

# Turn raw request and failure counts into error-budget context that on-call engineers can act on.
# This is useful when dashboards are unavailable but incident responders still need a budget answer.

TOTAL_REQUESTS=0
FAILED_REQUESTS=0
SLO_PERCENT=99.9

usage() {
  printf '%s\n' \
    "Usage: sli-error-budget.sh --total-requests 120000 --failed-requests 63 [--slo-percent 99.9]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --total-requests) TOTAL_REQUESTS="$2"; shift 2 ;;
      --failed-requests) FAILED_REQUESTS="$2"; shift 2 ;;
      --slo-percent) SLO_PERCENT="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  validate_positive_int "$TOTAL_REQUESTS"
  validate_positive_int "$FAILED_REQUESTS"
  require_cmd python

  python - <<'PY' "$TOTAL_REQUESTS" "$FAILED_REQUESTS" "$SLO_PERCENT"
import sys
total = int(sys.argv[1])
failed = int(sys.argv[2])
slo = float(sys.argv[3])
if total == 0:
    print("total requests must be greater than zero")
    raise SystemExit(1)

availability = ((total - failed) / total) * 100
allowed_failures = total * ((100 - slo) / 100)
remaining = allowed_failures - failed
print(f"availability_percent={availability:.4f}")
print(f"allowed_failures={allowed_failures:.2f}")
print(f"remaining_budget={remaining:.2f}")
raise SystemExit(1 if remaining < 0 else 0)
PY
}

main "$@"
