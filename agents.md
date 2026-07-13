# AGENTS.md

## Repository purpose

This repository contains the implementation of the **Enterprise AI Platform Engineering Labs**.

The labs form one continuous local project for **SupportOps Inc.**

Students inherit a valid but incomplete AI platform and progressively complete it until the platform is fully operational.

This repository is focused only on:

- executable lab code;
- Kubernetes manifests;
- Helm charts;
- application services;
- workflows;
- datasets;
- tests;
- verification scripts;
- local operational tooling;
- concise lab instructions required to complete the work.

Do not build a book, handbook, website, slide deck, Quarto project, or publishing pipeline.

---

## Primary objective

Produce clean, reliable, professional-grade labs that help students understand and apply the complete MLOps and LLMOps lifecycle on a local machine.

Every lab must:

- have one clear engineering objective;
- add one useful platform capability;
- reuse the same continuous SupportOps project;
- preserve all previously completed capabilities;
- run locally on `kind`;
- use only the approved open-source stack;
- include automated validation;
- include realistic failure and recovery behavior;
- avoid unnecessary complexity;
- avoid unrelated tools or content.

No extra features.

No missing required capabilities.

---

## Authoritative files

Before making changes, read:

- `LABS_SPEC.md`
- `LAB_TEMPLATE.md`
- `LABS_ROADMAP.md`
- `datasets/DATASET_SPEC.md`
- all approved earlier labs
- the current repository structure
- existing Make targets
- existing tests and verification scripts

These files are authoritative.

When instructions conflict, use this priority:

1. Explicit user request
2. `AGENTS.md`
3. Task-specific issue or goal
4. `LABS_SPEC.md`
5. `LAB_TEMPLATE.md`
6. Existing repository conventions

Do not redesign the lab sequence or replace the approved technologies unless explicitly requested.

---

## Continuous project model

The organization is **SupportOps Inc.**

Students are the internal **AI Platform Engineering Team**.

A previous contractor delivered a repository and a valid but incomplete platform.

The platform starts with a trustworthy local foundation and progressively gains:

1. Local Kubernetes baseline
2. Data and artifact storage
3. Experiment tracking and model registry
4. Kubernetes-native training
5. ML inference
6. Local LLM inference
7. AI gateway
8. Evaluation gates
9. Observability
10. Progressive delivery
11. Security
12. GitOps reconciliation
13. Continuous AI operations

The platform must never reset between labs.

Each completed capability remains operational in all later labs.

---

## Frozen technology stack

### Foundation

- Kubernetes with `kind`
- Helm
- Docker Registry v2
- ingress-nginx

### Data and lifecycle

- SeaweedFS
- PostgreSQL
- DVC
- MLflow

### Workflows and delivery

- Argo Workflows
- Argo Events
- Argo Rollouts
- Argo CD

### Application services

- Python
- FastAPI
- scikit-learn
- MLflow PyFunc
- Ollama
- Hugging Face model provenance

### Evaluation and testing

- Pytest
- Evidently
- DeepEval
- Promptfoo
- k6

### Observability

- OpenTelemetry
- Grafana Alloy
- Prometheus
- Grafana
- Loki
- Tempo

### Security

- Kyverno
- Trivy
- Cosign

### Scaling

- Kubernetes HPA
- KEDA only where explicitly required or optional

Do not introduce:

- cloud-managed services;
- paid APIs;
- Kubeflow;
- KServe;
- Ray;
- Spark;
- Kafka;
- Istio;
- Vault;
- RAG;
- vector databases;
- agents;
- distributed GPU training;
- multi-cluster architecture.

---

## Local-only execution requirements

All core workloads must run on one local workstation using `kind`.

The implementation must:

- support CPU-only execution;
- require no AWS, Azure, or Google Cloud account;
- require no hosted SaaS service;
- require no paid API;
- continue working without Internet access after images and models are cached;
- use local persistent volumes;
- use a local OCI registry;
- use pinned dependency and image versions;
- avoid `latest` tags;
- provide predictable start, stop, reset, and verification commands;
- support constrained local hardware.

Expected resource profiles:

### Core profile

Designed for approximately 16 GB RAM.

### Operations profile

Designed for approximately 24 GB RAM.

### Full profile

Designed for approximately 32 GB RAM.

Do not make every component always-on when a lighter profile is sufficient.

---

## Dataset requirements

Use the **SupportOps Synthetic IT Helpdesk Dataset**.

The dataset must be:

- deterministic;
- generated from versioned templates;
- generated using fixed random seeds;
- free of real personal data;
- reproducible by checksum;
- suitable for ML and LLM tasks;
- divided into explicit releases.

Required releases:

- `sample`
- `v1.0`
- `v1.1`
- `v2.0`
- `v2.1-drift`
- `v2.2-corrupt`
- `v3.0`
- `golden-ml`
- `golden-llm`

Do not silently change:

