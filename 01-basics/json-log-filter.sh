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

# Filter structured JSON logs quickly during incidents instead of writing ad hoc jq one-liners.
# The script can stream matching records or emit only a summary count for dashboards and runbooks.

LOG_FILE=""
LEVEL=""
SERVICE=""
SINCE_UNIX=0
SUMMARY_ONLY="false"

usage() {
  printf '%s\n' \
    "Usage: json-log-filter.sh --file logs/app.json --level error --service payments --since-unix 1713974400 [--summary-only]" \
    "Fields expected: timestamp, level, service"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --file) LOG_FILE="$2"; shift 2 ;;
      --level) LEVEL="$2"; shift 2 ;;
      --service) SERVICE="$2"; shift 2 ;;
      --since-unix) SINCE_UNIX="$2"; shift 2 ;;
      --summary-only) SUMMARY_ONLY="true"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  require_file "$LOG_FILE"
  validate_positive_int "$SINCE_UNIX"
  require_cmd jq
}

build_filter() {
  local jq_filter='. as $line | select((.timestamp // 0) >= $since)'
  [[ -n "$LEVEL" ]] && jq_filter="${jq_filter} | select((.level // \"\") == \$level)"
  [[ -n "$SERVICE" ]] && jq_filter="${jq_filter} | select((.service // \"\") == \$service)"
  printf '%s\n' "$jq_filter"
}

main() {
  local jq_filter
  parse_args "$@"
  jq_filter="$(build_filter)"

  if [[ "$SUMMARY_ONLY" == "true" ]]; then
    jq -c --arg level "$LEVEL" --arg service "$SERVICE" --argjson since "$SINCE_UNIX" \
      "$jq_filter" "$LOG_FILE" | wc -l
    exit 0
  fi

  jq -c --arg level "$LEVEL" --arg service "$SERVICE" --argjson since "$SINCE_UNIX" \
    "$jq_filter" "$LOG_FILE"
}

main "$@"
