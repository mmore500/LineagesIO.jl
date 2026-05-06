---
date-created: 2026-05-05T14:24:23-07:00
date-revised: 2026-05-05T14:24:23-07:00
status: proposed
---

# Tasks for Tranche 1 remediation: canonical owner boundary and handle-typing repair

Tasking identifier: `20260505T1424--tranche-1-remediation-tasking`

Parent tranche: Tranche 1
Parent PRD: `01_prd.md`
Parent tasking: `03_tranche-1--tasking.md`

## Settled user decisions and environment baseline

- Treat `FileIO.load(...)` as a compatibility wrapper, not as the canonical package-owned owner of LineagesIO load semantics.
- Preserve authoritative table construction as the canonical parse output. Do not collapse the design into direct parser-to-graph construction.
- Preserve retained node and edge annotation semantics in both authoritative tables and materialized callbacks.
- Preserve container-agnostic and target-agnostic materialization semantics. Do not hard-code one graph or basenode representation as the only valid target.
- Preserve stable asset destructuring order `(graph, basenode, node_table, edge_table)`.
- No repo-owned public API removal, rename, export change, or signature break is authorized in this remediation slice.
- No final exported package-owned load verb may be chosen in this remediation slice.
- No final exported builder-surface spelling may be chosen in this remediation slice.
- Use the existing root `Manifest.toml`, `test/Project.toml`, and `docs/Project.toml` environments.
- Do not add dependencies or edit dependency declarations directly without user review.
- Use the approved upstream workspace at `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/` for `FileIO` and `Tables` primary-source reading.
- Treat extension migration, extension shim removal, and public docs repositioning as later-tranche work unless a local touch is strictly required to keep the repository green.
- The landed Tranche 1 implementation commit `b86bee8` currently passes `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. This remediation exists because that green state still permits contract violations and an unreviewed compatibility regression.

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
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-1a--remediation-tasking.md`

The bundled style baseline under `/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/` was also read for this remediation run and is byte-identical to the repo-local `STYLE*.md` files above. Bundled `CONTRIBUTING.md` was not present there, so the repo-local `CONTRIBUTING.md` remains authoritative for contribution guidance.

