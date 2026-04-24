# `port-reachability.sh`

        ## Problem Statement
        Networking issues often show up as simple port reachability problems, but engineers still end up testing endpoints manually. This script turns that check into a repeatable, alertable workflow.

        ## When To Use It
        - You need to verify east-west service connectivity after a deploy or firewall change.
- A runbook calls for checking a matrix of hosts and service ports.

        ## Prerequisites
        - Bash 4+
- `nc` or a compatible netcat implementation

        ## How It Works
        - Accepts comma-separated host and port lists.
- Checks every host/port combination and logs the result.
- Exits nonzero if any endpoint is unreachable so CI or cron can alert on it.

        ## Example Usage
        ```bash
./03-networking/port-reachability.sh --hosts api.internal,db.internal --ports 443,5432 --timeout 2
```

        ## Expected Output
        - One log line per endpoint plus a final summary.
- Exit code `1` when at least one endpoint fails.

        ## Failure Scenarios
        - DNS resolution fails before a TCP connection is attempted.
- Firewall or routing issues block traffic to one or more targets.
