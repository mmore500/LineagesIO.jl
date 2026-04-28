# Tasks for tranche 2: Single-parent construction protocol and annotation contract

Parent tranche: Tranche 2 (`02_tranches.md`)
Parent PRD: `design/brief.md`, `design/brief--user-stories.md`, `design/brief--community-support-objectives.md`, `design/brief--community-support-user-stories.md`

## Governance

All tasks must comply with the following governance documents. Read each one
line by line before planning, implementing, reviewing, or delegating work from
this file. This obligation must be passed forward into every downstream task or
agent handoff.

All tasks must comply with:

- `CONTRIBUTING.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-writing.md`
- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, and branch remain the human project owner's
responsibility unless the user explicitly instructs otherwise.

## Controlled vocabulary

All downstream work must preserve the controlled vocabulary already ratified in
`STYLE-vocabulary.md` and the governing briefs.

In particular:

- use `StructureKeyType`, `nodekey`, `edgekey`, `src_nodekey`, `dst_nodekey`,
  `edgeweight`, `rootnode`, `bind_rootnode!`, `add_child`,
  `finalize_graph!`, `node_table`, `edge_table`, `NodeRowRef`, `EdgeRowRef`,
  `LineageGraphAsset`, and `LineageGraphStore` exactly where those concepts
  are in scope
- write "root node" in prose, but use `rootnode` for project-owned identifiers
- write "edge weight" in prose, but use `edgeweight` for project-owned
  identifiers
- use `node` rather than `vertex`, `edge` rather than `branch` in code
  identifiers, and `leaf` rather than `tip`
- do not introduce proscribed alternates such as `root`, `root_node`,
  `node_idx`, `edge_idx`, `edgelength`, `payload`, or extension-local
  builder-boundary bag terminology in place of the ratified row-reference
  contract

## Upstream primary sources

The following upstream primary sources constrain tranche 2 and must be read in
full before implementation:

- `fileio.jl/`
  Read at minimum the contract-bearing material in `src/types.jl`,
  `src/loadsave.jl`, `src/query.jl`, and `src/registry_setup.jl` so the new
  load surfaces remain FileIO-compatible and do not bypass FileIO ownership.
- `Tables.jl`
  Read at minimum the installed Tables.jl interface documentation and source
  covering `Tables.AbstractColumns`, `Tables.AbstractRow`, `Tables.rows`,
  `Tables.columns`, `Tables.schema`, `Tables.getcolumn`, and
  `Tables.columnnames`, so authoritative tables and row references remain
  genuinely Tables.jl-compatible and direct post-load retention remains honest.
- Julia package-extension and weak-dependency primary sources
  Read the Julia `Pkg` documentation section on conditional loading of code in
  `Pkg/docs/src/creating-packages.md`, especially the `[weakdeps]`,
  `[extensions]`, and "Behavior of extensions" sections, because tranche 2
  establishes the core public protocol that later extension modules will own
  methods against.
- `Phylo.jl/`
  Read the upstream Newick parsing and tests only where needed to verify
  simple rooted Newick structural reading expectations and retained-field
  boundary decisions that affect annotation retention.
- `PhyloNetworks.jl/`
  Read the simple and extended Newick reader behavior only where needed to
  distinguish tranche 2 simple rooted-tree annotation retention from later
  multi-parent and rooted-network work.

When describing these upstream contracts downstream, distinguish verified
upstream fact from local inference.

## Current-state diagnosis

This repository is no longer a pure scaffold. Tranche 1 has established a
tables-only simple rooted Newick owner, and that baseline was revalidated on
2026-04-27 by running `julia --project=test test/runtests.jl`.

Revalidated observations:

- `src/LineagesIO.jl`, `src/core_types.jl`, `src/tables.jl`, `src/views.jl`,
  `src/newick_format.jl`, and `src/fileio_integration.jl` implement the
  tranche 1 tables-only core path
- authoritative `SourceTable`, `CollectionTable`, `GraphTable`, `NodeTable`,
  `EdgeTable`, `LineageGraphAsset`, and `LineageGraphStore` owners exist and
  are covered by tranche 1 tests
- the public load path currently supports only tables-only `load(src)`,
  explicit FileIO override, and stream-based loads; there are no construction
  protocol load surfaces yet
