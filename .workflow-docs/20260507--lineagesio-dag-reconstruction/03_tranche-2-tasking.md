# Tasks for tranche 2: Single-parent construction protocol and annotation contract

Parent tranche: Tranche 2 from `../LineagesIO.jl-stash-20260503/closed/20260427--production01/02_tranches.md`
Parent PRD: `../LineagesIO.jl-stash-20260503/design/brief.md`, `../LineagesIO.jl-stash-20260503/design/brief--user-stories.md`, `../LineagesIO.jl-stash-20260503/design/brief--community-support-objectives.md`, `../LineagesIO.jl-stash-20260503/design/brief--community-support-user-stories.md`

## Settled user decisions and environment baseline

- This file is an approved reconstruction of the archived LineagesIO DAG tranche-2 handoff. It is meant to let a fresh agent deliver the historical tranche honestly.
- Current repository reality on 2026-05-07 is already beyond this tranche. Current HEAD contains row references, construction owners, supplied-basenode binding, rooted-network work, `read_lineages(...)`, and extension code. `julia --project=test test/runtests.jl` passes and `julia --project=docs docs/make.jl` builds successfully on current HEAD.
- Because current HEAD no longer matches the original tranche diagnosis, this file must not be executed blindly against current HEAD. The intended execution baseline is the pre-tranche-2 tables-only LineagesIO core from the archived DAG workflow.
- The historical execution baseline for this tranche is: bare `load(src)` returns authoritative tables only; there is no package-owned single-parent construction owner yet; there are no `NodeRowRef` or `EdgeRowRef` types yet; there is no supplied-basenode binding path yet; there is no `ext/` directory yet; there is no package-owned `read_lineages(...)` public surface yet.
- The docs truth boundary for this tranche is fixed: documentation must be updated to match the tranche-2 implementation, not the other way around. Do not broaden API surface to satisfy docs.
- The compatibility boundary for this tranche is fixed: preserve the tranche-1 tables-only `load(src)` contract exactly while adding new construction surfaces on top of the same authoritative tables.
- The public-surface boundary for this tranche is fixed: the allowed tranche-2 surfaces are `load(src)`, `load(src, NodeT)`, `load(src, basenode)`, and `load(src; builder = fn)`. Do not ratify `read_lineages(...)`, `BuilderDescriptor`, weak-dependency extension wiring, or rooted-network public wording in this tranche.
- The environment baseline remains package-project based. Do not introduce a `Manifest.toml`, path overrides, or hard dependencies that were not part of the original tranche scope.
- When local upstream checkouts exist under `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`, prefer those as primary-source paths instead of recollection or secondary summaries.

## Governance

Read every applicable governance and workflow document line by line before implementation, review, or delegation. Pass the same obligations forward explicitly in every downstream handoff.

All work from this file must comply with:

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
- `../LineagesIO.jl-stash-20260503/design/brief.md`
- `../LineagesIO.jl-stash-20260503/design/brief--user-stories.md`
- `../LineagesIO.jl-stash-20260503/design/brief--community-support-objectives.md`
- `../LineagesIO.jl-stash-20260503/design/brief--community-support-user-stories.md`
- `../LineagesIO.jl-stash-20260503/closed/20260427--production01/02_tranches.md`

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, branch creation, rebase, or reset remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Active authorities

- Repo-local authorities: `AGENTS.md`, `CONTRIBUTING.md`, all listed `STYLE*.md` files.
- Skill authorities: `development-policies`, `devflow-feature-03--tranche-to-tasks`.
- Parent workflow authorities: the archived DAG tranche file and the four archived design briefs listed above.
- Current-run revalidation authority: current repository code, tests, docs, and outputs as checked on 2026-05-07.

## Controlled vocabulary

All downstream work must preserve the controlled vocabulary in `STYLE-vocabulary.md` and the archived briefs.

In particular:

- use `StructureKeyType`, `nodekey`, `edgekey`, `src_nodekey`, `dst_nodekey`, `edgeweight`, `basenode`, `bind_basenode!`, `add_child`, `finalize_graph!`, `node_table`, `edge_table`, `NodeRowRef`, `EdgeRowRef`, `LineageGraphAsset`, and `LineageGraphStore` exactly where those concepts are in scope
- write "basenode" in prose, but use `basenode` for project-owned identifiers
- write "edge weight" in prose, but use `edgeweight` for project-owned identifiers
- use `node` rather than `vertex`, `edge` rather than `branch`, and `leaf` rather than `tip` in project-owned identifiers
- do not replace the ratified row-reference contract with payload-bag, metadata-bundle, copied-dictionary, or generated-field terminology
- do not use `read_lineages`, `BuilderDescriptor`, `weakdeps`, or extension-public terminology as if they were already part of the tranche-2 public contract

## Upstream primary sources

Read the following upstream primary sources in full before implementation. These are contract-bearing sources for this tranche, not optional background reading.

- `fileio.jl`
  Read `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/fileio.jl/src/types.jl`, `loadsave.jl`, `query.jl`, and `registry_setup.jl`.
  These sources constrain how `load(...)`, `File{format"..."}`, and `Stream{format"..."}` surfaces must remain FileIO-compatible.
- `Tables.jl`
  Read `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/Tables.jl/src/Tables.jl`.
  These sources constrain the `Tables.AbstractColumns`, `Tables.AbstractRow`, `Tables.schema`, `Tables.getcolumn`, and `Tables.columnnames` contracts that authoritative tables and row references must satisfy honestly.
- Julia `Pkg` package-extension documentation
  Read `/home/jeetsukumaran/.julia/juliaup/julia-1.12.6+0.x64.linux.gnu/share/julia/stdlib/v1.12/Pkg/docs/src/creating-packages.md`, especially the sections that define public API, weak dependencies, extensions, and extension behavior.
  Even though tranche 2 does not implement extensions, it must leave a core protocol that later extension tranches can own without reopening the builder boundary.
- Newick scope-discrimination sources
  Read only the locally available Newick parsing and test material needed to distinguish simple rooted-tree retained-annotation scope from later rooted-network and multi-parent work. Do not freeze later network semantics into this tranche.

When writing downstream instructions, distinguish verified upstream fact from local inference.

## Primary-goal lock

### Lock 1: bare `load(src)` stays tables-only

- The work is not complete if tranche 2 changes the tranche-1 `load(src)` path from authoritative tables only into graph materialization or any other new ownership model.
- Direct red-state repro: before tranche 2, bare `load(src)` is the only supported public surface and returns a `LineageGraphStore` whose graph assets expose authoritative `node_table` and `edge_table` with no materialized graph owner.
- Closed by tasks `6`, `8`, `9`, and `10`.
- Failing proof artifact: `test/core/newick_tables_only.jl`, `test/core/fileio_load_surfaces.jl`, and the asset-destructuring assertions in `test/core/construction_protocol_single_parent.jl` must fail any implementation that repurposes bare `load(src)` into a materializing path.

### Lock 2: one core single-parent construction owner exists

- The work is not complete if `load(src, NodeT)` is missing, if root and descendant construction happen through separate ad hoc surfaces, or if the protocol does not flow through `add_child(::Nothing, ...)`, `add_child(parent, ...)`, and `finalize_graph!`.
- Direct red-state repro: the tables-only baseline has no package-owned single-parent construction owner and no library-created-basenode materialization surface.
- Closed by tasks `2`, `6`, `8`, and `10`.
- Failing proof artifact: `test/core/construction_protocol_single_parent.jl` must fail the pre-tranche-2 state and any fake fix that special-cases one surface instead of repairing the owner.

### Lock 3: supplied-basenode binding is explicit and one-graph only

- The work is not complete if `load(src, basenode)` guesses across multi-graph sources, bypasses `bind_basenode!`, or silently falls back to library-created-basenode construction.
- Direct red-state repro: the tables-only baseline has no supplied-basenode binding path at all, and a fake fix could add a convenience path that guesses how to bind multi-graph sources.
- Closed by tasks `2`, `7`, `8`, and `10`.
- Failing proof artifact: `test/core/basenode_binding.jl` must fail any implementation that accepts a multi-graph source or does not route the root through `bind_basenode!`.

