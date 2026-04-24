# `aws-instance-audit.sh`

        ## Problem Statement
        Cloud inventories become stale quickly unless teams can regenerate them on demand. This script exports a tag-filtered EC2 audit report for reviews, migrations, and incident response.

        ## When To Use It
        - You need a quick inventory of production or staging instances.
- A change review asks for IAM profile and security group visibility by environment.

        ## Prerequisites
        - Bash 4+
- AWS CLI configured with permission to describe EC2 instances

        ## How It Works
        - Filters instances by tag key and value.
- Outputs key details including state, AZ, private IP, IAM profile, and security groups.
- Writes the audit into a TSV file that can be imported into spreadsheets or attached to tickets.

        ## Example Usage
        ```bash
AWS_REGION=us-east-1 ./07-cloud/aws-instance-audit.sh --tag-key Environment --tag-value production --output reports/prod-ec2.tsv
```

        ## Expected Output
        - A tab-separated audit report under `reports/`.
- A final log entry with the generated file path.

        ## Failure Scenarios
        - AWS credentials are missing or expired.
- The filter matches no instances and the output file is empty.
