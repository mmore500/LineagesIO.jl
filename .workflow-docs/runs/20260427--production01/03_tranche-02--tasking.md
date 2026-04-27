# Tasks for Tranche 2: Single-parent construction protocol and annotation contract

Parent tranche: Tranche 2 (`02_tranches.md`)
Parent PRD: `design/brief.md`, `design/brief--user-stories.md`,
`design/brief--community-support-objectives.md`,
`design/brief--community-support-user-stories.md`

## Governance

All tasks must comply with the following governance documents. Read each one
line by line before planning, implementing, reviewing, or delegating work from
this file. This obligation must be passed forward into every downstream task or
agent handoff.

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

All work must preserve the controlled vocabulary ratified in `STYLE-vocabulary.md`
and the governing briefs.

In particular:

- use `NodeRowRef`, `EdgeRowRef`, `bind_rootnode!`, `add_child`,
  `finalize_graph!`, `StructureKeyType`, `nodekey`, `edgekey`,
  `src_nodekey`, `dst_nodekey`, `edgeweight`, `rootnode`, `node_table`,
  `edge_table`, `nodedata`, `edgedata` exactly where those concepts are in scope
- do not introduce `node_idx`, `edge_idx`, `edgelength`, `root`, `root_node`,
  or generic `vertex` terminology in project-owned identifiers
- write "root node" and "edge weight" in prose; use `rootnode` and `edgeweight`
  in code identifiers

## Upstream primary sources

The following upstream primary sources constrain tranche 2 and must be read in
full where they apply before implementation:

- `fileio.jl/`
  Read `src/loadsave.jl` to confirm how positional args and keyword args
  are forwarded to backend `fileio_load` methods, so the new load surfaces
  are wired correctly.
- `Tables.jl/`
  Sufficient reading was done in tranche 1; re-read only if row-reference
  property access requires new Tables.jl interface points.

When describing upstream contracts downstream, distinguish verified upstream
fact from local inference.

## Current-state diagnosis

Tranche 1 is complete and merged. Confirmed current state:

- `src/core_types.jl` — type aliases only; no row-reference types yet
- `src/tables.jl` — package-owned table types with Tables.jl compliance; no
  row-reference helpers yet
- `src/views.jl` — `LineageGraphAsset`, `LineageGraphStore`,
  `GraphAssetIterator`, `node_property(table, key, prop)`,
  `edge_property(table, key, prop)`; `StoredGraph` has no `root_handle` field;
  `GraphAssetIterator` always produces `LineageGraphAsset{Nothing, ...}`
- `src/newick_format.jl` — tables-only parsing path only; no construction
  protocol emission
- `src/fileio_integration.jl` — `fileio_load(File{NewickFormat})` and
  `fileio_load(Stream{NewickFormat})` only; no positional `NodeT` or
  `rootnode` variants
- `src/LineagesIO.jl` — does not export `NodeRowRef`, `EdgeRowRef`,
  `bind_rootnode!`, `add_child`, or `finalize_graph!`
- no construction protocol file exists yet
- test suite is green

Because all owning layers are in their tranche 1 state, this tranche must
establish the construction protocol owner and all callers before extensions
and consumer packages can use them.

## Ownership and invariant framing

Tranche 2 establishes the core owner for:

- `NodeRowRef` and `EdgeRowRef` row-reference types
- `bind_rootnode!`, `add_child`, and `finalize_graph!` as the public
  single-parent construction protocol
- `node_property` and `edge_property` overloads that accept row references
  rather than explicit table + key pairs
- `StoredGraph` updated to carry a typed `root_handle` field
- `GraphAssetIterator` updated to produce correctly typed `LineageGraphAsset{NodeT}`
- Newick orchestration path that emits protocol calls when a `NodeT` or
  `rootnode` target is supplied
- FileIO load surfaces for `load(src, NodeT)`, `load(src, rootnode::NodeT)`,
  and `load(src; builder=fn)`
- Informative error when a caller supplies a rootnode to a multi-graph source

This tranche does not yet own:

- multi-parent `add_child` tier (tranche 6)
- extension modules (tranche 3 onward)
- `LineageNetwork` or `LineageGraphML` format parsing

