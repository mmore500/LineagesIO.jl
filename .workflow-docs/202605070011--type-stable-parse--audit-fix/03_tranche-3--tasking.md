---
date-created: 2026-05-08T00:43:08-07:00
status: proposed
---

# Tasks for Tranche 3: supplied-instance MetaGraphsNext owner repair

Tasking identifier: `20260508T0043--tranche-3-tasking`

Parent tranche: Tranche 3
Parent PRD: `01_prd.md`

## Settled user decisions and environment baseline

- This tasking is for Tranche 3 only in `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`.
- Branch A is ratified by the human project owner in `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`: constructor-based extension through user-owned `VertexData(::NodeRowRef)` and `EdgeData(::EdgeWeightType, ::EdgeRowRef)`.
- `read_lineages` remains the ratified first-class package-owned public surface.
- `BuilderDescriptor` remains the ratified first-class typed builder surface.
- `FileIO.load(...)` remains a `compatibility wrapper`.
- `load_alife_table(...)` remains the in-memory Tables.jl `convenience wrapper`.
- The supplied-instance `MetaGraph` path remains directed-only, empty-instance-only, and `Symbol`-label-only.
- The current built-in supplied-instance special cases remain fixed input and must stay supported:
  - `VertexData = Nothing`
  - `VertexData <: NodeRowRef`
  - `EdgeData = Nothing`
  - `EdgeData = Union{Nothing, Float64}`
  - `EdgeData <: Real`
  - `EdgeData <: EdgeRowRef`
- Tranche 3 owns only the runtime owner repair and direct proof surfaces for the supplied-instance contract. `README.md` and `docs/src/index.md` synchronization remains assigned to Tranche 5 and must not be pulled forward here.
- Library-created `MetaGraph` target tightening remains assigned to Tranche 4 and must not be mixed into this tranche.
- Use the installed upstream `MetaGraphsNext` and `Tables` sources named below. The older upstream checkout path referenced by the parent architecture PRD is not present in the current environment, and no `codebases-and-documentation` workspace was found.
- Use the existing root, `test/Project.toml`, and `docs/Project.toml` environments. Do not add dependencies or edit dependency declarations directly.
- Current repository revalidation on 2026-05-08 confirms the motivating red state is still live while the repository is otherwise green:
  - `julia --project=test test/runtests.jl` passed with `1233` tests in `1m31.6s`
  - `julia --project=docs docs/make.jl` passed
  - direct supplied-instance custom-data repros still fail with raw internal `MethodError` from `add_node_to_metagraph!` and `add_edge_to_metagraph!`

## Governance

Explicit line-by-line reading is mandatory before execution. All downstream work
must read and conform to:

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
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
- this tasking file

The bundled style baseline under `/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/` was also checked during tasking. The bundled style files are byte-identical to the repo-local style files above except for `STYLE-vocabulary.md`, where the repo-local file is the higher-priority project authority. Bundled `CONTRIBUTING.md` was not present there, so repo-local `CONTRIBUTING.md` remains controlling.

`STYLE-makie.md` is not an active authority for this tranche because no Makie,
rendering, or figure work is in scope. `STYLE-python.md` was not present in the
repo-local or bundled governance set.

Workflow authorities used to produce this tasking were `development-policies`
and `devflow-architecture-03--tranche-to-tasks`. Downstream execution must
preserve their pass-forward mandates, especially active-authority restatement,
exact scope control, branch-specific handoff integrity, exact lock-item proof
obligations, required upstream-source naming, failure-oriented verification,
and honest stop conditions.

Mandatory upstream primary sources for this tranche are:

- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`

These sources constrain the tranche as follows:

- `MetaGraphsNext.MetaGraph(...)` construction is explicit and positional for
  empty graphs. There is no generic zero-argument factory for arbitrary
  concrete `MetaGraph` subtype requests.
- `MetaGraphsNext.Graphs.add_vertex!` accepts caller-supplied metadata values
  for non-`Nothing` vertex-data shapes.
- `MetaGraphsNext.Graphs.add_edge!` accepts caller-supplied metadata values for
  non-`Nothing` edge-data shapes.
- `MetaGraphsNext.default_weight(graph)` and `MetaGraphsNext.Graphs.weights`
  define the current numeric edge-data behavior already exercised by the
  built-in `Union{Nothing, Float64}` and `<:Real` paths.
- `Tables.AbstractRow`, `Tables.getcolumn`, `Tables.columnnames`, and the
  optional typed `Tables.getcolumn(row, ::Type{T}, i, nm)` entrypoint define
  the row contracts already satisfied by `NodeRowRef` and `EdgeRowRef`.

Local inference from those verified facts:

- Branch A is honest without inventing a new protocol function because the
  supplied-instance owner can construct user-owned metadata values directly
  before calling `add_vertex!` or `add_edge!`.
- The correct owner boundary for this repair is the conversion step inside
  `add_node_to_metagraph!` and `add_edge_to_metagraph!`, not the public docs,
  not library-created target validation, and not a second helper protocol.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use
`package-owned public surface`, `compatibility wrapper`,
`convenience wrapper`, `authoritative tables`,
`materialized graph or basenode result`, `ownership boundary`, `lock item`,
`red-state repro`, `verification artifact`, `read_lineages`, and
`BuilderDescriptor` consistently. Do not describe this tranche as narrowing the
contract to precise `ArgumentError`s, because that is the non-ratified Branch B
story. Do not describe `00-02_audit-fix-decisions.md` as a ratified contract
decision.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, rebase, reset, and branch creation remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Primary-goal lock

### Lock 3e: Branch-A constructor extension must succeed for supported custom metadata shapes

- The work is not complete if a caller-supplied empty `MetaGraph` with a
  user-owned `VertexData(::NodeRowRef)` constructor or a user-owned
  `EdgeData(::EdgeWeightType, ::EdgeRowRef)` constructor still fails on the
  supplied-instance path.
- Direct red-state repro:
  - `MetaGraph(SimpleDiGraph{Int}(), Symbol, MyVertex, Float64, ...)` currently
    fails with raw `MethodError` from `add_node_to_metagraph!`
  - `MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, MyEdge, ...)` currently
    fails with raw `MethodError` from `add_edge_to_metagraph!`
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix
  shape: direct owner-level and public-surface regressions where constructor-
  backed custom metadata types succeed on both tree and rooted-network
  supplied-instance loads while preserving authoritative tables and graph
  structure. The current implementation fails this artifact because both custom
  shapes still die before construction reaches a user-owned constructor.

### Lock 3f: missing custom constructors must fail at the approved constructor entrypoint, not at internal extension dispatch

- The work is not complete if a caller who chooses a user-owned metadata type
  without the Branch-A constructor still receives a raw `MethodError` naming
  `add_node_to_metagraph!` or `add_edge_to_metagraph!` as the failure surface.
- Direct red-state repro: the current supplied-instance path throws raw
  internal dispatch failures because no generic fallback exists to call
  `MyVertex(::NodeRowRef)` or `MyEdge(::EdgeWeightType, ::EdgeRowRef)`.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix
  shape: negative regressions that intentionally omit the approved user-owned
  constructor and assert that the thrown `MethodError` points at the
  user-owned constructor call rather than at `add_node_to_metagraph!` or
  `add_edge_to_metagraph!`. The current implementation fails because the
  internal helper names still appear in the failure surface.

### Lock 3g: current built-in supplied-instance shapes and invariants must remain intact

- The work is not complete if the Branch-A repair breaks the existing built-in
  `Nothing`, `NodeRowRef`, numeric-edge, or `EdgeRowRef` special cases, or if
  it weakens the directed-only, empty-instance-only, `Symbol`-label-only, or
  multi-parent supplied-instance invariants.
- Direct bad shape to guard against: a fake fix that broadens custom-data
  support by disturbing the already-supported paths or by moving support into a
  less honest owner.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: existing supplied-instance, canonical-owner, and network rejection
  tests remain green, direct built-in-shape assertions remain green, and the
  full suite continues to pass. A change that only makes custom metadata work
  by breaking established built-in shapes fails this lock.

### Lock 3h: both supported public surfaces touched by this semantic must move together

- The work is not complete if `read_lineages!(source, supplied_metagraph)` and
  retained `load(source, supplied_metagraph)` do not agree on the Branch-A
  constructor-based custom-data contract.
- Direct bad shape to guard against: landing the owner repair in a way that
  proves only one public surface, leaving the other surface free to drift.
- Closing tasks: 2 and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: explicit parity regressions in
  `test/extensions/metagraphsnext_public_surface.jl` for both supported
  constructor-backed success and missing-constructor failure across
  `read_lineages(...)` and retained `load(...)`. Current repository state fails
  this artifact because no parity proof exists for Branch-A custom metadata and
  both surfaces still surface the same internal raw `MethodError`.

### Lock 3i: Branch-A scope, compatibility, and docs boundaries must remain intact

- The work is not complete if this tranche reopens Branch B-style early
  `ArgumentError` validation, changes the library-created `MetaGraph` path, or
  synchronizes README or package docs surfaces that remain assigned to
  Tranche 5.
- Direct bad shape to guard against: solving the owner repair by mixing in a
  different contract branch, by touching Tranche 4's library-created tightening
  work, or by using docs edits to conceal runtime drift.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: touched-file scope remains limited to `ext/MetaGraphsNextIO.jl`,
  `test/extensions/metagraphsnext_supplied_basenode.jl`,
  `test/extensions/metagraphsnext_canonical_owner.jl`, and
  `test/extensions/metagraphsnext_public_surface.jl`; `README.md`,
  `docs/src/index.md`, `ext/MetaGraphsNextAbstractTreesIO.jl`, and
  library-created target validation remain untouched.

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
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
  - this tasking file
- Parent documents:
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
  - this tasking file
- Settled decisions and non-negotiables:
  - Branch A is ratified and is the only runtime contract branch this tranche
    may implement.
  - `read_lineages` remains the ratified first-class package-owned public
    surface.
  - `BuilderDescriptor` remains the ratified first-class typed builder surface.
  - `FileIO.load(...)` remains a compatibility wrapper.
  - `load_alife_table(...)` remains the in-memory Tables.jl convenience
    wrapper.
  - The supplied-instance `MetaGraph` path remains directed-only,
    empty-instance-only, and `Symbol`-label-only.
  - The built-in supplied-instance metadata special cases remain fixed input.
  - Tranche 5, not this tranche, owns README and package index docs
    synchronization.
  - Tranche 4, not this tranche, owns library-created `MetaGraph` target
    tightening.
- Authorization boundary:
  - Only the supplied-instance MetaGraphsNext owner in `ext/MetaGraphsNextIO.jl`
    and the directly affected extension tests are in scope.
  - Runtime implementation may redesign the owner internals where needed, but
    only to realize Branch A honestly and to preserve the existing supplied-
    instance invariants.
  - README, docs, examples, public naming, export policy, dependency policy,
    and library-created `MetaGraph` behavior are out of scope.
- Current-state diagnosis:
  - `ext/MetaGraphsNextIO.jl` still defines `add_node_to_metagraph!` only for
    `VertexData = Nothing` and `VertexData <: NodeRowRef`.
  - `ext/MetaGraphsNextIO.jl` still defines `add_edge_to_metagraph!` only for
    `EdgeData = Nothing`, `EdgeData = Union{Nothing, Float64}`,
    `EdgeData <: Real`, and `EdgeData <: EdgeRowRef`.
  - A supplied user-owned `MyVertex` type still fails with raw internal
    `MethodError` in `add_node_to_metagraph!`.
  - A supplied user-owned `MyEdge` type still fails with raw internal
    `MethodError` in `add_edge_to_metagraph!`.
  - `README.md` and `docs/src/index.md` still describe a broader empty-instance
    customization story than the runtime currently honors, but that docs drift
    is intentionally deferred to Tranche 5.
  - `julia --project=test test/runtests.jl` and
    `julia --project=docs docs/make.jl` are currently green despite those bad
    custom-data shapes surviving.
- Primary-goal lock:
  - Locks 3e through 3i above are mandatory and separate.
- Direct red-state repros:
  - `MetaGraph(SimpleDiGraph{Int}(), Symbol, MyVertex, Float64, ...)` still
    fails with raw `MethodError` from `add_node_to_metagraph!`.
  - `MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, MyEdge, ...)` still
    fails with raw `MethodError` from `add_edge_to_metagraph!`.
  - There is still no direct proof that Branch-A constructor semantics hold
    through `read_lineages(...)` and retained `load(...)`.
- Owner and invariant under repair:
  - owner: the supplied-instance conversion boundary in
    `add_node_to_metagraph!` and `add_edge_to_metagraph!`
  - invariant: the supplied-instance MetaGraphsNext path must have one honest
    constructor-based custom-data contract whose owner-level behavior,
    compatibility-wrapper parity, and later docs synchronization can all agree
- Supported public surfaces affected by that owner or semantic:
  - `read_lineages!(source, supplied_metagraph)`
  - `load(source, supplied_metagraph)`
  - `README.md` MetaGraphsNext guidance
  - `docs/src/index.md` MetaGraphsNext guidance
- Exact files or surfaces in scope:
  - `ext/MetaGraphsNextIO.jl`
  - `test/extensions/metagraphsnext_supplied_basenode.jl`
  - `test/extensions/metagraphsnext_canonical_owner.jl`
  - `test/extensions/metagraphsnext_public_surface.jl`
- Exact files or surfaces out of scope:
  - `README.md`
  - `docs/src/index.md`
  - `ext/MetaGraphsNextAbstractTreesIO.jl`
  - library-created `MetaGraph` validation in `validate_extension_load_target`
  - `default_metagraph()`
  - `emit_basenode(...)`
  - `test/extensions/metagraphsnext_activation.jl`
  - `test/extensions/metagraphsnext_simple_newick.jl`
  - `test/extensions/metagraphsnext_tables_after_load.jl`
  - `test/extensions/metagraphsnext_abstracttrees.jl`
  - `test/extensions/metagraphsnext_network_rejection.jl`
  - public naming, export, migration, deprecation, and docs-classification
    policy
- Required upstream primary sources:
  - the installed `MetaGraphsNext` and `Tables` sources named in the Governance
    section above
- Green-state gates:
  - constructor-backed custom `VertexData` succeeds on a supplied-instance tree
    load
  - constructor-backed custom `VertexData` plus `EdgeData` succeeds on a
    supplied-instance rooted-network load
  - a missing `VertexData(::NodeRowRef)` constructor fails at the user-owned
    constructor entrypoint rather than at `add_node_to_metagraph!`
  - a missing `EdgeData(::EdgeWeightType, ::EdgeRowRef)` constructor fails at
    the user-owned constructor entrypoint rather than at
    `add_edge_to_metagraph!`
  - built-in supplied-instance shapes remain green
  - parity remains green for `canonical_load(...)` vs retained `load(...)`
    where that owner proof already exists
  - parity becomes explicit for `read_lineages(...)` vs retained `load(...)`
    for Branch-A custom metadata
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
- Stop conditions:
  - stop and escalate if implementation seems to require reopening Branch A or
    introducing Branch B-style early `ArgumentError` validation
  - stop and escalate if runtime repair appears to require changing the
    library-created `MetaGraph` path, `default_metagraph()`, or
    `validate_extension_load_target`
  - stop and escalate if the current docs drift appears to require sync work in
    this tranche instead of remaining deferred to Tranche 5
  - stop and escalate if the installed upstream `MetaGraphsNext` or `Tables`
    sources no longer support the constructor-based local inference recorded in
    this tasking
  - stop and revise this tasking if the direct red-state repros no longer match
    the live repository

## Required revalidation before implementation

- Read `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`,
  and `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
  in full.
