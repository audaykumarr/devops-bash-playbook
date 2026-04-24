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

    APP_DIR="."
    BUILD_CMD="make build"
    TEST_CMD="make test"
    PACKAGE_DIR="dist"
    RELEASE_ROOT="releases"
    CURRENT_LINK="current"
    HEALTH_URL="http://127.0.0.1:8080/healthz"

    usage() {
      cat <<'EOF'
    Usage: pipeline.sh --app-dir . --build-cmd "make build" --test-cmd "make test" --package-dir dist
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --app-dir) APP_DIR="$2"; shift 2 ;;
          --build-cmd) BUILD_CMD="$2"; shift 2 ;;
          --test-cmd) TEST_CMD="$2"; shift 2 ;;
          --package-dir) PACKAGE_DIR="$2"; shift 2 ;;
          --release-root) RELEASE_ROOT="$2"; shift 2 ;;
          --current-link) CURRENT_LINK="$2"; shift 2 ;;
          --health-url) HEALTH_URL="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      require_dir "$APP_DIR"
      require_cmd bash tar ln curl mkdir
      ensure_dir "$RELEASE_ROOT"

      bash -lc "cd '$APP_DIR' && $BUILD_CMD"
      bash -lc "cd '$APP_DIR' && $TEST_CMD"
      require_dir "${APP_DIR}/${PACKAGE_DIR}"

      release_id="$(date +%Y%m%d%H%M%S)"
      archive_path="${RELEASE_ROOT}/release-${release_id}.tar.gz"
      tar -czf "$archive_path" -C "$APP_DIR" "$PACKAGE_DIR"

      live_release_dir="${RELEASE_ROOT}/release-${release_id}"
      ensure_dir "$live_release_dir"
      tar -xzf "$archive_path" -C "$live_release_dir"
      ln -sfn "$live_release_dir" "$CURRENT_LINK"
      wait_for_http_ok "$HEALTH_URL" 10 3
      log INFO "mini pipeline release succeeded id=$release_id"
    }

    main "$@"
