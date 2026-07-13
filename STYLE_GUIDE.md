# Enterprise AI Platform Engineering — Style Guide

## Voice

Write as an experienced platform engineer guiding another engineer through a
production-minded local system. Use direct, precise, calm language.

Prefer concrete explanations over slogans. Explain why a decision matters to
reliability, reproducibility, security, or operability.

Address the reader as “you” only when giving an action or framing a decision.
Use “we” sparingly and only for a shared engineering action.

## SupportOps terminology

Use these names consistently:

- SupportOps Inc. for the organization;
- SupportOps AI platform for the evolving platform;
- SupportOps Synthetic IT Helpdesk Dataset for the dataset;
- AI gateway for the service that coordinates ML and LLM capabilities;
- desired state for Git-controlled platform configuration;
- verification for automated proof that acceptance conditions hold;
- controlled incident for an intentional operational failure exercise.

Do not rename frozen products, dataset fields, releases, laboratories, or
platform capabilities.

## Structure

Keep paragraphs concise. Each paragraph should develop one idea.

Use headings to expose the reasoning path, not to fragment every paragraph.
Introduce a concept before presenting commands or configuration that depend on
it.

Prefer this explanatory order:

1. operational problem;
2. system boundary and relevant state;
3. engineering decision;
4. implementation or configuration;
5. verification and failure behavior;
6. operational consequence.

Avoid repeating background material. Link to the owning chapter instead.

## Quarto Markdown

Write valid Quarto Markdown with one level-one chapter heading after the YAML
front matter. Use sentence case for headings.

Assign identifiers to sections, figures, tables, listings, and diagrams that are
referenced elsewhere. Use descriptive identifiers such as `#sec-model-promotion`
or `#fig-artifact-flow`.

Use Quarto cross-references rather than phrases such as “the diagram below.”
Keep captions concise and state what the reader should learn from the visual.

## Code and commands

Use fenced code blocks with a language identifier. Commands must be safe to copy
and must show the working context when it is not obvious.

Use repository-relative paths in prose and code. Do not embed workstation-
specific absolute paths.

Prefer Make targets for repeatable workflows. Show direct tool commands only
when teaching the tool boundary or diagnosing a failure.

Do not include secrets, real credentials, or unexplained opaque values. Use
clearly named environment variables for sensitive inputs.

## Configuration

Show the smallest configuration fragment that establishes the concept. Keep the
complete executable configuration in its source directory and reference it from
the chapter.

Explain ownership, persistence, resource constraints, health behavior, and
rollback implications when they are relevant.

Do not present configuration that replaces a frozen technology.

## Diagrams

Prefer original Mermaid diagrams for architecture, sequence, state transition,
and dependency views. Use a diagram only when it clarifies relationships that
are difficult to explain linearly.

Keep diagrams focused. Use stable SupportOps component names and avoid decorative
nodes. Explain the important boundary or flow in the surrounding prose.

Do not copy web images. If a raster or external image is unavoidable, document
its provenance and licensing.

## Tables and lists

Use a table for exact comparisons, mappings, or repeated fields. Avoid wide
tables that do not render cleanly in PDF.

Use ordered lists for sequences and unordered lists for collections. Do not turn
ordinary prose into long lists without a structural reason.

## Notes and warnings

Use callouts sparingly:

- notes clarify context;
- tips offer a practical shortcut that preserves correctness;
- warnings identify a realistic destructive, security, or reliability risk;
- important callouts state a non-negotiable platform constraint.

Do not use callouts as a substitute for coherent prose.

## Technical precision

Distinguish desired state from observed state, artifacts from metadata, models
from serving endpoints, and evaluation from monitoring.

State whether a component runs on the workstation, in Kind, or as a supporting
local service. State where persistent state resides and what happens during a
restart when persistence matters.

Label optional advanced capabilities as optional. Do not present KEDA as a
required baseline capability.

## Accessibility

Provide meaningful captions and alt text. Do not rely on color alone to convey
state. Use descriptive link text and readable labels in diagrams.

## Final review

Before delivery:

- remove duplicated explanations;
- verify terminology against the authoritative specifications;
- validate commands, paths, cross-references, and diagrams;
- render HTML and PDF;
- search case-insensitively for unfinished markers;
- confirm that no student-facing source exposes instructor solutions.
