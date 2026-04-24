# `load-balancer-smoke-test.sh`

## Problem Statement
After a deploy or infrastructure change, a load balancer may appear healthy while only a subset of backends are actually serving traffic. This script runs repeated requests and checks both status codes and backend distribution headers.

## When To Use It
- After updating a load balancer or ingress.
- During canary checks before widening traffic.

## Prerequisites
- Bash 4+
- `curl`, `awk`, `sort`, `uniq`

## How It Works
- Sends repeated requests to the same URL.
- Checks that the returned HTTP status matches expectations.
- Counts unique backend header values if your platform exposes one.

## Example Usage
```bash
./03-networking/load-balancer-smoke-test.sh \
  --url https://app.example.com/healthz \
  --requests 12 \
  --backend-header X-Served-By
```

## Expected Output
- A summary line with request count, bad statuses, and backends seen.
- Exit code `0` when all checks pass.

## Failure Scenarios
- The endpoint returns intermittent 5xx responses.
- The backend header is absent because the platform does not add it.

