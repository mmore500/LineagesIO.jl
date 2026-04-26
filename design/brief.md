---
date-created: 2026-04-25T00:00:00
version: 2.0
supersedes: .workflow-docs/logs/log.20260424--superceded-brief.md
---

# LineagesIO.jl — Design Brief v2.0

## Purpose

This Julia package provides FileIO-compatible loading and saving of phylogenetic
graph (tree or network) data together with package-native lazy readers, behaving
as a proper FileIO backend for a range of phylogenetic graph data formats.

It serves as:

* a **FileIO backend** for lineage graph formats
* a **format parsing and detection layer**
* an **orchestration layer** that maps parsed data into user-specified or default
  representations via a principled builder protocol

## Design objectives

The package must satisfy the following goals.

It must provide idiomatic FileIO integration for supported phylogenetic formats
through `load`, `save`, explicit `File{format"..."}(...)`, and stream-based entry
points.

It must support multiple phylogenetic file formats under one coherent package,
with each format implemented as a bundled submodule rather than as a completely
separate package.

It must support lazy iteration over phylogenetic graph collections.

Using idiomatic Julia generics mechanisms — parameterized types and functions,
multiple dispatch, callback/builder functions — this package will not itself
provide any concrete domain types. All graph construction and materialization is
performed by the user either implicitly (via type parameterization, methods on
their types) or explicitly (via builder functions passed as arguments).

The package conforms to FileIO's backend conventions: FileIO remains the public
dispatcher, while this package supplies the actual parsers, serializers, format
detectors, and internal loader/saver methods.

It must distinguish between the **FileIO contract** and **package-native
convenience APIs**, rather than overloading FileIO terms for non-FileIO
semantics.

Through use of idiomatic Julia mechanisms and practices — parameterization,
multiple dispatch, keyword-argument function-based access — the base layer must
be transparent to particular types yet remain type-stable with all types known
at compile time (see `STYLE-julia.md`).

## Non-goals

The package will not implement phylogenetic inference, reconciliation,
comparative methods, plotting, or analysis algorithms as primary
responsibilities.

The package will not attempt, in Phase 1, to solve every dialect or
ecosystem-specific annotation convention for every tree-producing program.

The package will not require FileIO registry inclusion in order to be considered
complete for the purposes of this PRD, though it must be engineered so that
registration can be done later with minimal redesign.

The package will not define any concrete domain graph type. If a default
normalized in-memory representation is ever needed, that is the responsibility
of `LineageGraphs.jl`, to which `LineagesIO.jl` may relate via a package
extension.

## Ecosystem and interface constraints

### FileIO contract constraints

FileIO requires backend packages to implement **private** loader/saver functions
inside the package module, rather than extending `FileIO.load` or `FileIO.save`
directly.

FileIO identifies formats through `DataFormat`s such as `format"PNG"`, and a
package may expose explicit format forcing through forms like
`load(File{format"PNG"}(filename))` and stream forcing through
`Stream{fmt}(io)`. The package therefore must support both implicit detection
and explicit override.

A new FileIO format is registered by
`add_format(fmt, magic, extension, libraries...)`, where the package UUID is
part of the registration data. FileIO's registration docs also note that `fmt`
is just an internal identifier chosen by the implementer.

### Julia graph/tree ecosystem constraints

Graphs.jl defines the `AbstractGraph` ecosystem, and GraphIO already provides
graph-format persistence for Graphs.jl, including GraphML support. This matters
because generic GraphML handling already exists in the Julia graph ecosystem and
should not be semantically appropriated as though all `.graphml` files are
phylogenetic trees.

## Product architecture

The package is divided into the following layers. Each layer has a single
well-defined responsibility and a stable interface boundary.

### Parsing layer

* Format-specific parsers (one submodule per format)
* No required output data structure — parsers emit events
* Source-location tracking for error reporting

### Builder protocol layer

* Receives parser events and constructs the user's preferred graph type
* Defined by a single generic function (see **Builder protocol** below)
* User-supplied (see **Builder protocol**)

### Metadata layer

* Three-layer system for format-supplied node/edge annotations (see
  **Metadata architecture** below)
* Tables.jl-compliant node table as companion return alongside the graph

### FileIO adapter layer

* Private `load`, `save` implementations
* Format detection and dispatch
* Explicit format override support

### View layer

* Lazy iterators over lineage graph collections

## Builder protocol

`add_child` is LineagesIO.jl's central exported generic function and the primary
public interface through which parsed structure is communicated to user code.
Everything in the library's parsing pipeline converges on calls to `add_child`.
Users supply the implementation; the library calls it.

