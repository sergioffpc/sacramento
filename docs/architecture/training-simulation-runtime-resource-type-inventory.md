# Training Simulation Runtime Resource Type Inventory

Status: Candidate; no Runtime Resource type is admitted until its exact type
identity, schema, limits, dependencies, materializer contract, and vectors are
approved

Approval: Pending

Inventory version: `RRTI-001`

Purpose: Close the candidate population and admission state of every Runtime
Resource type required by the current Authority and Client role-pack
architecture.

Scope: Semantic runtime projections selected by one Runtime Content Release;
source assets, package representations, launch configuration, evidence,
vendor objects, and live Training Session state are excluded.

Intended readers: Project owner, architects, content-pipeline authors,
responsibility-module implementers, security reviewers, and verification
authors.

Prerequisites: [ADR-0012](../adr/0012-establish-runtime-resource-and-role-pack-architecture.md),
[runtime-resource architecture](0012-runtime-resource-and-role-pack-architecture.md),
[canonical responsibility](0004-canonical-responsibility.md), the approved
requirements, and every exact catalogue and Approved Profile named by a future
admitted row.

Canonical information owner: Project owner.

## Inventory rules

One row represents one semantic type contract, not one source file, instance,
pack entry, C++ class, vendor object, or allocation. A type has exactly one
responsibility-module owner and one role-pack applicability. Authority and
Client projections never share a Resource Identity or type merely because they
share a source or bytes.

`Blocked` means the semantic boundary is identified but no type is admitted.
An admitted successor row requires all of the following:

- one stable unsigned type identity and display name;
- one exact schema version and restricted deterministic encoding;
- closed required and nullable Resource Reference fields;
- permitted dependency type identities and an acyclic role-local graph;
- format, decoded, recursion, collection, scratch, object, descriptor, and GPU
  limits where applicable;
- one bounded capacity function over authenticated fields;
- semantic validation and materialization owner contract;
- stable failure mappings and cleanup behavior;
- golden, malformed, cross-platform, fuzz, and representative-resource
  evidence; and
- exact trace to every canonical source artifact whose runtime projection it
  carries.

Unknown rows and unapproved candidate rows never enter a Pack Manifest. A type
identity survives an encoding revision only when its semantic meaning, owner,
and invariants remain stable; every encoding change creates a new exact schema
version. Meaning or owner changes create a new type identity.

## Authority candidate population

The following candidate boundaries are complete for the known Authority Pack
sources. All are blocked because no exact runtime schema, numerical limits, or
type identity has been approved.

