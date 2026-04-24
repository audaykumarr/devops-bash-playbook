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

    DEPLOY_USER="deploy"
    APP_DIR="/srv/apps"
    REQUIRED_COMMANDS="curl,jq,git"

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --user) DEPLOY_USER="$2"; shift 2 ;;
          --app-dir) APP_DIR="$2"; shift 2 ;;
          --required-commands) REQUIRED_COMMANDS="$2"; shift 2 ;;
          -h|--help)
            echo "Usage: postcheck.sh [--user deploy] [--app-dir /srv/apps] [--required-commands curl,jq,git]"
            exit 0
            ;;
          *)
            die "unknown argument: $1"
            ;;
        esac
      done

      id "$DEPLOY_USER" >/dev/null 2>&1 || die "deploy user missing: $DEPLOY_USER"
      require_dir "$APP_DIR"
      IFS=',' read -r -a commands <<< "$REQUIRED_COMMANDS"
      require_cmd "${commands[@]}"
      log INFO "server postcheck passed user=$DEPLOY_USER app_dir=$APP_DIR"
    }

    main "$@"
