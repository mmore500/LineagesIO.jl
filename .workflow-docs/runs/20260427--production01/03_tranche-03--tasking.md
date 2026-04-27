# Tasks for Tranche 3: MetaGraphsNext reference simple-Newick extension

Parent tranche: Tranche 3 (`02_tranches.md`)
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
and the governing briefs. At the extension boundary, LineagesIO vocabulary governs
all internal identifiers until the final hand-off to a MetaGraphsNext or
AbstractTrees API call. Do not let consumer-package terminology bleed into
LineagesIO-owned code.

In particular:

- use `nodekey`, `edgekey`, `src_nodekey`, `dst_nodekey`, `edgeweight`,
  `rootnode`, `node_table`, `edge_table`, `nodedata`, `edgedata`,
  `NodeRowRef`, `EdgeRowRef`, `bind_rootnode!`, `add_child`, `finalize_graph!`
  exactly where those concepts are in scope within LineagesIO-owned code
- use MetaGraphsNext's own vocabulary (`label`, `vertex_properties`,
  `add_vertex!`, `add_edge!`, `code_for`, `label_for`) only at the actual
  upstream API call sites

## Upstream primary sources

The following upstream primary sources must be read in full before implementing
the relevant parts of this tranche:

- `MetaGraphsNext.jl/src/metagraph.jl`
  Read in full. Understand `MetaGraph` struct fields, all constructors (both
  empty and non-empty forms), `setindex!` vs `add_vertex!`/`add_edge!`
  mutation paths, `code_for`, `label_for`, vertex-code stability after
  incremental construction, and the note that integer label types are
  discouraged because they conflict with vertex codes.
- `MetaGraphsNext.jl/src/graphs.jl`
  Read in full. Understand `add_vertex!`, `add_edge!`, `outneighbor_labels`,
  `inneighbor_labels`, and `set_data!`.
- `MetaGraphsNext.jl/test/tutorial/1_basics.jl`
  Read in full. This is the authoritative usage reference for the label-based
  mutation interface (`setindex!` with one key for vertices, two keys for edges).
- `Graphs.jl/` — read at minimum the `SimpleDiGraph` interface: `add_vertex!`,
  `add_edge!`, `outneighbors`, `inneighbors`, and directedness contracts.
- `AbstractTrees.jl/src/base.jl` and `AbstractTrees.jl/src/traits.jl`
  Read in full. Understand the minimum required interface (`children`), the
  optional trait system (`ChildIndexing`, `NodeType`, `nodetype`, `childtype`),
  and which traits to implement for predictable type-stable traversal with
  `PreOrderDFS`.
- Julia package extension documentation
  Read the official Julia documentation on `[weakdeps]` and `[extensions]` in
  `Project.toml`, extension activation semantics, multi-package triggers, and
  the constraint that an extension module cannot reference symbols defined in
  a sibling extension module. Verify this before designing the
  AbstractTrees integration strategy.

When describing upstream contracts downstream, distinguish verified upstream
fact from local inference.

## Current-state diagnosis

Tranche 2 is complete and merged. Confirmed current state:

- `src/construction_protocol.jl` — `bind_rootnode!`, `add_child`,
  `finalize_graph!` are defined and exported
- `src/core_types.jl` — `NodeRowRef` and `EdgeRowRef` are defined
- `src/newick_format.jl` — construction paths for `load(src, NodeT)` and
  `load(src, rootnode::NodeT)` are implemented
- `src/fileio_integration.jl` — new `fileio_load` variants for construction
  surfaces exist
- `Project.toml` has no `[weakdeps]` or `[extensions]` blocks yet
- no extension modules exist under `ext/`
- no extension test files exist under `test/extensions/`
- no fixture with retained node annotations suitable for extension tests exists
- test suite is green

## Ownership and invariant framing

Tranche 3 establishes the core owner for:

- the extension module `MetaGraphsNextIO` under `ext/MetaGraphsNextIO.jl`
- an extension-owned handle wrapper type that carries the `MetaGraph`, the
  current node's label (as `StructureKeyType`), and any extension-local
  lookup structures needed for directed construction
