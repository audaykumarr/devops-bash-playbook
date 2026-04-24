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

    UNTIL_FILTER="168h"
    AGGRESSIVE="false"

    usage() {
      cat <<'EOF'
    Usage: cleanup-host.sh [--until 168h] [--aggressive]
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --until) UNTIL_FILTER="$2"; shift 2 ;;
          --aggressive) AGGRESSIVE="true"; shift ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      require_cmd docker
      log INFO "docker disk usage before cleanup"
      docker system df
      docker container prune --force --filter "until=$UNTIL_FILTER"
      docker image prune --all --force --filter "until=$UNTIL_FILTER"
      if [[ "$AGGRESSIVE" == "true" ]]; then
        docker volume prune --force
        docker builder prune --all --force
      fi
      log INFO "docker disk usage after cleanup"
      docker system df
    }

    main "$@"