### Lock 4: row references are authoritative-table views, not copied payloads

- The work is not complete if `nodedata` or `edgedata` become copied dictionaries, `NamedTuple` payload bags, generated field structs, or any second annotation store that duplicates authoritative tables.
- Direct red-state repro: the pre-tranche-2 baseline has no row-reference owner, so a shallow implementation could invent a second builder-boundary payload model rather than making authoritative tables first class.
- Closed by tasks `2`, `3`, `6`, and `8`.
- Failing proof artifact: `test/core/row_references.jl` must fail if the implementation stops exposing the authoritative table schema and direct property access through row references.

### Lock 5: retained scalar annotations are preserved as raw text and bad shapes fail directly

- The work is not complete if supported scalar node or edge annotations are dropped, semantically coerced in core, renamed ad hoc, or silently flattened from unsupported structured forms.
- Direct red-state repro: the tables-only baseline rejects simple rooted Newick retained annotations instead of preserving them into authoritative tables.
- Closed by tasks `4`, `5`, and `10`.
- Failing proof artifact: `test/core/annotation_retention.jl` must fail the old parser state that rejected retained annotations outright, and it must fail fake fixes that coerce or flatten values.

### Lock 6: tranche 2 stays single-parent and core-owned

- The work is not complete if it introduces multi-parent `add_child`, rooted-network parsing, `ext/` modules, or consumer-package semantic coercion as part of the tranche-2 repair.
- Direct red-state repro: the historical tranche boundary explicitly reserved multi-parent, rooted-network, and extension work for later tranches.
- Closed by tasks `6`, `7`, `9`, and `10`.
- Failing proof artifact: final touched-file review plus unchanged absence of `ext/`, `Project.toml` weak-dependency work, and network-specific tests in the tranche diff must fail any implementation that smuggles later-phase work into this tranche.

### Lock 7: tranche 2 must not silently ratify later public-surface decisions

- The work is not complete if tranche 2 introduces `read_lineages(...)`, `BuilderDescriptor`, extension-owned public wording, or any other later-phase public surface redesign that the archived DAG workflow had not yet ratified at this point.
- Direct red-state repro: the archived tranche-2 contract names only the `load(...)` family of surfaces. A fake fix could use tranche-2 documentation or builder cleanup as an excuse to smuggle in later public-surface redesign.
- Closed by tasks `6`, `7`, `9`, and `10`.
- Failing proof artifact: docs review and diff review must fail any tranche-2 implementation that adds `read_lineages`, `BuilderDescriptor`, or weak-dependency public wording.

## Handoff packet

