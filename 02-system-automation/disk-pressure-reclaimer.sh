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

# Reclaim disk space with explicit switches instead of panic-deleting files during an outage.
# Each cleanup path is opt-in so operators can choose the least risky action first.

VACUUM_DAYS=7
CLEAN_TMP="false"
CLEAN_PACKAGE_CACHE="false"
CLEAN_JOURNAL="false"

usage() {
  printf '%s\n' \
    "Usage: disk-pressure-reclaimer.sh [--vacuum-days 7] [--clean-journal] [--clean-tmp] [--clean-package-cache] [--dry-run]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --vacuum-days) VACUUM_DAYS="$2"; shift 2 ;;
      --clean-journal) CLEAN_JOURNAL="true"; shift ;;
      --clean-tmp) CLEAN_TMP="true"; shift ;;
      --clean-package-cache) CLEAN_PACKAGE_CACHE="true"; shift ;;
      --dry-run) export DRY_RUN="true"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  validate_positive_int "$VACUUM_DAYS"
  require_cmd df
  log INFO "disk usage before cleanup"
  df -h /

  if [[ "$CLEAN_JOURNAL" == "true" ]]; then
    require_cmd journalctl
    run_cmd sudo journalctl --vacuum-time="${VACUUM_DAYS}d"
  fi

  if [[ "$CLEAN_TMP" == "true" ]]; then
    run_cmd find /tmp -mindepth 1 -mtime +"$VACUUM_DAYS" -delete
  fi

  if [[ "$CLEAN_PACKAGE_CACHE" == "true" ]]; then
    if command -v apt-get >/dev/null 2>&1; then
      run_cmd sudo apt-get clean
    elif command -v dnf >/dev/null 2>&1; then
      run_cmd sudo dnf clean all
    fi
  fi

  log INFO "disk usage after cleanup"
  df -h /
}

main "$@"
