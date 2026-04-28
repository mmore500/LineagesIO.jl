---
date-created: 2026-04-27T00:00:00
status: approved
---

# LineagesIO.jl — Phase 1 architecture tranches

## Authority

This document is the approved tranche file derived from the combined LineagesIO
design specification set.

The governing specification set is:

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

If this tranche document conflicts with any governing design document, the
governing design document or documents control and this tranche document must
be revised.

## Governance and required reading

All downstream tasking, implementation, review, and audit work derived from
this tranche document must require line-by-line reading of:

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
- the four governing design documents listed above

This pass-forward obligation is mandatory at every downstream handoff.

## Controlled vocabulary

All downstream work must preserve the controlled vocabulary already ratified in
`STYLE-vocabulary.md` and the governing briefs.

In particular:

- use exact core identifiers such as `StructureKeyType`, `nodekey`,
  `edgekey`, `src_nodekey`, `dst_nodekey`, `edgeweight`, `rootnode`,
  `bind_rootnode!`, `add_child`, `finalize_graph!`, `node_table`,
  `edge_table`, `NodeRowRef`, and `EdgeRowRef`
- do not substitute proscribed alternates such as `node_idx`, `edge_idx`,
  `edgelength`, `tip`, or generic `vertex` terminology in project-owned
  identifiers
- treat provisional extension-owned names shown in
  `design/brief--community-support-user-stories.md` as placeholders only until
  explicitly ratified

## Upstream primary sources

The following upstream primary sources are mandatory where their contracts are
material to a tranche:

- `fileio.jl/`
- `Graphs.jl/`
- `MetaGraphsNext.jl/`
- `AbstractTrees.jl/`
- `PhyloNetworks.jl/`
- `Phylo.jl/`
- `Tables.jl/`

The following additional upstream sources are required by this tranche plan and
were missing from the governing briefs:

- `Tables.jl/`
  Reason: package-owned Tables.jl-compliant table types are first-class core
  contracts.
- Julia package-extension and weak-dependency primary sources
  Reason: `ext/` activation behavior and optional-dependency semantics are
  first-class extension contracts.

Any downstream task or review that depends on one of these sources must name it
explicitly rather than referring vaguely to "upstream behavior".

## Current-state diagnosis

The current repository state is a scaffold, not an implementation of the
governing design.

Verified current-state observations:

- `src/LineagesIO.jl` contains only a minimal module shell
- no package-owned format modules, authoritative table types, row-reference
  types, return types, loading surfaces, or extension modules exist yet
- the current test suite is limited to Aqua and JET scaffolding

Because the owning layers do not yet exist, foundational tranches are required
before user-facing ecosystem support can be implemented honestly.

## Ownership and invariant framing

The architectural owner boundaries in the governing briefs require the
following tranche discipline:

- core owns parsing, format detection, structural key assignment, authoritative
  tables, row-reference types, FileIO backend methods, lazy view types, and
  public protocol emission
- extensions own translation into target-package graph structures, any
  package-specific annotation interpretation, and package-specific wrappers
- no extension may introduce a shadow parser stack, an alternative
  builder-boundary payload bag, or a redefinition of the core structural
  contract

Foundational core tranches therefore come before extension tranches whenever an
extension would otherwise have to guess or reconstruct a core-owned invariant.

## Authorization boundary

The following disruption boundary is authorized by the combined specification
set and the current repository state:

- foundational establishment of the core architecture is authorized
- clean extension-layer design is authorized inside the currently unimplemented
  extension surface
- phase 1 scope includes `Newick`, rooted-network-capable network inputs,
  `LineageGraphML`, `MetaGraphsNext.jl`, `Phylo.jl`, `PhyloNetworks.jl`, and
  `AbstractTrees.jl` compatibility

The following remain out of scope for this tranche file unless explicitly
re-authorized later:

- serialization as a delivery target
- `Nexus`
- `TskitTrees`
- additional consumer packages beyond the governing briefs
- silent export of provisional extension-owned names before explicit review

## Verification and green-state gates

Every tranche must begin and end in a green, policy-compliant state.

Minimum tranche-end verification rules:

- all code-bearing tranches must pass `julia --project=test test/runtests.jl`
- documentation-bearing tranches must also pass
  `julia --project=docs docs/make.jl`
