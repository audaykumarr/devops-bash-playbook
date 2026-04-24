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

    IMAGE_NAME=""
    IMAGE_TAG="latest"
    PLATFORMS="linux/amd64"
    CONTEXT_DIR="."
    DOCKERFILE="Dockerfile"
    PUSH_IMAGE="false"

    usage() {
      cat <<'EOF'
    Usage: docker-buildx.sh --image ghcr.io/acme/app --tag 1.2.3 [--platforms linux/amd64,linux/arm64] [--push]
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --image) IMAGE_NAME="$2"; shift 2 ;;
          --tag) IMAGE_TAG="$2"; shift 2 ;;
          --platforms) PLATFORMS="$2"; shift 2 ;;
          --context) CONTEXT_DIR="$2"; shift 2 ;;
          --dockerfile) DOCKERFILE="$2"; shift 2 ;;
          --push) PUSH_IMAGE="true"; shift ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$IMAGE_NAME" ]] || die "--image is required"
      require_dir "$CONTEXT_DIR"
      require_file "$DOCKERFILE"
      require_cmd docker

      docker buildx inspect devops-playbook-builder >/dev/null 2>&1 || docker buildx create --name devops-playbook-builder --use
      docker buildx build         --platform "$PLATFORMS"         --file "$DOCKERFILE"         --tag "${IMAGE_NAME}:${IMAGE_TAG}"         $([[ "$PUSH_IMAGE" == "true" ]] && printf -- '--push' || printf -- '--load')         "$CONTEXT_DIR"

      log INFO "docker buildx completed image=${IMAGE_NAME}:${IMAGE_TAG} platforms=$PLATFORMS"
    }

    main "$@"
