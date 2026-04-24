# `bootstrap.sh`

        ## Problem Statement
        Provisioning a new Linux host should be repeatable and reviewable. This project script creates a baseline application host with packages, directories, and optional kernel tuning in one pass.

        ## When To Use It
        - You are preparing a fresh VM for application deployments.
- A team needs a transparent bootstrap alternative to larger config-management systems for a small environment.

        ## Prerequisites
        - Bash 4+
- Sudo access on a Linux host
- A supported package manager

        ## How It Works
        - Installs a configurable list of baseline packages.
- Creates a deploy user and application directories if they do not already exist.
- Optionally applies a sysctl file for host tuning.

        ## Example Usage
        ```bash
sudo ./projects/server-bootstrap/bootstrap.sh --user deploy --app-dir /srv/apps --packages curl,jq,git,nginx --sysctl-file projects/server-bootstrap/configs/sysctl.conf
```

        ## Expected Output
        - Installed packages, created directories, and a final bootstrap log line.
- Optional sysctl reload output when a tuning file is provided.

        ## Failure Scenarios
        - The host has no supported package manager.
- The sysctl file contains invalid kernel settings.
