---
date-created: 2026-05-08T03:02:55-07:00
status: proposed
---

# Tasks for Tranche 4: library-created MetaGraphsNext target tightening

Tasking identifier: `20260508T030255--tranche-4-tasking`

Parent tranche: Tranche 4
Parent PRD: `01_prd.md`

## Settled user decisions and environment baseline

- This tasking is for Tranche 4 only in `.workflow-docs/202605070011--type-stable-parse--audit-fix/02_tranches.md`.
- `read_lineages` remains the ratified first-class package-owned public surface.
- `BuilderDescriptor` remains the ratified first-class typed builder surface.
- `FileIO.load(...)` remains a `compatibility wrapper`.
- `load_alife_table(...)` remains the in-memory Tables.jl `convenience wrapper`.
- The Tranche 3 Branch-A supplied-instance contract in `.workflow-docs/202605070011--type-stable-parse--audit-fix/00-03_supplied-instance-contract-decision.md` is fixed input. Library-created rejection may direct callers to the supplied-instance path, but Tranche 4 must not reopen that contract, mix in Branch B validation, or modify the supplied-instance owner.
- Tranche 4 remains blocked on Tranche 3 as an implementation-state precondition, not just as a reviewed decision artifact. Before Tranche 4 implementation proceeds, the supplied-instance runtime/tests that make the redirect honest must already be green in the current repository state.
- The ratified library-created public token `read_lineages(source, MetaGraph)` remains fixed input and must stay supported for single-parent sources.
- The exact concrete library-created request that may stay supported is the real owner-derived `typeof(default_metagraph())`. No broader accepted family and no hand-written partial `MetaGraph` type literal is authorized.
- Unsupported concrete library-created `MetaGraph` requests must fail before construction with a precise `ArgumentError` that names the supplied type and directs callers to the caller-supplied `MetaGraph` path.
- The library-created multi-parent rejection remains fixed input: `read_lineages(source, MetaGraph)` and retained `load(source, MetaGraph)` must continue to reject multi-parent sources on the library-created path after Tranche 4 lands.
- Tranche 5 still owns `README.md` and `docs/src/index.md` synchronization and must not be pulled forward here.
- Use the installed upstream `MetaGraphsNext` sources named below. The older upstream checkout path referenced by the parent architecture PRD is not present in the current environment, and no `codebases-and-documentation` workspace was found.
- Use the existing root, `test/Project.toml`, and `docs/Project.toml` environments. Do not add dependencies or edit dependency declarations directly.
- Live revalidation on 2026-05-08 confirms the motivating red state is still live while the repository is otherwise green:
  - `git status --short` was empty
  - `julia --project=test test/runtests.jl` passed with `1336` tests in `1m24.2s`
  - `julia --project=docs docs/make.jl` passed
  - the direct tree-path red-state repro on `test/fixtures/single_rooted_tree.nwk` is still live on both supported public surfaces:
    - `LineagesIO.read_lineages(tree_path, typeof(weighted_metagraph_target()))` succeeds but returns `MetaGraph{Int64, Graphs.SimpleGraphs.SimpleDiGraph{Int64}, Symbol, Nothing, Union{Nothing, Float64}, Nothing, MetaGraphsNextIO.var"#default_metagraph##0#default_metagraph##1", Float64}` instead of the requested `MetaGraph{Int64, Graphs.SimpleGraphs.SimpleDiGraph{Int64}, Symbol, Nothing, Float64, Nothing, typeof(identity), Float64}`
    - `FileIO.load(tree_path, typeof(weighted_metagraph_target()))` shows the same mismatch
  - the owner-derived exact-concrete request still succeeds today:
    - `LineagesIO.read_lineages(tree_path, typeof(extension.default_metagraph()))` returns a graph whose concrete type exactly equals the request
    - `FileIO.load(tree_path, typeof(extension.default_metagraph()))` does the same
  - `ext/MetaGraphsNextIO.jl` still contains a no-op `validate_extension_load_target(::Type{<:MetaGraph})` while `emit_basenode(...)` still unconditionally constructs `default_metagraph()`

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
- this tasking file

The bundled style baseline under `/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/` was also checked during tasking. The bundled style files are byte-identical to the repo-local style files above except for `STYLE-vocabulary.md`, where the repo-local file is the higher-priority project authority. Bundled `CONTRIBUTING.md` was not present there, so repo-local `CONTRIBUTING.md` remains controlling.

