# Enterprise AI Platform Engineering — Laboratory Specification

## Purpose

The laboratories implement the architecture and lifecycle described in the
Enterprise AI Platform Engineering handbook.

Students inherit a valid but incomplete local AI platform for SupportOps Inc.

The platform is not randomly broken.

It is structurally coherent, bootable, and intentionally missing enterprise
capabilities.

Each laboratory adds one capability or introduces one controlled operational
incident.

No laboratory is isolated.

No completed capability is discarded.

The same platform evolves from Lab 0 through Lab 12.

---

## Ultimate objective

Students must build and operate a local, open-source, Kubernetes-native AI
platform capable of:

- managing versioned datasets;
- storing artifacts and metadata;
- tracking experiments;
- registering and promoting models;
- running Kubernetes-native training workflows;
- serving classical ML models;
- serving a local LLM;
- orchestrating ML and LLM services through an AI gateway;
- evaluating models, prompts, and generated responses;
- collecting metrics, logs, and traces;
- performing progressive delivery and rollback;
- enforcing security policies;
- reconciling platform state through GitOps;
- detecting drift and triggering controlled retraining.

---

## Operating constraints

The complete project must:

- run on one local workstation;
- use a Kind Kubernetes cluster;
- avoid AWS, Azure, Google Cloud, and hosted SaaS dependencies;
- require no paid API;
- remain operational without Internet access after images and models are cached;
- support CPU-only execution;
- use only open-source core technologies;
- expose repeatable Make targets;
- maintain Git as the source of truth;
- use local persistent volumes;
- provide resource profiles for 16 GB, 24 GB, and 32 GB machines.

---

## Business scenario

The organization is SupportOps Inc.

SupportOps operates an enterprise IT and customer-support platform.

A previous contractor created an incomplete AI platform repository and then
left the project.

Students join as the new AI Platform Engineering team.

They inherit:

- a repository skeleton;
- a partial Kind configuration;
- namespace definitions;
- a baseline health service;
- a local registry design;
- an initial support-ticket dataset;
- partial architecture documentation;
- incomplete GitOps definitions.

Students progressively complete and operate the platform.

---

## Frozen technology stack

### Foundation

- Kind
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

- FastAPI
- scikit-learn
- MLflow PyFunc
- Ollama
- Hugging Face model provenance

### Evaluation

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
- KEDA as an optional advanced capability

Do not replace these technologies unless explicitly requested.

---

## Dataset

The platform uses the SupportOps Synthetic IT Helpdesk Dataset.

The dataset is generated deterministically using repository-owned templates and
fixed random seeds.

### Canonical schema

- ticket_id
- created_at
- channel
- language
- customer_tier
- product
- subject
- body
- category
- priority
- escalated
- resolution_time_minutes
- agent_response
- satisfaction_score

### Releases

- sample: 250 rows
- v1.0: balanced baseline
- v1.1: corrected labels
- v2.0: new product and category
- v2.1-drift: distribution drift
- v2.2-corrupt: schema and quality incident
- v3.0: post-retraining candidate
- golden-ml: stable ML regression set
- golden-llm: stable LLM evaluation set

### ML workloads

- ticket-category classification;
- priority classification;
- escalation-risk prediction.

### LLM workloads

- ticket summarization;
- support-response drafting;
- troubleshooting-plan generation;
- escalation handover;
- priority explanation.

---

## Laboratory stages

### Stage I — Foundation and lifecycle

- Lab 0: Establish the trusted local baseline
- Lab 1: Recover the data and artifact platform
- Lab 2: Recover the experiment and model lifecycle platform

### Stage II — Production path

- Lab 3: Build the Kubernetes training factory
- Lab 4: Deliver ML inference
- Lab 5: Deliver local LLM inference
- Lab 6: Build the SupportOps AI gateway

### Stage III — Quality and operational control

- Lab 7: Build evaluation and release gates
- Lab 8: Make the platform observable
- Lab 9: Implement progressive delivery

### Stage IV — Enterprise operations

- Lab 10: Secure the AI platform
- Lab 11: Make Git authoritative
- Lab 12: Implement Continuous AI

---

## Laboratory philosophy

Every lab follows this lifecycle:

1. Engineering incident or business request
2. Platform state before the mission
3. Mission objectives
4. Acceptance criteria
5. Architecture review
6. Engineering decisions
7. Implementation
8. Automated verification
9. Controlled failure or recovery exercise
10. Operational runbook
11. Pull request delivery
12. Platform maturity update

---

## Student delivery model

Each laboratory must produce:

- a feature branch;
- a pull request;
- source-controlled desired state;
- architecture documentation;
- at least one ADR when a major decision is made;
- implementation assets;
- automated verification;
- operational runbook updates;
- incident or recovery evidence;
- regression evidence for previous capabilities.

Screenshots alone are not valid evidence.

---

## Definition of done

A lab is complete only when:

- the new capability works;
- previous capabilities still work;
- Kubernetes health checks pass;
- state survives restart where required;
- configuration is versioned;
- verification is automated;
- operational failure behavior is tested;
- security considerations are documented;
- Git contains the desired state;
- the relevant runbook is updated;
- the lab verification command exits successfully.

Each lab must expose:

```bash
make verify-lab-N
```
