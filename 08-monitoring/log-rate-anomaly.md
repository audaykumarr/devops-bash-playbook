# `log-rate-anomaly.sh`

## Problem Statement
Many production issues show up first as a sudden burst of repetitive log lines. This script provides a quick threshold-based detector for that pattern.

## When To Use It
- In small environments without full log analytics.
- During incident triage when you need a quick signal from logs.

## Prerequisites
- Bash 4+
- A log file or systemd journal access

## How It Works
- Counts recent log lines from a file or journal window.
- Compares the observed count to a configured threshold.
- Exits nonzero when the threshold is exceeded.

## Example Usage
```bash
./08-monitoring/log-rate-anomaly.sh \
  --journal-unit nginx \
  --threshold 400 \
  --window-minutes 10
```

## Expected Output
- A summary line with observed log volume and threshold.
- Exit code `1` when a burst is detected.

## Failure Scenarios
- The log file path is wrong.
- The chosen threshold is too low and creates noise.

