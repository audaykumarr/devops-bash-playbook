# `file-permission-audit.sh`

        ## Problem Statement
        World-writable files and directories are easy to miss and can create real privilege escalation risk. This script scans target paths and writes findings to a report for review.

        ## When To Use It
        - You are auditing shared hosts or application directories.
- A security review calls for a quick sweep of writable paths.

        ## Prerequisites
        - Bash 4+
- `find` and `stat` on the target host

        ## How It Works
        - Scans each requested path without crossing filesystem boundaries.
- Reports files and directories that are world-writable.
- Writes all findings to a persistent report for follow-up work.

        ## Example Usage
        ```bash
sudo ./09-security/file-permission-audit.sh --paths /etc,/srv/app --report reports/permission-audit.txt
```

        ## Expected Output
        - A text report listing any world-writable paths discovered.
- A completion log line even if the report is empty.

        ## Failure Scenarios
        - One of the requested paths does not exist.
- The script lacks permission to traverse part of the directory tree.
