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

    AWS_REGION="${AWS_REGION:-us-east-1}"
    TAG_KEY=""
    TAG_VALUE=""
    OUTPUT_FILE="reports/ec2-instance-audit.tsv"

    usage() {
      cat <<'EOF'
    Usage: aws-instance-audit.sh --tag-key Environment --tag-value production [--region us-east-1] [--output reports/ec2.tsv]
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --region) AWS_REGION="$2"; shift 2 ;;
          --tag-key) TAG_KEY="$2"; shift 2 ;;
          --tag-value) TAG_VALUE="$2"; shift 2 ;;
          --output) OUTPUT_FILE="$2"; shift 2 ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$TAG_KEY" ]] || die "--tag-key is required"
      [[ -n "$TAG_VALUE" ]] || die "--tag-value is required"
      require_cmd aws mkdir dirname
      ensure_dir "$(dirname "$OUTPUT_FILE")"

      aws ec2 describe-instances         --region "$AWS_REGION"         --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" "Name=instance-state-name,Values=running,stopped"         --query 'Reservations[].Instances[].[
          Tags[?Key==`Name`]|[0].Value,
          InstanceId,
          State.Name,
          Placement.AvailabilityZone,
          PrivateIpAddress,
          IamInstanceProfile.Arn,
          join(`,`, SecurityGroups[].GroupId)
        ]'         --output text > "$OUTPUT_FILE"

      log INFO "EC2 audit written to $OUTPUT_FILE"
    }

    main "$@"
