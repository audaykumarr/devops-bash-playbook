# `systemd-unit-audit.sh`

## Problem Statement
Servers often carry hidden service failures that only surface during maintenance or outages. This script captures failing and unexpectedly inactive systemd services into a report.

## When To Use It
- Before patching or rebooting a server.
- During host acceptance checks after bootstrap or migration.

## Prerequisites
- Bash 4+
- `systemctl`

## How It Works
- Lists failed services.
- Lists enabled services that are not active.
- Writes the result into a timestampable report file.

## Example Usage
```bash
./02-system-automation/systemd-unit-audit.sh \
  --report reports/systemd-audit.txt \
  --ignore-regex 'user@|session'
```

## Expected Output
- A text report with failed and inactive services.
- A final INFO log with the report path.

## Failure Scenarios
- The host does not use systemd.
- Permissions prevent inspection of some units.

