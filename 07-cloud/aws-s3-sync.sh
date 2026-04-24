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

    SOURCE_DIR=""
    DESTINATION_URI=""
    SSE_MODE="AES256"
    DELETE_EXTRA="false"
    EXCLUDE_FILE=""

    usage() {
      cat <<'EOF'
    Usage: aws-s3-sync.sh --source ./dist --destination s3://my-bucket/releases/app --exclude-file .syncignore [--delete]
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --source) SOURCE_DIR="$2"; shift 2 ;;
          --destination) DESTINATION_URI="$2"; shift 2 ;;
          --exclude-file) EXCLUDE_FILE="$2"; shift 2 ;;
          --delete) DELETE_EXTRA="true"; shift ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      require_dir "$SOURCE_DIR"
      [[ "$DESTINATION_URI" =~ ^s3:// ]] || die "--destination must be an s3:// URI"
      require_cmd aws

      sync_args=(s3 sync "$SOURCE_DIR" "$DESTINATION_URI" --sse "$SSE_MODE")
      [[ "$DELETE_EXTRA" == "true" ]] && sync_args+=(--delete)
      if [[ -n "$EXCLUDE_FILE" ]]; then
        require_file "$EXCLUDE_FILE"
        while IFS= read -r pattern || [[ -n "$pattern" ]]; do
          [[ -z "$pattern" ]] && continue
          sync_args+=(--exclude "$pattern")
        done < "$EXCLUDE_FILE"
      fi

      with_backoff 3 5 aws "${sync_args[@]}"
      log INFO "S3 sync completed: $SOURCE_DIR -> $DESTINATION_URI"
    }

    main "$@"
