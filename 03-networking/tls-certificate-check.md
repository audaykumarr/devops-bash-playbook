# `tls-certificate-check.sh`

## Problem Statement
Expiring TLS certificates can take down healthy services with little warning. This script checks one or more endpoints and fails when a certificate is inside the warning window.

## When To Use It
- In daily cron jobs for external endpoints.
- Before planned traffic shifts or DNS changes.

## Prerequisites
- Bash 4+
- `openssl`

## How It Works
- Opens a TLS connection to each host and port.
- Uses `openssl x509 -checkend` to compare expiry against the warning threshold.
- Exits nonzero if any target is nearing expiry.

## Example Usage
```bash
./03-networking/tls-certificate-check.sh \
  --targets api.example.com:443,cdn.example.com:443 \
  --warning-days 21
```

## Expected Output
- One INFO or ERROR line per endpoint.
- Exit code `1` when at least one certificate is too close to expiry.

## Failure Scenarios
- The endpoint is not reachable.
- The target does not present a valid certificate chain.

