# `package-updater.sh`

        ## Problem Statement
        Patching hosts is a basic reliability and security task, but package commands vary across distributions. This script standardizes a safe update flow with retries and explicit manager detection.

        ## When To Use It
        - You run scheduled host patching on Linux servers.
- You need one Bash entry point that works across Ubuntu, RHEL, and Rocky-based systems.

        ## Prerequisites
        - Bash 4+
- Root or sudo access
- A supported package manager installed on the host

        ## How It Works
        - Detects the package manager automatically unless one is provided.
- Retries metadata refreshes and upgrades to survive transient mirror issues.
- Supports a security-focused update path when the package manager exposes one.

        ## Example Usage
        ```bash
sudo ./02-system-automation/package-updater.sh --manager auto --security-only
```

        ## Expected Output
        - Distribution-specific update output followed by repository log messages.
- Exit code `0` when the package transaction completes successfully.

        ## Failure Scenarios
        - No supported package manager is installed.
- Security-only mode is requested on apt without `unattended-upgrade` available.
