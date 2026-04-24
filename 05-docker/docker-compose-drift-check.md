# `docker-compose-drift-check.sh`

## Problem Statement
Compose-managed services drift when operators change environment files or service definitions outside the expected deploy flow. This script compares the rendered compose configuration to a recorded approved hash.

## When To Use It
- Before deploying a compose stack.
- In cron or CI jobs that watch for drift in smaller environments.

## Prerequisites
- Bash 4+
- Docker Compose v2

## How It Works
- Renders the effective compose configuration.
- Hashes it and compares the result to a stored baseline.
- Initializes the state file automatically if none exists yet.

## Example Usage
```bash
./05-docker/docker-compose-drift-check.sh \
  --compose-file docker-compose.prod.yml \
  --state-file state/prod-compose.sha256
```

## Expected Output
- A warning when the state file is initialized.
- An INFO line comparing current and recorded hashes.

## Failure Scenarios
- Docker Compose is not installed.
- The compose file references missing environment variables or files.

