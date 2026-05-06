---
date-created: 2026-05-06T08:48:28-0700
status: approved
---

# Tasks for Tranche 4: approved public rollout and contract synchronization

Tasking identifier: `20260506T0848--tranche-4-tasking`

Parent tranche: Tranche 4
Parent PRD: `01_prd.md`

## Settled user decisions and environment baseline

- `LineagesIO.read_lineages` is the ratified first-class package-owned public file or stream verb.
- `LineagesIO.BuilderDescriptor` is the ratified first-class typed builder descriptor spelling.
- `FileIO.load(...)` remains a compatibility-only wrapper.
- `load_alife_table(...)` remains a repo-owned convenience wrapper over the same canonical owner. It is not the first-class package-owned file or stream surface, and it is not compatibility-only in the same sense as `FileIO.load(...)`.
- No deprecations, renames, removals, export breaks, or signature breaks are authorized in this tranche. The rollout is additive only.
- `canonical_load(...)`, the package-owned source descriptors, and the internal typed request types remain internal owner surfaces. This tranche must not export or document them as first-class public API.
- The canonical parse invariant remains fixed: package-owned load surfaces normalize once, build authoritative tables first, and only then materialize graph or basenode results.
- Authoritative `node_table` and `edge_table` semantics, retained annotation semantics, rooted-tree and rooted-network validation semantics, extension activation behavior, and stable asset destructuring order `(graph, basenode, node_table, edge_table)` remain non-negotiable.
- Use the existing root environment and the existing `test/Project.toml`, `docs/Project.toml`, and `examples/Project.toml` environments. Do not add dependencies or edit dependency declarations directly without explicit user review.
- Use the approved upstream workspace at `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/` for `FileIO`, `Tables`, `PhyloNetworks.jl`, and `MetaGraphsNext.jl` primary-source reading.
- The repo-local `STYLE-vocabulary.md` is the higher-priority vocabulary authority for this tranche. It supersedes the bundled baseline because it now contains the 2026-05-06 ratifications for `read_lineages` and `BuilderDescriptor`.
- The current repository already contains the internal typed owner and direct-owner tests from earlier tranches. This tranche must not retask owner repair work as if it were still red.

The following public-surface decisions are derivable from the active sources and are settled for downstream implementation in this tranche:

- `read_lineages` is a path-or-stream surface only. Raw text descriptors and internal source descriptor types remain internal and must not become part of the public contract in this tranche.
- `read_lineages(path::AbstractString, args...; format = nothing)` is the package-owned path surface. Package-owned automatic source selection must recognize Newick safe extensions `.nwk`, `.newick`, `.tree`, `.tre`, and `.trees` as Newick, and `.csv` as alife CSV. The ambiguous `.txt` extension must not be auto-inferred; it requires explicit package-owned override via `format = :newick`.
- `read_lineages(io::IO, args...; source_path = nothing, format = nothing)` is the package-owned stream surface. A stream load must succeed when `format` is supplied as `:newick` or `:alife`, or when `source_path` carries a non-ambiguous supported extension. A stream surface with neither explicit `format` nor an inferable `source_path` must fail with a contract-level `ArgumentError` instead of guessing.
- The only package-owned `format` keyword values authorized in this tranche are `:newick` and `:alife`. `FileIO.File{...}` and `FileIO.Stream{...}` wrappers remain compatibility-only surfaces and must not become part of the `read_lineages` contract.
- `BuilderDescriptor` must mirror the internal typed builder contract rather than invent a second builder model. The public typed descriptor shape for this tranche is `BuilderDescriptor(builder, HandleT[, ParentCollectionT])`.
- `read_lineages(source, BuilderDescriptor(...))` is the first-class typed builder path. Raw `builder = fn` remains compatibility-only and must not be accepted on `read_lineages`.
- `read_lineages(source, basenode)` is a typed supplied-basenode path only. It must translate directly to the internal typed supplied-basenode request. If `construction_handle_type(basenode)` is `nothing`, the package-owned first-class surface must fail honestly with a precise error that points the caller to the compatibility wrapper story or to implementing `construction_handle_type`. It must not silently route through the legacy single-parent compatibility fallback.
- `load_alife_table(table, BuilderDescriptor(...); source_path = ...)` should be added in this tranche as the additive typed convenience-wrapper counterpart for in-memory Tables.jl input so the convenience wrapper stays aligned with the same canonical typed owner. Raw `builder = fn` remains supported on `load_alife_table(...)` as a compatibility or convenience surface.

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
- `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`
- `.workflow-docs/202605040131_type-stable-parse/03_tranche-4--tasking.md`

