# Tasks for tranche 3: MetaGraphsNext reference simple-Newick extension

Parent tranche: Tranche 3 (`02_tranches.md`)
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
  `edgeweight`, `basenode`, `bind_basenode!`, `add_child`,
  `finalize_graph!`, `node_table`, `edge_table`, `NodeRowRef`, `EdgeRowRef`,
  `LineageGraphAsset`, and `LineageGraphStore` exactly where those concepts
  are in scope
- write "basenode" and "edge weight" in prose, but use `basenode` and
  `edgeweight` for project-owned identifiers
- use `node` rather than `vertex`, `edge` rather than `branch` in project-owned
  identifiers, and `leaf` rather than `tip`
- when discussing upstream `Graphs.jl` or `MetaGraphsNext.jl` APIs, it is
  acceptable to use upstream terms such as `vertex`, `label`, `code`, and
  `MetaGraph`, but do not substitute those terms for ratified LineagesIO
  identifiers at the core/extension boundary
- treat any extension-private helper names as non-public unless task 1
  explicitly ratifies them as part of the approved user-facing surface
- never use `StructureKeyType` directly as the `Label` type parameter for
  `MetaGraph`; the governing briefs require a distinct non-integer wrapper type
  around `nodekey`

## Upstream primary sources

The following upstream primary sources constrain tranche 3 and must be read in
full before implementation:

- `fileio.jl/`
  Read at minimum the contract-bearing material in `src/types.jl`,
  `src/loadsave.jl`, `src/query.jl`, and `src/registry_setup.jl` so the
  extension continues to consume FileIO-owned load surfaces rather than
  bypassing them.
- `Tables.jl`
  Read at minimum the installed Tables.jl interface documentation and source
  covering `Tables.AbstractColumns`, `Tables.AbstractRow`, `Tables.rows`,
  `Tables.columns`, `Tables.schema`, `Tables.getcolumn`, and
  `Tables.columnnames`, so authoritative table retention remains honest after
  extension-based loads.
- Julia package-extension and weak-dependency primary sources
  Read the Julia `Pkg` documentation section on conditional loading of code in
  `Pkg/docs/src/creating-packages.md`, especially the `[weakdeps]`,
  `[extensions]`, extension code-structure examples, extension test-dependency
  guidance, and the "Behavior of extensions" section, because tranche 3 is the
  first optional-dependency extension path in this repository.
- `MetaGraphsNext.jl/`
  Read at minimum `Project.toml`, `src/MetaGraphsNext.jl`, `src/metagraph.jl`,
  `src/graphs.jl`, `src/directedness.jl`, `docs/src/api.md`,
  `test/tutorial/1_basics.jl`, and `test/misc.jl` so the extension uses
  supported constructors, respects the non-integer label requirement, and uses
  `add_vertex!`, `add_edge!`, `code_for`, and `label_for` honestly.
- `Graphs.jl/`
  Read at minimum the primary material covering `SimpleDiGraph`,
  `AbstractGraph`, `outneighbors`, and `inneighbors`, including
  `src/SimpleGraphs/SimpleGraphs.jl`,
  `docs/src/ecosystem/graphtypes.md`,
  `docs/src/first_steps/construction.md`, and
  `docs/src/first_steps/access.md`, so rooted-tree materialization and
  traversal checks use upstream graph semantics directly.
- `AbstractTrees.jl/`
  Read at minimum `src/base.jl`, `src/traits.jl`, `src/iteration.jl`, and the
  primary interface documentation under `docs/src/index.md`, so any tree-view
  wrapper advertises only the traits and methods it truly satisfies.

When describing these upstream contracts downstream, distinguish verified
upstream fact from local inference.

## Current-state diagnosis

This repository now has the tranche 2 core owner in place but no extension
layer yet. Tranche 3 must add the first consumer extension as a thin projection
over that core rather than reopening core ownership.

Revalidated observations on 2026-04-27:

- `src/LineagesIO.jl`, `src/core_types.jl`, `src/tables.jl`, `src/views.jl`,
  `src/construction.jl`, `src/newick_format.jl`, and
  `src/fileio_integration.jl` implement the tranche 2 tables-plus-construction
  core path
