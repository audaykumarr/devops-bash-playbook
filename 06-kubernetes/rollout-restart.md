# `rollout-restart.sh`

        ## Problem Statement
        Restarting Kubernetes workloads safely requires targeting the right resources and waiting for the rollout to settle. This script wraps the common `kubectl rollout restart` flow with validation and status checks.

        ## When To Use It
        - A new ConfigMap or Secret requires pod restarts.
- An operator needs to restart a deployment without changing the manifest.

        ## Prerequisites
        - Bash 4+
- `kubectl` configured with access to the cluster

        ## How It Works
        - Finds matching resources by namespace, kind, and label selector.
- Performs a rollout restart on each matched resource.
- Waits for rollout completion before moving to the next item.

        ## Example Usage
        ```bash
./06-kubernetes/rollout-restart.sh --namespace platform --selector app=myapp --kind deployment --timeout 300s
```

        ## Expected Output
        - One rollout status stream per resource.
- A completion log entry for each restarted workload.

        ## Failure Scenarios
        - The selector matches no resources.
- The rollout never stabilizes before the timeout expires.