The bundled style baseline under `/home/jeetsukumaran/site/service/env/start/workhost/resources/packages/shared/workhost-resources/configure/coding-agent-skills/development-policies/references/` was also read during this tasking run. It is byte-identical to the repo-local style files except for `STYLE-vocabulary.md`. The repo-local vocabulary file is newer and higher priority because it carries the ratified public identifiers `read_lineages` and `BuilderDescriptor`. Bundled `CONTRIBUTING.md` was not present there, so repo-local `CONTRIBUTING.md` remains authoritative for contribution guidance.

Workflow authorities used to produce this tasking were `development-policies` and `devflow-architecture-03--tranche-to-tasks`. Downstream implementation must preserve their pass-forward mandates, especially active-authority restatement, exact upstream-source naming, exact authorization boundaries, controlled vocabulary, primary-goal lock items, direct red-state repros, and failure-oriented verification.

Upstream primary sources that must be read line by line for this tranche are:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/loadsave.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/query.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/src/Tables.jl`

These sources constrain the public rollout as follows:

- `FileIO` owns the host-framework `load(...)` surface, format detection, ambiguity handling, `File{fmt}` wrappers, `Stream{fmt}` wrappers, and formatted dispatch. The package-owned public rollout must therefore keep `FileIO.load(...)` documented as a compatibility wrapper rather than as the canonical package-owned contract.
- `Tables` owns the in-memory table contract used by `load_alife_table(...)`, including `Tables.istable`, `Tables.columns`, `Tables.columnnames`, `Tables.getcolumn`, and the optional typed `getcolumn(table, ::Type{T}, i, nm)` entrypoint. The convenience-wrapper story for in-memory alife data must therefore stay explicitly distinct from the file-or-stream `read_lineages` story.

Conditional extension upstreams are mandatory if implementation touches extension-facing behavior, extension-facing public tests, or source-specific docs and examples that assert extension semantics:

- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/types.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/readwrite.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/manipulateNet.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/PhyloNetworks.jl/src/auxiliary.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/README.md`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/metagraph.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/graphs.jl`
- `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/MetaGraphsNext.jl/src/weights.jl`

Controlled vocabulary from `STYLE-vocabulary.md` is mandatory. Use `basenode`, `package-owned public surface`, `compatibility wrapper`, `convenience wrapper`, `authoritative tables`, `materialized graph or basenode result`, `source descriptor`, `materialization descriptor`, `ownership boundary`, `green state`, `lock item`, `red-state repro`, `handoff packet`, and `verification artifact` consistently. Do not use `type stable` as shorthand for universal exact inference when the real contract is absence of package-owned erasure and runtime recovery in owned paths.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, rebase, reset, and branch creation remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Primary-goal lock

### Lock 1: the first-class package-owned public surface must exist as `LineagesIO.read_lineages`

- The work is not complete if `LineagesIO.read_lineages` is still missing, still internal-only, or still documented only through wrapper-first `load(...)` flows.
- Direct red-state repro: `src/LineagesIO.jl` currently exports `load_alife_table` but does not export `read_lineages`, while `README.md` and `docs/src/index.md` still teach wrapper-first `load(...)` flows as the primary public story.
- Closing tasks: 1, 2, 3, 4, and 5.
- Verification artifact that must fail the old implementation or fake-fix shape: direct public-surface tests for `read_lineages` on path and stream sources plus user-facing docs and example updates that place `read_lineages` at the front of the package-owned story. Current code fails because the public name does not exist and the docs still lead with compatibility wrappers.

### Lock 2: the first-class typed builder descriptor surface must exist as `LineagesIO.BuilderDescriptor`

- The work is not complete if the tranche exposes `TypedBuilderLoadRequest` as public API, leaves the first-class typed builder story implicit, or accepts raw `builder = fn` on `read_lineages`.
- Direct red-state repro: the typed builder path already exists internally through `TypedBuilderLoadRequest(...)`, but there is no public `BuilderDescriptor` name and current user-facing docs teach only the compatibility-only `load(src; builder = fn)` flow.
- Closing tasks: 1, 2, 3, and 5.
- Verification artifact that must fail the old implementation or fake-fix shape: public tests that use `BuilderDescriptor(builder, HandleT[, ParentCollectionT])` through `read_lineages` and `load_alife_table(...)`, combined with negative regressions proving that `read_lineages(...; builder = fn)` is rejected with a contract-level error that points callers toward `BuilderDescriptor`. Current code fails because `BuilderDescriptor` does not exist and `read_lineages` does not exist.

### Lock 3: the first-class typed supplied-basenode boundary must stay honest

- The work is not complete if `read_lineages(source, basenode)` silently falls back to the legacy supplied-basenode compatibility path when no explicit handle-type contract is available.
- Direct red-state repro: `src/load_owner.jl` and `src/construction.jl` already distinguish between `BasenodeLoadRequest` and the legacy compatibility fallback. `BasenodeLoadRequest(basenode)` requires `construction_handle_type(basenode)`, while the compatibility wrappers still permit a single-parent fallback through `LegacyBasenodeLoadRequest`. A fake rollout could blur that distinction by routing `read_lineages` through compatibility normalization.
- Closing tasks: 1, 2, and 5.
- Verification artifact that must fail the old implementation or fake-fix shape: public tests that prove `read_lineages(source, basenode)` succeeds when `construction_handle_type(basenode)` exists, fails with a precise typed-boundary error when it does not, and does not silently inherit the legacy single-parent compatibility fallback. Current code fails because `read_lineages` does not exist and therefore there is no first-class typed boundary to verify.

### Lock 4: `load_alife_table(...)` must stay explicitly a convenience wrapper

- The work is not complete if `load_alife_table(...)` still reads as a policy-ambiguous public surface, if it is documented as the first-class package-owned file or stream surface, or if it is demoted inaccurately into the compatibility-only bucket.
- Direct red-state repro: `src/alife_format.jl` and `docs/src/index.md` currently teach `load_alife_table(...)` directly, but the Tranche 3 decision record ratifies it specifically as a convenience wrapper over the canonical owner.
- Closing tasks: 1, 2, and 3.
- Verification artifact that must fail the old implementation or fake-fix shape: direct docs language and public tests that classify `load_alife_table(...)` as a convenience wrapper, keep its existing convenience behavior, and add the additive typed `BuilderDescriptor` convenience path without relabeling it as the first-class file or stream surface. Current code fails because the ratified classification is not yet rolled out anywhere user-facing.

### Lock 5: the wrapper-first public contract must be removed from docs and examples

- The work is not complete if `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, or the runnable examples still present `FileIO.load(...)` or extension-specific wrapper flows as the primary public happy path.
- Direct red-state repro: `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, `examples/src/alife_standard_mwe.jl`, `examples/src/phylonetworks_mwe01.jl`, and `examples/src/phylonetworks_mwe02.jl` all currently lead with compatibility-wrapper flows.
- Closing tasks: 3, 4, and 5.
- Verification artifact that must fail the old implementation or fake-fix shape: docs review plus runnable examples that use `read_lineages` as the first-class public story, while keeping `FileIO.load(...)` documented only as compatibility-only and `load_alife_table(...)` as the in-memory convenience wrapper. Current code fails because the examples and docs are still wrapper-first.

### Lock 6: the rollout must stay additive-only and preserve retained wrapper support

- The work is not complete if the tranche removes or deprecates existing wrapper surfaces, broadens the authorization boundary beyond the ratified names, or changes extension-facing behavior while updating the public story.
- Direct red-state repro: the current repository still needs the new public surface, but a fake rollout could achieve that by renaming or deprecating retained wrappers instead of adding the ratified surface alongside them.
- Closing tasks: 1, 2, 3, 4, and 5.
- Verification artifact that must fail the old implementation or fake-fix shape: retained FileIO-wrapper parity tests, retained `load_alife_table(...)` compatibility and convenience tests, extension public-surface parity tests, and review of touched exports and docs proving that no deprecation, removal, or renamed wrapper story was smuggled in. Current code fails because the additive public rollout is still absent.

## Handoff packet

- Active authorities:
  `AGENTS.md`, `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, `STYLE-writing.md`, `.workflow-docs/202605040131_type-stable-parse/01_prd.md`, `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`, `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`, and this tasking file.
