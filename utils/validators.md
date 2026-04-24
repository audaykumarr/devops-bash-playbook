# `validators.sh`

        ## Problem Statement
        Argument validation is one of the easiest places for shell scripts to become unsafe. This helper centralizes the most common checks used across deployment, monitoring, and cloud automation flows.

        ## When To Use It
        - You want fast validation for ports, paths, URLs, or required environment variables.
- You want consistent failure messages across scripts.

        ## Prerequisites
        - Bash 4+
- The shared `utils/common.sh` helper

        ## How It Works
        - Provides simple validators that fail loudly and early.
- Sources the common helper so every validation failure is logged consistently.
- Encodes common operational assumptions like valid port ranges and URL prefixes.

        ## Example Usage
        ```bash
source ./utils/validators.sh && validate_port 443
```

        ## Expected Output
        - No output when values are valid.
- A descriptive error if validation fails.

        ## Failure Scenarios
        - A caller passes an unset environment variable name.
- A file or directory path does not exist at runtime.
