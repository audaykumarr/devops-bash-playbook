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

    SEVERITY="info"
    CHECK_NAME=""
    MESSAGE=""

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --severity) SEVERITY="$2"; shift 2 ;;
          --check) CHECK_NAME="$2"; shift 2 ;;
          --message) MESSAGE="$2"; shift 2 ;;
          -h|--help)
            echo "Usage: notify.sh --severity critical --check api-health --message 'service down'"
            exit 0
            ;;
          *)
            die "unknown argument: $1"
            ;;
        esac
      done

      [[ -n "$CHECK_NAME" ]] || die "--check is required"
      [[ -n "$MESSAGE" ]] || die "--message is required"
      if [[ -n "${WEBHOOK_URL:-}" ]]; then
        curl -fsSL -X POST -H 'Content-Type: application/json'           -d "$(printf '{"check":"%s","severity":"%s","message":"%s"}' "$CHECK_NAME" "$SEVERITY" "$MESSAGE")"           "$WEBHOOK_URL" >/dev/null
      else
        log WARN "check=$CHECK_NAME severity=$SEVERITY message=$MESSAGE"
      fi
    }

    main "$@"
