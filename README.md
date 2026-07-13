# Enterprise AI Platform Engineering Lab

This repository contains the handbook specifications, student-facing laboratory
source, executable platform assets, verification, incident packs, and protected
instructor solutions for the evolving SupportOps Inc. AI platform.

## Authoritative references

Read these files before authoring:

- `BOOK_SPEC.md` — handbook scope, constraints, and authority;
- `STYLE_GUIDE.md` — language, terminology, Quarto, and visual conventions;
- `CHAPTER_TEMPLATE.md` — required chapter progression;
- `ROADMAP.md` — approved capability sequence;
- `LABS_SPEC.md` — laboratory contract, frozen stack, dataset, and outcomes;
- `AGENTS.md` — repository working and validation rules.

## Source layout

- `lab-handbook/` contains student-facing Quarto instructions.
- `labs/` and `starter-project/` contain executable starter assets.
- `platform/` contains shared platform desired state.
- `datasets/` contains deterministic dataset sources and release metadata.
- `incident-packs/` contains controlled operational incidents.
- `verification/` contains automated evidence.
- `docs/lab-architecture/` contains architecture documentation and ADRs.
- `solutions/` contains instructor material excluded from student releases.

The same SupportOps AI platform evolves from Lab 0 through Lab 12. Do not
replace the frozen technology stack or create disconnected lab environments.

## Begin Lab 0

Run the laboratory from WSL 2 or another Linux shell:

```bash
make doctor
make install-kind
make doctor
make bootstrap-lab-0 PROFILE=16gb
```

Follow the complete student guide in `lab-handbook/labs/lab-00.qmd`. Stop at
each tutor checkpoint and review the observed state before continuing.

## Begin Lab 1

After Lab 0 passes and `s3.supportops.local` resolves to `127.0.0.1` in WSL:

```bash
make bootstrap-lab-1
```

Lab 1 deploys persistent SeaweedFS and PostgreSQL services, generates and
validates a deterministic SupportOps helpdesk release, loads SQL records, and
publishes the artifact through DVC. Follow the complete tutor-guided procedure
in `lab-handbook/labs/lab-01.qmd`.