- there are no package-owned `bind_rootnode!`, `add_child`, or
  `finalize_graph!` protocol owners, no `NodeRowRef` or `EdgeRowRef` types,
  no builder-callback orchestration, and no root-binding validation path yet
- the simple rooted Newick parser still rejects retained annotations when it
  encounters `[` comments or annotation-like constructs, so tranche 2 must add
  the first honest retained-annotation path rather than pretending row
  references are useful without retained fields

Because the tables-only owner already exists, tranche 2 must establish the
single-parent construction owner on top of that foundation without regressing
the tranche 1 `load(src)` contract.

## Ownership and invariant framing

Tranche 2 establishes the core owner for:

- single-parent graph materialization over authoritative core tables
- `bind_rootnode!`, `add_child`, and `finalize_graph!` as public core protocol
  functions
- package-owned `NodeRowRef` and `EdgeRowRef` delivery at the builder boundary
- `load(src, NodeT)`, `load(src, rootnode::NodeT)`, and `load(src; builder=fn)`
  as alternate load surfaces over the same core protocol
- retained simple-Newick scalar annotation extraction into authoritative tables
  so row references expose real retained values
- validation of root-binding and builder compatibility before construction work
  where possible

This tranche does not yet own:

- multi-parent `add_child` protocol behavior
- rooted-network parsing or network annotation semantics such as `gamma`
- extension modules under `ext/`
- consumer-package projection logic or package-specific semantic coercion

Do not solve later extension or network problems speculatively inside tranche
2. Repair the core owner needed by the single-parent construction tier and stop
there.

## Authorization boundary

The user-authorized disruption boundary allows foundational establishment of
the core construction architecture because the current package is still in
early implementation and tranche 2 is explicitly foundational.

Allowed in this tranche:

- new core source files or source-file restructuring under `src/`
- new package-owned protocol types and protocol functions
- expansion of simple rooted Newick parsing to retain scalar annotations needed
  by the core contract
- new tests, fixtures, and docs updates for the newly ratified load surfaces
- deep internal refactor where needed to create one owner for tables, row
  references, and single-parent construction

Not allowed in this tranche without further approval:

- external breaking changes to the tranche 1 `load(src)` tables-only path
- extension modules under `ext/`
- multi-parent construction or rooted-network parsing
- `LineageNetwork`, `LineageGraphML`, `Nexus`, `TskitTrees`, or serialization
  work
- target-package-specific annotation semantics in core

No standalone MIGRATE task is required for tranche 2, because the work should
be additive over the tranche 1 baseline. Every task must preserve the existing
tables-only path while adding the new protocol load surfaces.

## Required revalidation before implementation

- Read this tranche and the four parent design briefs in full
- Read the relevant code, tests, docs, and examples in full:
  `src/LineagesIO.jl`, `src/core_types.jl`, `src/tables.jl`, `src/views.jl`,
  `src/newick_format.jl`, `src/fileio_integration.jl`, `test/runtests.jl`,
  all existing files under `test/core/`, `README.md`, `docs/src/index.md`, and
  any current files under `examples/`
- Read all cited upstream primary sources in full where they constrain the
  work
- Re-check the user-authorized disruption boundary before making deep changes
- Re-confirm that the repository starts green by running
  `julia --project=test test/runtests.jl`
- Re-run `julia --project=docs docs/make.jl` whenever public APIs or docs-owned
  usage surfaces are changed
- If the tranche diagnosis no longer matches reality, stop and raise that
  before changing code
- If the parent brief still leaves the explicit builder callback shape
  materially ambiguous after revalidation, stop and raise that before exporting
  a public callback surface rather than inventing one ad hoc

## Tranche execution rule

The work may redesign, replace, or deeply refactor internals where authorized,
but it must begin and end in the tranche's required green, policy-compliant
state.

Every code-bearing task in this tranche must end with
`julia --project=test test/runtests.jl` passing for the repository state at
that checkpoint. Any task that changes docs-described public API or user-facing
loading surfaces must also end with `julia --project=docs docs/make.jl`
passing.

The implementation must preserve the tranche 2 scope boundary:

- `load(src)` must remain the tables-only path and must continue to return
  authoritative tables with `graph_rootnode === nothing`
