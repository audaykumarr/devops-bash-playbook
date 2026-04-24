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

    LOG_DIR="/var/log"
    FILE_PATTERN="*.log"
    MAX_SIZE_MB=200
    RETENTION_DAYS=7

    usage() {
      cat <<'EOF'
    Usage: log-rotator.sh [--dir /var/log/myapp] [--pattern '*.log'] [--max-size-mb 200] [--retention-days 7]
EOF
    }

    parse_args() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --dir) LOG_DIR="$2"; shift 2 ;;
          --pattern) FILE_PATTERN="$2"; shift 2 ;;
          --max-size-mb) MAX_SIZE_MB="$2"; shift 2 ;;
          --retention-days) RETENTION_DAYS="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      require_dir "$LOG_DIR"
      validate_positive_int "$MAX_SIZE_MB"
      validate_positive_int "$RETENTION_DAYS"
    }

    rotate_file() {
      local logfile="$1"
      local archive_file="${logfile}.$(date +%Y%m%d%H%M%S)"
      cp "$logfile" "$archive_file"
      : > "$logfile"
      gzip -f "$archive_file"
      log INFO "rotated $logfile to $archive_file.gz"
    }

    main() {
      parse_args "$@"
      require_cmd find gzip stat

      while IFS= read -r logfile; do
        rotate_file "$logfile"
      done < <(find "$LOG_DIR" -type f -name "$FILE_PATTERN" -size +"${MAX_SIZE_MB}"M)

      find "$LOG_DIR" -type f -name "${FILE_PATTERN}.*.gz" -mtime +"$RETENTION_DAYS" -delete
      log INFO "log rotation sweep completed in $LOG_DIR"
    }

    main "$@"
