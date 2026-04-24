# `aws-s3-sync.sh`

        ## Problem Statement
        S3 sync jobs often need encryption defaults, exclusion patterns, and safe retries. This script makes those decisions explicit so deployments and backups are more predictable.

        ## When To Use It
        - You publish static build artifacts or backups to S3.
- You need a safer wrapper around `aws s3 sync` for CI or cron jobs.

        ## Prerequisites
        - Bash 4+
- AWS CLI configured with S3 write access

        ## How It Works
        - Validates the source directory and S3 destination URI.
- Builds a sync command that enforces server-side encryption.
- Optionally loads exclusion patterns from a file and retries the transfer if AWS calls fail transiently.

        ## Example Usage
        ```bash
./07-cloud/aws-s3-sync.sh --source ./dist --destination s3://my-bucket/releases/app --exclude-file .syncignore --delete
```

        ## Expected Output
        - AWS sync progress followed by a completion log line.
- Encrypted objects uploaded to the target prefix.

        ## Failure Scenarios
        - The IAM role lacks `s3:PutObject` or `s3:DeleteObject` permissions.
- The exclude file references patterns that accidentally omit required artifacts.
