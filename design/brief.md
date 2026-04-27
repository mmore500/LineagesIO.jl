---
date-created: 2026-04-26T00:00:00
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
| `STYLE-makie.md` | Makie integration contracts; LineagesMakie interoperability constraints |
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

| Source | Relevance |
|---|---|
| `fileio.jl/` | FileIO backend contract; `DataFormat`; `File` and `Stream`; `add_format`; private `load` and `save`; dispatch and detection semantics |
| `NewickTree.jl/` | Julia Newick parsing reference |
| `DendroPy/` | Builder-oriented parsing architecture reference |
| `Phylo.jl/` | Julia Newick and NEXUS parsing reference; extension target |
| `PhyloNetworks.jl/` | Extended Newick with hybrid nodes; extension target |
| `AbstractTrees.jl/` | Traversal traits and iteration interface; LineagesMakie interoperability |
| `Phylogenies.jl/` | Minimal Julia ecosystem context |
| `tskit` | Mandatory context for future genealogical-table formats |
| `../../LineagesMakie.jl/` | Local companion package; accessor protocol that loaded graphs must fit once the user supplies the required accessors |

When upstream behavior matters, verified source text governs. Memory,
secondary summaries, and plausible recollection do not.

## Purpose

LineagesIO.jl provides FileIO-compatible loading and saving of phylogenetic
graph data together with package-native lazy access to graph collections.

It serves three roles:

- a FileIO backend for lineage graph formats
- a parsing and format-detection layer
- an orchestration layer that maps parsed structure into user-specified graph
  or node representations through a principled builder protocol

The package does not define the user's graph model. It defines how parsed
structure and format-owned payload are presented to user code.

## Design objectives

The package must satisfy all of the following objectives.

It must provide idiomatic FileIO integration for supported phylogenetic formats
through `load`, `save`, explicit `File{format"..."}(...)`, and stream-based
entry points.

It must support multiple phylogenetic formats within one coherent package, with
each format implemented as a package-owned parser module rather than as an
ad hoc bundle of unrelated helpers.

It must support lazy iteration over graph collections and multi-source loads.

It must remain transparent to user domain types. All graph construction and
materialization is performed by user code either through normal Julia method
extension on `add_child` or through an explicit builder callback.

It must separate structural contract from metadata contract. Structural graph
facts are owned by the core protocol and tables. Metadata semantics are owned
by each format module.

It must remain type-stable at the public package boundary by avoiding any core
contract that requires runtime inference of field names from source annotations.

It must preserve FileIO's ownership model. FileIO remains the public
dispatcher. LineagesIO provides the actual parser, format detector, serializer,
and backend methods.

It must give users and ecosystem packages direct access to structural tables
and format-owned payload without forcing a particular in-memory graph type.

It must scale to:

- huge trees and networks
- many graphs in one source
- many huge graphs across many sources

while keeping metadata handling concrete, stable, and format-owned.

## Non-goals

The package will not implement phylogenetic inference, reconciliation,
comparative methods, plotting, or analysis algorithms as primary
responsibilities.

The package will not define a default concrete domain graph type in core. If a
shared normalized graph type is ever needed, that responsibility belongs to a
separate package.

The package will not treat every arbitrary annotation key in every source file
as a generic core-level schema design problem.

The package will not require FileIO registry inclusion in order to be
considered complete, though it must be engineered so that later registration
requires minimal redesign.

The package will not claim ownership of generic GraphML. Only the
package-ratified phylogeny-specific profile belongs here.

## Core architectural commitments

The package is built around the following non-negotiable commitments.

### Structure first

The core package owns graph structure and structural identity. Structural facts
are not treated as ordinary metadata.

### Format-owned metadata

Each format module owns its own stable metadata schema, payload representation,
and preservation decisions beyond the distinguished structural properties.

### No core runtime field-name inference

The core package does not infer metadata field names from runtime annotation
keys and does not derive public row types from per-source key discovery.

### Stable public tables