- `add_child` methods for library-created-root and single-parent construction
  into MetaGraphsNext
- `bind_rootnode!` methods for supplied-root construction into MetaGraphsNext
  where the upstream semantics are clean and verified
- `finalize_graph!` method if upstream construction requires post-build
  edge insertion or normalization (must be verified from the upstream source)
- the `MetaGraphsNextTreeView` wrapper type for AbstractTrees traversal
- `AbstractTrees.children` and supporting trait methods for `MetaGraphsNextTreeView`

This tranche must remain a thin projection layer over the tranche 2 core
protocol and authoritative tables. It must not introduce:

- extension-local re-parsing of Newick
- alternative builder-boundary payload bags
- redefinition of `nodekey`, `edgekey`, or other structural identifiers
- multiple-root semantics
- multi-parent construction logic (deferred to tranche 8)

## Authorization boundary

Allowed in this tranche:

- adding `MetaGraphsNext`, `Graphs`, and `AbstractTrees` as weak dependencies
- creating the extension module and its extension-owned types
- implementing the single-parent construction protocol for MetaGraphsNext
- adding the `MetaGraphsNextTreeView` wrapper with AbstractTrees compatibility
- adding test fixtures and extension tests under `test/extensions/`

Not allowed without further approval:

- multi-parent or rooted-network construction in the MetaGraphsNext extension
- extension-local Newick parsing or format detection
- exporting provisional or unreviewed extension-owned public names before the
  tranche-boundary review
- changes to `Project.toml` beyond the weak-dependency and extension entries
  needed for this tranche

## Required revalidation before implementation

- Read this tranche and all four parent design briefs in full
- Read `design/brief--community-support-objectives.md` section on MetaGraphsNext
  support objectives in full
- Read all source files added or modified in tranches 1 and 2 in full before
  editing any of them
- Read all upstream primary sources listed above in full before implementing
- Verify the Julia package extension activation contract from official Julia
  documentation before designing the AbstractTrees integration
- Confirm that `julia --project=test test/runtests.jl` starts green
- If the diagnosis above no longer matches reality, stop and raise that before
  changing code

## Tranche execution rule

Every code-bearing task must end with `julia --project=test test/runtests.jl`
passing. Extension tests require both `LineagesIO` and `MetaGraphsNext` (and
`AbstractTrees` where applicable) to be present in the test environment. Update
`test/Project.toml` and `test/Manifest.toml` as needed so the full suite
continues to pass with `julia --project=test test/runtests.jl`.

The existing tranche 1 tables-only and tranche 2 construction paths must remain
unaffected throughout.

---

## Tasks

### 1. Add weak dependencies and extension entry to `Project.toml`

**Type**: CONFIG
**Output**: `Project.toml` has `[weakdeps]` entries for `MetaGraphsNext`,
`Graphs`, and `AbstractTrees` with correct UUIDs; `[extensions]` has the entry
for `MetaGraphsNextIO`; `test/Project.toml` has the corresponding test
dependencies so that extension tests can load the required packages
**Depends on**: none

Do not edit `Project.toml` manually to guess UUIDs. Use `Pkg.add` in a Julia
session to add each package to `[weakdeps]`, or read the existing `Manifest.toml`
after adding to confirm the UUIDs. Add:

```
[weakdeps]
AbstractTrees = "<uuid>"
Graphs = "<uuid>"
MetaGraphsNext = "<uuid>"

[extensions]
MetaGraphsNextIO = ["MetaGraphsNext", "Graphs", "AbstractTrees"]
```

Read the Julia package extension documentation to confirm the correct
`[extensions]` trigger syntax and whether all three packages must be listed as
triggers for the extension to activate when all three are present in the session.
Verify the activation semantics before committing to one trigger set.

Add `MetaGraphsNext`, `Graphs`, and `AbstractTrees` to `test/Project.toml`
as well so that extension activation tests can load them. Do not add them as
hard dependencies in the main `[deps]` block. End green with
`julia --project=test test/runtests.jl`.

---

