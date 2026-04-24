# `ssh-hardening-audit.sh`

        ## Problem Statement
        SSH remains a critical control surface on Linux hosts, and configuration drift can quietly weaken access controls. This script audits a few high-value hardening settings that teams commonly review.

        ## When To Use It
        - You are checking host posture before a security review.
- A base image or bootstrap role may have drifted from the expected SSH policy.

        ## Prerequisites
        - Bash 4+
- Read access to `sshd_config`

        ## How It Works
        - Reads the effective value for a handful of high-signal SSH settings.
- Logs PASS or FAIL for each expectation.
- Gives operators a quick view before they decide whether remediation is needed.

        ## Example Usage
        ```bash
sudo ./09-security/ssh-hardening-audit.sh --config /etc/ssh/sshd_config
```

        ## Expected Output
        - One PASS or FAIL line per audited setting.
- Exit code `0` even when findings exist, so the report can be reviewed manually.

        ## Failure Scenarios
        - The config file path is wrong.
- Important settings are only present in included files and not in the main config.