Each `LineageGraphAsset` returns concrete Tables.jl-compliant companion tables.
Their schemas are determined by format design, not by the specific runtime
annotation key set encountered in one source file.

### Builder freedom

Builders may consume payload eagerly during `add_child`, ignore it, or store a
handle for deferred lookup later.

### Single owner per invariant

Parsers own format semantics. The orchestration layer owns protocol routing,
builder validation, key assignment, and asset assembly. Extensions own only the
translation from core protocol calls into target-package graph construction.

## Structural contract

The structural contract is the core package's stable, format-independent model
of graph identity and graph edges.

### Node identity

`nodekey` is the distinguished node identity key.

Its contract is:

- type: `Int`
- scope: unique within one graph
- ownership: assigned by the orchestration layer
- semantics: primary key of the node table; foreign key target of all node
  references in returned tables and format-owned payload

`nodekey` is assigned sequentially in traversal order, starting at `1` for each
graph.

### Edge identity

`edgekey` is the distinguished edge identity key.

Its contract is:

- type: `Int`
- scope: unique within one graph
- ownership: assigned by the orchestration layer
- semantics: primary key of the edge table; stable structural key for edge
  lookup and payload lookup

`edgekey` is assigned sequentially within each graph.

### Label

`label` is a distinguished structural node property.

Its contract is:

- type: `AbstractString` at the builder boundary; stored as `String` in core
  tables
- semantics: raw source label, passed through unchanged
- missing label rule: parsers pass `""`

The core package performs no label disambiguation and no synthetic label
generation.

### Edge weight

`edgeweight` is a distinguished structural edge property.

Its contract is:

- type at builder boundary: `Union{EdgeUnitT, Nothing}`
- stored form in core edge table: `Union{Float64, Nothing}` for phase 1 formats
  that model numeric edge weights
- semantics: absent when the source does not supply a value

`edgeweight` is not ordinary metadata. It is part of the structural contract in
the same sense as `nodekey`, `edgekey`, and `label`.

### Edge endpoints

The core edge table always stores:

- `src_nodekey`
- `dst_nodekey`

These are structural join columns. They are not optional metadata.

## Builder protocol

`add_child` is the central exported generic function through which parsed
structure is communicated to user code.

Everything in the parsing pipeline converges on calls to `add_child`.
LineagesIO calls it. User code or extension code implements it.

`finalize_graph!` is the post-build protocol function invoked once after the
last `add_child` call for a graph and before `LineageGraphAsset` assembly.

### Invocation styles

Two invocation styles are supported and may coexist.

**Style 1 — Method extension**

Users extend `LineagesIO.add_child` for their concrete node-handle type and
pass that type positionally to `load`.

**Style 2 — Builder callback**

Users pass an explicit `builder` callback to `load`.

An explicit `builder` keyword argument always takes precedence over extended
`LineagesIO.add_child` methods in scope.

### Dispatch levels

The protocol has two structural levels.

**Network level**

Used for formats that may produce nodes with multiple incoming edges.

```julia
function add_child(
    ::AbstractVector{NodeT},
    ::Int,                                        # nodekey
    ::AbstractString,                             # label
    ::AbstractVector{Union{EdgeUnitT, Nothing}};  # edgeweights
    kwargs...,                                    # edgedata, nodedata
)::NodeT where {NodeT, EdgeUnitT}
end
```

**Single-parent level**

Used for formats in which every node has at most one parent.

```julia
function add_child(
    ::Nothing,
    ::Int,                           # nodekey
    ::AbstractString,                # label
    ::Union{EdgeUnitT, Nothing};     # edgeweight
    kwargs...,                       # edgedata, nodedata
)::NodeT where {NodeT, EdgeUnitT}
end

function add_child(
    ::NodeT,
    ::Int,                           # nodekey
    ::AbstractString,                # label
    ::Union{EdgeUnitT, Nothing};     # edgeweight
    kwargs...,                       # edgedata, nodedata
)::NodeT where {NodeT, EdgeUnitT}
end
```

### Builder semantics

The builder contract is:

- `nodekey` is the library-assigned structural node key
- `label` is the raw source label, possibly `""`
- `edgeweight` or `edgeweights` is the distinguished structural incoming edge
  weight or weights
- `nodedata` carries the format-owned node payload handle or value for the node
  being created
- `edgedata` carries the format-owned incoming edge payload handle or handles

For the single-parent entry-point call:

- `parent === nothing`
- `edgedata === nothing`

For the network entry-point call:

- `parents` is empty
- `edgeweights` is empty
- `edgedata` is empty or `nothing`, depending on the concrete helper path

At every non-entry-point `add_child` call, all ancestor handles already exist
and are in scope.

The returned `NodeT` is the library's stored handle for that node in all
subsequent builder calls.

### Protocol determination

The library determines the protocol tier once, before any `add_child` call.

This determination is owned by the format declaration, not by per-node runtime
inspection.

Formats capable of hybrid or reticulate structure declare the network tier.
Formats that encode only single-parent structure declare the single-parent tier.

### Builder validation

Once the format declares its tier, the orchestration layer validates builder
compatibility before parsing begins.

If the format declares the network tier and the supplied builder is not
compatible with it, the library raises an informative error before any parse
work begins.

### Parse order

Parsers emit `add_child` calls in top-down pre-order traversal after completing
whatever structural analysis the format requires.

The package does not define a generic source-wide metadata discovery pass.
A parser may still pre-scan or fully parse a source before emission if the
format requires it for structural correctness, collection handling, payload
storage setup, or error reporting.

## Metadata contract

Metadata in this package means format-owned payload beyond the distinguished
structural properties:

- `nodekey`
- `edgekey`
- `label`
- `src_nodekey`
- `dst_nodekey`
- `edgeweight`

Everything outside that set is format-owned payload.

### Ownership

The metadata contract is split as follows.

- Core package owns transport, tables, stable handles, and builder plumbing.
- Each format module owns the payload schema, payload preservation policy, and
  payload access conventions.
- User and extension code own interpretation and materialization into their
  domain types.

### Stable format schemas

Each format module defines explicit stable node and edge schemas in code.

These schemas may include:

- zero format-specific node payload columns
- zero format-specific edge payload columns
- any ratified format-specific payload columns needed for that format

These schemas are not derived from runtime key discovery in one source file.

### Payload representation at build time

`nodedata` and `edgedata` are type-stable format-owned payload handles or
values.

Valid representations include:

- lightweight row-reference objects into the authoritative node and edge tables
- lightweight wrapper structs around tables and keys
- small typed payload structs
- another format-owned concrete representation with equivalent stable semantics

The core contract does not require payload to be exposed as promoted fields.
Direct syntax such as `nodedata.bootstrap` is allowed only if that format's
implementation chooses to provide it. It is not a package-wide guarantee.

### Payload behavior

Builders may:

- read payload immediately during `add_child`
- ignore payload
- store payload handles for deferred lookup later

Deferred lookup is a first-class design use case.

### Unknown or open-ended annotations

The core package does not impose a single generic preservation strategy for
unknown annotations.

Each format may choose one of the following, provided the behavior is concrete,
documented, and stable:

- ignore unsupported annotations
- normalize them into explicit auxiliary tables
- preserve them in another stable format-owned store

The package does not require a format to preserve every arbitrary source
annotation.

## Companion table contract

Every `LineageGraphAsset` exposes concrete Tables.jl-compliant tables.

### Node table

The node table is authoritative for node-level structure and any node-level
format payload columns retained by the format.

Required columns:

| Column | Type | Meaning |
|---|---|---|
| `nodekey` | `Int` | primary key within the graph |
| `label` | `String` | raw source label, possibly empty |

Additional node columns are format-owned.

### Edge table

The edge table is authoritative for edge-level structure and any edge-level
format payload columns retained by the format.

Required columns:

| Column | Type | Meaning |
|---|---|---|
| `edgekey` | `Int` | primary key within the graph |
| `src_nodekey` | `Int` | source node structural key |
| `dst_nodekey` | `Int` | destination node structural key |
| `edgeweight` | `Union{Float64, Nothing}` | distinguished structural edge weight |

