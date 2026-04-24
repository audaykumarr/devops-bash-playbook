# `release-note-generator.sh`

## Problem Statement
Release notes are often skipped because teams do not have a fast way to summarize what changed between deploys. This script turns Git history into a release note artifact.

## When To Use It
- Before tagging or deploying a release.
- In CI pipelines that publish artifacts or release descriptions.

## Prerequisites
- Bash 4+
- Git history available locally

## How It Works
- Accepts a start ref and optional end ref.
- Reads commit subjects in the range.
- Writes a Markdown release note file.

## Example Usage
```bash
./04-ci-cd/release-note-generator.sh \
  --from-ref v1.4.0 \
  --to-ref HEAD \
  --output artifacts/release-notes.md
```

## Expected Output
- A Markdown file containing the commit list for the release.
- A final INFO log with the file path.

## Failure Scenarios
- The start ref does not exist.
- Git history is shallow and does not include the full range.