- Read `ext/MetaGraphsNextIO.jl` in full.
- Read `README.md` and `docs/src/index.md` in full even though they remain out
  of scope, because their current drift is part of the red-state diagnosis and
  the defer-to-Tranche-5 boundary must stay explicit.
- Read `test/extensions/metagraphsnext_supplied_basenode.jl`,
  `test/extensions/metagraphsnext_canonical_owner.jl`, and
  `test/extensions/metagraphsnext_public_surface.jl` in full.
- Read the installed `MetaGraphsNext` and `Tables` sources named above in full.
- Re-check that Branch A remains the ratified supplied-instance contract branch.
- Re-check that the supplied-instance owner still exposes only the current
  narrow hard-coded `VertexData` and `EdgeData` method set before any new code
  is written.
- Re-run the direct `MyVertex` and `MyEdge` repros and confirm that the live
  failures still name `add_node_to_metagraph!` and `add_edge_to_metagraph!`.
- Re-check that both `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` are still green before code changes.
- Re-check that `README.md` and `docs/src/index.md` still describe the broader
  empty-instance customization story that Tranche 5 must later synchronize.
- Re-check the user-authorized disruption boundary before editing code.
- If any of those revalidation points no longer hold, stop and revise this
  tasking before proceeding.

## Tranche execution rule

