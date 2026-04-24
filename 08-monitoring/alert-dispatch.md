# `alert-dispatch.sh`

        ## Problem Statement
        Alert delivery is often glued together differently on every team. This script defines a small, reusable alert payload format that works with webhooks or local logs.

        ## When To Use It
        - You want a shared alerting primitive that monitoring and watchdog scripts can call.
- A team uses Slack, Teams, or an internal webhook relay for notifications.

        ## Prerequisites
        - Bash 4+
- `curl` if dispatching to an HTTP endpoint

        ## How It Works
        - Builds a structured JSON payload with service name, severity, message, and timestamp.
- Posts to a webhook when one is configured.
- Falls back to warning logs so alerts are still visible during development or offline testing.

        ## Example Usage
        ```bash
WEBHOOK_URL=https://alerts.example.com/hook ./08-monitoring/alert-dispatch.sh --severity critical --service checkout --message 'Deployment failed health checks'
```

        ## Expected Output
        - A successful webhook post or a structured warning log line.
- Exit code `0` when the alert is dispatched or logged locally.

        ## Failure Scenarios
        - The webhook URL is malformed.
- The remote alert receiver returns a non-success HTTP code.
