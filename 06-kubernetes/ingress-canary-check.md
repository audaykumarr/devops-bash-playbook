# `ingress-canary-check.sh`

## Problem Statement
Ingress canaries often look healthy at the controller level while still serving the wrong application response. This script validates both status code and response content before widening traffic.

## When To Use It
- During canary or blue-green traffic shifts.
- After ingress changes, DNS moves, or new TLS cert installation.

## Prerequisites
- Bash 4+
- `curl`

## How It Works
- Sends requests to the ingress IP or URL with a forced `Host` header.
- Validates status code and optional body content.
- Retries a small number of times before failing.

## Example Usage
```bash
./06-kubernetes/ingress-canary-check.sh \
  --url https://1.2.3.4/healthz \
  --host-header app.example.com \
  --expected-substring ok
```

## Expected Output
- Warning logs during retries.
- A final INFO line when the canary response is healthy.

## Failure Scenarios
- The ingress route is not yet configured.
- The app responds with the right status but the wrong body content.

