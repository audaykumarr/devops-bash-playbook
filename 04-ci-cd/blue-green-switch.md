# `blue-green-switch.sh`

## Problem Statement
Blue-green deployments need a disciplined switch step so teams can validate traffic movement and retain an easy rollback. This script flips a live symlink and waits for application health.

## When To Use It
- Your deployment model keeps blue and green releases side by side.
- You want a simple, auditable traffic switch command.

## Prerequisites
- Bash 4+
- A blue and green release directory layout
- Optional reload command for your web server or proxy

## How It Works
- Resolves the requested target color.
- Updates the live symlink to that directory.
- Optionally reloads the traffic-serving component and checks health.

## Example Usage
```bash
./04-ci-cd/blue-green-switch.sh \
  --target-color green \
  --health-url https://app.example.com/healthz \
  --reload-cmd "sudo systemctl reload nginx"
```

## Expected Output
- A final INFO line with the chosen color.
- Exit code `0` only when the health check succeeds.

## Failure Scenarios
- The target release directory is missing.
- The switched application never becomes healthy.