- extension tranches must add direct end-to-end load tests from representative
  source text into the target package
- weak proxies are forbidden; field-level structural correctness, table
  contents, and any claimed annotation interpretation path must be asserted
  directly

## Tranche summary

1. `Simple Newick tables-only core foundation`
   Type: `AFK`
   Blocked by: none

2. `Single-parent construction protocol and annotation contract`
   Type: `AFK`
   Blocked by: tranche 1

3. `MetaGraphsNext reference simple-Newick extension`
   Type: `AFK`
   Blocked by: tranche 2

4. `Phylo.jl simple-Newick rooted-tree extension`
   Type: `AFK`
   Blocked by: tranche 2

5. `PhyloNetworks simple-tree extension`
   Type: `HITL`
   Blocked by: tranche 2

6. `Multi-parent core protocol and rooted-network format owners`
   Type: `AFK`
   Blocked by: tranche 3, tranche 4, and tranche 5

7. `LineageGraphML phase 1 core format completion`
   Type: `AFK`
   Blocked by: tranche 6

8. `Network-capable extension completion`
   Type: `HITL`
   Blocked by: tranche 6

9. `Phase 1 stabilization, conformance, and documentation`
   Type: `HITL`
   Blocked by: tranche 7 and tranche 8

## Tranche 1: Simple Newick tables-only core foundation

**Type**: AFK
**Blocked by**: None -- can start immediately

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of `fileio.jl/`, `Tables.jl/`, and any simple-Newick
  upstream reference material in `Phylo.jl/` or `PhyloNetworks.jl/` that is
  used to define the parser-owned structural reading rules

### What to build

Build the foundational core owner for tables-only loading of simple rooted
Newick data.

This tranche is foundational. It establishes:

- `format"Newick"` ownership and detection rules for the phase 1 minimum path
- FileIO-compatible backend load entrypoints for filename, explicit format
  override, and stream-based loads
- package-owned `LineageGraphStore` and `LineageGraphAsset` return types
- package-owned authoritative table types for source, collection, graph, node,
  and edge data
- lazy `graphs` iteration and graph/source coordinate tracking

This tranche does not yet build graph materialization into user node handles or
consumer packages. It establishes the owner that those later tranches depend
on.

### How to verify

- **Manual**: Load a representative simple rooted Newick file through
  `load("primates.nwk")`, `load(File{format"Newick"}(...))`, and
  `load(Stream{format"Newick"}(...))`. Inspect the first returned graph asset
  and confirm `materialized === nothing`, authoritative `node_table` and
  `edge_table` exist, and source/collection coordinates are preserved.
- **Automated**: Add and run `test/core/newick_tables_only.jl`,
  `test/core/fileio_load_surfaces.jl`, and `test/core/graph_store_coordinates.jl`
  through `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a simple rooted Newick file, when `load("primates.nwk")` runs,
      then the result is a lazy `LineageGraphStore` whose first graph asset
      exposes authoritative package-owned tables and `materialized === nothing`.
- [ ] Given an ambiguous source that is unsafe to auto-detect, when a caller
      uses a bare `load(...)` surface, then the package raises an informative
      explicit-override error rather than guessing a format.

### User stories addressed

- Core user story 1: Tables-only load from a simple Newick file
- Core user story 2: Explicit format override and stream-based load
- Core user story 3: Lazy iteration over multi-graph sources
- Core user story 9: Source and collection coordinates remain attached to each graph
- Core user story 10: Informative errors for ambiguous or invalid loads

## Tranche 2: Single-parent construction protocol and annotation contract

**Type**: AFK
**Blocked by**: Tranche 1

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of `fileio.jl/`, `Tables.jl/`, and Julia package-extension
  and weak-dependency primary sources where they constrain the load surfaces
  and contract boundaries being established here

### What to build

Build the core single-parent materialization owner for rooted simple Newick
trees.

This tranche is foundational. It establishes:

- `bind_rootnode!`, single-parent `add_child`, and `finalize_graph!`
- `NodeRowRef` and `EdgeRowRef`
- generic property lookup helpers over authoritative tables and row references
- `load(src, NodeT)`, `load(src, rootnode::NodeT)`, and `load(src; builder=fn)`
  on top of the same core protocol
- builder and root-binding validation before parse work where possible
- informative failure paths for invalid one-graph root-binding loads and other
  contract violations

This tranche repairs the owner boundary so later extensions consume the core
protocol rather than inventing local materialization payloads.

### How to verify

- **Manual**: Define representative custom node-handle types that implement
  `bind_rootnode!` and `add_child`. Confirm that rooted simple Newick loads
  construct a rooted tree, preserve stable structural keys, and expose raw
  retained annotation text through row references.
- **Automated**: Add and run `test/core/construction_protocol_single_parent.jl`,
  `test/core/root_binding.jl`, `test/core/row_references.jl`,
  `test/core/builder_callback.jl`, and `test/core/error_paths.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a custom `NodeT`, when `load("primates.nwk", NodeT)` runs, then the
      package emits the root-creation and descendant-construction protocol with
      stable `nodekey`, `edgekey`, `label`, `nodedata`, and `edgedata` values.
