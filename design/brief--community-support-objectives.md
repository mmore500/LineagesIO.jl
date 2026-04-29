---
date-created: 2026-04-26T00:00:00
date-revised: 2026-04-28T00:00:00
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

`design/brief--community-support-user-stories.md` is the authoritative
user-story annex to this document. It must be read alongside this document when
planning tranches, tasking, verification, or consumer-facing syntax examples.
It anchors intended ecosystem support through numbered user stories and Julia
syntax examples. It does not relax, replace, or override any contract stated
in either governing brief.

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

When upstream behavior matters, verified source text governs. Memory,
secondary summaries, and plausible recollection do not.

## Purpose

The core LineagesIO.jl package will be extended (using Julia's package extension mechanism) to provide supported for **DESERIALIZATION**:

- `MetaGraphsNextIO`
    - Triggered on `MetaGraphsNext`, will provide native materialization of `MetaGraphsNext.jl` types from support data source formatted-files.
    - `AbstractTrees.jl` interface will be added through wrapper functions on appropriate `MetaGraphsNextIO.jl` types.
- `PhyloNetworksIO`
    - Triggered on `PhyloNetworks.jl`, as above for native object materialization from any supported data source.

Current native-construction scope in this companion brief is limited to
`MetaGraphsNextIO` and `PhyloNetworksIO`. Additional native consumer packages
are deferred and must not be treated as current tranche, tasking, or
user-story-fulfillment targets unless explicitly reauthorized.

- which ecosystem packages receive first-class extension support, as reference examples of how consumer packages can black-box wide-spectrum deserialization and materialize custom native phylogenetic data types
- what kind of support each package receives in terms of data
- what responsibilities belong to LineagesIO core and what responsibilities
  belong to extension packages
- what public load surfaces consumers use to materialize native target-package
  types without reaching into extension internals
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

We want not to allow fast and economical loading of very large trees or networks (at the lazy iterator level) and 
also very large collections of very large trees or networks (at both file and iterator level).

At the same time, the data can always be dereferenced at any client-side end 
point by dereferencing the references and we can have some nice idiomatic usability by providing syntactic sugars or wrappers (e.g. getproperty overrides, `node_property(graph, node, :fieldname)`
So we do not try to promote metadata to fieldnames or store them locally in the nodes.
Instead we can the tables which can be part of the graph if we own it in our data model and/or by that can somehow be returned to and used by the client, using wrappers, shims, methods, etc.

Read the primary brief, `brief.md` to confirm, and confirm 
code implementation conforms to this, and evaluate that this is a good design.
If there are any problems or logical issues, we need to discuss and revise.

At time of implementation, it would be good to review current architecture and code and understanding to confirm that this is all a good fit.

LineagesIO is not a competing graph-model package. It is the package that
loads rooted lineage graph sources, preserves authoritative structure and
retained annotations, and makes that content available to target packages
through stable public protocols.

## User story annex

`design/brief--community-support-user-stories.md` is the authoritative
user-story annex for this companion brief.

Its purpose is to anchor:

- the staged extension deliverables, with `MetaGraphsNext.jl` first and the
  `PhyloNetworks.jl` soft release centered on rooted-network-capable
  `format"Newick"`
- the priority of `MetaGraphsNext.jl` as the reference-standard consumer
- the consumer-facing syntax shapes that tranche plans should target
- extension-specific verification expectations and rejection behavior

All downstream tranche and tasking documents derived from this brief must cite
the relevant numbered user stories from that annex when those stories are in
scope.

If a code example in that annex conflicts with a ratified contract in this
document or in `design/brief.md`, the governing brief or briefs govern and the
annex must be revised.

## Scope-hardening rules for extension specs and examples

Extension-facing briefs, tranche files, tasking files, and verification plans
must use only ratified core format owners when they define near-term
deliverables.

For the current phase 1 soft-release sequence, the domain-focal production
surface is `load(src, HybridNetwork)` from rooted-network-capable
`format"Newick"` sources.

Provisional format names, extension-private handle concepts, and placeholder
helper names must not appear in near-term user stories, acceptance criteria,
or verification plans as if they were already public contracts.

If a document discusses a future format or helper surface, it must label that
item as future scope and must not couple it to current tranche gates.

## Community support objectives

The package must satisfy all of the following community-facing objectives.

It must support first-class construction into focal consumer packages through
Julia package extensions rather than by embedding those packages as hard
dependencies in core.

It must present consumer-facing load surfaces in terms of native target-package
types or instances whenever that can be supported cleanly and idiomatically.
Extension-private handles, cursors, and helper wrapper types may exist
internally, but they must not become the default user-facing materialization
API unless a specific exception is explicitly ratified.

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

- `MetaGraphsNext.jl`, `PhyloNetworks.jl`
    - Building from parser directly into (appropriate) native types from (appropriate) data sources of (supported) data formats
- `AbstractTrees.jl` 
    - Add wrappers around `MetaGraphsNext.jl` types to provide `AbstractTree` interface

## Scope of community support (Integrated "consumer packages")

Community support in this project is divided into three categories.

### Category 1 — Graph-construction targets

These are packages into which LineagesIO constructs graph objects directly
through package extensions.

Phase 1 focal graph-construction targets:

- `MetaGraphsNext.jl`
- `PhyloNetworks.jl`

### Category 2 — Downstream consumer compatibility

These are packages whose contracts shape the design of returned native graph
objects, optional wrappers, and accessors, even when LineagesIO does not
construct their objects directly in core.

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

Core `LineagesIO` must not depend hard on `MetaGraphsNext.jl` or
`PhyloNetworks.jl`.

The extension loading model is:

- LineagesIO core is always loadable by itself
- an extension activates automatically only when both LineagesIO and the target
  package are loaded in the same Julia session
- the target package remains optional from the perspective of LineagesIO core

### Extension module layout

Extension modules live under `ext/`.

Phase 1 extension modules are:

- `ext/MetaGraphsNextIO.jl`
- `ext/MetaGraphsNextAbstractTreesIO.jl`
- `ext/PhyloNetworksIO.jl`

`ext/MetaGraphsNextIO.jl` and `ext/PhyloNetworksIO.jl` own direct native
graph construction. `ext/MetaGraphsNextAbstractTreesIO.jl` owns the
`AbstractTrees.jl` compatibility layer over `MetaGraphsNextIO` materialized
graphs.

Each extension module owns:

- the native-target materialization methods behind `load(src, TargetType)` and,
  when supported, `load(src, target)`
- any extension-private cursor types, label wrapper types, or lookup
  structures needed for internal construction
- `bind_rootnode!` methods for supplied-root construction into that package
- `add_child` methods for library-created-root and descendant construction into
  that package
- `finalize_graph!` methods when the target package requires post-build cleanup
- optional package-specific convenience accessors

### Extension ownership boundary

Extensions may:

- allocate and mutate target-package graph objects
- allocate internal cursor or helper state needed to satisfy the construction
  protocol cleanly
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
- require callers to use `Base.get_extension(...)` to reach a public
  materialization target
- require callers to import extension-private handle or cursor types in order
  to materialize native target-package structures
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
loading into a caller-supplied native target or other construction entry object
through `load(src, rootnode)`.

This hook is for binding the parsed root node onto an already-existing target
package entry point.

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

As noted above, data can also be dereferenced from graph-level tables, and 
should be preferred if it does not break other design principles for 
scaling to large trees.

### Deferred interpretation after construction

An extension may also choose not to store a semantic value on the target graph
object and instead rely on the authoritative LineagesIO tables later.

Example shape:

```julia
bootstrap(asset.node_table, node.nodekey)
hybrid_gamma(asset.edge_table, edge.edgekey)
```

This is the preferred mechanism for performance reasons. 
We can layer in convenience wrappers, delegates, dispatches, etc. as needed to improve client experience based on how the ownership and semantic boundaries and constructed between LineagesIO and the consumer package.
We would like to structure in the node and edge table data into data model using various idiomatic mechanisms (e.g if we owned it or the consumer package architecture allowed some sort of field addition or property annex).
Review implementation with lead developer before committing.
(HIL)

### Projection into target-package metadata stores

If a target package exposes its own node or edge metadata storage, an extension
may provide an option for projecting retained annotations into that storage; but this should default to the more performant mechanism described above to keep nodes lightweight.
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
| `MetaGraphsNext.jl` | direct construct extension | single-parent, multi-parent, general graph | Phase 1 |
| `AbstractTrees.jl` | downstream traversal compatibility target | consumer-facing | Phase 1 |
| `PhyloNetworks.jl` | direct construction extension | rooted single-parent, rooted multi-parent | Phase 1 |

### Phase 2

| Package or format context | Support type | Priority |
|---|---|---|
| `Nexus` | source-format expansion through phase-appropriate targets | Phase 2 |
| `TskitTrees` | source-format and ecosystem expansion | Phase 2 |
| additional ratified packages | extension or consumer compatibility | Future |

## MetaGraphsNext.jl support objectives

### Role

`MetaGraphsNext.jl` is the primary phase 1 graph construction target.

Its importance comes from:

* ability to represent arbitrary graph structure (trees, DAGs, general graphs)
* separation of structural graph from metadata
* stable node labeling independent of internal graph codes
* compatibility with the `Graphs.jl` ecosystem

If this extension is correct, it forms the reference implementation for all
general graph materialization in LineagesIO.

If we can support this package's abstractions, we can support any phylogenetic structure.

The public MetaGraphsNext load surface must be expressed in terms of native
`MetaGraph` types or instances, not extension-private node-handle types.

### Construction tier

`MetaGraphsNext.jl` support must implement:

* single-parent construction tier (trees)
* multi-parent construction tier (networks)

In all cases:

* exactly one `rootnode` is used as the entry point
* unrooted trees are treated as rooted at a distinguished node
* reticulate nodes are constructed via multi-parent `add_child` calls

No multiple-root semantics are permitted.

### Extension-private construction state responsibility

The extension may define private cursor or helper types sufficient to carry:

* the target `MetaGraph`
* the current node identity as a non-integer label value — an extension-local
  wrapper type that holds a `StructureKeyType` value; never `StructureKeyType`
  directly (see the structural mapping note below)
* a mapping between `nodekey` and target graph node identity
* any extension-local lookup structures required for:

  * node resolution
  * edge resolution (if needed)
  * parent tracking (for directed construction)

Any such types are internal implementation detail unless explicitly ratified
otherwise. The public surface must remain the native `MetaGraph` target.

The internal-state design must:

* preserve concrete field types
* avoid abstract fields
* follow `STYLE-julia.md`

### Structural mapping expectations

The extension must map:

* `nodekey`
  → stable node identity via a non-integer label wrapper type

  **Hard constraint**: `StructureKeyType = Int`. MetaGraphsNext's internal vertex
  code type is also `Code<:Integer`. The MetaGraphsNext source *recommends*
  that integer types must not be used as the `Label` type parameter because vertex
  labels (stable, user-supplied) and vertex codes (mutable internal integers) must
  be distinct types. 
  The extension can pin an internal fixed type (e.g. `Symbol`) that we will use to 
  map our `nodekey` <=> MetaGraphsNext `label`.

* `edgekey`
  → stable edge identity (must be tracked extension-locally; MetaGraphsNext does not provide intrinsic edge IDs)

* `edgeweight`
  → edge weight storage (either:

  * Graphs.jl weight system, or
  * edge metadata field)

### Annotation interpretation expectations

None required.

The extension may:

* store annotation text directly in node/edge metadata, or
* ignore annotation projection and rely entirely on authoritative tables

Interpretation is downstream responsibility.

### Finalization expectations

If required by construction mechanics:

* the extension must implement `finalize_graph!`

Possible responsibilities include:

* ensuring all nodes exist before edge insertion (if deferred)
* resolving label → vertex-code mappings
* validating graph invariants (e.g. no missing endpoints)

All behavior must be verified against upstream `MetaGraphsNext.jl` contracts.

### Format support expectations

Phase 1 `MetaGraphsNext.jl` extension support must cover:

* `format"Newick"`
* rooted-tree Newick
* rooted-network-capable Newick
* unrooted-tree Newick
* unrooted-network-compatible Newick (as ratified)

Phase 2 work may extend this to:

* `format"Nexus"`
* other formats

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

The public `PhyloNetworks.jl` load surface must be expressed in terms of native
`HybridNetwork` types or instances, not extension-private node-handle types.

### Extension-private construction state responsibility

The extension may define private cursor or helper state sufficient to carry:

- the target `HybridNetwork`
- the current target `Node`
- any additional extension-local state needed to satisfy the construction
  protocol cleanly

Any such state is internal implementation detail unless explicitly ratified
otherwise. The public surface must remain the native `HybridNetwork` target.

The internal-state design must preserve concrete field types and follow
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

- rooted-network-capable `format"Newick"`
- tree-compatible rooted `format"Newick"` loads only where they are part of
  the same verified native `HybridNetwork` workflow

Phase 2 work may extend this to:

- additional ratified core formats such as `format"Nexus"` where they are
  implemented in core and explicitly approved for this extension

## Deferred additional native consumer packages

Additional native consumer-package integrations beyond `MetaGraphsNext.jl` and
`PhyloNetworks.jl` are explicitly deferred beyond the current soft-release
sequence.

No current tranche, tasking file, user-story fulfillment claim, or acceptance
gate may treat a deferred native consumer package as part of active phase-1
scope.

If later work authorizes another native consumer package, that work must first
ratify:

- the upstream primary sources that govern the target package
- the exact public `load` surfaces to expose
- the structural tier the target can represent honestly
- the extension-module filename and ownership boundaries
- package-specific verification and rejection behavior

Until that reauthorization exists, current community-support scope is complete
when `MetaGraphsNext.jl`, `MetaGraphsNextAbstractTreesIO`-mediated
`AbstractTrees.jl` compatibility, and `PhyloNetworks.jl` behavior are
correctly specified and verified.

## AbstractTrees.jl

### AbstractTrees.jl

LineagesIO does not need to construct `AbstractTrees.jl` objects directly.

Instead, the community objective is that loaded native graph objects and any
optional compatibility wrappers remain compatible with `AbstractTrees.jl`
traversal patterns when the user or the extension supplies the required
traversal methods.

Core design choices that support this objective include:

- one `rootnode` per graph
- explicit child-construction semantics
- stable node identity through `nodekey`

## Verification requirements for community support

No ecosystem integration may be considered complete without direct,
package-specific verification.

At minimum, each first-class extension must verify:

- extension activation through Julia package extensions
- native-target creation through `load(src, TargetType)`
- native-target binding through `load(src, target)` when supported
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
- absence of any requirement for callers to use extension-private handle types
  or `Base.get_extension(...)` in the public happy path

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

- `MetaGraphsNextIO` constructs 
    - rooted trees 
    - unrooted trees
    - rooted networks
    - structures isomorphic to `PhyloNetworks.jl` reticulation networks
- `MetaGraphsNextAbstractTreesIO` provides `AbstractTrees.jl`-compatible
  wrappers over `MetaGraphsNextIO` materializations for rooted trees and
  unrooted trees with a distinguished `rootnode`
- `PhyloNetworksIO` constructs rooted networks and tree-compatible rooted
  inputs from phase 1 supported formats through the public core protocol
- users can choose library-created native-target construction or supplied-target
  binding where the extension supports both
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
- a requirement that callers import extension-private handle types or use
  `Base.get_extension(...)` to request native package materialization
- a requirement that every retained annotation be copied into target-package
  graph objects
- a requirement that target-package graph objects expose direct field-style
  access to retained annotations
- any assumption that rooted networks require multiple roots
- any assumption that authoritative LineagesIO tables are optional after
  extension-based graph construction

## Fundamental implementation mandates

Reading of `design/brief.md` is mandated alongside this document.

Reading of `design/brief--community-support-user-stories.md` is mandated
alongside this document whenever planning or implementing extension-facing
behavior, early deliverables, consumer-package verification, or tranche
boundaries for ecosystem support.

Reading of `design/brief--user-stories.md` is also mandated whenever the work
touches shared core-loading behavior, authoritative table usage, or public
loading syntax that spans the core and extension boundary.

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