- Parent documents:
  `.workflow-docs/202605040131_type-stable-parse/01_prd.md`, `.workflow-docs/202605040131_type-stable-parse/02_tranches.md`, `.workflow-docs/202605040131_type-stable-parse/00_tranche3-public-surface-decision.md`, and this file.
- Settled decisions and non-negotiables:
  `read_lineages` is the ratified first-class package-owned public file or stream verb; `BuilderDescriptor` is the ratified first-class typed builder descriptor spelling; `FileIO.load(...)` remains compatibility-only; `load_alife_table(...)` remains a convenience wrapper; no deprecations, removals, or public breakage are authorized; source descriptors and internal typed request names remain internal.
- Authorization boundary:
  additive rollout only across repo-owned API, docs, README, examples, exports, and public-surface tests; no deprecations, renames, removals, or broader vocabulary changes.
- Current-state diagnosis:
  the internal typed owner already exists and is directly tested; `src/LineagesIO.jl` still does not export `read_lineages` or `BuilderDescriptor`; user-facing docs and examples remain wrapper-first; `load_alife_table(...)` is already exported but not yet repositioned as a convenience wrapper; the first-class typed supplied-basenode boundary still needs explicit rollout rather than compatibility fallback.
- Primary-goal lock:
  locks 1 through 6 above.
