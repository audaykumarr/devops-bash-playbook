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

    TARGET_PATHS=""
    REPORT_FILE="reports/permission-audit.txt"

    usage() {
      cat <<'EOF'
    Usage: file-permission-audit.sh --paths /etc,/srv/app [--report reports/permission-audit.txt]
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --paths) TARGET_PATHS="$2"; shift 2 ;;
          --report) REPORT_FILE="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$TARGET_PATHS" ]] || die "--paths is required"
      require_cmd find stat dirname
      ensure_dir "$(dirname "$REPORT_FILE")"

      : > "$REPORT_FILE"
      IFS=',' read -r -a path_array <<< "$TARGET_PATHS"
      for path_item in "${path_array[@]}"; do
        require_dir "$path_item"
        find "$path_item" -xdev \( -type f -perm -0002 -o -type d -perm -0002 \) -print >> "$REPORT_FILE"
      done

      log INFO "permission audit completed report=$REPORT_FILE"
    }

    main "$@"