### Invocation styles

Two invocation styles are supported and may coexist within the same project. They
share identical call signatures; only the provisioning mechanism differs.

**Style 1 — Method extension (multiple dispatch)**

Users extend `LineagesIO.add_child` for their concrete node type and pass the
type as a positional argument to `load`. The library dispatches all builder calls
through normal Julia multiple dispatch, specializing fully on `NodeT` at compile
time.

This follows the Tables.jl sink pattern used by CSV.jl (`CSV.read(src, DataFrame)`)
and similar ecosystem interfaces. Making the node type explicit at the call site
eliminates any ambiguity about which methods to dispatch to and allows the compiler
to specialize the entire parse on `NodeT` without runtime lookup.

```julia
# User extends LineagesIO.add_child for MyNode:
function LineagesIO.add_child(
    parent     :: Nothing,
    node_idx   :: Int,
    label      :: AbstractString,
    edgelength :: Union{Float64, Nothing},
    nodedata   :: R,
) where {R}
    return MyNode(node_idx, label, edgelength, nodedata.bootstrap)   # entry-point node
end

function LineagesIO.add_child(
    parent     :: MyNode,
    node_idx   :: Int,
    label      :: AbstractString,
    edgelength :: Union{Float64, Nothing},
    nodedata   :: R,
) where {R}
    return add_node_to_graph!(parent, node_idx, label, edgelength, nodedata.bootstrap)
end

# Node type passed as positional argument — no kwarg needed:
result = load("file.nwk", MyNode)
```

The three calling patterns for `load` are therefore:

| Call | Returns |
|---|---|
| `load("file.nwk")` | `LoadResult` with node/edge tables only (no builder) |
| `load("file.nwk", MyNode)` | `LoadResult{MyNode}` via dispatch extension |
| `load("file.nwk"; builder = fn)` | `LoadResult{NodeT}` via callback |

An explicit `builder` kwarg always takes precedence over extended methods.

**Style 2 — Builder callback (keyword argument)**

Users pass an `add_child`-compatible function as the `builder` keyword argument to
`load`. The library calls this function directly. An explicit `builder` kwarg
always takes precedence over any extended `LineagesIO.add_child` methods in scope.

```julia
result = load("file.nwk"; builder = (parent, node_idx, label, edgelength, nodedata) -> ...)
```

This style is preferred for ad-hoc or scripting contexts, for cases where a user
wants multiple different builder strategies for the same node type, or when
disambiguation between several extended methods is impractical.

### Dispatch levels

The protocol defines two levels, corresponding to the two structural families of
phylogenetic files.

**Network level — general case (baseline):**

```julia
# R = row type of node_table, fixed by discovery pass; parameterize with where {R}
add_child(
    parents     :: AbstractVector{NodeT},
    node_idx    :: Int,
    label       :: AbstractString,
    edgelengths :: AbstractVector{Union{EdgeLenT, Nothing}},
    nodedata    :: R,
) :: NodeT
```

`parents` and `edgelengths` are parallel vectors: `edgelengths[i]` is the length
of the edge from `parents[i]` to the new node. An empty `parents` vector signals
entry-point node creation (the traversal origin). This overload is the baseline:
it handles directed and undirected graphs, rooted and unrooted, including
reticulate and hybrid nodes with multiple incoming edges.

**Single-parent level — restricted case:**

```julia
# R = row type of node_table, fixed by discovery pass; parameterize with where {R}
add_child(
    parent     :: Nothing,
    node_idx   :: Int,
    label      :: AbstractString,
    edgelength :: Union{EdgeLenT, Nothing},
    nodedata   :: R,
) :: NodeT   # entry-point node creation; called exactly once per graph

add_child(
    parent     :: NodeT,
    node_idx   :: Int,
    label      :: AbstractString,
    edgelength :: Union{EdgeLenT, Nothing},
    nodedata   :: R,
) :: NodeT   # subsequent node
```

`parent = nothing` signals entry-point node creation. The returned `NodeT` is the
library's only handle on the graph; all subsequent calls receive it or a descendant
as `parent`. This overload applies when every node has at most one parent — the
restricted case that includes all rooted trees.

### Protocol determination

The library determines which dispatch level will be used **once, before any
`add_child` call is made**. Per-call dispatch based on `length(parents)` at call
time is explicitly rejected: it creates two unacceptable failure modes — a
single-parent-protocol user whose methods are bypassed mid-parse when a multi-parent
node appears, and a general-protocol user whose vector overload is never reached
when a file happens to contain only single-parent nodes.

