# Git Flow

Status: Approved initial profile

Purpose: Define the repository branch lifecycle and integration rules.

Scope: Every change integrated into the repository.

Canonical information owner: Project owner.

## Table of contents

- [Permanent branches](#permanent-branches)
- [Working branches](#working-branches)
- [Integration](#integration)
- [Commit and tag rules](#commit-and-tag-rules)
- [Definition of done](#definition-of-done)

## Permanent branches

| Branch | Purpose | Accepted input |
|---|---|---|
| `main` | Released and releasable project states | Completed `release/*` and `hotfix/*` branches |
| `develop` | Integration point for the next release | Completed `feature/*`, `release/*`, and `hotfix/*` branches |

Direct development on either permanent branch is prohibited.

## Working branches

| Pattern | Created from | Integrated into | Purpose |
|---|---|---|---|
| `feature/<slug>` | `develop` | `develop` | One coherent product, documentation, test, or tooling change |
| `release/<version>` | `develop` | `main` and `develop` | Release stabilization and release-only corrections |
| `hotfix/<version>` | `main` | `main` and `develop` | Urgent correction to a released state |

`<slug>` uses lowercase ASCII letters, digits, and hyphens. `<version>` is the
intended release version without a leading `v`.

A working branch is deleted after all required integrations complete.

## Integration

- Every integration uses a reviewed pull request.
- A `feature/*` pull request targets `develop`.
- A `release/*` or `hotfix/*` branch is first integrated into `main`, then
  integrated into `develop` so that the branches retain the same correction.
- Required checks must pass and every commit must satisfy the repository
  commit-message policy before integration.
- Integration must preserve a linear permanent-branch history. Squash is the
  default for a single coherent change; rebase is permitted when every source
  commit is independently useful and conforming.
- The pull-request title must be a valid Conventional Commit header because it
  becomes the commit header for squash integration.

## Commit and tag rules

- Every commit follows the
  [Conventional Commit Profile](conventional-commits.md).
- Every commit and annotated release tag is signed with a verified contributor
  key.
- A release integrated into `main` receives an annotated signed tag named
  `v<version>`.
- The `git-flow` command-line extension may automate branch creation and
  completion, but it does not override this document or repository gates.

## Definition of done

The workflow is operational when `main` and `develop` exist, both permanent
branches reject unsigned and non-reviewed integration, commit-policy checks
are required, and a contributor can complete each working-branch lifecycle
without bypassing a repository gate.