- the canonical schema;
- label definitions;
- release purpose;
- deterministic generation behavior.

All dataset validation must be executable through tests or scripts.

---

## Lab design rules

Every lab must focus on one primary capability.

Each lab must contain only what students need to achieve that capability.

A lab must include:

- mission objective;
- initial platform state;
- expected final platform state;
- clear prerequisites;
- implementation tasks;
- acceptance criteria;
- automated verification;
- one realistic controlled incident where appropriate;
- recovery expectations;
- required deliverables;
- regression checks for earlier labs.

Do not include long theory sections.

Do not duplicate the handbook.

Do not include unnecessary discussion.

Do not include unrelated optional tools in the core path.

Optional extensions must be clearly separated and must not be required to pass the lab.

---

## Implementation quality rules

All code must be production-inspired, readable, tested, and maintainable.

### General

- Keep changes scoped to the current lab.
- Prefer simple and explicit implementations.
- Avoid premature abstraction.
- Avoid duplicate code.
- Remove dead code.
- Remove unused dependencies.
- Use deterministic behavior where possible.
- Use clear names.
- Use small focused functions.
- Add comments only where intent is not obvious.
- Do not hide failures.
- Fail fast with actionable error messages.
- Keep public interfaces stable across later labs.

### Python

- Target one pinned supported Python version.
- Use type hints for public functions.
- Use structured configuration.
- Validate external input.
- Use explicit exception handling.
- Do not use broad `except Exception` unless re-raising with useful context.
- Use logging instead of `print` in services.
- Use structured JSON logs where practical.
- Keep business logic separate from transport and infrastructure code.
- Include unit tests for non-trivial logic.
- Include integration tests for service boundaries.
- Format and lint code consistently.

### FastAPI

- Use Pydantic request and response models.
- Expose:
  - `/health/live`
  - `/health/ready`
  - `/version`
- Use startup and shutdown lifecycle hooks correctly.
- Load models once during startup.
- Return stable error contracts.
- Include request or correlation IDs.
- Add timeouts for external service calls.
- Implement graceful partial failure where required.
- Do not log sensitive ticket content.
- Expose Prometheus-compatible metrics where required.

### Shell scripts

- Use:

```bash
set -Eeuo pipefail
```

- Quote variables.
- Use functions for repeated behavior.
- Print concise progress and error messages.
- Return non-zero on failure.
- Make scripts safe to rerun where practical.
- Avoid destructive actions unless explicitly requested.
- Confirm or clearly document destructive reset commands.

### Makefiles

- Use clear target names.
- Keep targets small and composable.
- Mark non-file targets as `.PHONY`.
- Prefer Make targets over long manual command sequences.
- Provide help text.
- Avoid platform-specific assumptions where possible.

---

## Kubernetes and Helm rules

### Kubernetes

- Pin Kubernetes-compatible component versions.
- Use namespaces consistently.
- Use dedicated service accounts.
- Use resource requests and limits.
- Use liveness and readiness probes.
- Use non-root containers.
- Prefer read-only root filesystems where practical.
- Use persistent volumes only for stateful services.
- Use labels and annotations consistently.
- Avoid host networking and privileged workloads.
- Avoid manual cluster changes not represented in Git.
- Keep manifests valid for local `kind`.

### Helm

- Use Helm for student-developed services and reusable configuration.
- Keep values files understandable.
- Do not over-template simple resources.
- Use sane local defaults.
- Support resource profiles through values.
- Pin upstream chart versions.
- Keep secrets out of values files committed to Git.
- Run Helm lint and template validation.

### Images

- Build through the local registry.
- Use immutable version tags or digests.
- Never use `latest`.
- Use small base images.
- Use multi-stage builds where useful.
- Run as non-root.
- Add health checks through Kubernetes probes rather than Docker-only assumptions.

---

## State and persistence rules

For stateful components:

- define persistent storage explicitly;
- test pod recreation;
- document backup and restore;
- avoid storing important data only inside container layers;
- make reset behavior explicit;
- distinguish ephemeral lab state from required persistent state.

Later labs must not corrupt earlier lab state.

Where a lab requires clean state, provide a scoped reset command.

---

## Security rules

Never commit:

- real credentials;
- private keys;
- access tokens;
- cloud secrets;
- personal data.

Use:

- generated local secrets;
- `.env.example`;
- Kubernetes Secrets created from local setup scripts;
- least-privilege service accounts;
- non-root security contexts;
- approved local registry images;
- Trivy scanning;
- Cosign signing where introduced;
- Kyverno policies where introduced.

Do not weaken security controls merely to make verification pass.

---

## Verification contract

Every lab must provide:

```bash
make verify-lab-N
```

The verification target must:

- test the new capability;
- regression-test important earlier capabilities;
- return non-zero on failure;
- print concise PASS/FAIL output;
- avoid manual inspection when automation is possible;
- be safe to rerun;
- complete in a reasonable time;
- explain the failed check clearly.

