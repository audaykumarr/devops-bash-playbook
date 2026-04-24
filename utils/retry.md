# `retry.sh`

        ## Problem Statement
        Operational systems often fail because scripts assume the network or a freshly deployed service will be ready immediately. This helper packages retry and wait semantics into reusable functions.

        ## When To Use It
        - You need exponential backoff for flaky remote calls.
- You want a simple helper for HTTP readiness checks.

        ## Prerequisites
        - Bash 4+
- `curl` for HTTP readiness checks
- The shared `utils/common.sh` helper

        ## How It Works
        - Retries arbitrary commands with increasing delays.
- Polls HTTP endpoints until a healthy status is observed or attempts run out.
- Uses the shared logging helper so retries are visible in job logs.

        ## Example Usage
        ```bash
source ./utils/retry.sh && wait_for_http_ok https://example.internal/healthz 5 2
```

        ## Expected Output
        - Repeated readiness log lines followed by success or failure.
- Exit code `0` only when the target recovers in time.

        ## Failure Scenarios
        - The endpoint never returns a healthy status.
- The caller provides invalid attempt counts or delay values.