The determination proceeds in two steps:

**A — Format declaration (primary source).** Every format parser declares the
structural complexity it can produce. Formats capable of encoding hybrid or
reticulate nodes (extended Newick, NEXUS network blocks, `format"LineageNetwork"`)
declare general (network) protocol. Formats that encode only single-parent graphs
(plain Newick, `format"LineageGraphML"`) declare single-parent protocol. This
declaration is made before parsing begins and is authoritative.

**B — Builder validation (gate before first call).** Once the format has declared
its protocol tier, the library validates that the user's builder is compatible
before starting the parse. If the format declares general protocol and the user's
builder does not define the vector-parent overload, the library raises an
informative error at load time — not mid-parse, not on the first multi-parent node
encountered. If the format declares single-parent protocol, the library calls only
single-parent-level methods even if general-level methods are also defined.

This design guarantees: at the moment `load` begins emitting `add_child` calls,
the user knows exactly which method signature will be called throughout the entire
parse. There are no surprises mid-parse.

### Semantics

* `node_idx` is a 1-based sequential integer assigned by the library for each node
  during parsing. It is the primary key of the node table and the foreign key used
  in the edge table (`src_node_idx`, `dst_node_idx`). The library assigns it; the
  user stores it on their `NodeT` to enable joins against the tables.
* `label` is the raw node label from the source file, possibly empty.
* `edgelength` / `edgelengths` is `nothing` when the source does not supply a
  value for that edge.
* `nodedata :: R` is a single row of the node table for this node (see **Metadata
  architecture**). `R` is the row type of `node_table` — a `NamedTuple` type
  established by the discovery pass before any `add_child` calls are made. Fields
  are the promoted table column names; optional fields are `Union{T, Nothing}`.
* The returned `NodeT` is passed as `parent` in all subsequent `add_child` calls
  for that node's children. It is the library's only stored handle; the user must
  retain any graph-structure reference they need.

### Parse order

Parsers call `add_child` in top-down (pre-order) traversal after completing
internal format parsing. For inside-out formats such as plain Newick, the parser
completes tokenization and builds full internal state before emitting any
`add_child` calls. At every `add_child` call, all ancestor nodes have already
been created and their handles are in scope.

### Multi-graph sources

For formats containing multiple graphs (NEXUS, multi-Newick, tskit `TreeSequence`),
the full `add_child` sequence is invoked once per graph. The lazy iteration layer
exposes these as an iterator of `GraphParseResult` values (see **Return types**).

## Metadata architecture

Format files carry annotation data across four structural levels. The package
exposes all four through a unified hierarchy, designed from the most complex case
(multi-source network files) down to the restricted cases (single rooted graph).

All metadata is fully promoted: every annotation key present in a source file
becomes a proper typed column. There are no overflow dictionaries anywhere in
the design.

### Level 1 — Node metadata

Before any `add_child` calls the parser performs a **discovery pass** over the
full source, collecting every annotation key name present across all nodes.
Every discovered key is promoted to a typed column. Column types are inferred
from the values seen during the discovery pass (or from format-specific rules for
well-known keys). For keys absent on some nodes the column type is
`Union{T, Nothing}` and those rows carry `nothing`.

The row type `R` — a fixed `NamedTuple` type — is constructed from this schema
after the discovery pass completes. It is stable for the entire load of a source.

`nodedata :: R` is passed as the final argument to every `add_child` call. It is
a single row of `node_table` for the node being created. The user accesses fields
as `nodedata.bootstrap`, `nodedata.gamma`, etc. Field names are the promoted table
column names, discovered from the file — not hardcoded from format-specific type
definitions. Format submodules do not define a bespoke `D` type; the row schema
is produced by the parser from the source.

### Level 2 — Edge metadata

Edge annotation keys are discovered in the same discovery pass and promoted to
typed columns in the edge table. The edge table accompanies every `GraphParseResult`,
with one row per directed edge:

| Column | Type | Description |
|---|---|---|
| `src_node_idx` | `Int` | parent node index (traversal-order predecessor for unrooted graphs) |
| `dst_node_idx` | `Int` | child node index |
| `edgelength` | `Union{Float64, Nothing}` | edge weight/length |
| format-specific columns | — | e.g. `gamma` for hybrid edge inheritance proportions |

The edge table is always present regardless of graph type. For single-parent
graphs it contains one row per node (excluding the entry-point node).

### Level 3 — Graph-level metadata

