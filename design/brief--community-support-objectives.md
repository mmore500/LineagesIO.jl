---
date-created: 2026-04-26T00:00:00
status: authoritative-companion
---

# LineagesIO.jl — Community support objectives

## Authority

This document is the authoritative companion design brief for community-facing
integration, extension ownership, ecosystem support priorities, and extension
verification requirements in LineagesIO.jl.

`design/brief.md` is the primary core-design authority. This document must be
read alongside it. It does not relax, replace, or override any core contract
stated there.

All downstream planning documents, tranche files, tasking files, audit scopes,
review instructions, implementation work, and extension work that concern
ecosystem support or package integration must conform to this document and to
`design/brief.md`.

If any extension-specific plan or task conflicts with the core brief or with
this companion, the documents must be revised before implementation begins.

## Governance and policy transmission mandates

All implementers, reviewers, tranche authors, downstream agents, and community
contributors must read the following governance documents line by line before
planning, implementing, reviewing, delegating, or ratifying any work derived
from this brief.

| Document | Relevance |
|---|---|
| `STYLE-architecture.md` | Ownership boundaries; anti-fix prohibition; green-state discipline |
| `STYLE-docs.md` | Documentation formatting standards |
| `STYLE-git.md` | Commit style and branching model |
| `STYLE-julia.md` | Functional design; naming; type annotations; mutation contract; struct field concreteness; codebase curation |
| `STYLE-upstream-contracts.md` | Host-framework contract reading; divergence authorization; primary-source verification |
| `STYLE-verification.md` | Verification artifact standards; weak-proxy prohibition; field-level verification |
| `STYLE-vocabulary.md` | Controlled terminology; proscribed terms; compound-word rules; canonical identifier table |
| `STYLE-workflow-docs.md` | Workflow document structure; revalidation rule; pass-forward obligations |
| `STYLE-writing.md` | Prose style for documentation |
| `CONTRIBUTING.md` | Contribution process and expectations |

This obligation must be passed forward explicitly into every downstream
artifact. It is not sufficient to link a parent document and assume the next
reader will infer the mandates.

Passing these mandates forward means:

- naming the required governance documents explicitly
- restating the applicable terminology constraints explicitly
- naming the required upstream primary sources explicitly
- restating the ownership boundary and authorization boundary explicitly
- restating the verification gates explicitly
- restating the integration contract directly and completely enough for a new
  reader to apply it correctly without consulting separate explanatory context

No downstream plan, tranche, task, review scope, or delegated work description
is valid if it silently drops these obligations.

Community compliance is mandatory. This document is an anchor text for repeated
contributor and agent cycles and must continue to be cited and propagated in
downstream work.

### Vocabulary mapping

As this production involves interfacing with third-party packages, there will no doubt be conflict in terminological and vocabulary.
Internally, we will continue to use to LineagesIO terminology and concepts and names for variables etc., until final hand-off.
Of course, we will use consumer/client terms when needed by their API.
In most cases, the interface boundary is clear. 
In all cases, confirm with me.
If there is a conflict or confusion, discuss with me.

## Upstream primary sources

The following upstream primary sources materially constrain the community and
extension design of the package and must be read line by line before
implementing the relevant parts of the system.

Available at `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`:

| Source | Relevance |
|---|---|
| `fileio.jl/` | FileIO backend contract; `DataFormat`; `File` and `Stream`; `add_format`; private `load` and `save`; dispatch and detection semantics |
| `Graphs.jl/` | Key consumer domain ecosystem, providing common abstractions, interfaces, etc. |
| `MetaGraphsNext.jl/` | Key consumer support target package with concrete types for which we will provide first-class support for using the package extension mechanism |
| `AbstractTrees.jl/` | Traversal traits and iteration interface; to be supported by wrapping appropriate `MetaGraphsNext.jl` types in the package extension |
| `PhyloNetworks.jl/` | Extended Newick with hybrid nodes parsing reference; Domain consumer support target; extension target to be provided with native support like  `MetaGraphsNext.jl`|
| `Phylo.jl/` | Julia Newick and NEXUS parsing reference; extension target, as above |

When upstream behavior matters, verified source text governs. Memory,
secondary summaries, and plausible recollection do not.

## Purpose

