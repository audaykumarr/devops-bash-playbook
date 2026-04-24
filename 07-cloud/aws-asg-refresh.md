# `aws-asg-refresh.sh`

## Problem Statement
Refreshing an Auto Scaling Group by hand is error-prone during AMI or launch template rollouts. This script starts an instance refresh and can optionally wait until it finishes.

## When To Use It
- Rolling new AMIs through a server fleet.
- Updating launch templates after patching or hardening.

## Prerequisites
- Bash 4+
- AWS CLI permissions for Auto Scaling instance refreshes

## How It Works
- Starts a new instance refresh for the target Auto Scaling Group.
- Logs the refresh ID.
- Optionally polls until success or failure.

## Example Usage
```bash
AWS_REGION=us-east-1 ./07-cloud/aws-asg-refresh.sh \
  --asg-name prod-web \
  --wait
```

## Expected Output
- The refresh ID at start.
- Repeated status updates when `--wait` is used.

## Failure Scenarios
- The Auto Scaling Group name is wrong.
- The refresh fails because health checks never stabilize.

