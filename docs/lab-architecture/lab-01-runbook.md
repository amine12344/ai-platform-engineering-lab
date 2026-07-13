# Lab 1 data and artifact runbook

## Purpose

Operate and recover the SupportOps Inc. local PostgreSQL, SeaweedFS, dataset,
and DVC path established in Lab 1.

## Health check

```bash
make verify-lab-1
kubectl -n supportops-data get pods,pvc,ingress
```

Proceed by boundary: first Lab 0 and ingress, then stateful workload readiness,
then the dataset contract, SQL load, and DVC remote state.

## Common diagnoses

### DVC cannot reach the endpoint

```bash
getent hosts s3.supportops.local
.venv/bin/dvc status --cloud
kubectl -n supportops-data get ingress seaweedfs-s3
```

Restore the WSL `/etc/hosts` entry if resolution is absent. If curl fails, check
ingress-nginx and the SeaweedFS Pod before changing DVC configuration.

### PostgreSQL is not Ready

```bash
kubectl -n supportops-data describe pod postgresql-0
kubectl -n supportops-data logs postgresql-0
kubectl -n supportops-data get pvc data-postgresql-0
```

Do not delete the claim as a first response. Reapply desired state with
`make deploy-data-platform` after identifying the cause.

### Dataset validation fails

```bash
python3 datasets/verify_supportops.py
git diff -- datasets/generate_supportops.py datasets/verify_supportops.py
```

If generation logic and seed are unchanged, regenerate with
`make generate-dataset`. Then reload and republish; do not hand-edit the release.

## Recovery

```bash
make recover-lab-1
make evidence-lab-1
```

The recovery target regenerates and verifies the release, replaces SQL rows,
pushes DVC content, and executes the entire Lab 0 plus Lab 1 acceptance suite.

## Evidence

Text evidence is written under `evidence/lab-01/<UTC timestamp>/` and is ignored
by Git. Attach relevant excerpts to a review without exposing local credentials.
