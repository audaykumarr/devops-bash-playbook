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

    SERVICES=""
    LOG_PATHS=""
    SINCE_WINDOW="-15 min"
    OUTPUT_FILE="bundles/logs/log-bundle.tar.gz"

    usage() {
      cat <<'EOF'
    Usage: log-bundle.sh --services nginx,myapp --log-paths /var/log/nginx/access.log,/var/log/myapp/app.log [--since '-30 min']
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --services) SERVICES="$2"; shift 2 ;;
          --log-paths) LOG_PATHS="$2"; shift 2 ;;
          --since) SINCE_WINDOW="$2"; shift 2 ;;
          --output-file) OUTPUT_FILE="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$SERVICES" || -n "$LOG_PATHS" ]] || die "provide at least one of --services or --log-paths"
      require_cmd journalctl tail tar dirname
      ensure_dir "$(dirname "$OUTPUT_FILE")"
      temp_dir="$(mktemp -d)"

      if [[ -n "$SERVICES" ]]; then
        IFS=',' read -r -a service_array <<< "$SERVICES"
        for service_name in "${service_array[@]}"; do
          journalctl -u "$service_name" --since "$SINCE_WINDOW" > "${temp_dir}/${service_name}.journal.txt" 2>&1 || true
        done
      fi

      if [[ -n "$LOG_PATHS" ]]; then
        IFS=',' read -r -a log_array <<< "$LOG_PATHS"
        for log_path in "${log_array[@]}"; do
          require_file "$log_path"
          tail -n 500 "$log_path" > "${temp_dir}/$(basename "$log_path").tail.txt"
        done
      fi

      tar -czf "$OUTPUT_FILE" -C "$temp_dir" .
      rm -rf "$temp_dir"
      log INFO "log bundle created: $OUTPUT_FILE"
    }

    main "$@"
