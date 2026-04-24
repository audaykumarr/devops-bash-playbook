# `json-log-filter.sh`

## Problem Statement
Incident responders regularly need to isolate a subset of structured logs by level, service, and time window. This script turns that workflow into a repeatable filter.

## When To Use It
- Your applications emit JSON logs.
- You need a fast local triage tool for errors or noisy services.

## Prerequisites
- Bash 4+
- `jq`
- A JSON log file with predictable fields

## How It Works
- Validates the input log file.
- Builds a small `jq` filter based on the provided selectors.
- Prints matching lines or just a count.

## Example Usage
```bash
./01-basics/json-log-filter.sh \
  --file logs/api.json \
  --level error \
  --service payments \
  --since-unix 1713974400
```

## Expected Output
- Matching JSON log lines.
- Or a single numeric count when `--summary-only` is used.

## Failure Scenarios
- The log file is missing.
- The file contains malformed JSON that `jq` cannot parse.

