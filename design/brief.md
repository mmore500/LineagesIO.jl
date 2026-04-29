---
date-created: 2026-04-26T00:00:00
date-revised: 2026-04-28T00:00:00
status: authoritative
---

# LineagesIO.jl — Core design brief

## Authority

This document is the primary design authority for the core architecture,
public contracts, ownership boundaries, terminology, and verification
expectations of LineagesIO.jl.

All downstream planning documents, tranche files, tasking files, audit scopes,
review instructions, implementation work, and extension work must conform to
this document.

If any companion or downstream document conflicts with this document, this
document governs the core package design. Companion and downstream documents
must be revised to match it.

`design/brief--community-support-objectives.md` remains a mandatory companion
document for extension architecture, upstream parse-stack reference, and target
ecosystem support. It must be read alongside this document. It does not relax,
replace, or override any core contract stated here.

`design/brief--user-stories.md` is the authoritative user-story annex to this
document. It must be read alongside this document when planning tranches,
tasking, verification, or public API examples. It anchors intended use through
numbered user stories and Julia syntax examples. It does not relax, replace,
or override any core contract stated here.

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
- restating the core package contract directly and completely enough for a new
  reader to apply it correctly without consulting separate explanatory context

No downstream plan, tranche, task, review scope, or delegated work description
is valid if it silently drops these obligations.

Community compliance is mandatory. This document is not only an internal design
note for one implementation pass. It is the anchor text for repeated
contributor and agent cycles. Downstream work must continue to cite it and
continue to propagate its mandates.

## Upstream primary sources

The following upstream primary sources materially constrain the design of the
package and must be read line by line before implementing the relevant parts of
the system.

Available at `/home/jeetsukumaran/site/storage/local/00_resources/codebases-and-documentation/`:

Core technologies:

| Source | Relevance |
|---|---|
| `fileio.jl/` | FileIO backend contract; `DataFormat`; `File` and `Stream`; `add_format`; private `load` and `save`; dispatch and detection semantics |
| `Graphs.jl/` | Key consumer domain ecosystem, providing common abstractions, interfaces, etc. |
| `MetaGraphsNext.jl/` | Key consumer support target package for which we will provide first-class support for using the package extension mechanism |
| `AbstractTrees.jl/` | Traversal traits and iteration interface; to be supported by wrapping appropriate `MetaGraphsNext.jl` types in the package extension |
| `PhyloNetworks.jl/` | Extended Newick with hybrid nodes parsing reference; Domain consumer support target; extension target to be provided with native support like `MetaGraphsNext.jl` |
| `Tables.jl/` | Tables.jl interface and materialization contract for authoritative table ownership and retention |

When upstream behavior matters, verified source text governs. Memory,
secondary summaries, and plausible recollection do not.

## Purpose

LineagesIO.jl provides FileIO-compatible loading and saving of rooted
phylogenetic graph data together with package-native lazy access to graph
collections.

It serves four roles:

- a FileIO backend for lineage graph formats
- a parsing and format-detection layer
- an authoritative table-building layer for structural graph data and retained
  source annotations
- an orchestration layer that maps parsed structure into user-specified graph
  or node representations through a public construction protocol

The package does not define the user's graph model. It defines how parsed
structure, retained source annotations, and optional graph construction are
delivered to user code.

## User story annex

`design/brief--user-stories.md` is the authoritative user-story annex for this
brief.

Its purpose is to anchor:

- intended public usage patterns
- tranche decomposition and dependency planning
- verification targets and failure-mode coverage
- public syntax examples for core loading, tables, and construction protocol

All downstream tranche and tasking documents derived from this brief must cite
the relevant numbered user stories from that annex when those stories are in
scope.

If a code example in the annex conflicts with a ratified core contract in this
document, this document governs and the annex must be revised.

## Scope-hardening rules for downstream specs and examples

This specification set distinguishes between:

- ratified current-scope format owners and public load surfaces
- phase-roadmap items that remain future work
- illustrative filenames, helper names, and examples

Downstream briefs, tranche files, tasking files, review scopes, examples, and
acceptance criteria must not treat a future format name, placeholder wrapper,
or example-only syntax as a ratified near-term contract.

A format or public load surface may appear in current-scope user stories,
tranche gates, or task verification only after the governing briefs define its
owner, structural protocol tier, detection policy, and phase placement
explicitly.

