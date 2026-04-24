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

    SOURCE_FILE=".env.example"
    OUTPUT_FILE=".env"
    REQUIRED_VARS=""

    usage() {
      cat <<'EOF'
    Usage: env-bootstrap.sh [--source .env.example] [--output .env] [--required VAR1,VAR2]
EOF
    }

    parse_args() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --source)
            SOURCE_FILE="$2"
            shift 2
            ;;
          --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
          --required)
            REQUIRED_VARS="$2"
            shift 2
            ;;
          -h|--help)
            usage
            exit 0
            ;;
          *)
            die "unknown argument: $1"
            ;;
        esac
      done
    }

    bootstrap_env() {
      local backup_file=""
      require_file "$SOURCE_FILE"

      if [[ -f "$OUTPUT_FILE" ]]; then
        backup_file="${OUTPUT_FILE}.$(date +%Y%m%d%H%M%S).bak"
        cp "$OUTPUT_FILE" "$backup_file"
        log WARN "existing env file backed up to $backup_file"
      fi

      : > "$OUTPUT_FILE"
      while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
          key="${BASH_REMATCH[1]}"
          sample_value="${BASH_REMATCH[2]}"
          current_value="${!key:-$sample_value}"
          printf '%s=%s
' "$key" "$current_value" >> "$OUTPUT_FILE"
        else
          printf '%s
' "$line" >> "$OUTPUT_FILE"
        fi
      done < "$SOURCE_FILE"

      chmod 600 "$OUTPUT_FILE"
    }

    validate_required_vars() {
      [[ -z "$REQUIRED_VARS" ]] && return 0
      IFS=',' read -r -a required_array <<< "$REQUIRED_VARS"
      load_env_file "$OUTPUT_FILE"
      require_env "${required_array[@]}"
    }

    main() {
      parse_args "$@"
      bootstrap_env
      validate_required_vars
      log INFO "environment bootstrap completed: $OUTPUT_FILE"
    }

    main "$@"
