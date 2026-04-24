# Mini CI/CD Pipeline

This project shows how a Bash-first pipeline can build, test, package, deploy, and roll back an application artifact using a versioned release directory layout.

## Architecture

```mermaid
flowchart LR
  Source["application source"] --> Build["pipeline.sh build/test/package"]
  Build --> Artifact["artifacts/release.tgz"]
  Artifact --> Deploy["deploy step inside pipeline.sh"]
  Deploy --> Current["current symlink"]
  Current --> Health["health check"]
  Health -->|failure| Rollback["rollback.sh"]
```

## Files

- `pipeline.sh`: Runs build, test, package, deploy, and optional health verification.
- `rollback.sh`: Re-points the live symlink to the previous release.
- `env/example.env`: Sample configuration values for the project.

## Quick Start

```bash
cp projects/mini-ci-cd/env/example.env .env
./projects/mini-ci-cd/pipeline.sh --app-dir /srv/myapp --build-cmd "make build" --test-cmd "make test" --package-dir dist
```
