# `process-watchdog.sh`

        ## Problem Statement
        Services occasionally die silently even when the host is otherwise healthy. This watchdog script detects missing processes, restarts them, and prevents restart storms with a state file.

        ## When To Use It
        - You run a legacy service without a robust supervisor.
- A cron-based watchdog is part of the current operational model.

        ## Prerequisites
        - Bash 4+
- `pgrep` and a working restart command
- Write access to the watchdog state directory

        ## How It Works
        - Checks for a matching process pattern using `pgrep -f`.
- Tracks restart attempts in a state file so it can stop after a safe limit.
- Optionally emits a critical alert if the restart limit is exceeded.

        ## Example Usage
        ```bash
./08-monitoring/process-watchdog.sh --process 'gunicorn: master' --restart-cmd 'sudo systemctl restart api' --alert-script ./08-monitoring/alert-dispatch.sh
```

        ## Expected Output
        - A healthy log line when the process exists or a restart log when it does not.
- A nonzero exit if restart suppression is triggered.

        ## Failure Scenarios
        - The process pattern is too broad and matches the wrong program.
- The restart command fails repeatedly and the watchdog hits its cap.