For the current phase 1 soft-release sequence, the near-term production target
is rooted-network-capable `format"Newick"` together with native
`PhyloNetworks.jl` materialization.

## Design objectives

The package must satisfy all of the following objectives.

It must provide idiomatic FileIO integration for supported phylogenetic formats
through `load`, `save`, explicit `File{format"..."}(...)`, and stream-based
entry points.

It must support multiple phylogenetic formats within one coherent package, with
each format implemented as a package-owned parser module rather than as an
ad hoc bundle of unrelated helpers.

It must support one-graph sources, multi-graph sources, and lazy iteration over
graph sources, where graph sources may contain single graphs, a collection of 
graphs, or multiple collections of graphs.

It must remain transparent to user domain types. All graph construction and
materialization is performed by user code either through normal Julia method
extension on the public protocol functions or through an explicit builder
callback.

It must give every loaded graph authoritative package-owned `node_table` and
`edge_table` objects that remain directly useful in user space after loading.

It must treat structural graph facts as a distinguished core contract rather
than as generic metadata.

It must preserve retained non-structural node and edge source annotations in
the authoritative tables under their source field names by default.

It must deliver retained node and edge annotation rows to builders through
small row-reference objects rather than through copied per-node or per-edge
bags (for generic type stability, performance, and scalability).

It must preserve retained non-structural annotations with no responsibility
for semantic coercion in core. 
Interpretation and coercion belong to format-specific and
consumer-specific layers.

It must scale to:

- huge trees and rooted networks
- many graphs in one source
- many huge graphs across many sources

while keeping structural handling concrete, row delivery lightweight, and
annotation preservation table-backed.

It must preserve FileIO's ownership model. FileIO remains the public
dispatcher. LineagesIO provides the actual parser, format detector, serializer,
and backend methods.

It must be engineered so that later FileIO registration requires minimal

It must remain type-stable through-out, and yet avoid or defer downstream as far as possible
any narrowing or constraining of types unless this breaks good design in a particular case.

## Non-goals

The package will not implement phylogenetic inference, reconciliation,
comparative methods, plotting, or analysis algorithms as primary
responsibilities.

The package will not define a default concrete domain graph type in core. If a
shared normalized graph type is ever needed, that responsibility belongs to a
separate package.

The package will not define a package-wide semantic ontology for source
annotation names such as `bootstrap`, `gamma`, `posterior`, `species`, or
other non-structural fields.

The package will not coerce retained non-structural source annotations into
semantic numeric or logical types in core.

The package will not guarantee direct field-style access such as
`nodedata.bootstrap`, `edgedata.gamma`, or `node.bootstrap` as a generic core
contract.

The package will not treat generic GraphML as a LineagesIO-owned format. Only
the package-ratified phylogeny-specific profile belongs here.

The package will not require FileIO registry inclusion in order to be
considered complete, though it must be engineered so that later registration
requires minimal redesign.

## Core architectural commitments

The package is built around the following non-negotiable commitments.

### Structure first

The core package owns graph structure and structural identity. Structural facts
are not treated as ordinary metadata.

### Core-owned authoritative tables

The core package owns the authoritative `node_table` and `edge_table` for each
loaded graph. These tables are the primary preserved representation of
structure and retained node and edge annotations.

### Source-name annotation preservation

Retained non-structural node and edge source annotations are preserved in the
authoritative tables under their source field names by default. Optional
mapping functions may rename those fields before table assembly.

### Raw annotation values in core

Retained non-structural annotations are preserved in core without semantic
coercion. Core preserves text values; format-specific and consumer-specific
layers interpret those values.

### Row-reference delivery at build time

The public construction protocol receives `nodedata` and `edgedata` as small
row-reference objects into the authoritative tables. The protocol does not pass
copied per-node or per-edge metadata bags.

### Interpretation outside core

The core package preserves structure and retained annotations. Format-specific
and consumer-specific code decides how to parse, coerce, cache, and expose
those annotations.

### Single owner per invariant

Parsers own source parsing and field extraction. The orchestration layer owns
key assignment, table assembly, root binding, protocol routing, and asset
assembly. Extensions own only the translation from the core protocol into
target-package graph construction and user-facing accessors.

