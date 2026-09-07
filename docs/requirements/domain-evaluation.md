# Domain evaluation

Status: Existing specialist acceptance obligations retained unchanged. Owner: Project owner.
Read only when a requirement needs Mode Equivalence or Representative Evaluation;
TDD does not replace these judgments. Generic acceptance uses the
[workflow](training-simulation-verification-plan.md). References to retired process
IDs resolve through the [migration map](../project/documentation-migration.csv).

**PROCESS-MODE-EQUIVALENCE-TOLERANCE-001** — Before a Mode Equivalence procedure is executed, the implementation team MUST record proposed tolerances for each compared information item and tactically relevant outcome.

**PROCESS-MODE-EQUIVALENCE-TOLERANCE-002** — Representative Evaluators MUST confirm that differences within the proposed tolerances are tactically immaterial, and the project owner MUST approve those tolerances before comparative results are observed.

**PROCESS-MODE-EQUIVALENCE-TOLERANCE-003** — A tolerance changed after comparative results have been observed MUST invalidate those results and require a new verification execution under the approved replacement tolerance.

**PROCESS-MODE-EQUIVALENCE-COVERAGE-001** — Each Mode Equivalence procedure MUST use a versioned coverage inventory that enumerates every applicable Scenario-relevant information item, tactically relevant outcome, and canonical initial-state class for every covered requirement and Scenario capability.

**PROCESS-MODE-EQUIVALENCE-COVERAGE-002** — Every coverage-inventory item MUST trace to the stable requirement identifiers and Scenario capabilities that justify its inclusion, and every covered requirement and capability MUST trace to at least one applicable information item, outcome, or explicit non-applicability record.

**PROCESS-MODE-EQUIVALENCE-COVERAGE-003** — Before tolerances are finalized or comparative results are observed, the implementation team MUST reconcile the coverage inventory against the current requirements and Scenario-capability inventory, at least two qualified Representative Evaluators MUST confirm its tactical completeness independently, and the project owner MUST approve the exact coverage-inventory version.

**PROCESS-MODE-EQUIVALENCE-COVERAGE-004** — A Mode Equivalence obligation MUST NOT receive `Pass` unless every applicable item and canonical initial-state class in the approved coverage-inventory version has received the results required by its assigned methods.

**PROCESS-MODE-EQUIVALENCE-COVERAGE-005** — A change to a covered requirement, Scenario capability, information item, outcome, canonical initial-state class, or dependency MUST trigger impact analysis of the coverage inventory and retained Mode Equivalence evidence under `PROCESS-EVIDENCE-CHANGE-001` through `PROCESS-EVIDENCE-CHANGE-006`.

**PROCESS-EVALUATOR-QUALIFICATION-001** — Before a Representative Evaluator observes the product or evaluation results, the evaluator MUST have a recorded qualification identifying the person, relevant armed-forces experience, applicable roles, environments, equipment and decisions, and the dates of that experience.

**PROCESS-EVALUATOR-QUALIFICATION-002** — Each Representative Evaluation procedure MUST define the required evaluator-experience scope and recency before candidate evaluators are selected or observe the product or results.

**PROCESS-EVALUATOR-APPROVAL-001** — The project owner MUST approve each Representative Evaluator against the recorded procedure-specific scope and recency conditions before that person's findings become acceptance evidence.

**PROCESS-EVALUATOR-SCOPE-001** — A Representative Evaluator's findings MUST be used as acceptance evidence only for evaluation questions within that evaluator's approved experience scope.

**PROCESS-EVALUATOR-EVIDENCE-001** — Each Representative Evaluation evidence record MUST remain traceable to the applicable evaluator qualification, procedure version, scope, recency conditions, and project-owner approval.

**PROCESS-EVALUATION-PROTOCOL-001** — Before Representative Evaluators observe the product, each Representative Evaluation procedure MUST define its tasks, questions, controlled conditions, scoring method, and identifier-level acceptance criteria.

**PROCESS-EVALUATION-PROTOCOL-002** — The project owner MUST approve the exact Representative Evaluation procedure version before any result produced by that procedure can become acceptance evidence.

**PROCESS-EVALUATION-INDIVIDUAL-001** — The evidence record MUST preserve each evaluator's individual observations, scores, and findings separately from every aggregate result.

**PROCESS-EVALUATION-AGGREGATION-001** — When an aggregate result is used, its calculation and pass/fail interpretation MUST be defined in the approved procedure before observations begin and MUST remain reproducible from the retained individual results.

**PROCESS-EVALUATION-CONSENSUS-001** — Post-observation discussion or consensus MAY be retained as supporting evidence but MUST NOT replace, alter, or erase the original individual results.

**PROCESS-EVALUATION-PANEL-001** — Every obligation for which Representative Evaluation is a Required method MUST be evaluated by at least two Representative Evaluators qualified for that obligation's evaluation scope.

**PROCESS-EVALUATION-PANEL-002** — Each Representative Evaluator MUST complete and submit the individual result before observing another evaluator's result or participating in discussion about the evaluated behavior.

**PROCESS-EVALUATION-PANEL-003** — Unless the approved procedure defines a different aggregation rule using more than two evaluators, every required individual evaluation MUST satisfy its predeclared acceptance criteria for the obligation to receive `Pass` from Representative Evaluation.

**PROCESS-EVALUATION-PANEL-004** — An alternative aggregation rule MUST be defined and approved before observations begin and MUST NOT reduce the panel below two qualified evaluators.
