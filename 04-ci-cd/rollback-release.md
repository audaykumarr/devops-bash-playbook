# `rollback-release.sh`

        ## Problem Statement
        Rolling back should be faster and safer than redeploying from scratch. This script re-points the live symlink to the previous release and validates service health before completing.

        ## When To Use It
        - A fresh deployment is unhealthy and you need a quick revert.
- You keep historical releases on disk for simple VM-based deployments.

        ## Prerequisites
        - Bash 4+
- A `current` symlink style deployment layout
- A working service restart command and health endpoint

        ## How It Works
        - Enumerates release directories in order.
- Selects the previous release as the rollback target.
- Swaps the live symlink, restarts the service, and verifies the health endpoint.

        ## Example Usage
        ```bash
./04-ci-cd/rollback-release.sh --releases-dir /srv/releases --current-link /srv/current --health-url https://app.example.com/healthz --restart-cmd 'sudo systemctl restart myapp'
```

        ## Expected Output
        - A log entry pointing to the restored release.
- Exit code `0` only when the rolled-back service becomes healthy.

        ## Failure Scenarios
        - Only one release exists on disk.
- The previous release also fails health checks after the rollback.