## Authorization boundary

Allowed in this tranche:

- extending `StoredGraph` and `GraphAssetIterator` to carry typed root handles
- adding row-reference types and row-reference helpers alongside existing table
  types and helpers
- adding construction protocol stubs and implementations in core
- adding new `fileio_load` method signatures for the construction surfaces
- updating `newick_format.jl` to emit protocol calls on the construction path

Not allowed in this tranche without further approval:

- multi-parent `add_child` tier
- extension modules
- format additions beyond Newick
- breaking the existing tranche 1 tables-only load surfaces

## Required revalidation before implementation

- Read this tranche and all four parent design briefs in full
- Read `src/LineagesIO.jl`, `src/core_types.jl`, `src/tables.jl`, `src/views.jl`,
  `src/newick_format.jl`, `src/fileio_integration.jl` in full before editing any
- Read `test/runtests.jl`, `test/core/companion_tables.jl`,
  `test/core/newick_tables_only.jl`, `test/core/graph_store_coordinates.jl`,
  and `test/core/fileio_load_surfaces.jl` in full
- Read `fileio.jl/src/loadsave.jl` to verify how positional args are forwarded
  to backend functions
- Confirm that `julia --project=test test/runtests.jl` starts green
- If the tranche diagnosis no longer matches reality, stop and raise that before
  changing code

## Tranche execution rule

Every code-bearing task must end with `julia --project=test test/runtests.jl`
passing. Any task that changes docs-described public API or user-facing loading
surfaces must also end with `julia --project=docs docs/make.jl` passing.

The tranche 1 tables-only load path — `load(src)`, `load(File{...}(src))`,
`load(Stream{...}(io))` returning `LineageGraphStore` with
`graph_rootnode === nothing` — must remain green and unaffected throughout.

---

## Tasks

### 1. Add `NodeRowRef` and `EdgeRowRef` to core types

**Type**: WRITE
**Output**: `NodeRowRef{NodeTableT}` and `EdgeRowRef{EdgeTableT}` exist in
`src/core_types.jl`; `node_property` and `edge_property` overloads that accept
a row reference instead of an explicit table and key pair exist in `src/views.jl`;
`NodeRowRef` and `EdgeRowRef` are exported from `src/LineagesIO.jl`
**Depends on**: none

Add `NodeRowRef` and `EdgeRowRef` to `src/core_types.jl`. The concrete types must
match the ratified contracts in `design/brief.md`:

```julia
struct NodeRowRef{NodeTableT}
    table::NodeTableT
    nodekey::StructureKeyType
end

struct EdgeRowRef{EdgeTableT}
    table::EdgeTableT
    edgekey::StructureKeyType
end
```

Both fields must be concrete — do not use abstract or union field types. Both
types must be exported from `src/LineagesIO.jl`. Then add overloads to
`src/views.jl` for the two existing property helpers that accept a row reference
directly, delegating to the table-and-key forms already present:

```julia
node_property(nodedata::NodeRowRef, propertykey)
edge_property(edgedata::EdgeRowRef, propertykey)
```

These overloads must raise the same informative errors as the table-and-key
forms for missing columns or out-of-range keys. Do not change existing
`node_property` or `edge_property` signatures. Verify with
`julia --project=test test/runtests.jl`.

---

### 2. Test row-reference types and property helpers

**Type**: TEST
**Output**: `test/core/row_references.jl` exists, is included from
`test/runtests.jl`, and passes; tests verify that row references delegate
correctly to authoritative tables and that error paths fire for missing
fields and out-of-range keys
**Depends on**: 1

Add `test/core/row_references.jl` and include it from `test/runtests.jl` (before
the existing core test includes to preserve ordering). Using synthetic node and
edge tables from the tranche 1 fixtures or constructed inline, verify at the
field level:

- `node_property(NodeRowRef(node_table, 2), :label)` returns the same value as
  `node_property(node_table, 2, :label)`
- `edge_property(EdgeRowRef(edge_table, 1), :edgeweight)` returns the same value
  as `edge_property(edge_table, 1, :edgeweight)`
- property access on a row reference for a retained annotation column returns the
  expected `Union{Nothing, String}` value