- Direct red-state repros:
  missing `read_lineages` and `BuilderDescriptor` exports; wrapper-first docs and examples; no public-surface tests for the ratified names; no first-class typed supplied-basenode boundary at the public surface.
- Owner and invariant under repair:
  the repo-owned public load contract must name one first-class package-owned surface, keep wrapper boundaries explicit, and preserve the authoritative-table-first invariant without reopening typed-core ownership.
- Exact files or surfaces in scope:
  `src/LineagesIO.jl`, a new package-owned public-surface file for `read_lineages`, `src/load_owner.jl` only as needed for additive public bridging, `src/alife_format.jl` only as needed for additive convenience-wrapper typed-descriptor support, `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, `examples/src/alife_standard_mwe.jl`, `examples/src/phylonetworks_mwe01.jl`, `examples/src/phylonetworks_mwe02.jl`, and the public-surface test files created or updated to prove the rollout.
- Exact files or surfaces out of scope:
  deprecations, removals, export breaks, changes to the canonical owner boundary beyond additive bridging, changes to authoritative table semantics, retained annotation semantics, stable asset destructuring order, or extension-core ownership; internal source descriptor promotion; public raw-text read surface design.
- Required upstream primary sources:
  the exact `FileIO`, `Tables`, and conditional extension sources named in the Governance section.
- Green-state gates:
  `julia --project=test test/runtests.jl`; `julia --project=docs docs/make.jl`; `julia --project=examples examples/src/alife_standard_mwe.jl`; `julia --project=examples examples/src/phylonetworks_mwe01.jl`; `julia --project=examples examples/src/phylonetworks_mwe02.jl`.
- Stop conditions:
  stop if implementation appears to require a different public name, deprecations, removals, or broader vocabulary changes; stop if the first-class supplied-basenode path cannot be rolled out honestly without inventing a new public spelling or reviving the legacy compatibility fallback; stop if the extension-facing public tests or docs reveal a deeper behavior break that belongs to a different tranche than this public rollout.

## Required revalidation before implementation

- Read the parent tranche, parent PRD, and Tranche 3 decision record in full.
- Read `src/LineagesIO.jl`, `src/load_owner.jl`, `src/load_compat.jl`, `src/fileio_integration.jl`, and `src/alife_format.jl` in full.
- Read `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, `examples/src/alife_standard_mwe.jl`, `examples/src/phylonetworks_mwe01.jl`, and `examples/src/phylonetworks_mwe02.jl` in full.
- Read `test/core/canonical_load_owner.jl`, `test/core/fileio_load_surfaces.jl`, `test/core/alife_format.jl`, `test/extensions/phylonetworks_canonical_owner.jl`, `test/extensions/metagraphsnext_canonical_owner.jl`, and `test/runtests.jl` in full.
- Re-read the exact `FileIO` and `Tables` primary sources listed above in full before changing the public surface, and re-read the conditional extension upstream sources if extension-facing docs, examples, or public-surface tests are touched.
- Re-check that `src/LineagesIO.jl` still exports `load_alife_table` but not `read_lineages` or `BuilderDescriptor`.
- Re-check that `README.md`, `docs/src/index.md`, `docs/src/phylonetworks.md`, and the three runnable examples still present wrapper-first flows as the primary public story.
- Re-check that `src/load_owner.jl` still defines the typed internal source descriptors, `TypedBuilderLoadRequest`, and the typed `BasenodeLoadRequest` boundary, and that `src/construction.jl` still contains the legacy supplied-basenode compatibility path for retained wrapper surfaces only.
- Re-check that `test/core/canonical_load_owner.jl` still proves direct-owner typed entry through `canonical_load(...)`, and that there is still no public-surface test file for `read_lineages`.
- If any of those revalidation points no longer hold, stop and revise this tasking before changing code.

