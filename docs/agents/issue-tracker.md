# Issue Tracker

Status: Active

Purpose: Define where project issues live and how engineering skills interact
with them.

Scope: Agent creation, reading, triage, and resolution of project work items.

Intended readers: Repository agents and their maintainers.

Prerequisites: Repository access through the GitHub CLI.

Canonical information owner: Project owner.

## Table of contents

- [Tracker](#tracker)
- [Conventions](#conventions)
- [Pull requests as a triage surface](#pull-requests-as-a-triage-surface)
- [Skill operations](#skill-operations)
- [Wayfinding operations](#wayfinding-operations)

## Tracker

Issues and specifications live in this repository's GitHub Issues. Use the
`gh` CLI for all operations and infer the repository from `git remote -v`.

## Conventions

- Create: `gh issue create --title "..." --body-file <file>`.
- Read: `gh issue view <number> --comments`.
- List: `gh issue list --state open --json number,title,body,labels,comments`.
- Comment: `gh issue comment <number> --body "..."`.
- Apply a label: `gh issue edit <number> --add-label "..."`.
- Remove a label: `gh issue edit <number> --remove-label "..."`.
- Close: `gh issue close <number> --comment "..."`.

## Pull requests as a triage surface

PRs as a request surface: no.

GitHub shares one number space across issues and pull requests. Resolve an
ambiguous reference with `gh pr view <number>` and fall back to
`gh issue view <number>`.

## Skill operations

When a skill says to publish to the issue tracker, create a GitHub issue.

When a skill says to fetch a relevant ticket, run:

```sh
gh issue view <number> --comments
```

## Wayfinding operations

A wayfinding map is one issue labelled `wayfinder:map`. Its child issues are
the executable tickets.

- Map: contains Notes, Decisions-so-far, and Fog.
- Child ticket: linked as a GitHub sub-issue and labelled `wayfinder:<type>`.
- Supported child types: `research`, `prototype`, `grilling`, and `task`.
- Blocking relationships use GitHub issue dependencies.
- The first open, unassigned child without an open blocker is the frontier.
- Claim a ticket with `gh issue edit <number> --add-assignee @me`.
- Resolve a ticket by commenting with the result, closing it, and adding its
  context pointer to the map.