The core LineagesIO.jl package will be extended (using Julia's package extension mechanism) to provide supported for **DESERIALIZATION**:

- `MetaGraphsNextIO`
    - Triggered on `MetaGraphsNext`, will provide native materialization of concrete `MetaGraphsNext.jl` types from support data source formatted-files.
    - `AbstractTrees.jl` interface will be added through wrapper functions on appropriate `MetaGraphsNextIO.jl` types.
- `PhyloNetworksIO`
    - Triggered on `PhyloNetworks.jl`, as above for native object materialization from any supported data source.
- `PhyloIO`
    - Triggered on `Phylo.jl`, as above for native object materialization from any supported data source.

- which ecosystem packages receive first-class extension support, as reference examples of how consumer packages can black-box wide-spectrum deserialization and materialize custom native phylogenetic data types
- what kind of support each package receives in terms of data
- what responsibilities belong to LineagesIO core and what responsibilities
  belong to extension packages
- how authoritative tables and row references are used at the extension
  boundary
- what verification is required before community support can be considered
  complete

(Note: we may discuss serialization or aspects of serialization in this or other documents in this workflow, but that should not be taken to mean that these are production target or are in scope for current development. 

We of course need to design for them, and that is why they are part 
of the discussion. 

When designing implementations, focus on robust best-practices idiomatic 
Julia, while following STYLE-julia.md for design principles and 
mechanics, or the various tasking instructions.
Defer narrowing of types or avoid it if you can if not needed.

In we want to target loading very large trees or networks and 
maybe even very large collections of very large trees or networks.
Node-level and edge-level metadata needs in these cases can be minimal 
to none.
At the same time, the data can always be dereferenced at any client-side end 
point by dereferencing the references and we can have some nice idiomatic usability by providing syntactic sugars or wrappers (e.g. getproperty overrides, `node_property(graph, node, :fieldname)`
So we do not try to promote metadata to fieldnames or store them locally in the nodes by use the tables which can be part of the graph if we own it in our data model or otherwise returned to the client.

Read the primary brief, `brief.md` to confirm, and confirm 
code implementation conforms to this, and evaluate that this is a good design.
If there are any problems or logical issues, we need to discuss and revise.

At time of implementation, it would be good to review current architecture and code and understanding to confirm that this is all a good fit.

LineagesIO is not a competing graph-model package. It is the package that
loads rooted lineage graph sources, preserves authoritative structure and
retained annotations, and makes that content available to target packages
through stable public protocols.

## Community support objectives

The package must satisfy all of the following community-facing objectives.

It must support first-class construction into focal consumer ackages
packages through Julia package extensions rather than by embedding those
packages as hard dependencies in core.

It must preserve a clean ownership boundary:

- core owns parsing, detection, authoritative tables, structural keys, root
  binding, descendant construction events, and row-reference delivery
- extensions own translation into target-package graph structures
- format-specific and consumer-specific code own semantic interpretation of
  retained non-structural annotations

It must preserve authoritative `node_table` and `edge_table` access even when a
target package chooses not to store all retained annotation values on its own
graph objects.

It must support immediate annotation interpretation during construction and
deferred interpretation after construction without forcing per-node or per-edge
annotation copies.

It must support rooted trees and rooted networks as distinct construction
disciplines while preserving the same distinguished structural contract:

- one `rootnode` per graph
- `nodekey`
- `edgekey`
- `src_nodekey`
- `dst_nodekey`
- `label`
- `edgeweight`

It must make it straightforward for community packages to provide typed
wrappers such as `bootstrap(...)`, `hybrid_gamma(...)`, and related accessors
without requiring LineagesIO core to own those semantics.

It must provide organic idiomatic support for seamless downstream 
interoperability with domain-standard ecosystem packages and traversers:

- `MetaGraphsNext.jl`, `PhyloNetworks.jl`, `Phylo.jl`
    - Building from parser directly into (appropriate) native concrete types from (appropriate) data sources of (supported) data formats
- `AbstractTrees.jl` 
    - Add wrappers around `MetaGraphsNext.jl` concrete types to provide `AbstractTree` interface

## Scope of community support (Integrated "consumer packages")

Community support in this project is divided into three categories.

### Category 1 — Graph-construction targets

These are packages into which LineagesIO constructs graph objects directly
through package extensions.

Phase 1 focal graph-construction targets:

- `MetaGraphsNext.jl`
- `PhyloNetworks.jl`
- `Phylo.jl`

### Category 2 — Downstream consumer compatibility

These are packages whose contracts shape the design of returned handles,
wrappers, and accessors, even when LineagesIO does not construct their objects
directly in core.

Phase 1 focal downstream-consumer targets:

- `AbstractTrees.jl`

### Category 3 — Future integration targets

These are important ecosystem contexts whose support is ratified as future work
but not fully implemented in phase 1.

Phase 2 and future targets include:

- `Nexus` ingestion support through phase-appropriate construction targets
- `TskitTrees` and related genealogical-table formats
- additional ratified ecosystem packages as approved later

## Extension architecture

### Weak-dependency model

First-class ecosystem integrations must be implemented as Julia package
extensions.

Core `LineagesIO` must not depend hard on `MetaGraphsNext.jl`, `Phylo.jl` or `PhyloNetworks.jl`.

The extension loading model is:

- LineagesIO core is always loadable by itself
- an extension activates automatically only when both LineagesIO and the target
  package are loaded in the same Julia session
- the target package remains optional from the perspective of LineagesIO core

### Extension module layout

Extension modules live under `ext/`.

Phase 1 extension modules are:

- `ext/MetaGraphsNextIO.jl`
- `ext/PhyloExt.jl`
- `ext/PhyloNetworksExt.jl`

Each extension module owns:

- the target-package handle wrapper type or rootnode wrapper type
- `bind_rootnode!` methods for supplied-root construction into that package
- `add_child` methods for library-created-root and descendant construction into
  that package
- `finalize_graph!` methods when the target package requires post-build cleanup
- optional package-specific convenience accessors

### Extension ownership boundary

Extensions may:

- allocate and mutate target-package graph objects
- parse retained annotation text values into richer semantic types for that
  target package
- choose which retained annotations to project into target-package node or edge
  metadata stores
- keep only structural information on target-package graph objects and rely on
  authoritative LineagesIO tables for other annotations

Extensions must not:

- reimplement source parsing already owned by LineagesIO core
- redefine the distinguished structural contract
- invent alternative builder-boundary payload containers
- rely on runtime-generated struct fields derived from retained annotation names
- weaken the one-rootnode-per-graph contract

## Core-to-extension contract

All ecosystem extensions must consume the public core protocol defined in
`design/brief.md`.

At the extension boundary, the package guarantees:

- `StructureKeyType` for all package-assigned structural keys
- one `rootnode` per graph
- authoritative package-owned `node_table` and `edge_table`
- one row per node in `node_table`
- one row per edge in `edge_table`
- retained non-structural node annotations preserved in `node_table`
- retained non-structural edge annotations preserved in `edge_table`
- retained non-structural annotation values preserved as `Union{Nothing,String}`
- row-reference delivery through `nodedata::NodeRowRef` and
  `edgedata::EdgeRowRef` or vectors of edge row references

The extension boundary does not guarantee:

- semantic coercion of retained non-structural annotations in core
- field-style annotation access such as `nodedata.bootstrap`
- copied annotation dictionaries or source-shaped `NamedTuple` payloads
- package-specific graph metadata semantics in core

## Root binding, descendant construction, and finalization

Every extension must be designed around the three public core protocol
functions:

- `bind_rootnode!`
- `add_child`
- `finalize_graph!`

### `bind_rootnode!`

An extension implements `bind_rootnode!` when the target package supports
loading into a caller-supplied rootnode handle through `load(src, rootnode)`.

This hook is for binding the parsed root node onto an already-existing graph
entry point in the target package.

### `add_child`

An extension implements `add_child` for:

- library-created root construction when the caller supplies `load(src, NodeT)`
- single-parent descendant construction for rooted trees or rooted graphs whose
  current node has one incoming edge
- multi-parent descendant construction for rooted networks or rooted graphs
  whose current node has multiple incoming edges

### `finalize_graph!`

An extension implements `finalize_graph!` only when the target package requires
post-build cleanup or normalization after all root binding and descendant
construction events are complete.

## Annotation-handling expectations for extensions

### Extension responsibility for annotation meaning

LineagesIO core preserves retained non-structural annotation values as text.

Extensions decide:

- which retained fields they care about
- when to interpret those fields
- how to interpret those fields
- whether to store interpreted values on target-package graph objects
- whether to leave some or all annotation interpretation to later user-space
  wrappers

### Immediate interpretation during construction

An extension may parse retained annotation values directly from row references
during `bind_rootnode!` or `add_child`.

Example shape:

```julia
txt = edge_property(edgedata, :gamma)
gamma = txt === nothing ? nothing : parse(Float64, txt)
```

### Deferred interpretation after construction

An extension may also choose not to store a semantic value on the target graph
object and instead rely on the authoritative LineagesIO tables later.

Example shape:

```julia
bootstrap(asset.node_table, node.nodekey)
hybrid_gamma(asset.edge_table, edge.edgekey)
```

### Projection into target-package metadata stores

If a target package exposes its own node or edge metadata storage, an extension
may project retained annotations into that storage.

This projection is optional and target-specific. The authoritative preserved
store remains the LineagesIO tables.

### No obligation to project every retained field

An extension is not required to copy every retained field from the
authoritative tables onto the target-package graph object.

The minimum requirement is:

- correct structural construction in the target package
- authoritative tables still available to the user after load
- documented package-specific accessors for any important interpreted fields

## Focal package support matrix

### Phase 1

| Package | Support type | Structural tier | Priority |
|---|---|---|---|
| `Phylo.jl` | direct construction extension | single-parent | Phase 1 |
| `PhyloNetworks.jl` | direct construction extension | multi-parent | Phase 1 |
| `AbstractTrees.jl` | downstream traversal compatibility target | consumer-facing | Phase 1 |

### Phase 2

| Package or format context | Support type | Priority |
|---|---|---|
| `Nexus` | source-format expansion through phase-appropriate targets | Phase 2 |
| `TskitTrees` | source-format and ecosystem expansion | Phase 2 |
| additional ratified packages | extension or consumer compatibility | Future |

## PhyloNetworks.jl support objectives

### Role

`PhyloNetworks.jl` is the primary phase 1 rooted-network construction target.

Its importance comes from:

- direct support for reticulate and hybrid evolutionary structures
- explicit hybrid-edge semantics
- established use in the Julia phylogenetics community

### Construction tier

`PhyloNetworks.jl` support must use the multi-parent construction tier.

A rooted network still has one `rootnode`. Hybrid or reticulate interior nodes
are constructed through multi-parent `add_child` calls, not through multiple
roots.

### Extension wrapper responsibility

The extension must define a wrapper or handle type that is sufficient to carry:

- the target `HybridNetwork`
- the current target `Node`
- any additional extension-local state needed to satisfy the construction
  protocol cleanly

The wrapper design must preserve concrete field types and follow
`STYLE-julia.md`.

### Structural mapping expectations

The extension must map:

- `nodekey` to stable node identity in its wrapper and any needed lookup path
- `edgekey` to stable edge identity in any extension-local edge lookup path
- `label` to target-package node naming as appropriate
- `edgeweight` to target-package edge-length storage as appropriate

If `PhyloNetworks.jl` requires unique node names for internal mechanics, any
extension-local name normalization is the extension's responsibility. Such
normalization does not change the authoritative `label` preserved by LineagesIO.

### Annotation interpretation expectations

The extension should interpret important retained fields when they are needed by
`PhyloNetworks.jl` itself.

Typical examples include:

- `gamma`
- support-like values when projected onto target-package edge or node fields

The extension may interpret those values during construction directly from row
references.

### Finalization expectations

If `PhyloNetworks.jl` requires post-build normalization or validation after
incremental construction, the extension must implement `finalize_graph!`.

Any required post-build actions must be verified against upstream source and
documented in the extension test plan.

### Format support expectations

Phase 1 `PhyloNetworks.jl` extension support must cover:

- `format"LineageNetwork"`
- rooted-network-capable Newick support as ratified by core format policy

Phase 2 work may extend this to:

- `format"Nexus"` where ratified and implemented in core

## Phylo.jl support objectives

### Role

`Phylo.jl` is the primary phase 1 rooted-tree construction target.

Its importance comes from:

- broad Julia ecosystem familiarity
- native rooted-tree constructors
- existing metadata handling conventions
- relevance for ordinary rooted-tree workflows

### Construction tier

`Phylo.jl` support must use the single-parent construction tier for rooted-tree
formats.

The extension must reject or decline formats whose structure requires the
multi-parent construction tier if the target package cannot represent them.

### Extension wrapper responsibility

The extension must define a wrapper or handle type that is sufficient to carry:

- the target `RootedTree` or equivalent target tree object
- the current target node reference or node identifier needed for incremental
  construction
- any additional extension-local state needed to satisfy the construction
  protocol cleanly

The wrapper design must preserve concrete field types and follow
`STYLE-julia.md`.

### Structural mapping expectations

The extension must map:

- `nodekey` to stable node identity in its wrapper and any needed lookup path
- `edgekey` to stable edge identity in any extension-local edge lookup path
- `label` to target-package node naming as appropriate
- `edgeweight` to target-package branch-length storage as appropriate

If `Phylo.jl` requires unique node names for internal mechanics, any
extension-local name normalization is the extension's responsibility. Such
normalization does not change the authoritative `label` preserved by LineagesIO.

### Annotation interpretation expectations

`Phylo.jl` support may choose either of the following strategies, provided the
behavior is documented and verified:

- project selected retained fields into `Phylo.jl` node or branch metadata
  stores
- keep target-package objects structurally minimal and rely primarily on the
  authoritative LineagesIO tables for annotation access

In either case, semantic interpretation of retained annotation text values
belongs to the extension or to later user-space wrappers, not to core.

### Finalization expectations

If `Phylo.jl` construction does not require post-build cleanup, the extension
may rely on the default no-op `finalize_graph!`.

If upstream-verified cleanup is required, the extension must implement and
verify it explicitly.

### Format support expectations

Phase 1 `Phylo.jl` extension support must cover:

- `format"Newick"` for rooted-tree construction

Phase 2 work may extend this to:

- `format"Nexus"` where ratified and implemented in core

## AbstractTrees.jl and Graphs.jl objectives

### AbstractTrees.jl

LineagesIO does not need to construct `AbstractTrees.jl` objects directly.

Instead, the community objective is that target-package wrappers and loaded
graph objects remain compatible with `AbstractTrees.jl` traversal patterns when
the user or the extension supplies the required traversal methods.

Core design choices that support this objective include:

- one `rootnode` per graph
- explicit child-construction semantics
- stable node identity through `nodekey`

## Verification requirements for community support

No ecosystem integration may be considered complete without direct,
package-specific verification.

At minimum, each first-class extension must verify:

- extension activation through Julia package extensions
- root creation through `load(src, NodeT)`
- root binding through `load(src, rootnode::NodeT)` when supported
- single-parent descendant construction where applicable
- multi-parent descendant construction where applicable
- correct mapping of `label`
- correct mapping of `edgeweight`
- correct structural preservation of `nodekey` and `edgekey`
- correct interpretation path for any important retained annotation fields the
  extension claims to support semantically
- authoritative `node_table` and `edge_table` availability after load
- deferred annotation access after load through authoritative tables
- post-build finalization where applicable
- rejection or error behavior for unsupported structural cases

Verification must include both:

- extension-level tests
- end-to-end load tests from real or representative source text into the target
  package

Weak proxies are forbidden. For example:

- proving that a target graph exists is not enough
- proving that a file parsed is not enough
- proving that one row exists in a table is not enough

The tests must verify field-level structural correctness and any claimed
annotation interpretation behavior.

## Success criteria

Community support is successful when all of the following are true.

- `PhyloExt` constructs rooted trees from phase 1 supported formats through the
  public core protocol
- `PhyloNetworksExt` constructs rooted networks from phase 1 supported formats
  through the public core protocol
- users can choose library-created-root construction or supplied-root binding
  where the extension supports both
- authoritative `node_table` and `edge_table` remain available and useful after
  extension-based graph construction
- important retained annotation fields can be interpreted either during
  extension construction or later through package-specific wrappers
- rooted-network construction uses one `rootnode` and multi-parent descendant
  events rather than any multiple-root assumption
- extension work remains a thin projection layer over authoritative core tables
  and public protocol events rather than a shadow parser stack
- downstream users can bridge loaded graphs into traversal and visualization
  consumers through package-specific accessors without requiring core redesign

## Contracts that do not exist

The following are not part of the community-support contract and must not be
introduced downstream without explicit approval.

- extension-local replacement parsers for formats already owned by LineagesIO
  core
- extension-local redefinition of structural keys or structural field names
- extension-local builder-boundary payload bags, dictionaries, or generated
  struct fields in place of authoritative core row references
- a requirement that every retained annotation be copied into target-package
  graph objects
- a requirement that target-package graph objects expose direct field-style
  access to retained annotations
- any assumption that rooted networks require multiple roots
- any assumption that authoritative LineagesIO tables are optional after
  extension-based graph construction

## Fundamental implementation mandates

Reading of `design/brief.md` is mandated alongside this document.

Reading and compliance with all applicable `STYLE-*.md` files and
`CONTRIBUTING.md` are mandated and must be passed forward into all downstream
work.

In particular, note terminological policies in `STYLE-vocabulary.md`, together
with the LineagesIO-specific core identifiers and public protocol names
ratified by the core brief:

- `StructureKeyType`
- `nodekey`
- `edgekey`
- `src_nodekey`
- `dst_nodekey`
- `edgeweight`
- `rootnode`
- `bind_rootnode!`
- `add_child`
- `finalize_graph!`
- `node_table`
- `edge_table`
- `NodeRowRef`
- `EdgeRowRef`

Reading of the key technological context named above is mandated for this
project, and downstream community reading of those sources is required
whenever their contracts are in scope.
