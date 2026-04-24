# `monitor.sh`

        ## Problem Statement
        This project ties lightweight checks and alerting together so teams can stand up basic monitoring without additional software. It shows how Bash can still model a clean check-dispatch architecture.

        ## When To Use It
        - You need a tiny monitoring loop for a small environment or demo.
- You want to teach how check definitions can be externalized into config.

        ## Prerequisites
        - Bash 4+
- `curl`, `df`, and `awk` on the host
- A check definition file and a notify script

        ## How It Works
        - Reads pipe-delimited checks from a config file.
- Evaluates HTTP and disk checks today, while leaving room for future types.
- Delegates alert delivery to `notify.sh` so the loop stays simple.

        ## Example Usage
        ```bash
./projects/monitoring-alert-system/monitor.sh --config projects/monitoring-alert-system/configs/checks.env --notify-script projects/monitoring-alert-system/notify.sh
```

        ## Expected Output
        - Per-check INFO logs or warning/critical notifications.
- A repeatable monitoring pass that can be scheduled with cron.

        ## Failure Scenarios
        - A config line is malformed.
- The monitoring host cannot reach a remote HTTP target.
