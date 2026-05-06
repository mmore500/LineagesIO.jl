---
date-created: 2026-05-05T20:22:07-07:00
date-revised: 2026-05-05T20:22:07-07:00
status: proposed
---

# Tasks for Tranche 2: compatibility and extension migration onto the canonical owner

Tasking identifier: `20260505T2022--tranche-2-tasking`

Parent tranche: Tranche 2
Parent PRD: `01_prd.md`

## Settled user decisions and environment baseline

- Treat `FileIO.load(...)` as a compatibility wrapper, not as the canonical package-owned owner of LineagesIO load semantics.
- Preserve authoritative table construction as the canonical parse output. Do not collapse the design into direct parser-to-graph construction.
- Preserve retained node and edge annotation semantics in both authoritative tables and materialized callbacks.
- Preserve container-agnostic and target-agnostic materialization semantics. Do not hard-code one graph or basenode representation as the only valid target.
- Preserve stable asset destructuring order `(graph, basenode, node_table, edge_table)`.
- No repo-owned public API removal, rename, export change, or signature break is authorized in this tranche.
- No final exported package-owned load verb may be chosen in this tranche.
- No final exported builder-surface spelling may be chosen in this tranche.
- Public-surface ratification, wrapper-first versus first-class docs repositioning, deprecations, and compatibility-policy decisions remain blocked to Tranche 3 and Tranche 4.
- Use the existing root `Manifest.toml`, `test/Project.toml`, and `docs/Project.toml` environments.
- Do not add dependencies or edit dependency declarations directly without user review.
- Use the approved upstream workspace at `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/` for `FileIO`, `Tables`, `MetaGraphsNext.jl`, and `PhyloNetworks.jl` primary-source reading.
- Tranche 1 and the Tranche 1 remediation slice are already landed in current code reality. `src/load_owner.jl`, `src/load_compat.jl`, `src/fileio_integration.jl`, and `src/alife_format.jl` already route the tables-only, node-type, supplied-basenode, and builder compatibility surfaces through the canonical owner or explicit compatibility layer. Do not task that already-landed migration again as if it were still red.

## Governance

Explicit line-by-line reading is mandatory before implementation. All downstream work must read and conform to:

- `AGENTS.md`
- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-makie.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `.workflow-docs/202605040131_type-stable-parse/01_prd.md`
- `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-1--tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/04_tranche-1--remediation-tasking.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-2--tasking.md`

The bundled style baseline under `/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/` was also read for this tasking run and is byte-identical to the repo-local `STYLE*.md` files above. Bundled `CONTRIBUTING.md` was not present there, so the repo-local `CONTRIBUTING.md` remains authoritative for contribution guidance.

Workflow authorities used to produce this tasking were `development-policies` and `devflow-architecture-03--tranche-to-tasks`. Downstream implementation must preserve their pass-forward mandates, especially active-authority restatement, upstream-source naming, vocabulary control, exact authorization boundaries, direct red-state repros, and failure-oriented verification.

