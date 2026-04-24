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

    NAMESPACE=""
    KUBE_CONTEXT="${KUBE_CONTEXT:-}"

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
          --namespace) NAMESPACE="$2"; shift 2 ;;
          -h|--help)
            echo "Usage: cluster-health-check.sh [--namespace platform]"
            exit 0
            ;;
          *)
            die "unknown argument: $1"
            ;;
        esac
      done

      require_cmd kubectl

      log INFO "checking node readiness"
      kubectl_cmd get nodes

      if [[ -n "$NAMESPACE" ]]; then
        log INFO "checking workload health in namespace=$NAMESPACE"
        kubectl_cmd -n "$NAMESPACE" get pods
        kubectl_cmd -n "$NAMESPACE" get pvc
        kubectl_cmd -n "$NAMESPACE" get events --sort-by=.lastTimestamp | tail -n 20
      else
        log INFO "checking unhealthy pods across all namespaces"
        kubectl_cmd get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded
        kubectl_cmd get pvc --all-namespaces
      fi
    }

    main "$@"
