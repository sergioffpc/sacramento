# Domain Documentation

Status: Active

Purpose: Define how engineering skills consume the repository's domain
documentation.

Canonical information owner: Project owner.

## Table of contents

- [Layout](#layout)
- [Required reading](#required-reading)
- [Vocabulary](#vocabulary)
- [Architectural decisions](#architectural-decisions)

## Layout

This is a single-context repository:

```text
/
├── CONTEXT.md
├── docs/adr/
└── src/
```

## Required reading

Before exploring or changing the project:

1. Read `CONTEXT.md`.
2. Read the ADRs under `docs/adr/` that affect the area being changed.

If an indicated file or directory does not exist, proceed silently. Domain
terminology and ADRs are created when decisions require them.

## Vocabulary

Use terms exactly as defined in `CONTEXT.md` in issues, specifications,
hypotheses, tests, designs, and implementation.

Do not substitute synonyms that the glossary explicitly rejects. An absent
concept may indicate either inappropriate terminology or a genuine
domain-model gap that requires review.

## Architectural decisions

If proposed work contradicts an existing ADR, identify the conflict
explicitly. Do not silently override an accepted architectural decision.