- Active authorities: `AGENTS.md`, `CONTRIBUTING.md`, the listed `STYLE*.md` files, the archived design briefs, the archived tranche file, and the current revalidation result from 2026-05-07.
- Parent documents: `../LineagesIO.jl-stash-20260503/closed/20260427--production01/02_tranches.md`; `../LineagesIO.jl-stash-20260503/design/brief.md`; `../LineagesIO.jl-stash-20260503/design/brief--user-stories.md`; `../LineagesIO.jl-stash-20260503/design/brief--community-support-objectives.md`; `../LineagesIO.jl-stash-20260503/design/brief--community-support-user-stories.md`.
- Settled decisions and non-negotiables: preserve bare `load(src)` as tables only; use authoritative tables plus row references as the only builder-boundary payload contract; keep retained annotation values as raw text in core; keep the tranche single-parent and core-owned; do not ratify `read_lineages(...)` or extension surfaces here.
- Authorization boundary: deep internal refactor inside core `src/` is allowed; `ext/`, rooted-network logic, multi-parent construction, weak-dependency wiring, and later public-surface redesign are not.
- Current-state diagnosis: the historical baseline is tables-only and lacks construction owners, row references, annotation retention, and basenode binding; current HEAD no longer matches this baseline and must trigger a stop if used directly.
- Primary-goal lock: locks `1` through `7` above.
- Direct red-state repros: no row references; no single-parent construction owner; no supplied-basenode binding; simple rooted Newick retained annotations rejected; bare `load(src)` is tables only.
- Owner and invariant under repair: the core LineagesIO load owner is being repaired so all single-parent construction surfaces share one authoritative-table-first contract and one normalized builder boundary.
- Exact files and surfaces in scope: `src/LineagesIO.jl`, `src/core_types.jl`, `src/tables.jl`, `src/views.jl`, `src/load_owner.jl`, `src/construction.jl`, `src/newick_format.jl`, `src/fileio_integration.jl`, `README.md`, `docs/src/index.md`, `test/runtests.jl`, `test/core/row_references.jl`, `test/core/annotation_retention.jl`, `test/core/construction_protocol_single_parent.jl`, `test/core/basenode_binding.jl`, `test/core/builder_callback.jl`, `test/core/error_paths.jl`, and the named fixtures under `test/fixtures/`.
- Exact files and surfaces out of scope: `ext/`, `Project.toml`, `test/Project.toml`, `src/alife_format.jl`, `src/read_lineages.jl`, `src/load_compat.jl` public-surface redesign beyond the historical `load(...)` family, `docs/src/phylonetworks.md`, `test/core/network_*`, `test/extensions/*`, `examples/src/phylonetworks_*`, and all rooted-network or multi-parent public wording.
- Required upstream primary sources: the exact `fileio.jl`, `Tables.jl`, and Julia `Pkg` paths listed above.
- Green-state gates: `julia --project=test test/runtests.jl` passes after each code-bearing task; `julia --project=docs docs/make.jl` passes once docs are updated; the added tests fail the known old or fake-fix shapes listed in the lock items.
- Stop conditions: stop immediately if the branch already contains row references, `src/load_owner.jl`, `src/construction.jl`, supplied-basenode binding, rooted-network tests, `read_lineages(...)`, or `ext/`; stop if a derivable design question remains unresolved; stop if the work would require multi-parent or extension scope to get green.

## Required revalidation before implementation

- Read this file, the archived tranche file, and the four archived design briefs in full.
- Read the relevant historical baseline code, tests, docs, and fixtures in full before changing anything.
- Read all listed governance documents line by line.
- Read all listed upstream primary sources in full before implementing contract-sensitive behavior.
- Re-check that the intended execution target is a historical pre-tranche-2 branch or equivalent baseline. If you are on current HEAD and it already contains row references, construction owners, `read_lineages(...)`, network tests, or `ext/`, stop and escalate instead of executing this file.
- Re-confirm that the baseline branch starts green with `julia --project=test test/runtests.jl`.
- Re-run `julia --project=docs docs/make.jl` once public docs are touched.
- If the historical tranche diagnosis no longer matches the actual target branch, stop and rewrite the tasking instead of forcing the old framing onto new reality.

## Tranche execution rule

This tranche may introduce new core source files and deeply refactor internal load orchestration where needed, but it must begin and end in a green, policy-compliant state for the intended historical baseline.

Every code-bearing task must end with `julia --project=test test/runtests.jl` passing for that checkpoint. Any task that changes docs-described public surfaces must also end with `julia --project=docs docs/make.jl` passing.

The tranche must preserve all of the following throughout execution:

- bare `load(src)` remains the tables-only path
- all construction paths reuse the same authoritative `node_table` and `edge_table`
- retained annotations remain raw text in core authoritative tables
- basenode-binding failure for multi-graph sources is explicit, not guessed
- no later-phase public-surface redesign is smuggled in

## Non-negotiable execution rules

- Do not recreate authoritative-table access through a second copied payload store.
- Do not solve retained-annotation needs by semantically coercing values in core.
- Do not introduce multi-parent `add_child` in this tranche.
- Do not introduce rooted-network parsing, `gamma` semantics, or network fixtures beyond what is needed to reject out-of-scope scope creep.
- Do not add `ext/`, `[weakdeps]`, `[extensions]`, or extension-public documentation here.
- Do not broaden the API surface to `read_lineages(...)`, `BuilderDescriptor`, or other later-phase names.
- Do not weaken the tranche-1 tables-only contract merely to make builder or basenode tests pass.
- Do not accept verification that proves only helper behavior when a public-surface regression is available.