- [ ] Given a supplied `rootnode` and a source that yields more than one graph,
      when `load(src, rootnode)` is attempted, then the package raises an
      informative error instead of guessing how multiple graphs should bind.

### User stories addressed

- Core user story 4: Library-created-root construction into custom node handles
- Core user story 5: Root binding onto a caller-supplied rootnode
- Core user story 6: Eager annotation interpretation during construction
- Core user story 7: Deferred annotation access after load
- Core user story 10: Informative errors for ambiguous or invalid loads

## Tranche 3: MetaGraphsNext reference simple-Newick extension

**Type**: AFK
**Blocked by**: Tranche 2

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of `MetaGraphsNext.jl/`, `Graphs.jl/`, `AbstractTrees.jl/`,
  `fileio.jl/`, `Tables.jl/`, and Julia package-extension and weak-dependency
  primary sources

### What to build

Build the first reference-standard extension for rooted simple Newick trees
into `MetaGraphsNext.jl`.

This tranche is user-facing. It establishes:

- the `MetaGraphsNext` package extension module
- native-target `MetaGraph` load surfaces for simple rooted Newick
- any extension-private cursor or helper state needed for clean single-parent
  incremental construction, kept out of the public API
- root creation and, where upstream semantics make it clean, supplied-root
  binding for `MetaGraphsNext` targets
- authoritative-table retention after extension-based loads
- an initial `AbstractTrees.jl` compatibility wrapper over the
  MetaGraphsNext-backed tree view

This tranche must remain a thin projection layer over the tranche 2 core
protocol and tables. It must not add an extension-local parser stack.

### How to verify

- **Manual**: Load a representative rooted simple Newick file after loading
  both LineagesIO and MetaGraphsNext. Inspect the returned native
  `MetaGraph`, verify the target graph structure, and confirm the authoritative
  tables remain usable after load. Traverse the wrapper with
  `AbstractTrees.PreOrderDFS`.
