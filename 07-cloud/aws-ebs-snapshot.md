# `aws-ebs-snapshot.sh`

        ## Problem Statement
        Disk snapshots are a common pre-maintenance guardrail, but manually tracking attached volumes is error-prone. This script creates tagged EBS snapshots for every volume on one or more instances.

        ## When To Use It
        - You want a pre-deploy or pre-patch rollback point for EC2 instances.
- An operations team needs consistent snapshot tags for retention workflows.

        ## Prerequisites
        - Bash 4+
- AWS CLI configured with EC2 snapshot permissions

        ## How It Works
        - Enumerates attached volumes for each instance.
- Creates tagged snapshots so ownership and retention are visible later.
- Optionally waits for snapshots to complete before exiting.

        ## Example Usage
        ```bash
./07-cloud/aws-ebs-snapshot.sh --instances i-0123456789abcdef0,i-0fedcba9876543210 --retention-days 14 --wait
```

        ## Expected Output
        - A snapshot ID log entry for every attached volume.
- Optional blocking completion if `--wait` is set.

        ## Failure Scenarios
        - The instance list includes a nonexistent ID.
- Snapshot creation is throttled or denied by IAM policy.
