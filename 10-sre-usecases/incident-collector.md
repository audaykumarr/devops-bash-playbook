# `incident-collector.sh`

        ## Problem Statement
        Incidents move faster when responders capture a stable diagnostic snapshot before systems recover or change again. This script bundles host and service context into an archive keyed by incident ID.

        ## When To Use It
        - An on-call engineer wants a repeatable evidence collection step.
- You need an attachment for a ticket, postmortem, or escalated support case.

        ## Prerequisites
        - Bash 4+
- `systemctl`, `journalctl`, `tar`, and common Linux observability tools
- Permission to read service logs and kernel messages

        ## How It Works
        - Creates a dedicated incident directory with host health snapshots.
- Captures service status and recent journals for each named service.
- Compresses the results so they can be attached to an issue or artifact store.

        ## Example Usage
        ```bash
sudo ./10-sre-usecases/incident-collector.sh --incident INC-1042 --services nginx,myapp,postgres --output-dir bundles/incidents
```

        ## Expected Output
        - A timestamped `.tar.gz` bundle containing host and service diagnostics.
- A completion log line with the archive path.

        ## Failure Scenarios
        - One of the requested services does not exist on the host.
- Permissions prevent reading recent journals or kernel messages.
