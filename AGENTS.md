# AGENTS.md

## Required references

Before authoring, read:

- `BOOK_SPEC.md`
- `STYLE_GUIDE.md`
- `CHAPTER_TEMPLATE.md`
- `ROADMAP.md`

For laboratory work, also read:

- `LABS_SPEC.md`

These files are authoritative.

## Working rules

- Do not redesign the curriculum.
- Do not change the frozen technology stack.
- Do not create labs during handbook tasks.
- Preserve the SupportOps Inc. narrative.
- Write valid Quarto Markdown.
- Prefer original Mermaid diagrams.
- Do not copy web images.
- Keep paragraphs concise.
- Avoid repeated explanations across chapters.
- Use existing terminology consistently.
- Keep instructor solutions under `solutions/` and out of student releases.

## Validation

Before finishing:

1. Render HTML.
2. Render PDF.
3. Validate cross-references.
4. Validate Mermaid diagrams.
5. Search for unfinished markers and filler text.
6. Summarize modified files.
7. Do not commit unless explicitly requested.

## Commands

```bash
quarto render --to html
quarto render --to pdf
```
