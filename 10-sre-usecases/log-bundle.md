# `log-bundle.sh`

        ## Problem Statement
        Log capture is one of the first tasks during troubleshooting, but recent journal output and file-based logs are often scattered across systems. This script collects both into one archive.

        ## When To Use It
        - You need recent logs from several services quickly.
- A responder wants a portable log bundle for triage or escalation.

        ## Prerequisites
        - Bash 4+
- `journalctl`, `tail`, `tar`, and `mktemp` on the target host

        ## How It Works
        - Collects recent `journalctl` output for named services.
- Tails file-based logs when specific paths are provided.
- Compresses everything into a single archive for sharing or retention.

        ## Example Usage
        ```bash
sudo ./10-sre-usecases/log-bundle.sh --services nginx,myapp --log-paths /var/log/nginx/access.log,/var/log/myapp/app.log --since '-30 min' --output-file bundles/logs/app-incident.tar.gz
```

        ## Expected Output
        - A compressed archive containing journal excerpts and tailed log files.
- An INFO log line with the bundle location.

        ## Failure Scenarios
        - One of the requested log paths does not exist.
- The process lacks permission to read one of the service journals.
