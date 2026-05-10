---
date-created: 2026-05-07T22:10:00-07:00
date-revised: 2026-05-08T00:10:00-07:00
status: ratified
---

# Supplied-instance MetaGraphsNext contract decision

## Authority

This document is the tranche 2 decision record required by:

- `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-2--tasking.md`

If this document conflicts with the governing PRD, tranche file, tranche-2
tasking, or active governance authorities, the higher-priority authority
controls and this document must be revised before later tranche work proceeds.

## Current status

This document closes the tranche-2 red state that existed at start:
`.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
was absent.

This document now records the tranche-2 human-review outcome from this
workflow thread on 2026-05-08.

The tranche-2 review gate is closed. Branch A is ratified by the human project
owner. Tranche 3 is unblocked for a separate tranche-to-tasking pass. Tranche 4
remains blocked by Tranche 3. Tranche 5 remains blocked by Tranches 3 and 4.

## Governance and required reading

This document was prepared under the following active authorities:

- `AGENTS.md`
- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-2--tasking.md`

The bundled baseline style files under the `development-policies` skill
reference depot remain the baseline internal authorities. The tranche-2
tasking records that those bundled style files are byte-identical to the
repo-local style files except for `STYLE-vocabulary.md`, where the repo-local
file is the higher-priority project authority. Bundled `CONTRIBUTING.md` was
not present there, so repo-local `CONTRIBUTING.md` remains authoritative.

`STYLE-makie.md` is not an active authority for this workflow-only tranche
because no Makie or rendering work is in scope. `STYLE-python.md` was not
present in the repo-local governance set.

Controlled vocabulary remains mandatory. This document uses
`package-owned public surface`, `compatibility wrapper`, `convenience wrapper`,
`authoritative tables`, `materialized graph or basenode result`,
`ownership boundary`, `lock item`, `red-state repro`, `verification artifact`,
`read_lineages`, and `BuilderDescriptor` consistently. It does not describe
`00-02_audit-fix-decisions.md` as a ratified contract decision.

## Recorded review outcome and provenance

Review date:

- 2026-05-08

Recorded human-project-owner answer from this workflow thread:

- Branch A: ratify constructor-based extension on user-owned
  `VertexData(::NodeRowRef)` and `EdgeData(::EdgeWeightType, ::EdgeRowRef)`

Approval provenance:

- On 2026-05-08, the human project owner answered the tranche-2 reserved
  review gate directly with:
  `Branch A: ratify constructor-based extension on user-owned VertexData(::NodeRowRef) and EdgeData(::EdgeWeightType, ::EdgeRowRef).`

This answer is the required HITL review artifact for tranche 2. No agent-side
inference or preference was used to close the branch decision.

## Settled decisions and non-negotiables

The following points are settled and are not reopened here:

- `read_lineages` remains the ratified first-class package-owned public
  surface for the library-created path (Type token or BuilderDescriptor target).
- `read_lineages!` is the first-class package-owned public surface for the
  supplied-instance path (populates a caller-owned empty graph in place).
  **Branch Narrow (2026-05-09):** First-edge atomicity is guaranteed; later-edge
  failure may leave partial state; callers requiring retry safety after any
  failure must supply a fresh empty instance.
- `BuilderDescriptor` remains the ratified first-class typed builder surface.
- `FileIO.load(...)` remains a compatibility wrapper.
- `load_alife_table(...)` remains the in-memory Tables.jl convenience wrapper.
- The supplied-instance `MetaGraph` path remains directed-only,
  empty-instance-only, and `Symbol`-label-only.
- The supplied-instance path already supports both single-parent and
  multi-parent sources when the caller supplies an empty `MetaGraph` instance
  whose type parameters match currently supported shapes.
- This tranche does not authorize runtime implementation, test changes, docs
  synchronization, example updates, export changes, renames, deprecations, or
  broader migration-policy changes.
- The tranche-2 branch decision is now settled: Branch A is ratified.
- The supplied-instance custom-data extension point is constructor-based:
  user-owned `VertexData(::NodeRowRef)` and
  `EdgeData(::EdgeWeightType, ::EdgeRowRef)`.
- `00-02_audit-fix-decisions.md` is supporting input only. It does not settle
  the supplied-instance branch by itself.

## Authorization boundary

In scope for tranche 2:

- this workflow decision artifact
- the read-only diagnosis needed to state the current contract honestly
- the human-project-owner review outcome that selects branch A, branch B, or
  explicit deferral
- the pass-forward handoff boundary for later runtime and docs tranches

Out of scope for tranche 2:

- `ext/MetaGraphsNextIO.jl`
- `README.md`
- `docs/src/index.md`
- `test/*`
- any runtime behavior change
- any docs synchronization change
- any later-tranche tasking artifact

## Revalidated current state

The following facts were revalidated against the live repository and installed
upstream sources on 2026-05-07:

- This decision artifact was absent before this tranche run.
- `ext/MetaGraphsNextIO.jl` currently defines `add_node_to_metagraph!`
  only for `VertexData = Nothing` and `VertexData <: NodeRowRef`.
- `ext/MetaGraphsNextIO.jl` currently defines `add_edge_to_metagraph!`
  only for `EdgeData = Nothing`, `EdgeData = Union{Nothing, Float64}`,
  `EdgeData <: Real`, and `EdgeData <: EdgeRowRef`.
- A supplied custom `MetaGraph` with user-owned `VertexData` still fails with
  a raw `MethodError` at `add_node_to_metagraph!`.
- A supplied custom `MetaGraph` with user-owned `EdgeData` still fails with
  a raw `MethodError` at `add_edge_to_metagraph!`.
- The current README and package index docs still describe a broader
  caller-supplied empty-instance customization story than the runtime currently
  honors.
- The supplied-instance path still accepts both single-parent and multi-parent
  sources when the caller supplies an empty `MetaGraph` instance whose type
  parameters already match supported shapes.

## Upstream contract facts

The following upstream primary sources were re-read for this tranche:

- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`

Verified facts from those sources:

- `MetaGraphsNext.MetaGraph(...)` empty-graph construction requires explicit
  constructor inputs. There is no generic zero-argument factory for arbitrary
  concrete `MetaGraph` subtype requests.
- `MetaGraphsNext.Graphs.add_vertex!` accepts caller-supplied metadata values
  for vertex insertion.
- `MetaGraphsNext.Graphs.add_edge!` accepts caller-supplied metadata values
  for edge insertion.
- `MetaGraphsNext.default_weight(graph)` and `MetaGraphsNext.Graphs.weights`
  confirm the current weight-bearing `EdgeData` shapes that the live extension
  already supports directly.
- `Tables.AbstractRow`, `Tables.getcolumn`, `Tables.columnnames`, and the
  optional typed `getcolumn(row, ::Type{T}, i, nm)` entrypoint define the row
  contracts that `NodeRowRef` and `EdgeRowRef` already satisfy.

Local inference from those verified facts:

- LineagesIO can only claim a broader supplied-instance custom-data contract
  if it owns an honest conversion or validation boundary for user-owned
  `VertexData` and `EdgeData` values.
- The current runtime does not own that broader contract yet because it only
  dispatches directly on a narrow hard-coded supported-shape matrix.

## Exact current supported-shape matrix

The current supplied-instance runtime supports the following shapes:

### VertexData

- `VertexData = Nothing`
- `VertexData <: NodeRowRef`

### EdgeData

- `EdgeData = Nothing`
- `EdgeData = Union{Nothing, Float64}`
- `EdgeData <: Real`
- `EdgeData <: EdgeRowRef`

The following live repros confirmed current supported behavior on 2026-05-07:

- `MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, Nothing)` succeeds through
  the supplied-instance `read_lineages!(...)` path.
- `MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, Float64, ...)` succeeds
  through the supplied-instance `read_lineages!(...)` path.
- `MetaGraph(SimpleDiGraph{Int}(), Symbol, LineagesIO.NodeRowRef, LineagesIO.EdgeRowRef, ...)`
  succeeds through the supplied-instance `read_lineages!(...)` path.

## Direct unsupported-shape repros

The following red-state repros still fail on the live repository:

### User-owned VertexData repro

Supplying:

- `MetaGraph(SimpleDiGraph{Int}(), Symbol, MyVertex, Float64, ...)`

currently fails with:

- raw `MethodError`
- failing owner: `add_node_to_metagraph!`
- current failure surface: internal extension dispatch rather than a contract-
  level `ArgumentError`

### User-owned EdgeData repro

Supplying:

- `MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, MyEdge, ...)`

currently fails with:

- raw `MethodError`
- failing owner: `add_edge_to_metagraph!`
- current failure surface: internal extension dispatch rather than a contract-
  level `ArgumentError`

## Affected public surfaces and downstream owners

The supplied-instance custom-data semantic appears through more than one
supported public surface. Each affected surface must remain explicit:

| Surface | Current tranche owner | Later tranche owner | Required later movement |
|---|---|---|---|
| `read_lineages!(source, supplied_metagraph)` | Tranche 2 review gate | Tranche 3 | Runtime owner repair and direct supported or unsupported contract proofs |
| `load(source, supplied_metagraph)` | Tranche 2 review gate | Tranche 3 | Runtime parity proof through the retained compatibility wrapper |
| `README.md` MetaGraphsNext guidance | Tranche 2 review gate | Tranche 5 | Public contract synchronization |
| `docs/src/index.md` MetaGraphsNext guidance | Tranche 2 review gate | Tranche 5 | Public contract synchronization |

No affected public surface is closed by this tranche alone. This tranche
records the contract branch needed before later runtime and docs ownership can
move honestly.

## Branch matrix for review

The remedial PRD left exactly two contract branches open for the supplied-
instance custom-data story.

### Branch A

Status: ratified on 2026-05-08 by the human project owner.

Constructor-based extension on user-owned data types.

If branch A is ratified:

- later implementation may preserve the current custom-data story
- Tranche 3 must implement runtime support through user-owned
  `VertexData(::NodeRowRef)` and `EdgeData(::EdgeWeightType, ::EdgeRowRef)`
  constructor entry points while preserving the current built-in special cases
- Tranche 3 must verify both `read_lineages!(...)` and retained `load(...)`
  surfaces against that contract
- Tranche 5 must synchronize README and package docs to that explicit
  constructor-based extension story

### Branch B

Status: not ratified.

Narrowed supported-shape contract with precise early rejection.

If branch B is ratified:

- later implementation must keep support only for the currently supported
  built-in `VertexData` and `EdgeData` shapes
- Tranche 3 must add explicit early validation with precise `ArgumentError`
  for unsupported shapes
- Tranche 3 must verify both `read_lineages!(...)` and retained `load(...)`
  surfaces against that narrowed contract
- Tranche 5 must synchronize README and package docs to the narrowed supported-
  shape story

## Review outcome

The tranche-2 human review gate is closed.

Recorded outcome as of 2026-05-08:

- Status: branch A ratified
- Ratified branch:
  - branch A

Approval provenance:

- Recorded in this artifact from the human-project-owner answer quoted above

Current unblock state:

- Tranche 3: unblocked for a separate tranche-to-tasking pass
- Tranche 4: blocked by Tranche 3
- Tranche 5: blocked by Tranches 3 and 4

## Branch-specific downstream boundary

Because Branch A is ratified, later workflow is constrained as follows:

- Tranche 3 must own the runtime owner repair in `ext/MetaGraphsNextIO.jl`.
- Tranche 3 may rely on constructor-based extension through
  `VertexData(::NodeRowRef)` and `EdgeData(::EdgeWeightType, ::EdgeRowRef)` as
  the approved user-owned custom-data extension point.
- Tranche 3 must preserve the current built-in special cases for
  `VertexData = Nothing`, `VertexData <: NodeRowRef`, `EdgeData = Nothing`,
  `EdgeData = Union{Nothing, Float64}`, `EdgeData <: Real`, and
  `EdgeData <: EdgeRowRef`.
- Tranche 3 must verify both supported package-owned public surfaces touched by
  this semantic: `read_lineages!(source, supplied_metagraph)` and
  `load(source, supplied_metagraph)`.
- Tranche 5 must synchronize `README.md` and `docs/src/index.md` to the
  constructor-based extension story and close the public contract drift.
- This artifact does not authorize direct runtime implementation by itself.
  A separate Tranche 3 tasking pass is still required before code changes.

## Lock coverage

### Lock 3a

Current closure state: closed.

- The decision-record file exists.
- The artifact records a human-project-owner-reviewed branch decision.

### Lock 3b

Current closure state: closed.

- This artifact records the exact current supported-shape matrix
- This artifact records the direct raw-dispatch failure modes
- Runtime and docs synchronization remain open for later tranches

### Lock 3c

Current closure state: closed.

- This artifact enumerates each affected public surface
- This artifact assigns Tranche 3 or Tranche 5 ownership explicitly

### Lock 1b

Current closure state: closed.

- This artifact labels `00-02_audit-fix-decisions.md` as supporting input only
- This artifact does not treat the design note as a ratified branch choice

### Lock 3d

Current closure state: closed for this tranche.

- This artifact does not authorize runtime implementation, docs changes, or
  later-tranche tasking
- Runtime owner repair remains assigned to Tranche 3
- Public docs synchronization remains assigned to Tranche 5

## Handoff packet

- Active authorities:
  - `AGENTS.md`
  - `CONTRIBUTING.md`
  - `STYLE-agent-handoffs.md`
  - `STYLE-architecture.md`
  - `STYLE-docs.md`
  - `STYLE-git.md`
  - `STYLE-julia.md`
  - `STYLE-upstream-contracts.md`
  - `STYLE-verification.md`
  - `STYLE-vocabulary.md`
  - `STYLE-workflow-docs.md`
  - `STYLE-writing.md`
  - `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
  - `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
  - `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-01_production-final-audit.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-02_audit-fix-decisions.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-2--tasking.md`
  - this decision artifact
- Parent documents:
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-2--tasking.md`
  - this decision artifact