- a row reference for a missing column raises `ArgumentError` with the same
  informative text as the direct table-and-key form
- a row reference with an out-of-range key raises `ArgumentError`

Do not test parsing or construction yet — these tests are purely for the
row-reference layer. End green with `julia --project=test test/runtests.jl`.

---

### 3. Define the single-parent construction protocol

**Type**: WRITE
**Output**: a new `src/construction_protocol.jl` file exists and is included
from `src/LineagesIO.jl`; `bind_rootnode!`, `add_child`, and `finalize_graph!`
are defined as public protocol stubs; all three are exported; a default no-op
`finalize_graph!` is provided
**Depends on**: 2

Create `src/construction_protocol.jl`. Include it from `src/LineagesIO.jl` after
the other source includes. Export `bind_rootnode!`, `add_child`, and
`finalize_graph!` from `src/LineagesIO.jl`.

Define the protocol stubs as documented in `design/brief.md`. The single-parent
`add_child` variant has two dispatch forms: root creation (parent is `Nothing`,
edgekey and edgeweight are `Nothing`) and single-parent descendant construction
(parent is `NodeT`, edgekey and edgeweight are structural). The two forms have
distinct signatures and must not be collapsed into one.

Provide a default `finalize_graph!` implementation that is a no-op:

```julia
function finalize_graph!(::Any, ::Any, ::Any)::Nothing
    return nothing
end
```

Do not provide default implementations of `bind_rootnode!` or `add_child` —
these are user-implementable protocol functions. Provide only the protocol-level
function stubs. Add a docstring to each public function that describes its role,
its expected return value, and which load surfaces it is called from. Verify
with `julia --project=test test/runtests.jl`.

---

### 4. Update `StoredGraph` and `GraphAssetIterator` for typed root handles

**Type**: WRITE
**Output**: `StoredGraph` carries a typed `root_handle` field; `GraphAssetIterator`
produces `LineageGraphAsset{NodeT}` with the correct `graph_rootnode` value; the
existing tables-only path is unaffected and still produces `graph_rootnode === nothing`
**Depends on**: 3

Read `src/views.jl` in full before editing. Update `StoredGraph` to add a
`root_handle::NodeT` field and a `NodeT` type parameter. Because `StoredGraph` is
a package-internal type (not exported), changing its field layout is not a
public contract break. Update the `GraphAssetIterator.Base.iterate` method to
pass `stored_graph.root_handle` as `graph_rootnode` when assembling the
`LineageGraphAsset`. Update `Base.eltype` on `GraphAssetIterator` to infer
`NodeT` from the element type of `stored_graphs`.

For the tables-only path, `root_handle` must be `nothing` and the returned
`LineageGraphAsset{Nothing, ...}` must be identical to the tranche 1 behavior.
Update the `LineageGraphStore` positional constructor to set `NodeT` from the
element type of the `graphs` iterator rather than hardcoding `Nothing`.

The existing companion-tables test in `test/core/companion_tables.jl` constructs
a `StoredGraph` directly; update that constructor call to include the new
`root_handle=nothing` argument. End green with
`julia --project=test test/runtests.jl`.

---

### 5. Implement construction-aware Newick orchestration

**Type**: WRITE
**Output**: `src/newick_format.jl` has a construction path that, given a `NodeT`
type or a `rootnode::NodeT`, emits `bind_rootnode!` and `add_child` calls with
`NodeRowRef` and `EdgeRowRef` row references into the authoritative tables,
builds the authoritative tables first, then returns `LineageGraphStore{NodeT}`
with root handles stored in the graph assets
**Depends on**: 4

Read `src/newick_format.jl` in full before editing. The tranche 1 path
(`build_newick_store(text, source_path)`) must remain unchanged and must
continue to produce `LineageGraphStore{Nothing}`.

Add a construction variant:

```
build_newick_store(text, source_path, ::Type{NodeT}) -> LineageGraphStore{NodeT}
```

This variant pre-parses the Newick source fully (using the existing
`parse_newick_source` path), builds the authoritative node and edge tables
for each graph (using the existing `build_stored_graph` logic), then emits
protocol calls in pre-order traversal:

- for the root node: `add_child(nothing, nodekey, label, nothing, nothing; edgedata=nothing, nodedata=NodeRowRef(node_table, nodekey))`
- for each descendant: `add_child(parent_handle, nodekey, label, edgekey, edgeweight; edgedata=EdgeRowRef(edge_table, edgekey), nodedata=NodeRowRef(node_table, nodekey))`
- after all `add_child` calls for the graph: `finalize_graph!(root_handle, node_table, edge_table)`

The root handle returned by the root `add_child` call is stored as `root_handle`
in the `StoredGraph`. Use it for subsequent `add_child` parent args by tracking
a `nodekey -> node_handle` mapping as traversal proceeds.

Add a second construction variant for supplied-root binding:

```
build_newick_store(text, source_path, rootnode::NodeT) -> LineageGraphStore{NodeT}
```

This variant must first count the parsed graphs, raise an informative error if
there is more than one (because a supplied rootnode can only bind to a
single-graph source), then proceed as above but replace the root `add_child`
call with:

```
bind_rootnode!(rootnode, nodekey, label; nodedata=NodeRowRef(node_table, nodekey))
```

The supplied `rootnode` is stored as `root_handle` in the `StoredGraph`. Do not
implement the multi-parent tier here. End green with
`julia --project=test test/runtests.jl`.

---

### 6. Add construction load surfaces to FileIO integration

**Type**: WRITE
**Output**: `src/fileio_integration.jl` has `fileio_load` methods for
`(File|Stream){NewickFormat}` with a positional `::Type{NodeT}` arg and with a
positional `rootnode::NodeT` arg; existing tranche 1 load surfaces are
unaffected; the multi-graph rootnode error is raised by the `fileio_load` level
before parsing begins where possible
**Depends on**: 5

Read `src/fileio_integration.jl` in full and re-read `fileio.jl/src/loadsave.jl`
to confirm how positional args and keyword args are forwarded to backend
`fileio_load` functions. Verify that FileIO forwards them correctly before
implementing.

Add four new `fileio_load` methods — `File` and `Stream` variants for the
`::Type{NodeT}` surface, and `File` and `Stream` variants for the
`rootnode::NodeT` surface — by delegating to the `build_newick_store` variants
added in task 5. Keep the structure parallel to the existing tranche 1 methods.
The `rootnode` `Stream` variant cannot cheaply detect multi-graph sources before
parsing; raise the error inside `build_newick_store` where it already has access
to the parsed graph count.

Verify that:
- `load("primates.nwk", DemoNode)` reaches the new `::Type{NodeT}` path
- `load("primates.nwk", my_root)` reaches the new `rootnode::NodeT` path
- The existing `load("primates.nwk")`, `load(File{...}(path))`, and
  `load(Stream{...}(io))` tranche 1 surfaces remain unchanged

End green with `julia --project=test test/runtests.jl`.

---

### 7. Test single-parent construction with representative custom node types

**Type**: TEST
**Output**: `test/core/construction_protocol_single_parent.jl` and
`test/core/builder_callback.jl` exist, are included from `test/runtests.jl`,
and pass; tests verify field-level structural correctness of all `add_child`
and `finalize_graph!` calls against a known fixture tree
**Depends on**: 6

Add `test/core/construction_protocol_single_parent.jl` and include it from
`test/runtests.jl`. Define a `DemoNode` type that implements the tranche 2
single-parent protocol exactly as shown in user story 4 of
`design/brief--user-stories.md`. Use the existing
`test/fixtures/single_rooted_tree.nwk` fixture to load with `DemoNode` and
verify at the field level:

- `asset.graph_rootnode isa DemoNode`
- root node has the expected `nodekey`, `label`
- children of the root have the expected `nodekey` and `label` values in
  traversal order
- `nodedata` row references on each `DemoNode` point into `asset.node_table`
  and return correct values through `node_property`
- `edgedata` row references on non-root nodes point into `asset.edge_table`
  and return correct `edgeweight` and any retained annotation values
- `asset.node_table` and `asset.edge_table` remain independently usable after
  the load