- **Automated**: Add and run `test/extensions/metagraphsnext_activation.jl`,
  `test/extensions/metagraphsnext_simple_newick.jl`,
  `test/extensions/metagraphsnext_supplied_root.jl`,
  `test/extensions/metagraphsnext_tables_after_load.jl`, and
  `test/extensions/metagraphsnext_abstracttrees.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a rooted simple Newick file and an active MetaGraphsNext extension,
      when `load("primates.nwk", MetaGraph)` runs, then the package returns a
      native MetaGraphsNext-backed materialization that still exposes
      authoritative LineagesIO tables after load and does not require any
      extension-private handle type.
- [ ] Given the MetaGraphsNext tree wrapper, when `AbstractTrees.PreOrderDFS`
      traverses it, then the traversal follows the same root/child structure
      implied by the authoritative core tables and does not depend on any
      extension-local parsing shortcut.

### User stories addressed

- Community user story 1: Extension activation for the MetaGraphsNext reference path
- Community user story 2: MetaGraphsNext is the earliest reference-standard deliverable
- Community user story 4: AbstractTrees traversal works through a MetaGraphsNext wrapper
- Community user story 9: The same source can materialize into different consumers
- Community user story 11: Authoritative tables remain first-class after extension-based loads
- Community user story 12: Package-specific wrappers can bridge the loaded graph onward

## Tranche 4: Phylo.jl simple-Newick rooted-tree extension

**Type**: AFK
**Blocked by**: Tranche 2

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of `Phylo.jl/`, `fileio.jl/`, `Tables.jl/`, and Julia
  package-extension and weak-dependency primary sources

### What to build

Build the rooted simple Newick extension path into `Phylo.jl`.

This tranche is user-facing. It establishes:

- the `Phylo` package extension module
- native-target `RootedTree` load surfaces for clean single-parent
  construction into a rooted `Phylo.jl` tree
- library-created-root construction and, if upstream-verified and clean,
  supplied-root binding
- explicit rejection of unsupported multi-parent or rooted-network loads
- authoritative-table retention after extension-based materialization

This tranche should keep target-package objects structurally honest and avoid
forcing retained annotations into the target package unless that projection is
explicitly chosen and verified.

### How to verify

- **Manual**: Load a representative rooted simple Newick file into a
  `Phylo.jl` target and inspect the rooted structure, returned native tree, branch
  lengths, and retained authoritative tables after load.
- **Automated**: Add and run `test/extensions/phylo_activation.jl`,
  `test/extensions/phylo_simple_newick.jl`,
  `test/extensions/phylo_supplied_root.jl`, and
  `test/extensions/phylo_rejection_paths.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a rooted simple Newick file and an active Phylo extension, when
      `load("primates.nwk", RootedTree)` runs, then the package returns a
      rooted `Phylo.jl` materialization and retains authoritative LineagesIO
      tables after load.
- [ ] Given a source that requires the multi-parent construction tier, when the
      Phylo extension is asked to load it, then the package raises an
      informative target-specific rejection instead of silently flattening the
      structure.

### User stories addressed

- Community user story 5: Phylo.jl rooted-tree materialization is available from the same core load
- Community user story 6: Phylo.jl root binding can target a caller-owned rooted tree
- Community user story 9: The same source can materialize into different consumers
- Community user story 10: Unsupported structural cases fail specifically by target
- Community user story 11: Authoritative tables remain first-class after extension-based loads

## Tranche 5: PhyloNetworks simple-tree extension

**Type**: HITL
**Blocked by**: Tranche 2

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of `PhyloNetworks.jl/`, `fileio.jl/`, `Tables.jl/`, and
  Julia package-extension and weak-dependency primary sources

### What to build

Build the early simple-tree deliverable for `PhyloNetworks.jl`.

This tranche is user-facing and review-gated. It establishes:

- the `PhyloNetworks` package extension module for simple rooted tree inputs
- an extension-owned target path that materializes a tree-compatible
  `HybridNetwork` representation from simple Newick through the tranche 2
  single-parent core protocol
- authoritative-table retention after load
- explicit rejection of any extension-local shadow parsing or contract
  divergence that would weaken the upstream target semantics

This tranche is HITL because upstream `PhyloNetworks.jl` exposes a low-level
mutable network assembly surface, and the exact early tree-as-network path
should be reviewed before it is treated as the public pattern for later network
support.

### How to verify

- **Manual**: Load a representative rooted simple Newick file into the
  PhyloNetworks extension path and inspect the resulting tree-compatible target
  structure together with the retained authoritative tables. Review the target
  assembly strategy against upstream source before merger.
