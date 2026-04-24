# `auto-heal-service.sh`

        ## Problem Statement
        Auto-healing can reduce time-to-recovery for simple service failures, but only if it avoids restart loops and keeps state between runs. This script implements a guarded health-check and restart workflow.

        ## When To Use It
        - You run a service with a reliable health endpoint and controlled restart command.
- A cron-driven auto-heal mechanism is acceptable for your environment.

        ## Prerequisites
        - Bash 4+
- `curl`, `bash`, and `flock` on the target host
- A health endpoint and restart command for the service

        ## How It Works
        - Checks the service health endpoint once per invocation.
- Tracks consecutive failures and only restarts after a threshold is crossed.
- Uses a cooldown file and lock file to prevent overlapping or repeated restarts.

        ## Example Usage
        ```bash
./10-sre-usecases/auto-heal-service.sh --health-url https://app.example.com/healthz --service myapp --restart-cmd 'sudo systemctl restart myapp' --failure-threshold 3
```

        ## Expected Output
        - Healthy logs when the service responds successfully.
- A warning log and restart action only after repeated failures.

        ## Failure Scenarios
        - The health endpoint is unreachable even though the service is actually healthy.
- Cooldown suppression prevents another restart during a prolonged incident.