`STYLE-makie.md` is not an active authority for this tranche because no Makie,
rendering, or figure work is in scope. `STYLE-python.md` was not present in the
repo-local or bundled governance set.

Workflow authorities used to produce this tasking were `development-policies`
and `devflow-architecture-03--tranche-to-tasks`. Downstream execution must
preserve their pass-forward mandates, especially active-authority restatement,
exact scope control, exact lock-item proof obligations, required upstream-source
naming, failure-oriented verification, and honest stop conditions.

Mandatory upstream primary sources for this tranche are:

- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
- `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`

These sources constrain the tranche as follows:

- `MetaGraphsNext.MetaGraph(...)` empty-graph construction is explicit and positional. There is no zero-argument library factory for arbitrary concrete `MetaGraph` requests.
- `MetaGraphsNext.Graphs.add_vertex!` and `MetaGraphsNext.Graphs.add_edge!` operate on an already-constructed `MetaGraph`; they do not create a fresh graph of an arbitrary requested concrete type.
- `MetaGraphsNext.default_weight(graph)` and `MetaGraphsNext.Graphs.weights(graph)` confirm the weight-bearing behavior owned by the concrete `default_metagraph()` graph that the extension already constructs today.

Local inference from those verified facts:

- The honest Tranche 4 repair is to derive the accepted library-created request family from `default_metagraph()` itself and reject every other concrete request at the validation boundary.
- A new factory protocol, trait, or post-hoc cast would be an anti-fix here because the real owner already hard-codes one concrete construction path.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use
`package-owned public surface`, `compatibility wrapper`,
`convenience wrapper`, `authoritative tables`,
`materialized graph or basenode result`, `ownership boundary`, `lock item`,
`red-state repro`, `verification artifact`, `read_lineages`, and
`BuilderDescriptor` consistently. Do not describe `FileIO.load(...)` as a
first-class public surface, and do not describe this tranche as a factory
redesign.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, rebase, reset, and branch creation remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Primary-goal lock

### Lock 4a: the ratified `MetaGraph` library-created token must remain honest and supported

- The work is not complete if `read_lineages(source, MetaGraph)` or retained
  `load(source, MetaGraph)` stops being a supported single-parent
  library-created request, or if either surface stops returning the
  `default_metagraph()` concrete graph for that token.
- Direct bad shape to guard against: tightening the accepted family by
  accidentally rejecting the ratified `MetaGraph` token, or by changing the
  returned graph semantics rather than making the existing owner honest.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: direct tree-load positive regressions on both `read_lineages(...)`
  and retained `load(...)` for the `MetaGraph` token that assert
  `typeof(asset.graph) === typeof(default_metagraph())`, plus the existing
  multi-parent rejection regressions that keep the library-created network
  rejection intact.

### Lock 4b: the owner-derived exact concrete library-created request must stay exact

- The work is not complete if `read_lineages(source, typeof(default_metagraph()))`
  or retained `load(source, typeof(default_metagraph()))` stops returning a
  graph whose concrete type exactly equals the request, or if the accepted
  family is expressed as a hand-written partial `MetaGraph` literal instead of
  being derived from the real owner.
- Direct historical bad behavior: the current broad validator accepts
  unsupported concrete `MetaGraph` requests, which proves the accepted family
  is not presently owned by `default_metagraph()` even though the owner-derived
  exact concrete request still happens to work.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: owner-level and public-surface regressions that explicitly request
  `typeof(default_metagraph())` and assert `typeof(asset.graph) === requested_type`,
  plus manual inspection that the acceptance helper derives from
  `default_metagraph()` rather than from a hand-written type literal.

### Lock 4c: unsupported concrete library-created requests must reject before construction

- The work is not complete if an unsupported concrete `MetaGraph` request can
  still pass validation and return a different concrete graph type, or if the
  rejection surface is still delayed past the validation boundary.
- Direct red-state repro:
  `read_lineages(tree_path, typeof(weighted_metagraph_target()))` and retained
  `load(tree_path, typeof(weighted_metagraph_target()))` currently succeed even
  though the returned graph type is the `default_metagraph()` type rather than
  the requested weighted concrete type.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix
  shape: direct negative regressions on both public surfaces and on the
  canonical owner path that assert the weighted concrete request throws a
  precise `ArgumentError` before construction and directs callers to the
  caller-supplied `MetaGraph` path. The current implementation fails because
  the weighted concrete request still succeeds.