## Tranche execution rule

This tranche is a public rollout and contract-synchronization tranche. It may add exports, additive bridging code, public tests, docs, and examples needed to ship the ratified names, but it must begin and end in a green, policy-compliant state and it must not reopen the already-settled design decisions from the PRD or Tranche 3.

When this tranche is complete:

- `LineagesIO.read_lineages` is implemented, exported, tested, and documented as the first-class package-owned file or stream surface.
- `LineagesIO.BuilderDescriptor` is implemented, exported, tested, and documented as the first-class typed builder descriptor surface.
- `FileIO.load(...)` remains supported and documented as compatibility-only.
- `load_alife_table(...)` remains supported and documented as the in-memory convenience wrapper over the same canonical owner.
- Public docs, runnable examples, and direct public-surface tests all tell the same ownership story.

## Non-negotiable execution rules

- Do not export or document `canonical_load(...)`, source descriptor types, `TypedBuilderLoadRequest`, `BasenodeLoadRequest`, or other internal owner types as first-class public API.
- Do not accept raw `builder = fn` on `read_lineages`. Keep that raw builder surface compatibility-only.
- Do not silently route `read_lineages(source, basenode)` through the legacy supplied-basenode compatibility path when `construction_handle_type(basenode)` is unavailable. Fail honestly instead.
- Do not require FileIO `File{fmt}` or `Stream{fmt}` wrappers on `read_lineages`. Those remain compatibility surfaces.
- Do not remove, rename, or deprecate `FileIO.load(...)`, `load_alife_table(...)`, `load(src, NodeT)`, `load(src, basenode)`, `load(src; builder = fn)`, or extension-specific wrapper flows in this tranche.
- Do not change authoritative table semantics, retained annotation semantics, rooted-network scheduling and validation semantics, stable asset destructuring order, or extension activation behavior while updating the public contract.
- Do not promote internal raw-text descriptors or invent a new public raw-text read surface in this tranche.
- Do not replace contract-level verification with grep checks, docs-string policing, or helper-only tests. These may supplement but must not replace direct public-surface verification.

## Concrete anti-patterns or removal targets

- missing `read_lineages` and `BuilderDescriptor` exports
- wrapper-first public contract wording in `README.md`, `docs/src/index.md`, and `docs/src/phylonetworks.md`
- wrapper-first runnable examples in `examples/src/alife_standard_mwe.jl`, `examples/src/phylonetworks_mwe01.jl`, and `examples/src/phylonetworks_mwe02.jl`
- any attempt to expose `TypedBuilderLoadRequest` or `canonical_load(...)` as public API instead of introducing the ratified names
- any first-class `read_lineages` implementation that silently inherits the legacy supplied-basenode compatibility fallback
- any docs update that blurs `compatibility wrapper`, `convenience wrapper`, and `package-owned public surface` back together
- any additive rollout that quietly broadens into deprecations, removals, or export breaks

