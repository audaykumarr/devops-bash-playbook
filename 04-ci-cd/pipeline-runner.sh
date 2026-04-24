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

    APP_DIR="."
    RELEASE_ID="$(date +%Y%m%d%H%M%S)"
    BUILD_CMD="${BUILD_CMD:-make build}"
    TEST_CMD="${TEST_CMD:-make test}"
    PACKAGE_CMD="${PACKAGE_CMD:-tar -czf artifacts/release.tgz dist}"
    ARTIFACT_DIR="artifacts"

    usage() {
      cat <<'EOF'
    Usage: pipeline-runner.sh [--app-dir .] [--release-id 20260424093000] [--artifact-dir artifacts]
    Environment:
      BUILD_CMD   build command to execute
      TEST_CMD    test command to execute
      PACKAGE_CMD packaging command to execute
EOF
    }

    parse_args() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --app-dir) APP_DIR="$2"; shift 2 ;;
          --release-id) RELEASE_ID="$2"; shift 2 ;;
          --artifact-dir) ARTIFACT_DIR="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      require_dir "$APP_DIR"
      ensure_dir "$ARTIFACT_DIR/logs"
    }

    run_stage() {
      local name="$1"
      local command_string="$2"
      local log_file="${ARTIFACT_DIR}/logs/${name}.log"
      log INFO "starting stage=$name"
      bash -lc "cd '$APP_DIR' && $command_string" | tee "$log_file"
      log INFO "completed stage=$name log=$log_file"
    }

    write_metadata() {
      cat > "${ARTIFACT_DIR}/release-metadata.env" <<EOF
    RELEASE_ID=$RELEASE_ID
    BUILD_CMD=$BUILD_CMD
    TEST_CMD=$TEST_CMD
    PACKAGE_CMD=$PACKAGE_CMD
    GENERATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF
    }

    main() {
      parse_args "$@"
      run_stage build "$BUILD_CMD"
      run_stage test "$TEST_CMD"
      run_stage package "$PACKAGE_CMD"
      write_metadata
      log INFO "pipeline completed for release_id=$RELEASE_ID"
    }

    main "$@"