Additional edge columns are format-owned.

### Graph table

The graph table is authoritative for graph-level summary and graph-level
metadata retained by the load.

Required summary columns mirror the graph coordinates carried on
`LineageGraphAsset`.

### Collection table

The collection table is authoritative for collection-level summary and any
collection-level metadata retained by the load.

### Source table

The source table is authoritative for source-level summary and any source-level
metadata retained by the load.

### Table design rule

All companion tables must be:

- Tables.jl-compliant
- concretely typed or concretized through type parameters
- valid for direct user-space retention after loading

## Post-load access contract

Users and extension packages must be able to retain and use the returned
tables directly after loading.

They are not required to hold the full `LineageGraphAsset` for the lifetime of
their work if they have already retained the graph handle they need together
with the relevant tables.

### Generic lookup helpers

The package may provide generic convenience helpers such as:

```julia
node_property(node_table, nodekey, propertykey)
edge_property(edge_table, edgekey, propertykey)
```

These helpers are package-native convenience APIs, not the primary type-stable
builder contract.

When the lookup key is a runtime `Symbol`, the convenience lookup may be
dynamically typed. That is acceptable for user-space convenience. It is not the
recommended hot-path access pattern for performance-critical code.

### Format-specific accessors

Format modules, client packages, and extensions are encouraged to provide
typed convenience accessors over retained tables or payload handles, for
example:

```julia
clade_posterior_probability(node_table, nodekey)
hybrid_gamma(edge_table, edgekey)
```

or package-specific wrappers such as:

```julia
clade_posterior_probability(lgraph::TheirGraphType, node::TheirNodeType)
```

These wrappers belong to the format-specific or consumer-specific layer, not to
the core structural contract.

### Direct field access is not a core guarantee

The package does not guarantee `node.fieldname`, `nodedata.fieldname`, or
`edgedata.fieldname` as a generic metadata access contract.

If a format-specific implementation wants to provide field-like sugar, it may.
The core package does not require it.

## Return types

### LineageGraphAsset

`LineageGraphAsset{NodeT}` is the single-graph result struct.

It must carry:

- `index`
- `source_idx`
- `collection_idx`
- `collection_graph_idx`
- `collection_label`
- `graph_label`
- `node_table`
- `edge_table`
- `graph_rootnode`
- `source_path`

`graph_rootnode` is the handle returned by the entry-point builder call.

When the caller does not supply a builder and no default materialization path is
requested, `NodeT` may be `Nothing` and `graph_rootnode` may therefore be
`nothing`.

### LineageGraphStore

`LineageGraphStore{NodeT}` is always returned by `load`.

It must carry:

- `source_table`
- `collection_table`
- `graph_table`
- `graphs`

`graphs` is a lazy iterator of `LineageGraphAsset{NodeT}`.

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
assignment, or graph construction.

## Format support

Formats are implemented as package-owned parser modules with clear ownership of
their schemas and semantics.

### Phase 1

- `format"Newick"`
- `format"LineageNetwork"`
- `format"LineageGraphML"`

### Phase 2

- `format"Nexus"`
- `format"TskitTrees"`
- additional ratified formats

### Format schema rule

Each format must define:

- its structural protocol tier
- its stable node schema
- its stable edge schema
- its payload preservation policy for non-structural data
- any format-specific convenience accessors it chooses to expose

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

- method-extension builders through `load(src, NodeT)`
- explicit builder callbacks through `load(src; builder = fn)`
- return type parameterization driven by `NodeT`
- concrete format-owned node and edge table types
- concrete format-owned payload-handle types

The package must not require public row-type inference from source-specific
annotation keys in order to remain type-stable.

## Error handling

The package must distinguish:

- parse errors
- unsupported constructs
- ambiguous formats
- lossy conversions

Errors must include source location where possible.

Builder compatibility errors must be raised before parse work begins.