This tranche implements only the Branch-A runtime owner repair and the direct
verification needed to prove it honestly. It may redesign supplied-instance
internals in `ext/MetaGraphsNextIO.jl` where necessary, but it must begin and
end in the tranche's required green state.

When this tranche is complete:

- the supplied-instance `MetaGraph` owner supports user-owned
  `VertexData(::NodeRowRef)` and `EdgeData(::EdgeWeightType, ::EdgeRowRef)`
  constructors without inventing a second protocol
- missing user-owned constructors fail at the constructor entrypoint rather
  than at raw extension-helper dispatch
- the built-in supplied-instance special cases remain intact
- direct owner-level proof exists for the Branch-A custom-data contract
- direct parity proof exists for both supported public surfaces touched by the
  semantic: `read_lineages(...)` and retained `load(...)`
- `README.md` and `docs/src/index.md` remain untouched and explicitly deferred
  to Tranche 5
- the library-created `MetaGraph` path remains untouched and explicitly
  deferred to Tranche 4

This tranche must not claim closure for public docs drift. It closes the runtime
owner repair only, while leaving the later docs and public-contract
synchronization work explicit and unavoidable.

## Non-negotiable execution rules

- Do not implement Branch B-style early validation with precise `ArgumentError`
  for unsupported custom-data shapes.
