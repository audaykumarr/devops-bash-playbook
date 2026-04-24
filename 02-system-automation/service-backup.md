# `service-backup.sh`

        ## Problem Statement
        Service configuration and mutable application data often live in multiple directories, making ad hoc backups easy to miss. This script packages those directories into a versioned archive with retention controls.

        ## When To Use It
        - You need a quick backup before patching or deploying a service.
- A team wants a cron-safe backup wrapper for service-owned directories.

        ## Prerequisites
        - Bash 4+
- `tar`, `find`, and `systemctl` on the target host
- Read access to the source directories

        ## How It Works
        - Validates each source directory before running.
- Optionally records service state and then archives the requested paths into a timestamped tarball.
- Deletes old backups for the same service name after the run.

        ## Example Usage
        ```bash
sudo ./02-system-automation/service-backup.sh --service myapp --sources /etc/myapp,/srv/myapp --backup-dir /var/backups/myapp
```

        ## Expected Output
        - A `.tar.gz` archive in the chosen backup directory.
- A warning if the service is already stopped.

        ## Failure Scenarios
        - A source directory is missing.
- The host does not have enough free space to write the archive.
