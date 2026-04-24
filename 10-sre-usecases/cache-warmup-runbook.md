# `cache-warmup-runbook.sh`

## Problem Statement
Some applications depend on expensive caches that rebuild slowly after deployment or failover. This script warms selected endpoints ahead of live traffic.

## When To Use It
- Immediately after a deployment.
- Before expected traffic spikes or failover tests.

## Prerequisites
- Bash 4+
- `curl`
- Reachable warmup endpoints

## How It Works
- Accepts a comma-separated list of warmup URLs.
- Optionally sends a header for protected endpoints.
- Retries each warmup call before moving on.

## Example Usage
```bash
./10-sre-usecases/cache-warmup-runbook.sh \
  --urls https://app.example.com/warm/users,https://app.example.com/warm/catalog
```

## Expected Output
- One INFO line per warmed endpoint.
- Exit code `0` when all warmup calls succeed.

## Failure Scenarios
- The warmup endpoints are not exposed or require missing credentials.
- One endpoint stays unhealthy through all retries.

