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

# Guard cron-driven automations by checking a heartbeat file before restarting work.
# This helps teams detect stuck jobs and recover safely without launching duplicate runs.

HEARTBEAT_FILE=""
MAX_AGE_SECONDS=900
RECOVERY_CMD=""
LOCK_FILE="/tmp/cron-health-guard.lock"

usage() {
  printf '%s\n' \
    "Usage: cron-health-guard.sh --heartbeat-file /var/run/job.heartbeat --max-age-seconds 900 --recovery-cmd 'systemctl restart sync-job'" \
    "Optional: --lock-file /tmp/cron-health-guard.lock"
}

get_mtime() {
  local target_file="$1"
  if stat -c %Y "$target_file" >/dev/null 2>&1; then
    stat -c %Y "$target_file"
  else
    stat -f %m "$target_file"
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --heartbeat-file) HEARTBEAT_FILE="$2"; shift 2 ;;
      --max-age-seconds) MAX_AGE_SECONDS="$2"; shift 2 ;;
      --recovery-cmd) RECOVERY_CMD="$2"; shift 2 ;;
      --lock-file) LOCK_FILE="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  require_file "$HEARTBEAT_FILE"
  validate_positive_int "$MAX_AGE_SECONDS"
}

recover_if_stale() {
  local now_epoch last_seen age_seconds
  now_epoch="$(date +%s)"
  last_seen="$(get_mtime "$HEARTBEAT_FILE")"
  age_seconds=$(( now_epoch - last_seen ))

  log INFO "heartbeat age=${age_seconds}s file=$HEARTBEAT_FILE"
  if (( age_seconds < MAX_AGE_SECONDS )); then
    log INFO "heartbeat fresh; no recovery needed"
    return 0
  fi

  [[ -n "$RECOVERY_CMD" ]] || die "heartbeat stale and no recovery command was provided"
  acquire_lock "$LOCK_FILE"
  log WARN "heartbeat stale; running recovery command"
  bash -lc "$RECOVERY_CMD"
}

main() {
  parse_args "$@"
  recover_if_stale
}

main "$@"
