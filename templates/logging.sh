#!/usr/bin/env bash
    set -euo pipefail
    IFS=$'
	'

    LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Map friendly severity names to numeric levels so noisy jobs stay readable.
# Write logs to stderr so script output and diagnostics stay separate.

    _level_to_int() {
      case "$1" in
        DEBUG) echo 10 ;;
        INFO) echo 20 ;;
        WARN) echo 30 ;;
        ERROR) echo 40 ;;
        *) echo 20 ;;
      esac
    }

    log_message() {
      local level="$1"
      shift
      if [[ "$(_level_to_int "$level")" -lt "$(_level_to_int "$LOG_LEVEL")" ]]; then
        return 0
      fi

      printf '%s [%s] %s
' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$level" "$*" >&2
    }

    log_debug() { log_message DEBUG "$@"; }
    log_info() { log_message INFO "$@"; }
    log_warn() { log_message WARN "$@"; }
    log_error() { log_message ERROR "$@"; }
