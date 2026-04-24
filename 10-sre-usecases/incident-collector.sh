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

    INCIDENT_ID=""
    SERVICES=""
    OUTPUT_DIR="bundles/incidents"

    usage() {
      cat <<'EOF'
    Usage: incident-collector.sh --incident INC-1042 --services nginx,myapp,postgres [--output-dir bundles/incidents]
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --incident) INCIDENT_ID="$2"; shift 2 ;;
          --services) SERVICES="$2"; shift 2 ;;
          --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$INCIDENT_ID" ]] || die "--incident is required"
      [[ -n "$SERVICES" ]] || die "--services is required"
      require_cmd systemctl journalctl tar uptime free df ps ss dmesg
      ensure_dir "$OUTPUT_DIR"

      bundle_dir="${OUTPUT_DIR}/${INCIDENT_ID}-$(date +%Y%m%d%H%M%S)"
      ensure_dir "$bundle_dir"
      uptime > "${bundle_dir}/uptime.txt"
      free -m > "${bundle_dir}/memory.txt"
      df -h > "${bundle_dir}/disk.txt"
      ps aux --sort=-%mem | head -n 25 > "${bundle_dir}/top-processes.txt"
      ss -tulpn > "${bundle_dir}/sockets.txt"
      dmesg | tail -n 200 > "${bundle_dir}/kernel.txt"

      IFS=',' read -r -a service_array <<< "$SERVICES"
      for service_name in "${service_array[@]}"; do
        systemctl status "$service_name" > "${bundle_dir}/${service_name}-status.txt" 2>&1 || true
        journalctl -u "$service_name" --since '-30 min' > "${bundle_dir}/${service_name}-journal.txt" 2>&1 || true
      done

      tar -czf "${bundle_dir}.tar.gz" -C "$OUTPUT_DIR" "$(basename "$bundle_dir")"
      log INFO "incident bundle created: ${bundle_dir}.tar.gz"
    }

    main "$@"
