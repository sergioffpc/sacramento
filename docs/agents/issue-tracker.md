# Issue Tracker

Use GitHub Issues as the canonical work-request and specification surface. Use
the `gh` CLI and infer the repository from `git remote -v`. Treat pull requests
as implementation and review artifacts, not as work requests.

## Read a ticket

1. Resolve an issue reference with `gh issue view <number> --comments`. If the
   reference is actually a pull request, use `gh pr view <number> --comments`.
2. Read the body, every comment, linked sub-issues, and blockers relevant to the
   requested work.
3. Identify the current scope, acceptance conditions, latest maintainer
   decision, open questions, and blocking relationships before acting.

Reading is complete when the planned work accounts for every acceptance
condition and current blocker. A stale body does not override a later explicit
maintainer decision.

## Change a ticket

Mutate GitHub only when the current task authorizes it. When a skill directs
publication to the issue tracker, create a GitHub issue.

After creating, editing, linking, labelling, commenting on, assigning, or
closing a ticket, fetch it again. The change is complete when the returned
issue state contains the intended content, relationships, labels, and status.

## Wayfinding operations

A wayfinding map is one issue labelled `wayfinder:map`; its child issues are
the executable tickets.

- Map: contains Notes, Decisions-so-far, and Fog.
- Child ticket: linked as a GitHub sub-issue and labelled `wayfinder:<type>`.
- Supported child types: `research`, `prototype`, `grilling`, and `task`.
- Blocking relationships use GitHub issue dependencies.
- Frontier: the first open, unassigned child without an open blocker.
- Claim: assign the frontier with `gh issue edit <number> --add-assignee @me`,
  then fetch it and confirm the assignment.
- Resolve: comment with the result, close the child, add its context pointer to
  the map, then fetch both issues and confirm all four outcomes.