### Lock 4d: both supported public surfaces touched by this semantic must move together

- The work is not complete if `read_lineages(source, NodeT)` and retained
  `load(source, NodeT)` disagree about the supported library-created request
  family, the returned concrete type for accepted requests, or the rejection
  surface for unsupported requests.
- Direct bad shape to guard against: fixing only the package-owned public
  surface or only the retained wrapper while leaving the sibling surface free
  to drift.
- Closing tasks: 2 and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: explicit parity regressions in
  `test/extensions/metagraphsnext_public_surface.jl` that cover both accepted
  and rejected library-created request shapes across `read_lineages(...)` and
  retained `load(...)`.

### Lock 4e: the repair must stay inside the authorized owner boundary

- The work is not complete if Tranche 4 introduces a new factory protocol,
  edits the supplied-instance custom-data path, rewrites README or package docs
  synchronization that belongs to Tranche 5, or otherwise widens this repair
  beyond the library-created validation and construction owner.
- Direct bad shape to guard against: solving the mismatch by building a second
  implementation, by reopening the Tranche 3 supplied-instance contract, or by
  broadening public naming and documentation decisions that are already fixed.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the bad implementation or fake-fix
  shape: touched-file scope remains limited to `ext/MetaGraphsNextIO.jl`,
  `test/extensions/metagraphsnext_canonical_owner.jl`, and
  `test/extensions/metagraphsnext_public_surface.jl`; `README.md`,
  `docs/src/index.md`, `ext/MetaGraphsNextAbstractTreesIO.jl`, supplied-instance
  owner paths, and dependency declarations remain untouched.

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
  - the parent type-stable parse PRD and tranche file
  - the tranche-3 public-surface decision record
  - the production final audit
  - the audit-fix design note
  - the supplied-instance contract decision record
  - the remedial PRD
  - this tasking file
- Settled decisions and non-negotiables:
  - `read_lineages` remains the first-class package-owned public surface
  - `BuilderDescriptor` remains the first-class typed builder surface
  - `FileIO.load(...)` remains a `compatibility wrapper`
  - `load_alife_table(...)` remains a `convenience wrapper`
  - the Tranche 3 Branch-A supplied-instance contract remains fixed input
  - Tranche 3 runtime/tests must already be green before Tranche 4 execution
    proceeds, because any redirect to the caller-supplied path is only honest
    after that repaired path is live in the current repository state
  - `read_lineages(source, MetaGraph)` remains a supported library-created token
  - the only exact concrete library-created request that may stay supported is
    the owner-derived `typeof(default_metagraph())`
  - no new factory protocol, public naming change, or docs synchronization
    widening is authorized here
- Authorization boundary:
  - only the library-created MetaGraphsNext target validator and accepted-family
    owner in `ext/MetaGraphsNextIO.jl`, directly affected canonical-owner and
    public-surface tests, and any narrow rejection wording required for that
    owner are in scope
- Current-state diagnosis:
  - `validate_extension_load_target(::Type{<:MetaGraph})` currently accepts
    every concrete `MetaGraph` request
  - `emit_basenode(...)` always constructs `default_metagraph()`
  - the accepted-family owner is therefore dishonest today because unsupported
    weighted concrete requests survive validation and return the wrong graph
    type
- Primary-goal lock:
  - close Lock 2 from the PRD by making the supported library-created request
    family exact and owner-derived, while keeping Tranche 3 and Tranche 5
    boundaries intact
- Direct red-state repros:
  - `read_lineages(tree_path, typeof(weighted_metagraph_target()))` currently
    returns the wrong concrete graph type
  - retained `load(tree_path, typeof(weighted_metagraph_target()))` currently
    does the same
- Owner and invariant under repair:
  - the library-created MetaGraphsNext request validator must normalize the
    accepted request family exactly once from the real `default_metagraph()`
    owner, and the construction path must never pretend to support a concrete
    request it does not actually build
- Supported public surfaces affected by that owner or semantic:
  - `read_lineages(source, MetaGraph)`
  - `read_lineages(source, typeof(default_metagraph()))`
  - retained `load(source, MetaGraph)`
  - retained `load(source, typeof(default_metagraph()))`
  - rejected concrete requests shaped like `typeof(weighted_metagraph_target())`
    on both public surfaces
