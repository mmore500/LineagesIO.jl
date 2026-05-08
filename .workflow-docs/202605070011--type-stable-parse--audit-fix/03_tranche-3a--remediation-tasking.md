---
date-created: 2026-05-08T01:32:59-07:00
date-revised: 2026-05-08T01:32:59-07:00
status: proposed
---

# Tasks for Tranche 3 remediation: supplied-instance failure atomicity and caller-owned graph integrity

Tasking identifier: `20260508T013259--tranche-3-remediation-tasking`

Parent tranche: Tranche 3
Parent PRD: `01_prd.md`
Parent tasking: `03_tranche-3--tasking.md`

## Settled user decisions and environment baseline

- This remediation is for Tranche 3 only in
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`.
- Branch A remains ratified by the human project owner in
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`:
  constructor-based extension through user-owned
  `VertexData(::NodeRowRef)` and
  `EdgeData(::EdgeWeightType, ::EdgeRowRef)`.
- `read_lineages` remains the ratified first-class package-owned public
  surface.
- `BuilderDescriptor` remains the ratified first-class typed builder surface.
- `FileIO.load(...)` remains a `compatibility wrapper`.
- `load_alife_table(...)` remains the in-memory Tables.jl
  `convenience wrapper`.
- The supplied-instance `MetaGraph` path remains directed-only,
  empty-instance-only, and `Symbol`-label-only.
- The current built-in supplied-instance special cases remain fixed input and
  must stay supported:
  - `VertexData = Nothing`
  - `VertexData <: NodeRowRef`
  - `EdgeData = Nothing`
  - `EdgeData = Union{Nothing, Float64}`
  - `EdgeData <: Real`
  - `EdgeData <: EdgeRowRef`
- The landed Tranche 3 Branch-A repair is real and must be preserved. This
  remediation exists because post-delivery review found one surviving
  owner-level failure path, not because Branch A is being reopened.
- Tranche 4 still owns library-created `MetaGraph` target tightening and must
  not be mixed into this remediation.
- Tranche 5 still owns `README.md` and `docs/src/index.md` synchronization and
  must not be pulled forward here.
- Use the installed upstream `MetaGraphsNext` and `Tables` sources named below.
  The older upstream checkout path referenced by the parent architecture PRD is
  not present in the current environment, and no
  `codebases-and-documentation` workspace was found.
- Use the existing root, `test/Project.toml`, and `docs/Project.toml`
  environments. Do not add dependencies or edit dependency declarations
  directly.
- Live revalidation on 2026-05-08 confirms the motivating red state is still
  live while the repository is otherwise green:
  - `julia --project=test test/runtests.jl` passed with `1301` tests in
    `1m20.2s`
  - `julia --project=docs docs/make.jl` passed
  - a direct missing-custom-edge repro on
    `test/fixtures/rooted_network_with_annotations.nwk` still leaves the
    caller-owned supplied `MetaGraph` dirty after the first failure:
    `nv == 2`, `ne == 0`
  - retrying the same supplied graph still changes the failure class from the
    constructor `MethodError` to
    `ArgumentError: A supplied MetaGraph must be empty before loading into it.`
- Current Branch-A tests prove supported success and constructor-entrypoint
  error surfacing, but they do not yet prove failure atomicity:
  `test/extensions/metagraphsnext_supplied_basenode.jl`,
  `test/extensions/metagraphsnext_canonical_owner.jl`, and
  `test/extensions/metagraphsnext_public_surface.jl` currently assert error
  text for missing custom edge constructors without checking the post-failure
  graph state or retrying the same supplied instance.

## Governance

Explicit line-by-line reading is mandatory before execution. All downstream
work must read and conform to:

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
- `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3--tasking.md`
- this remediation tasking file

The bundled style baseline under
`/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/`
was also checked during tasking. The bundled style files are byte-identical to
the repo-local style files above except for `STYLE-vocabulary.md`, where the
repo-local file is the higher-priority project authority. Bundled
`CONTRIBUTING.md` was not present there, so repo-local `CONTRIBUTING.md`
remains controlling.

