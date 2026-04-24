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

# Audit systemd state before patch windows or handoffs so failing units do not go unnoticed.
# The report combines failed services with enabled units that are unexpectedly inactive.

REPORT_FILE="reports/systemd-unit-audit.txt"
IGNORE_REGEX=""

usage() {
  printf '%s\n' \
    "Usage: systemd-unit-audit.sh [--report reports/systemd-unit-audit.txt] [--ignore-regex 'user@|session']"
}

should_ignore() {
  local service_name="$1"
  [[ -n "$IGNORE_REGEX" && "$service_name" =~ $IGNORE_REGEX ]]
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --report) REPORT_FILE="$2"; shift 2 ;;
      --ignore-regex) IGNORE_REGEX="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  require_cmd systemctl dirname
  ensure_dir "$(dirname "$REPORT_FILE")"
  : > "$REPORT_FILE"

  {
    echo "[failed-units]"
    systemctl list-units --type=service --failed --no-legend || true
    echo
    echo "[enabled-but-inactive]"
    while read -r unit_name _; do
      should_ignore "$unit_name" && continue
      if ! systemctl is-active --quiet "$unit_name"; then
        printf '%s inactive\n' "$unit_name"
      fi
    done < <(systemctl list-unit-files --type=service --state=enabled --no-legend)
  } >> "$REPORT_FILE"

  log INFO "systemd audit written to $REPORT_FILE"
}

main "$@"