## Structural contract

The structural contract is the core package's stable, format-independent model
of graph identity and graph edges.

### Structural key type

The package defines:

```julia
const StructureKeyType = Int
```

`StructureKeyType` is the canonical public key type for all distinguished
structural keys in phase 1.

All public contracts, tables, helper APIs, and row-reference objects that
traffic in package-assigned structural keys must use `StructureKeyType`
semantically, even when the concrete underlying type remains `Int`.

### One rootnode per graph

Each loaded graph asset has exactly one graph entry point, referred to in exact
API names as `rootnode`.

This applies to rooted trees and rooted networks alike. Rooted networks still
have one `rootnode`. Reticulation is represented by multi-parent interior nodes,
not by multiple roots.

### Node identity

`nodekey` is the distinguished node identity key.

Its contract is:

- type: `StructureKeyType`
- scope: unique within one graph
- ownership: assigned by the orchestration layer
- semantics: primary key of the node table; structural key for node lookup;
  foreign key target of all node references in returned tables

`nodekey` is assigned sequentially in traversal order, starting at `1` for each
graph.

### Edge identity

`edgekey` is the distinguished edge identity key.

Its contract is:

- type: `StructureKeyType`
- scope: unique within one graph
- ownership: assigned by the orchestration layer
- semantics: primary key of the edge table; structural key for edge lookup

`edgekey` is assigned sequentially within each graph.

### Label

`label` is a distinguished structural node property.

Its contract is:

- type at the public protocol boundary: `AbstractString`
- stored form in authoritative tables: `String`
- semantics: raw source label, passed through unchanged
- missing-label rule: parsers pass `""`

The core package performs no label disambiguation and no synthetic label
generation.

### Edge weight

`edgeweight` is a distinguished structural edge property.

Its contract is:

- type at the public protocol boundary: `Union{EdgeUnitT, Nothing}`
- stored form in `edge_table` for phase 1 numeric formats:
  `Union{Float64, Nothing}`
- semantics: absent when the source does not supply a value

`edgeweight` is not ordinary annotation. It is part of the structural contract
in the same sense as `nodekey`, `edgekey`, and `label`.

### Edge endpoints

The core edge table always stores:

- `src_nodekey`
- `dst_nodekey`

These are distinguished structural join columns. They are not optional
annotation.

## Public loading surfaces

The package supports the following public loading surfaces:

- `load(src)`
- `load(src, NodeT)`
- `load(src, rootnode::NodeT)`
- `load(src; builder = fn)`

Their meanings are:

- `load(src)` loads into package-owned tables only and does not require a user
  graph materialization target
- `load(src, NodeT)` asks LineagesIO to create a materialized result through
  the public construction protocol for that target type
- `load(src, rootnode::NodeT)` asks LineagesIO to bind the parsed root node
  onto the supplied construction target and then construct descendants through
  the public construction protocol
- `load(src; builder = fn)` asks LineagesIO to use an explicit builder callback

For user-defined protocol implementations, `NodeT` is often a root-node or
node-handle type. For first-class package extensions, `NodeT` may instead be a
native graph or container type from the target package. Public extension load
surfaces must prefer native target-package types where that can be supported
cleanly and idiomatically.

Explicit format override is provided through FileIO wrappers such as
`File{format"..."}(...)` and `Stream{fmt}(io)`. This design does not define a
separate positional `load(src, FormatType())` signature.

A supplied `rootnode` target binds one graph. If a source yields more than one
graph, that loading surface is invalid and the package must raise an
informative error that directs the caller to a one-graph load surface or a
different construction path.

An explicit `builder = ...` callback and a supplied `rootnode::NodeT` target
represent different construction ownership models and must not be combined
implicitly.

## Root binding and child-construction protocol

The public graph-construction protocol consists of three functions:

- `bind_rootnode!`
- `add_child`
- `finalize_graph!`

`bind_rootnode!` binds a parsed root node onto a supplied construction target.
`add_child` materializes descendants. `finalize_graph!` performs optional
post-build cleanup after the final `add_child` call for a graph and before
`LineageGraphAsset` assembly, returning the value stored as the graph's
materialized result.

### `bind_rootnode!`

When the caller supplies `load(src, rootnode::NodeT)`, LineagesIO binds the
parsed root node onto that supplied target through:

