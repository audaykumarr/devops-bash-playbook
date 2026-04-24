# `cluster-health-check.sh`

        ## Problem Statement
        Cluster incidents often begin with a quick health sweep across nodes, pods, PVCs, and recent warning events. This script packages those routine checks into one command for triage and operations reviews.

        ## When To Use It
        - You need a fast pre-deploy or post-incident cluster overview.
- An on-call engineer wants a single command for health context.

        ## Prerequisites
        - Bash 4+
- `kubectl` access to the cluster

        ## How It Works
        - Prints node status first so scheduling issues are visible immediately.
- Shows pod and PVC health either cluster-wide or in a single namespace.
- Pulls recent events because they usually explain why workloads are failing.

        ## Example Usage
        ```bash
./06-kubernetes/cluster-health-check.sh --namespace payments
```

        ## Expected Output
        - Tabular Kubernetes output that can be attached to incident notes.
- Exit code `0` unless `kubectl` itself fails.

        ## Failure Scenarios
        - The current kube context points to the wrong cluster.
- RBAC prevents reading one or more resource types.
