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

    PRIMARY_RECORD=""
    SECONDARY_RECORD=""
    HEALTH_URL=""
    SECONDARY_HEALTH_URL=""

    usage() {
      cat <<'EOF'
    Usage: dns-failover-check.sh --primary app-primary.example.com --secondary app-dr.example.com --health-url https://app.example.com/healthz --secondary-health-url https://dr.example.com/healthz
EOF
    }

    resolve_record() {
      local record="$1"
      dig +short "$record" | paste -sd ',' -
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --primary) PRIMARY_RECORD="$2"; shift 2 ;;
          --secondary) SECONDARY_RECORD="$2"; shift 2 ;;
          --health-url) HEALTH_URL="$2"; shift 2 ;;
          --secondary-health-url) SECONDARY_HEALTH_URL="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$PRIMARY_RECORD" ]] || die "--primary is required"
      [[ -n "$SECONDARY_RECORD" ]] || die "--secondary is required"
      validate_url "$HEALTH_URL"
      validate_url "$SECONDARY_HEALTH_URL"
      require_cmd dig paste curl

      primary_ips="$(resolve_record "$PRIMARY_RECORD")"
      secondary_ips="$(resolve_record "$SECONDARY_RECORD")"

      log INFO "primary record $PRIMARY_RECORD resolves to: ${primary_ips:-none}"
      log INFO "secondary record $SECONDARY_RECORD resolves to: ${secondary_ips:-none}"

      if wait_for_http_ok "$HEALTH_URL" 3 2; then
        log INFO "primary endpoint healthy; failover not required"
        exit 0
      fi

      if wait_for_http_ok "$SECONDARY_HEALTH_URL" 3 2; then
        log WARN "primary endpoint unhealthy while secondary is healthy; failover should be evaluated"
        exit 0
      fi

      die "both primary and secondary endpoints are unhealthy"
    }

    main "$@"
