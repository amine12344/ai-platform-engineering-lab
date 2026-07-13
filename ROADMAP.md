# Enterprise AI Platform Engineering — Roadmap

## Purpose

This roadmap preserves the approved capability sequence for the SupportOps AI
platform. It coordinates handbook authoring with the laboratory stages in
`LABS_SPEC.md`; it does not create a second curriculum.

## Sequencing rules

- The same platform evolves through every stage.
- A completed capability remains available to later stages.
- Later content may depend on earlier content but must not duplicate it.
- Controlled incidents appear only after the affected capability has a valid baseline.
- GitOps becomes authoritative in Lab 11; earlier stages still keep desired state in Git.
- Continuous AI integrates established lifecycle, evaluation, observability, delivery, and security controls.

## Stage I — Foundation and lifecycle

### Lab 0: Establish the trusted local baseline

Handbook ownership: local architecture, workstation prerequisites, Kind,
registry and ingress boundaries, namespaces, resource profiles, repeatable
bootstrap, health verification, and restart expectations.

### Lab 1: Recover the data and artifact platform

Handbook ownership: deterministic SupportOps datasets, DVC, SeaweedFS,
PostgreSQL, artifact boundaries, metadata boundaries, persistence, and data
quality failure behavior.

### Lab 2: Recover the experiment and model lifecycle platform

Handbook ownership: MLflow tracking, artifact integration, model registration,
promotion semantics, reproducibility, and provenance.

Stage exit: the platform has a reproducible local foundation and a durable data,
experiment, artifact, and model lifecycle.

## Stage II — Production path

### Lab 3: Build the Kubernetes training factory

Handbook ownership: Kubernetes-native training, Argo Workflows, parameterized
runs, data and artifact inputs, resource constraints, and retriable execution.

### Lab 4: Deliver ML inference

Handbook ownership: FastAPI, scikit-learn, MLflow PyFunc, model loading, health
probes, request contracts, resource behavior, and Kubernetes HPA.

### Lab 5: Deliver local LLM inference

Handbook ownership: Ollama, local model lifecycle, Hugging Face provenance,
CPU-aware serving, cache preparation, offline operation, and LLM health behavior.

### Lab 6: Build the SupportOps AI gateway

Handbook ownership: ML and LLM orchestration, stable API boundaries, routing,
timeouts, fallback behavior, and SupportOps workflow composition.

Stage exit: the platform can train models and serve coordinated ML and LLM
capabilities through a stable application boundary.

## Stage III — Quality and operational control

### Lab 7: Build evaluation and release gates

Handbook ownership: Pytest, Evidently, DeepEval, Promptfoo, k6, golden datasets,
quality thresholds, regression evidence, and release decisions.

### Lab 8: Make the platform observable

Handbook ownership: OpenTelemetry, Grafana Alloy, Prometheus, Grafana, Loki,
Tempo, correlation, service-level signals, and diagnostic workflows.

### Lab 9: Implement progressive delivery

Handbook ownership: Argo Rollouts, canary analysis, promotion, abort, rollback,
and the observability signals that control delivery.

Stage exit: releases are evaluated, observable, progressive, and recoverable.

## Stage IV — Enterprise operations

### Lab 10: Secure the AI platform

Handbook ownership: Kyverno policy, Trivy scanning, Cosign verification, trust
boundaries, workload permissions, artifact provenance, and policy failure behavior.

### Lab 11: Make Git authoritative

Handbook ownership: Argo CD, desired-state organization, reconciliation, drift
correction, promotion boundaries, and recovery from invalid desired state.

### Lab 12: Implement Continuous AI

Handbook ownership: distribution drift, controlled retraining triggers, Argo
Events, evaluation gates, model promotion, progressive delivery, and feedback
into the authoritative Git state.

Stage exit: the platform can enforce policy, reconcile desired state, detect
drift, and execute a controlled end-to-end AI lifecycle.

## Authoring order

Author material in stage order unless a request explicitly targets an existing
roadmap item. When work begins out of sequence, document its dependencies and do
not assume unavailable platform state.

For each roadmap item:

1. establish chapter ownership and avoid overlap;
2. author the handbook explanation using `CHAPTER_TEMPLATE.md`;
3. validate terminology and presentation using `STYLE_GUIDE.md`;
4. confirm alignment with `BOOK_SPEC.md` and `LABS_SPEC.md`;
5. render and validate before marking the item complete.

## Status convention

Track authoring status in pull requests or project tooling rather than editing
the curriculum sequence. Use only these states: planned, drafting, review, and
complete.
