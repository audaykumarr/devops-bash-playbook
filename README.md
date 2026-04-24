# devops-bash-playbook

![Bash](https://img.shields.io/badge/bash-5.2-121011?logo=gnubash)
![Scripts](https://img.shields.io/badge/scripts-59-success)
![Docs](https://img.shields.io/badge/docs-70%2B-blue)
![Focus](https://img.shields.io/badge/focus-devops%20%7C%20sre-orange)

Production-grade Bash for DevOps engineers, SREs, platform teams, and open-source learners who want real operational playbooks instead of toy snippets.

This repository is built around the kind of work that actually lands on your desk:

- patch windows
- release rollouts
- Docker cleanup
- Kubernetes canaries
- AWS fleet refreshes
- certificate expiry
- incident bundles
- error-budget checks
- failover drills

The goal is simple: provide Bash automation that is useful in real environments and easy to study, adapt, and maintain.

## Why This Repo Stands Out

Most Bash repositories are one of two things:

- beginner syntax notes
- random scripts with no structure or docs

`devops-bash-playbook` is different:

- `59` executable Bash scripts
- `70+` Markdown docs and support files
- scenario-based structure from basics to SRE drills
- shared logging, validation, retries, and error handling
- CI checks for shell quality and docs parity
- end-to-end projects, not just isolated commands

## What You Can Steal For Real Work

- guarded cron recovery with heartbeat checks
- log filtering for JSON-based services
- systemd fleet audits
- disk-pressure remediation runbooks
- TLS expiry checks and reports
- blue-green and rollback helpers
- Docker vulnerability gating
- Kubernetes drain and canary checks
- AWS Auto Scaling refresh automation
- error-budget and log-rate anomaly checks
- Kubernetes RBAC reporting
- cache warmups and dependency failover drills

## Repository Layout

| Path | Focus |
| --- | --- |
| `01-basics/` | Operational Bash foundations with reusable on-call helpers |
| `02-system-automation/` | Host maintenance, patching, service, and disk workflows |
| `03-networking/` | Connectivity, DNS, TLS, and traffic verification |
| `04-ci-cd/` | Build, release, deploy, rollback, and release-note automation |
| `05-docker/` | Build pipelines, registry workflows, vulnerability gating, and drift detection |
| `06-kubernetes/` | Cluster health, restart logic, drains, and ingress checks |
| `07-cloud/` | AWS inventory, snapshots, cost scans, and fleet refreshes |
| `08-monitoring/` | Resource checks, error budgets, log anomalies, and alerting |
| `09-security/` | Secret scanning, SSH review, RBAC review, permissions, and TLS reports |
| `10-sre-usecases/` | Auto-healing, incident collection, cache warmup, and failover drills |
| `projects/` | End-to-end Bash projects with architecture notes |
| `templates/` | Copyable templates for new scripts |
| `utils/` | Shared libraries for logging, validation, retries, and locks |
| `docs/` | Contributor docs, architecture notes, and repository guides |

## 20 Advanced Scripts Added

These are the newest advanced additions layered on top of the original playbook:

| Script | Why It Matters |
| --- | --- |
| `01-basics/cron-health-guard.sh` | Recovers stale cron jobs without duplicate restarts |
| `01-basics/json-log-filter.sh` | Filters structured logs during incidents fast |
| `02-system-automation/systemd-unit-audit.sh` | Surfaces failed or unexpectedly inactive services |
| `02-system-automation/disk-pressure-reclaimer.sh` | Reclaims space safely during disk incidents |
| `03-networking/tls-certificate-check.sh` | Catches expiring certs before outages |
| `03-networking/load-balancer-smoke-test.sh` | Verifies status codes and backend spread |
| `04-ci-cd/release-note-generator.sh` | Generates publishable release notes from Git |
| `04-ci-cd/blue-green-switch.sh` | Switches live traffic between release colors safely |
| `05-docker/image-vulnerability-gate.sh` | Fails CI on disallowed vulnerability findings |
| `05-docker/docker-compose-drift-check.sh` | Detects drift in compose-managed environments |
| `06-kubernetes/pod-eviction-drain.sh` | Standardizes node drain during maintenance |
| `06-kubernetes/ingress-canary-check.sh` | Validates canary ingress before widening traffic |
| `07-cloud/aws-cost-anomaly-scan.sh` | Flags suspicious daily spend spikes |
| `07-cloud/aws-asg-refresh.sh` | Rolls AMI or launch-template changes through ASGs |
| `08-monitoring/sli-error-budget.sh` | Calculates remaining error budget quickly |
| `08-monitoring/log-rate-anomaly.sh` | Detects bursty retry loops or runaway errors |
| `09-security/k8s-rbac-audit.sh` | Exports high-privilege Kubernetes bindings |
| `09-security/tls-expiry-report.sh` | Produces audit-ready TLS expiry reports |
| `10-sre-usecases/cache-warmup-runbook.sh` | Warms critical caches before traffic spikes |
| `10-sre-usecases/dependency-failover-drill.sh` | Rehearses dependency failover safely |

## End-to-End Projects

- `projects/mini-ci-cd/`
  A Bash-first build, package, deploy, and rollback flow.
- `projects/server-bootstrap/`
  A practical Linux host bootstrap and validation pattern.
- `projects/monitoring-alert-system/`
  A lightweight monitor plus notification loop for smaller environments.

## Quick Start

```bash
git clone https://github.com/audaykumarr/devops-bash-playbook.git
cd devops-bash-playbook

chmod +x 04-ci-cd/deploy-release.sh
./04-ci-cd/deploy-release.sh --help
```

Useful local checks:

```bash
make lint
make validate
make docs-check
```

## How Scripts Are Built

Every production script follows the same operational baseline:

- `#!/usr/bin/env bash`
- `set -euo pipefail`
- shared logging
- trapped errors
- environment-variable driven configuration
- comments that explain the operational intent
- same-name Markdown docs next to the script

## Best Paths Through The Repo

If you are learning:

1. Start in `templates/` and `utils/`
2. Work through `01-basics/` to `03-networking/`
3. Move into `04-ci-cd/`, `05-docker/`, and `06-kubernetes/`
4. Finish with `07-cloud/` to `10-sre-usecases/`

If you are shipping something at work:

1. Steal from `04-ci-cd/`, `05-docker/`, and `06-kubernetes/`
2. Use `07-cloud/`, `08-monitoring/`, and `09-security/` as guardrails
3. Adapt `10-sre-usecases/` into your incident runbooks

If you are building a portfolio:

1. Keep the repo public
2. Make CI green
3. Add a license and code of conduct
4. Keep documentation and examples current as the repository evolves

## Key Docs

- Learning path: [`docs/learning-path.md`](docs/learning-path.md)
- Architecture map: [`docs/architecture.md`](docs/architecture.md)
- Good first issues: [`docs/good-first-issues.md`](docs/good-first-issues.md)

## Contribution Guidelines

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

Short version:

- run `make lint`, `make validate`, and `make docs-check`
- keep changes scenario-driven and production-oriented
- prefer shared helpers over one-off script logic
- document usage, expected output, and failure modes

## Why Repositories Like This Are Useful

- It saves time for working engineers.
- It teaches patterns, not just commands.
- It is easy to copy into a real environment.
- It is helpful for maintainers, contributors, and learners at the same time.

If you want the repo to grow faster, keep shipping:

- more cloud scripts
- more incident drill playbooks
- more CI examples
- more contributor-friendly issues
