---
date-created: 2026-04-27T00:00:00
date-revised: 2026-04-28T00:00:00
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

The current repository state is no longer a scaffold. The tranche 1 through
tranche 3 foundation is implemented and green, and the remaining phase 1 work
must now be re-tranched around the next honest owner boundary and the
user-authorized delivery focus.

Verified current-state observations:

- `src/LineagesIO.jl`, `src/core_types.jl`, `src/tables.jl`, `src/views.jl`,
  `src/construction.jl`, `src/newick_format.jl`, and
  `src/fileio_integration.jl` implement the tranche 1 and tranche 2 core path
- `ext/MetaGraphsNextIO.jl` and `ext/MetaGraphsNextAbstractTreesIO.jl`
  implement the tranche 3 rooted simple-Newick reference extension path
- `Project.toml` and `test/Project.toml` already declare the weak dependency
  and extension wiring for `MetaGraphsNext.jl` and `AbstractTrees.jl`
- the current repository state is green:
  `julia --project=test test/runtests.jl` passes and
  `julia --project=docs docs/make.jl` builds successfully apart from the normal
  Documenter deployment warning
- no multi-parent construction protocol, rooted-network-capable core format
  owner, `PhyloNetworks.jl` extension, `Phylo.jl` extension, or
  `LineageGraphML` owner exists yet

The next clean foundational owner is therefore the multi-parent core and
rooted-network format layer needed to support a native `PhyloNetworks.jl`
soft-release path without forcing extension code to guess network structure,
annotation retention, or format ownership.

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

The current remaining-work sequence must also respect the following additional
framing:

- tranche 3 already establishes the reference-standard simple-Newick extension
  pattern through `MetaGraphsNext.jl`
- the next domain-focal deliverable is an end-user-ready
  `PhyloNetworks.jl`-based workflow, not a deferred network core followed by a
  later production pass
- `Phylo.jl` rooted-tree work remains in phase 1 scope, but it is intentionally
  deferred behind the `PhyloNetworks.jl` soft-release sequence

## Authorization boundary

The following disruption boundary is authorized by the combined specification
set and the current repository state:

- foundational establishment of the core architecture is authorized
- clean extension-layer design is authorized inside the current extension
  surface
- phase 1 scope includes `Newick`, rooted-network-capable network inputs,
  `LineageGraphML`, `MetaGraphsNext.jl`, `Phylo.jl`, `PhyloNetworks.jl`, and
  `AbstractTrees.jl` compatibility
- the remaining work may be re-tranched so that the next tranche series ends in
  a `PhyloNetworks.jl`-ready soft release suitable for end-user workflow use,
  provided the design remains a thin projection over the core owners and the
  green-state gates remain explicit

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

4. `Multi-parent core protocol and rooted-network format owners`
   Type: `AFK`
   Blocked by: tranche 3

5. `PhyloNetworks native rooted-network load surface`
   Type: `HITL`
   Blocked by: tranche 4

6. `PhyloNetworks soft-release hardening and end-user workflow completion`
   Type: `HITL`
   Blocked by: tranche 5

7. `MetaGraphsNext network-capable and unrooted-tree completion`
   Type: `HITL`
   Blocked by: tranche 6

8. `LineageGraphML phase 1 core format completion`
   Type: `AFK`
   Blocked by: tranche 4

9. `Phylo.jl simple-Newick rooted-tree extension`
   Type: `AFK`
   Blocked by: tranche 2

10. `Phase 1 stabilization, conformance, and documentation`
   Type: `HITL`
   Blocked by: tranche 6, tranche 7, tranche 8, and tranche 9

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

## Tranche 4: Multi-parent core protocol and rooted-network format owners

**Type**: AFK
**Blocked by**: Tranche 3

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of `PhyloNetworks.jl/`, `fileio.jl/`, `Tables.jl/`, and the
  exact upstream primary sources that define rooted-network-capable `Newick`
  and `LineageNetwork` structure and annotation rules

### What to build

Build the foundational core owner for multi-parent rooted-network support.

This tranche is foundational. It establishes:

- the multi-parent `add_child` protocol tier, including vector
  `edgekeys` / `edgeweights` / `edgedata` delivery
- target compatibility validation for the multi-parent tier before parse work
  begins where possible
- rooted-network-capable core parsing ownership for phase 1
  `format"Newick"` and `format"LineageNetwork"` inputs
- authoritative table assembly for multi-parent graph structure and retained
  edge annotations such as raw `gamma` text
- explicit one-`rootnode` semantics for rooted networks and clear rejection of
  any multiple-root assumption

This tranche must remain wholly core-owned. No extension should be forced to
guess rooted-network structure rules, retained-annotation placement, or format
ownership for itself.

### How to verify

- **Manual**: Load representative rooted-network-capable Newick and
  `LineageNetwork` inputs tables-only and into a custom
  multi-parent-compatible target. Inspect the authoritative tables,
  multi-parent descendant events, raw retained `gamma` text, and one-`rootnode`
  invariant.
- **Automated**: Add and run
  `test/core/network_protocol_multi_parent.jl`,
  `test/core/network_newick_format.jl`,
  `test/core/lineagenetwork_format.jl`,
  `test/core/network_target_validation.jl`, and
  `test/core/network_annotation_retention.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a rooted-network-capable `Newick` or `LineageNetwork` source, when
      the core package loads it tables-only or into a multi-parent-compatible
      target, then the load uses one `rootnode`, stable structural keys, and
      multi-parent descendant construction rather than any multiple-root
      assumption.
- [ ] Given a target or builder that is incompatible with the multi-parent
      construction tier, when the caller attempts the load, then the package
      raises an informative compatibility error before irreversible
      construction work where possible.

### User stories addressed

- Core user story 2: Explicit format override and stream-based load
- Core user story 8: Multi-parent rooted-network construction
- Core user story 10: Informative errors for ambiguous or invalid loads
- Community user story 8: PhyloNetworks can later consume rooted-network inputs with gamma

## Tranche 5: PhyloNetworks native rooted-network load surface

**Type**: HITL
**Blocked by**: Tranche 4

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

Build the native `PhyloNetworks.jl` rooted-network materialization path on top
of the tranche 4 core owner.

This tranche is user-facing and review-gated. It establishes:

- the `PhyloNetworks` package extension module
- native-target `HybridNetwork` load surfaces for
  `load(src, HybridNetwork)` and any upstream-verified supplied-target binding
  path that is clean enough to ratify
- extension-owned mapping of `nodekey`, `edgekey`, `label`, and `edgeweight`
  into stable `PhyloNetworks.jl` structure
- extension-owned interpretation of important retained fields such as `gamma`
  when `PhyloNetworks.jl` needs them semantically
- authoritative-table retention after extension-based loads
- explicit target-specific rejection behavior when a requested load cannot be
  represented honestly by the target package

This tranche is HITL because upstream `PhyloNetworks.jl` exposes low-level
mutable network assembly mechanics, and the exact cursor/finalization pattern
must be reviewed before it becomes the public native-target contract.

### How to verify

- **Manual**: Load representative rooted-network-capable Newick and
  `LineageNetwork` inputs through `load(path, HybridNetwork)`. Inspect the
  resulting `HybridNetwork`, its rooted-network structure, any claimed `gamma`
  interpretation path, and the retained authoritative tables after load.
- **Automated**: Add and run
  `test/extensions/phylonetworks_activation.jl`,
  `test/extensions/phylonetworks_newick_networks.jl`,
  `test/extensions/phylonetworks_lineagenetwork.jl`,
  `test/extensions/phylonetworks_annotation_paths.jl`,
  `test/extensions/phylonetworks_tables_after_load.jl`, and
  `test/extensions/phylonetworks_rejection_paths.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a rooted-network-capable input and an active `PhyloNetworks`
      extension, when `load(phylonetworksourcefilepath, HybridNetwork)` runs,
      then the package returns a native `HybridNetwork`, preserves rooted
      structure honestly, and retains authoritative LineagesIO tables after
      load.
