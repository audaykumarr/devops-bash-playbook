# `cleanup-host.sh`

        ## Problem Statement
        Container hosts and CI runners frequently run out of disk because stale images and stopped containers accumulate over time. This script provides a safer cleanup path than manually pruning everything.

        ## When To Use It
        - A build runner or shared Docker host is low on disk.
- You want a predictable cleanup job with a time-based safety window.

        ## Prerequisites
        - Bash 4+
- Docker installed and the current user allowed to manage it

        ## How It Works
        - Prints Docker disk usage before cleanup.
- Prunes stopped containers and old images using the supplied age filter.
- Optionally prunes volumes and build cache when aggressive cleanup is acceptable.

        ## Example Usage
        ```bash
./05-docker/cleanup-host.sh --until 240h --aggressive
```

        ## Expected Output
        - Docker disk usage tables before and after cleanup.
- Reduced space consumption on the host.

        ## Failure Scenarios
        - A still-needed image is only referenced by a stopped container and gets pruned.
- The host user does not have permission to manage Docker resources.