Upstream primary sources that must be read line by line for this tranche are:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/src/Tables.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/metagraph.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/graphs.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/weights.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/auxiliary.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/readwrite.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/manipulateNet.jl`

These sources constrain the work as follows:

- `FileIO` owns format detection, ambiguity handling, `File{fmt}` wrappers, `Stream{fmt}` wrappers, and formatted dispatch.
- `Tables` owns the `Tables.AbstractColumns` and `Tables.AbstractRow` contracts, including `Tables.schema`, `Tables.columnnames`, `Tables.getcolumn`, and the optional typed `getcolumn(table, ::Type{T}, i, nm)` entrypoint.
- `MetaGraphsNext.jl` owns the empty-graph constructor contract, `MetaGraph` label and metadata invariants, `add_vertex!`, `add_edge!`, `code_for`, `label_for`, `weights`, and default-weight behavior.
- `PhyloNetworks.jl` owns the `HybridNetwork`, `Node`, and `Edge` data structures, mutation helpers such as `pushNode!`, `pushEdge!`, `setNode!`, and `setEdge!`, and post-build validity operations such as `storeHybrids!`, `checkNumHybEdges!`, `directedges!`, `readnewick`, `writenewick`, and `addChild!`.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use `basenode`, `compatibility wrapper`, `package-owned public surface`, `authoritative tables`, `materialized graph or basenode result`, `source descriptor`, `materialization descriptor`, `parent collection`, `ownership boundary`, `green state`, `lock item`, and `verification artifact` consistently. Do not use `type stable` as shorthand for universal exact inference when the real contract is absence of package-owned erasure and runtime recovery in owned paths.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, rebase, reset, and branch creation remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Primary-goal lock

### Lock 1: compatibility wrappers remain thin delegators

- The work is not complete if `FileIO.load(...)` or `load_alife_table(...)` regrow an independent request-normalization owner or an extension-specific semantic path instead of delegating into the canonical package-owned owner or the explicit compatibility layer.
- Direct red-state repro: the pre-tranche architecture split semantics across `fileio_load(...)`, `load_alife_table(...)`, and construction internals. Current code has already repaired much of this. A fake fix would silently move semantic rules back into wrapper code while leaving the canonical owner nominally present.
- Closing tasks: 2 and 4.
- Verification artifact that must fail the bad implementation or fake-fix shape: direct canonical-owner versus wrapper parity tests across file/path, stream, and in-memory table surfaces, plus extension-specific direct-owner parity tests, so wrappers are not the only subject of verification.

### Lock 2: the PhyloNetworks extension must stop owning parent-collection typing

- The work is not complete if the `HybridNetwork` node-type path still selects the extension-side `build_parent_collection` override in `ext/PhyloNetworksIO.jl` or still performs `Any[]`/`reduce(typejoin, ...)` parent-handle recovery instead of using the typed core owner.
- Direct red-state repro: current dispatch revalidation shows `LineagesIO.build_parent_collection(::NodeTypeLoadRequest{HybridNetwork}, ::Vector{PhyloNetworksBuildCursor{...}})` still resolves to `ext/PhyloNetworksIO.jl`, not to the generic typed-core owner in `src/construction.jl`.
- Closing tasks: 1 and 2.
- Verification artifact that must fail the bad implementation or fake-fix shape: a dispatch regression proving the sampled node-type parent-collection path resolves to the core method in `src/construction.jl`, not the extension override; current code fails this proof.

### Lock 3: the MetaGraphsNext extension must not retain dead pre-remediation shims

- The work is not complete if the extension still keeps the graph-vector multi-parent probe shim or stale probe-era comments as a second owner story after the canonical sampled-handle path already dispatches directly to the cursor overload.
- Direct red-state repro: current dispatch revalidation shows the supplied-instance sampled parent collection already calls the `MetaGraphsNextBuildCursor` multi-parent overload directly, so the `add_child(::AbstractVector{<:MetaGraph}, ...)` shim is now dead compatibility scaffolding.
- Closing tasks: 3 and 4.
- Verification artifact that must fail the bad implementation or fake-fix shape: a method-table or dispatch regression that proves the sampled parent collection dispatches directly to the cursor overload and that no graph-vector shim survives as a second path; current code fails the "no shim survives" proof.

### Lock 4: extension migration must preserve real user-facing behaviors

- The work is not complete if the extension cleanup breaks rooted-network validation, retained annotation behavior, authoritative table retention, synthesized leaf-name handling, `MetaGraphsNext` weight and metadata semantics, or extension-owned traversal and downstream mutation behavior.
- Direct red-state repro: a fake cleanup could remove shadow owner code but quietly break `HybridNetwork` gamma or branch behavior, `MetaGraph` edge-data behavior, or post-load workflow while a narrower suite still passes.
- Closing tasks: 2 and 4.
- Verification artifact that must fail the bad implementation or fake-fix shape: direct canonical-owner versus wrapper parity tests plus the existing extension and integration checks for `HybridNetwork`, `MetaGraph`, `MetaGraphsNextTreeView`, authoritative `node_table` and `edge_table` retention, and downstream mutation or round-trip behavior.

### Lock 5: tranche 2 must not silently ratify the public-surface decision

- The work is not complete if tranche 2 chooses public naming, deprecations, wrapper-first versus first-class docs policy, or any repo-owned API breakage that the PRD reserved for user review in Tranche 3.
- Direct red-state repro: the parent tranche text includes a docs-related warning that is now broader than the higher-authority PRD. A fake fix would use tranche 2 cleanup as an excuse to reposition README or docs as if the public-surface decision were already ratified.
- Closing tasks: 1, 3, and 4.
- Verification artifact that must fail the bad implementation or fake-fix shape: review of touched repo-owned public files confirms no new export, no public rename, and no README or docs contract rewrite beyond narrow truth fixes required to keep the docs build honest.

## Handoff packet

- Active authorities:
  `AGENTS.md`, `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, `STYLE-writing.md`, `.workflow-docs/202605040131_type-stable-parse/01_prd.md`, `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`, `.workflow-docs/202605040131_type-stable-parse/03_tranche-1--tasking.md`, `.workflow-docs/202605040131_type-stable-parse/04_tranche-1--remediation-tasking.md`, and this file.