## Failure-oriented verification

- Add direct public-surface tests proving that `read_lineages` exists and supports the ratified path and stream stories for Newick and alife file-backed or stream-backed sources. Current code must fail because the public name does not exist.
- Add direct negative regressions proving that:
  - `read_lineages("tree.txt")` without `format = :newick` fails with a precise package-owned ambiguity error.
  - `read_lineages(io)` without `format` or an inferable `source_path` fails with a precise package-owned stream-format error.
  - `read_lineages(source; builder = fn)` is rejected and points callers to `BuilderDescriptor`.
  - `read_lineages(source, basenode)` fails honestly when `construction_handle_type(basenode)` is unavailable instead of silently inheriting the compatibility fallback.
- Add direct `BuilderDescriptor` public tests proving that `read_lineages(source, BuilderDescriptor(...))` and `load_alife_table(table, BuilderDescriptor(...))` reach the typed canonical owner and preserve multi-parent builder behavior.
- Add direct extension public-surface parity tests proving that `read_lineages(path, HybridNetwork)`, `read_lineages(path, HybridNetwork())`, `read_lineages(path, MetaGraph)`, and `read_lineages(path, metagraph_instance)` preserve the same authoritative tables and extension-facing behavior as the underlying canonical-owner and retained-wrapper paths.
- Keep the retained `FileIO.load(...)` parity tests, `load_alife_table(...)` tests, canonical-owner tests, and extension activation or canonical-owner parity tests green so the additive rollout cannot hide behind the new public surface alone.
- Run `julia --project=test test/runtests.jl`.
- Run `julia --project=docs docs/make.jl`.
- Run `julia --project=examples examples/src/alife_standard_mwe.jl`.
- Run `julia --project=examples examples/src/phylonetworks_mwe01.jl`.
- Run `julia --project=examples examples/src/phylonetworks_mwe02.jl`.

## Tasks

### 1. Introduce the ratified public owner and typed builder surface

**Type**: WRITE
**Output**: `LineagesIO.read_lineages` and `LineagesIO.BuilderDescriptor` exist as exported public API, and the first-class package-owned file or stream surface delegates directly into the canonical typed owner without exposing internal owner names.
**Depends on**: none
**Positive contract**: Implement and export `read_lineages` and `BuilderDescriptor`. Support `read_lineages(path::AbstractString, args...; format = nothing)` and `read_lineages(io::IO, args...; source_path = nothing, format = nothing)` for tables-only, node-type, supplied-basenode, and typed builder flows. Recognize `.nwk`, `.newick`, `.tree`, `.tre`, and `.trees` as Newick and `.csv` as alife. Require `format = :newick` for `.txt`. Require either explicit `format` or an inferable `source_path` for streams. Support `BuilderDescriptor(builder, HandleT[, ParentCollectionT])` as the public typed builder descriptor. Add the additive convenience-wrapper overload `load_alife_table(table, BuilderDescriptor(...); source_path = ...)` so in-memory Tables.jl input can use the same typed builder path.
**Negative contract**: Do not export or publicly document `canonical_load`, internal source descriptors, `TypedBuilderLoadRequest`, or `BasenodeLoadRequest`. Do not accept raw `builder = fn` on `read_lineages`. Do not silently route `read_lineages(source, basenode)` through the legacy compatibility fallback when `construction_handle_type(basenode)` is unavailable. Do not require FileIO wrapper types on `read_lineages`. Do not add deprecations, removals, or export breaks.
**Files**: `src/LineagesIO.jl`, new `src/read_lineages.jl`, `src/load_owner.jl` only if a narrow additive bridge or helper is required, `src/alife_format.jl`
**Out of scope**: `src/fileio_integration.jl`, `src/load_compat.jl`, public docs, examples, tests, deprecations, removals, internal owner redesign
**Verification**: Task 2 must be able to prove the new exports exist and that the typed public surface behaves as specified. The old implementation must fail because neither public name exists. At minimum, leave direct public call sites possible for `read_lineages("tree.nwk")`, `read_lineages("phylogeny.csv")`, `read_lineages(io; format = :newick)`, `read_lineages(path, NodeT)`, `read_lineages(path, basenode)` when `construction_handle_type` exists, and `read_lineages(path, BuilderDescriptor(...))`.