Metadata about a single graph as a unit: name/identifier (e.g. NEXUS `tree PAUP_1`),
weight or posterior probability in a sample, rooting declaration, graph-level
comments. Carried in the `graph_label` and related fields of `GraphParseResult`
(see **Return types**).

### Level 4 — Collection-level and file-level metadata

Metadata shared across multiple graphs within a collection (e.g. NEXUS TRANSLATE
block, MCMC sample size, burnin count) or across a whole source file (provenance,
format version, source program). For `format"TskitTrees"`, the file level carries
the entire population, individual, site, and migration tables from the tskit
`TreeSequence` model.

Carried in the `collection_table` and `source_table` of `LoadResult`
(see **Return types**).

LineagesIO.jl takes `Tables.jl` as a dependency (lightweight pure-interface package).
It does **not** depend on `DataFrames.jl`. Users who want a DataFrame call
`DataFrame(result.graphs[1].node_table)` — one line, no LineagesIO dependency required.

## Return types

### GraphParseResult

`GraphParseResult{NodeT}` is the single-graph result struct yielded by the lazy
graph iterator and collected in `LoadResult.graphs`. It carries the complete parse
output for one graph together with the index coordinates needed to locate it within
a multi-source, multi-collection load.

```julia
struct GraphParseResult{NodeT}
    index                :: Int                      # overall 1-based index across entire load
    source_idx           :: Int                      # 1-based index of source file
    collection_idx       :: Int                      # 1-based index of collection within source
    collection_graph_idx :: Int                      # 1-based index of graph within collection
    collection_label     :: Union{String, Nothing}   # e.g. NEXUS tree block name
    graph_label          :: Union{String, Nothing}   # e.g. NEXUS individual graph name
    node_table           :: <Tables.jl compliant>    # one row per node; node_idx as primary key
    edge_table           :: <Tables.jl compliant>    # one row per edge; src_node_idx, dst_node_idx
    graph_rootnode       :: NodeT                    # entry-point handle returned by add_child([],...);
                                                     # semantic root for directed rooted graphs,
                                                     # traversal origin for unrooted graphs
    source_path          :: Union{String, Nothing}
end
```

### LoadResult

`LoadResult{NodeT}` is always returned by `load` — callers cannot assume a source
contains only one graph. The nesting structure (source → collection → graph) is
expressed as index coordinates on each record, not as nested containers.

```julia
struct LoadResult{NodeT}
    source_table     :: <Tables.jl compliant>    # one row per source file
    collection_table :: <Tables.jl compliant>    # one row per collection within sources
    graph_table      :: <Tables.jl compliant>    # one row per graph (index + label summary)
    graphs           :: <lazy iterator of GraphParseResult{NodeT}>
end
```

`source_table` columns: `source_idx`, `source_path`, format-specific file-level
metadata. `collection_table` columns: `source_idx`, `collection_idx`, `label`,
`graph_count`, collection-level metadata (e.g. NEXUS TRANSLATE table encoding).
`graph_table` mirrors the index coordinates and label fields of `GraphParseResult`
without the node/edge table payloads.

### Convenience wrappers

| Function | Behaviour |
|---|---|
| `load(src, NodeT)` | `LoadResult{NodeT}` via dispatch extension |
| `load(src; builder = fn)` | `LoadResult{NodeT}` via callback |
| `load(src)` | `LoadResult` with node/edge tables only (no builder) |
| `loadfirst(src, ...)` | First `GraphParseResult`; no error on multiple |
| `loadone(src, ...)` | Single `GraphParseResult`; errors if count ≠ 1 |
| `load([f1, f2], ...)` | Multi-source; `source_idx` distinguishes origins |

## FileIO contract

The package must implement:

* private `load` methods
* private `save` methods

It must support:

* format auto-detection
* explicit format override
* stream-based I/O

## Lazy access design

The package must provide:

* lazy iterators over multi-graph sources, yielding `GraphParseResult{NodeT}` values
* `LoadResult.graphs` as the primary lazy iteration surface
* multi-source loading via `load([f1, f2, ...], ...)`

## Format support

### Phase 1

* `format"Newick"` — standard parenthetical tree notation
* `format"LineageGraphML"` — GraphML with a ratified phylogeny-specific
  attribute scheme

### Phase 2

* `format"Nexus"` — NEXUS tree blocks with TRANSLATE tables
* `format"LineageNetwork"` — extended Newick with hybrid/reticulate node
  notation as used by PhyloNetworks
