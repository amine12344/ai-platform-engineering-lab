# Lab 0: Establish the trusted local baseline

## Mission

Recover the SupportOps Inc. workstation-to-Kubernetes request path. The final
state has a pinned Kind cluster, local Registry v2, ingress-nginx, ownership
namespaces, and a repository-built health service.

## Prerequisites

- WSL 2 or another Linux shell
- Docker Engine with at least 16 GB available for the core profile
- Git, curl, make, kubectl, and Helm
- Internet access for the first dependency cache

Run every command from the repository root.

## Step 1: Validate the workstation

```bash
make doctor
```

If Kind is the only missing tool, install the pinned repository-local binary:

```bash
make install-kind
make doctor
```

Do not continue until the doctor reports success. Docker failures are
workstation failures, not Kubernetes failures.

## Step 2: Review the resource profile

Choose one topology:

- `16gb`: one control-plane and one worker;
- `24gb`: one control-plane and two workers;
- `32gb`: one control-plane and three workers.

```bash
sed -n '1,160p' platform/kind/profiles/16gb.yaml
```

The profiles map workstation ports 80 and 443 into the Kind control-plane node.

## Step 3: Cache pinned dependencies

```bash
make cache-lab-0
```

This caches the Kind node image, Registry v2, ingress-nginx chart and controller,
and the health-service base image. Versions are declared in
`platform/versions.env` and never use `latest`.

## Step 4: Create the cluster and registry

```bash
make create-cluster PROFILE=16gb
kind get clusters
kubectl --context kind-supportops-ai get nodes
curl -fsS http://127.0.0.1:5001/v2/
```

Expected state: `supportops-ai` exists, every node is Ready, and the local
registry returns a successful Registry API response.

## Step 5: Install ingress-nginx

```bash
make install-ingress
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller
```

Ingress owns the external request boundary. Pod readiness alone does not prove
that traffic can enter the cluster.

## Step 6: Build and deploy the baseline

```bash
make build-platform-health
make deploy-baseline
kubectl -n supportops-platform get deployment,pod,service,ingress
```

The build target pushes `platform-health` to the local registry. Deployment
applies the five SupportOps namespaces and the health-service desired state.

## Step 7: Test the complete request path

```bash
curl -fsS -H 'Host: platform.supportops.local' http://127.0.0.1/healthz
curl -fsS -H 'Host: platform.supportops.local' http://127.0.0.1/readyz
```

Both endpoints must return `ok`. This proves client, ingress, Service, and Pod
routing together.

## Step 8: Run automated verification

```bash
make verify-lab-0
```

Verification checks the cluster image, node readiness, profile labels, registry,
namespaces, ingress image, health image, probes, and external endpoint.

## Step 9: Run the controlled incident

```bash
make incident-lab-0
make verify-lab-0 || true
kubectl -n supportops-platform get deployment platform-health
```

The incident scales the health deployment to zero. Diagnose the failed
availability path, then recover from source-controlled desired state:

```bash
make recover-lab-0
```

Recovery is complete only when the full verification target passes again.

## Step 10: Capture evidence

```bash
make evidence-lab-0
find evidence/lab-00 -type f -maxdepth 2 -print
```

Review `docs/lab-architecture/adr-0001-local-kind-foundation.md` and
`docs/lab-architecture/lab-00-runbook.md` before delivery.

## Repeatable path

After reading the individual steps, the complete idempotent path is:

```bash
make bootstrap-lab-0 PROFILE=16gb
```

Lab 0 is complete when `make verify-lab-0` reports zero failures.