- Parent documents:
  `01_prd.md`, `02_tranches.md`, `03_tranche-1--tasking.md`, `04_tranche-1--remediation-tasking.md`.
- Settled decisions and non-negotiables:
  canonical owner and typed core already landed in tranche 1; `FileIO.load(...)` remains a compatibility wrapper; authoritative tables remain canonical; extension cleanup must not settle public naming or docs policy; no public API breakage is authorized.
- Authorization boundary:
  extension and compatibility-wrapper migration only; no public-surface ratification, no public rename, no export change, no dependency changes, no docs repositioning beyond narrow truth fixes.
- Current-state diagnosis:
  `src/fileio_integration.jl` and `src/alife_format.jl` already delegate into `src/load_compat.jl` and `src/load_owner.jl`; `ext/MetaGraphsNextIO.jl` still contains a dead graph-vector multi-parent probe shim even though current sampled-handle dispatch goes straight to the cursor overload; `ext/PhyloNetworksIO.jl` still actively owns `HybridNetwork` node-type parent-collection recovery via an extension-side `build_parent_collection` override using `Any[]` and `reduce(typejoin, ...)`.
- Primary-goal lock:
  locks 1 through 5 above.
- Direct red-state repros:
  active `which(...)` resolution for `PhyloNetworks` node-type parent collections points at `ext/PhyloNetworksIO.jl`; stale `MetaGraphsNext` graph-vector probe shim remains in code despite dead dispatch; wrapper-first docs still remain for later review-gated tranches.
- Owner and invariant under repair:
  the canonical invariant is that compatibility wrappers and extensions normalize into one package-owned typed owner, then consume authoritative tables, then materialize through the typed core without reintroducing extension-side type recovery or shadow request owners.
- Exact files or surfaces in scope:
  `ext/PhyloNetworksIO.jl`, `ext/MetaGraphsNextIO.jl`, `ext/MetaGraphsNextAbstractTreesIO.jl` only if required by concrete extension cleanup, and the extension/core test files needed to prove canonical-owner parity and anti-regrowth behavior.