* `format"TskitTrees"` — tskit native HDF5 binary genealogical table format
  (distinct from and not collapsible with tree-format Newick/Nexus exports)
* Additional formats as specified

Formats must be implemented as submodules.

## GraphML policy

GraphML must be treated as:

* a general graph format
* used by LineagesIO only via a phylogeny-specific profile (`LineageGraphML`)

The package must not claim ownership of generic GraphML.

## Detection policy

Each format must define:

* supported extensions
* detection logic
* auto-detection safety

Ambiguous formats must require explicit override.

## Parameterization requirements

All APIs must support:

* user-supplied builders — either extended `LineagesIO.add_child` methods or
  explicit `builder` callback functions — parameterized on `NodeT`, `EdgeLenT`, `D`
* parameterized return types driven by builder return type
* configurable parsing modes per format

## Error handling

The package must distinguish:

* parse errors
* unsupported constructs
* ambiguous formats
* lossy conversions

Errors must include source location where possible.

## Registration readiness

The package must be designed to support FileIO registration:

* stable format identifiers
* documented extensions
* detection mechanisms
* loader/saver ownership

Registration itself is out of scope.

## Phase plan

### Phase 1

* FileIO integration
* Newick support
* builder protocol implementation
* Tables.jl node table companion return
* lazy iterators

### Phase 2

* NEXUS support
* LineageNetwork (hybrid/reticulate extended Newick via PhyloNetworks semantics)
* TskitTrees (HDF5 genealogical table format)
* richer metadata preservation
* conversion matrix
* compliance suite

## Success criteria

The package is successful when:

* `load("file.nwk", MyNode)` returns `LoadResult{MyNode}` via dispatch extension
* `load("file.nwk"; builder = fn)` returns `LoadResult{NodeT}` via callback
* `load("file.nwk")` returns `LoadResult` with node/edge tables usable with zero
  builder code
* `loadone` and `loadfirst` convenience wrappers return `GraphParseResult` correctly
* multi-source `load([f1, f2], ...)` works with `source_idx` distinguishing origins
* explicit format override works
* lazy iteration over `LoadResult.graphs` is available for all multi-graph sources
* builder output is type-stable; `GraphParseResult{NodeT}` is fully parameterized
* `node_idx` in `add_child` enables lossless joins between graph structure and
  node/edge tables
* network graph files with hybrid/reticulate nodes parse correctly through the
  general `add_child(parents::AbstractVector{NodeT}, ...)` protocol
* loaded graphs are immediately consumable by LineagesMakie via its accessor
  protocol without additional transformation

## Fundamental mandates

Where "reading" means line-by-line, without summarization or assuming:

* Reading and compliance with — and ensuring downstream community reading and
  compliance with — **GOVERNANCE DOCUMENTS** (`STYLE-*.md` files) are
  **MANDATED** and must be incorporated into every stage of the process, from
  design to final product.

* Reading of **KEY TECHNOLOGICAL CONTEXT** is mandated for the project, and
  downstream/community reading of all of the following is required:

  **Core framework:**
  - `fileio.jl` — FileIO backend contract (implementing, registering, dispatch)

  **Parsing reference implementations:**
  - `DendroPy` — Python reference for Newick/NEXUS parsing architecture,
    builder pattern, tokenizer design
  - `NewickTree.jl` — Julia Newick parser (stack-based)
  - `Phylo.jl` — Julia Newick/NEXUS parser (combinator-based) with NHX
    metadata

  **Network/reticulate phylogenetics:**
  - `PhyloNetworks.jl` — extended Newick with hybrid nodes; `HybridNetwork`
    type; `readnewick`/`writenewick` architecture; NEXUS/PHYLIP/FASTA support

  **Tabular genealogy format:**
  - `tskit` — `.trees` HDF5 binary format, `TreeSequence` tabular model;
    mandatory context for `format"TskitTrees"` design

  **Visualization interoperability:**
  - `LineagesMakie.jl` — accessor protocol (`children`, `edgelength`,
    `branchingtime`, `coalescenceage`, `nodevalue`, `nodecoordinates`,
    `nodepos`); loaded graphs must be immediately consumable

  **Abstract tree interface:**
  - `AbstractTrees.jl` — traversal traits and iteration interface

  **Additional context (user-facing ecosystem):**
  - `Phylogenies.jl` — minimal Julia core type reference

[1]: https://juliaio.github.io/FileIO.jl/stable/implementing/
[2]: https://juliaio.github.io/FileIO.jl/stable/registering/
[3]: https://juliaio.github.io/FileIO.jl/stable/reference/
