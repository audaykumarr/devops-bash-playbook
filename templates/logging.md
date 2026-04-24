# `logging.sh`

        ## Problem Statement
        Operational Bash scripts need structured logs that are easy to read in CI jobs, cron output, and incident notes. This template isolates logging semantics into a small reusable module.

        ## When To Use It
        - You want a standalone logging helper without sourcing the full common library.
- You are prototyping a new script and only need severity-based log helpers.

        ## Prerequisites
        - Bash 4+

        ## How It Works
        - Maps severity strings to numeric values.
- Suppresses messages below the configured `LOG_LEVEL`.
- Writes ISO-8601 UTC timestamps to stderr.

        ## Example Usage
        ```bash
LOG_LEVEL=DEBUG source ./templates/logging.sh && log_info "deployment started"
```

        ## Expected Output
        - A single log line with timestamp, severity, and message.
- No output for suppressed levels.

        ## Failure Scenarios
        - The log level is invalid and falls back to INFO semantics.
- The calling script redirects stderr away from the console.
