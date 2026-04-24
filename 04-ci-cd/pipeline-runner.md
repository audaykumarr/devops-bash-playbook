# `pipeline-runner.sh`

        ## Problem Statement
        Delivery pipelines often need a thin orchestration layer around build, test, and packaging commands. This script provides a portable Bash wrapper that captures logs and metadata for each stage.

        ## When To Use It
        - You need a lightweight CI entry point without adopting a heavier orchestrator first.
- You want build and test logs split into predictable files for later inspection.

        ## Prerequisites
        - Bash 4+
- `tee` and whatever commands your build, test, and package stages require

        ## How It Works
        - Executes build, test, and package stages in order inside the chosen application directory.
- Captures a dedicated log file for each stage.
- Writes release metadata so deploy jobs know exactly what artifact was produced.

        ## Example Usage
        ```bash
BUILD_CMD='make build' TEST_CMD='make test' PACKAGE_CMD='tar -czf artifacts/release.tgz dist' ./04-ci-cd/pipeline-runner.sh --app-dir . --release-id 20260424093000
```

        ## Expected Output
        - Per-stage logs under `artifacts/logs/`.
- A `release-metadata.env` file describing the pipeline inputs.

        ## Failure Scenarios
        - A stage command exits nonzero and the pipeline stops immediately.
- The artifact directory cannot be created or written.
