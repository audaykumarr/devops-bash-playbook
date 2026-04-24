# `log-rotator.sh`

        ## Problem Statement
        Long-running services can fill disks quickly when log rotation is not consistently configured. This script provides a lightweight safety net for custom app logs and ephemeral environments.

        ## When To Use It
        - A service writes custom logs outside the system logrotate policy.
- You need a scheduled cleanup job on a small VM or CI runner.

        ## Prerequisites
        - Bash 4+
- `find`, `gzip`, and `stat` on the target host
- Permission to read and truncate target logs

        ## How It Works
        - Finds oversized log files that match the requested pattern.
- Copies the current log to a timestamped archive, compresses it, and truncates the original file.
- Deletes archives older than the configured retention window.

        ## Example Usage
        ```bash
sudo ./01-basics/log-rotator.sh --dir /var/log/myapp --pattern '*.log' --max-size-mb 100 --retention-days 14
```

        ## Expected Output
        - Archived `.gz` files with timestamps.
- An INFO log for each rotation and a completion message.

        ## Failure Scenarios
        - The process lacks permissions to truncate the live log file.
- A log grows faster than the scheduled rotation cadence can handle.