## Concrete anti-patterns or removal targets

- alternative builder-boundary payload bags such as copied dictionaries, per-node metadata bundles, or generated annotation field structs
- compatibility fallbacks that route supplied-basenode requests through guessed library-created-basenode behavior
- parser behavior that rejects all retained annotations even after row references are introduced
- parser behavior that silently flattens structured retained annotations instead of rejecting them
- doc wording that presents later-phase extension or `read_lineages(...)` surfaces as if tranche 2 already delivered them
- source-text-only or grep-only checks used in place of contract-level regression tests

## Failure-oriented verification

- `test/core/row_references.jl` must fail the pre-tranche-2 state that lacks `NodeRowRef` and `EdgeRowRef`.
- `test/core/annotation_retention.jl` must fail the old parser state that rejects retained `[` annotations outright.
- `test/core/construction_protocol_single_parent.jl` must fail any implementation that does not emit root and descendant construction through the package-owned single-parent protocol owner.
- `test/core/basenode_binding.jl` must fail any implementation that accepts a multi-graph source for supplied-basenode binding.
- `test/core/error_paths.jl` must fail implementations that omit informative fallback errors for unsupported `bind_basenode!`, `add_child`, or incompatible `builder` combinations.
- `test/core/newick_tables_only.jl` and `test/core/fileio_load_surfaces.jl` must fail any implementation that changes bare `load(src)` from tables-only behavior.
- `julia --project=docs docs/make.jl` must fail any docs drift introduced by the tranche-2 API additions.
- Final review must inspect touched files and fail any implementation that introduces `ext/`, `Project.toml` extension wiring, `read_lineages(...)`, `BuilderDescriptor`, or rooted-network public wording in this tranche.

## Tasks

### 1. Establish the tranche 2 source skeleton and fixture set

**Type**: WRITE
**Output**: `src/load_owner.jl` and `src/construction.jl` exist and are included from `src/LineagesIO.jl`; representative annotated rooted-tree, invalid-annotation, and multi-graph basenode-binding fixtures exist under `test/fixtures/`
**Depends on**: none
**Positive contract**: the repository has the tranche-owned source layout and fixture inventory needed for protocol ownership without changing public behavior yet.
**Negative contract**: this task must not implement construction behavior, extension wiring, rooted-network logic, or docs-surface changes under the label of "scaffolding".
**Files**: `src/LineagesIO.jl`, `src/load_owner.jl`, `src/construction.jl`, `test/fixtures/annotated_simple_rooted.nwk`, `test/fixtures/invalid_annotation_structured.nwk`, `test/fixtures/multi_graph_basenode_binding_source.trees`
**Out of scope**: `ext/`, `Project.toml`, `test/Project.toml`, `src/alife_format.jl`, `docs/src/index.md`, `README.md`, `test/core/network_*`, `test/extensions/*`
**Verification**: run `julia --project=test test/runtests.jl`; inspect that bare `load(src)` behavior is unchanged and that the new files are included cleanly without public-surface drift.

Create the tranche-owned source layout needed for protocol ownership while preserving the tranche-1 tables-only owner boundary. Add the three named fixtures with content that matches the parent brief's scope: one annotated rooted simple-Newick tree, one invalid structured retained-annotation case that must eventually fail informatively, and one multi-graph source used to reject supplied-basenode binding. Keep naming aligned with the controlled vocabulary and the tranche-1 fixture patterns already used in the repository. Do not touch docs or public API wording in this task.

### 2. Implement row references, protocol fallbacks, and generic property lookup