```julia
function bind_rootnode!(
    rootnode::NodeT,
    nodekey::StructureKeyType,
    label::AbstractString;
    nodedata,
)::NodeT where {NodeT}
end
```

The contract of `bind_rootnode!` is:

- it is called exactly once for each graph loaded through
  `load(src, rootnode::NodeT)`
- it binds the distinguished structural root-node properties of the parsed
  graph onto the supplied target
- it may mutate the supplied target, validate it, or return an equivalent
  target
- it receives `nodedata` as a row reference into the authoritative node table
- it does not receive an `edgekey`, `edgeweight`, or `edgedata`, because the
  root node has no incoming edge

After `bind_rootnode!` returns, all descendant construction proceeds through
`add_child`, using the bound root return value as the parent handle where
appropriate.

### `add_child`

`add_child` is the central public function through which parsed descendants are
communicated to user code.

Everything in the parsing pipeline converges on calls to `bind_rootnode!`,
`add_child`, and `finalize_graph!`. LineagesIO calls them. User code or
extension code implements them.

### Library-created root node

When the caller uses `load(src, NodeT)` and LineagesIO is responsible for
creating the root node, the root-construction call is:

```julia
function add_child(
    ::Nothing,
    ::StructureKeyType,                   # nodekey
    ::AbstractString,                     # label
    ::Nothing,                            # edgekey
    ::Nothing;                            # edgeweight
    edgedata = nothing,
    nodedata,
)::NodeT where {NodeT}
end
```

This root-construction call is used for rooted trees and rooted networks
alike. The root node still has no incoming edge.

For generic user-defined protocol implementations, the returned `NodeT` is
typically the root node or root handle itself. For native package-extension
loads, the public requested result type may instead be a graph or container
type, while any extension-private per-node cursor state remains internal and
non-public.

### Single-parent descendant construction

For descendants with exactly one incoming parent edge:

```julia
function add_child(
    ::NodeT,
    ::StructureKeyType,                   # nodekey
    ::AbstractString,                     # label
    ::StructureKeyType,                   # edgekey
    ::Union{EdgeUnitT, Nothing};          # edgeweight
    edgedata,
    nodedata,
)::NodeT where {NodeT, EdgeUnitT}
end
```

### Multi-parent descendant construction

For descendants with multiple incoming parent edges:

```julia
function add_child(
    ::AbstractVector{NodeT},
    ::StructureKeyType,                           # nodekey
    ::AbstractString,                             # label
    ::AbstractVector{StructureKeyType},           # edgekeys
    ::AbstractVector{Union{EdgeUnitT, Nothing}};  # edgeweights
    edgedata,
    nodedata,
)::NodeT where {NodeT, EdgeUnitT}
end
```

### Public protocol semantics

At every `add_child` call:

- `nodekey` is the library-assigned structural node key for the node being
  created
- `label` is the raw source label, possibly `""`
- `edgekey` or `edgekeys` is the library-assigned structural incoming edge key
  or keys
- `edgeweight` or `edgeweights` is the distinguished structural incoming edge
  weight or weights
- `nodedata` is a row reference into the authoritative node table for the node
  being created
- `edgedata` is either `nothing`, one edge row reference, or a vector of edge
  row references for the incoming edge or edges

At every non-root `add_child` call, all ancestor handles already exist and are
in scope.

For generic user-defined protocol implementations, the returned `NodeT` is the
library's stored handle for that node in all subsequent protocol calls.
Native package extensions may keep additional private construction state
internally so long as the public requested materialized type remains the user-
facing result.

### Builder callbacks

An explicit `builder = fn` callback is a package-owned convenience surface. It
does not define a different graph contract.

If the package supports a callback builder, that callback path must receive or
be internally adapted to the same root-binding, child-construction, and
finalization events defined above, with the same structural values and the same
row-reference delivery contract.

### Protocol determination

The library determines the structural protocol tier once, before any
construction call.

This determination is owned by the format declaration, not by per-node runtime
inspection.

Formats that may produce nodes with multiple incoming edges declare the
multi-parent tier. Formats that encode only single-parent structure declare the
single-parent tier.

### Builder validation

Once the format declares its tier, the orchestration layer validates
compatibility of the supplied target before parsing begins where possible.

