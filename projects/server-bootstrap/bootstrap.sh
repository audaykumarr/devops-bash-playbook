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

    DEPLOY_USER="deploy"
    APP_DIR="/srv/apps"
    PACKAGE_LIST="curl,jq,git"
    SYSCTL_FILE=""

    usage() {
      cat <<'EOF'
    Usage: bootstrap.sh [--user deploy] [--app-dir /srv/apps] [--packages curl,jq,git] [--sysctl-file projects/server-bootstrap/configs/sysctl.conf]
EOF
    }

    install_packages() {
      IFS=',' read -r -a packages <<< "$PACKAGE_LIST"
      if command -v apt-get >/dev/null 2>&1; then
        with_backoff 3 5 sudo apt-get update
        with_backoff 3 5 sudo apt-get install -y "${packages[@]}"
      elif command -v dnf >/dev/null 2>&1; then
        with_backoff 3 5 sudo dnf install -y "${packages[@]}"
      else
        die "supported package manager not found"
      fi
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --user) DEPLOY_USER="$2"; shift 2 ;;
          --app-dir) APP_DIR="$2"; shift 2 ;;
          --packages) PACKAGE_LIST="$2"; shift 2 ;;
          --sysctl-file) SYSCTL_FILE="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      require_cmd sudo useradd mkdir chown
      install_packages
      id "$DEPLOY_USER" >/dev/null 2>&1 || sudo useradd --create-home --shell /bin/bash "$DEPLOY_USER"
      sudo mkdir -p "$APP_DIR" /var/log/apps
      sudo chown -R "$DEPLOY_USER":"$DEPLOY_USER" "$APP_DIR" /var/log/apps

      if [[ -n "$SYSCTL_FILE" ]]; then
        require_file "$SYSCTL_FILE"
        sudo cp "$SYSCTL_FILE" /etc/sysctl.d/99-devops-bash-playbook.conf
        sudo sysctl --system
      fi

      log INFO "server bootstrap completed user=$DEPLOY_USER app_dir=$APP_DIR"
    }

    main "$@"