- the current repository state is green:
  `julia --project=test test/runtests.jl` passes and
  `julia --project=docs docs/make.jl` builds successfully apart from the normal
  Documenter deployment warning
- there is no `ext/` directory and no package extension module yet
- `Project.toml` currently declares only `FileIO` and `Tables` under `[deps]`
  and contains no `[weakdeps]` or `[extensions]` sections
- `test/Project.toml` currently contains no `MetaGraphsNext` or `AbstractTrees`
  test dependency
- there is no `test/extensions/` directory and none of the tranche-required
  MetaGraphsNext verification files exist yet
- `README.md` and `docs/src/index.md` currently document only the tables-only
  and generic single-parent construction surfaces, not MetaGraphsNext-specific
  loading or `AbstractTrees` compatibility

Because tranche 2 is already implemented, tranche 3 should not redo core
construction ownership. It should add the first honest optional-dependency
projection layer over the existing authoritative tables and protocol events.

## Ownership and invariant framing

Tranche 3 establishes the extension owner for:

- optional-dependency activation for the MetaGraphsNext reference path
- the MetaGraphsNext extension module and any narrowly-scoped extension-loading
  structure required to keep MetaGraphsNext activation and AbstractTrees
  compatibility honest
- native-target `MetaGraph` load surfaces for rooted simple-Newick
- any extension-private cursor or helper state needed for single-parent
  materialization into `MetaGraph`, kept out of the public API
- the required non-integer MetaGraphsNext label wrapper around `nodekey`
- extension-owned `bind_basenode!`, `add_child`, and `finalize_graph!` methods
  for the rooted simple-Newick MetaGraphsNext path
- an initial `AbstractTrees.jl` compatibility wrapper over the
  MetaGraphsNext-backed tree view
- extension tests and docs that prove authoritative `node_table` and
  `edge_table` retention after extension-based loads

This tranche does not yet own:

- multi-parent `add_child` behavior
- rooted-network or unrooted-tree support
- additional native consumer-package construction
- redesign of the core parser, authoritative tables, or construction protocol
- any extension-local shadow parser stack or alternative builder-boundary
  payload store

The core package remains the owner of parsing, FileIO load surfaces,
authoritative tables, row references, structural keys, and top-down protocol
emission. The extension must consume those owners directly and remain a thin
projection over them.

## Authorization boundary

The user-authorized disruption boundary allows tranche 3 to add the first
reference extension path on top of the existing early-stage core package.

Allowed in this tranche:

- adding `[weakdeps]` and `[extensions]` entries to `Project.toml`
- adding the required extension test dependencies to `test/Project.toml`
- creating `ext/MetaGraphsNextIO.jl` and any narrowly-scoped extension-loading
  file under `ext/` that is required to preserve both honest MetaGraphsNext
  activation and honest AbstractTrees compatibility
- adding `test/extensions/` verification files and any minimal new fixtures
  needed for those tests
- minimal source changes under `src/` only where task 1 ratifies that the
  parent package needs a thin native-target validation hook or an optional
  helper surface that does not expose extension internals
- documentation updates in `README.md` and `docs/src/index.md`

Not allowed in this tranche without further approval:

- introducing a hard dependency from LineagesIO core onto MetaGraphsNext
- multi-parent, rooted-network, or unrooted-tree implementation
- parser duplication, shadow topology stores, or alternative metadata-payload
  containers
- additional native consumer-package support
- silent export of provisional extension-owned public names before review

No standalone MIGRATE task is required for tranche 3, because there is no
pre-existing MetaGraphsNext extension surface in this repository. Compatibility
and exposure obligations are instead explicit in tasks 1, 2, 3, 7, and 10.

## Required revalidation before implementation

- Read this tranche and the four parent design briefs in full
- Read the relevant code, tests, docs, and examples in full:
  `Project.toml`, `test/Project.toml`, `src/LineagesIO.jl`,
  `src/core_types.jl`, `src/tables.jl`, `src/views.jl`,
  `src/construction.jl`, `src/newick_format.jl`,
  `src/fileio_integration.jl`, `test/runtests.jl`, all existing files under
  `test/core/`, `README.md`, `docs/src/index.md`, and any current files under
  `ext/`, `test/extensions/`, and `examples/`