If the format declares the multi-parent tier and the supplied target is not
compatible with it, the library raises an informative error before any parse
work begins.

### Parse order

Parsers emit `bind_rootnode!` and `add_child` calls in top-down pre-order
traversal after completing whatever source analysis the format requires.

The package may pre-parse a graph or an entire source before emission if the
format requires it for structural correctness, collection handling, annotation
field discovery, table assembly, payload setup, or error reporting.

## Annotation preservation and delivery contract

In this document, a node or edge annotation is any parsed source field that is
not one of the distinguished structural properties:

- `nodekey`
- `edgekey`
- `label`
- `src_nodekey`
- `dst_nodekey`
- `edgeweight`

Everything outside that set is non-structural annotation.

### Ownership

The annotation contract is split as follows.

- The core package owns retention of retained annotations into the authoritative
  node and edge tables.
- Format parsers own extraction of source annotations and placement of those
  annotations onto the node side or edge side.
- Format-specific and consumer-specific code own semantic interpretation,
  coercion, caching, and user-facing convenience accessors.

### Field-name preservation

All retained node annotations become node-table fields.

All retained edge annotations become edge-table fields.

By default, the retained field name is the field name as found in the source.

The package may support optional field-name mapping functions for node
annotations and edge annotations. If such mapping functions are supplied, the
mapped names become the retained field names in the authoritative tables.

Any field-name mapping facility must satisfy all of the following:

- mapping is deterministic
- mapping is applied before table assembly
- mapping is one-to-one within a table
- mapping must not collide with structural field names
- mapping must not produce duplicate retained field names within one table

### Value preservation

The core package preserves retained non-structural annotation values as raw
source text.

The authoritative `node_table` and `edge_table` store retained non-structural
annotation values as `Union{Nothing, String}`.

The core package does not parse retained annotation values into semantic
numeric, boolean, enum, or domain-specific types.

Examples of values that core preserves as text rather than semantically
coercing include:

- `bootstrap`
- `gamma`
- `posterior`
- `species`
- `population`

Format-specific and consumer-specific code may parse those values into richer
types as needed.

### Complex annotation values

The core package supports one scalar text value per retained annotation field
per node or per edge.

If a source exposes a structured annotation value that cannot be represented as
one scalar text field on one node or one edge, the format parser must do one of
the following:

- decompose it into explicit scalar fields before authoritative table assembly
- reject it with an informative error

The core package does not define an alternative builder-boundary payload
container for complex source annotations.

### Row-reference delivery

The public protocol receives retained node and edge annotation context through
small row-reference objects into the authoritative tables.

The concrete public row-reference types must be equivalent to:

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

At the public protocol boundary:

- `nodedata` is a `NodeRowRef`
- `edgedata` is `nothing` for root construction
- `edgedata` is one `EdgeRowRef` for single-parent descendants
- `edgedata` is `AbstractVector{<:EdgeRowRef}` for multi-parent descendants

These row references point into the authoritative tables. They do not copy
annotation fields into per-node or per-edge payload bags.

### Immediate consumption during construction

Client code may read and interpret retained annotations immediately during
construction.

Example:

```julia
function LineagesIO.add_child(
    parent::MyNode,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekey::StructureKeyType,
    edgeweight;
    nodedata::NodeRowRef,
    edgedata::EdgeRowRef,
)::MyNode
    posterior_txt = node_property(nodedata, :posterior)
    posterior = posterior_txt === nothing ? nothing : parse(Float64, posterior_txt)
    return MyNode(nodekey, String(label), posterior)
end
```

### Deferred consumption after construction

Client code may also retain row references or retain the authoritative tables
and interpret retained annotations later.

Example:

```julia
struct MyNode{NodeRefT}
    nodekey::StructureKeyType
    label::String
    nodedata::NodeRefT
end

bootstrap(node::MyNode) = begin
    txt = node_property(node.nodedata, :bootstrap)
    return txt === nothing ? nothing : parse(Float64, txt)
end
```

This deferred path is a first-class intended use case.

### What the core package does not promise

The core package does not promise any of the following as a generic annotation
contract:

- `nodedata.bootstrap`
- `edgedata.gamma`
- `node.bootstrap`
- source-specific generated struct field names derived from runtime annotation
  names

Client packages and format-specific packages may provide such sugar if they
want it. The core package does not require it.

