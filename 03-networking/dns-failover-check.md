# `dns-failover-check.sh`

        ## Problem Statement
        DNS failover is only safe when health checks and record resolution tell a consistent story. This script gives operators a quick signal before they change traffic at the DNS layer.

        ## When To Use It
        - You run an active-passive service with primary and DR hostnames.
- An incident runbook asks whether traffic should fail over.

        ## Prerequisites
        - Bash 4+
- `dig`, `paste`, and `curl` installed
- Reachable health endpoints for both environments

        ## How It Works
        - Resolves the current IPs for the primary and secondary records.
- Checks both health endpoints with retries.
- Logs whether the environment looks safe to fail over or whether both sides are unhealthy.

        ## Example Usage
        ```bash
./03-networking/dns-failover-check.sh --primary app-primary.example.com --secondary app-dr.example.com --health-url https://app.example.com/healthz --secondary-health-url https://dr.example.com/healthz
```

        ## Expected Output
        - A log of current DNS answers and the health decision.
- Exit code `0` when at least one environment is healthy.

        ## Failure Scenarios
        - DNS resolution returns no records.
- Both endpoints stay unhealthy throughout the retry window.
