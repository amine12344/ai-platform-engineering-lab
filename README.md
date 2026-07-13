# Enterprise AI Platform Engineering Labs

This repository contains the executable local labs for the evolving SupportOps
Inc. AI platform. The labs reuse one Kind cluster and preserve every completed
capability.

## Current labs

- [Lab 0](labs/lab-00/README.md) establishes the trusted workstation, Kind,
  registry, ingress, namespace, and health-service baseline.
- [Lab 1](labs/lab-01/README.md) adds deterministic helpdesk data, PostgreSQL,
  SeaweedFS object storage, and DVC artifact versioning.

## Repository layout

- `labs/` contains operational lab instructions and automation.
- `platform/` contains shared Kubernetes desired state.
- `datasets/` contains deterministic generation and validation code.
- `starter-project/` contains repository-owned service source.
- `verification/` contains executable acceptance checks.
- `incident-packs/` contains controlled failure exercises.
- `docs/lab-architecture/` contains concise ADRs and runbooks.
- `solutions/` remains instructor-only.

## Quick start

Run from WSL 2 or another Linux shell with Docker available:

```bash
make doctor
make install-kind
make bootstrap-lab-0 PROFILE=16gb
grep -q 's3.supportops.local' /etc/hosts || \
  echo '127.0.0.1 s3.supportops.local' | sudo tee -a /etc/hosts
make bootstrap-lab-1
```

Use `make help` for individual operations. Read each lab guide before running
the combined bootstrap target.