- all construction paths must reuse the same authoritative tables and
  row-reference contract rather than inventing alternative payload stores
- retained annotations in core must remain raw text in authoritative tables;
  semantic coercion stays outside core
- root-binding surfaces must reject multi-graph sources informatively rather
  than guessing

## Tasks

### 1. Establish the tranche 2 source skeleton and annotated fixture set

**Type**: WRITE
**Output**: the tranche-owned protocol/orchestration source layout exists under
`src/`, included from `src/LineagesIO.jl`; representative annotated rooted
simple-Newick, multi-graph, and invalid-contract fixtures exist under
`test/fixtures/`
**Depends on**: none

Create the tranche 2 source layout needed for protocol ownership without yet
changing public behavior. Touch `src/LineagesIO.jl` and create the tranche-owned
source files needed for protocol types and construction orchestration under
`src/`, while preserving the tranche 1 tables-only owner boundaries. Add
representative fixtures under `test/fixtures/` for: an annotated rooted simple
Newick source, a multi-graph source used to verify invalid supplied-root loads,
and at least one invalid annotation or contract case that should fail
informatively. Keep naming aligned with the ratified vocabulary and the tranche
1 fixture set. End the task green with `julia --project=test test/runtests.jl`.

### 2. Implement row references, default protocol hooks, and generic lookup helpers

**Type**: WRITE
**Output**: package-owned `NodeRowRef` and `EdgeRowRef` exist; default
`finalize_graph!` exists; the core exposes informative protocol fallback
behavior; and `node_property` and `edge_property` work over both authoritative
tables and row references
**Depends on**: 1

Implement the package-owned builder-boundary types and convenience helpers.
Touch the core types, view/protocol, and table-lookup owner files under `src/`.
Add concrete `NodeRowRef` and `EdgeRowRef` types that point into
authoritative tables by structural key, add the package-owned default no-op
`finalize_graph!`, and add or refine informative failure behavior for
unsupported `bind_rootnode!` and `add_child` paths so later extensions and user
types have one clear contract owner. Extend `node_property` and `edge_property`
so they work directly over row references as well as tables. Do not introduce
copied annotation payloads or field-style sugar as a core contract. End the
task green with `julia --project=test test/runtests.jl`.

### 3. Verify row-reference and lookup contracts with synthetic data

**Type**: TEST
**Output**: focused tests prove row references preserve structural keys, read
through authoritative tables, and surface retained fields and missing-property
errors directly
**Depends on**: 2

Add targeted tests under `test/core/row_references.jl` and wire them into
`test/runtests.jl`. Use synthetic `NodeTable` and `EdgeTable` data to verify
that row references preserve the expected `nodekey` and `edgekey`, that lookup
helpers over row references return the same values as direct table lookups, and
that missing-property and missing-row errors remain informative. These tests
must verify the actual contract boundary rather than merely proving that a row
reference object can be constructed. End the task green with
`julia --project=test test/runtests.jl`.

### 4. Extend simple rooted Newick parsing for retained scalar annotations

**Type**: WRITE
**Output**: the simple rooted Newick owner retains supported scalar node and
edge annotation text into authoritative tables, preserves source field names,
and rejects unsupported or unrepresentable annotation constructs informatively
**Depends on**: 3

Extend the package-owned simple rooted Newick parser so tranche 2 row
references expose real retained fields. Touch `src/newick_format.jl` and any
supporting table or core-type owners that need changes for authoritative field
assembly. Re-read the governing briefs and upstream parser references before
choosing which annotation forms belong to the tranche 2 simple rooted Newick
scope. Preserve retained values as raw `Union{Nothing, String}` text under
source field names, preserve existing structural-key ordering guarantees, and
raise informative source-located errors for complex or out-of-scope annotation
forms rather than silently flattening them. Do not add semantic coercion,
multi-parent behavior, or extension-owned meaning here. End the task green with
`julia --project=test test/runtests.jl`.

### 5. Verify annotation retention without tables-only regressions

**Type**: TEST
**Output**: annotated-fixture tests prove retained-field columns are present in
authoritative tables, retained values remain raw text, and the existing
tables-only path still behaves exactly as tranche 1 ratified
**Depends on**: 4