- Do not add a second extension protocol function, trait, or registry for
  custom metadata conversion. Branch A's approved extension point is the
  user-owned constructor itself.
- Do not catch and rewrap missing-constructor `MethodError` in a way that hides
  the user-owned constructor entrypoint.
- Do not move custom-data conversion into `add_child`, wrapper layers, or tests.
  The owner must remain `add_node_to_metagraph!` and
  `add_edge_to_metagraph!`.
- Do not modify `README.md`, `docs/src/index.md`, or any example files in this
  tranche.
- Do not modify `validate_extension_load_target`, `default_metagraph()`,
  `emit_basenode(...)`, or the library-created `MetaGraph` contract in this
  tranche.
- Do not reopen `read_lineages`, `BuilderDescriptor`, `FileIO.load(...)`, or
  `load_alife_table(...)` naming or classification.
- Do not add dependencies, change manifests, or edit dependency declarations.
- Do not let a green suite stand in for the required direct custom-data proof.

## Concrete anti-patterns or removal targets

- raw internal `MethodError` from `add_node_to_metagraph!` as the user-facing
  failure surface for a supported Branch-A custom `VertexData` shape
- raw internal `MethodError` from `add_edge_to_metagraph!` as the user-facing
  failure surface for a supported Branch-A custom `EdgeData` shape
- any second implicit custom-data contract that coexists with the ratified
  constructor-based contract
- any Branch B-style validation helper or fallback that narrows the ratified
  Branch-A runtime story
- any shadow conversion logic in `add_child`, compatibility wrappers, or tests
  that leaves the owner boundary unrepaired
- any partial migration where tree loads work but rooted-network supplied-
  instance loads still fail for the same approved custom-data contract
- any public-surface drift where `read_lineages(...)` and retained `load(...)`
  differ for the same supplied-instance custom-data request
- any README or docs edits that make it look as if the public contract drift is
  already closed

## Failure-oriented verification

- The direct `MyVertex` red-state repro must fail the old implementation:
  `MetaGraph(SimpleDiGraph{Int}(), Symbol, MyVertex, Float64, ...)` currently
  raises raw `MethodError` from `add_node_to_metagraph!`.
