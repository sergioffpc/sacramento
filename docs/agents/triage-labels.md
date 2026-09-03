# Triage Labels

Read the issue and its comments, then apply the one canonical label describing
its current triage state. Remove any canonical triage label that describes a
superseded state.

| Canonical role | Repository label | Meaning |
|---|---|---|
| `needs-triage` | `needs-triage` | A maintainer has not yet chosen the issue's disposition |
| `needs-info` | `needs-info` | A named question must be answered before disposition or execution |
| `ready-for-agent` | `ready-for-agent` | Scope, acceptance conditions, and dependencies permit autonomous execution |
| `ready-for-human` | `ready-for-human` | Execution requires a named human capability or decision |
| `wontfix` | `wontfix` | A maintainer has decided that the repository will not action the issue |

Triage is complete when the fetched issue shows the selected label and its
comments make any missing information, human dependency, or `wontfix` rationale
explicit.
