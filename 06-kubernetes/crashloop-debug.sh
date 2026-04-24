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

    NAMESPACE="default"
    POD_NAME=""
    SELECTOR=""
    OUTPUT_DIR="bundles"

    usage() {
      cat <<'EOF'
    Usage: crashloop-debug.sh --namespace platform --pod myapp-abc123
           crashloop-debug.sh --namespace platform --selector app=myapp
EOF
    }

    resolve_pod() {
      if [[ -n "$POD_NAME" ]]; then
        echo "$POD_NAME"
        return 0
      fi
      kubectl -n "$NAMESPACE" get pods -l "$SELECTOR" -o jsonpath='{.items[0].metadata.name}'
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --namespace) NAMESPACE="$2"; shift 2 ;;
          --pod) POD_NAME="$2"; shift 2 ;;
          --selector) SELECTOR="$2"; shift 2 ;;
          --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$POD_NAME" || -n "$SELECTOR" ]] || die "either --pod or --selector is required"
      require_cmd kubectl tar
      ensure_dir "$OUTPUT_DIR"

      pod="$(resolve_pod)"
      bundle_dir="${OUTPUT_DIR}/${pod}-$(date +%Y%m%d%H%M%S)"
      ensure_dir "$bundle_dir"

      kubectl -n "$NAMESPACE" describe pod "$pod" > "${bundle_dir}/describe.txt"
      kubectl -n "$NAMESPACE" logs "$pod" --all-containers=true > "${bundle_dir}/logs-current.txt" || true
      kubectl -n "$NAMESPACE" logs "$pod" --all-containers=true --previous > "${bundle_dir}/logs-previous.txt" || true
      kubectl -n "$NAMESPACE" get events --sort-by=.lastTimestamp > "${bundle_dir}/events.txt"

      tar -czf "${bundle_dir}.tar.gz" -C "$OUTPUT_DIR" "$(basename "$bundle_dir")"
      log INFO "crashloop debug bundle created: ${bundle_dir}.tar.gz"
    }

    main "$@"
