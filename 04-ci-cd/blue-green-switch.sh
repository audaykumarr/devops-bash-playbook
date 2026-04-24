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

# Switch live traffic between blue and green release directories with a health gate.
# This preserves a fast rollback path because the inactive color remains intact on disk.

TARGET_COLOR=""
BLUE_PATH="/srv/releases/blue"
GREEN_PATH="/srv/releases/green"
LIVE_LINK="/srv/live"
HEALTH_URL=""
RELOAD_CMD=""

usage() {
  printf '%s\n' \
    "Usage: blue-green-switch.sh --target-color green --health-url https://app.example.com/healthz [--blue-path /srv/releases/blue] [--green-path /srv/releases/green] [--live-link /srv/live] [--reload-cmd 'sudo systemctl reload nginx']"
}

target_path() {
  case "$TARGET_COLOR" in
    blue) printf '%s\n' "$BLUE_PATH" ;;
    green) printf '%s\n' "$GREEN_PATH" ;;
    *) die "target color must be blue or green" ;;
  esac
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target-color) TARGET_COLOR="$2"; shift 2 ;;
      --blue-path) BLUE_PATH="$2"; shift 2 ;;
      --green-path) GREEN_PATH="$2"; shift 2 ;;
      --live-link) LIVE_LINK="$2"; shift 2 ;;
      --health-url) HEALTH_URL="$2"; shift 2 ;;
      --reload-cmd) RELOAD_CMD="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  validate_url "$HEALTH_URL"
  target_dir="$(target_path)"
  require_dir "$target_dir"
  ln -sfn "$target_dir" "$LIVE_LINK"
  [[ -n "$RELOAD_CMD" ]] && bash -lc "$RELOAD_CMD"
  wait_for_http_ok "$HEALTH_URL" 10 3
  log INFO "blue-green switch completed target_color=$TARGET_COLOR"
}

main "$@"
