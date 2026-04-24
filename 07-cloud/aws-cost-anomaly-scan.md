# `aws-cost-anomaly-scan.sh`

## Problem Statement
Cloud spend surprises are usually found too late. This script compares yesterday’s AWS cost with a recent baseline and fails when the jump is suspiciously large.

## When To Use It
- In daily budget monitoring jobs.
- After major infrastructure rollouts or scaling events.

## Prerequisites
- Bash 4+
- AWS CLI access to Cost Explorer
- Python 3

## How It Works
- Pulls daily unblended cost from AWS Cost Explorer.
- Calculates a simple recent average.
- Exits nonzero if yesterday exceeds the configured spike threshold.

## Example Usage
```bash
./07-cloud/aws-cost-anomaly-scan.sh \
  --lookback-days 10 \
  --spike-percent 35
```

## Expected Output
- A line showing baseline, yesterday, and delta percentage.
- Exit code `1` when a cost anomaly is detected.

## Failure Scenarios
- Cost Explorer is not enabled or accessible.
- The account does not yet have enough recent data points.

