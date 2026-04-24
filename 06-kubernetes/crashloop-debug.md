# `crashloop-debug.sh`

        ## Problem Statement
        CrashLoopBackOff investigations move faster when logs, describes, and events are collected together before a pod is rescheduled away. This script creates a portable debug bundle for that scenario.

        ## When To Use It
        - A Kubernetes workload is repeatedly crashing and you need evidence quickly.
- You want to attach pod diagnostics to a ticket or incident timeline.

        ## Prerequisites
        - Bash 4+
- `kubectl` access to the cluster
- `tar` for bundle creation

        ## How It Works
        - Resolves a pod directly or via a label selector.
- Collects `describe`, current logs, previous logs, and recent events into one directory.
- Compresses the directory into a shareable archive.

        ## Example Usage
        ```bash
./06-kubernetes/crashloop-debug.sh --namespace platform --selector app=myapp --output-dir bundles
```

        ## Expected Output
        - A `.tar.gz` archive containing pod diagnostics.
- A final log line with the bundle path.

        ## Failure Scenarios
        - The selector matches no pods.
- The pod has already been deleted before logs are collected.
