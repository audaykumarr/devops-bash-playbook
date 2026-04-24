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

    CPU_THRESHOLD=85
    MEMORY_THRESHOLD=85
    DISK_THRESHOLD=85
    ALERT_SCRIPT=""

    usage() {
      cat <<'EOF'
    Usage: host-resource-check.sh [--cpu 85] [--memory 85] [--disk 85] [--alert-script ./08-monitoring/alert-dispatch.sh]
EOF
    }

    send_alert() {
      local message="$1"
      if [[ -n "$ALERT_SCRIPT" ]]; then
        bash "$ALERT_SCRIPT" --severity warning --service host --message "$message"
      else
        log WARN "$message"
      fi
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --cpu) CPU_THRESHOLD="$2"; shift 2 ;;
          --memory) MEMORY_THRESHOLD="$2"; shift 2 ;;
          --disk) DISK_THRESHOLD="$2"; shift 2 ;;
          --alert-script) ALERT_SCRIPT="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      validate_positive_int "$CPU_THRESHOLD"
      validate_positive_int "$MEMORY_THRESHOLD"
      validate_positive_int "$DISK_THRESHOLD"
      require_cmd awk df free top tail tr

      cpu_usage="$(top -bn1 | awk '/Cpu\(s\)/ {print int(100 - $8)}' | tail -n1)"
      memory_usage="$(free | awk '/Mem:/ {printf("%d", $3/$2 * 100)}')"
      disk_usage="$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')"

      log INFO "cpu=${cpu_usage}% memory=${memory_usage}% disk=${disk_usage}%"
      (( cpu_usage < CPU_THRESHOLD )) || send_alert "CPU usage above threshold: ${cpu_usage}%"
      (( memory_usage < MEMORY_THRESHOLD )) || send_alert "Memory usage above threshold: ${memory_usage}%"
      (( disk_usage < DISK_THRESHOLD )) || send_alert "Disk usage above threshold: ${disk_usage}%"
    }

    main "$@"
