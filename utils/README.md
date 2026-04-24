# Utils

This folder contains sourced Bash libraries shared across the repository:

- `common.sh`: logging, retries, dry-run behavior, and lock handling
- `validators.sh`: common input validation helpers
- `retry.sh`: exponential backoff and HTTP readiness helpers

These files are intended to be sourced by executable scripts rather than run directly.
