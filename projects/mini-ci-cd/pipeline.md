# `pipeline.sh`

        ## Problem Statement
        Small teams often need a simple deployment pipeline before they adopt a larger CI/CD platform. This project script demonstrates a full Bash-driven build, test, package, and release flow.

        ## When To Use It
        - You want a self-contained demo of CI/CD mechanics in Bash.
- You are preparing for an interview or teaching basic release orchestration.

        ## Prerequisites
        - Bash 4+
- A buildable application directory and reachable health endpoint

        ## How It Works
        - Runs build and test commands inside the application directory.
- Packages the requested artifact directory into a release archive.
- Expands the archive into a versioned release directory, updates the live symlink, and checks application health.

        ## Example Usage
        ```bash
./projects/mini-ci-cd/pipeline.sh --app-dir /srv/myapp --build-cmd 'make build' --test-cmd 'make test' --package-dir dist --release-root /srv/releases --current-link /srv/current --health-url https://app.example.com/healthz
```

        ## Expected Output
        - A versioned tarball and release directory under the release root.
- A successful health check after the symlink swap.

        ## Failure Scenarios
        - The build or test command fails.
- The health endpoint never recovers after deployment.
