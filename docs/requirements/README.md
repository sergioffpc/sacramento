# Requirements: start with one behavior

Owner: Project owner. This is navigation, not another specification. Product
requirements retain their stable identifiers and meaning. Use the relevant
capability in [Initial Requirements](training-simulation-initial-requirements.md)
or search one identifier:

```sh
python3 scripts/documentation.py requirement REQ-STATE-CONSISTENCY-001
```

The command shows the definition, current applicability, acceptance criteria and
method assignments, then direct architecture/design references. Reading every
requirement or every catalogue is not a prerequisite to changing one behavior.

| If the change concerns… | Read only the applicable source |
| --- | --- |
| Product behavior, lifecycle, content or Admission | [Initial Requirements](training-simulation-initial-requirements.md) |
| Latency, smoothness, capacity or reliability | [Non-functional requirements](training-simulation-non-functional-requirements.md) and the referenced profile |
| Signals and measurement | [Observability contract](training-simulation-observability-contract.md) |
| Trainee Performance Assessment | [Assessment requirements](training-simulation-performance-assessment-requirements.md) |
| Platform-specific measurement | [Hardware profiles](training-simulation-reference-hardware-profiles.md) and [Engagement Target](training-simulation-performance-profile-engagement-target-001.md) |
| Future Autonomous Participants | [Autonomous Participant requirements](training-simulation-autonomous-participant-requirements.md) |
| What is currently in scope | [Applicability](training-simulation-baseline-applicability.md) |
| How to accept a change | [Acceptance workflow](training-simulation-verification-plan.md) |

The [acceptance catalogue](training-simulation-acceptance-examples.csv) preserves
requirement-specific method/evidence assignments from the former verification
plan. It is data to query, not a new document to approve in full. Implemented
examples become public-behavior tests; non-functional measurements and qualified
military evaluation remain necessary when the requirement demands them.
