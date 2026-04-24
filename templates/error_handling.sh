#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Define cleanup centrally so temporary state is always removed on exit.
# Trap failures with command and line context to simplify incident debugging.
cleanup() {
  :
}

on_error() {
  local line="$1"
  local command="$2"
  local exit_code="${3:-1}"
  printf '%s [ERROR] line=%s command=%s exit_code=%s\n' \
    "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$line" "$command" "$exit_code" >&2
  cleanup
  exit "$exit_code"
}

trap 'on_error "$LINENO" "$BASH_COMMAND" "$?"' ERR
trap cleanup EXIT
