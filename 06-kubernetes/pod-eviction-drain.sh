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

# Drain a node in a predictable way before maintenance and preserve the exact command flags used.
# This is safer than improvising kubectl drain options during a production incident.

NODE_NAME=""
TIMEOUT="300s"
KUBE_CONTEXT="${KUBE_CONTEXT:-}"

usage() {
  printf '%s\n' \
    "Usage: pod-eviction-drain.sh --node ip-10-0-1-12 [--timeout 300s] [--dry-run]"
}

kubectl_cmd() {
  if [[ -n "$KUBE_CONTEXT" ]]; then
    kubectl --context "$KUBE_CONTEXT" "$@"
  else
    kubectl "$@"
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --node) NODE_NAME="$2"; shift 2 ;;
      --timeout) TIMEOUT="$2"; shift 2 ;;
      --dry-run) export DRY_RUN="true"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  [[ -n "$NODE_NAME" ]] || die "--node is required"
  require_cmd kubectl
  run_cmd kubectl_cmd cordon "$NODE_NAME"
  run_cmd kubectl_cmd drain "$NODE_NAME" \
    --ignore-daemonsets \
    --delete-emptydir-data \
    --force \
    --timeout="$TIMEOUT"
  log INFO "node drain completed node=$NODE_NAME timeout=$TIMEOUT"
}

main "$@"