- **Automated**: Add and run `test/extensions/phylonetworks_activation.jl`,
  `test/extensions/phylonetworks_simple_tree.jl`, and
  `test/extensions/phylonetworks_tables_after_load.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a rooted simple Newick file and an active PhyloNetworks extension,
      when `load("primates.nwk", HybridNetwork)` runs, then the
      package returns a tree-compatible target path and retains authoritative
      LineagesIO tables after load.
- [ ] Given an implementation approach that would require unverified divergence
      from upstream `PhyloNetworks.jl` assembly semantics, when that approach is
      encountered, then the tranche pauses for human review rather than merging
      a speculative adapter.

### User stories addressed

- Community user story 7: PhyloNetworks gets an early simple-tree deliverable
- Community user story 9: The same source can materialize into different consumers
- Community user story 10: Unsupported structural cases fail specifically by target
- Community user story 11: Authoritative tables remain first-class after extension-based loads

## Tranche 6: Multi-parent core protocol and rooted-network format owners

**Type**: AFK
**Blocked by**: Tranche 3, tranche 4, and tranche 5

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of `PhyloNetworks.jl/`, `Phylo.jl/`, `fileio.jl/`,
  `Tables.jl/`, and any rooted-network-capable upstream source text that is
  used to define the parser-owned structure contract

### What to build

Build the core owner for multi-parent rooted-network support.

This tranche is foundational. It establishes:

- the multi-parent `add_child` protocol tier
- target compatibility validation for multi-parent formats before parse work
  where possible
- rooted-network-capable core parsing ownership for `format"LineageNetwork"`
  and rooted-network-capable Newick inputs that belong to phase 1
- authoritative table assembly for multi-parent graph structure and retained
  edge annotations such as raw `gamma` text
- explicit one-`rootnode` semantics for rooted networks

This tranche must remain wholly core-owned. No extension should be forced to
guess network structure rules for itself.

### How to verify

- **Manual**: Load a representative rooted-network-capable input into
  tables-only and custom multi-parent-compatible `NodeT` surfaces. Inspect the
  authoritative tables, multi-parent descendant events, and one-`rootnode`
  invariant.
- **Automated**: Add and run `test/core/network_protocol_multi_parent.jl`,
  `test/core/lineagenetwork_format.jl`,
  `test/core/network_target_validation.jl`, and
  `test/core/network_annotation_retention.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a rooted-network-capable source, when the core package loads it
      tables-only or into a multi-parent-compatible target, then the load uses
      one `rootnode`, stable structural keys, and multi-parent descendant
      construction rather than any multiple-root assumption.
- [ ] Given a target or builder that is incompatible with the multi-parent
      construction tier, when the caller attempts the load, then the package
      raises an informative compatibility error before irreversible construction
      work where possible.

### User stories addressed

- Core user story 8: Multi-parent rooted-network construction
- Core user story 10: Informative errors for ambiguous or invalid loads
- Community user story 8: PhyloNetworks can later consume rooted-network inputs with gamma
- Community user story 10: Unsupported structural cases fail specifically by target

## Tranche 7: LineageGraphML phase 1 core format completion

**Type**: AFK
**Blocked by**: Tranche 6

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of `fileio.jl/`, `Tables.jl/`, and the exact source text or
  standards that define the package-ratified phylogeny-specific GraphML
  profile

### What to build

Build the remaining phase 1 core format owner for `format"LineageGraphML"`.

This tranche is foundational and format-specific. It establishes:

- the package-ratified phylogeny-specific GraphML profile as a core-owned
  format
- detection and explicit-override behavior that refuses to treat generic
  GraphML as package-owned input
- authoritative tables-first loading for the ratified profile
- consistent graph/source coordinate handling through the same core return
  types established in tranche 1

This tranche must preserve the GraphML ownership boundary defined by the core
brief.

### How to verify

- **Manual**: Load a representative file that matches the ratified
  phylogeny-specific GraphML profile and inspect the returned authoritative
  tables. Attempt a generic `.graphml` file outside the ratified profile and
  confirm the package refuses ownership.
