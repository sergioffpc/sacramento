# Evidence impact workflow

Status: Active — ADR-0014 supersedes manual global-graph and output-pre-registration
rules. Owner: Project owner. This stable path owns conservative impact analysis,
not a prerequisite inventory approval before running tests.

For a change, identify affected requirements, claims, interfaces, tests, data,
profiles, configurations and environments. Follow their actual dependencies,
including transitive ones. The generated `build/docs/references.csv` helps locate
direct references but is **not a complete semantic dependency graph**.

1. Record the changed revision and affected behavior in the issue/PR.
2. Run affected tests and required measurements/evaluations. If impact is uncertain,
   treat it as affected and rerun conservatively.
3. Retain an accepted result only with reproducible reasoning showing the changed
   baseline still satisfies the exact clause-level criterion. Absence from the
   reference index is never proof that evidence is unaffected.
4. Attach attributable results using the [acceptance workflow](../requirements/training-simulation-verification-plan.md).

No global graph, output ID registration, staged-tree digest or inventory successor
is needed before an ordinary test or documentation validator can run. Generated
indexes and validators check structural facts; they neither accept evidence nor
silently approve candidate design or a product baseline.

Accepted and superseded evidence remains immutable and retained indefinitely.
The prior nodes, relations, impact cases and control records are preserved in
[reference history](../research/legacy-document-control/README.md), not reinterpreted
as evidence for this changed baseline. This reform reruns documentation checks and
does not retain any product result as unaffected.
