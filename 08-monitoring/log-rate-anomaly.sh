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

# Detect sudden bursts of log volume that often precede outages or runaway retry loops.
# The script supports both file-based logs and systemd journals.

LOG_FILE=""
JOURNAL_UNIT=""
THRESHOLD=500
WINDOW_MINUTES=5

usage() {
  printf '%s\n' \
    "Usage: log-rate-anomaly.sh [--file /var/log/app.log | --journal-unit nginx] [--threshold 500] [--window-minutes 5]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --file) LOG_FILE="$2"; shift 2 ;;
      --journal-unit) JOURNAL_UNIT="$2"; shift 2 ;;
      --threshold) THRESHOLD="$2"; shift 2 ;;
      --window-minutes) WINDOW_MINUTES="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  validate_positive_int "$THRESHOLD"
  validate_positive_int "$WINDOW_MINUTES"
  [[ -n "$LOG_FILE" || -n "$JOURNAL_UNIT" ]] || die "provide either --file or --journal-unit"

  if [[ -n "$LOG_FILE" ]]; then
    require_file "$LOG_FILE"
    line_count="$(tail -n "$THRESHOLD" "$LOG_FILE" | wc -l)"
  else
    require_cmd journalctl
    line_count="$(journalctl -u "$JOURNAL_UNIT" --since "-${WINDOW_MINUTES} min" | wc -l)"
  fi

  log INFO "window_minutes=$WINDOW_MINUTES observed_lines=$line_count threshold=$THRESHOLD"
  (( line_count < THRESHOLD )) || die "log rate anomaly detected"
}

main "$@"