In `test/core/builder_callback.jl`, test the `load(src; builder=fn)` surface
once task 9 is complete. This file should exist as a placeholder until then with
an explicit `@test_broken` or a skip note so the suite stays green. End green
with `julia --project=test test/runtests.jl`.

---

### 8. Test root-binding, row-reference delivery, and error paths

**Type**: TEST
**Output**: `test/core/root_binding.jl` and `test/core/error_paths.jl` exist,
are included from `test/runtests.jl`, and pass; tests verify `bind_rootnode!`
behavior, `NodeRowRef`/`EdgeRowRef` delivery during construction, and all
informative error paths
**Depends on**: 7

Add `test/core/root_binding.jl`. Define a `BoundNode` type that implements
`bind_rootnode!` as shown in user story 5 of `design/brief--user-stories.md`.
Load `single_rooted_tree.nwk` with a supplied rootnode and verify at the field
level:

- `asset.graph_rootnode === rootnode` (identity, not equality)
- the rootnode's bound `nodekey` matches the authoritative node table
- `bind_rootnode!` was called exactly once
- descendant nodes were constructed through `add_child` with the correct parent
  chain

Add `test/core/error_paths.jl`. Verify:

- `load("posterior.trees", some_rootnode)` raises `ArgumentError` whose message
  includes wording about a single-graph source (matching user story 10 of
  `design/brief--user-stories.md`)
- `node_property(asset.node_table, 4, :missing_field)` raises `ArgumentError`
  whose message includes the field name (this may already be covered by tranche
  1 tests — add only the new load-surface error paths not yet covered)

All tests must fail for actual contract breaks, not merely confirm that an error
was raised. End green with `julia --project=test test/runtests.jl`.

---

### 9. Add the `load(src; builder=fn)` surface

**Type**: WRITE
**Output**: `load(src; builder=fn)` is implemented and documented; the `fn`
callable receives the same protocol events as `add_child` and `bind_rootnode!`;
the `builder_callback.jl` test file from task 7 is completed and passes
**Depends on**: 8

Read `design/brief.md` section on builder callbacks before implementing. The
`builder=fn` surface is a convenience wrapper over the core protocol. Implement
`fn` as a callable that receives root-creation and single-parent descendant
events with the same positional and keyword args as `add_child`. The root
handle returned by the first call to `fn` (with `parent=nothing`) is the stored
root handle for the graph asset. The return type of `fn` is inferred from the
first call and used as `NodeT` for that graph.

Add `fileio_load` methods for `File{NewickFormat}` and `Stream{NewickFormat}`
that accept a `builder` keyword and delegate to `build_newick_store` with an
appropriate adapter. The `build_newick_store(text, source_path; builder=fn)`
path must forward `finalize_graph!` to the default no-op unless the caller also
supplies a `finalizer` keyword or the `fn` callable implements a conventional
check.

Document the `builder=fn` contract in the `construction_protocol.jl` docstrings.
Confirm with the project owner that the exact `fn` signature (whether it
receives a symbol tag or dispatches on the `parent` type) matches the ratified
intent before completing this task. End green with
`julia --project=test test/runtests.jl`.

---

### 10. Tranche-boundary review and scope verification

**Type**: REVIEW
**Output**: tranche 2 is confirmed complete at the scope boundary; tables-only
and construction paths co-exist correctly; no multi-parent logic or extension
coupling is present; full test suite and docs build pass
**Depends on**: 9

Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.
Both must pass. Review the completed tranche against its scope boundary:

- confirm that `src/newick_format.jl` does not contain multi-parent `add_child`
  calls or network-tier logic
- confirm that `src/construction_protocol.jl` exports only the ratified function
  names and no provisional or undocumented protocol extensions
- confirm that `StoredGraph` and `GraphAssetIterator` remain unexported and that
  no external API depends on their internal layout
- confirm that `load(src)` and `load(File{...})` still return
  `LineageGraphStore{Nothing}` with `graph_rootnode === nothing` in all assets
- confirm that `NodeRowRef` and `EdgeRowRef` are exported and that row-reference
  delivery occurs at every `add_child` and `bind_rootnode!` call site

Flag any deviation from the tranche scope to the project owner before declaring
this tranche complete.
