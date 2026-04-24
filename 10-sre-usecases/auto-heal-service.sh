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

# Parse and validate inputs before mutating infrastructure state.
# Keep side effects inside dedicated functions so failures stay easier to reason about.

    HEALTH_URL=""
    SERVICE_NAME=""
    RESTART_CMD=""
    STATE_DIR="state/auto-heal"
    FAILURE_THRESHOLD=3
    COOLDOWN_SECONDS=300

    usage() {
      cat <<'EOF'
    Usage: auto-heal-service.sh --health-url https://app.example.com/healthz --service myapp --restart-cmd 'sudo systemctl restart myapp'
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --health-url) HEALTH_URL="$2"; shift 2 ;;
          --service) SERVICE_NAME="$2"; shift 2 ;;
          --restart-cmd) RESTART_CMD="$2"; shift 2 ;;
          --state-dir) STATE_DIR="$2"; shift 2 ;;
          --failure-threshold) FAILURE_THRESHOLD="$2"; shift 2 ;;
          --cooldown-seconds) COOLDOWN_SECONDS="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      validate_url "$HEALTH_URL"
      [[ -n "$SERVICE_NAME" ]] || die "--service is required"
      [[ -n "$RESTART_CMD" ]] || die "--restart-cmd is required"
      validate_positive_int "$FAILURE_THRESHOLD"
      validate_positive_int "$COOLDOWN_SECONDS"
      require_cmd bash curl flock
      ensure_dir "$STATE_DIR"

      lock_file="${STATE_DIR}/${SERVICE_NAME}.lock"
      acquire_lock "$lock_file"

      state_file="${STATE_DIR}/${SERVICE_NAME}.state"
      last_restart_file="${STATE_DIR}/${SERVICE_NAME}.last_restart"
      failure_count="$(awk -F= '/count=/ {print $2}' "$state_file" 2>/dev/null || echo 0)"
      last_restart_epoch="$(cat "$last_restart_file" 2>/dev/null || echo 0)"

      if wait_for_http_ok "$HEALTH_URL" 1 1; then
        printf 'count=0
' > "$state_file"
        log INFO "service healthy: $SERVICE_NAME"
        exit 0
      fi

      failure_count=$(( failure_count + 1 ))
      printf 'count=%s
' "$failure_count" > "$state_file"
      log WARN "health check failed service=$SERVICE_NAME consecutive_failures=$failure_count"

      if (( failure_count < FAILURE_THRESHOLD )); then
        exit 0
      fi

      now_epoch="$(date +%s)"
      if (( now_epoch - last_restart_epoch < COOLDOWN_SECONDS )); then
        die "restart suppressed by cooldown for service=$SERVICE_NAME"
      fi

      bash -lc "$RESTART_CMD"
      printf '%s
' "$now_epoch" > "$last_restart_file"
      printf 'count=0
' > "$state_file"
      log WARN "auto-heal restart executed for service=$SERVICE_NAME"
    }

    main "$@"