`STYLE-makie.md` is not an active authority for this tranche because no Makie,
rendering, or figure work is in scope. `STYLE-python.md` was not present in the
repo-local or bundled governance set.

Workflow authorities used to produce this tasking were `development-policies`
and `devflow-architecture-03--tranche-to-tasks`. Downstream execution must
preserve their pass-forward mandates, especially active-authority restatement,
exact scope control, exact lock-item proof obligations, required upstream-source
naming, failure-oriented verification, and honest stop conditions.

Mandatory upstream primary sources for this remediation are:

- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/README.md`
- `/home/jeetsukumaran/.julia/packages/Tables/cRTb7/src/Tables.jl`

These sources constrain the remediation as follows:

- `MetaGraphsNext.Graphs.add_vertex!` and `MetaGraphsNext.Graphs.add_edge!`
  mutate the caller-owned graph in place.
- The current extension already has all information needed to construct custom
  edge payloads before graph mutation:
  `edgeweight`, `EdgeRowRef`, and the target graph type parameters.
- `Tables.AbstractRow`, `Tables.getcolumn`, `Tables.columnnames`, and the
  optional typed `Tables.getcolumn(row, ::Type{T}, i, nm)` entrypoint define
  the row contracts already satisfied by `EdgeRowRef`.

Local inference from those verified facts:

- The current generic node-data fallback already evaluates
  `NodeDataT(nodedata)` before `add_vertex!`, so missing
  `VertexData(::NodeRowRef)` constructors do not create the reviewed
  partial-mutation bug shape.
- The current generic edge-data fallback evaluates
  `EdgeDataT(edgeweight, edgedata)` only after the supplied-instance child node
  has already been inserted by `add_child`, so failing custom edge
  construction can dirty the caller-owned graph.
- The narrowest honest owner repair is to pre-materialize edge payloads in the
  extension-private supplied-instance owner layer before any child-node
  mutation occurs, while preserving the same user-owned constructor entrypoint
  and without inventing a second protocol.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use
`package-owned public surface`, `compatibility wrapper`,
`convenience wrapper`, `authoritative tables`,
`materialized graph or basenode result`, `ownership boundary`, `lock item`,
`red-state repro`, `verification artifact`, `read_lineages`, and
`BuilderDescriptor` consistently. Do not describe this remediation as a Branch
B validation rewrite, because the ratified contract branch is still Branch A.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, rebase, reset, and branch creation remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Review-derived current-state diagnosis

This remediation exists because the landed Tranche 3 implementation still fails
one high-severity owner-level contract in the supplied-instance custom-edge
failure path:

- `ext/MetaGraphsNextIO.jl` now owns Branch-A constructor-backed success for
  supported custom `VertexData` and `EdgeData` shapes, and the missing-
  constructor failures now surface at the user-owned constructor entrypoint.
- However, both supplied-instance `add_child` paths still insert the child node
  before the custom edge payload is guaranteed to exist:
  - single-parent `add_child(...)` calls `add_node_to_metagraph!` and only then
    calls `add_edge_to_metagraph!`
  - multi-parent `add_child(...)` calls `add_node_to_metagraph!` and only then
    loops through `add_edge_to_metagraph!`
- A missing or throwing custom edge constructor therefore escapes only after
  caller-owned mutation has already begun.
- The live missing-custom-edge repro on
  `rooted_network_with_annotations.nwk` currently proves that bad shape
  directly:
  - the first failure raises the user-owned constructor `MethodError`
  - the caller-owned supplied graph is left at `nv == 2`, `ne == 0`
  - retrying the same object no longer reports the constructor problem first;
    it now fails earlier with the empty-instance validation error
- The current suite and docs build are green despite that surviving bug, so
  this remediation must add direct failure-atomicity proof rather than relying
  on inherited green-state gates.

These are not style-only issues. A supported public surface that accepts a
caller-owned empty supplied `MetaGraph` must not corrupt that caller-owned
object merely because the chosen Branch-A custom `EdgeData` constructor is
missing or throws before the first edge can be recorded.

## Primary-goal lock

### Lock 3j: failed custom-edge construction must not dirty a caller-owned supplied MetaGraph

- The work is not complete if a supplied empty `MetaGraph` with unsupported or
  constructor-throwing custom `EdgeData` can still gain nodes or edges before
  the failure escapes.
- Direct red-state repro: with
  `MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, MissingEdge, ...)` on
  `rooted_network_with_annotations.nwk`, the first failed load currently leaves
  the caller-owned target at `nv == 2`, `ne == 0`.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix
  shape: direct owner-level and public-surface regressions that assert
  `nv(graph) == 0` and `ne(graph) == 0` immediately after failed custom-edge
  construction on the same caller-owned target. The current implementation
  fails this artifact because the supplied graph is left partially populated.

### Lock 3k: retrying the same supplied target must preserve the original failure class

- The work is not complete if retrying the same caller-owned target after a
  failed custom-edge construction changes the failure from the constructor
  error to the empty-instance validation error.
- Direct red-state repro: after the first missing-custom-edge failure dirties
  the supplied graph, the second load currently fails with
  `ArgumentError: A supplied MetaGraph must be empty before loading into it.`
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix
  shape: regressions that retry the same supplied graph after a failed
  custom-edge load and assert the second attempt still fails at the same
  user-owned constructor surface instead of at `validate_empty_metagraph`. The
  current implementation fails because retrying the same object changes the
  failure class.

### Lock 3l: both supported public surfaces must preserve caller-owned graph integrity for this failure path

- The work is not complete if `read_lineages(source, supplied_metagraph)` and
  retained `load(source, supplied_metagraph)` do not agree on post-failure
  graph state and retry behavior for unsupported custom `EdgeData`.
- Direct bad shape to guard against: repairing the owner-level path but proving
  only `canonical_load(...)` or only one user-facing surface, leaving the
  other surface free to drift.
- Closing tasks: 2 and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: explicit regressions in
  `test/extensions/metagraphsnext_public_surface.jl` that prove both supported
  public surfaces leave their own supplied targets empty and retryable after
  failed custom-edge construction. A helper-only or canonical-owner-only proof
  fails this lock.

### Lock 3m: the remediation must preserve the landed Branch-A success contract and stay inside tranche scope

- The work is not complete if the remediation weakens supported Branch-A
  success, reopens Branch B-style early validation, changes the library-created
  `MetaGraph` path, or synchronizes README or package docs surfaces that remain
  assigned to Tranche 5.
- Direct bad shape to guard against: solving failure atomicity by catching and
  rewriting constructor failures, resetting caller state in wrapper layers,
  replacing the caller-owned graph with a fresh graph, or mixing in Tranche 4
  or Tranche 5 work.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: existing Branch-A positive tests remain green, touched-file scope
  remains limited to `ext/MetaGraphsNextIO.jl`,
  `test/extensions/metagraphsnext_supplied_basenode.jl`,
  `test/extensions/metagraphsnext_canonical_owner.jl`, and
  `test/extensions/metagraphsnext_public_surface.jl`, and the final
  `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` gates remain green.

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
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3--tasking.md`
  - this remediation tasking file