Create one additive public-surface file and wire it from `src/LineagesIO.jl`. Use package-owned format selection rather than FileIO host wrappers for the new surface. Keep the source descriptors internal and translate public calls into the existing internal typed request objects. Treat path and stream source selection as a public contract, not as an implementation detail left for the next agent to invent.

### 2. Lock core public-surface behavior and compatibility boundaries

**Type**: TEST
**Output**: The test suite directly proves the first-class `read_lineages` and `BuilderDescriptor` behavior, while retained wrappers and convenience wrappers stay green.
**Depends on**: 1
**Positive contract**: Add direct public-surface tests that cover `read_lineages` on Newick safe extensions, `read_lineages` on alife `.csv`, explicit `format = :newick` for `.txt`, stream loads through `format` or `source_path`, node-type targets, typed supplied-basenode targets, and typed builder targets. Add additive typed convenience-wrapper tests for `load_alife_table(table, BuilderDescriptor(...))`. Keep retained wrapper parity proofs for `FileIO.load(...)` and current `load_alife_table(...)` flows.
**Negative contract**: Do not rely on helper-only canonical-owner tests as the sole proof for the new public surface. Do not let `read_lineages` inherit raw `builder = fn` or legacy supplied-basenode fallback behavior silently. Do not use generic `MethodError` acceptance where a contract-level `ArgumentError` is available and derivable.
**Files**: new `test/core/read_lineages_public_surface.jl`, `test/core/canonical_load_owner.jl`, `test/core/fileio_load_surfaces.jl`, `test/core/alife_format.jl`, `test/runtests.jl`
**Out of scope**: user-facing docs and examples, extension-specific docs, export changes beyond those from task 1
**Verification**: Add direct negative regressions proving that `read_lineages("tree.txt")` without `format = :newick` fails, `read_lineages(io)` without enough format information fails, `read_lineages(source; builder = fn)` is rejected with a `BuilderDescriptor`-pointing error, and `read_lineages(source, basenode)` fails honestly when `construction_handle_type` is unavailable. Keep retained wrapper parity tests green so the additive rollout does not alter existing wrapper behavior. Then run the full test gate.

Make the first-class package-owned public surface, not only internal helpers, the explicit subject of verification. The task is complete only when a fake fix that leaves the public contract implicit or permissive would fail.

### 3. Synchronize the general public contract in README, index docs, and the alife example

**Type**: WRITE
**Output**: `README.md`, `docs/src/index.md`, and `examples/src/alife_standard_mwe.jl` present `read_lineages` as the first-class package-owned public surface, `load_alife_table(...)` as the convenience wrapper, `BuilderDescriptor` as the typed builder surface, and `FileIO.load(...)` as compatibility-only.
**Depends on**: 1
**Positive contract**: Update the general user-facing story so the first code path and first narrative path use `read_lineages`. Show `read_lineages(path)` for Newick and alife file-backed sources, `read_lineages(io; ...)` where stream behavior is being explained, and `load_alife_table(...)` only in the in-memory Tables.jl section. If builder behavior is documented here, use `BuilderDescriptor` for the first-class typed story and move raw `builder = fn` into an explicit compatibility note. The alife runnable example should demonstrate both `read_lineages(path)` for file-backed alife input and `load_alife_table(...)` for the in-memory convenience wrapper.
**Negative contract**: Do not leave wrapper-first wording or FileIO-wrapper examples in the lead position. Do not describe `load_alife_table(...)` as compatibility-only or as the first-class file or stream surface. Do not document `TypedBuilderLoadRequest` or `canonical_load(...)` as public API. Do not imply any deprecations or removals.
**Files**: `README.md`, `docs/src/index.md`, `examples/src/alife_standard_mwe.jl`
**Out of scope**: `docs/src/phylonetworks.md`, extension-specific examples, new public behavior beyond the ratified names
**Verification**: Task 5 must be able to leave the docs build and `examples/src/alife_standard_mwe.jl` green. Manual docs review must make it obvious which surface is first-class, which is the in-memory convenience wrapper, and which remains compatibility-only.

