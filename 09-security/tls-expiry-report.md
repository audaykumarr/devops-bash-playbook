# `tls-expiry-report.sh`

## Problem Statement
Security reviews often need a report, not just a pass or fail. This script records certificate expiry dates and days remaining for multiple endpoints.

## When To Use It
- Before audits or compliance reviews.
- As a weekly reporting job for exposed endpoints.

## Prerequisites
- Bash 4+
- `openssl`
- Python 3

## How It Works
- Connects to each TLS endpoint.
- Extracts the certificate expiry date.
- Calculates remaining days and writes everything to a TSV report.

## Example Usage
```bash
./09-security/tls-expiry-report.sh \
  --targets api.example.com:443,cdn.example.com:443 \
  --report reports/tls-expiry-report.tsv
```

## Expected Output
- A TSV report with target, expiry date, and remaining days.
- A final INFO log showing the report path.

## Failure Scenarios
- One or more endpoints cannot complete a TLS handshake.
- Python cannot parse a nonstandard certificate date string.

