# `rollback.sh`

        ## Problem Statement
        A release demo is incomplete without a clean rollback path. This companion project script shows how versioned release directories make reversions straightforward.

        ## When To Use It
        - You are demonstrating rollback mechanics to a team or interviewer.
- A test deployment in the mini pipeline needs to be reverted quickly.

        ## Prerequisites
        - Bash 4+
- At least two release directories created by `pipeline.sh`

        ## How It Works
        - Finds the previous release directory on disk.
- Re-points the live symlink to that release.
- Validates service health before reporting rollback success.

        ## Example Usage
        ```bash
./projects/mini-ci-cd/rollback.sh --release-root /srv/releases --current-link /srv/current --health-url https://app.example.com/healthz
```

        ## Expected Output
        - A rollback log with the selected release path.
- Exit code `0` when the previous release becomes healthy.

        ## Failure Scenarios
        - Only one release exists.
- The restored release still fails health checks.