Rewrite the general user story, not just isolated snippets. The task is complete only when a reader can identify the ownership boundary without inferring hidden policy from prior wrapper examples.

### 4. Synchronize the PhyloNetworks public docs and runnable examples

**Type**: WRITE
**Output**: `docs/src/phylonetworks.md`, `examples/src/phylonetworks_mwe01.jl`, and `examples/src/phylonetworks_mwe02.jl` use `read_lineages` as the primary package-owned public story while preserving explicit compatibility notes for retained wrappers.
**Depends on**: 1
**Positive contract**: Update the rooted-network, tree-compatible rooted, and supplied-target examples and docs so they lead with `read_lineages(path, HybridNetwork)` or `read_lineages(path, HybridNetwork())` as appropriate. Keep the authoritative-table retention story unchanged. Keep any mention of `FileIO.load(...)` explicitly labeled as compatibility-only. Preserve scope notes about rooted-network support, tree-compatible rooted support, explicit format override on `.txt`, synthesized leaf-name behavior, and no unrooted-network support.
**Negative contract**: Do not leave `load(path, HybridNetwork)` as the primary happy path. Do not remove the compatibility note entirely. Do not imply deprecations, removals, or broader extension-surface changes that were not ratified. Do not broaden extension scope while updating examples.
**Files**: `docs/src/phylonetworks.md`, `examples/src/phylonetworks_mwe01.jl`, `examples/src/phylonetworks_mwe02.jl`
**Out of scope**: core API code, MetaGraphsNext docs beyond the general docs touched in task 3, extension internals, public renames or deprecations
**Verification**: Task 5 must leave both PhyloNetworks example scripts green. Manual docs review must confirm that `read_lineages` is the first-class public path and `FileIO.load(...)` is clearly secondary and compatibility-only.

Keep the extension docs and examples aligned with the ratified ownership boundary, not just with legacy code snippets.

### 5. Add extension public-surface parity tests and close the green gates

**Type**: TEST
**Output**: Extension public-surface tests prove that `read_lineages` is the first-class package-owned public path for `HybridNetwork` and `MetaGraph` targets, retained wrappers stay thin, and the repository ends green.
**Depends on**: 2, 3, 4
**Positive contract**: Add direct public-surface parity tests for `read_lineages(path, HybridNetwork)`, `read_lineages(path, HybridNetwork())`, `read_lineages(path, MetaGraph)`, and `read_lineages(path, metagraph_instance)` on the same sources already covered by direct canonical-owner and retained-wrapper tests. Verify authoritative tables, basenode projection, graph materialization shape, extension-facing round-trip or traversal behavior, and source-specific data behavior such as retained gamma or MetaGraph weight semantics. Keep retained `FileIO.load(...)` and `load_alife_table(...)` tests green so wrappers remain supported and explicitly secondary.
**Negative contract**: Do not rely on docs-string checks, helper-only tests, or wrapper-only tests as the sole proof. Do not broaden the public API surface beyond `read_lineages` and `BuilderDescriptor` while adding these tests. Do not skip MetaGraphsNext coverage because it lacks a dedicated docs page.
**Files**: new `test/extensions/phylonetworks_public_surface.jl`, new `test/extensions/metagraphsnext_public_surface.jl`, `test/extensions/phylonetworks_canonical_owner.jl`, `test/extensions/metagraphsnext_canonical_owner.jl`, `test/runtests.jl`
**Out of scope**: public docs beyond the files touched in tasks 3 and 4, extension-core redesign, deprecations, removals, dependency changes
**Verification**: Run `julia --project=test test/runtests.jl`, `julia --project=docs docs/make.jl`, `julia --project=examples examples/src/alife_standard_mwe.jl`, `julia --project=examples examples/src/phylonetworks_mwe01.jl`, and `julia --project=examples examples/src/phylonetworks_mwe02.jl`. The old implementation must fail because there is no `read_lineages` surface to test. The tranche is complete only when all locks above are closed against real public behavior, not against helper-level proxies alone.

Finish by proving the new public surface and the retained wrappers can coexist honestly inside one green repository state.