- The direct `MyEdge` red-state repro must fail the old implementation:
  `MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, MyEdge, ...)` currently
  raises raw `MethodError` from `add_edge_to_metagraph!`.
- Positive Branch-A verification must include both a tree fixture and a
  rooted-network fixture so that a fake fix cannot pass while multi-parent
  supplied-instance construction still breaks.
- Negative Branch-A verification must intentionally omit the user-owned
  constructor and assert that the thrown `MethodError` now names
  `MyVertex(::NodeRowRef)` or
  `MyEdge(::EdgeWeightType, ::EdgeRowRef)` rather than
  `add_node_to_metagraph!` or `add_edge_to_metagraph!`.
- Owner-level verification must include at least one direct
  `LineagesIO.canonical_load(...)` proof so this tranche cannot hide behind
  wrapper-only coverage.
- Public-surface verification must include at least one direct parity proof for
  `read_lineages(...)` and retained `load(...)` using the same custom metadata
  contract.
- Built-in supplied-instance paths must continue to pass their existing tests,
  so a fake fix that helps only custom metadata while breaking `Nothing`,
  numeric edge-data, or row-reference storage still fails.
- `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`
  remain mandatory tranche-end gates.
- README and package docs text are not verification artifacts for this tranche,
  because public docs synchronization is intentionally deferred to Tranche 5.

## Tasks

### 1. Implement the Branch-A constructor fallbacks in the supplied-instance MetaGraphsNext owner

**Type**: WRITE  
**Output**: `ext/MetaGraphsNextIO.jl` supports Branch-A custom `VertexData` and `EdgeData` shapes by calling user-owned constructors from the supplied-instance owner while preserving all current built-in special cases and supplied-instance invariants.  
**Depends on**: none  
**Positive contract**: Add the owner-level Branch-A repair in `ext/MetaGraphsNextIO.jl`. Keep the existing specific `add_node_to_metagraph!` and `add_edge_to_metagraph!` methods for the current built-in shapes, and add one generic node-data fallback and one generic edge-data fallback that convert through the approved user-owned constructors before calling `MetaGraphsNext.Graphs.add_vertex!` or `MetaGraphsNext.Graphs.add_edge!`. The generic node-data fallback must construct `NodeDataT(nodedata)` from the `NodeRowRef`. The generic edge-data fallback must construct `EdgeDataT(edgeweight, edgedata)` from the `EdgeWeightType` and `EdgeRowRef`. Preserve `validate_empty_metagraph`, preserve the current multi-parent supplied-instance path, preserve `Symbol` labels, and keep all custom-data conversion owned by `add_node_to_metagraph!` and `add_edge_to_metagraph!` rather than spreading it into `add_child`.  
**Negative contract**: Do not add Branch B-style early validation. Do not add a new protocol function or trait. Do not catch and rewrite missing-constructor `MethodError`. Do not touch the library-created `MetaGraph` path, `validate_extension_load_target`, `default_metagraph()`, `emit_basenode(...)`, `ext/MetaGraphsNextAbstractTreesIO.jl`, README, package docs, or example files. Do not duplicate conversion logic in wrapper layers or tests.  
**Files**: `ext/MetaGraphsNextIO.jl`  
**Out of scope**: `README.md`, `docs/src/index.md`, `ext/MetaGraphsNextAbstractTreesIO.jl`, `test/*`, library-created `MetaGraph` target validation, public naming or classification decisions, and dependency declarations  
**Verification**: Manually re-run the direct supplied-instance repros with test-local `MyVertex` and `MyEdge` types. Confirm that a supported `MyVertex(::LineagesIO.NodeRowRef)` constructor now allows a tree supplied-instance load to succeed, that a supported pair of `MyVertex(::LineagesIO.NodeRowRef)` and `MyEdge(::LineagesIO.EdgeWeightType, ::LineagesIO.EdgeRowRef)` constructors now allows a rooted-network supplied-instance load to succeed, and that missing constructors now fail at the user-owned constructor entrypoint instead of at `add_node_to_metagraph!` or `add_edge_to_metagraph!`. Then run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. The old implementation fails this verification because the direct repros still die in internal helper dispatch.

