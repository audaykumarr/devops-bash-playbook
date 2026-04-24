# `notify.sh`

        ## Problem Statement
        Monitoring loops need a dedicated notification function so the check logic stays focused. This project helper posts alert payloads to a webhook or logs them locally during testing.

        ## When To Use It
        - You are using the monitoring project with a chatops or webhook endpoint.
- You want the monitoring loop to stay independent from any single alert transport.

        ## Prerequisites
        - Bash 4+
- `curl` if using a webhook transport

        ## How It Works
        - Accepts a check name, severity, and message.
- Posts a small JSON payload to `WEBHOOK_URL` when configured.
- Falls back to warning logs in development environments.

        ## Example Usage
        ```bash
WEBHOOK_URL=https://alerts.example.com/hook ./projects/monitoring-alert-system/notify.sh --severity critical --check api-health --message 'health endpoint returned 503'
```

        ## Expected Output
        - A webhook post or a local warning log line.
- Exit code `0` on successful delivery or local fallback.

        ## Failure Scenarios
        - The webhook receiver is unreachable.
- The caller omits a required check name or message.
