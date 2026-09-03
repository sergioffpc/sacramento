# Triage Labels

Status: Active

Purpose: Map canonical triage roles to the labels used by this repository.

Scope: Classification of GitHub issues during repository triage.

Intended readers: Repository agents, maintainers, and issue triagers.

Prerequisites: [Issue Tracker](issue-tracker.md).

Canonical information owner: Project owner.

## Table of contents

- [Label mapping](#label-mapping)
- [Usage](#usage)

## Label mapping

| Canonical role | Repository label | Meaning |
|---|---|---|
| `needs-triage` | `needs-triage` | Maintainer must evaluate the issue |
| `needs-info` | `needs-info` | Waiting for information from the reporter |
| `ready-for-agent` | `ready-for-agent` | Fully specified and ready for an autonomous agent |
| `ready-for-human` | `ready-for-human` | Requires human implementation |
| `wontfix` | `wontfix` | Will not be actioned |

## Usage

When a skill refers to a canonical triage role, use the corresponding
repository label from this table.
