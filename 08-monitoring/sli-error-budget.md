# `sli-error-budget.sh`

## Problem Statement
During incidents, teams often know request counts and failures but still need a quick answer to “how much error budget is left?” This script provides that answer from raw numbers.

## When To Use It
- During incident response when dashboards lag or are unavailable.
- In lightweight reporting jobs that compute SLO burn from exported metrics.

## Prerequisites
- Bash 4+
- Python 3

## How It Works
- Accepts total requests, failed requests, and the SLO target.
- Calculates availability, allowed failures, and remaining budget.
- Exits nonzero when the budget is already exhausted.

## Example Usage
```bash
./08-monitoring/sli-error-budget.sh \
  --total-requests 120000 \
  --failed-requests 63 \
  --slo-percent 99.9
```

## Expected Output
- Availability percentage.
- Allowed failures and remaining budget.

## Failure Scenarios
- Total requests are zero.
- Failed requests already exceed the allowed budget.

