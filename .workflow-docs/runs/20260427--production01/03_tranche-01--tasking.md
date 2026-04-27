# Tasks for tranche 1: Simple Newick tables-only core foundation

Parent tranche: Tranche 1 (`02_tranches.md`)
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
  `edgeweight`, `rootnode`, `node_table`, `edge_table`, `LineageGraphAsset`,
  and `LineageGraphStore` exactly where those concepts are in scope
- write "root node" and "edge weight" in prose, but use `rootnode` and
  `edgeweight` for project-owned identifiers
- use `node` rather than `vertex`, `edge` rather than `branch` in code
  identifiers, and `leaf` rather than `tip`
- do not introduce proscribed alternates such as `node_idx`, `edge_idx`,
  `edgelength`, `root`, `root_node`, `fromnode`, `tonode`, or generic
  `vertex` terminology in project-owned identifiers

## Upstream primary sources

The following upstream primary sources constrain tranche 1 and must be read in
full before implementation:

- `fileio.jl/`
  Read at minimum the contract-bearing material in `src/types.jl`,
  `src/loadsave.jl`, `src/query.jl`, and `src/registry_setup.jl` so the
  implementation respects FileIO's `DataFormat`, `File`, `Stream`, detection,
  and backend-dispatch semantics.
- `Tables.jl`
  Read at minimum the installed Tables.jl interface documentation and source
  covering `Tables.istable`, `Tables.rowaccess`, `Tables.columnaccess`,
  `Tables.rows`, `Tables.columns`, `Tables.schema`, `Tables.getcolumn`,
  `Tables.columnnames`, and `Tables.materializer`, so the package-owned table
  types are genuinely Tables.jl-compliant.
- `Phylo.jl/`
  Read the simple-Newick parser and tests in `src/newick.jl` and
  `test/test_newick.jl` only for upstream structural reading expectations that
  help define simple rooted Newick behavior.
- `PhyloNetworks.jl/`
  Read the simple and extended Newick reader behavior in `src/readwrite.jl`
  and `test/test_relaxed_reading.jl` only where needed to distinguish tranche 1
  simple rooted Newick scope from later network-capable work.

When describing these upstream contracts downstream, distinguish verified
upstream fact from local inference.

## Current-state diagnosis

This repository is still in the scaffold state described by `design/02_tranches.md`.

Revalidated observations:

- `src/LineagesIO.jl` is a minimal module shell only
- no package-owned format modules, authoritative table types, lazy graph view
  types, parsing owners, or FileIO backend methods exist yet
- no representative Newick fixtures or end-to-end load tests exist yet
- the baseline repository is currently green:
  `julia --project=test test/runtests.jl` passes and
  `julia --project=docs docs/make.jl` builds

Because the owning layers do not yet exist, this tranche must establish the
foundational core owner rather than trying to stage extension or graph-building
behavior early.

## Ownership and invariant framing

Tranche 1 establishes the core owner for:

- `format"Newick"` phase 1 minimum-path ownership
- safe detection and explicit-override behavior for the supported tables-only
  Newick path
- package-owned authoritative source, collection, graph, node, and edge table
  types
- package-owned `LineageGraphAsset` and `LineageGraphStore` return types
- lazy graph iteration and graph/source coordinate carriage for tables-only
  loads

This tranche does not yet own:

- `bind_rootnode!`, `add_child`, or `finalize_graph!` graph-construction
  surfaces
- row-reference delivery contracts
- consumer-package materialization
- multi-parent or rooted-network behavior

Do not smuggle tranche 2 responsibilities into tranche 1 as a speculative
foundation. Fix the actual owner needed for tables-only loading and stop there.

## Authorization boundary

The user-authorized disruption boundary allows foundational establishment of
the core architecture because the current package is a scaffold.

Allowed in this tranche:

- clean internal source-layout design under `src/`
- package-owned table and return-type design
- package-owned simple rooted Newick parsing and FileIO integration for the
  tables-only path
- explicit error design for ambiguous bare loads

Not allowed in this tranche without further approval:

- external breaking changes beyond the contracts already ratified in the briefs
- extension modules under `ext/`
- graph-construction protocol implementation
- network-capable parsing behavior, `LineageNetwork`, `LineageGraphML`,
  `Nexus`, or serialization work

No standalone MIGRATE task is required for this tranche because there is no
existing implementation surface to migrate yet, but every task must preserve
later compatibility with the ratified core contracts and FileIO-ready loading
surfaces.

## Required revalidation before implementation

- Read this tranche and the four parent design briefs in full
- Read the relevant code, tests, docs, and examples in full:
  `src/LineagesIO.jl`, `Project.toml`, `test/runtests.jl`, `test/Project.toml`,
  `README.md`, `docs/src/index.md`, `docs/Project.toml`, and current files
  under `examples/`
