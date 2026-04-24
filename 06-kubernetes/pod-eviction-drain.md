# `pod-eviction-drain.sh`

## Problem Statement
Node maintenance often fails because `kubectl drain` is run inconsistently or with the wrong flags under pressure. This script standardizes the drain flow and supports dry-run rehearsals.

## When To Use It
- Before node patching or replacement.
- During controlled cluster maintenance windows.

## Prerequisites
- Bash 4+
- `kubectl` access to the cluster

## How It Works
- Cordon the node first.
- Drain workloads with explicit flags for daemonsets and `emptyDir`.
- Log the exact node and timeout used.

## Example Usage
```bash
./06-kubernetes/pod-eviction-drain.sh \
  --node ip-10-0-1-12 \
  --timeout 600s
```

## Expected Output
- Cordon and drain output from `kubectl`.
- A final INFO line when the drain completes.

## Failure Scenarios
- A pod disruption budget blocks eviction.
- Cluster permissions do not allow node drain operations.