- Read all cited upstream primary sources in full where they constrain the
  work
- Re-check the user-authorized disruption boundary before making deep changes
- Re-confirm that the repository starts green by running
  `julia --project=test test/runtests.jl`
- Re-confirm that the current docs build is green by running
  `julia --project=docs docs/make.jl`
- If the tranche diagnosis no longer matches reality, stop and raise that
  before changing code
- If the exact native-target public surface or any optional tree-view helper
  surface is still unsettled after task 1, stop before exporting or
  documenting names and return to the review boundary rather than inventing
  them ad hoc

## Tranche execution rule

The work may redesign, replace, or deeply refactor extension internals where
authorized, but it must begin and end in the tranche's required green,
policy-compliant state.

Every code-bearing task in this tranche must end with
`julia --project=test test/runtests.jl` passing for the repository state at
that checkpoint. Any task that edits `README.md`, `docs/src/index.md`, or other
docs-owned public usage surfaces must also end with
`julia --project=docs docs/make.jl` passing.

The implementation must preserve the tranche 3 scope boundary:

- LineagesIO core must remain loadable without MetaGraphsNext installed or
  loaded
- MetaGraphsNext activation must be driven by Julia package extensions and weak
  dependencies, not by a hard dependency or an extension-local shadow loader
- the `MetaGraph` label type must be a non-integer wrapper around `nodekey`;
  `StructureKeyType` itself must never be used directly as the upstream label
  type
- extension-based loads must remain thin projections over authoritative
  `node_table` and `edge_table`; those tables remain first-class after load
- the extension must not introduce a shadow parser stack, a second topology
  owner, or copied metadata bags in place of the core row-reference contract
- AbstractTrees traversal must follow the same root/child structure implied by
  the authoritative core tables and the built MetaGraphsNext graph, not an
  extension-local parsing shortcut
- supplied-basenode behavior must remain valid only for one-graph sources

## Tasks

### 1. Ratify the MetaGraphsNext native-target public surface

**Type**: REVIEW
**Output**: approved public MetaGraphsNext load target or targets, approved
optional tree-view helper naming, and explicit confirmation that the public
happy path does not rely on `Base.get_extension(...)` or any extension-private
handle type
**Depends on**: none

Review `design/brief--community-support-objectives.md`,
`design/brief--community-support-user-stories.md`, the tranche file, the
current LineagesIO source layout, and the Julia package-extension guidance to
decide the exact native-target public API for the MetaGraphsNext path.
Ratify whether the supported library-created target is `MetaGraph`,
`MetaGraph{...}`, or both; whether supplied-target binding is also supported in
this tranche; and whether any optional `AbstractTrees` helper should be
surfaced on `LineagesIO`. Include the required non-integer `MetaGraph` label
wrapper in this review, but keep that wrapper internal unless there is a
positive reason to expose it. Do not implement materializing behavior yet. If
the governing documents still leave the public naming or exposure boundary
materially ambiguous, stop and escalate rather than inventing an unreviewed
public API.

### 2. Add weak-dependency and MetaGraphsNext extension skeleton

**Type**: CONFIG
**Output**: `Project.toml` and `test/Project.toml` declare the tranche-owned
optional dependencies honestly; `ext/MetaGraphsNextIO.jl` exists as a loading
skeleton; and any ratified parent-side native-target validation or helper hook
exists without
introducing a hard dependency in core
**Depends on**: 1

Touch `Project.toml`, `test/Project.toml`, and `src/LineagesIO.jl` only if task
1 ratified that the parent package must surface an optional helper or native-
target validation hook.
Create `ext/MetaGraphsNextIO.jl` and any narrowly-scoped extension-loading file
under `ext/` if that is required to preserve honest MetaGraphsNext activation
and honest AbstractTrees compatibility without forcing AbstractTrees to be
loaded for the basic MetaGraphsNext materialization path. Use Julia Pkg
`[weakdeps]`, `[extensions]`, and extension test-dependency guidance directly
rather than ad hoc loading patterns. Keep this task to skeleton and dependency
plumbing only; do not materialize graphs yet. End the task green with
`julia --project=test test/runtests.jl`.

