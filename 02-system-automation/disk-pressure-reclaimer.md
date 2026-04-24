# `disk-pressure-reclaimer.sh`

## Problem Statement
Disk pressure incidents are messy when responders improvise deletions under time pressure. This script offers a controlled cleanup path for the most common reclaim targets.

## When To Use It
- Root disk usage is approaching dangerous levels.
- A temporary emergency cleanup is needed before a larger remediation.

## Prerequisites
- Bash 4+
- Optional: `journalctl`, `apt-get`, or `dnf`

## How It Works
- Prints disk usage before cleanup.
- Performs only the cleanup actions you explicitly enable.
- Prints disk usage again so operators can measure impact.

## Example Usage
```bash
sudo ./02-system-automation/disk-pressure-reclaimer.sh \
  --clean-journal \
  --clean-tmp \
  --vacuum-days 5
```

## Expected Output
- Filesystem usage before and after cleanup.
- Logs showing which cleanup actions ran.

## Failure Scenarios
- The process lacks permission to delete old files.
- The host uses a package manager outside the supported set.

