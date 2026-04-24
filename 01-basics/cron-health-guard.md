# `cron-health-guard.sh`

## Problem Statement
Cron jobs often fail silently and leave behind stale state. This script checks a heartbeat file and triggers a recovery command only when the job looks genuinely stuck.

## When To Use It
- A scheduled sync, backup, or import job updates a heartbeat file while healthy.
- You want a safe watchdog around cron without introducing a new daemon.

## Prerequisites
- Bash 4+
- A heartbeat file updated by the monitored job
- A recovery command if you want auto-remediation

## How It Works
- Reads the heartbeat file modification time.
- Compares it with the allowed freshness threshold.
- Uses a lock file before launching the recovery command.

## Example Usage
```bash
./01-basics/cron-health-guard.sh \
  --heartbeat-file /var/run/daily-sync.heartbeat \
  --max-age-seconds 1200 \
  --recovery-cmd "sudo systemctl restart daily-sync"
```

## Expected Output
- An INFO line with the current heartbeat age.
- A WARN line only when the heartbeat is stale and recovery is triggered.

## Failure Scenarios
- The heartbeat file does not exist.
- The recovery command is missing when a stale heartbeat is detected.

