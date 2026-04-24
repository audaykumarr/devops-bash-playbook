# `common.sh`

        ## Problem Statement
        Most repository scripts need the same primitives for logging, retries, dry-run behavior, and locking. This helper prevents every folder from reinventing those patterns differently.

        ## When To Use It
        - You are writing a new operational script in this repository.
- You want a shared, low-friction way to log, fail, retry, or gate execution.

        ## Prerequisites
        - Bash 4+
- `flock` for scripts that use lock files

        ## How It Works
        - Normalizes log formatting and error messages.
- Provides command checks, retries, dry-run support, and lock acquisition.
- Keeps scripts smaller by moving repetitive functions into one place.

        ## Example Usage
        ```bash
source ./utils/common.sh && log INFO "shared helper loaded"
```

        ## Expected Output
        - No output beyond the requested log line.
- Helper functions become available to the calling shell.

        ## Failure Scenarios
        - A caller relies on a missing external command and forgets to call `require_cmd`.
- Lock acquisition fails because another job is already running.
