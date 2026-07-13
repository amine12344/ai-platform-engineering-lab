# Enterprise AI Platform Engineering — Book Specification

## Purpose

The handbook explains how to design, build, and operate the local enterprise AI
platform used by SupportOps Inc. It supplies the architecture, engineering
reasoning, and operational context required by the laboratory sequence.

The handbook and laboratories describe one evolving platform. They must not
present disconnected reference architectures or disposable examples.

## Audience

The primary audience is software, platform, MLOps, and AI engineers who already
understand basic Git, containers, Python, and command-line workflows.

Readers are not assumed to have production experience with Kubernetes-native AI
platforms. New operational concepts must be introduced before they are used.

## Reader outcomes

After completing the handbook and laboratories, readers should be able to:

- explain the responsibilities and boundaries of an enterprise AI platform;
- operate a reproducible local Kubernetes foundation;
- manage versioned data, artifacts, experiments, and models;
- build Kubernetes-native training and inference paths;
- integrate classical ML and local LLM workloads behind an AI gateway;
- define automated evaluation and release gates;
- collect and correlate metrics, logs, and traces;
- apply progressive delivery, policy enforcement, and GitOps reconciliation;
- detect drift and operate a controlled retraining lifecycle;
- document engineering decisions, incidents, and recovery procedures.

## Narrative

SupportOps Inc. operates an enterprise IT and customer-support platform. A
previous contractor left behind a coherent, bootable, but incomplete local AI
platform. The reader joins the new AI Platform Engineering team and evolves that
platform without discarding completed capabilities.

The platform is intentionally incomplete, not randomly broken. Failures must be
controlled, diagnosable, and tied to an engineering or operational objective.

## Scope

The handbook covers:

- local platform foundations;
- data and model lifecycle management;
- training and inference workflows;
- ML and LLM application integration;
- evaluation, observability, and progressive delivery;
- security, GitOps, drift detection, and controlled retraining;
- operational evidence, runbooks, and architectural decisions.

The handbook does not cover public-cloud deployment, hosted SaaS platforms,
paid APIs, proprietary replacements for the frozen stack, or unrelated model
research.

## Operating constraints

All designs must:

- run on one local workstation;
- use a Kind Kubernetes cluster;
- support CPU-only execution;
- avoid AWS, Azure, Google Cloud, and hosted SaaS dependencies;
- require no paid API;
- remain usable offline after required images and models are cached;
- use local persistent volumes;
- expose repeatable Make targets;
- maintain Git as the source of truth;
- account for 16 GB, 24 GB, and 32 GB resource profiles.

## Frozen technology stack

The curriculum uses the following stack:

- Foundation: Kind, Helm, Docker Registry v2, and ingress-nginx.
- Data and lifecycle: SeaweedFS, PostgreSQL, DVC, and MLflow.
- Workflows and delivery: Argo Workflows, Argo Events, Argo Rollouts, and Argo CD.
- Application services: FastAPI, scikit-learn, MLflow PyFunc, Ollama, and Hugging Face model provenance.
- Evaluation: Pytest, Evidently, DeepEval, Promptfoo, and k6.
- Observability: OpenTelemetry, Grafana Alloy, Prometheus, Grafana, Loki, and Tempo.
- Security: Kyverno, Trivy, and Cosign.
- Scaling: Kubernetes HPA, with KEDA as an optional advanced capability.

Do not replace these technologies unless explicitly requested.

## Dataset and workloads

Examples use the deterministic SupportOps Synthetic IT Helpdesk Dataset defined
in `LABS_SPEC.md`. Handbook examples must use its canonical terminology, schema,
releases, ML workloads, and LLM workloads.

Do not introduce a second business domain or unrelated dataset when the
SupportOps scenario can demonstrate the concept.

## Relationship to laboratories

The handbook teaches architecture and operational reasoning. The laboratory
handbook supplies student missions and verification. Executable assets belong
under `labs/`, `starter-project/`, `platform/`, `datasets/`, `incident-packs/`,
and `verification/`.

Instructor solutions belong under `solutions/` and must not be included in a
student release.

`LABS_SPEC.md` is authoritative for laboratory outcomes, acceptance conditions,
dataset releases, and the frozen laboratory stack. `ROADMAP.md` preserves the
approved sequence. Handbook chapters must not silently add, remove, or reorder
laboratory outcomes.

## Chapter requirements

Every chapter must:

- use valid Quarto Markdown;
- follow `STYLE_GUIDE.md` and `CHAPTER_TEMPLATE.md`;
- state its operational purpose and connection to the evolving platform;
- explain architecture before implementation detail;
- define important boundaries, state, and failure behavior;
- preserve the SupportOps Inc. narrative where an example is needed;
- avoid duplicating explanations owned by another chapter;
- use original diagrams when a visual materially improves understanding;
- end with a concise maturity update and a transition to the next capability.

## Evidence and quality

Technical claims must be testable or attributable. Commands and configuration
must be internally consistent with the frozen stack. Screenshots are supporting
evidence only; they do not replace source-controlled desired state or automated
verification.

Before delivery, render HTML and PDF, validate cross-references and Mermaid
diagrams, and search for unfinished markers. If an external toolchain prevents a
required render, report the exact dependency and preserve the successful checks.

## Authority

For handbook authoring, apply the sources in this order:

1. `BOOK_SPEC.md` for scope and curriculum boundaries.
2. `ROADMAP.md` for sequence and ownership.
3. `STYLE_GUIDE.md` for language and presentation.
4. `CHAPTER_TEMPLATE.md` for chapter structure.
5. `LABS_SPEC.md` for laboratory behavior and the evolving platform contract.

Resolve conflicts explicitly. Do not silently redesign the curriculum.
