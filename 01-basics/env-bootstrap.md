# `env-bootstrap.sh`

        ## Problem Statement
        New environments regularly fail because `.env` files are copied by hand, drift away from examples, or miss required values. This script standardizes onboarding and local bootstrap flows.

        ## When To Use It
        - You are onboarding a new service or teammate.
- A CI job or local environment needs a generated `.env` from a committed example file.

        ## Prerequisites
        - Bash 4+
- A committed example file such as `.env.example`

        ## How It Works
        - Reads a source environment file line by line.
- Preserves comments while allowing exported environment variables to override sample values.
- Backs up existing files and validates required keys after generation.

        ## Example Usage
        ```bash
./01-basics/env-bootstrap.sh --source .env.example --output .env --required AWS_REGION,APP_ENV
```

        ## Expected Output
        - A generated `.env` file with secure permissions.
- A backup file if an older `.env` already existed.

        ## Failure Scenarios
        - The source example file is missing.
- A required variable is still empty after generation.