## Companion table contract

Every `LineageGraphAsset` exposes package-owned concrete Tables.jl-compliant
`node_table` and `edge_table` objects.

These are the authoritative preserved stores for graph-local node structure,
graph-local edge structure, and retained node and edge annotations.

### Node table

The node table has exactly one row per node in the graph.

The node table is authoritative for:

- `nodekey`
- `label`
- all retained node annotations

Required structural fields:

| Field | Type | Meaning |
|---|---|---|
| `nodekey` | `StructureKeyType` | primary key within the graph |
| `label` | `String` | raw source label, possibly empty |

All retained node annotations appear as additional node-table fields.

All retained non-structural node-annotation fields store
`Union{Nothing, String}` values.

### Edge table

The edge table has exactly one row per edge in the graph.

The edge table is authoritative for:

- `edgekey`
- `src_nodekey`
- `dst_nodekey`
- `edgeweight`
- all retained edge annotations

Required structural fields:

| Field | Type | Meaning |
|---|---|---|
| `edgekey` | `StructureKeyType` | primary key within the graph |
| `src_nodekey` | `StructureKeyType` | source node structural key |
| `dst_nodekey` | `StructureKeyType` | destination node structural key |
| `edgeweight` | `Union{Float64, Nothing}` | distinguished structural edge weight |

All retained edge annotations appear as additional edge-table fields.

All retained non-structural edge-annotation fields store
`Union{Nothing, String}` values.

### Graph table

The graph table is authoritative for graph-level summary and any graph-level
metadata retained by the load.

Required summary fields mirror the graph coordinates carried on
`LineageGraphAsset`.

### Collection table

The collection table is authoritative for collection-level summary and any
collection-level metadata retained by the load.

### Source table

The source table is authoritative for source-level summary and any source-level
metadata retained by the load.

### Key-order rule

Within one graph:

- node-table row order matches `nodekey` order
- edge-table row order matches `edgekey` order

This means:

- node-table row `i` corresponds to `nodekey == i`
- edge-table row `i` corresponds to `edgekey == i`

This rule exists to keep key-based lookup straightforward and cheap.

### Table design rule

All companion tables must be:

- package-owned concrete table types
- Tables.jl-compliant
- valid for direct user-space retention after loading
- usable through key-based lookup without requiring the full
  `LineageGraphAsset` handle to remain in scope

## Post-load access contract

Users and extension packages must be able to retain and use the returned
authoritative tables directly after loading.

They are not required to hold the full `LineageGraphAsset` for the lifetime of
their work if they have already retained the graph handle they need together
with the relevant tables.

### Generic lookup helpers

The package may provide generic convenience helpers such as:

```julia
node_property(node_table, nodekey, propertykey)
edge_property(edge_table, edgekey, propertykey)
node_property(nodedata::NodeRowRef, propertykey)
edge_property(edgedata::EdgeRowRef, propertykey)
```

These helpers are package-native convenience APIs for the authoritative tables
and their row references.

The `propertykey` may be represented by the exact retained field name as a
`Symbol` or `AbstractString`.

For retained non-structural annotation fields, these helpers return
`Union{Nothing, String}`.

### Format-specific and consumer-specific accessors

Format-specific packages and consumer packages are encouraged to provide typed
wrappers over the authoritative tables or over retained row references.

Examples:

```julia
bootstrap(node_table, nodekey) = begin
    txt = node_property(node_table, nodekey, :bootstrap)
    return txt === nothing ? nothing : parse(Float64, txt)
end

hybrid_gamma(edge_table, edgekey) = begin
    txt = edge_property(edge_table, edgekey, :gamma)
    return txt === nothing ? nothing : parse(Float64, txt)
end
```

or package-specific wrappers such as:

```julia
bootstrap(lgraph::TheirGraphType, node::TheirNodeType) =
    bootstrap(lgraph.node_table, node.nodekey)
```

These wrappers belong to the format-specific or consumer-specific layer, not to
the core structural contract.

### Direct field access is not a core guarantee

The package does not guarantee `node.fieldname`, `nodedata.fieldname`, or
`edgedata.fieldname` as a generic retained-annotation access contract.

If a package wants to provide field-like sugar or macro-based sugar over the
authoritative tables, it may. The core package does not require it.