| Candidate key | Semantic runtime projection | Owner | Principal source | Dependencies | Admission state |
| --- | --- | --- | --- | --- | --- |
| `RRT-AUTHORITY-SCENARIO-001` | Authority Scenario Model: exact teams, Team Positions, Loadouts, Map reference, objective, completion, precedence, duration, mission parameters, and Map subresource references required by the selected Scenario | `Scenario` | Exact Scenario version | Authority Map Model and each referenced runtime catalogue/profile projection | `Blocked` |
| `RRT-AUTHORITY-MAP-001` | Authority Map Model: Sacramento spatial, collision, physical-material, canonical Map object, anchor, region, tactical-space, and connection content required by authoritative execution | `Simulation` | Exact Map version and admitted canonical-source closure | Applicable authoritative catalogue/profile projections | `Blocked` |
| `RRT-AUTHORITY-ACTION-INVENTORY-001` | Runtime projection of the Action Inventory | `Simulation` | Exact Action Inventory version | Applicable action-condition and profile projections | `Blocked` |
| `RRT-AUTHORITY-ACTION-CONDITION-001` | Runtime projection of the Action Physical Condition Inventory | `Simulation` | Exact Action Physical Condition Inventory version | Action Inventory and applicable profile projections | `Blocked` |
| `RRT-AUTHORITY-ACTION-COMPATIBILITY-001` | Runtime projection of the Action Compatibility Matrix | `Simulation` | Exact Action Compatibility Matrix version | Action Inventory and Action Physical Condition Inventory projections | `Blocked` |
| `RRT-AUTHORITY-CARRYING-001` | Runtime projection of the Carrying Catalogue | `Simulation` | Exact Carrying Catalogue version | Action and applicable profile projections | `Blocked` |
| `RRT-AUTHORITY-WEAPON-001` | Runtime projection of the Weapon Behavior Catalogue | `Simulation` | Exact Weapon Behavior Catalogue version | Action, carrying, physical, injury, and applicable profile projections | `Blocked` |
| `RRT-AUTHORITY-PHYSICAL-EFFECTS-001` | Runtime projection of the Physical Effects Catalogue | `Simulation` | Exact Physical Effects Catalogue version | Applicable Physical, Injury, Fire, Obscurant, and environment projections | `Blocked` |
| `RRT-AUTHORITY-ACOUSTIC-PROPAGATION-001` | Runtime projection of the Acoustic Propagation Catalogue | `Simulation` | Exact Acoustic Propagation Catalogue version | Applicable Acoustic, Map, material, and environment projections | `Blocked` |
| `RRT-AUTHORITY-INJURY-OUTCOME-001` | Runtime projection of the Injury Outcome Catalogue | `Simulation` | Exact Injury Outcome Catalogue version | Harmful-effect, physical, protection, and Injury Profile projections | `Blocked` |
| `RRT-AUTHORITY-FUNCTIONAL-STATE-001` | Runtime projection of the Functional State Transition Catalogue | `Simulation` | Exact Functional State Transition Catalogue version | Injury-outcome and action projections | `Blocked` |
| `RRT-AUTHORITY-MELEE-COVERAGE-001` | Runtime projection of the Melee Coverage Catalogue | `Simulation` | Exact Melee Coverage Catalogue version | Action, physical-condition, physical-effect, and injury projections | `Blocked` |
| `RRT-AUTHORITY-HARMFUL-EFFECT-001` | Runtime projection of the Harmful Effect Inventory | `Simulation` | Exact Harmful Effect Inventory version | Physical, injury, melee, Fire, environment, and equipment projections | `Blocked` |
| `RRT-AUTHORITY-ENVIRONMENT-COVERAGE-001` | Runtime projection of the Environment Coverage Catalogue | `Simulation` | Exact Environment Coverage Catalogue version | Map, environment-state, Fire, Obscurant, physical, and acoustic projections | `Blocked` |
| `RRT-AUTHORITY-ENVIRONMENT-STATE-001` | Runtime projection of the Environment State Catalogue | `Simulation` | Exact Environment State Catalogue version | Environment-coverage and applicable profile projections | `Blocked` |
| `RRT-AUTHORITY-LOCOMOTION-PROFILE-001` | Runtime projection of one exact Locomotion Profile | `Simulation` | Exact admitted Locomotion Profile | Explicit downstream profile relations only | `Blocked` |
| `RRT-AUTHORITY-FATIGUE-PROFILE-001` | Runtime projection of one exact Fatigue Profile | `Simulation` | Exact admitted Fatigue Profile | Explicit downstream profile relations only | `Blocked` |
| `RRT-AUTHORITY-STRESS-PROFILE-001` | Runtime projection of one exact Stress Profile | `Simulation` | Exact admitted Stress Profile | Explicit downstream profile relations only | `Blocked` |
| `RRT-AUTHORITY-PHYSICAL-PROFILE-001` | Runtime projection of one exact Physical Profile | `Simulation` | Exact admitted Physical Profile | Explicit downstream profile relations only | `Blocked` |
| `RRT-AUTHORITY-ACOUSTIC-PROFILE-001` | Runtime projection of one exact Acoustic Profile | `Simulation` | Exact admitted Acoustic Profile | Map/material projections where declared | `Blocked` |
| `RRT-AUTHORITY-INJURY-PROFILE-001` | Runtime projection of one exact Injury Profile | `Simulation` | Exact admitted Injury Profile | Explicit downstream profile relations only | `Blocked` |
| `RRT-AUTHORITY-FIRE-PROFILE-001` | Runtime projection of one exact Fire Profile | `Simulation` | Exact admitted Fire Profile | Physical, environment, and Map projections where declared | `Blocked` |
| `RRT-AUTHORITY-OBSCURANT-PROFILE-001` | Runtime projection of one exact Obscurant Profile | `Simulation` | Exact admitted Obscurant Profile | Physical, environment, Map, and presentation-relevant relations where declared | `Blocked` |

The names above do not merge their canonical source identities or versions.
Each exact catalogue or profile remains a separately identified governed source
and produces a separately identified role-specific Runtime Resource instance.

## Client candidate population

Client representation schemas are not yet supplied by an accepted design. The
following list closes the known semantic boundaries without pretending that a
generic engine-asset taxonomy is admitted.