### 3. Prove extension activation and optional-dependency behavior

**Type**: TEST
**Output**: `test/extensions/metagraphsnext_activation.jl` proves that the
MetaGraphsNext reference path activates only when the required target package
is loaded and that the core tables-only path still works without requesting the
extension-owned materialization surface
**Depends on**: 2

Add `test/extensions/metagraphsnext_activation.jl` and wire the new extension
test directory into `test/runtests.jl`. Verify directly that the MetaGraphsNext
extension is absent before `using MetaGraphsNext`, becomes available after the
target package is loaded, and does not make core LineagesIO loading depend on a
hard MetaGraphsNext import. If task 2 introduced any companion loading
structure for AbstractTrees compatibility, prove that basic MetaGraphsNext
materialization still does not require `using AbstractTrees`. Also re-assert
that `load(src)` for the tables-only path continues to work and returns
authoritative tables with `materialized === nothing`. End the task green with
`julia --project=test test/runtests.jl`.

### 4. Implement the MetaGraphsNext native-target library-created-basenode path

**Type**: WRITE
**Output**: the extension defines any private construction state it genuinely
needs, the required non-integer label wrapper around `nodekey`, and the rooted
simple-Newick materialization path needed to load into a native `MetaGraph`
**Depends on**: 3

Touch `ext/MetaGraphsNextIO.jl` and `src/LineagesIO.jl` only if task 1 ratified
that a parent-side alias or validation hook is required for the approved public
surface. Implement the rooted simple-Newick single-parent materialization path
on top of the existing core protocol. Use an upstream-supported directed graph
owner such as `SimpleDiGraph` under `MetaGraph`, define a concrete non-integer
wrapper type around `StructureKeyType` for the upstream label type, and keep
any per-node cursor state private to the extension rather than making it a
documented user-facing target. The resulting public happy path must support the
ratified native-target `load(src, MetaGraph)` surface. Keep authoritative
LineagesIO tables as the primary preserved annotation store by default; only
project metadata into MetaGraphsNext where the extension design actually needs
it. Do not introduce a shadow parser stack, multi-parent logic, or unrooted-
tree behavior. End the task green with
`julia --project=test test/runtests.jl`.

### 5. Verify rooted simple-Newick MetaGraphsNext materialization and authoritative-table retention

**Type**: TEST
**Output**: `test/extensions/metagraphsnext_simple_newick.jl` and
`test/extensions/metagraphsnext_tables_after_load.jl` prove correct rooted-tree
materialization, stable structural mapping, and continued first-class access to
authoritative LineagesIO tables after extension-based loads
**Depends on**: 4

Add `test/extensions/metagraphsnext_simple_newick.jl` and
`test/extensions/metagraphsnext_tables_after_load.jl`, using representative
rooted simple-Newick fixtures that already exist in the repository unless a
minimal new fixture is genuinely required. Verify the actual contract boundary:
the returned `materialized` type, MetaGraphsNext graph structure, stable
mapping from `nodekey` to the extension-owned label wrapper, correct edge
insertion, and continued direct access to `asset.node_table` and
`asset.edge_table` after load. Use upstream `MetaGraphsNext` and `Graphs.jl`
accessors such as `code_for`, `label_for`, `nv`, `ne`, `outneighbors`, or
equivalent graph-level checks rather than weak proxies. These tests must fail
for the pre-tranche-3 repository state. End the task green with
`julia --project=test test/runtests.jl`.

### 6. Implement supplied-basenode binding for MetaGraphsNext targets

**Type**: WRITE
**Output**: the extension provides the approved `bind_basenode!` path for the
MetaGraphsNext supplied native target and any required extension-local
`finalize_graph!` behavior for the rooted simple-Newick single-parent tier
**Depends on**: 5