## Return types

### `LineageGraphAsset`

`LineageGraphAsset{MaterializedT}` is the single-graph result struct.

It must carry:

- `index`
- `source_idx`
- `collection_idx`
- `collection_graph_idx`
- `collection_label`
- `graph_label`
- `node_table`
- `edge_table`
- `materialized`
- `source_path`

`materialized` is:

- the final value returned by `finalize_graph!` when the caller requested graph
  materialization
- `nothing` when the caller did not request graph materialization

For generic node-model construction, this value is often the root node or root
handle. For first-class package extensions, it should ordinarily be the native
target-package graph or container object requested by the caller.

### `LineageGraphStore`

`LineageGraphStore{MaterializedT}` is always returned by `load`.

It must carry:

- `source_table`
- `collection_table`
- `graph_table`
- `graphs`

`graphs` is a lazy iterator of `LineageGraphAsset{MaterializedT}`.

### Multi-source coordinates

`nodekey` and `edgekey` are unique within a graph, not globally across a
multi-source load.

Cross-graph and cross-source identity is expressed by:

- `source_idx`
- `collection_idx`
- `collection_graph_idx`
- `index`

## FileIO and package-native APIs

The package must distinguish FileIO contract from package-native convenience
APIs.

### FileIO contract

The package must implement private backend methods inside the `LineagesIO`
module rather than extending `FileIO.load` or `FileIO.save` directly.

It must support:

- format auto-detection where safe
- explicit format override through `File{format"..."}(...)`
- stream-based I/O through `Stream{fmt}(io)`

### Package-native convenience APIs

The package may provide convenience wrappers such as:

- `loadfirst`
- `loadone`
- generic property lookup helpers
- multi-source loading helpers

These are package-owned APIs layered on top of the FileIO backend contract.

## View layer

The package must provide lazy access to graph collections.

`LineageGraphStore.graphs` is the primary lazy iteration surface.

The package must support:

- first-graph convenience access
- exactly-one-graph convenience access
- multi-source load with source coordinates retained on each graph asset

The view layer owns convenience semantics. It does not own parsing, key
assignment, table assembly, root binding, or graph construction.

## Format support

Formats are implemented as package-owned parser modules with clear ownership of
their parsing rules, detection rules, unsupported constructs, and annotation
extraction rules.

### Phase 1

- `format"Newick"`
- `format"LineageGraphML"`

### Phase 2

- `format"Nexus"`
- `format"TskitTrees"`
- additional ratified formats

### Format declaration requirements

Each format must define:

- its structural protocol tier
- its supported extensions
- its detection rules
- its retained annotation extraction rules
- its unsupported constructs and error behavior

Formats do not define alternative core payload containers. All retained node
and edge annotations flow into the authoritative tables and their row
references.

## GraphML policy

Generic GraphML is not owned by this package.

Only the package-ratified phylogeny-specific GraphML profile belongs to
`format"LineageGraphML"`.

The package must not treat every `.graphml` file as LineageGraphML merely
because the extension matches.

## Detection policy

Each format must define:

- supported extensions
- magic-byte or content-sniffing rules when needed
- whether auto-detection is safe
- whether explicit override is required for ambiguous cases

Ambiguous formats must raise informative errors that request explicit format
override rather than silently guessing.

## Parameterization requirements

The package must support:

- method-extension graph construction through `load(src, NodeT)`
- rootnode binding through `load(src, rootnode::NodeT)`
- explicit builder callbacks through `load(src; builder = fn)`
- `StructureKeyType` as the semantic key type for all package-assigned
  structural keys
- package-owned concrete `node_table` and `edge_table` types
- package-owned concrete row-reference types

The package must not require:

- generated public struct fields from runtime annotation names
- source-specific public row types derived from per-source annotation names
- copied per-node or per-edge metadata bags at the builder boundary

## Error handling

The package must distinguish:

- parse errors
- unsupported constructs
- ambiguous formats
- lossy conversions
- invalid field-name mappings
- invalid rootnode-target loads
- invalid property lookups

Errors must include source location where possible.

If a caller supplies `load(src, rootnode::NodeT)` and the source yields more
than one graph, the package must raise an informative error rather than trying
to guess how the caller wanted multiple graphs to bind.