- Exact files or surfaces out of scope:
  `src/load_owner.jl`, `src/load_compat.jl`, `src/fileio_integration.jl`, `src/alife_format.jl`, `src/LineagesIO.jl`, `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, examples, export lists, and public naming or deprecation policy unless a narrow truth fix is strictly required to keep the repository honest and green.
- Required upstream primary sources:
  the exact `FileIO`, `Tables`, `MetaGraphsNext.jl`, and `PhyloNetworks.jl` files listed in the Governance section.
- Green-state gates:
  `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`; if examples or example-backed docs are touched, run the relevant example scripts and record them.
- Stop conditions:
  stop if removing the `PhyloNetworks` override unexpectedly requires widening the typed-core contract in `src/construction.jl`; stop if the `MetaGraphsNext` shim turns out to be necessary under current core dispatch, because that would indicate tranche 1 boundary drift; stop if cleanup pressures imply a public-surface ratification, export change, or docs repositioning that belongs to Tranche 3 or Tranche 4; stop if any upstream contract reading shows a local extension assumption is wrong.

## Required revalidation before implementation

- Read the tranche, parent PRD, the Tranche 1 tasking and remediation tasking files, and this tasking file in full.
- Read the current code in `src/load_owner.jl`, `src/load_compat.jl`, `src/fileio_integration.jl`, `src/alife_format.jl`, `src/construction.jl`, `ext/PhyloNetworksIO.jl`, `ext/MetaGraphsNextIO.jl`, `ext/MetaGraphsNextAbstractTreesIO.jl`, and `src/LineagesIO.jl` in full.
- Read the relevant tests in `test/core/canonical_load_owner.jl`, `test/core/fileio_load_surfaces.jl`, `test/core/alife_format.jl`, `test/extensions/metagraphsnext_simple_newick.jl`, `test/extensions/metagraphsnext_supplied_basenode.jl`, `test/extensions/metagraphsnext_abstracttrees.jl`, `test/extensions/metagraphsnext_network_rejection.jl`, `test/extensions/phylonetworks_newick_networks.jl`, `test/extensions/phylonetworks_tree_compatible_newick.jl`, `test/extensions/phylonetworks_tables_after_load.jl`, `test/extensions/phylonetworks_rejection_paths.jl`, `test/integration/phylonetworks_soft_release.jl`, and `test/runtests.jl` in full.
- Read the current public docs in `README.md`, `docs/src/index.md`, and `docs/src/phylonetworks.md` in full so extension cleanup does not accidentally contradict current user-facing text, even though public docs repositioning is not a tranche 2 goal.
- Re-read the upstream `FileIO`, `Tables`, `MetaGraphsNext.jl`, and `PhyloNetworks.jl` primary sources listed above before changing code that depends on those contracts.
- Re-check the PRD authorization boundary before touching any export, docs, or compatibility surface.
- Reproduce or re-check the active `PhyloNetworks` shadow-owner repro against current code before changing it. Confirm that the `HybridNetwork` node-type sampled parent-collection path still resolves to the extension override in `ext/PhyloNetworksIO.jl`.
- Reproduce or re-check the `MetaGraphsNext` shim diagnosis against current code before changing it. Confirm that the sampled supplied-instance multi-parent path already dispatches directly to the cursor overload and that the graph-vector probe shim is dead under current core dispatch.
- If any of those revalidation points no longer hold, stop and revise this tasking before changing code.

## Tranche execution rule

This tranche may remove, demote, or deeply simplify extension-side shadow-owner artifacts and stale compatibility scaffolding, but it must begin and end in a green, policy-compliant state. It must preserve the existing public wrapper surfaces and extension behaviors while making those surfaces thinner and more explicitly downstream of the canonical package-owned owner.

When Tranche 2 is complete:

- `FileIO` path and stream wrappers, `load_alife_table(...)`, and extension materialization paths must remain downstream consumers of the canonical owner rather than parallel semantic owners.
- `PhyloNetworks` and `MetaGraphsNext` extension logic must not reintroduce extension-side `Any` storage, runtime `typejoin` recovery, graph-vector probe shims, or a second request-normalization story.
- docs may be touched only as needed to keep the docs build green or to remove an outright false statement created by implementation detail changes; docs must not be used to ratify the public-surface decision early.

## Non-negotiable execution rules

- Do not move request normalization or extension-specific semantics back into `FileIO` wrappers, `load_alife_table(...)`, or extension code paths.
- Do not reintroduce `Any[]`, `Vector{Any}`, `reduce(typejoin, ...)`, callback-signature recovery, or any renamed equivalent as a convenience inside extension or compatibility paths.
- Do not keep dead probe shims, stale pre-remediation comments, or compatibility-only artifacts as a second implementation once current canonical dispatch makes them unnecessary.
- Do not widen the public extension contract for `MetaGraph`, `HybridNetwork`, or builder surfaces without explicit user review.
- Do not change `README.md`, `docs/src/index.md`, or `docs/src/phylonetworks.md` as if the tranche 3 public-surface decision had already been ratified.
- Do not add new dependencies, edit dependency declarations, or rewrite upstream extension contracts beyond what is required to align with the canonical owner.
- Do not replace direct extension or parity verification with grep checks, docs-string policing, or method-table checks alone. Those may supplement, but not replace, behavior-level verification.

## Concrete anti-patterns or removal targets

- `ext/PhyloNetworksIO.jl` `build_parent_collection(::NodeTypeLoadRequest{HybridNetwork}, ...)` as an active shadow owner for parent-collection typing.
- `ext/PhyloNetworksIO.jl` use of `Any[]` and `reduce(typejoin, ...)` to recover parent collection element types.
- any extension-side logic that keeps `HybridNetwork` node-type loads on a different parent-collection typing path from the canonical typed core.
- `ext/MetaGraphsNextIO.jl` graph-vector multi-parent probe shim and the associated stale comment block that describes a superseded validation path.
- any reintroduced extension-specific request model, validation shim, or wrapper parity shortcut that lets the extension define semantic behavior independently of the canonical owner.
- any test suite shape that proves only wrapper behavior and never exercises direct canonical-owner entry for extension-backed surfaces.

## Failure-oriented verification

- Add a direct dispatch regression that proves the `HybridNetwork` node-type sampled parent-collection path resolves to the core `src/construction.jl` `build_parent_collection` method rather than the extension override. Current code must fail this regression.
- Add a direct regression that proves the `MetaGraphsNext` supplied-instance sampled parent-collection path dispatches to the cursor overload without any graph-vector shim. Also add a direct check that the graph-vector shim method no longer exists after cleanup. Current code must fail the no-shim proof.
- Add direct canonical-owner versus wrapper parity tests for `HybridNetwork` node-type and supplied-target loads on rooted-network and tree-compatible rooted sources. Those tests must compare authoritative tables, basenode projection, rooted-network child structure, gamma and branch semantics, synthesized leaf-name behavior, and relevant downstream operations such as round-trip writing or downstream mutation.
- Add direct canonical-owner versus wrapper parity tests for `MetaGraph` tree loads and supplied-instance multi-parent network loads. Those tests must compare authoritative tables, basenode projection, vertex or edge data behavior, weight behavior, and `MetaGraphsNextTreeView` traversal where applicable.
- Keep the existing `load_alife_table(...)` and FileIO wrapper parity tests active so wrapper surfaces are not the only proof of canonical ownership.
- Run `julia --project=test test/runtests.jl`.
- Run `julia --project=docs docs/make.jl`.
- If any example-backed extension docs or examples are touched, run the relevant example scripts and record them explicitly.

## Tasks

### 1. Remove the active PhyloNetworks shadow parent-collection owner

**Type**: WRITE  
**Output**: `HybridNetwork` node-type and supplied-target materialization no longer rely on an extension-side `build_parent_collection` owner, and the PhyloNetworks extension owns only graph-specific construction and finalization behavior.  
**Depends on**: none  
**Positive contract**: Multi-parent and tree-compatible `HybridNetwork` materialization continue to work through the canonical typed core, while parent-collection typing for the node-type and supplied-target surfaces comes from `NodeTypeLoadRequest` and `BasenodeLoadRequest` rather than an extension override.  
**Negative contract**: Do not keep `Any[]`, `reduce(typejoin, ...)`, or any renamed helper that still reconstructs parent collection types inside `ext/PhyloNetworksIO.jl`. Do not broaden the `HybridNetwork` public surface, alter rooted-network validation, or touch public docs as if the public-surface decision were settled.  
**Files**: `ext/PhyloNetworksIO.jl`  
**Out of scope**: `src/load_owner.jl`, `src/load_compat.jl`, `src/construction.jl` unless revalidation proves a core-owner bug that cannot be resolved extension-locally, `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, `ext/MetaGraphsNextIO.jl`, export lists, and public naming decisions  
**Verification**: Add a regression that proves the sampled `HybridNetwork` node-type parent-collection dispatch resolves to the core `src/construction.jl` method instead of the extension override. That regression must fail the current implementation. Then keep the existing `HybridNetwork` tree-compatible rooted, rooted-network, supplied-target, gamma-validation, and soft-release tests green, and run the full test and docs gates.

