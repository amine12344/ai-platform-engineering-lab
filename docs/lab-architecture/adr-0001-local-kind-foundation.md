# ADR-0001: Use Kind as the local platform foundation

- Status: Accepted
- Decision date: 2026-07-13
- Owners: SupportOps AI Platform Engineering
- Scope: Lab 0 and all later laboratories

## Context

SupportOps Inc. needs a Kubernetes-native AI platform that runs on one local
workstation, supports CPU-only execution, and remains usable without Internet
access after dependencies are cached.

The laboratory sequence requires a reproducible foundation for data services,
training workflows, inference, observability, security, and GitOps. The
foundation must expose Kubernetes behavior without requiring a cloud account.

## Decision

Use a Kind cluster named `supportops-ai` with a digest-pinned Kubernetes node
image. Provide 16 GB, 24 GB, and 32 GB topology profiles while preserving the
same API and namespace boundaries.

Run Docker Registry v2 as a separate persistent container named
`supportops-registry`. Expose it on `localhost:5001`, connect it to the Kind
network, and configure each Kind node to resolve the same image reference
through the registry container.

Use ingress-nginx for the local ingress boundary because it is frozen by the
curriculum. Pin the final chart and controller releases and treat the component
as a laboratory dependency, not a recommendation for a new production system.

## Consequences

- The platform can run without public-cloud infrastructure.
- Cluster creation remains repeatable across the three resource profiles.
- Image references remain consistent between the workstation and Kind nodes.
- Registry data survives cluster recreation until the registry volume is deleted.
- Host ports 80, 443, and 5001 must be available.
- Docker or Docker Desktop remains a workstation dependency.
- Kind is not a production cluster and cannot demonstrate every failure mode of
  a managed or multi-host Kubernetes environment.
- ingress-nginx retirement is an explicit lifecycle risk. The frozen stack must
  be changed through a curriculum decision rather than an unreviewed lab edit.

## Rejected alternatives

Minikube, k3d, MicroK8s, and managed Kubernetes were not selected because the
curriculum freezes Kind. A registry inside the cluster was rejected because
cluster deletion would couple image persistence to cluster persistence.

## Verification

`make verify-lab-0` proves that the cluster, namespaces, registry discovery,
ingress controller, local image, workload, Service, Ingress, and external health
endpoint are available.