- Read all cited upstream primary sources in full where they constrain the
  work
- Re-check the user-authorized disruption boundary before making deep changes
- Re-confirm that the repository starts green by running
  `julia --project=test test/runtests.jl`
- Re-run `julia --project=docs docs/make.jl` whenever public APIs or docs-owned
  usage surfaces are changed
- If the tranche diagnosis no longer matches reality, stop and raise that
  before changing code

## Tranche execution rule

The work may redesign, replace, or deeply refactor internals where authorized,
but it must begin and end in the tranche's required green, policy-compliant
state.

Every code-bearing task in this tranche must end with
`julia --project=test test/runtests.jl` passing for the repository state at
that checkpoint. Any task that changes docs-described public API or user-facing
loading surfaces must also end with `julia --project=docs docs/make.jl`
passing.

The implementation must preserve the tranche 1 scope boundary:

- `load(src)` must remain tables-only for this tranche
- returned graph assets must expose authoritative tables and
  `graph_rootnode === nothing`
- ambiguous bare loads must fail with an informative explicit-override error
  instead of guessing

## Tasks

### 1. Establish the tranche 1 source skeleton and fixture set

**Type**: WRITE
**Output**: `src/LineagesIO.jl` is reduced to imports and `include` calls;
the tranche-owned source files for core types, view/table ownership, Newick
format ownership, and FileIO integration exist under `src/`; representative
rooted simple-Newick fixtures for single-graph, multi-graph, and ambiguous-load
cases exist under `test/`
**Depends on**: none

Restructure the package so the module file remains a thin owner-level entry
point per `STYLE-julia.md`, and create the tranche 1 source layout needed for
later implementation without yet solving higher-tranche concerns. Touch
`src/LineagesIO.jl` and create the tranche-owned source files needed for core
types, package-owned table sources, lazy graph views, Newick parsing, and
FileIO bridging under `src/`. Add representative rooted simple-Newick fixture
files under `test/` for: one rooted tree, one multi-graph source, and one text
path whose extension is intentionally ambiguous for bare auto-detection. Keep
the naming consistent with the ratified vocabulary and with the tranche-owned
owner boundaries. Verify the repository remains green with
`julia --project=test test/runtests.jl`.

### 2. Implement package-owned companion table types and tables-only return types

**Type**: WRITE
**Output**: package-owned concrete `source_table`, `collection_table`,
`graph_table`, `node_table`, and `edge_table` types exist and satisfy Tables.jl;
`LineageGraphAsset` and `LineageGraphStore` exist with the ratified tranche 1
fields; `graphs` is a lazy iterator surface; `graph_rootnode` is `nothing` for
the tables-only path
**Depends on**: 1

Implement the package-owned authoritative table owner and the tables-only
return types. Touch the source files that own core types, table interfaces, and
view-layer return types under `src/`. The node table must carry `nodekey`,
`label`, and retained node annotations; the edge table must carry `edgekey`,
`src_nodekey`, `dst_nodekey`, `edgeweight`, and retained edge annotations; the
source, collection, and graph tables must own the summary and coordinate
surfaces required by the briefs. Make all table and return-type fields concrete
or concretized through type parameters, and implement genuine Tables.jl source
methods rather than ad hoc lookalikes. `LineageGraphAsset` must carry the
ratified coordinate and label fields together with `node_table`, `edge_table`,
`graph_rootnode`, and `source_path`. `LineageGraphStore` must always be the
`load` return type and expose lazy `graphs` iteration rather than eager graph
materialization. Verify with `julia --project=test test/runtests.jl`.

### 3. Verify table contracts, lazy graph views, and coordinate carriage with synthetic data

**Type**: TEST
**Output**: focused tests confirm Tables.jl compliance, required structural
fields, key-order behavior, lazy `graphs` iteration, and preservation of
`index`, `source_idx`, `collection_idx`, and `collection_graph_idx` without
requiring real parsing yet
**Depends on**: 2

Add targeted tests under `test/` for the package-owned table and view layer
before parser work begins. Use synthetic data to verify `Tables.istable`,
column access, schema exposure where provided, and field-level structural
content for the companion tables. Assert that node-table row order matches
`nodekey` order and edge-table row order matches `edgekey` order. Verify that
`LineageGraphStore.graphs` is a lazy iterator surface and that graph assets
retain source and collection coordinates exactly as ratified in the briefs.
These tests must prove the owner-level contracts directly rather than relying
on weak proxies such as "construction succeeded". End the task green with
`julia --project=test test/runtests.jl`.

### 4. Implement simple rooted Newick parsing and table assembly for tables-only loads