Extend `ext/MetaGraphsNextIO.jl` so `load(src, basenode)` can bind rooted
simple-Newick materialization onto a caller-supplied MetaGraphsNext target
through the same core protocol owner. Reuse the same extension-owned graph
container, label-wrapper, and structural mapping strategy as the
library-created-basenode path rather than inventing a second owner. Validate the
supported initial state explicitly and implement `finalize_graph!` only if the
MetaGraphsNext construction mechanics genuinely require a post-build cleanup or
normalization step. Do not widen this task into multi-parent, unrooted, or
cross-graph binding behavior. End the task green with
`julia --project=test test/runtests.jl`.

### 7. Verify supplied-basenode behavior and one-graph rejection paths

**Type**: TEST
**Output**: `test/extensions/metagraphsnext_supplied_root.jl` proves successful
one-graph binding, preserved authoritative tables, and informative rejection of
unsupported supplied-basenode cases
**Depends on**: 6

Add `test/extensions/metagraphsnext_supplied_root.jl` and use the existing
single-graph and multi-graph fixtures unless a minimal additional fixture is
strictly required. Verify successful one-graph binding for the approved root
target shape, including the expected post-load relationship between
`asset.materialized` and the supplied target. Assert that authoritative
tables remain available after the bound load. Verify that multi-graph sources
and any other unsupported supplied-basenode combinations fail informatively rather
than guessing. End the task green with `julia --project=test test/runtests.jl`.

### 8. Implement the AbstractTrees wrapper over the MetaGraphsNext-backed tree view

**Type**: WRITE
**Output**: the tranche-owned MetaGraphsNext tree-view wrapper exists together
with the required `AbstractTrees` methods and traits for honest rooted
simple-tree traversal
**Depends on**: 7

Touch `ext/MetaGraphsNextIO.jl` and any companion extension-loading file under
`ext/` that task 2 established for AbstractTrees compatibility. Define the
concrete tree-view wrapper over the MetaGraphsNext-backed rooted-tree
materialization together with the authoritative `node_table` and `edge_table`
context it needs. Implement only the `AbstractTrees` methods and traits the
design actually satisfies, such as `children`, `nodevalue`, `NodeType`, or
`childrentype`, and only implement parent-link traits if the chosen design
truly stores parent information. Child discovery must come from the built graph
and/or authoritative tables, not from a second parser-owned or extension-local
topology store. Keep the wrapper naming aligned with the task 1 ratification.
End the task green with `julia --project=test test/runtests.jl`.

### 9. Verify AbstractTrees traversal against authoritative structure

**Type**: TEST
**Output**: `test/extensions/metagraphsnext_abstracttrees.jl` proves that the
MetaGraphsNext tree-view wrapper traverses the same rooted simple-tree
structure implied by the authoritative core tables
**Depends on**: 8

Add `test/extensions/metagraphsnext_abstracttrees.jl` and verify the actual
cross-package contract. Use `AbstractTrees.PreOrderDFS` on the extension-owned
tree-view wrapper and assert that traversal order, root/child relationships,
and representative leaf behavior match the structure implied by the
authoritative `node_table` and `edge_table`. Include at least one direct
`children(...)` assertion in addition to traversal-level checks. If the wrapper
claims `HasNodeType`, verify that the iteration element type and returned child
shape honestly satisfy that trait. End the task green with
`julia --project=test test/runtests.jl`.

### 10. Close tranche 3 with docs, full verification, and scope-boundary review

**Type**: REVIEW
**Output**: the docs describe the ratified MetaGraphsNext reference path
accurately, the full verification suite passes, and a final review confirms the
extension remained a thin single-parent projection layer over the core package
**Depends on**: 9

Update `README.md` and `docs/src/index.md` so the documented public API matches
the ratified MetaGraphsNext reference path, including activation expectations,
authoritative-table retention, and the approved AbstractTrees wrapper usage.
Avoid `Base.get_extension(...)`, placeholder handle names, or other
extension-internal constructs in public examples. Run
`julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`.
Then review the final repository state against the tranche boundary: no hard
dependency in core, no shadow parser, no multi-parent or unrooted support
leakage, no silent export of unreviewed extension names, and no loss of
authoritative tables after extension-based loads.