### 2. Create the `MetaGraphsNextIO` extension skeleton

**Type**: WRITE
**Output**: `ext/MetaGraphsNextIO.jl` exists with the correct module declaration
and imports; the extension activates when the trigger packages are loaded in a
Julia session; the full test suite remains green
**Depends on**: 1

Create `ext/MetaGraphsNextIO.jl`. The module name must match the extension name
in `Project.toml` exactly. Import `LineagesIO`, `MetaGraphsNext`, `Graphs`, and
`AbstractTrees` (and any submodules needed). Do not import packages that are not
in the trigger set.

Read `MetaGraphsNext.jl/src/MetaGraphsNext.jl` to understand what names
MetaGraphsNext exports and which you will need. Do not wildcard-import; list
only the names you will use.

Add an extension activation test to `test/extensions/metagraphsnext_activation.jl`
and include it from `test/runtests.jl`. The activation test must verify:

- after `using LineagesIO, MetaGraphsNext, Graphs, AbstractTrees`, the extension
  module is accessible
- the extension does not activate if one of the trigger packages is not loaded
  (this can be tested by checking that extension-owned types are not defined in
  the base session)

End green with `julia --project=test test/runtests.jl`.

---

### 3. Design and implement the extension-owned handle wrapper type

**Type**: WRITE
**Output**: an extension-owned handle wrapper type exists in `ext/MetaGraphsNextIO.jl`;
its fields are concrete; it carries the `MetaGraph`, the current node's
`StructureKeyType` label, and any extension-local state needed for child lookup
and edge insertion during directed construction
**Depends on**: 2

Read `MetaGraphsNext.jl/src/metagraph.jl` and `MetaGraphsNext.jl/test/tutorial/1_basics.jl`
in full before designing the wrapper. The key design question is how to
represent the current node's identity within a `MetaGraph`. From the upstream
source:

- each vertex is added with a user-supplied label; the label is the stable
  identity across the lifetime of incremental construction
- the note that integer labels are "generally discouraged" because they conflict
  with vertex codes applies here — read the upstream note carefully and decide
  whether using `StructureKeyType` (which is `Int`) as the MetaGraph label is
  safe for incremental directed construction where no vertex is deleted

The wrapper type must carry at minimum:

- the `MetaGraph{Int, SimpleDiGraph{Int}, StructureKeyType, ...}` being
  constructed (or a reference to a shared graph object)
- the `StructureKeyType` label for the current node (its `nodekey`)
- any additional extension-local state needed to look up parent handles by
  `nodekey` during `add_child` calls

All fields must be concrete. Follow `STYLE-julia.md` on struct field concreteness.
The exact `VertexData` and `EdgeData` type parameters are extension decisions;
the tranche brief says the extension may choose `Nothing` for both and rely on
the authoritative LineagesIO tables for annotation access. Do not attempt to
project retained annotation fields into `MetaGraph` vertex or edge data in this
tranche — keep target-package objects structurally minimal. Ratify the wrapper
type name with the project owner (the community objectives use `MetaGraphsNextNodeHandle`
as a placeholder; the exact ratified name must be decided before implementation
lands). End green with `julia --project=test test/runtests.jl`.

---

### 4. Implement `add_child` for library-created-root and single-parent construction

**Type**: WRITE
**Output**: `add_child` methods for the extension wrapper type handle both
root creation (parent is `Nothing`) and single-parent descendant construction
(parent is the extension wrapper); the `MetaGraph` is incrementally constructed
by each `add_child` call; the returned wrapper carries the new node's `nodekey`
as its label
**Depends on**: 3

Read `MetaGraphsNext.jl/src/graphs.jl` in full before implementing. The
key mutation question is whether to use:

- `setindex!` with one label key (`meta_graph[nodekey] = vertex_data`), which
  is the idiomatic interface shown in the tutorial, or
- `add_vertex!(meta_graph, nodekey, vertex_data)`, which is the lower-level
  method

Use the approach verified from the upstream source as correct for incremental
label-based construction in a directed graph. Confirm that vertex codes remain
stable during incremental construction without deletion (they do, as verified
from the MetaGraphsNext source).

