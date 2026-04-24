# `deploy-release.sh`

        ## Problem Statement
        Release deployment should be deterministic, reversible, and observable. This script uses versioned release directories plus a symlink swap so deployments stay fast and rollback-friendly.

        ## When To Use It
        - You deploy tarball artifacts to a VM or bare-metal host.
- You want a Bash-native alternative to more complex release tooling.

        ## Prerequisites
        - Bash 4+
- `tar`, `ln`, and `curl` on the deployment host
- A restart command for the target service

        ## How It Works
        - Extracts the release artifact into a timestamped directory.
- Atomically updates the `current` symlink to the new release.
- Restarts the application and waits for a healthy HTTP response before declaring success.

        ## Example Usage
        ```bash
./04-ci-cd/deploy-release.sh --archive artifacts/release.tgz --releases-dir /srv/releases --current-link /srv/current --health-url https://app.example.com/healthz --restart-cmd 'sudo systemctl restart myapp'
```

        ## Expected Output
        - A new timestamped release directory and updated symlink.
- Health-check log lines confirming rollout success.

        ## Failure Scenarios
        - The artifact is corrupt or missing required files.
- The service restarts but never becomes healthy before retries are exhausted.
