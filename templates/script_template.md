# `script_template.sh`

        ## Problem Statement
        Teams often copy older Bash scripts with inconsistent error handling and logging, which creates drift over time. This template gives contributors a single, production-friendly starting point.

        ## When To Use It
        - You are creating a new script in this repository.
- You want the same logging, validation, and dry-run patterns used elsewhere.

        ## Prerequisites
        - Bash 4+
- Access to `utils/common.sh` and `utils/validators.sh`

        ## How It Works
        - Parses flags in a predictable `while/case` loop.
- Sources shared libraries for logging and argument validation.
- Uses `run_cmd` so dry-run behavior is consistent.

        ## Example Usage
        ```bash
./templates/script_template.sh --target example --dry-run
```

        ## Expected Output
        - Timestamped log lines showing the target and dry-run action.
- Exit code `0` when required arguments are provided.

        ## Failure Scenarios
        - The target argument is missing.
- A later command fails and the global trap logs the failing line.