Refactor `ext/PhyloNetworksIO.jl` so it no longer owns parent-collection typing for the node-type path. Keep the extension-specific construction cursor, graph mutation, hybrid-parent orientation, retained gamma and branch handling, and finalization behavior. The task is complete only when the extension's role is clearly reduced to `HybridNetwork` construction semantics and the canonical typed core owns parent-collection typing again.

### 2. Lock PhyloNetworks canonical-owner parity and no-regrowth proof

**Type**: TEST  
**Output**: The test suite directly proves that `HybridNetwork` wrappers are thin consumers of the canonical owner and that extension cleanup did not break real user-facing behavior.  
**Depends on**: 1  
**Positive contract**: Direct canonical-owner entry and wrapper entry both materialize equivalent rooted-network and tree-compatible rooted `HybridNetwork` results, preserve authoritative tables, keep retained gamma and branch annotations meaningful, preserve synthesized nonempty leaf names where required, and preserve downstream usability such as round-trip write or downstream mutation.  
**Negative contract**: Do not rely on wrapper-only tests, method-table checks alone, or docs-string policing. Do not weaken the parity comparison to table equality only when graph-facing behavior is part of the extension contract.  
**Files**: new `test/extensions/phylonetworks_canonical_owner.jl`, `test/extensions/phylonetworks_newick_networks.jl`, `test/extensions/phylonetworks_tree_compatible_newick.jl`, `test/extensions/phylonetworks_tables_after_load.jl`, `test/extensions/phylonetworks_rejection_paths.jl`, `test/integration/phylonetworks_soft_release.jl`, `test/runtests.jl`  
**Out of scope**: extension code except minimal test-support touchups, `README.md`, `docs/src/*`, `ext/MetaGraphsNextIO.jl`, public API naming or deprecation work  
**Verification**: Add direct canonical-owner versus wrapper parity tests for `NodeTypeLoadRequest(HybridNetwork)` and for `BasenodeLoadRequest(target, construction_handle_type(target))` on rooted-network and tree-compatible rooted sources. Compare authoritative tables, basenode projection, child structure, hybrid-edge semantics, synthesized leaf names, and one downstream post-load operation. Keep the dispatch regression from task 1 active. Then run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.