- Exact files or surfaces in scope:
  - `ext/MetaGraphsNextIO.jl`
  - `test/extensions/metagraphsnext_canonical_owner.jl`
  - `test/extensions/metagraphsnext_public_surface.jl`
  - direct canonical-owner verification through
    `LineagesIO.canonical_load(...)`
- Exact files or surfaces out of scope:
  - `README.md`
  - `docs/src/index.md`
  - `ext/MetaGraphsNextAbstractTreesIO.jl`
  - supplied-instance custom-data owner logic
  - `test/extensions/metagraphsnext_supplied_basenode.jl`
  - dependency declarations
  - broader public naming or wrapper-classification decisions
- Required upstream primary sources:
  - `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/metagraph.jl`
  - `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/graphs.jl`
  - `/home/jeetsukumaran/.julia/packages/MetaGraphsNext/0QPgf/src/weights.jl`
- Green-state gates:
  - the current Tranche 3 supplied-instance runtime/tests remain green before
    Tranche 4 execution starts
  - direct positive regressions for `MetaGraph` and
    `typeof(default_metagraph())`
  - direct negative regressions for the weighted concrete request
  - owner-level proof through `canonical_load(...)`
  - retained wrapper parity proof through `load(...)`
  - existing multi-parent `MetaGraph` network rejection remains green
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
- Stop conditions:
  - stop and escalate if the Tranche 3 supplied-instance runtime/tests are not
    green in the current repository state, because redirecting rejected
    library-created requests there would no longer be honest
  - stop and escalate if making the accepted-family repair honest would require
    rejecting the ratified `MetaGraph` token
  - stop and escalate if a broader external compatibility or migration question
    appears around parameterized `MetaGraph` requests that cannot be resolved
    from the active sources alone
  - stop and escalate if the repair appears to require a new factory protocol,
    supplied-instance contract changes, or Tranche 5 docs synchronization

## Required revalidation before implementation

- Read the tranche and parent PRD in full.
- Read the relevant code, tests, docs, and examples in full:
  - `README.md`
  - `ext/MetaGraphsNextIO.jl`
  - `src/read_lineages.jl`
  - `src/load_compat.jl`
  - `src/load_owner.jl`
  - `test/extensions/metagraphsnext_activation.jl`
  - `test/extensions/metagraphsnext_canonical_owner.jl`
  - `test/extensions/metagraphsnext_public_surface.jl`
  - `test/extensions/metagraphsnext_network_rejection.jl`
  - `docs/src/index.md`
- Read the cited upstream primary sources in full where they constrain the work.
- Re-check the user-authorized disruption boundary before making deep changes.
- Reconfirm that the Tranche 3 supplied-instance contract artifacts still
  remain fixed input, that the Tranche 3 supplied-instance runtime/tests are
  still green, and that no later docs-sync tranche has already moved
  `README.md` or `docs/src/index.md`.
- If the diagnosis no longer matches reality, stop and raise that before
  changing code.

## Tranche execution rule

This tranche may redesign the library-created request validator internally, but
it must begin and end in the tranche's required green, policy-compliant state.
External breaking changes remain out of scope unless a stop condition is
triggered.

For this owner-boundary tranche:

- the owner that must remain is the library-created validation and construction
  boundary in `ext/MetaGraphsNextIO.jl`
- the artifact that must no longer survive is broad
  `validate_extension_load_target(::Type{<:MetaGraph})` acceptance for concrete
  requests the owner does not actually build
- the forbidden workaround is a second factory, post-hoc cast, wrapper, or
  reinterpretation that still lets an unsupported request appear accepted
- docs must remain truthful to the current API, but docs synchronization itself
  is not owned here and must not be used as a substitute for runtime repair

## Non-negotiable execution rules

- Do not add a new MetaGraphsNext factory protocol, trait, or callback surface.
- Do not solve the mismatch by post-hoc casting, wrapping, or reinterpreting a
  `default_metagraph()` result.
- Do not reopen the ratified `read_lineages(source, MetaGraph)` token or the
  first-class versus `compatibility wrapper` naming decisions.
- Do not reopen the Tranche 3 supplied-instance custom-data contract or modify
  supplied-instance owner code in this tranche.
- Do not edit `README.md` or `docs/src/index.md` in this tranche.
- Do not encode the supported exact concrete request as a hand-written partial
  `MetaGraph` type literal.
