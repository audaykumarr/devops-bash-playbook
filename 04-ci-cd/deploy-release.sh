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

    RELEASE_ARCHIVE=""
    RELEASES_DIR="/srv/releases"
    CURRENT_LINK="/srv/current"
    HEALTH_URL=""
    RESTART_CMD=""

    usage() {
      cat <<'EOF'
    Usage: deploy-release.sh --archive artifacts/release.tgz --releases-dir /srv/releases --current-link /srv/current --health-url https://app.example.com/healthz --restart-cmd 'sudo systemctl restart myapp'
EOF
    }

    parse_args() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --archive) RELEASE_ARCHIVE="$2"; shift 2 ;;
          --releases-dir) RELEASES_DIR="$2"; shift 2 ;;
          --current-link) CURRENT_LINK="$2"; shift 2 ;;
          --health-url) HEALTH_URL="$2"; shift 2 ;;
          --restart-cmd) RESTART_CMD="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      require_file "$RELEASE_ARCHIVE"
      validate_url "$HEALTH_URL"
      [[ -n "$RESTART_CMD" ]] || die "--restart-cmd is required"
      ensure_dir "$RELEASES_DIR"
    }

    main() {
      parse_args "$@"
      require_cmd tar ln bash curl

      release_dir="${RELEASES_DIR}/release-$(date +%Y%m%d%H%M%S)"
      ensure_dir "$release_dir"
      tar -xzf "$RELEASE_ARCHIVE" -C "$release_dir"
      ln -sfn "$release_dir" "$CURRENT_LINK"
      bash -lc "$RESTART_CMD"
      wait_for_http_ok "$HEALTH_URL" 10 3
      log INFO "deployment completed current_link=$CURRENT_LINK release_dir=$release_dir"
    }

    main "$@"
