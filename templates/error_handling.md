# `error_handling.sh`

        ## Problem Statement
        Bash frequently fails in surprising ways unless scripts trap errors and clean up partial state. This template shows the minimal structure required for predictable failure handling.

        ## When To Use It
        - You need a reusable trap pattern for temporary files, lock files, or deployment state.
- You want errors to include the failing command and line number.

        ## Prerequisites
        - Bash 4+

        ## How It Works
        - Defines a no-op `cleanup` function that callers can override.
- Traps `ERR` and `EXIT` separately so cleanup still runs on normal exits.
- Logs failure context without leaking implementation details to callers.

        ## Example Usage
        ```bash
source ./templates/error_handling.sh
```

        ## Expected Output
        - Cleanup runs automatically on success and failure.
- Unhandled command errors are logged with line numbers.

        ## Failure Scenarios
        - A custom `cleanup` function itself fails.
- The parent script disables `set -e` and bypasses the trap semantics.
