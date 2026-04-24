# `host-resource-check.sh`

        ## Problem Statement
        A simple but reliable host health check is still one of the most useful monitoring building blocks. This script measures CPU, memory, and disk pressure and optionally forwards alerts to a dispatcher.

        ## When To Use It
        - You need lightweight monitoring on VMs without a full agent stack.
- A cron job or user-data script should warn when a host is under pressure.

        ## Prerequisites
        - Bash 4+
- `top`, `free`, `df`, and `awk` on the target host

        ## How It Works
        - Collects CPU, memory, and disk utilization using common Linux tools.
- Compares each value to configurable thresholds.
- Calls an alerting script when a threshold is crossed, or logs a warning locally.

        ## Example Usage
        ```bash
./08-monitoring/host-resource-check.sh --cpu 80 --memory 75 --disk 90 --alert-script ./08-monitoring/alert-dispatch.sh
```

        ## Expected Output
        - A summary line with current resource usage.
- Warning or alert output if thresholds are crossed.

        ## Failure Scenarios
        - The host lacks one of the required Linux utilities.
- The alerting script path is invalid and alerts cannot be dispatched externally.
