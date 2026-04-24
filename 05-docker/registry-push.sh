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

    LOCAL_IMAGE=""
    REGISTRY_IMAGE=""
    TAGS=""

    usage() {
      cat <<'EOF'
    Usage: registry-push.sh --local-image myapp:build --registry-image ghcr.io/acme/myapp --tags 1.2.3,stable
    Environment:
      DOCKER_USERNAME
      DOCKER_PASSWORD
EOF
    }

    login_if_needed() {
      if [[ -n "${DOCKER_USERNAME:-}" && -n "${DOCKER_PASSWORD:-}" ]]; then
        printf '%s' "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin "$(printf '%s' "$REGISTRY_IMAGE" | cut -d/ -f1)"
      fi
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --local-image) LOCAL_IMAGE="$2"; shift 2 ;;
          --registry-image) REGISTRY_IMAGE="$2"; shift 2 ;;
          --tags) TAGS="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$LOCAL_IMAGE" ]] || die "--local-image is required"
      [[ -n "$REGISTRY_IMAGE" ]] || die "--registry-image is required"
      [[ -n "$TAGS" ]] || die "--tags is required"
      require_cmd docker cut

      login_if_needed
      IFS=',' read -r -a tag_array <<< "$TAGS"
      for tag in "${tag_array[@]}"; do
        docker tag "$LOCAL_IMAGE" "${REGISTRY_IMAGE}:${tag}"
        with_backoff 3 5 docker push "${REGISTRY_IMAGE}:${tag}"
      done

      log INFO "registry push completed for $REGISTRY_IMAGE"
    }

    main "$@"
