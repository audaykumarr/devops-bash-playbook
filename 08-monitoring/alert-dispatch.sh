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

    SEVERITY="info"
    SERVICE_NAME="unknown"
    MESSAGE=""
    WEBHOOK_URL="${WEBHOOK_URL:-}"

    usage() {
      cat <<'EOF'
    Usage: alert-dispatch.sh --severity critical --service checkout --message "deployment failed"
    Environment:
      WEBHOOK_URL  optional HTTP endpoint for Slack, Teams, or custom alert relays
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --severity) SEVERITY="$2"; shift 2 ;;
          --service) SERVICE_NAME="$2"; shift 2 ;;
          --message) MESSAGE="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$MESSAGE" ]] || die "--message is required"
      payload="$(printf '{"service":"%s","severity":"%s","message":"%s","timestamp":"%s"}'         "$SERVICE_NAME" "$SEVERITY" "$MESSAGE" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")")"

      if [[ -n "$WEBHOOK_URL" ]]; then
        validate_url "$WEBHOOK_URL"
        require_cmd curl
        curl -fsSL -X POST -H 'Content-Type: application/json' -d "$payload" "$WEBHOOK_URL" >/dev/null
        log INFO "alert dispatched to webhook for service=$SERVICE_NAME severity=$SEVERITY"
      else
        log WARN "$payload"
      fi
    }

    main "$@"