**Type**: WRITE
**Output**: package-owned `NodeRowRef`, `EdgeRowRef`, `bind_basenode!` fallback, `add_child` fallback, `finalize_graph!`, `node_property`, and `edge_property` own the builder-boundary contract centrally
**Depends on**: `1`
**Positive contract**: row references point into authoritative tables by structural key and `node_property` and `edge_property` work over both tables and row references.
**Negative contract**: this task must not introduce copied annotation payloads, field-style generated accessors, consumer-specific coercion, or multi-parent protocol shapes.
**Files**: `src/core_types.jl`, `src/tables.jl`, `src/views.jl`, `src/load_owner.jl`, `src/construction.jl`
**Out of scope**: `src/newick_format.jl`, `src/fileio_integration.jl`, docs, fixtures, `ext/`, multi-parent support
**Verification**: run `julia --project=test test/runtests.jl`; confirm locally that missing-row and missing-property failures are informative and that row-reference lookup uses the authoritative table schema directly.

Implement the package-owned single source of truth for row references and generic property lookup. `NodeRowRef` and `EdgeRowRef` must carry the authoritative table and the relevant structural key, not copied values. The default `finalize_graph!` must be a no-op owner-level hook. The default `bind_basenode!` and `add_child` fallbacks must fail informatively so later consumers and user-defined node handles have one obvious contract owner. Extend the lookup helpers so row-reference access is the same contract as direct table access.

### 3. Add focused row-reference contract tests

**Type**: TEST
**Output**: synthetic-data tests prove row references preserve structural keys, expose authoritative table schema and column names, and fail informatively on bad keys and missing properties
**Depends on**: `2`
**Positive contract**: the tests fail the pre-tranche-2 state where row references do not exist and they directly exercise the real table/row boundary.
**Negative contract**: the tests must not accept "row reference object can be constructed" as proof; they must fail any fake fix that swaps in copied payloads or drifts away from the authoritative table schema.
**Files**: `test/core/row_references.jl`, `test/runtests.jl`
**Out of scope**: parser changes, fixture updates, builder or basenode end-to-end tests, docs
**Verification**: run `julia --project=test test/runtests.jl`; verify that the new test file would fail if `NodeRowRef` and `EdgeRowRef` stopped exposing `Tables.schema`, `Tables.columnnames`, and direct property access through the authoritative table.

Add focused synthetic tests over `NodeTable` and `EdgeTable` data. Verify the row-reference structural keys, schema identity, column names, direct `Tables.getcolumn` behavior, parity with direct table lookup through `node_property` and `edge_property`, and informative failures for unknown keys and unknown retained fields. Keep this test narrowly scoped to the row-reference contract; do not overlap it with parser or end-to-end construction coverage.

### 4. Extend simple rooted Newick parsing for retained scalar annotations

**Type**: WRITE
**Output**: simple rooted Newick parsing retains supported scalar node and edge annotations as raw `Union{Nothing, String}` values under source field names in authoritative tables and rejects unsupported structured shapes with source-located errors
**Depends on**: `3`
**Positive contract**: row references now expose real retained fields from authoritative tables instead of an annotation-free parser result.
**Negative contract**: this task must not semantically coerce retained values, flatten unsupported structured shapes, introduce multi-parent parsing, or encode rooted-network semantics.
**Files**: `src/newick_format.jl`, `src/tables.jl`, `src/core_types.jl` if needed only for annotation typing support
**Out of scope**: `ext/`, `src/alife_format.jl`, `src/fileio_integration.jl`, docs, rooted-network tests, extension wording
**Verification**: run `julia --project=test test/runtests.jl`; directly load the annotated fixture and confirm retained columns appear in authoritative tables; directly load the invalid structured-annotation fixture and confirm it fails with a source-located error.

Extend the package-owned simple rooted Newick parser so it honestly owns retained scalar annotations needed by the row-reference contract. Preserve source field names, preserve raw text values, keep structural key ordering intact, and reject any retained annotation shape that cannot be represented as one scalar field on one node or one edge. This task must repair the parser owner rather than layering builder-side annotation workarounds on top of an annotation-free table owner.

### 5. Add annotation-retention regressions without tables-only drift