Strengthen the extension suite so a future shadow-owner regrowth or contract break cannot hide behind wrapper-only coverage. The task is complete only when direct canonical-owner extension tests and wrapper parity tests jointly prove the `HybridNetwork` extension is a downstream consumer of the canonical owner rather than a second semantic owner.

### 3. Remove the stale MetaGraphsNext probe shim and keep the cursor path authoritative

**Type**: WRITE  
**Output**: `MetaGraphsNextIO` no longer contains the dead graph-vector multi-parent probe shim or stale pre-remediation probe comments, and supplied-instance multi-parent loading continues to rely on the cursor-based canonical sampled-handle path.  
**Depends on**: none  
**Positive contract**: The supplied-instance multi-parent `MetaGraph` path continues to validate and construct through `MetaGraphsNextBuildCursor` parent collections, while the library-created `MetaGraph` path remains tree-only and `MetaGraphsNextTreeView` keeps working for rooted-tree materialization.  
**Negative contract**: Do not widen the library-created `load(src, MetaGraph)` contract to multi-parent sources. Do not introduce a new extension-specific request model or a replacement probe shim. Do not change public docs to imply tranche 3 public ratification.  
**Files**: `ext/MetaGraphsNextIO.jl`, `ext/MetaGraphsNextAbstractTreesIO.jl` only if a concrete cleanup requires it  
**Out of scope**: `src/construction.jl` unless revalidation proves a core sampled-handle regression, `README.md`, `docs/src/*`, `ext/PhyloNetworksIO.jl`, export or public naming changes  
**Verification**: Add a regression that proves a supplied-instance sampled parent collection dispatches directly to the `MetaGraphsNextBuildCursor` multi-parent overload. Add a negative check that no graph-vector shim method survives after cleanup. Current code must fail the no-shim proof. Keep the existing library-created tree path, supplied-instance network path, rejection-path, and AbstractTrees view tests green, then run the full test and docs gates.