**Type**: WRITE
**Output**: a package-owned simple rooted Newick parser module reads tranche 1
inputs into authoritative node and edge tables, assigns `StructureKeyType`
keys, preserves raw labels and edge weights, assembles graph assets and store
coordinates, and rejects out-of-scope constructs instead of guessing
**Depends on**: 3

Implement the tranche 1 parser owner for simple rooted Newick only. Touch the
Newick format-owner files under `src/`, using the upstream `Phylo.jl` and
`PhyloNetworks.jl` readers only as contract references rather than as embedded
parsers. Parse simple rooted Newick into package-owned authoritative tables,
assign `nodekey` and `edgekey` sequentially per graph using
`StructureKeyType`, populate `src_nodekey`, `dst_nodekey`, `label`, and
`edgeweight`, and preserve graph/source coordinates into the returned assets and
store. Preserve retained annotations only where tranche 1 simple-Newick scope
actually supports them; reject out-of-scope or structurally ambiguous constructs
with informative errors instead of inventing payload bags or silently dropping
structure. Do not implement `bind_rootnode!`, `add_child`, row references, or
consumer-package materialization here. Verify with
`julia --project=test test/runtests.jl`.

### 5. Add end-to-end core parsing tests for tables-only Newick and graph coordinates

**Type**: TEST
**Output**: `test/core/newick_tables_only.jl` and
`test/core/graph_store_coordinates.jl` exist and verify field-level table
contents, structural keys, `graph_rootnode === nothing`, lazy iteration, and
coordinate retention for representative rooted simple-Newick inputs
**Depends on**: 4

Add direct end-to-end tests for the tables-only parsing owner using the tranche
fixtures. Touch `test/runtests.jl` and the new test files under `test/core/`.
Verify representative rooted simple-Newick loads at the field level: required
node and edge table columns, exact `nodekey`/`edgekey` assignments,
`src_nodekey`/`dst_nodekey` relationships, `edgeweight` values, blank-label
handling where applicable, and `graph_rootnode === nothing`. Add multi-graph
tests that confirm lazy iteration and source/collection coordinate carriage
without forcing eager graph allocation. These tests must fail for real contract
breaks, not merely confirm that a store object exists. End the task green with
`julia --project=test test/runtests.jl`.

### 6. Implement FileIO format ownership, safe detection, and explicit override surfaces

**Type**: WRITE
**Output**: `format"Newick"` is package-owned for the tranche 1 path; module-
owned FileIO backend behavior supports safe bare loads, `File{format"Newick"}`
loads, and `Stream{format"Newick"}(...)` loads; ambiguous bare loads raise an
informative explicit-override error instead of guessing
**Depends on**: 5

Implement the FileIO-facing owner for tranche 1 by touching the FileIO
integration and format-owner files under `src/`. Respect FileIO's module-owned
backend pattern: do not extend `FileIO.load` or `FileIO.save` directly. Make
the tranche 1 path work for `load("primates.nwk")` when auto-detection is safe,
`load(File{format"Newick"}(...))`, and `load(Stream{format"Newick"}(...))`.
Use the upstream FileIO contract sources to decide the package-owned strategy
for format ownership, query behavior, and any needed registration/bootstrap so
the current implementation works now without forcing a later redesign. For
ambiguous bare paths such as Newick content behind an unsafe extension, raise
an informative explicit-override error that directs callers to the
`File{format"Newick"}(...)` surface rather than silently guessing. End the task
green with `julia --project=test test/runtests.jl`.

### 7. Close tranche 1 with load-surface verification and scope-boundary review

**Type**: REVIEW
**Output**: `test/core/fileio_load_surfaces.jl` exists; the full test suite and
docs build pass; the implementation is reviewed to confirm tranche 1 stops at
tables-only loading and does not leak tranche 2 graph-construction or later
network/extension responsibilities into core
**Depends on**: 6

Add the direct verification for the three tranche-owned load surfaces and then
review the completed tranche against its scope boundary. Touch the load-surface
tests under `test/core/`, and update docs only if the public loading surfaces
or examples now need explicit coverage. Verify: `load("primates.nwk")`,
`load(File{format"Newick"}(...))`, and `load(Stream{format"Newick"}(...))`
return lazy `LineageGraphStore` results whose first graph asset exposes the
authoritative tables and `graph_rootnode === nothing`; ambiguous bare loads
raise the required explicit-override error; unaffected baseline behavior
remains green. Then perform a tranche-boundary review to ensure the code has
not introduced `bind_rootnode!`, `add_child`, row-reference contracts, weak
extension coupling, or multi-parent logic ahead of tranche 2 and tranche 6.
Finish with both `julia --project=test test/runtests.jl` and
`julia --project=docs docs/make.jl` passing.