For the root-creation `add_child` call (parent `Nothing`):
- create a new empty `MetaGraph` with `SimpleDiGraph{Int}` as the underlying
  graph, with `StructureKeyType` as the label type
- add the root vertex with `nodekey` as its label
- return a wrapper holding this `MetaGraph` and the root's `nodekey`

For single-parent descendant construction:
- add the child vertex with `nodekey` as its label to the existing `MetaGraph`
  in the parent wrapper
- add the directed edge from `src_nodekey` to `dst_nodekey`
- store `edgeweight` using the `weight_function` or edge data, as verified
  from upstream
- return a new wrapper holding the same shared `MetaGraph` and the child's `nodekey`

The parent wrapper's `MetaGraph` must be shared (not copied) across all
`add_child` calls for one graph so that the final `MetaGraph` is built
incrementally in a single mutable object. Verify how to share a mutable
`MetaGraph` across wrapper instances (e.g., wrap in a `Ref` or use a
construction context object). End green with
`julia --project=test test/runtests.jl`.

---

### 5. Implement `bind_rootnode!` for supplied-root construction

**Type**: WRITE
**Output**: `bind_rootnode!` for the extension wrapper type is implemented;
the supplied rootnode handle is mutated or updated to carry the parsed root's
structural properties and to serve as the root for subsequent `add_child` calls
**Depends on**: 4

Read `design/brief.md` section on `bind_rootnode!` before implementing. The
supplied rootnode is passed by the caller via `load(src, rootnode::WrapperT)`.
The implementation must:

- bind the parsed `nodekey` and `label` onto the supplied rootnode handle
- set up the handle so subsequent `add_child` calls (with it as parent) can
  continue constructing the shared `MetaGraph`
- return the updated handle

The key design question is whether the supplied handle already owns a `MetaGraph`
(which the caller constructed before passing it) or whether the extension must
create the `MetaGraph` during `bind_rootnode!`. Read `design/brief.md` carefully
on this: the handle is caller-constructed and the extension binds structural
data onto it, it does not construct a new graph object.

If `bind_rootnode!` for `MetaGraph` has subtle upstream-contract constraints
that cannot be safely implemented in this tranche, raise that to the project
owner rather than producing a speculative implementation. End green with
`julia --project=test test/runtests.jl`.

---

### 6. Implement `finalize_graph!` if required by MetaGraphsNext construction

**Type**: WRITE
**Output**: `finalize_graph!` is implemented for the extension wrapper type if
upstream-verified MetaGraphsNext construction requires post-build work; otherwise
the default no-op from the tranche 2 core is confirmed sufficient and no method
is added
**Depends on**: 5

Read `MetaGraphsNext.jl/src/graphs.jl` and verify from the upstream source
whether incremental `add_vertex!` + `add_edge!` construction leaves the
`MetaGraph` in a valid state after the last `add_child` call, or whether any
normalization, index rebuild, or validation step is required. Check specifically:

- whether all edges added during `add_child` calls are visible to `outneighbors`
  after construction without a separate finalization step
- whether the `vertex_properties` and `vertex_labels` dictionaries are fully
  consistent after incremental construction

If no finalization is required by verified upstream contract, document that
explicitly in a comment in the extension source and rely on the tranche 2
default no-op. Do not add a `finalize_graph!` method that does nothing extra —
rely on the default. If finalization is required, implement it and add a test
that confirms the post-finalization state is correct. End green with
`julia --project=test test/runtests.jl`.

---

### 7. Define `MetaGraphsNextTreeView` and AbstractTrees compatibility

**Type**: WRITE
**Output**: `MetaGraphsNextTreeView` is defined in the extension and holds a
reference to the constructed `MetaGraph`, the authoritative `node_table` and
`edge_table`, and the `rootnode` handle; `AbstractTrees.children` is implemented
for `MetaGraphsNextTreeView` and returns the correct child nodes in traversal
order; `PreOrderDFS(tree_view)` traverses the tree in the expected pre-order
**Depends on**: 6