Remove the dead probe shim and stale commentary instead of preserving them as "just in case" scaffolding. The task is complete only when the extension's live owner story is reduced to the cursor-based canonical path and there is no second multi-parent probe mechanism left to drift back into use later.

### 4. Close tranche 2 with MetaGraphsNext and wrapper anti-regrowth verification

**Type**: TEST  
**Output**: The repository has direct canonical-owner versus wrapper parity coverage for `MetaGraph` extension surfaces, and the existing FileIO and `load_alife_table(...)` compatibility proofs remain the active proof that wrappers stay thin.  
**Depends on**: 3  
**Positive contract**: Direct canonical-owner `MetaGraph` tree loads and supplied-instance multi-parent network loads match their wrapper surfaces on authoritative tables, basenode projection, vertex or edge data behavior, weight behavior, and `MetaGraphsNextTreeView` traversal where applicable. The existing canonical-owner core parity tests remain aligned with this tranche and continue to prove `FileIO` and `load_alife_table(...)` do not regrow independent semantics.  
**Negative contract**: Do not use grep or source-text auditing as the only proof. Do not treat docs as the place to prove wrapper thinness. Do not pull builder compatibility redesign, public-surface naming, or docs repositioning into this tranche.  
**Files**: new `test/extensions/metagraphsnext_canonical_owner.jl`, `test/extensions/metagraphsnext_simple_newick.jl`, `test/extensions/metagraphsnext_supplied_basenode.jl`, `test/extensions/metagraphsnext_abstracttrees.jl`, `test/extensions/metagraphsnext_network_rejection.jl`, `test/core/canonical_load_owner.jl` only if a narrow parity helper update is required, `test/runtests.jl`  
**Out of scope**: `src/*` beyond minimal test-support touchups, `README.md`, `docs/src/*`, public renames, deprecations, or export changes  
**Verification**: Add direct canonical-owner versus wrapper parity tests using `NodeTypeLoadRequest(MetaGraph)` on a rooted-tree source and `BasenodeLoadRequest(graph, construction_handle_type(graph))` on a multi-parent rooted-network source. Verify authoritative tables, basenode projection, `MetaGraph` vertex and edge data behavior, weight behavior, and `MetaGraphsNextTreeView` traversal. Keep the no-shim regression from task 3 active. Keep the existing FileIO and `load_alife_table(...)` canonical-owner parity tests green. Then run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.

Finish the tranche by making the direct canonical owner, not only the public wrappers, the explicit subject of extension verification. The task is complete only when a fresh implementing agent cannot claim success while the extension paths or compatibility wrappers still survive as independent semantic owners behind a green suite.