- Do not touch `ext/MetaGraphsNextAbstractTreesIO.jl`.
- Do not weaken proof to `asset.graph isa MetaGraph` when exact
  `typeof(asset.graph) === requested_type` proof is available.

## Concrete anti-patterns or removal targets

- broad `validate_extension_load_target(::Type{<:MetaGraph})` acceptance for
  every concrete `MetaGraph` request
- silent mismatch between an accepted weighted concrete request and the actual
  `default_metagraph()` return type
- any helper that spells the supported request family via a hand-written
  parameter tuple instead of deriving it from `default_metagraph()`
- any second implementation that tries to fabricate unsupported concrete graph
  types on the library-created path
- any partial migration where `read_lineages(...)` tightens the accepted family
  but retained `load(...)` still accepts the old broad request

## Failure-oriented verification

- The direct weighted concrete red-state repro must fail the old
  implementation on both supported public surfaces:
  `read_lineages(tree_path, typeof(weighted_metagraph_target()))` and retained
  `load(tree_path, typeof(weighted_metagraph_target()))` currently succeed and
  return the wrong concrete graph type.
- Positive verification must include the ratified `MetaGraph` token on a
  single-parent tree fixture so a fake fix cannot pass by breaking the
  first-class supported token while narrowing the accepted family.
- Positive verification for the `MetaGraph` token must assert
  `typeof(asset.graph) === typeof(default_metagraph())` on both supported
  public surfaces and on the canonical-owner proof, not just parity between
  sibling surfaces.
- Positive verification must include the owner-derived exact concrete request
  `typeof(default_metagraph())` and must assert exact type equality rather than
  `isa` or subtype-only checks.
- Owner-level verification must include at least one direct
  `LineagesIO.canonical_load(...)` proof so this tranche cannot hide behind
  wrapper-only coverage.
- Public-surface verification must include both `read_lineages(...)` and
  retained `load(...)` because the same semantic is exposed through both
  supported surfaces.
- Existing multi-parent rejection for the `MetaGraph` token must stay green so
  tightening the accepted family does not accidentally weaken the honest
  library-created network rejection.
- `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`
  remain mandatory tranche-end gates.
- README and package docs text are not verification artifacts for this tranche,
  because public contract synchronization remains assigned to Tranche 5.

## Tasks

### 1. Tighten the owner-derived accepted family in `MetaGraphsNextIO`

**Type**: WRITE  
**Output**: `ext/MetaGraphsNextIO.jl` derives the supported library-created request family from `default_metagraph()` and rejects every other concrete `MetaGraph` request before construction.  
**Depends on**: none  
**Positive contract**: Implement the library-created owner repair in `ext/MetaGraphsNextIO.jl`. Add an extension-private helper that derives the exact owner-produced concrete type from `default_metagraph()`, and use that helper to keep only two supported library-created request forms: the ratified `MetaGraph` token and the exact owner-derived `typeof(default_metagraph())`. Keep `emit_basenode(...)` constructing `default_metagraph()`; the honest repair belongs at the validation boundary, not in a second factory. Tighten `validate_extension_load_target(::Type{<:MetaGraph})` so any other concrete or hand-written partial `MetaGraph` request throws a precise `ArgumentError` naming the supplied type and directing callers to the caller-supplied `MetaGraph` path. Preserve the existing graph-asset validation that rejects multi-parent sources for the library-created path after the request family is known to be supported.  
**Negative contract**: Do not add a new protocol function, trait, or build callback. Do not hand-write the accepted concrete type as a literal parameter tuple. Do not post-hoc cast or wrap the returned graph to pretend the request matched. Do not reopen the Tranche 3 supplied-instance contract, do not edit README or package docs, and do not touch `ext/MetaGraphsNextAbstractTreesIO.jl`.  
**Files**: `ext/MetaGraphsNextIO.jl`  
**Out of scope**: `src/read_lineages.jl`, `src/load_compat.jl`, `README.md`, `docs/src/index.md`, `ext/MetaGraphsNextAbstractTreesIO.jl`, supplied-instance custom-data helpers, and dependency declarations  
**Verification**: Re-run the direct tree-path repros from `test/fixtures/single_rooted_tree.nwk`. Confirm `read_lineages(tree_path, MetaGraph)` returns a graph whose concrete type is exactly `typeof(extension.default_metagraph())`, `read_lineages(tree_path, typeof(extension.default_metagraph()))` returns a graph whose concrete type exactly equals the request, and `read_lineages(tree_path, typeof(weighted_metagraph_target()))` now throws precise `ArgumentError` before construction. Re-run the same three shapes through retained `load(...)`. The old implementation fails this verification because the weighted concrete request still succeeds and returns the wrong concrete type.