**Type**: TEST
**Output**: regression tests prove retained-field columns and raw values exist in `node_table` and `edge_table`, while bare `load(src)` still returns tables-only assets
**Depends on**: `4`
**Positive contract**: the tests fail the old parser state that rejected retained annotations outright and they prove the tranche-1 tables-only surface still tells the truth.
**Negative contract**: the tests must not bless fixes that parse numbers in core, move annotations into copied payload stores, or materialize graph handles on the bare load path.
**Files**: `test/core/annotation_retention.jl`, `test/runtests.jl`
**Out of scope**: builder tests, basenode tests, docs, extension tests, rooted-network tests
**Verification**: run `julia --project=test test/runtests.jl`; confirm the bare load path still gives `graph === nothing` and `basenode === nothing` while the retained columns and values are present in authoritative tables.

Use the annotated rooted-tree fixture to assert exact retained node and edge columns, exact raw text values, and the unchanged tables-only load surface. Use the invalid structured-annotation fixture to assert explicit failure rather than silent flattening. Keep the regression focused on contract-level user-visible behavior: authoritative tables, retained-field names, raw values, and honest failure for unsupported retained annotation shapes.

### 6. Implement library-created-basenode construction and builder orchestration

**Type**: WRITE
**Output**: `load(src, NodeT)` and `load(src; builder = fn)` execute through one shared single-parent construction owner that reuses authoritative tables, row references, and `finalize_graph!`
**Depends on**: `5`
**Positive contract**: root creation uses `add_child(::Nothing, ...)`, descendant creation uses single-parent `add_child(parent, ...)`, authoritative `NodeRowRef` and `EdgeRowRef` values cross the public boundary, and the resulting materialized value is attached without changing the authoritative tables.
**Negative contract**: this task must not create a second builder-boundary payload model, extension-private public types, multi-parent shapes, or later-phase public surfaces such as `read_lineages(...)` or `BuilderDescriptor`.
**Files**: `src/LineagesIO.jl`, `src/load_owner.jl`, `src/construction.jl`, `src/newick_format.jl`, `src/fileio_integration.jl`, `src/views.jl`
**Out of scope**: `ext/`, `Project.toml`, `src/read_lineages.jl`, `src/alife_format.jl`, docs, rooted-network parsing
**Verification**: run `julia --project=test test/runtests.jl`; exercise `load(src, NodeT)` with a representative custom node handle and confirm protocol event order, authoritative-table reuse, and successful `finalize_graph!`.

Implement one owner-level orchestration path for library-created-basenode materialization. The explicit `builder = fn` surface must remain a thin convenience wrapper over the same construction events instead of becoming a separate construction model. Preserve the tranche-1 tables-only path unchanged. If the builder callback shape is still materially ambiguous after revalidation on the historical baseline, stop and escalate rather than inventing a second model that later tranches would need to undo.

### 7. Implement supplied-basenode binding and one-graph validation

**Type**: WRITE
**Output**: `load(src, basenode)` binds the parsed basenode through `bind_basenode!`, rejects multi-graph sources and invalid builder combinations informatively, and reuses the same construction owner as task `6`
**Depends on**: `6`
**Positive contract**: supplied-basenode loads work only for exactly one graph and the root is bound through the package-owned `bind_basenode!` contract before descendant construction continues.
**Negative contract**: this task must not guess across multi-graph sources, silently fall back to library-created-basenode behavior, or allow a mixed `builder` plus `basenode` ownership model.
**Files**: `src/load_owner.jl`, `src/construction.jl`, `src/newick_format.jl`, `src/fileio_integration.jl`, `src/views.jl`
**Out of scope**: multi-parent binding, rooted-network behavior, docs, `ext/`, `Project.toml`, later public-surface redesign
**Verification**: run `julia --project=test test/runtests.jl`; directly verify success on the annotated one-graph rooted-tree fixture and direct failure on `test/fixtures/multi_graph_basenode_binding_source.trees`.

Implement supplied-basenode binding as the same core owner, not as a sibling convenience path. Validate the one-graph requirement as early as the architecture allows, and make the failure direct and informative instead of letting parse work proceed and then guessing how multiple graphs should bind to one basenode. Reject incompatible `builder` combinations explicitly so the builder boundary remains singular and honest.

### 8. Add end-to-end single-parent construction, basenode-binding, builder, and error-path tests

