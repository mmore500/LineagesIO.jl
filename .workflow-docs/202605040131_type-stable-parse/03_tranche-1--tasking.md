---
date-created: 2026-05-05T00:10:00-07:00
date-revised: 2026-05-05T00:10:00-07:00
status: proposed
---

# Tasks for Tranche 1: foundational canonical load owner and typed core repair

Tasking identifier: `20260505T0010--typed-parse-tasking`

Parent tranche: Tranche 1
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
- Use the existing root `Manifest.toml`, `test/Project.toml`, and `docs/Project.toml` environments.
- Do not add dependencies or edit dependency declarations directly without user review.
- Use the approved upstream workspace at `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/` for `FileIO` and `Tables` primary-source reading.
- Treat extension migration, extension shim removal, and public docs repositioning as later-tranche work unless a local touch is strictly required to keep the repository green.

## Governance

Explicit line-by-line reading is mandatory before implementation. All downstream work must read and conform to:

- `CONTRIBUTING.md`
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

The bundled style baseline under `/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/` was also read for this planning run and is byte-identical to the repo-local `STYLE*.md` files above. Bundled `CONTRIBUTING.md` was not present there, so the repo-local `CONTRIBUTING.md` remains authoritative for contribution guidance.

Upstream primary sources that must be read line by line for this tranche are:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/src/Tables.jl`

These sources constrain the work as follows:

- `FileIO` owns format detection, ambiguity handling, `File{fmt}` wrappers, `Stream{fmt}` wrappers, and formatted dispatch.
- `Tables` owns the `Tables.AbstractColumns` and `Tables.AbstractRow` contracts, including `Tables.schema`, `Tables.columnnames`, `Tables.getcolumn`, and the optional typed `getcolumn(table, ::Type{T}, i, nm)` entrypoint.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use `basenode`, `compatibility wrapper`, `package-owned public surface`, `authoritative tables`, `materialized graph or basenode result`, `source descriptor`, `materialization descriptor`, `parent collection`, `ownership boundary`, and `green state` consistently. Do not use `type stable` as shorthand for universal exact inference when the real contract is absence of package-owned erasure and runtime recovery in owned paths.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, rebase, reset, and branch creation remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Required revalidation before implementation

- Read the tranche, the parent PRD, and this tasking file in full.
- Read the relevant code in `src/fileio_integration.jl`, `src/alife_format.jl`, `src/newick_format.jl`, `src/construction.jl`, `src/views.jl`, `src/tables.jl`, and `src/LineagesIO.jl` in full.
- Read the relevant tests in `test/core/fileio_load_surfaces.jl`, `test/core/alife_format.jl`, `test/core/builder_callback.jl`, `test/core/network_target_validation.jl`, `test/core/network_protocol_multi_parent.jl`, `test/core/network_newick_format.jl`, `test/core/basenode_binding.jl`, and `test/runtests.jl` in full.
- Read the current public docs in `README.md`, `docs/src/index.md`, and `docs/src/phylonetworks.md` in full, even though docs repositioning is not a Tranche 1 goal, so that no internal change accidentally contradicts current user-facing text.
- Re-read the upstream `FileIO` and `Tables` primary sources listed above before changing code that depends on their contracts.
- Re-check the PRD authorization boundary before making deep refactors.
- If the tranche diagnosis no longer matches reality, stop and raise that before changing code.

One diagnosis point is explicitly revalidated and fixed at the tasking level here: the typed-core problem is not limited to legacy builder callback recovery. The supplied-basenode path also hides the real construction-handle type behind `BasenodeLoadRequest{BasenodeT}`. Do not treat this tranche as "add more tests around the existing request types" work while leaving that owner boundary unchanged.

## Tranche execution rule

This tranche may redesign, replace, or deeply refactor internal load normalization and materialization logic where needed, but it must begin and end in a green, policy-compliant state. It must establish one canonical package-owned owner for source and request normalization behind non-breaking delegation while preserving authoritative-table-first parsing and current public names.

When Tranche 1 is complete:

- wrapper-owned or split-owner request normalization must no longer remain the real owner of package semantics
- the canonical materialization core must no longer depend on package-owned `Any` storage or package-owned runtime `typejoin` recovery
- the legacy `builder = fn` public surface may survive only as a compatibility adapter if it cannot yet satisfy the typed canonical contract honestly
- docs may be touched only as needed to keep the docs build green or to avoid an outright false statement caused by internal refactor, not to reposition the public contract as if Tranche 3 had already happened

## Non-negotiable execution rules

- Do not move the real semantic owner back into `FileIO` wrappers, positional argument tuples, or split helper entrypoints.
- Do not bypass authoritative table construction in favor of direct parser-to-graph or parser-to-basenode construction.
- Do not replace `Vector{Any}` with another erased container and present that as typed-core repair.
- Do not hide runtime type recovery behind helper functions, wrapper structs, or test-only assertions.
- Do not preserve the current builder callback path as a silently canonical surface if it still depends on callback-signature recovery.
- Do not settle or document the final exported package-owned load verb.
- Do not settle or document the final exported builder-surface spelling.
- Do not remove, rename, or break repo-owned public APIs in this tranche.
- Do not migrate or rewrite extension-specific request models in `ext/*` as part of this tranche except for a minimal local touch that is strictly necessary to keep the repository green and does not change extension ownership boundaries.
- Do not weaken authoritative table semantics, retained annotation semantics, single-parent or multi-parent validation semantics, or stable asset destructuring order just to make tests pass.

## Concrete anti-patterns or removal targets

- `build_load_request(...)` in `src/fileio_integration.jl` as the practical owner of request semantics
- split semantic ownership between `fileio_load(...)`, `load_alife_table(...)`, and `src/construction.jl`
- package-owned `materialized_handles::Vector{Any}` in `src/construction.jl`
- generic `build_parent_collection(::AbstractLoadRequest, parent_handles::Vector{Any})`
- `reduce(typejoin, ...)` recovery in the canonical node-type, supplied-basenode, or builder materialization path
- builder-path recovery from callback method signatures through `build_builder_parent_collection_sample(...)`, `builder_parent_argument_type(...)`, `collect_builder_parent_handle_types!(...)`, or equivalent replacement logic
- any code path that still assumes `typeof(request.basenode)[]` is the true multi-parent parent-collection type when the actual construction handle is a different type
- any code or test change that starts treating wrapper parity alone as proof of canonical typed ownership

## Failure-oriented verification

- Add direct canonical-owner tests that exercise file-backed, stream-backed, and in-memory alife sources without relying on `FileIO.load(...)` as the only execution path.
- Add direct canonical-owner coverage for tables-only, node-type, supplied-basenode, and typed-builder request or descriptor shapes.
- Add a synthetic supplied-basenode regression test where the caller-owned basenode type and the true construction-handle type differ. This test must fail the old `typeof(request.basenode)[]` or runtime-recovery design.
- Add a typed-builder regression test where a single-parent-only builder shape is rejected by the canonical typed multi-parent builder path. This test must fail the old callback-signature-recovery design.
- Keep wrapper-parity tests so compatibility surfaces are still checked against the canonical owner for equivalent requests.
- Keep rooted-network scheduling, annotation-retention, and authoritative-table retention tests green throughout.
- Run `julia --project=test test/runtests.jl`.
- Run `julia --project=docs docs/make.jl`.
- A source-text search for `Vector{Any}` or `typejoin` may be used only as a supplementary audit after behavioral and contract-level tests exist. Source-text policing alone is not sufficient proof.

## Tasks

### 1. Establish the non-exported canonical load owner and source descriptors

**Type**: WRITE  
**Output**: A non-exported canonical owner normalizes supported source descriptors and request descriptors for tables-only, node-type, and supplied-basenode flows, and the current file, stream, and in-memory alife entry surfaces delegate to it without public-name changes.  
**Depends on**: none  
**Positive contract**: One package-owned owner exists for supported Tranche 1 source normalization. `fileio_load(...)` and `load_alife_table(...)` no longer each own their own semantic normalization path for tables-only, node-type, and supplied-basenode requests. Format-specific parsing still produces authoritative tables first.  
**Negative contract**: `build_load_request(...)`, `fileio_load(...)`, and `load_alife_table(...)` must not remain parallel semantic owners. Do not present the legacy `builder = fn` path as already first-class and typed in this task. Do not change public exports or public naming.  
**Files**: `src/LineagesIO.jl`, new `src/load_owner.jl`, `src/fileio_integration.jl`, `src/alife_format.jl`, `src/newick_format.jl`, `test/core/fileio_load_surfaces.jl`, `test/core/alife_format.jl`, new `test/core/canonical_load_owner.jl`, `test/runtests.jl`  
**Out of scope**: `src/construction.jl` typed-core repair, `ext/MetaGraphsNextIO.jl`, `ext/PhyloNetworksIO.jl`, `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, any export list change other than including the new internal file in `src/LineagesIO.jl`  
**Verification**: Add direct tests that call the canonical owner on a Newick file source, a Newick stream source, and an in-memory alife table source for tables-only, node-type, and supplied-basenode requests. Add parity assertions proving current wrappers return the same authoritative tables for the same semantic request. Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.

Create a new internal owner file and wire it through `src/LineagesIO.jl`. Define one non-exported canonical owner entrypoint plus explicit source descriptors for Newick text, alife text, and in-memory alife tables. Route `src/fileio_integration.jl` and `load_alife_table(...)` in `src/alife_format.jl` through that owner for tables-only, node-type, and supplied-basenode flows. Reuse the existing authoritative-table builders in `src/newick_format.jl` and `src/alife_format.jl` instead of changing parse semantics here. The task is complete only when the supported non-builder entry surfaces delegate into one owner and the repository is green.

### 2. Make node-type and supplied-basenode materialization explicitly typed

**Type**: WRITE  
**Output**: The canonical owner drives node-type and supplied-basenode materialization through explicit construction-handle typing and request-owned parent-collection typing, with no package-owned `Any` storage or generic runtime parent recovery in the canonical path.  
**Depends on**: 1  
**Positive contract**: `NodeTypeLoadRequest` remains explicit for library-created handles, and the supplied-basenode path gains an explicit internal handle-type contract before multi-parent scheduling begins. The canonical path no longer depends on post-hoc handle inspection to discover parent-collection element types.  
**Negative contract**: Do not replace `Vector{Any}` with `Vector{Union{Nothing,Any}}`. Do not keep `reduce(typejoin, ...)` in the canonical node-type or supplied-basenode path under a helper rename. Do not treat JET success or return-type annotations alone as proof while runtime recovery still exists.  
**Files**: `src/construction.jl`, `src/load_owner.jl`, `src/views.jl` only if result typing requires it, `test/core/network_target_validation.jl`, `test/core/network_protocol_multi_parent.jl`, `test/core/basenode_binding.jl`, `test/core/canonical_load_owner.jl`, `test/runtests.jl`  
**Out of scope**: the legacy builder callback path, `ext/MetaGraphsNextIO.jl`, `ext/PhyloNetworksIO.jl`, `README.md`, `docs/src/*`, export or public naming changes  
**Verification**: Add a direct-owner regression that uses a MetaGraphsNext-like supplied-basenode scenario where the caller-owned basenode type and the real construction-handle type differ, and confirm that the canonical path passes only through the new explicit handle-type contract. Keep existing network scheduler and basenode-binding tests green. Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.

Refactor `src/construction.jl` around `materialize_graph_basenode(...)`, `emit_childnode(...)`, and parent-collection construction so the canonical node-type and supplied-basenode path no longer rely on `materialized_handles::Vector{Any}` or a generic `build_parent_collection(::AbstractLoadRequest, parent_handles::Vector{Any})`. Introduce an internal supplied-basenode descriptor or protocol contract that provides the real construction-handle type before scheduling starts. Use a synthetic core test double to prove the handle-type mismatch case rather than pulling `ext/MetaGraphsNextIO.jl` into this tranche. Preserve stable `LineageGraphAsset` destructuring order and all existing rooted-network validation semantics.

### 3. Introduce the typed builder descriptor and demote legacy builder introspection

**Type**: WRITE  
**Output**: The canonical owner supports a non-exported typed builder request or descriptor carrying explicit handle and parent-collection types, while the current `builder = fn` public surface survives only as a compatibility adapter outside the typed guarantee boundary.  
**Depends on**: 1, 2  
**Positive contract**: The canonical owner can materialize tree and multi-parent sources through an explicitly typed builder descriptor without recovering types from builder method signatures or callback return values. The compatibility wrapper story is explicit in code comments and tests even though public docs are not yet repositioned in this tranche.  
**Negative contract**: `build_builder_parent_collection_sample(...)`, `builder_parent_argument_type(...)`, `collect_builder_parent_handle_types!(...)`, and equivalent signature-driven recovery must not remain on the canonical typed path. Do not export or document the final public builder spelling here.  
**Files**: `src/construction.jl`, `src/load_owner.jl`, `src/fileio_integration.jl`, `src/alife_format.jl`, `test/core/builder_callback.jl`, `test/core/network_newick_format.jl`, `test/core/error_paths.jl`, `test/core/canonical_load_owner.jl`, `test/runtests.jl`  
**Out of scope**: `README.md`, `docs/src/*`, `ext/*`, public deprecations, exported builder naming, Tranche 2 extension migration  
**Verification**: Add direct canonical-owner tests for a typed builder descriptor on a rooted tree source and a multi-parent rooted-network source. Add a negative test proving a single-parent-only builder shape is rejected by the canonical typed multi-parent builder path. Preserve the current wrapper-level `builder = fn` behavior as compatibility-only and keep the full test and docs gates green.

Replace the canonical builder path with an explicitly typed internal builder descriptor that stores the builder callable plus the handle type and parent-collection type, or a parent-collection factory tied to that handle type. Route the canonical owner through that descriptor. If the existing public `builder = fn` wrapper must temporarily retain callback-signature recovery to preserve compatibility, isolate that logic outside the canonical owner and mark it in code and tests as compatibility-only rather than first-class typed ownership. Reuse the existing builder-event test style in `test/core/builder_callback.jl` and `test/core/network_newick_format.jl` so the anti-fix checks are behavioral rather than source-text-based.

### 4. Close the tranche with failure-oriented canonical-owner verification

**Type**: TEST  
**Output**: Direct canonical-owner coverage exists for the full Tranche 1 source and request matrix, and fake fixes are caught by behavior-level tests rather than by string-policing or wrapper-only coverage.  
**Depends on**: 1, 2, 3  
**Positive contract**: One direct test surface exercises file-backed, stream-backed, and in-memory alife sources plus tables-only, node-type, supplied-basenode, and typed-builder requests. Wrapper-parity tests prove current wrappers delegate rather than diverge.  
**Negative contract**: Do not use grep or source-text policing for `Vector{Any}` or `typejoin` as the only proof. Do not let wrapper-only tests stand in for canonical-owner tests. Do not change docs to imply Tranche 3 public ratification.  
**Files**: `test/core/canonical_load_owner.jl`, `test/core/fileio_load_surfaces.jl`, `test/core/alife_format.jl`, `test/core/network_target_validation.jl`, `test/core/network_newick_format.jl`, `test/runtests.jl`  
**Out of scope**: `src/*` migration work beyond minimal test-only touchups, `ext/*`, `README.md`, `docs/src/*`, public rename or deprecation decisions  
**Verification**: Ensure one new direct-owner test would fail the old split-owner architecture and one new direct-owner test would fail the old builder or supplied-basenode runtime-recovery path. Then run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.

Strengthen the test suite so the canonical owner, not only the compatibility wrappers, is the explicit subject of verification. Consolidate the new direct-owner coverage into `test/core/canonical_load_owner.jl` and update existing surface tests only where needed to preserve parity assertions and anti-fix checks. The task is complete only when the repository demonstrates one tested canonical owner for Tranche 1 scope, the old fake-fix shapes are behaviorally rejected, and the standard green-state commands pass.
