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

# Parse and validate inputs before mutating infrastructure state.
# Keep side effects inside dedicated functions so failures stay easier to reason about.

    NAMESPACE="default"
    SELECTOR=""
    RESOURCE_KIND="deployment"
    KUBE_CONTEXT="${KUBE_CONTEXT:-}"
    TIMEOUT="180s"

    usage() {
      cat <<'EOF'
    Usage: rollout-restart.sh --namespace platform --selector app=myapp [--kind deployment] [--timeout 180s]
EOF
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
          --namespace) NAMESPACE="$2"; shift 2 ;;
          --selector) SELECTOR="$2"; shift 2 ;;
          --kind) RESOURCE_KIND="$2"; shift 2 ;;
          --timeout) TIMEOUT="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$SELECTOR" ]] || die "--selector is required"
      require_cmd kubectl
      mapfile -t resources < <(kubectl_cmd -n "$NAMESPACE" get "$RESOURCE_KIND" -l "$SELECTOR" -o name)
      (( ${#resources[@]} > 0 )) || die "no ${RESOURCE_KIND}s matched selector $SELECTOR"

      for resource in "${resources[@]}"; do
        kubectl_cmd -n "$NAMESPACE" rollout restart "$resource"
        kubectl_cmd -n "$NAMESPACE" rollout status "$resource" --timeout="$TIMEOUT"
        log INFO "rollout restart completed for $resource"
      done
    }

    main "$@"