### 2. Add owner-level regressions for constructor-backed success, multi-parent coverage, and missing-constructor failure surfaces

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_supplied_basenode.jl` and `test/extensions/metagraphsnext_canonical_owner.jl` directly prove the Branch-A owner repair at the supplied-instance boundary, including both positive custom-data success and negative missing-constructor failure surfaces.  
**Depends on**: 1  
**Positive contract**: Extend `test/extensions/metagraphsnext_supplied_basenode.jl` with test-local custom metadata structs and constructors that prove Branch-A behavior on the supplied-instance path. Cover at least one single-parent tree fixture and at least one rooted-network fixture, and prove both custom vertex and custom edge metadata construction. Add negative regressions that intentionally omit the approved constructor and assert that the failure now names the user-owned constructor entrypoint. Extend `test/extensions/metagraphsnext_canonical_owner.jl` with at least one direct `LineagesIO.canonical_load(...)` custom-data proof so the repaired owner is exercised without depending only on public wrapper normalization. Preserve existing authoritative-table snapshot checks and preserve the built-in supplied-instance special-case tests already present in those files. Keep any helper custom-data structs local to the touched test files rather than introducing new runtime helpers or a new test include.  
**Negative contract**: Do not replace the owner-level proof with `read_lineages(...)`-only or `load(...)`-only coverage. Do not remove or weaken the current `Nothing`, numeric edge-data, row-reference, directed-only, empty-instance-only, or `Symbol`-label regressions. Do not assert on source text, method-count trivia, or other weak proxies that would still pass if the owner boundary remained wrong. Do not reorder `test/runtests.jl` or add a new shared test harness for this narrow tranche.  
**Files**: `test/extensions/metagraphsnext_supplied_basenode.jl`; `test/extensions/metagraphsnext_canonical_owner.jl`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, `test/extensions/metagraphsnext_public_surface.jl`, `README.md`, `docs/src/index.md`, `test/runtests.jl`, library-created `MetaGraph` tests, and public docs synchronization  
**Verification**: Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. Confirm that the new owner-level regressions would have failed the old implementation because constructor-backed custom metadata still previously threw raw `MethodError` from `add_node_to_metagraph!` or `add_edge_to_metagraph!`, and because no direct canonical-owner proof for Branch-A custom metadata previously existed.

### 3. Add `read_lineages` and retained `load` parity proofs for the Branch-A custom-data contract

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_public_surface.jl` proves that both supported public surfaces touched by this semantic move together for constructor-backed success and missing-constructor failure.  
**Depends on**: 1, 2  
**Positive contract**: Extend `test/extensions/metagraphsnext_public_surface.jl` with direct parity coverage for the supplied-instance Branch-A custom-data story. Use the same supplied-instance custom metadata contract through both `LineagesIO.read_lineages!(...)` and retained `load(...)`. Add at least one positive parity test on a rooted-network fixture that compares authoritative-table snapshots, basenode identity, and graph-contract snapshots between the two surfaces for constructor-backed custom metadata. Add at least one negative parity regression that intentionally omits the approved constructor and asserts that both surfaces fail at the same user-owned constructor entrypoint rather than at `add_node_to_metagraph!` or `add_edge_to_metagraph!`. Keep the docs-sync boundary explicit by leaving README and package docs untouched.  
**Negative contract**: Do not substitute owner-level `canonical_load(...)` coverage for public-surface parity. Do not prove only one of the two public surfaces. Do not use a one-way subtype check, a graph-type-only assertion, or a helper-only success proxy that would still pass if custom metadata drifted between `read_lineages(...)` and `load(...)`. Do not edit README or package docs in this task.  
**Files**: `test/extensions/metagraphsnext_public_surface.jl`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, `README.md`, `docs/src/index.md`, `test/extensions/metagraphsnext_supplied_basenode.jl`, `test/extensions/metagraphsnext_canonical_owner.jl`, library-created `MetaGraph` tests, and Tranche 5 docs work  
**Verification**: Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. Confirm that the new parity regressions would have failed the old implementation because both public surfaces previously exposed raw internal helper `MethodError` for custom metadata and because no Branch-A public-surface parity proof previously existed.
