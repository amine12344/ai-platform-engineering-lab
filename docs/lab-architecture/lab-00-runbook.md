# Lab 0 runbook: Trusted local baseline

## Ownership

The SupportOps AI Platform Engineering team owns the Kind cluster, local
registry, ingress boundary, namespace definitions, and platform health service.

## Service objective

The baseline is healthy when `make verify-lab-0` exits successfully and
`platform.supportops.local/healthz` returns `ok` through ingress-nginx.

## Routine checks

```bash
kind get clusters
kubectl --context kind-supportops-ai get nodes
kubectl --context kind-supportops-ai get namespaces
kubectl --context kind-supportops-ai -n ingress-nginx get pods
kubectl --context kind-supportops-ai -n supportops-platform get all,ingress
curl -fsS -H 'Host: platform.supportops.local' http://127.0.0.1/healthz
make verify-lab-0
```

## Registry checks

Confirm the host endpoint and persistent container:

```bash
curl -fsS http://127.0.0.1:5001/v2/
docker inspect supportops-registry
docker volume inspect supportops-registry-data
```

Confirm node resolution configuration:

```bash
for node in $(kind get nodes --name supportops-ai); do
  docker exec "$node" cat /etc/containerd/certs.d/localhost:5001/hosts.toml
done
```

If the registry container is stopped, start it and reconnect it to the Kind
network when necessary:

```bash
docker start supportops-registry
docker network connect kind supportops-registry 2>/dev/null || true
```

## Workload diagnosis

Start with desired state and events:

```bash
kubectl --context kind-supportops-ai -n supportops-platform \
  describe deployment platform-health
kubectl --context kind-supportops-ai -n supportops-platform \
  get events --sort-by=.lastTimestamp
kubectl --context kind-supportops-ai -n supportops-platform \
  logs deployment/platform-health
```

An `ImagePullBackOff` normally indicates that the image was not pushed, the
registry is stopped, or a node lacks `hosts.toml`. Re-run these idempotent steps:

```bash
make create-cluster PROFILE=16gb
make build-platform-health
make deploy-baseline
```

## Ingress diagnosis

Check controller readiness, route discovery, and the backend Service:

```bash
kubectl --context kind-supportops-ai -n ingress-nginx \
  rollout status deployment/ingress-nginx-controller
kubectl --context kind-supportops-ai -n supportops-platform \
  describe ingress platform-health
kubectl --context kind-supportops-ai -n supportops-platform \
  get endpointslices -l kubernetes.io/service-name=platform-health
```

HTTP 404 usually means the Host header does not match. HTTP 503 means the route
exists but no ready backend endpoint is available.

## Controlled incident and recovery

Inject the approved baseline outage:

```bash
make incident-lab-0
curl -i -H 'Host: platform.supportops.local' http://127.0.0.1/healthz
```

Recover by reconciling repository-owned desired state:

```bash
make recover-lab-0
```

Do not repair the incident with an undocumented imperative configuration that
diverges from `platform/foundation/platform-health.yaml`.

## Restart expectations

The Kind node containers and registry use restartable Docker state. After a
Docker or workstation restart, start Docker and run:

```bash
docker start supportops-registry 2>/dev/null || true
kubectl --context kind-supportops-ai wait --for=condition=Ready nodes --all --timeout=180s
make recover-lab-0
```

If the cluster was deleted, run `make bootstrap-lab-0 PROFILE=16gb`. Registry
content persists unless `make destroy-all` removed its volume.

## Evidence

Capture machine-readable evidence after recovery:

```bash
make evidence-lab-0
```

The generated `evidence/lab-00/` directory is intentionally ignored by Git.
Attach its text files to the pull request or summarize their results in the pull
request description. Screenshots alone are not acceptable evidence.

## Cleanup

Preserve the platform for Lab 1 whenever possible. To delete only the cluster:

```bash
make destroy-cluster
```

`make destroy-all` also deletes the registry container and volume. Use it only
when a clean reset is required because cached platform images will be lost.