Property lookup convenience helpers must raise informative errors for missing
keys, missing columns, or invalid lookups rather than silently fabricating
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

- `load("file.nwk", MyNode)` returns `LineageGraphStore{MyNode}` via method
  extension on `add_child`
- `load("file.nwk"; builder = fn)` returns `LineageGraphStore{NodeT}` via
  callback
- `load("file.nwk")` returns a `LineageGraphStore` whose graphs expose
  authoritative node and edge tables even when no builder is used
- `LineageGraphAsset.node_table` and `LineageGraphAsset.edge_table` are
  directly useful in user space after loading
- `nodekey` enables stable node lookup within a graph
- `edgekey` enables stable edge lookup within a graph
- network-format graphs with hybrid nodes parse through the network builder
  protocol correctly
- loaded graphs are immediately compatible with LineagesMakie's accessor
  protocol once the user supplies the required accessors for their chosen
  `NodeT`
- the public package boundary remains type-stable without deriving row field
  names from runtime source annotations

## Removed concepts and stipulations

The following concepts and stipulations are intentionally removed from the core
design and must not be reintroduced downstream without explicit approval.

### Removed generic metadata discovery pass

The package no longer defines a generic core-level discovery pass that scans a
source file to discover arbitrary metadata field names and uses that discovery
to derive public row types.

### Removed source-derived public row schemas

The package no longer defines public node or edge row schemas by inspecting the
actual annotation key set present in one runtime source.

There is no core contract that the field names of `nodedata` or `edgedata`
depend on the specific source file being loaded.

### Removed package-wide requirement that every encountered key becomes a core column

The package no longer requires that every metadata key encountered in a source
file be promoted into a core companion-table column.

Formats, not the core package, decide which non-structural fields are retained,
how they are retained, and whether additional auxiliary structures are used.

### Removed package-wide guarantee of promoted-field access

The package no longer guarantees syntax such as:

- `nodedata.bootstrap`
- `nodedata.some_runtime_key`
- `edgedata.gamma`

across all formats merely because a source file happened to contain those
annotation names.

Any such field access is now format-owned sugar, not a package-wide promise.

### Removed core prohibition framed as “no overflow dictionaries anywhere”

The core package no longer frames metadata preservation as a universal
package-level prohibition on all auxiliary or normalized preservation
structures.

If a format needs explicit auxiliary tables or another stable preservation
structure for non-structural payload, that is a format-owned design decision.

### Removed generic shared schema-builder requirement

The core design no longer requires a package-wide generic schema-builder layer
whose job is to infer public node and edge row types from runtime annotation
records.

### Removed requirement that format modules avoid bespoke payload types

Format modules are now explicitly allowed to define stable format-owned payload
types, payload-handle types, row-reference types, and accessors when those are
the correct representation.

### Removed `node_idx` naming from the core contract

`node_idx` is removed from the core contract and replaced by `nodekey`.

### Removed `edge_idx` naming from the core contract

`edge_idx` is removed from the core contract and replaced by `edgekey`.

### Removed `src_node_idx` and `dst_node_idx` naming from the core contract

`src_node_idx` and `dst_node_idx` are removed from the core contract and
replaced by `src_nodekey` and `dst_nodekey`.

### Removed key-discovery-driven justification for type stability

The package no longer claims that type stability is achieved by discovering
runtime annotation keys first and then freezing source-specific row types.

The package now achieves type stability by making schemas and payload
representations format-owned and explicit.

## Fundamental implementation mandates

Reading of `design/brief--community-support-objectives.md` is mandated alongside
this document.

Reading and compliance with all applicable `STYLE-*.md` files and
`CONTRIBUTING.md` are mandated and must be passed forward into all downstream
work.

In particular, note terminological policies in `STYLE-vocabulary.md`, together
with the LineagesIO-specific core identifiers ratified by this document:

- `nodekey`
- `edgekey`
- `src_nodekey`
- `dst_nodekey`

Reading of the key technological context named above is mandated for this
project, and downstream community reading of those sources is required
whenever their contracts are in scope.
