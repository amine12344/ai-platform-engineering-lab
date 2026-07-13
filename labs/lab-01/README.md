# Lab 1: Recover the data and artifact platform

## Mission

Add durable query and artifact boundaries to the existing SupportOps AI
platform. PostgreSQL stores queryable ticket records, SeaweedFS stores versioned
artifact bytes, and DVC connects those bytes to Git history.

## Prerequisites

- a passing Lab 0 environment;
- Python 3 with virtual-environment support;
- the same `supportops-ai` Kind cluster;
- approximately 10 GiB of local persistent-volume capacity.

Run every command from the repository root.

## Step 1: Prove Lab 0 remains healthy

```bash
make verify-lab-0
```

Stop if any check fails. Lab 1 must extend the baseline rather than conceal a
foundation failure.

## Step 2: Install and cache pinned dependencies

```bash
make install-lab-1-tools
make cache-lab-1
.venv/bin/dvc --version
```

DVC is installed inside ignored `.venv`. SeaweedFS and PostgreSQL images are
cached and loaded into Kind when the cluster exists.

## Step 3: Configure local hostname resolution

```bash
grep -q 's3.supportops.local' /etc/hosts || \
  echo '127.0.0.1 s3.supportops.local' | sudo tee -a /etc/hosts
getent hosts s3.supportops.local
```

The hostname must resolve to `127.0.0.1` so bucket creation and DVC send the Host
value expected by the SeaweedFS Ingress.

## Step 4: Deploy persistent services

```bash
make deploy-data-platform
kubectl -n supportops-data get statefulsets,pods,pvc,ingress
```

The target generates local PostgreSQL and S3 credentials under ignored
`.local/lab-01`, applies Kubernetes Secrets, deploys both StatefulSets, waits for
readiness, and creates the `supportops-dvc` bucket. Do not commit local secrets.

## Step 5: Test deterministic generation

```bash
make test-lab-1
make generate-dataset
sha256sum datasets/releases/sample/tickets.csv
```

The sample release contains exactly 250 records using the canonical 14 fields
from `LABS_SPEC.md`. Its SHA-256 must match
`datasets/releases/sample/manifest.json`. Run generation twice; the hash must
remain unchanged.

## Step 6: Inspect the quality contract

```bash
python3 datasets/verify_supportops.py
head -n 3 datasets/releases/sample/tickets.csv
```

Validation checks exact schema order, row count, unique identifiers, timestamps,
domains, category/product pairs, numeric limits, and release checksum.

## Step 7: Load PostgreSQL idempotently

```bash
make load-dataset
kubectl -n supportops-data exec postgresql-0 -- \
  psql -U supportops -d supportops -c \
  'SELECT category, count(*) FROM helpdesk.tickets GROUP BY category ORDER BY category;'
```

The loader creates the constrained table, replaces the current release, imports
the CSV, and asserts exactly 250 rows. A second run must not create duplicates.

## Step 8: Publish the artifact through DVC

```bash
make configure-dvc
.venv/bin/dvc remote list
.venv/bin/dvc status --cloud
git status --short
```

Git tracks DVC configuration and the small content pointer. SeaweedFS holds the
dataset bytes. Credentials stay only in ignored `.dvc/config.local`.

## Step 9: Run automated verification

```bash
make verify-lab-1
```

The target regression-tests Lab 0, verifies both pinned stateful services and
claims, tests the authenticated S3 bucket, validates the dataset and SQL
constraints, and confirms DVC synchronization.

## Step 10: Run the controlled incident

```bash
make incident-lab-1
python3 datasets/verify_supportops.py || true
```

The incident changes one priority to an invalid value. The expected symptom is
a data-contract failure, not an infrastructure outage. Recover from declared
generation logic rather than hand-editing the CSV:

```bash
make recover-lab-1
```

Recovery regenerates the canonical bytes, reloads PostgreSQL, republishes DVC
content, and runs the complete Lab 0 plus Lab 1 verification suite.

## Step 11: Test persistence and capture evidence

Delete one Pod without deleting its claim:

```bash
kubectl -n supportops-data delete pod postgresql-0
kubectl -n supportops-data rollout status statefulset/postgresql
make verify-lab-1
make evidence-lab-1
```

The SQL row count must remain 250 after Pod recreation. Review
`docs/lab-architecture/adr-0002-data-artifact-boundaries.md` and
`docs/lab-architecture/lab-01-runbook.md` before delivery.

## Repeatable path

After reading the individual steps, the complete path is:

```bash
make bootstrap-lab-1
```

Lab 1 is complete when the unit tests and `make verify-lab-1` report zero
failures after the controlled recovery.
