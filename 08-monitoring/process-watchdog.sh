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

# Parse and validate inputs before mutating infrastructure state.
# Keep side effects inside dedicated functions so failures stay easier to reason about.

    PROCESS_PATTERN=""
    RESTART_CMD=""
    ALERT_SCRIPT=""
    STATE_DIR="state/watchdog"
    MAX_RESTARTS=3

    usage() {
      cat <<'EOF'
    Usage: process-watchdog.sh --process 'gunicorn: master' --restart-cmd 'sudo systemctl restart api' [--alert-script ./08-monitoring/alert-dispatch.sh]
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --process) PROCESS_PATTERN="$2"; shift 2 ;;
          --restart-cmd) RESTART_CMD="$2"; shift 2 ;;
          --alert-script) ALERT_SCRIPT="$2"; shift 2 ;;
          --state-dir) STATE_DIR="$2"; shift 2 ;;
          --max-restarts) MAX_RESTARTS="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$PROCESS_PATTERN" ]] || die "--process is required"
      [[ -n "$RESTART_CMD" ]] || die "--restart-cmd is required"
      validate_positive_int "$MAX_RESTARTS"
      require_cmd pgrep bash
      ensure_dir "$STATE_DIR"

      state_file="${STATE_DIR}/$(printf '%s' "$PROCESS_PATTERN" | tr ' /:' '___').count"
      restart_count="$(cat "$state_file" 2>/dev/null || echo 0)"

      if pgrep -f "$PROCESS_PATTERN" >/dev/null 2>&1; then
        echo 0 > "$state_file"
        log INFO "process healthy: $PROCESS_PATTERN"
        exit 0
      fi

      if (( restart_count >= MAX_RESTARTS )); then
        message="watchdog suppressing restart after ${restart_count} failures for pattern=$PROCESS_PATTERN"
        [[ -n "$ALERT_SCRIPT" ]] && bash "$ALERT_SCRIPT" --severity critical --service watchdog --message "$message"
        die "$message"
      fi

      bash -lc "$RESTART_CMD"
      echo $(( restart_count + 1 )) > "$state_file"
      log WARN "process restarted pattern=$PROCESS_PATTERN restart_count=$(( restart_count + 1 ))"
    }

    main "$@"