- Settled decisions and non-negotiables:
  - `read_lineages` remains the ratified first-class package-owned public
    surface
  - `BuilderDescriptor` remains the ratified first-class typed builder surface
  - `FileIO.load(...)` remains a compatibility wrapper
  - `load_alife_table(...)` remains a convenience wrapper
  - the supplied-instance path remains directed-only, empty-instance-only, and
    `Symbol`-label-only
  - `00-02_audit-fix-decisions.md` is supporting input only
  - Branch A is ratified
  - constructor-based extension through
    `VertexData(::NodeRowRef)` and `EdgeData(::EdgeWeightType, ::EdgeRowRef)`
    is the settled supplied-instance custom-data contract branch
- Authorization boundary:
  - workflow-only contract decision artifact
  - no runtime, docs, test, example, or later-tranche tasking changes
- Current-state diagnosis:
  - the supplied-instance runtime currently supports only a narrow supported-
    shape matrix
  - user-owned custom-data shapes still fail with raw internal `MethodError`
  - docs still imply a broader custom-data story than the runtime currently
    honors
- Primary-goal lock:
  - Locks 3a through 3d remain separate and explicit
- Direct red-state repros:
  - user-owned `MyVertex` still fails in `add_node_to_metagraph!`
  - user-owned `MyEdge` still fails in `add_edge_to_metagraph!`
  - README and docs still suggest broader support than the live runtime honors
- Owner and invariant under repair:
  - workflow review gate for the supplied-instance custom-data contract
  - one explicit contract branch must exist before later runtime or docs
    closure can proceed honestly
- Exact files or surfaces in scope:
  - this decision artifact
- Exact files or surfaces out of scope:
  - `ext/MetaGraphsNextIO.jl`
  - `README.md`
  - `docs/src/index.md`
  - `test/*`
  - later-tranche tasking
- Required upstream primary sources:
  - the installed `MetaGraphsNext` and `Tables` sources named above
- Green-state gates:
  - this decision artifact exists
  - it records the exact supported-shape matrix
  - it records the direct unsupported-shape repros
  - it inventories each affected public surface and later owner
  - it labels `00-02_audit-fix-decisions.md` as supporting input only
  - it records the human-project-owner-reviewed Branch A ratification
  - it states that Tranche 3 is unblocked only for a separate tasking pass
- Stop conditions:
  - stop and escalate if later work attempts to reopen Branch A without
    explicit human review
  - stop and escalate if later work tries to treat this artifact as direct
    runtime authorization
  - stop and escalate if later work reopens the ratified public naming or
    wrapper-classification boundary

## Green-state and blocked-state summary

Current tranche-2 green-state record:

- The workflow artifact now exists.
- The current contract facts, supported-shape matrix, unsupported-shape repros,
  and affected public surfaces are explicit.
- The human review gate is closed.
- Branch A is recorded as the ratified supplied-instance custom-data contract
  branch.
- Tranche 3 is unblocked for a separate tranche-to-tasking pass.

Current blocked-state record:

- Tranche 2 is complete at the workflow-decision layer.
- Tranche 4 remains blocked by Tranche 3.
- Tranche 5 remains blocked by Tranches 3 and 4.
