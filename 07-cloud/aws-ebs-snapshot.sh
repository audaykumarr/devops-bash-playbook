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
    INSTANCE_IDS=""
    RETENTION_DAYS=7
    WAIT_FOR_COMPLETION="false"

    usage() {
      cat <<'EOF'
    Usage: aws-ebs-snapshot.sh --instances i-0123456789abcdef0,i-0fedcba9876543210 [--retention-days 7] [--wait]
EOF
    }

    main() {
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --instances) INSTANCE_IDS="$2"; shift 2 ;;
          --region) AWS_REGION="$2"; shift 2 ;;
          --retention-days) RETENTION_DAYS="$2"; shift 2 ;;
          --wait) WAIT_FOR_COMPLETION="true"; shift ;;
          -h|--help) usage; exit 0 ;;
          *) die "unknown argument: $1" ;;
        esac
      done

      [[ -n "$INSTANCE_IDS" ]] || die "--instances is required"
      validate_positive_int "$RETENTION_DAYS"
      require_cmd aws

      IFS=',' read -r -a instances <<< "$INSTANCE_IDS"
      for instance_id in "${instances[@]}"; do
        mapfile -t volume_ids < <(aws ec2 describe-volumes           --region "$AWS_REGION"           --filters "Name=attachment.instance-id,Values=$instance_id"           --query 'Volumes[].VolumeId'           --output text)

        for volume_id in "${volume_ids[@]}"; do
          snapshot_id="$(aws ec2 create-snapshot             --region "$AWS_REGION"             --volume-id "$volume_id"             --description "Automated snapshot for $instance_id"             --tag-specifications "ResourceType=snapshot,Tags=[{Key=CreatedBy,Value=devops-bash-playbook},{Key=RetentionDays,Value=$RETENTION_DAYS},{Key=SourceInstance,Value=$instance_id}]"             --query 'SnapshotId'             --output text)"
          log INFO "created snapshot $snapshot_id for volume $volume_id"
          if [[ "$WAIT_FOR_COMPLETION" == "true" ]]; then
            aws ec2 wait snapshot-completed --region "$AWS_REGION" --snapshot-ids "$snapshot_id"
          fi
        done
      done
    }

    main "$@"
