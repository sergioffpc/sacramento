---
name: review-cpp-compliance
description: Review first-party C++ changes for compliance with the Sacramento C++ Engineering Baseline. Use for C++ style reviews, compliance checks, lint or formatting investigations, and pre-integration C++ review; use the live Google C++ Style Guide only when comparing or revising the project baseline.
---

# Review C++ Compliance

Treat `docs/standards/cpp-engineering.md` as the style authority. Preserve its
precedence, applicability boundaries, approved exceptions, and readiness state.
The Google C++ Style Guide is background rather than an additional rule set.

## Review

1. Read the repository `AGENTS.md` and follow its Domain Documentation and
   Evidence Dependency Inventory routes before interpreting an obligation or
   executing a registered verification.
2. Establish the requested scope. Classify generated and third-party files only
   from their explicit repository inventories; otherwise treat covered C++ as
   first-party.
3. Run `scripts/validate-cpp-style.sh -- <paths>` from the repository root for
   scoped files. Run it without paths only when an all-files check was requested.
   The gate result establishes only the checks it executed. A missing pinned tool
   or compilation database is `Not verified`, not a style violation or a pass.
4. Identify and run every additional baseline gate applicable to the requested
   conclusion, including pinned compiler warnings, builds, tests, sanitizers,
   and native platform closures. Do not infer these results from the style gate.
5. Inspect the applicable manual-review obligations in the baseline, including
   domain meaning, API boundaries, ownership and lifetime, units, failure
   boundaries, concurrency, determinism, serialization, and measured allocation
   rules. Record `Not Applicable` explicitly where the baseline requires it.
6. Report each confirmed finding with severity, file and line, the exact local
   rule, evidence, and the smallest useful correction. Separate confirmed
   violations from questions and verification gaps.

Conclude `Compliant with the format/lint and manual style rules for the reviewed
scope` only when the style gate passed and every applicable manual style
obligation was inspected. State full C++ Engineering Baseline compliance only
when every applicable build, warning, test, sanitizer, and native-platform gate
also passed. Otherwise state the narrower result and list what remains
unverified. Reviewing does not authorize source changes; implement fixes only
when the user asks for them.
