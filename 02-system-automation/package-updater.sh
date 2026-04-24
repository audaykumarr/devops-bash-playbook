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

    PACKAGE_MANAGER="auto"
    SECURITY_ONLY="false"

    usage() {
      cat <<'EOF'
    Usage: package-updater.sh [--manager auto|apt|dnf|yum] [--security-only]
EOF
    }

    detect_manager() {
      if [[ "$PACKAGE_MANAGER" != "auto" ]]; then
        echo "$PACKAGE_MANAGER"
        return 0
      fi

      if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
      elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
      elif command -v yum >/dev/null 2>&1; then
        echo "yum"
      else
        die "no supported package manager found"
      fi
    }

    run_update() {
      local manager="$1"
      case "$manager" in
        apt)
          with_backoff 3 5 sudo apt-get update
          if [[ "$SECURITY_ONLY" == "true" ]]; then
            command -v unattended-upgrade >/dev/null 2>&1 || die "unattended-upgrade is required for apt security-only updates"
            with_backoff 3 5 sudo unattended-upgrade -d
          else
            with_backoff 3 5 sudo apt-get upgrade -y
          fi
          ;;
        dnf)
          with_backoff 3 5 sudo dnf upgrade -y $([[ "$SECURITY_ONLY" == "true" ]] && printf -- '--security')
          ;;
        yum)
          with_backoff 3 5 sudo yum update -y $([[ "$SECURITY_ONLY" == "true" ]] && printf -- '--security')
          ;;
        *)
          die "unsupported package manager: $manager"
          ;;
      esac
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --manager) PACKAGE_MANAGER="$2"; shift 2 ;;
          --security-only) SECURITY_ONLY="true"; shift ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      require_cmd sudo
      manager="$(detect_manager)"
      log INFO "running package update using manager=$manager security_only=$SECURITY_ONLY"
      run_update "$manager"
      log INFO "package update completed"
    }

    main "$@"
