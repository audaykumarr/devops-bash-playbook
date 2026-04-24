#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=../../utils/common.sh
source "${REPO_ROOT}/utils/common.sh"
# shellcheck source=../../utils/validators.sh
source "${REPO_ROOT}/utils/validators.sh"
# shellcheck source=../../utils/retry.sh
source "${REPO_ROOT}/utils/retry.sh"
trap 'on_error $LINENO "$BASH_COMMAND"' ERR

# Parse and validate inputs before mutating infrastructure state.
# Keep side effects inside dedicated functions so failures stay easier to reason about.

    RELEASE_ROOT="releases"
    CURRENT_LINK="current"
    HEALTH_URL="http://127.0.0.1:8080/healthz"

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --release-root) RELEASE_ROOT="$2"; shift 2 ;;
          --current-link) CURRENT_LINK="$2"; shift 2 ;;
          --health-url) HEALTH_URL="$2"; shift 2 ;;
          -h|--help)
            echo "Usage: rollback.sh [--release-root releases] [--current-link current] [--health-url http://127.0.0.1:8080/healthz]"
            exit 0
            ;;
          *)
            die "unknown argument: $1"
            ;;
        esac
      done

      require_dir "$RELEASE_ROOT"
      mapfile -t release_dirs < <(find "$RELEASE_ROOT" -mindepth 1 -maxdepth 1 -type d | sort)
      (( ${#release_dirs[@]} >= 2 )) || die "not enough releases to roll back"

      ln -sfn "${release_dirs[-2]}" "$CURRENT_LINK"
      wait_for_http_ok "$HEALTH_URL" 10 3
      log INFO "mini pipeline rollback completed target=${release_dirs[-2]}"
    }

    main "$@"