Where appropriate, also provide:

```bash
make lab-N-up
make lab-N-down
make lab-N-reset
```

Verification must test behavior, not only resource existence.

Examples:

- service endpoint returns expected contract;
- data survives pod restart;
- DVC push and pull succeed;
- MLflow artifact lineage is complete;
- model alias resolves;
- workflow failure triggers retry;
- rollout aborts on bad metrics;
- policy rejects unsafe workload;
- GitOps reconciles drift.

---

## Testing requirements

Use the smallest test pyramid that gives confidence.

### Unit tests

Required for:

- dataset generation;
- validation rules;
- model-related utility code;
- routing logic;
- evaluation scoring;
- configuration parsing.

### Integration tests

Required for:

- API contracts;
- storage access;
- MLflow interaction;
- Ollama wrapper behavior;
- gateway behavior;
- workflow outputs.

### End-to-end checks

Required only for the critical path of each lab.

Do not create slow or fragile end-to-end suites for every edge case.

### Quality gates

Before completing a task, run applicable checks such as:

```bash
pytest
ruff check .
ruff format --check .
mypy .
helm lint
helm template
kubectl apply --dry-run=client
make verify-lab-N
```

Use only tools configured in the repository.

Do not claim tests passed unless they were executed.

---

## Controlled incident rules

Controlled incidents must teach realistic operational behavior.

Allowed examples:

- unavailable object storage;
- invalid credentials;
- data contract failure;
- missing model alias;
- failed workflow step;
- insufficient resources;
- service timeout;
- failed readiness;
- LLM unavailable;
- evaluation regression;
- elevated latency;
- failed canary;
- insecure workload rejected;
- GitOps drift;
- data or prediction drift.

Do not introduce:

- random syntax errors;
- intentionally malformed files without learning value;
- unrelated networking breakage;
- failures that require undocumented tricks;
- incidents that destroy prior lab work.

Each incident must have:

- observable symptoms;
- a clear diagnostic path;
- a recoverable outcome;
- automated post-recovery verification.

---

## Documentation scope

Documentation must be concise and operational.

Only create documentation that students or operators need to complete and run the lab.

Allowed documentation:

- short README;
- architecture diagram;
- ADR;
- runbook;
- API contract;
- acceptance criteria;
- troubleshooting notes.

Do not create:

- Quarto files;
- publishing configuration;
- books;
- websites;
- slide decks;
- long-form chapter content;
- decorative documentation with no operational value.

---

## Repository separation

Keep these concerns separate:

- `labs/` — student starter assets and lab implementation
- `solutions/` — instructor-only completed solutions
- `platform/` — shared platform components
- `services/` — application services
- `workflows/` — Argo workflow definitions
- `data/` or `datasets/` — dataset code, contracts, and releases
- `tests/` — automated tests
- `verification/` — lab verification scripts
- `incident-packs/` — controlled incident assets
- `docs/` — concise architecture, ADRs, and runbooks

Never expose instructor solutions in the student release.

---

## Workflow for each lab task

Before changing code:

1. Read the lab specification.
2. Inspect previous labs and current platform state.
3. Identify the exact capability being added.
4. Identify interfaces that must remain stable.
5. Identify required regression checks.
6. Plan the smallest correct implementation.

During implementation:

1. Add or modify only required files.
2. Keep the project runnable.
3. Add tests with the implementation.
4. Add verification checks.
5. Validate local resource assumptions.
6. Preserve earlier capabilities.

Before finishing:

1. Run formatting and linting.
2. Run unit tests.
3. Run integration tests where applicable.
4. Validate Kubernetes and Helm configuration.
5. Run `make verify-lab-N`.
6. Run important earlier lab verification.
7. Check for secrets and `latest` tags.
8. Update concise runbook or ADR files only where required.
9. Summarize files changed and checks executed.

---

## Definition of done

A lab implementation is complete only when:

- the required capability works locally;
- the code is clean and readable;
- tests pass;
- verification passes;
- earlier required capabilities still work;
- state survives restart where required;
- failure behavior is tested;
- recovery works;
- configuration is reproducible;
- no secret is committed;
- no `latest` tag is used;
- resource usage is appropriate for the selected profile;
- student instructions match the actual implementation;
- instructor solutions remain separate.

---

## Git rules

Do not commit or push unless explicitly requested.

When asked to commit:

- use a feature branch;
- keep commits focused;
- do not mix unrelated labs;
- use clear commit messages.

Examples:

```text
labs(lab01): add local data platform
platform(mlflow): add experiment tracking service
services(gateway): implement partial failure handling
fix(lab08): correct Tempo trace verification
```

---

## Completion report

At the end of every task, report only:

- files created;
- files modified;
- tests executed;
- verification executed;
- result of each check;
- unresolved blockers;
- assumptions made.

Keep the report concise and factual.