**Type**: TEST
**Output**: end-to-end regressions prove stable structural keys, protocol event order, retained annotation access through row references, finalization, and informative error paths for the historical tranche-2 load surfaces
**Depends on**: `7`
**Positive contract**: the tranche has direct regressions for each supported construction surface and each main failure boundary.
**Negative contract**: the tests must not rely on suite green alone; they must fail old and fake-fix implementations that skip row references, skip `bind_basenode!`, guess across multi-graph basenode loads, or invent copied payloads.
**Files**: `test/core/construction_protocol_single_parent.jl`, `test/core/basenode_binding.jl`, `test/core/builder_callback.jl`, `test/core/error_paths.jl`, `test/runtests.jl`
**Out of scope**: `test/core/network_*`, `test/extensions/*`, docs, extension fixtures, rooted-network public wording
**Verification**: run `julia --project=test test/runtests.jl`; confirm these regressions would fail if `nodedata` and `edgedata` were not authoritative row references or if supplied-basenode binding accepted multi-graph inputs.

Use representative custom node-handle types that implement `add_child`, `bind_basenode!`, and `finalize_graph!`. Assert exact `nodekey`, `edgekey`, `label`, `edgeweight`, `nodedata`, and `edgedata` behavior through the public boundary. Verify builder callback parity with the owner-level construction path, verify multi-graph supplied-basenode rejection, and verify informative fallback errors for unsupported or incompatible construction targets.

### 9. Synchronize public docs with the tranche-2 `load(...)` surfaces

**Type**: WRITE
**Output**: `README.md` and `docs/src/index.md` describe the tranche-2-era public load surfaces accurately and distinguish tables-only loads from construction loads without leaking later-phase API decisions
**Depends on**: `8`
**Positive contract**: docs tell the truth about `load(src)`, `load(src, NodeT)`, `load(src, basenode)`, and `load(src; builder = fn)` as they exist at the end of historical tranche 2.
**Negative contract**: this task must not broaden the API to match docs, introduce `read_lineages(...)` or `BuilderDescriptor`, or advertise extension or rooted-network work as if tranche 2 delivered it.
**Files**: `README.md`, `docs/src/index.md`
**Out of scope**: `docs/src/phylonetworks.md`, `ext/`, `Project.toml`, `test/extensions/*`, `src/read_lineages.jl`, rooted-network examples
**Verification**: run `julia --project=docs docs/make.jl` and `julia --project=test test/runtests.jl`; manually inspect that docs still distinguish bare tables-only loads from construction surfaces and do not claim later public-surface work.

Update the public docs only after the implementation is settled. The docs must preserve the distinction between authoritative tables-only loads and construction loads on top of those same tables. Keep wording strictly within the historical tranche-2 public boundary. If a doc example or sentence appears to require later-phase public-surface names to read cleanly, change the doc wording rather than broadening the implementation.

### 10. Close tranche 2 with scope-boundary review and full green verification

**Type**: REVIEW
**Output**: a read-only closure pass confirms the tranche repaired the owning layer, preserved scope boundaries, satisfied every lock item, and left the historical baseline green
**Depends on**: `9`
**Positive contract**: the closure pass verifies completion by lock item and green-state gate rather than by changed-file count.
**Negative contract**: this review must not sign off based only on suite green, and it must fail any surviving shadow payload path, later-phase public-surface drift, or smuggled extension/network work.
**Files**: none for the review itself; if the review finds drift, reopen the owning task instead of patching ad hoc here
**Out of scope**: new feature work, extension scaffolding, rooted-network implementation, public-surface redesign beyond the ratified tranche boundary
**Verification**: run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`; review the final diff against locks `1` through `7`, the in-scope file list, and the stop conditions in the handoff packet.

Review the completed tranche against the real owner and scope boundary, not just against local intuition. Confirm that bare `load(src)` remains tables only, that construction surfaces share one owner, that row references are authoritative-table views, that retained annotations are raw text in core, that supplied-basenode binding is one-graph only, and that no later-phase public surfaces or extension work were smuggled in. If any lock item could still survive behind a green suite, the tranche is not complete.
