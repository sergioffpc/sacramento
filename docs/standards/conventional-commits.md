# Conventional Commit Profile

Status: Approved initial profile

Purpose: Define the complete commit-message rules enforced by this repository.

Scope: Every commit integrated into the repository, including the initial
commit and commits produced by squash or rebase integration.

Intended readers: Contributors, maintainers, automation authors, and
verification authors.

Prerequisites: [Training Simulation Initial Requirements](../requirements/training-simulation-initial-requirements.md).

Canonical information owner: Project owner.

Source baseline: [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

## Table of contents

- [Header](#header)
- [Types](#types)
- [Scope](#scope)
- [Description](#description)
- [Body and footers](#body-and-footers)
- [Breaking changes](#breaking-changes)
- [Integration](#integration)
- [Git Flow compatibility](#git-flow-compatibility)
- [Examples](#examples)
- [Definition of done](#definition-of-done)

## Header

Every commit starts with exactly:

```text
<type>[optional scope][optional !]: <description>
```

The header is one line. Type and scope are case-sensitive and lowercase.

## Types

The type is mandatory and must be exactly one of:

| Type | Use |
|---|---|
| `build` | Build system or dependency change |
| `chore` | Repository maintenance with no product or test behavior change |
| `ci` | Continuous-integration configuration or automation |
| `docs` | Documentation-only change |
| `feat` | New externally meaningful capability |
| `fix` | Correction of defective behavior |
| `perf` | Behavior-preserving performance improvement |
| `refactor` | Behavior-preserving code restructuring |
| `revert` | Reversal of one or more earlier commits |
| `style` | Source presentation change with no behavior change |
| `test` | Test addition or correction |

## Scope

Scope is optional. When present, it is enclosed in parentheses and contains
only lowercase ASCII letters, digits, and internal hyphens. It names the
smallest stable area that makes the commit easier to understand.

Examples: `auth`, `requirements`, `verification`, `build`, `docs`.

## Description

The description is mandatory, starts immediately after `: `, and is a concise
summary of the change. It must not be empty or continue onto another line.

## Body and footers

A body is optional and begins after exactly one blank line following the
header. It may contain multiple paragraphs.

Footers are optional and follow the body after one blank line. A footer token
uses hyphens instead of spaces and is followed by `: ` or ` #`, except for the
special `BREAKING CHANGE` token.

## Breaking changes

A breaking change is declared by `!` immediately before the header colon, by
an exact `BREAKING CHANGE: <description>` footer, or by both. The footer form
must use uppercase `BREAKING CHANGE` and a non-empty description.

## Integration

- Every commit is validated locally before creation.
- The protected remote branch validates every commit independently.
- Bypassing a local hook does not bypass the remote gate.
- Integration must not create an automatic non-conforming merge message.
- Squash and rebase results use a conforming final message.

## Git Flow compatibility

The branch lifecycle is defined by [Git Flow](git-flow.md). Pull-request titles
must pass the same header validation as commits. This ensures that squash
integration creates a conforming commit. Generated merge messages are not an
exception to this profile.

## Examples

```text
docs: establish project requirements baseline
fix(auth): reject an expired continuity claim
feat(rendering)!: replace the public material interface
```

```text
feat(auth): add offline identity validation

Retain exact validation inputs for deterministic verification.

BREAKING CHANGE: the former unauthenticated admission path is removed
```

## Definition of done

The profile is satisfied when the complete commit message passes the
repository validator, the local commit gate is active, and the remote
protected-branch gate independently applies the same accepted grammar.