### 2. Add canonical-owner regressions for the supported and rejected library-created request family

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_canonical_owner.jl` directly proves the canonical owner accepts only the supported library-created family and rejects the weighted concrete request before construction.  
**Depends on**: 1  
**Positive contract**: Extend `test/extensions/metagraphsnext_canonical_owner.jl` with direct `LineagesIO.canonical_load(...)` coverage for the exact owner-derived concrete request and keep the existing `MetaGraph` token proof explicit. Add an exact token-path assertion that the `MetaGraph` request returns `typeof(default_metagraph())`, and an exact concrete-request assertion that `typeof(asset.graph) === requested_type` for `typeof(default_metagraph())`. Use `Base.get_extension(LineagesIO, :MetaGraphsNextIO).default_metagraph()` in the test helper path so the accepted family stays owner-derived instead of being restated as a hand-written type literal. Add a direct negative canonical-owner regression that proves the weighted concrete request now fails with a precise `ArgumentError` before construction. Keep the authoritative-table snapshot, basenode, graph-contract, and existing built-in-shape assertions intact.  
**Negative contract**: Do not weaken proof to `asset.graph isa MetaGraph`. Do not move public-surface parity proof into this task. Do not remove the existing exact-concrete activation coverage elsewhere in the suite to make this tranche pass vacuously. Do not touch `test/extensions/metagraphsnext_public_surface.jl`, supplied-instance tests, README, package docs, or runtime code in this task.  
**Files**: `test/extensions/metagraphsnext_canonical_owner.jl`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, `test/extensions/metagraphsnext_public_surface.jl`, `test/extensions/metagraphsnext_supplied_basenode.jl`, `test/extensions/metagraphsnext_activation.jl`, `README.md`, `docs/src/index.md`, and `test/runtests.jl`  
**Verification**: Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. Confirm the new owner-level regressions would have failed the old implementation because the weighted concrete request previously survived validation and because no direct canonical-owner rejection proof previously existed for that bad shape.

### 3. Add `read_lineages` and retained `load` parity proofs for accepted and rejected library-created requests

**Type**: TEST  
**Output**: `test/extensions/metagraphsnext_public_surface.jl` proves that both supported public surfaces stay aligned for the `MetaGraph` token, the owner-derived exact concrete request, and the rejected weighted concrete request.  
**Depends on**: 1, 2  
**Positive contract**: Extend `test/extensions/metagraphsnext_public_surface.jl` with single-parent tree parity tests that cover the ratified `MetaGraph` token and the exact owner-derived concrete request. For the `MetaGraph` token, add an explicit assertion on both `read_lineages(...)` and retained `load(...)` that the returned graph type is exactly `typeof(default_metagraph())`, not just a parity match. For the exact concrete request, assert `typeof(asset.graph) === requested_type` on both `read_lineages(...)` and retained `load(...)`, and keep authoritative-table, basenode, and graph-contract parity checks. Add a negative parity regression that `typeof(weighted_metagraph_target())` now fails on both surfaces with precise `ArgumentError` that names the supplied type and directs the caller to the caller-supplied `MetaGraph` path. Keep the existing network rejection and supplied-instance tests untouched; the full suite continues to cover those unaffected surfaces.  
**Negative contract**: Do not prove only `read_lineages(...)` or only retained `load(...)`. Do not settle for `isa MetaGraph`, `typeof(actual) != typeof(legacy)`, or other weak proxy checks. Do not rewrite docs or example text in place of runtime enforcement. Do not broaden this task into supplied-instance contract work or factory design.  
**Files**: `test/extensions/metagraphsnext_public_surface.jl`  
**Out of scope**: `ext/MetaGraphsNextIO.jl`, `test/extensions/metagraphsnext_canonical_owner.jl`, `test/extensions/metagraphsnext_activation.jl`, `test/extensions/metagraphsnext_network_rejection.jl`, `README.md`, and `docs/src/index.md`  
**Verification**: Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. Confirm the new parity regressions would have failed the old implementation because both public surfaces previously accepted the weighted concrete request and silently returned the default `Union{Nothing, Float64}` graph instead of the requested type.
