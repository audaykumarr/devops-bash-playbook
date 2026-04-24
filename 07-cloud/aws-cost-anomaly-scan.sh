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

# Flag sudden cost spikes before the monthly bill review by comparing yesterday with a recent baseline.
# This gives platform teams a small, scriptable guardrail around AWS Cost Explorer usage.

LOOKBACK_DAYS=7
SPIKE_PERCENT=40

usage() {
  printf '%s\n' \
    "Usage: aws-cost-anomaly-scan.sh [--lookback-days 7] [--spike-percent 40]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lookback-days) LOOKBACK_DAYS="$2"; shift 2 ;;
      --spike-percent) SPIKE_PERCENT="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  validate_positive_int "$LOOKBACK_DAYS"
  validate_positive_int "$SPIKE_PERCENT"
  require_cmd aws python

  start_date="$(date -u -d "${LOOKBACK_DAYS} days ago" +%F)"
  end_date="$(date -u +%F)"
  cost_json="$(aws ce get-cost-and-usage --time-period Start="$start_date",End="$end_date" --granularity DAILY --metrics UnblendedCost)"

  python - <<'PY' "$cost_json" "$SPIKE_PERCENT"
import json
import sys

payload = json.loads(sys.argv[1])
spike_percent = float(sys.argv[2])
amounts = [float(day["Total"]["UnblendedCost"]["Amount"]) for day in payload["ResultsByTime"]]
if len(amounts) < 2:
    print("not enough cost history for anomaly scan")
    raise SystemExit(0)

yesterday = amounts[-1]
baseline = sum(amounts[:-1]) / len(amounts[:-1])
delta = 0 if baseline == 0 else ((yesterday - baseline) / baseline) * 100
print(f"baseline={baseline:.2f} yesterday={yesterday:.2f} delta_percent={delta:.2f}")
raise SystemExit(1 if delta > spike_percent else 0)
PY
}

main "$@"
