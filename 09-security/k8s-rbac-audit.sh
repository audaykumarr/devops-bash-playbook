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

# Audit high-privilege Kubernetes bindings so cluster-admin access is visible and reviewable.
# The report focuses on broad roles that usually deserve extra scrutiny in production clusters.

OUTPUT_FILE="reports/k8s-rbac-audit.txt"
KUBE_CONTEXT="${KUBE_CONTEXT:-}"

usage() {
  printf '%s\n' \
    "Usage: k8s-rbac-audit.sh [--output reports/k8s-rbac-audit.txt]"
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
      --output) OUTPUT_FILE="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  require_cmd kubectl jq dirname
  ensure_dir "$(dirname "$OUTPUT_FILE")"
  kubectl_cmd get clusterrolebindings -o json | jq -r '
    .items[]
    | select(.roleRef.name == "cluster-admin" or .roleRef.name == "admin")
    | .metadata.name as $binding
    | .subjects[]?
    | "\($binding)\t\(.kind)\t\(.namespace // "-")\t\(.name)"
  ' > "$OUTPUT_FILE"
  log INFO "kubernetes RBAC audit written to $OUTPUT_FILE"
}

main "$@"