- [ ] Given an implementation approach that would require speculative
      divergence from verified upstream `PhyloNetworks.jl` assembly or
      finalization semantics, when that approach is encountered, then the
      tranche pauses for review rather than merging a speculative adapter.

### User stories addressed

- Community user story 6: Clients do not need extension-private handle types
- Community user story 7: PhyloNetworks gets an early simple-tree deliverable
- Community user story 8: PhyloNetworks can later consume rooted-network inputs with gamma
- Community user story 9: The same source can materialize into different consumers
- Community user story 10: Unsupported structural cases fail specifically by target
- Community user story 11: Authoritative tables remain first-class after extension-based loads

## Tranche 6: PhyloNetworks soft-release hardening and end-user workflow completion

**Type**: HITL
**Blocked by**: Tranche 5

### Parent PRD

- `design/brief.md`
- `design/brief--user-stories.md`
- `design/brief--community-support-objectives.md`
- `design/brief--community-support-user-stories.md`

### Governance and required reading

- Mandated line-by-line reading of all governance documents named in this file
- Mandated reading of `STYLE-vocabulary.md`
- Mandated reading of all upstream primary sources that constrain the
  `PhyloNetworks.jl` public workflow being documented, verified, or hardened in
  this tranche

### What to build

Build the `PhyloNetworks.jl`-focused soft-release layer that turns tranche 5
into an end-user-ready production component.

This tranche is stabilization-focused and review-gated. It establishes:

- production-grade end-to-end verification across the supported
  `PhyloNetworks.jl` happy paths
- package docs, README examples, and fixtures that demonstrate the actual
  ratified public surface for rooted-network inputs and tree-compatible rooted
  inputs
- any upstream-verified supplied-target binding or post-build hardening that is
  needed to make the public `PhyloNetworks.jl` workflow feel complete
- explicit verification that the extension remains a thin projection over the
  core authoritative tables and multi-parent protocol rather than a shadow
  parser or shadow network owner

This tranche must end with a `PhyloNetworks.jl`-ready soft release, not merely
with a passing internal adapter.

### How to verify

- **Manual**: Walk through the documented end-user workflow for loading a
  representative rooted-network input and a representative tree-compatible
  rooted input into `HybridNetwork`. Confirm that the documented syntax works,
  the resulting object can participate in an ordinary `PhyloNetworks.jl`
  workflow, and the authoritative tables remain directly usable after load.
- **Automated**: Add and run a production-facing verification set such as
  `test/integration/phylonetworks_soft_release.jl` together with any needed
  extension tests and docs examples, then run
  `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl`.

### Acceptance criteria

- [ ] Given the supported `PhyloNetworks.jl` public happy path, when a user
      follows the ratified docs and examples, then the package behaves as a
      production-ready component in an end-user `PhyloNetworks.jl` workflow
      rather than as a tranche-local prototype.
- [ ] Given the same tranche, when the automated and manual soft-release gates
      run, then they verify real load behavior, retained authoritative tables,
      target-specific semantics, and rejection paths at field level rather than
      relying on weak proxies.

### User stories addressed

- Core user story 2: Explicit format override and stream-based load
- Core user story 7: Deferred annotation access after load
- Core user story 9: Source and collection coordinates remain attached to each graph
- Community user story 6: Clients do not need extension-private handle types
- Community user story 7: PhyloNetworks gets an early simple-tree deliverable
- Community user story 8: PhyloNetworks can later consume rooted-network inputs with gamma
- Community user story 9: The same source can materialize into different consumers
- Community user story 10: Unsupported structural cases fail specifically by target
- Community user story 11: Authoritative tables remain first-class after extension-based loads

## Tranche 7: MetaGraphsNext network-capable and unrooted-tree completion

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
- Mandated reading of `MetaGraphsNext.jl/`, `Graphs.jl/`, `AbstractTrees.jl/`,
  `fileio.jl/`, `Tables.jl/`, and Julia package-extension and weak-dependency
  primary sources

### What to build

Build the remaining network-capable `MetaGraphsNext.jl` work on top of the
proven tranche 4 core and the ratified tranche 6 soft-release lessons.

This tranche is user-facing and review-gated. It establishes:

