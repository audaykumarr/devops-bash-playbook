#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=../../utils/common.sh
source "${REPO_ROOT}/utils/common.sh"
# shellcheck source=../../utils/validators.sh
source "${REPO_ROOT}/utils/validators.sh"
trap 'on_error $LINENO "$BASH_COMMAND"' ERR

# Parse and validate inputs before mutating infrastructure state.
# Keep side effects inside dedicated functions so failures stay easier to reason about.

    CONFIG_FILE="projects/monitoring-alert-system/configs/checks.env"
    NOTIFY_SCRIPT="projects/monitoring-alert-system/notify.sh"

    check_http() {
      local target="$1"
      local critical="$2"
      status_code="$(curl -ksS -o /dev/null -w '%{http_code}' "$target" || true)"
      if [[ "$status_code" -ge "$critical" ]]; then
        bash "$NOTIFY_SCRIPT" --severity critical --check "$check_name" --message "HTTP status $status_code from $target"
      else
        log INFO "check=$check_name status=$status_code"
      fi
    }

    check_disk() {
      local target="$1"
      local warning="$2"
      local critical="$3"
      usage_pct="$(df "$target" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')"
      if (( usage_pct >= critical )); then
        bash "$NOTIFY_SCRIPT" --severity critical --check "$check_name" --message "Disk usage on $target is ${usage_pct}%"
      elif (( usage_pct >= warning )); then
        bash "$NOTIFY_SCRIPT" --severity warning --check "$check_name" --message "Disk usage on $target is ${usage_pct}%"
      else
        log INFO "check=$check_name usage=${usage_pct}%"
      fi
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --config) CONFIG_FILE="$2"; shift 2 ;;
          --notify-script) NOTIFY_SCRIPT="$2"; shift 2 ;;
          -h|--help)
            echo "Usage: monitor.sh [--config projects/monitoring-alert-system/configs/checks.env] [--notify-script projects/monitoring-alert-system/notify.sh]"
            exit 0
            ;;
          *)
            die "unknown argument: $1"
            ;;
        esac
      done

      require_file "$CONFIG_FILE"
      require_file "$NOTIFY_SCRIPT"
      require_cmd curl awk df

      while IFS='|' read -r check_name check_type target warning critical || [[ -n "$check_name" ]]; do
        [[ -z "$check_name" || "$check_name" =~ ^# ]] && continue
        case "$check_type" in
          http) check_http "$target" "$critical" ;;
          disk) check_disk "$target" "$warning" "$critical" ;;
          *) log WARN "unknown check type=$check_type name=$check_name" ;;
        esac
      done < "$CONFIG_FILE"
    }

    main "$@"