Upstream primary sources that must be read line by line for this remediation are:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/src/Tables.jl`

These sources constrain the work as follows:

- `FileIO` owns format detection, ambiguity handling, `File{fmt}` wrappers, `Stream{fmt}` wrappers, and formatted dispatch.
- `Tables` owns the `Tables.AbstractColumns` and `Tables.AbstractRow` contracts, including `Tables.schema`, `Tables.columnnames`, `Tables.getcolumn`, and the optional typed `getcolumn(table, ::Type{T}, i, nm)` entrypoint.

If any task needs a local touch in `ext/MetaGraphsNextIO.jl`, `ext/PhyloNetworksIO.jl`, or any other extension file to keep the repository green, implementation must first identify and read the exact upstream files in the corresponding upstream package that define the constructor, mutation, and view contracts being touched.

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use `basenode`, `compatibility wrapper`, `package-owned public surface`, `authoritative tables`, `materialized graph or basenode result`, `source descriptor`, `materialization descriptor`, `parent collection`, `ownership boundary`, and `green state` consistently. Do not use `type stable` as shorthand for universal exact inference when the real contract is absence of package-owned erasure and runtime recovery in owned paths.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, rebase, reset, and branch creation remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Review-derived current-state diagnosis

This remediation exists because the landed Tranche 1 implementation does not yet satisfy the parent PRD, tranche, and tasking contract in three review-verified ways:

- The canonical owner still normalizes the legacy `builder = fn` compatibility wrapper path inside `canonical_load(...)`, and the same owner module still carries callback-signature recovery through `BuilderLoadRequest`, `build_builder_parent_collection_sample(...)`, `builder_parent_argument_type(...)`, and `collect_builder_parent_handle_types!(...)`. That leaves the compatibility wrapper path inside the canonical owner instead of demoting it outside the typed canonical boundary.
- Node-type and supplied-basenode requests enforce handle type only at basenode creation or binding. Their child-construction paths still allow descendant handle drift on single-parent sources and still rely on storage-time failures or post-hoc behavior on multi-parent sources instead of enforcing the request-owned handle contract at the owner boundary.
- The new supplied-basenode handle-type hook currently creates an unreviewed compatibility regression for existing single-parent targets whose `bind_basenode!` method returns a cursor-like handle type that differs from the caller-owned basenode target type. The PRD and tranche do not authorize silently ratifying that breakage.

The relevant point is that these are not hypothetical or source-only concerns. The current suite and docs build are green, so this remediation must add direct behavior-level regressions that fail the current landed implementation rather than relying on "the suite passes" as proof.

## Primary-goal lock

This remediation is not complete if any of the following remain true:

- The canonical owner still accepts or normalizes the raw legacy `builder = fn` compatibility shape anywhere on the owner boundary.
- Callback-signature recovery is still reachable from the canonical owner path, even if it has been renamed or wrapped.
- A rooted-tree node-type or supplied-basenode request can still construct a basenode of the requested type and then drift to a different descendant handle type without an immediate owner-level contract error.
- A previously valid single-parent supplied-basenode target whose `bind_basenode!` method returns a cursor-like handle type still needs new user code solely because of this remediation path.
- The only claimed proof is that `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl` are green.

These are primary goals, not secondary cleanup. Any implementation that leaves one alive has not completed the remediation honestly, even if the repository is otherwise green.

## Required revalidation before implementation

- Read the tranche, parent PRD, original Tranche 1 tasking file, and this remediation tasking file in full.
- Read the relevant code in `src/load_owner.jl`, `src/fileio_integration.jl`, `src/alife_format.jl`, `src/construction.jl`, `src/views.jl`, `src/newick_format.jl`, and `src/LineagesIO.jl` in full.
- Read the relevant tests in `test/core/canonical_load_owner.jl`, `test/core/builder_callback.jl`, `test/core/error_paths.jl`, `test/core/network_target_validation.jl`, `test/core/network_protocol_multi_parent.jl`, `test/core/basenode_binding.jl`, `test/core/fileio_load_surfaces.jl`, `test/core/alife_format.jl`, `test/core/annotation_retention.jl`, `test/core/network_annotation_retention.jl`, `test/core/companion_tables.jl`, and `test/runtests.jl` in full.
- Read the current public docs in `README.md`, `docs/src/index.md`, and `docs/src/phylonetworks.md` in full, even though public docs repositioning is not a remediation goal here.
- Re-read the upstream `FileIO` and `Tables` primary sources listed above before changing code that depends on their contracts.
- Reproduce or re-check the canonical-owner builder leak against the current code before changing it. Confirm that the old owner-level `canonical_load(...; builder = fn)` or equivalent compatibility shape is still accepted on the landed implementation.
- Reproduce or re-check the rooted-tree descendant handle-drift leak against the current code before changing it. Confirm that a request can still bind or construct the requested basenode type and then return a different descendant handle type later.
- Reproduce or re-check the supplied-basenode single-parent compatibility regression against the current code before changing it. Confirm that a rooted-tree cursor-returning target still fails today without a new explicit handle-type hook.
- Re-check the PRD authorization boundary before making deep refactors.
- If the diagnosis no longer matches reality, stop and revise this remediation tasking file before changing code.

## Tranche execution rule

This remediation may redesign or relocate internal owner boundaries where needed, but it must stay inside the original Tranche 1 authorization boundary: no public naming ratification, no repo-owned public breakage, and no docs repositioning as if the later public-surface tranche had already happened. It must leave one canonical package-owned owner for source and request execution, keep authoritative-table-first parsing intact, and restore any compatibility behavior that the PRD still requires.

When this remediation is complete:

- the canonical owner must no longer own raw legacy `builder = fn` compatibility normalization
- the canonical materialization core must enforce request-owned handle typing for descendants as well as basenodes
- the supplied-basenode convenience surface must no longer fail on previously valid single-parent cursor-returning targets solely because they do not implement the new explicit handle-type hook
- multi-parent supplied-basenode paths must still refuse to proceed without an explicit pre-scheduling handle-type contract when that contract is required to avoid runtime recovery

## Non-negotiable execution rules

- Do not keep the real legacy builder compatibility story inside the canonical owner just because tests can be made green there.
- Do not preserve callback-signature recovery on any canonical typed path.
- Do not treat descendant handle drift as acceptable so long as the basenode passed a type check.
- Do not rely on vector-assignment failures, abstract container widening, or post-hoc graph inspection as the mechanism that catches handle-type violations.
- Do not ratify the new supplied-basenode compatibility break as if it were an approved migration.
- Do not restore `typeof(request.basenode)[]`, `Vector{Any}`, `reduce(typejoin, ...)`, or any equivalent runtime handle recovery in multi-parent scheduling.
- Do not weaken authoritative table semantics, retained annotation semantics, rooted-network validation semantics, or stable asset destructuring order just to satisfy the new regressions.
- Do not migrate extension-specific request models or publicly reposition docs in this remediation except for a minimal local touch strictly required to keep the repository green.
- Do not claim the builder-boundary goal complete while raw `builder = fn` compatibility still enters through `canonical_load(...)` or any equivalent owner-level path.
- Do not claim the typed-core goal complete while a rooted-tree request can still drift to a different descendant handle type after basenode creation or binding.
- Do not claim the supplied-basenode compatibility goal complete while a previously valid single-parent cursor-returning target still needs new user code.

## Concrete anti-patterns or removal targets

- `canonical_load(source_descriptor, args...; builder = ...)` as the canonical owner entry surface
- canonical-owner ownership of `BuilderLoadRequest` normalization for the raw `builder = fn` compatibility wrapper path
- callback-signature recovery through `build_builder_parent_collection_sample(...)`, `builder_parent_argument_type(...)`, `collect_builder_parent_handle_types!(...)`, or equivalent replacement logic on the canonical typed path
- node-type or supplied-basenode child-construction paths that skip request-owned handle-type enforcement for descendants
- a supplied-basenode compatibility policy that requires every existing single-parent cursor-returning target to add `construction_handle_type` immediately
- any remediation that fixes the single-parent compatibility regression by reintroducing runtime handle recovery for multi-parent scheduling
- any code or test change that treats the current green test and docs gates as sufficient proof without new direct regressions for the three reviewed failures

## Failure-oriented verification

- Each of the three review-derived failures must have an explicit red-state proof in the test body or task-local verification notes before any fix is counted complete. It is not enough to say the old code would have failed in principle.
- Add a direct canonical-owner regression proving that the canonical owner accepts explicit request objects, while the raw legacy `builder = fn` compatibility surface no longer lives there.
- Add direct regressions proving that descendant handle drift is rejected for node-type and supplied-basenode requests on both single-parent and multi-parent shapes.
- Add a public-surface regression proving that a single-parent supplied-basenode target whose `bind_basenode!` method returns a different cursor-like handle type continues to work without new user code.
- Add a negative regression proving that the same missing explicit handle-type contract still fails early and precisely on a multi-parent supplied-basenode source instead of falling back to runtime handle recovery.
- Keep wrapper-parity tests so compatibility wrappers are still checked against the canonical owner for equivalent semantic requests. For tables-only requests, parity must cover the same authoritative tables. For node-type, supplied-basenode, and typed-builder requests, parity must cover graph or basenode projection, stable asset destructuring order, authoritative tables, and relevant error behavior.
- Keep rooted-network scheduling, annotation-retention, rooted-network annotation-retention, and authoritative-table retention tests green throughout.
- Run `julia --project=test test/runtests.jl`.
- Run `julia --project=docs docs/make.jl`.
- Any source-text search for `BuilderLoadRequest`, `typejoin`, or callback-signature-recovery helpers may be used only as a supplementary audit after behavioral regressions exist. Source-text policing alone is not sufficient proof.

## Tasks

### 1. Narrow the canonical owner to explicit request objects and isolate legacy builder compatibility

**Type**: WRITE  
**Output**: The canonical owner accepts explicit request objects only, and the raw legacy `builder = fn` surface survives only as a compatibility wrapper outside that owner.  
**Depends on**: none  
**Positive contract**: `canonical_load(::AbstractLoadSourceDescriptor, ::AbstractLoadRequest)` is the canonical package-owned owner shape. The typed builder path enters the canonical owner only through `TypedBuilderLoadRequest`. Raw `builder = fn` compatibility normalization is owned by a wrapper-layer compatibility helper instead of by the canonical owner itself.  
**Negative contract**: `BuilderLoadRequest`, `build_builder_parent_collection_sample(...)`, `builder_parent_argument_type(...)`, `collect_builder_parent_handle_types!(...)`, and equivalent callback-signature recovery must not remain on the canonical owner path. Do not keep `canonical_load(source_descriptor, args...; builder = ...)` as the owner-level builder surface. Do not change public exports or settle public naming.  
**Files**: `src/LineagesIO.jl`, `src/load_owner.jl`, new `src/load_compat.jl`, `src/fileio_integration.jl`, `src/alife_format.jl`, `src/construction.jl`, `test/core/canonical_load_owner.jl`, `test/core/builder_callback.jl`, `test/core/error_paths.jl`, `test/runtests.jl`  
**Out of scope**: `ext/*`, `README.md`, `docs/src/*`, public deprecations, exported naming decisions  
**Verification**: Add a direct-owner regression proving that `canonical_load(descriptor, TypedBuilderLoadRequest(...))` remains supported while the raw legacy builder compatibility shape no longer lives at the canonical owner boundary. The cleanest proof is a direct test that the old `canonical_load(descriptor; builder = fn)` or equivalent owner-level compatibility shape is now rejected, while wrapper-level `builder = fn` still works through `FileIO.load(...)` and `load_alife_table(...)`. This regression must fail on commit `b86bee8`. Then run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.

Create one non-exported compatibility helper owner outside the canonical owner so `FileIO` wrappers and `load_alife_table(...)` can continue to support the raw `builder = fn` public convenience surface without letting that raw surface remain the canonical package-owned owner. Keep source-descriptor ownership in `src/load_owner.jl`, but move the legacy builder compatibility story out of it. Make the direct canonical-owner tests use explicit request objects only.

### 2. Enforce request-owned handle typing on every descendant construction event

**Type**: WRITE  
**Output**: Node-type, supplied-basenode, and typed-builder requests enforce their handle-type contract for descendant construction events as well as for basenode creation or binding.  
**Depends on**: 1  
**Positive contract**: Any child callback that returns a handle outside the request-owned contract fails immediately with an owner-level `ArgumentError` before recursion, queueing, or storage proceeds. The request-owned handle contract is no longer partially enforced only at basenode creation, and a rooted-tree request can no longer succeed after descendant handle drift.  
**Negative contract**: Do not rely on vector-assignment failures, abstract container widening, or post-hoc graph shape assertions to catch descendant handle drift. Do not leave single-parent child paths unchecked while only tightening multi-parent storage.  
**Files**: `src/construction.jl`, `src/load_owner.jl` only if a direct request constructor is needed for explicit-handle tests, `test/core/canonical_load_owner.jl`, `test/core/network_target_validation.jl`, `test/core/error_paths.jl`, `test/core/basenode_binding.jl`, `test/runtests.jl`  
**Out of scope**: supplied-basenode compatibility fallback policy, `ext/*`, `README.md`, `docs/src/*`, public naming changes  
**Verification**: Add a single-parent regression where a node-type request constructs a basenode of the requested type but returns a different child-handle type later; the load must now fail with a precise owner-level error instead of succeeding. Add a supplied-basenode regression where the bound handle type is explicit and a later child returns the wrong handle type. Add a multi-parent regression proving the same contract is enforced before opaque storage-time failure. At least one of these regressions must fail on commit `b86bee8`. Then run the full test and docs gates.

Refactor `emit_single_parent_childnode(...)`, `emit_multi_parent_childnode(...)`, and any shared child-construction helpers so they use one request-owned handle-type enforcement story, not one rule for basenodes and a weaker or absent rule for descendants. Reuse the typed-builder enforcement shape as the model rather than inventing a separate weaker check for node-type and supplied-basenode requests.

### 3. Restore supplied-basenode compatibility without weakening multi-parent preflight

**Type**: MIGRATE  
**Output**: The supplied-basenode compatibility wrapper again supports existing single-parent targets whose `bind_basenode!` method returns a cursor-like handle type different from the caller-owned basenode type, while multi-parent supplied-basenode scheduling still requires an explicit pre-scheduling handle-type contract.  
**Depends on**: 1, 2  
**Positive contract**: The public `load(src, basenode)` and `load_alife_table(table, basenode)` compatibility surfaces preserve the pre-remediation single-parent contract, including cursor-returning binders on rooted-tree sources. The canonical typed path still has an explicit handle-type request shape for direct-owner and multi-parent use. If a supplied-basenode target lacks an explicit handle type, compatibility support may continue only on sources that do not require multi-parent parent-collection typing before scheduling begins.  
**Negative contract**: Do not keep the unconditional fallback `construction_handle_type(target) = typeof(target)` as if that were a safe compatibility contract. Do not reintroduce `typeof(request.basenode)[]`, `typejoin`, or other runtime handle recovery for multi-parent supplied-basenode scheduling. Do not force all existing single-parent cursor-returning targets to add `construction_handle_type` immediately.  
**Files**: `src/load_owner.jl`, `src/load_compat.jl`, `src/construction.jl`, `src/fileio_integration.jl`, `src/alife_format.jl`, `test/core/canonical_load_owner.jl`, `test/core/network_target_validation.jl`, `test/core/error_paths.jl`, `test/runtests.jl`  
**Out of scope**: `ext/*` unless a minimal local touch is strictly required to keep the repository green, `README.md`, `docs/src/*`, export or public naming changes  
**Verification**: Add a public-surface regression reproducing the review-reported single-parent compatibility shape: a caller-owned basenode target whose `bind_basenode!` method returns a different cursor-like handle type must succeed on a rooted-tree source through `FileIO.load(...)` and through `load_alife_table(...)` without new user code. Add a direct-owner regression proving that the explicit-handle supplied-basenode request still supports the typed multi-parent path. Add a negative public-surface regression proving that a multi-parent source still fails early with a precise compatibility error when the caller uses the legacy supplied-basenode surface without an explicit handle-type contract. These regressions must fail on commit `b86bee8`. Then run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.

Do not solve this by silently weakening the typed core. Instead, separate the compatibility policy from the canonical typed request model. The canonical path may require an explicit handle type for multi-parent supplied-basenode scheduling, but the compatibility wrapper must preserve the earlier single-parent contract. If needed, introduce a non-exported explicit-handle constructor for `BasenodeLoadRequest` so direct canonical-owner tests and compatibility helpers do not have to abuse internal struct parameter syntax.

### 4. Close the remediation with review-derived failure coverage

**Type**: TEST  
**Output**: The test suite directly catches all three review-derived failures and proves the corrected owner and compatibility boundaries instead of relying on the pre-existing green suite.  
**Depends on**: 1, 2, 3  
**Positive contract**: One direct test surface proves the canonical-owner request boundary, the wrapper-only legacy builder compatibility boundary, descendant handle-type enforcement, restored single-parent supplied-basenode compatibility, and the retained explicit-handle requirement for multi-parent supplied-basenode scheduling. Wrapper-parity tests continue to prove full observable parity for equivalent semantic requests.  
**Negative contract**: Do not rely on grep or source-text policing alone. Do not let wrapper-only tests stand in for canonical-owner tests. Do not let the review findings disappear behind "the suite passes" without direct regressions that fail the previous implementation. Do not change public docs to imply Tranche 3 public ratification.  
**Files**: `test/core/canonical_load_owner.jl`, `test/core/builder_callback.jl`, `test/core/error_paths.jl`, `test/core/network_target_validation.jl`, `test/core/fileio_load_surfaces.jl`, `test/core/alife_format.jl`, `test/runtests.jl`  
**Out of scope**: `src/*` changes beyond minimal test-support touchups, `ext/*`, `README.md`, `docs/src/*`, public rename or deprecation decisions  
**Verification**: Ensure one regression fails commit `b86bee8` for each of these three issues: canonical-owner leakage of the raw builder compatibility path, descendant handle drift escaping request-owned enforcement, and the supplied-basenode single-parent compatibility break. Then run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.

Consolidate the review-derived regressions into a durable direct-owner and compatibility-wrapper test story, not just one-off local checks. The remediation is complete only when the repository still satisfies the original Tranche 1 green-state commands and the three reviewed failure modes are now directly prevented by the verification artifacts themselves.