- Parent documents:
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`
  - `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3--tasking.md`
  - this remediation tasking file
- Settled decisions and non-negotiables:
  - Branch A remains the only ratified runtime contract branch.
  - `read_lineages` remains the ratified first-class package-owned public
    surface.
  - `BuilderDescriptor` remains the ratified first-class typed builder
    surface.
  - `FileIO.load(...)` remains a compatibility wrapper.
  - `load_alife_table(...)` remains the in-memory Tables.jl convenience
    wrapper.
  - The supplied-instance `MetaGraph` path remains directed-only,
    empty-instance-only, and `Symbol`-label-only.
  - The built-in supplied-instance metadata special cases remain fixed input.
  - Tranche 4 still owns library-created `MetaGraph` target tightening.
  - Tranche 5 still owns README and package docs synchronization.
- Authorization boundary:
  - Only the supplied-instance child-construction owner ordering in
    `ext/MetaGraphsNextIO.jl` and the directly affected extension tests are in
    scope.
  - This remediation owns failure atomicity for custom edge-payload
    construction only. It does not promise a new general transactional rollback
    story for unrelated graph-insertion failures outside the reviewed red-state
    repro.
- Current-state diagnosis:
  - the Branch-A repair is landed and should remain
  - failing custom edge construction still occurs after the child node has been
    inserted on supplied-instance paths
  - the caller-owned supplied graph is still left dirty after failure
  - retrying the same supplied graph still changes the failure class
  - current tests still do not prove post-failure graph integrity
- Primary-goal lock:
  - Locks 3j through 3m above are mandatory and separate
- Direct red-state repros:
  - first failed missing-custom-edge load leaves the caller-owned supplied
    graph at `nv == 2`, `ne == 0`
  - retrying the same supplied graph now fails with the empty-instance
    validation error instead of the constructor failure
- Owner and invariant under repair:
  - owner: supplied-instance child-construction ordering in
    `ext/MetaGraphsNextIO.jl`
  - invariant: failed custom-edge construction on a caller-owned empty supplied
    `MetaGraph` must leave the supplied graph unchanged and retryable with the
    same failure class
- Supported public surfaces affected by that owner or semantic:
  - `LineagesIO.canonical_load(...)` through `BasenodeLoadRequest`
  - `read_lineages(source, supplied_metagraph)`
  - `load(source, supplied_metagraph)`
- Exact files or surfaces in scope:
  - `ext/MetaGraphsNextIO.jl`
  - `test/extensions/metagraphsnext_supplied_basenode.jl`
  - `test/extensions/metagraphsnext_canonical_owner.jl`
  - `test/extensions/metagraphsnext_public_surface.jl`
- Exact files or surfaces out of scope:
  - `README.md`
  - `docs/src/index.md`
  - `ext/MetaGraphsNextAbstractTreesIO.jl`
  - `validate_extension_load_target`
  - `default_metagraph()`
  - library-created `MetaGraph` validation
  - `src/read_lineages.jl`
  - `BuilderDescriptor`
  - `test/extensions/metagraphsnext_activation.jl`
  - `test/extensions/metagraphsnext_simple_newick.jl`
  - `test/extensions/metagraphsnext_tables_after_load.jl`
  - `test/extensions/metagraphsnext_abstracttrees.jl`
  - `test/extensions/metagraphsnext_network_rejection.jl`
  - public naming, export, migration, deprecation, and docs-classification
    policy
- Required upstream primary sources:
  - the installed `MetaGraphsNext` and `Tables` sources named in the
    Governance section above
- Green-state gates:
  - failed custom-edge construction leaves the supplied target at
    `nv == 0`, `ne == 0`
  - retrying the same supplied target reproduces the same constructor failure
    rather than the empty-instance validation error
  - current supported Branch-A custom `VertexData` and `EdgeData` success paths
    remain green
  - current built-in supplied-instance shapes remain green
  - `canonical_load(...)`, `read_lineages(...)`, and retained `load(...)`
    each have direct proof for the repaired failure-atomicity contract
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
- Stop conditions:
  - stop and escalate if the live missing-custom-edge repro no longer matches
    this tasking
  - stop and escalate if preserving caller-owned graph identity appears to
    require replacing the supplied graph object
  - stop and escalate if the repair appears to require Branch B-style early
    validation, library-created `MetaGraph` changes, or docs synchronization
  - stop and revise this tasking if the current tests already prove
    failure atomicity, because the diagnosis would then be stale

## Required revalidation before implementation

- Read `.workflow-docs/202605070011--type-stable-parse--audit-fix/01_prd.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md`,
  `.workflow-docs/202605070011--type-stable-parse--audit-fix/03_tranche-3--tasking.md`,
  and this remediation tasking file in full.
- Read `ext/MetaGraphsNextIO.jl` in full.
- Read `test/extensions/metagraphsnext_supplied_basenode.jl`,
  `test/extensions/metagraphsnext_canonical_owner.jl`, and
  `test/extensions/metagraphsnext_public_surface.jl` in full.
- Read `README.md` and `docs/src/index.md` in full even though they remain out
  of scope, because the docs-sync defer-to-Tranche-5 boundary must remain
  explicit.
- Read the installed `MetaGraphsNext` and `Tables` sources named above in full.
- Re-run the direct missing-custom-edge repro and confirm that the first
  failure still leaves the supplied target dirty and the second load still
  flips to the empty-instance validation error.
- Re-check that missing custom vertex constructors do not already exhibit the
  same partial-mutation bug shape before broadening remediation scope.
- Re-check that Branch A remains the ratified supplied-instance contract
  branch.
- Re-check that `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` are still green before code changes.
- Re-check that README and package docs synchronization remains explicitly
  deferred to Tranche 5.
- Re-check the user-authorized disruption boundary before editing code.
- If any of those revalidation points no longer hold, stop and revise this
  tasking before proceeding.

## Tranche execution rule

This remediation implements only the supplied-instance failure-atomicity repair
for unsupported or constructor-throwing custom `EdgeData` on caller-owned empty
`MetaGraph` targets, plus the direct verification needed to prove it honestly.
It may refactor extension-private supplied-instance helpers in
`ext/MetaGraphsNextIO.jl` where necessary, but it must begin and end in the
remediation green state.

When this remediation is complete:

- the supplied-instance owner pre-materializes custom edge payloads before any
  caller-owned child-node mutation begins
- failed custom-edge construction leaves the caller-owned supplied graph
  unchanged
- retrying the same supplied graph reproduces the same constructor failure
- supported Branch-A custom metadata success remains intact
- direct owner-level proof exists for failure atomicity on
  `canonical_load(...)`
- direct public-surface proof exists for failure atomicity on
  `read_lineages(...)` and retained `load(...)`
- README and package docs remain untouched and explicitly deferred to Tranche 5
- the library-created `MetaGraph` path remains untouched and explicitly
  deferred to Tranche 4

This remediation does not reopen the public contract branch and does not create
a new general rollback policy for unrelated `add_edge!` or `add_vertex!`
failures that are outside the reviewed red-state repro.

## Non-negotiable execution rules

- Do not reopen Branch A or implement Branch B-style early validation with
  precise `ArgumentError` for unsupported custom-data shapes.
- Do not add a second extension protocol function, trait, or registry for
  custom metadata conversion.
- Do not catch and rewrite missing-constructor `MethodError` in a way that
  hides the user-owned constructor entrypoint.
- Do not fix this in wrapper layers by catching failure, clearing the graph,
  reconstructing a new graph, or retrying under the hood.
- Do not replace the caller-owned supplied graph object with a fresh graph and
  call that success.
- Do not move the ownership boundary to `read_lineages(...)`, retained
  `load(...)`, docs, or tests.
- Do not reopen vertex-constructor semantics unless live revalidation proves
  the same reviewed bug survives there too.
- Do not modify `README.md`, `docs/src/index.md`, example files,
  `validate_extension_load_target`, `default_metagraph()`,
  `emit_basenode(...)`, or the library-created `MetaGraph` contract.
- Do not add dependencies, change manifests, or edit dependency declarations.
- Do not let a green suite stand in for the required direct failure-atomicity
  proof.

## Concrete anti-patterns or removal targets

- supplied-instance `add_child(...)` ordering that inserts a node before custom
  edge payload materialization is guaranteed to succeed
- tests that assert only the missing-constructor error text while never
  inspecting the post-failure graph state
- tests that use a fresh supplied graph for every failure assertion and never
  retry the same target
- wrapper-layer catch-and-clear or catch-and-rebuild behavior that masks a dirty
  owner path
- any fix that preserves success only by narrowing the ratified Branch-A
  contract or by reclassifying the user-visible failure surface
- any README or package docs edit that makes it look as if public contract
  synchronization is already complete

## Failure-oriented verification

- The direct missing-custom-edge red-state repro must fail the old
  implementation:
  `MetaGraph(SimpleDiGraph{Int}(), Symbol, Nothing, MissingEdge, ...)` on
  `rooted_network_with_annotations.nwk` currently raises the user-owned
  constructor `MethodError`, leaves the caller-owned graph at `nv == 2`,
  `ne == 0`, and changes the second attempt into the empty-instance validation
  error.
- Positive Branch-A verification must keep the existing constructor-backed
  custom success paths green so a fake fix cannot preserve atomicity only by
  narrowing the supported contract again.
- Owner-level verification must include at least one direct
  `LineagesIO.canonical_load(...)` proof so this remediation cannot hide behind
  wrapper-only coverage.
- Owner-level verification must also include one multi-parent supplied-instance
  failure proof where custom edge construction fails only after earlier
  single-parent edges would otherwise have succeeded, so the multi-parent
  `add_child(parents::AbstractVector, ...)` ordering is directly exercised.
- Public-surface verification must include explicit post-failure graph-state
  and same-target retry proofs for both `read_lineages(...)` and retained
  `load(...)`.
- Built-in supplied-instance paths and existing Branch-A positive tests must
  continue to pass so a fake fix that only guards the reviewed failure while
  breaking supported custom metadata still fails.
- `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` remain mandatory remediation-end gates.
- README and package docs text are not verification artifacts for this
  remediation, because public docs synchronization is intentionally deferred to
  Tranche 5.

## Tasks

### 1. Pre-materialize supplied-instance custom edge payloads before caller-owned mutation

**Type**: WRITE  
**Output**: `ext/MetaGraphsNextIO.jl` computes supplied-instance custom edge payloads before child-node insertion on both single-parent and multi-parent paths, so failed custom-edge construction leaves the caller-owned supplied graph unchanged while preserving the landed Branch-A success contract.  
**Depends on**: none  
**Positive contract**: Refactor the supplied-instance edge owner in `ext/MetaGraphsNextIO.jl` so edge payload construction is a pre-mutation step. Keep the existing built-in `EdgeData` special cases and Branch-A constructor semantics, but move the payload-construction decision into extension-private helper methods that can run before `add_node_to_metagraph!` mutates the caller-owned graph. On the single-parent path, materialize the exact edge payload first, then add the node, then insert the edge with the precomputed payload. On the multi-parent path, materialize the complete ordered payload collection for every incoming edge first, then add the node, then insert the edges. Preserve current node-data behavior, preserve the same user-owned constructor failure surface, preserve `validate_empty_metagraph`, preserve `Symbol` labels, and preserve caller-owned graph identity.  
**Negative contract**: Do not solve this by wrapper-layer catch-and-clear behavior. Do not replace the caller-owned graph. Do not add Branch B validation, a new extension protocol, or constructor-error rewriting. Do not touch the library-created `MetaGraph` path, `validate_extension_load_target`, `default_metagraph()`, `emit_basenode(...)`, `ext/MetaGraphsNextAbstractTreesIO.jl`, README, package docs, or example files. Do not broaden this task into general transactional rollback for unrelated `add_edge!` failures.  
**Files**: `ext/MetaGraphsNextIO.jl`  
**Out of scope**: `README.md`, `docs/src/index.md`, `ext/MetaGraphsNextAbstractTreesIO.jl`, `test/*`, library-created `MetaGraph` target validation, public naming or classification decisions, and dependency declarations  
**Verification**: Re-run the direct missing-custom-edge repro on the same supplied graph object and confirm that the first failure still surfaces at the user-owned constructor entrypoint while leaving `nv == 0` and `ne == 0`, and that retrying the same object reproduces the same constructor failure rather than the empty-instance validation error. Re-run an existing supported Branch-A custom-edge success path and confirm it still succeeds. Then run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. The old implementation fails this verification because the first failed load dirties the supplied graph and the second load fails for a different reason.

### 2. Add owner-level failure-atomicity regressions for supplied-instance custom edge failures

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_supplied_basenode.jl` and `test/extensions/metagraphsnext_canonical_owner.jl` directly prove that failed supplied-instance custom-edge construction leaves caller-owned graphs unchanged and retryable on both owner-entry surfaces, including a multi-parent failure path.  
**Depends on**: 1  
**Positive contract**: Extend `test/extensions/metagraphsnext_supplied_basenode.jl` with a same-target missing-custom-edge regression that inspects `nv` and `ne` after failure and retries the same supplied graph object. Extend `test/extensions/metagraphsnext_canonical_owner.jl` with the same failure-atomicity proof on direct `LineagesIO.canonical_load(...)`. In at least one of those owner-level files, add a second negative regression that uses a test-local custom `EdgeData` type whose constructor throws only on a later rooted-network edge so the multi-parent supplied-instance path is exercised after earlier edges would otherwise have succeeded. In all cases, assert that the supplied target remains unchanged and the retry on the same object preserves the original failure class. Preserve the existing Branch-A positive custom metadata proofs and built-in supplied-instance shape proofs already present in those files.  
**Negative contract**: Do not replace the owner-level proof with wrapper-only parity tests. Do not weaken or remove the current Branch-A success tests, built-in supplied-instance shape tests, or authoritative-table assertions. Do not assert only on error text without checking graph state and same-target retry behavior. Do not create a new shared test harness or reorder `test/runtests.jl` for this narrow remediation.  
**Files**: `test/extensions/metagraphsnext_supplied_basenode.jl`; `test/extensions/metagraphsnext_canonical_owner.jl`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, `test/extensions/metagraphsnext_public_surface.jl`, `README.md`, `docs/src/index.md`, `test/runtests.jl`, library-created `MetaGraph` tests, and public docs synchronization  
**Verification**: Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. Confirm that the new owner-level regressions would have failed the old implementation because the same supplied graph object previously ended the first failure at `nv == 2`, `ne == 0`, and because retrying that same object previously changed the failure to the empty-instance validation error.

### 3. Add `read_lineages` and retained `load` parity proofs for caller-owned graph integrity on failure

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_public_surface.jl` proves that both supported public surfaces touched by this owner semantic leave caller-owned supplied graphs unchanged and retryable after failed custom-edge construction.  
**Depends on**: 1, 2  
**Positive contract**: Extend `test/extensions/metagraphsnext_public_surface.jl` with explicit failure-atomicity parity coverage for supplied-instance custom-edge failure. Use one caller-owned supplied graph for `read_lineages(...)` and a separate caller-owned supplied graph for retained `load(...)`, and in each case reuse that same graph object for the retry assertion. After each first failure, assert `nv == 0` and `ne == 0`, then retry and assert the same user-owned constructor failure still surfaces instead of the empty-instance validation error. Keep the current positive Branch-A custom metadata parity test intact so public-surface success parity remains explicit alongside failure parity.  
**Negative contract**: Do not substitute canonical-owner-only coverage for public-surface parity. Do not prove only one of the two public surfaces. Do not inspect only error text while skipping post-failure graph state or same-target retry. Do not edit README or package docs in this task.  
**Files**: `test/extensions/metagraphsnext_public_surface.jl`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, `README.md`, `docs/src/index.md`, `test/extensions/metagraphsnext_supplied_basenode.jl`, `test/extensions/metagraphsnext_canonical_owner.jl`, library-created `MetaGraph` tests, and Tranche 5 docs work  
**Verification**: Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. Confirm that the new public-surface regressions would have failed the old implementation because each surface previously dirtied its own supplied target after the first failure and because retrying that same target previously changed the failure class.