Add focused annotation-retention tests under `test/core/` and integrate them
into `test/runtests.jl`. Use the new annotated simple-Newick fixture to verify
field-level node-table and edge-table contents, retained source field names,
and raw text values for representative fields such as `posterior` or
`bootstrap` where the fixture supplies them. Also assert that the same tables
remain available through the bare `load(src)` path and that `graph_rootnode`
stays `nothing` there. These tests must fail for the pre-tranche-2 parser state
that rejected retained annotations outright. End the task green with
`julia --project=test test/runtests.jl`.

### 6. Implement library-created-root materialization and builder-callback orchestration

**Type**: WRITE
**Output**: `load(src, NodeT)` and `load(src; builder=fn)` run through one
shared top-down single-parent construction owner that reuses authoritative
tables, row references, and `finalize_graph!`
**Depends on**: 5

Implement the core orchestration path for library-created-root materialization.
Touch the protocol owner files under `src/`, the Newick owner, the view/asset
owner, and FileIO integration as needed. Add one shared top-down pre-order
emission path that constructs the root through `add_child(::Nothing, ...)`,
constructs descendants through single-parent `add_child(parent, ...)`, hands
`NodeRowRef` and `EdgeRowRef` values through the public boundary, and stores the
returned root handle as `graph_rootnode` in the returned asset. The explicit
`builder=fn` path must remain a thin convenience surface over the same core
events rather than inventing a second builder-boundary payload model. If the
required callback shape remains materially ambiguous after revalidation, stop
and raise that instead of exporting an ad hoc callback API. End the task green
with `julia --project=test test/runtests.jl`.

### 7. Implement supplied-root binding and one-graph validation

**Type**: WRITE
**Output**: `load(src, rootnode::NodeT)` binds through `bind_rootnode!`,
rejects multi-graph sources and incompatible combinations informatively, and
preserves the existing tables-only path unchanged
**Depends on**: 6

Implement the supplied-root load surface on the same core owner rather than as
an alternative code path. Touch the protocol/orchestration owner files, the
Newick owner, the view/asset owner, and FileIO integration as needed. Ensure
that one-graph root binding is validated before construction begins where
possible, and that multi-graph sources fail informatively instead of guessing
how binding should work. Reject incompatible combinations such as a supplied
`rootnode` together with an explicit builder callback if that surface would
blur distinct ownership models. Preserve the tranche 1 bare-load behavior and
the shared authoritative tables across all paths. End the task green with
`julia --project=test test/runtests.jl`.

### 8. Add end-to-end single-parent construction, builder, and root-binding tests

**Type**: TEST
**Output**: end-to-end tests verify stable structural keys, protocol emission
order, retained annotation access through row references, finalization, and
informative contract failures for all tranche 2 load surfaces
**Depends on**: 7

Add the tranche-owned end-to-end tests named in the tranche plan:
`test/core/construction_protocol_single_parent.jl`,
`test/core/root_binding.jl`, `test/core/builder_callback.jl`, and
`test/core/error_paths.jl`. Use representative custom node-handle types that
implement `add_child`, `bind_rootnode!`, and any needed finalization behavior.
Verify field-level structural correctness for emitted `nodekey`, `edgekey`,
`label`, `edgeweight`, `nodedata`, and `edgedata` values; verify retained
annotation text is visible through row references during construction; verify
root-binding rejection on multi-graph sources; and verify other ratified error
paths directly rather than through loose proxies. End the task green with
`julia --project=test test/runtests.jl`.

### 9. Close tranche 2 with docs, full verification, and scope-boundary review

**Type**: REVIEW
**Output**: docs and public examples describe the tranche 2 load surfaces
accurately; tests and docs builds pass; and a final review confirms tranche 2
did not leak multi-parent, extension-owned, or shadow-payload behavior
**Depends on**: 8

Update `README.md` and `docs/src/index.md` so the documented public API matches
the implemented tranche 2 load surfaces and preserves the distinction between
tables-only loads and construction loads. Add any small example adjustments
needed under `examples/` only if those examples are actually used by the
repository. Run `julia --project=test test/runtests.jl` and
`julia --project=docs docs/make.jl`. Then review the result against the
ownership and scope boundary: tranche 2 must remain single-parent, core-owned,
table-backed, and extension-ready without introducing multi-parent logic,
consumer-package coupling, or alternative builder-boundary payload stores.