Read `AbstractTrees.jl/src/base.jl` and `AbstractTrees.jl/src/traits.jl` in
full before implementing.

First, verify from the Julia package extension documentation whether
`AbstractTrees.children` can be extended inside the `MetaGraphsNextIO` extension
when `AbstractTrees` is one of the extension triggers. This is the mechanism
that makes the extension safe to call `AbstractTrees.children` without a
hard dependency: if `AbstractTrees` is listed as a trigger, it is guaranteed to
be loaded when the extension activates.

Define `MetaGraphsNextTreeView` as a struct with concrete fields:

- the root wrapper handle (from task 3)
- `node_table::NodeTable` (authoritative)
- `edge_table::EdgeTable` (authoritative)

The `AbstractTrees.children(view::MetaGraphsNextTreeView)` implementation must
return the child views for the current node. Use the authoritative `edge_table`
to find children by looking up rows where `src_nodekey` equals the current
node's `nodekey`, then construct child `MetaGraphsNextTreeView` instances for
each child node. This design avoids dependency on MetaGraphsNext's internal
graph traversal and keeps the authoritative tables as the source of truth for
tree structure.

Implement at minimum:
- `AbstractTrees.children(::MetaGraphsNextTreeView)` returning an indexable
  collection of child views
- `AbstractTrees.nodevalue(::MetaGraphsNextTreeView)` returning the handle
- `AbstractTrees.ChildIndexing(::Type{<:MetaGraphsNextTreeView})` returning
  `IndexedChildren()` for type-stable traversal

Verify from `AbstractTrees.jl/src/traits.jl` whether `NodeType` and `nodetype`
should also be implemented for type-stable `PreOrderDFS`. Add them if the
upstream source confirms they are needed. End green with
`julia --project=test test/runtests.jl`.

---

### 8. Add an annotated Newick fixture for extension tests

**Type**: WRITE
**Output**: `test/fixtures/annotated_simple_rooted.nwk` exists and contains a
small rooted tree with node labels, edge weights, and at least one retained
annotation that the tranche 2 parser can extract; the fixture is consistent
with the expected field-level values used in the extension tests
**Depends on**: none (can run in parallel with tasks 2–7)

Add `test/fixtures/annotated_simple_rooted.nwk`. The fixture must be a simple
rooted Newick tree with:

- at least four nodes (root, two internal, two leaves)
- named leaf and internal nodes where appropriate
- branch lengths on all non-root edges
- retained node annotations in square-bracket comment syntax if the tranche 2
  parser supports them, or deferred to the tranche 2 parser scope if it does not

Check what the tranche 2 Newick parser currently handles for annotations. The
tranche 1 parser explicitly rejects `[...]` comment blocks. If tranche 2 still
does not support them, use a fixture with only label and edge-weight content
and note the annotation-retention limitation explicitly in the fixture file.
Confirm the fixture parses correctly with
`julia --project=test test/runtests.jl` before writing extension tests that
depend on it.

---

### 9. Test extension activation, construction, and authoritative table retention

**Type**: TEST
**Output**: `test/extensions/metagraphsnext_activation.jl`,
`test/extensions/metagraphsnext_simple_newick.jl`,
`test/extensions/metagraphsnext_supplied_root.jl`, and
`test/extensions/metagraphsnext_tables_after_load.jl` exist, are included from
`test/runtests.jl`, and pass; tests verify field-level structural correctness
of the loaded `MetaGraph`, `nodekey`/`edgekey` mapping, `label` mapping,
`edgeweight` mapping, and authoritative table availability after load
**Depends on**: 7, 8

Add the extension test files and include them from `test/runtests.jl`. The tests
must be guarded so they only run when `MetaGraphsNext`, `Graphs`, and
`AbstractTrees` are available in the test environment; if any trigger package is
missing, the tests should skip gracefully rather than error.

In `test/extensions/metagraphsnext_simple_newick.jl`, using
`test/fixtures/annotated_simple_rooted.nwk` (or `single_rooted_tree.nwk` if
annotations are not yet supported), verify at the field level:

- `asset.graph_rootnode isa MetaGraphsNextNodeHandle` (or the ratified wrapper
  name)
- the `MetaGraph` constructed during load has the correct number of vertices and
  edges
- vertex labels match the expected `nodekey` values
- directed edges from `src_nodekey` to `dst_nodekey` exist in the `MetaGraph`
- `edgeweight` values are stored correctly (verify from `MetaGraph` edge data
  or weight function, as implemented in task 4)
- `asset.node_table` and `asset.edge_table` are the same objects as returned
  by the authoritative tables — not copies

In `test/extensions/metagraphsnext_tables_after_load.jl`, verify:

- `node_property(asset.node_table, root_nodekey, :label)` returns the expected
  root label without holding the full `LineageGraphStore` in scope
- the authoritative tables remain valid after the root wrapper handle is
  discarded

In `test/extensions/metagraphsnext_supplied_root.jl`, verify:

- `load(path, supplied_root_handle)` where `supplied_root_handle` is a
  caller-constructed wrapper returns `asset.graph_rootnode === supplied_root_handle`
- the bound root carries the correct `nodekey`

All tests must verify the actual structural content, not merely that objects
were constructed. Do not use weak proxies. End green with
`julia --project=test test/runtests.jl`.

---

### 10. Test AbstractTrees traversal through the MetaGraphsNext wrapper

**Type**: TEST
**Output**: `test/extensions/metagraphsnext_abstracttrees.jl` exists, is
included from `test/runtests.jl`, and passes; tests verify that
`AbstractTrees.PreOrderDFS` traverses the loaded tree in the same order as
the authoritative `node_table` row order and that child sets match the
authoritative `edge_table`
**Depends on**: 9

Add `test/extensions/metagraphsnext_abstracttrees.jl` and include it from
`test/runtests.jl`. Guard with the same trigger-package availability check as
the other extension tests.

Using `test/fixtures/single_rooted_tree.nwk` (or the annotated fixture if
available), load with the MetaGraphsNext extension, construct a
`MetaGraphsNextTreeView` from the returned asset, and verify at the field level:

- `AbstractTrees.children(tree_view)` for the root view returns the same number
  of children as the edge table has rows with `src_nodekey == 1`
- `collect(AbstractTrees.PreOrderDFS(tree_view))` returns nodes whose
  `nodekey` values match the expected pre-order sequence from the
  authoritative node table
- `collect(AbstractTrees.Leaves(tree_view))` returns only leaf nodes (nodes
  with no children in the edge table)

The tests must fail if the `children` implementation returns the wrong nodes
or the traversal visits nodes in the wrong order. Do not merely assert that a
collection of tree nodes was returned. End green with
`julia --project=test test/runtests.jl`.

---

### 11. Tranche-boundary review and scope verification

**Type**: REVIEW
**Output**: tranche 3 is confirmed complete at the scope boundary; the extension
is a thin projection layer over the tranche 2 core protocol; no shadow parsing,
alternative payload containers, or multi-parent logic is present; full test
suite and docs build pass; any extension-owned public names that were
provisional are either ratified or kept internal
**Depends on**: 10

Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.
Both must pass. Review the completed tranche against its scope boundary:

- confirm that `ext/MetaGraphsNextIO.jl` contains no Newick parsing logic
- confirm that the extension-owned handle wrapper type has no fields derived
  from runtime annotation names
- confirm that `AbstractTrees.children` for `MetaGraphsNextTreeView` uses the
  authoritative `edge_table` for child lookup rather than querying the
  `MetaGraph` directly (this keeps the authoritative tables as the structural
  source of truth)
- confirm that `load(src)` and `load(src, NodeT)` for non-MetaGraphsNext types
  are unaffected by the extension
- confirm that no provisional extension-owned public names are silently exported
  without ratification
- confirm that the `MetaGraph` constructed by the extension uses the correct
  directedness (`SimpleDiGraph`, not `SimpleGraph`) for rooted-tree loads

Flag any deviation from the tranche scope to the project owner before declaring
this tranche complete.