- **Automated**: Add and run `test/formats/lineagegraphml_profile.jl`,
  `test/formats/lineagegraphml_detection.jl`, and
  `test/formats/lineagegraphml_rejection.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a file that matches the ratified `LineageGraphML` profile, when the
      package loads it, then the result uses the same package-owned return
      types and authoritative tables as the Newick-based core paths.
- [ ] Given a generic `.graphml` file outside the ratified profile, when the
      caller attempts automatic or explicit LineageGraphML loading, then the
      package raises an informative profile/ownership error rather than claiming
      generic GraphML support.

### User stories addressed

- Core user story 1: Tables-only load from a simple Newick file
- Core user story 2: Explicit format override and stream-based load
- Core user story 3: Lazy iteration over multi-graph sources
- Core user story 9: Source and collection coordinates remain attached to each graph
- Core user story 10: Informative errors for ambiguous or invalid loads

## Tranche 8: Network-capable extension completion

**Type**: HITL
**Blocked by**: Tranche 6

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of `MetaGraphsNext.jl/`, `Graphs.jl/`, `PhyloNetworks.jl/`,
  `AbstractTrees.jl/`, `fileio.jl/`, `Tables.jl/`, and Julia package-extension
  and weak-dependency primary sources

### What to build

Build the network-capable extension layer on top of the tranche 6 core owner.

This tranche is user-facing and review-gated. It establishes:

- rooted-network-capable MetaGraphsNext support through the multi-parent core
  protocol
- rooted-network-capable PhyloNetworks support, including any important target
  interpretation path for retained fields such as `gamma`
- any ratified unrooted simple-Newick MetaGraphsNext path that still uses one
  distinguished `rootnode`
- target-specific rejection paths where a consumer package cannot represent the
  loaded structure honestly

This tranche is HITL because the exact public-facing extension names,
unrooted-tree staging boundary, and any target-specific semantic projection
need review before merger.

### How to verify

- **Manual**: Load representative rooted-network-capable inputs into the
  MetaGraphsNext and PhyloNetworks extension paths. Inspect structure,
  retained authoritative tables, and any claimed `gamma` interpretation path.
  If unrooted simple Newick support is included for MetaGraphsNext, inspect the
  distinguished-root behavior explicitly.
- **Automated**: Add and run
  `test/extensions/metagraphsnext_networks.jl`,
  `test/extensions/phylonetworks_networks.jl`,
  `test/extensions/network_annotation_paths.jl`, and
  `test/extensions/network_rejection_paths.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a rooted-network-capable input and an extension target that claims
      support for it, when the load runs, then the extension consumes the core
      multi-parent protocol, retains authoritative tables after load, and
      verifies any claimed semantic interpretation path such as `gamma`.
- [ ] Given an unrooted simple-Newick MetaGraphsNext path, when that path is
      included in this tranche, then it uses one distinguished `rootnode` and
      is merged only after the exact behavior is reviewed and ratified.

### User stories addressed

- Community user story 3: MetaGraphsNext can stage unrooted-tree support with a distinguished rootnode
- Community user story 8: PhyloNetworks can later consume rooted-network inputs with gamma
- Community user story 10: Unsupported structural cases fail specifically by target
- Community user story 11: Authoritative tables remain first-class after extension-based loads

## Tranche 9: Phase 1 stabilization, conformance, and documentation

**Type**: HITL
**Blocked by**: Tranche 7 and tranche 8

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of all upstream primary sources that constrain any behavior
  being documented, stabilized, or verified in this tranche

### What to build

Build the cross-cutting stabilization layer that turns the preceding tranches
into a coherent phase 1 deliverable.

This tranche is stabilization-focused and review-gated. It establishes:

- cross-extension conformance tests that verify the same core-owned invariants
  across all supported load paths
- documentation and examples that match the actual ratified public syntax
- explicit verification that extensions remain thin projection layers over core
  tables and protocol events
- final review of any extension-owned public names that were previously kept as
  placeholders

This tranche does not use documentation as a substitute for verification. It
adds documentation after the owner and contract work is already in place.

### How to verify

- **Manual**: Walk through the docs-described simple rooted Newick and
  rooted-network examples for each supported consumer path. Confirm that the
  documented syntax matches the ratified load surfaces and that the tables
  remain directly usable after load.
- **Automated**: Run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` after adding cross-extension conformance
  tests such as `test/integration/phase1_conformance.jl` and any associated
  doctests or docs examples.

### Acceptance criteria

- [ ] Given the phase 1 supported load surfaces and extension paths, when the
      full automated gates run, then tests and docs verify the real structural,
      table, activation, and annotation contracts at field level rather than
      relying on weak proxies.
- [ ] Given any extension-owned public name that remained provisional in earlier
      tranches, when this tranche finishes, then the name is either explicitly
      ratified and documented or kept internal rather than silently becoming
      part of the public contract.

### User stories addressed

- Core user story 2: Explicit format override and stream-based load
- Core user story 7: Deferred annotation access after load
- Community user story 1: Extension activation for the MetaGraphsNext reference path
- Community user story 4: AbstractTrees traversal works through a MetaGraphsNext wrapper
- Community user story 9: The same source can materialize into different consumers
- Community user story 11: Authoritative tables remain first-class after extension-based loads
- Community user story 12: Package-specific wrappers can bridge the loaded graph onward
