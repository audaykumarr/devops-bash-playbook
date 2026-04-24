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

    TARGET_DIR="."
    ALLOWLIST_FILE=""
    REPORT_FILE="reports/secret-scan.txt"

    usage() {
      cat <<'EOF'
    Usage: secret-scan.sh [--target .] [--allowlist .secret-scan-ignore] [--report reports/secret-scan.txt]
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --target) TARGET_DIR="$2"; shift 2 ;;
          --allowlist) ALLOWLIST_FILE="$2"; shift 2 ;;
          --report) REPORT_FILE="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      require_dir "$TARGET_DIR"
      require_cmd grep dirname
      ensure_dir "$(dirname "$REPORT_FILE")"

      grep -RInE --exclude-dir=.git --exclude='*.md' --exclude='*.png'         '(AKIA[0-9A-Z]16|-----BEGIN (RSA|OPENSSH|EC) PRIVATE KEY-----|password\s*=|token\s*=|secret\s*=)'         "$TARGET_DIR" > "$REPORT_FILE" || true

      if [[ -n "$ALLOWLIST_FILE" && -f "$ALLOWLIST_FILE" ]]; then
        grep -Fvx -f "$ALLOWLIST_FILE" "$REPORT_FILE" > "${REPORT_FILE}.filtered" || true
        mv "${REPORT_FILE}.filtered" "$REPORT_FILE"
      fi

      if [[ -s "$REPORT_FILE" ]]; then
        log WARN "potential secrets found report=$REPORT_FILE"
        exit 1
      fi

      log INFO "no obvious secrets detected in $TARGET_DIR"
    }

    main "$@"