- rooted-network-capable `MetaGraphsNext.jl` support through the multi-parent
  core protocol
- any ratified unrooted simple-Newick `MetaGraphsNext.jl` path that still uses
  one distinguished `rootnode`
- continued authoritative-table retention after extension-based loads
- explicit rejection paths where a requested structure cannot be represented
  honestly by the `MetaGraphsNext.jl` target

This tranche is HITL because the exact public-facing unrooted-tree staging
boundary and any new wrapper names still require review before merger.

### How to verify

- **Manual**: Load representative rooted-network-capable inputs into the
  `MetaGraphsNext.jl` extension path. If unrooted simple Newick support is
  included, inspect the distinguished-root behavior explicitly.
- **Automated**: Add and run
  `test/extensions/metagraphsnext_networks.jl`,
  `test/extensions/metagraphsnext_unrooted_distinguished_root.jl`,
  `test/extensions/metagraphsnext_network_tables_after_load.jl`, and
  `test/extensions/metagraphsnext_network_rejection_paths.jl` through
  `julia --project=test test/runtests.jl`.

### Acceptance criteria

- [ ] Given a rooted-network-capable input and an active `MetaGraphsNext`
      extension, when the load runs, then the extension consumes the core
      multi-parent protocol, preserves authoritative tables after load, and
      does not hide contract violations behind extension-local structure.
- [ ] Given a ratified unrooted simple-Newick path, when that path is included
      in this tranche, then it uses one distinguished `rootnode` and is merged
      only after the exact behavior is reviewed and verified.

### User stories addressed

- Community user story 3: MetaGraphsNext can stage unrooted-tree support with a distinguished rootnode
- Community user story 8: PhyloNetworks can later consume rooted-network inputs with gamma
- Community user story 9: The same source can materialize into different consumers
- Community user story 10: Unsupported structural cases fail specifically by target
- Community user story 11: Authoritative tables remain first-class after extension-based loads
- Community user story 12: Package-specific wrappers can bridge the loaded graph onward

## Tranche 8: LineageGraphML phase 1 core format completion

**Type**: AFK
**Blocked by**: Tranche 4

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
      package raises an informative profile/ownership error rather than
      claiming generic GraphML support.

### User stories addressed

- Core user story 1: Tables-only load from a simple Newick file
- Core user story 2: Explicit format override and stream-based load
- Core user story 3: Lazy iteration over multi-graph sources
- Core user story 9: Source and collection coordinates remain attached to each graph
- Core user story 10: Informative errors for ambiguous or invalid loads

## Tranche 9: Phylo.jl simple-Newick rooted-tree extension

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

This tranche is intentionally deferred behind the `PhyloNetworks.jl`
soft-release sequence because the current phase 1 delivery focus is the native
rooted-network workflow.

### How to verify

- **Manual**: Load a representative rooted simple Newick file into a
  `Phylo.jl` target and inspect the rooted structure, returned native tree,
  branch lengths, and retained authoritative tables after load.
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
- Community user story 6: Clients do not need extension-private handle types
- Community user story 9: The same source can materialize into different consumers
- Community user story 10: Unsupported structural cases fail specifically by target
- Community user story 11: Authoritative tables remain first-class after extension-based loads

## Tranche 10: Phase 1 stabilization, conformance, and documentation

**Type**: HITL
**Blocked by**: Tranche 6, tranche 7, tranche 8, and tranche 9

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
- [ ] Given any extension-owned public name that remained provisional in
      earlier tranches, when this tranche finishes, then the name is either
      explicitly ratified and documented or kept internal rather than silently
      becoming part of the public contract.

### User stories addressed

- Core user story 2: Explicit format override and stream-based load
- Core user story 7: Deferred annotation access after load
- Community user story 1: Extension activation for the MetaGraphsNext reference path
- Community user story 4: AbstractTrees traversal works through a MetaGraphsNext wrapper
- Community user story 9: The same source can materialize into different consumers
- Community user story 11: Authoritative tables remain first-class after extension-based loads
- Community user story 12: Package-specific wrappers can bridge the loaded graph onward
