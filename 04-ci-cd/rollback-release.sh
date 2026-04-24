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

    RELEASES_DIR="/srv/releases"
    CURRENT_LINK="/srv/current"
    HEALTH_URL=""
    RESTART_CMD=""

    usage() {
      cat <<'EOF'
    Usage: rollback-release.sh --releases-dir /srv/releases --current-link /srv/current --health-url https://app.example.com/healthz --restart-cmd 'sudo systemctl restart myapp'
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --releases-dir) RELEASES_DIR="$2"; shift 2 ;;
          --current-link) CURRENT_LINK="$2"; shift 2 ;;
          --health-url) HEALTH_URL="$2"; shift 2 ;;
          --restart-cmd) RESTART_CMD="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      validate_url "$HEALTH_URL"
      [[ -n "$RESTART_CMD" ]] || die "--restart-cmd is required"
      require_dir "$RELEASES_DIR"

      mapfile -t releases < <(find "$RELEASES_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
      (( ${#releases[@]} >= 2 )) || die "at least two releases are required to roll back"

      target_release="${releases[-2]}"
      ln -sfn "$target_release" "$CURRENT_LINK"
      bash -lc "$RESTART_CMD"
      wait_for_http_ok "$HEALTH_URL" 10 3
      log INFO "rollback completed target_release=$target_release"
    }

    main "$@"
