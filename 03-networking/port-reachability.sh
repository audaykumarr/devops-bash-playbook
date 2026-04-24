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

    HOSTS=""
    PORTS=""
    TIMEOUT=3

    usage() {
      cat <<'EOF'
    Usage: port-reachability.sh --hosts api.internal,db.internal --ports 443,5432 [--timeout 3]
EOF
    }

    check_endpoint() {
      local host="$1"
      local port="$2"
      if nc -z -w "$TIMEOUT" "$host" "$port" >/dev/null 2>&1; then
        log INFO "reachable: ${host}:${port}"
        return 0
      fi

      log ERROR "unreachable: ${host}:${port}"
      return 1
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --hosts) HOSTS="$2"; shift 2 ;;
          --ports) PORTS="$2"; shift 2 ;;
          --timeout) TIMEOUT="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$HOSTS" ]] || die "--hosts is required"
      [[ -n "$PORTS" ]] || die "--ports is required"
      validate_positive_int "$TIMEOUT"
      require_cmd nc

      IFS=',' read -r -a host_array <<< "$HOSTS"
      IFS=',' read -r -a port_array <<< "$PORTS"
      failures=0

      for host in "${host_array[@]}"; do
        for port in "${port_array[@]}"; do
          validate_port "$port"
          check_endpoint "$host" "$port" || failures=$(( failures + 1 ))
        done
      done

      (( failures == 0 )) || die "port reachability check failed for ${failures} endpoint(s)"
      log INFO "all connectivity checks passed"
    }

    main "$@"
