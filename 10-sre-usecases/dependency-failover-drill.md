# `dependency-failover-drill.sh`

## Problem Statement
Failover plans become dangerous when they are never rehearsed. This script validates a fallback dependency first and then executes a switch command as a controlled drill.

## When To Use It
- During resilience exercises or game days.
- Before formal disaster recovery runbook reviews.

## Prerequisites
- Bash 4+
- Reachable primary and fallback health endpoints
- A safe switch command for the dependency consumer

## How It Works
- Checks the primary endpoint so the starting state is recorded.
- Ensures the fallback dependency is healthy.
- Runs the provided switch command, with optional dry-run support.

## Example Usage
```bash
./10-sre-usecases/dependency-failover-drill.sh \
  --primary-url https://primary-db-proxy/healthz \
  --fallback-url https://dr-db-proxy/healthz \
  --switch-cmd "kubectl set env deploy/api DB_ENDPOINT=dr-db-proxy"
```

## Expected Output
- Health-check logs for primary and fallback dependencies.
- An INFO line after the drill switch command runs.

## Failure Scenarios
- The fallback dependency is not healthy enough for a drill.
- The switch command is wrong or blocked by permissions.

