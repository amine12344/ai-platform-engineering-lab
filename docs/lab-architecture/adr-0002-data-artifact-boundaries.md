# ADR-0002: Separate query, artifact, and version-control responsibilities

- Status: Accepted
- Date: 2026-07-13
- Scope: Lab 1 data and artifact platform

## Context

SupportOps Inc. needs durable helpdesk records for SQL analysis and immutable
dataset artifacts for reproducible AI work. Storing generated CSV files directly
in Git would enlarge repository history. Treating object storage as a relational
database would remove useful constraints and query semantics.

## Decision

PostgreSQL stores the queryable `helpdesk.tickets` relation. SeaweedFS provides
the S3-compatible artifact store. DVC records content identity in Git and moves
the corresponding bytes to SeaweedFS.

Both services use StatefulSets and persistent volume claims in
`supportops-data`. Images and the DVC client are pinned in
`platform/versions.env`. Dataset creation is deterministic and its independent
verifier runs before loading or artifact publication.

The PostgreSQL password is generated into ignored local runtime state and
applied as a Kubernetes Secret. DVC access values are stored only in ignored
`.dvc/config.local`. Lab 10 introduces the curriculum's full secret-management
system; Lab 1 does not pre-empt that design.

## Consequences

- Git reviews small desired-state and content-pointer changes.
- SQL constraints and dataset validation fail invalid records early.
- Recreating a Pod preserves data while deleting a claim intentionally does not.
- Local ingress hostname resolution is required for DVC to reach SeaweedFS.
- This single-node layout teaches boundaries but is not a production high-
  availability topology.
