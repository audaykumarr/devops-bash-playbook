# `k8s-rbac-audit.sh`

## Problem Statement
Kubernetes privilege creep is common, especially around `cluster-admin` and broad `admin` bindings. This script exports those bindings into a simple reviewable report.

## When To Use It
- During cluster access reviews.
- Before handing production clusters to a new team.

## Prerequisites
- Bash 4+
- `kubectl`
- `jq`

## How It Works
- Reads cluster role bindings in JSON form.
- Filters for high-privilege roles.
- Writes binding name, subject type, namespace, and subject name to a report.

## Example Usage
```bash
./09-security/k8s-rbac-audit.sh \
  --output reports/k8s-rbac-audit.txt
```

## Expected Output
- A tab-separated report of high-privilege subjects.
- A final INFO log with the report location.

## Failure Scenarios
- The cluster context is wrong.
- RBAC prevents listing cluster role bindings.