Builder compatibility and root-binding compatibility errors should be raised
before parse work begins where possible.

Invalid field-name mappings must raise informative errors for:

- collisions with structural names
- duplicate retained names
- otherwise invalid outputs for the retained table design

If a parser encounters a complex source annotation that cannot be represented
as one scalar text field per node or edge and the format does not decompose it,
the parser must raise an informative error.

Property lookup convenience helpers must raise informative errors for missing
fields, missing keys, or invalid lookups rather than silently fabricating
values.

## Registration readiness

The package must be designed so that later FileIO registration requires:

- no redesign of public format identifiers
- no redesign of private loader ownership
- no redesign of explicit override semantics
- no redesign of stream support

Registration itself is out of scope for this document.

## Success criteria

The package is successful when all of the following are true.

- `load("file.nwk", MyNode)` returns `LineageGraphStore{MyNode}` through the
  public root-creation and child-construction protocol
- `load("file.nwk", rootnode(lgraph))` binds the parsed root node onto the
  supplied rootnode handle through `bind_rootnode!` and then constructs
  descendants through `add_child`
- `load("file.nwk")` returns a `LineageGraphStore` whose graphs expose
  authoritative package-owned node and edge tables even when no graph
  materialization target is supplied
- every node in `node_table` has a stable `nodekey`
- every edge in `edge_table` has a stable `edgekey`
- every edge in `edge_table` has stable `src_nodekey` and `dst_nodekey`
- retained node and edge annotations are available both during construction and
  after load through the authoritative tables and their row references
- client code can interpret retained annotations eagerly during construction or
  defer interpretation until later without per-node copied annotation bags
- rooted network formats parse with one rootnode and multi-parent interior-node
  construction through the multi-parent `add_child` protocol
- format-specific and consumer-specific code can build wrappers such as
  `bootstrap(...)` and `hybrid_gamma(...)` without any core field-promotion
  contract
- the package scales to huge trees, many graphs, and many huge graphs while
  keeping the authoritative representation table-backed and the builder-boundary
  payload small

## Contracts that do not exist

The following are not part of the core design and must not be introduced
downstream without explicit approval.

- `node_idx`, `edge_idx`, `src_node_idx`, and `dst_node_idx` as core
  identifier names
- `edgelength` as the distinguished structural edge-weight name
- generated field-style public contracts such as `nodedata.bootstrap` or
  `edgedata.gamma`
- source-specific public row types derived from runtime annotation-name sets
- copied per-node or per-edge `Dict`, bag, or source-shaped `NamedTuple`
  payloads at the public builder boundary
- format-owned alternative builder-boundary payload stores in place of the
  authoritative core tables and their row references
- semantic coercion of retained non-structural annotation values in core
- a positional `load(src, FormatType())` override surface
- any assumption that rooted networks require multiple roots

## Community support through package extensions

The document `brief--community-support-objectives` describes product features that build on the core package described here to provide organic materialization of supported data source formats into representations from the following consumer packages: 

- MetaGraphsNext.jl
    - This is considered a **reference-standard** consumer that we will target for support and domain modeling. 
- PhyloNetworks.jl

Additional native consumer packages may be considered later only through
explicit reauthorization. They are not part of the current phase-1 delivery
contract or current tranche/tasking fulfillment map.

The document `design/brief--community-support-user-stories.md` is the
community-support user-story annex for that companion brief and must be read
alongside it when trancheing or verifying extension-facing work.

## Fundamental implementation mandates

Reading of `design/brief--community-support-objectives.md` is mandated alongside
this document.

Reading of `design/brief--user-stories.md` is mandated alongside this document
whenever planning or implementing user-facing behavior, verification coverage,
or tranche boundaries that derive from the core package contract.

Reading of `design/brief--community-support-user-stories.md` is also mandated
whenever the work touches ecosystem integration, extension behavior, or shared
success criteria that cross the core and community-support boundary.

Reading and compliance with all applicable `STYLE-*.md` files and
`CONTRIBUTING.md` are mandated and must be passed forward into all downstream
work.

In particular, note terminological policies in `STYLE-vocabulary.md`, together
with the LineagesIO-specific core identifiers ratified by this document:

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

Reading of the key technological context named above is mandated for this
project, and downstream community reading of those sources is required
whenever their contracts are in scope.
