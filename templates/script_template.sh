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

    usage() {
      cat <<'EOF'
    Usage: script_template.sh --target <name> [--dry-run]
EOF
    }

    TARGET=""

    parse_args() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --target)
            TARGET="$2"
            shift 2
            ;;
          --dry-run)
            export DRY_RUN="true"
            shift
            ;;
          -h|--help)
            usage
            exit 0
            ;;
          *)
            die "Unknown argument: $1"
            ;;
        esac
      done

      [[ -n "$TARGET" ]] || die "--target is required"
    }

    main() {
      parse_args "$@"
      log INFO "Starting template script for target: $TARGET"

      # Keep business logic inside functions so you can unit-test or reuse it.
      run_cmd echo "Performing work against $TARGET"

      log INFO "Template execution finished"
    }

    main "$@"
