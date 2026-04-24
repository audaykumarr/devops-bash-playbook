# `registry-push.sh`

        ## Problem Statement
        Pushing images is more than a single `docker push` when teams maintain semantic tags, stable aliases, and registry authentication. This script wraps that flow into a repeatable release step.

        ## When To Use It
        - You have one local image that needs multiple release tags.
- Your CI pipeline receives registry credentials via environment variables.

        ## Prerequisites
        - Bash 4+
- Docker installed and able to reach the registry
- A pre-built local image

        ## How It Works
        - Optionally logs in with environment-provided credentials.
- Tags the local image with each requested remote tag.
- Pushes every tag with exponential backoff to survive registry hiccups.

        ## Example Usage
        ```bash
DOCKER_USERNAME=ci-bot DOCKER_PASSWORD=*** ./05-docker/registry-push.sh --local-image myapp:build --registry-image ghcr.io/acme/myapp --tags 1.2.3,stable
```

        ## Expected Output
        - One push sequence per requested tag.
- A final log line when all tags are published.

        ## Failure Scenarios
        - Registry authentication fails.
- The local source image does not exist on the runner.
