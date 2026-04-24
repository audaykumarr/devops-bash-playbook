# `docker-buildx.sh`

        ## Problem Statement
        Teams frequently need the same image built for multiple architectures, but ad hoc Docker commands vary between laptops and CI runners. This script standardizes multi-platform builds with a named buildx builder.

        ## When To Use It
        - You publish images for mixed AMD64 and ARM64 environments.
- You want the same build command in CI and on a developer workstation.

        ## Prerequisites
        - Bash 4+
- Docker with buildx enabled
- A valid Dockerfile and build context

        ## How It Works
        - Ensures a named buildx builder exists.
- Builds the requested image for one or more platforms.
- Either pushes directly or loads the image locally depending on the flag.

        ## Example Usage
        ```bash
./05-docker/docker-buildx.sh --image ghcr.io/acme/app --tag 1.2.3 --platforms linux/amd64,linux/arm64 --push
```

        ## Expected Output
        - Build output from Docker plus a final repository log line.
- A pushed multi-arch manifest or locally loaded image.

        ## Failure Scenarios
        - Docker buildx is not installed or not configured.
- The Dockerfile path is wrong or the build context is incomplete.
