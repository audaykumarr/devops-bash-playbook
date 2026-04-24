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

# Start and observe an Auto Scaling instance refresh from Bash for AMI or launch template rollouts.
# This gives teams a lightweight alternative when they do not want full deployment orchestration.

ASG_NAME=""
AWS_REGION="${AWS_REGION:-us-east-1}"
WAIT_FOR_COMPLETION="false"

usage() {
  printf '%s\n' \
    "Usage: aws-asg-refresh.sh --asg-name prod-web --region us-east-1 [--wait]"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --asg-name) ASG_NAME="$2"; shift 2 ;;
      --region) AWS_REGION="$2"; shift 2 ;;
      --wait) WAIT_FOR_COMPLETION="true"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  [[ -n "$ASG_NAME" ]] || die "--asg-name is required"
  require_cmd aws

  refresh_id="$(aws autoscaling start-instance-refresh \
    --auto-scaling-group-name "$ASG_NAME" \
    --region "$AWS_REGION" \
    --query 'InstanceRefreshId' \
    --output text)"
  log INFO "started instance refresh id=$refresh_id asg=$ASG_NAME"

  if [[ "$WAIT_FOR_COMPLETION" == "true" ]]; then
    while true; do
      status="$(aws autoscaling describe-instance-refreshes \
        --auto-scaling-group-name "$ASG_NAME" \
        --region "$AWS_REGION" \
        --query 'InstanceRefreshes[0].Status' \
        --output text)"
      log INFO "instance refresh status=$status"
      [[ "$status" == "Successful" ]] && break
      [[ "$status" == "Failed" || "$status" == "Cancelled" ]] && die "instance refresh ended with status=$status"
      sleep 15
    done
  fi
}

main "$@"
