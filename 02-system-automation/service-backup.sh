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

    SERVICE_NAME=""
    SOURCE_DIRS=""
    BACKUP_DIR="/var/backups/services"
    RETENTION_DAYS=14

    usage() {
      cat <<'EOF'
    Usage: service-backup.sh --service nginx --sources /etc/nginx,/srv/app --backup-dir /var/backups/services
EOF
    }

    parse_args() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --service) SERVICE_NAME="$2"; shift 2 ;;
          --sources) SOURCE_DIRS="$2"; shift 2 ;;
          --backup-dir) BACKUP_DIR="$2"; shift 2 ;;
          --retention-days) RETENTION_DAYS="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$SERVICE_NAME" ]] || die "--service is required"
      [[ -n "$SOURCE_DIRS" ]] || die "--sources is required"
      validate_positive_int "$RETENTION_DAYS"
      ensure_dir "$BACKUP_DIR"
    }

    main() {
      parse_args "$@"
      require_cmd tar systemctl find

      IFS=',' read -r -a source_array <<< "$SOURCE_DIRS"
      for source_dir in "${source_array[@]}"; do
        require_dir "$source_dir"
      done

      systemctl is-active --quiet "$SERVICE_NAME" || log WARN "service $SERVICE_NAME is not active; continuing with filesystem backup"
      archive_path="${BACKUP_DIR}/${SERVICE_NAME}-$(date +%Y%m%d%H%M%S).tar.gz"
      tar -czf "$archive_path" "${source_array[@]}"
      find "$BACKUP_DIR" -type f -name "${SERVICE_NAME}-*.tar.gz" -mtime +"$RETENTION_DAYS" -delete
      log INFO "service backup created: $archive_path"
    }

    main "$@"