| Candidate key | Semantic runtime projection | Owner | Principal source | Dependencies | Admission state |
| --- | --- | --- | --- | --- | --- |
| `RRT-PREDICTION-MAP-001` | Prediction Map Model containing only immutable spatial and collision data required for correctable client-local Prediction | `Prediction` | Exact Map and role-specific processed products | Exact Prediction projections required by its future schema | `Blocked` |
| `RRT-PREDICTION-RULE-PROJECTION-001` | Placeholder population boundary for distinct Prediction projections of exact catalogues or profiles proven necessary by a future Prediction contract; it is not an admissible generic type | `Prediction` | Not yet established | Not yet established | `Blocked; split into exact rows before admission` |
| `RRT-PRESENTATION-SCENARIO-001` | Client Scenario Presentation containing briefing and diegetic presentation content without authoritative objective or terminal-result ownership | `Presentation` | Exact Scenario and role-specific processed products | Client Map Presentation and applicable presentation resources | `Blocked` |
| `RRT-PRESENTATION-MAP-001` | Client Map Presentation containing immutable visual and acoustic Map representation inputs | `Presentation` | Exact Map and role-specific processed products | Visual and Acoustic Representation resources | `Blocked` |
| `RRT-PRESENTATION-VISUAL-001` | One Sacramento visual representation product; meshes, images, shaders, GPU buffers, and vendor objects remain private materializer details | `Presentation` | Exact admitted source and processing configuration | Type-specific presentation dependencies not yet closed | `Blocked` |
| `RRT-PRESENTATION-ACOUSTIC-001` | One Sacramento acoustic representation product; encoded audio, decoder objects, and API resources remain private materializer details | `Presentation` | Exact admitted source and processing configuration | Type-specific presentation dependencies not yet closed | `Blocked` |

`Prediction Content`, `Presentation Asset`, `Resource Blob`, and `Other` are not
candidate types. A successor must split the Prediction placeholder into exact
semantic rows or remove it. Presentation never supplies mutable or authoritative
state to Prediction.

## Excluded populations

The following are not Runtime Resource types:

- Pack Envelope, Pack Manifest, Stored Extent, encoded bytes, signatures, and
  package indexes owned by Runtime Package;
- canonical sources, Blender data, importer state, Assimp structures, shader
  compiler inputs, caches, and staging products;
- processing records, approval records, evidence, retained history, and source
  provenance;
- Runtime Launch Specification, Content Signing Trust Reference, Memory Budget
  Configuration, Application Release, Identity Validation Package, and other
  separately provisioned launch or trust artifacts;
- canonical catalogues and Approved Profile documents themselves rather than
  their stripped deterministic runtime projections;
- live physical item identities, Training Session state, Canonical Tick
  candidates, Prediction state, and Presentation Frames; and
- memory allocations, CPU pointers, GPU API resources, descriptors, and Runtime
  Resource Handles.

Reference Hardware Profiles, Reference Workload Profiles, Radio Coverage
Profiles used only for acceptance, and other evaluation-only records enter no
pack merely because they are release provenance. Their runtime applicability
requires an exact governing requirement and a separately admitted row.

## Current closure and approval boundary

`RRTI-001` identifies 29 candidate boundaries: 23 Authority rows and six Client
rows. It admits zero Runtime Resource types. Every row remains `Blocked` until
its exact identity, schema, limits, dependency closure, capacity function,
materializer contract, vectors, and evidence are approved together.

This zero admitted population prevents implementation or baseline evidence from
claiming a usable role pack. It does not reopen ADR-0012's accepted identity,
format, ownership, lifecycle, or verification architecture. Adding, removing,
splitting, admitting, retiring, changing ownership of, or changing a dependency
relation for a row creates a successor inventory and triggers documentation,
baseline-artifact, and evidence-dependency impact analysis.

## Trace

This inventory principally traces to `REQ-CONTENT-PROCESSING-GATE-001`,
`REQ-CONTENT-PROCESSING-RECORD-001`, `REQ-CONTENT-PROCESSING-001`,
`REQ-CONTENT-TRACEABILITY-001`, `REQ-CONTENT-PROCESSING-ADMISSION-001`,
`REQ-CONTENT-PACK-ROLE-001`, `REQ-CONTENT-VERSION-002`,
`REQ-CONTENT-ACTIVATION-001`, `REQ-CONTENT-IMMUTABILITY-001`,
`REQ-RUNTIME-LAUNCH-SPECIFICATION-002`, `REQ-RUNTIME-READINESS-001`,
`PROCESS-ARCHITECTURE-CONTRACT-001`, and
`PROCESS-ARCHITECTURE-VERIFICATION-001`.
