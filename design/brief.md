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
    label      :: AbstractString,
    edgelength :: Union{Float64, Nothing},
    data       :: D,
) where {D}
    return MyNode(label, edgelength, data.bootstrap)   # root; data carries format metadata
end

function LineagesIO.add_child(
    parent     :: MyNode,
    label      :: AbstractString,
    edgelength :: Union{Float64, Nothing},
    data       :: D,
) where {D}
    return add_child_to_tree!(parent, label, edgelength, data.bootstrap)
end

# Node type passed as positional argument — no kwarg needed:
result = load("file.nwk", MyNode)
```

The three calling patterns for `load` are therefore:

| Call | Returns |
|---|---|
| `load("file.nwk")` | Tables.jl node table (no builder) |
| `load("file.nwk", MyNode)` | `MyNode` tree via dispatch extension |
| `load("file.nwk"; builder = fn)` | builder's `NodeT` via callback |

An explicit `builder` kwarg always takes precedence over extended methods.

**Style 2 — Builder callback (keyword argument)**

Users pass an `add_child`-compatible function as the `builder` keyword argument to
`load`. The library calls this function directly. An explicit `builder` kwarg
always takes precedence over any extended `LineagesIO.add_child` methods in scope.

```julia
result = load("file.nwk"; builder = (parent, label, edgelength, data) -> ...)
```

This style is preferred for ad-hoc or scripting contexts, for cases where a user
wants multiple different builder strategies for the same node type, or when
disambiguation between several extended methods is impractical.

### Dispatch levels

The protocol defines two levels, corresponding to the two structural families of
phylogenetic files.

**Tree level — single-parent case:**

```julia
add_child(
    parent     :: Nothing,
    label      :: AbstractString,
    edgelength :: Union{EdgeLenT, Nothing},
    data       :: D,
) :: NodeT   # root creation; called exactly once per tree

add_child(
    parent     :: NodeT,
    label      :: AbstractString,
    edgelength :: Union{EdgeLenT, Nothing},
    data       :: D,
) :: NodeT   # non-root node
```

`parent = nothing` signals root creation. The returned `NodeT` is the library's
only handle on the tree; all subsequent calls receive it or a descendant as
`parent`.

**Network level — multi-parent case:**

```julia
add_child(
    parents     :: AbstractVector{NodeT},
    label       :: AbstractString,
    edgelengths :: AbstractVector{Union{EdgeLenT, Nothing}},
    data        :: D,
) :: NodeT
```

`parents` and `edgelengths` are parallel vectors: `edgelengths[i]` is the length
of the edge from `parents[i]` to the new node. An empty `parents` vector signals
root creation, consistent with the tree-level protocol. This overload handles
reticulate and hybrid nodes whose genealogy requires multiple incoming edges.

### Protocol determination

The library determines which dispatch level will be used **once, before any
`add_child` call is made**. Per-call dispatch based on `length(parents)` at call
time is explicitly rejected: it creates two unacceptable failure modes — a
tree-protocol user whose methods are bypassed mid-parse when a hybrid node appears,
and a network-protocol user whose vector overload is never reached when a file
happens to contain only single-parent nodes.

The determination proceeds in two steps:

**A — Format declaration (primary source).** Every format parser declares the
structural complexity it can produce. Formats capable of encoding hybrid or
reticulate nodes (extended Newick, NEXUS network blocks, `format"LineageNetwork"`)
declare network protocol. Formats that encode only rooted trees (plain Newick,
`format"LineageGraphML"`) declare tree protocol. This declaration is made before
parsing begins and is authoritative.

**B — Builder validation (gate before first call).** Once the format has declared
its protocol tier, the library validates that the user's builder is compatible
before starting the parse. If the format declares network protocol and the user's
builder does not define the vector-parent overload, the library raises an
informative error at load time — not mid-parse, not on the first hybrid node
encountered. If the format declares tree protocol, the library calls only
tree-level methods even if network-level methods are also defined.

This design guarantees: at the moment `load` begins emitting `add_child` calls,
the user knows exactly which method signature will be called throughout the entire
parse. There are no surprises mid-tree.

### Semantics

* `label` is the raw node label from the source file, possibly empty.
* `edgelength` / `edgelengths` is `nothing` when the source does not supply a
  value for that edge.
* `data :: D` is the format-specific metadata `NamedTuple` (see **Metadata
  architecture**). The user's method is parameterized on `D`; `D` is
  format-supplied and may differ across formats.
* The returned `NodeT` is passed as `parent` in all subsequent `add_child` calls
  for that node's children. It is the library's only stored handle; the user must
  retain any subtree reference they need.

### Parse order

Parsers call `add_child` in top-down (pre-order) traversal after completing
internal format parsing. For inside-out formats such as plain Newick, the parser
completes tokenization and builds full internal state before emitting any
`add_child` calls. At every `add_child` call, all ancestor nodes have already
been created and their handles are in scope.

### Multi-tree files

For formats containing multiple trees (NEXUS, multi-Newick), the full `add_child`
sequence is invoked once per tree, yielding a separate root handle for each. The
lazy iteration layer exposes these as an iterator over root handles.

## Metadata architecture

Format files carry annotation data of varying depth — branch lengths, bootstrap
support values, gamma (inheritance proportions), NHX key-value pairs, GraphML
data elements, tskit table columns, and arbitrary free-form comments. The
package exposes this through a **three-layer** architecture:

### Layer 1 — Parametric `data::D` in the builder protocol

The `data::D` argument passed to `add_child` is a parametric type defined by
the format submodule. The user's builder function is parameterized on `D`; the
format supplies it, the user manages its storage. This layer imposes no
constraint on metadata storage: the user's type and dispatch determine
everything.

### Layer 2 — Format-specific typed `NamedTuple`

Each format submodule defines a `NamedTuple` type for the promoted, commonly-used
fields it can supply. The tuple carries:

* Named, typed fields for well-known annotations (e.g. `bootstrap`,
  `gamma`, `comment`, `support`) as `Union{T, Nothing}`
* A `Dict{Symbol, Any}` overflow field for arbitrary key-value annotations
  (NHX comments, GraphML data elements) whose key set is not known at
  compile time

The named fields are fully type-stable (the `NamedTuple` field types are fixed
per format at compile time); the overflow dict provides open extensibility
without polluting the stable interface.

### Layer 3 — Tables.jl-compliant node table

Every `load` call that produces a graph also produces a companion
**Tables.jl-compliant node table** with one row per node and one column per
metadata field the format can supply. The return from `load` is therefore a
named pair: `(graph = <built by builder>, nodes = <Tables.jl table>)`.

LineagesIO.jl takes `Tables.jl` as a dependency (it is a lightweight pure-interface
package). It does **not** depend on `DataFrames.jl`. Users who want a DataFrame
call `DataFrame(result.nodes)` — one line, no LineagesIO dependency required.

The node table is the materialization target for users who want flat, tabular
access to metadata without writing a builder.

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

* lazy iterators over lineage graph collections (multi-tree files)
* parameterized views over parsed content

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

* `load("file.nwk", MyNode)` works via FileIO and returns the user's graph type
  via dispatch extension
* `load("file.nwk"; builder = my_builder)` works via FileIO and returns the
  user's graph type via callback
* `load("file.nwk")` returns a Tables.jl-compliant node table usable with zero
  builder code
* explicit format override works
* lazy iteration is available for multi-tree files
* builder output is type-stable
* user-supplied builders integrate cleanly for Newick and LineageGraphML
* hybrid/reticulate node files round-trip correctly through the multi-parent
  builder protocol
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
  - `PalmTree.jl` — layout/visualization reference
  - `Phylogenies.jl` — minimal Julia core type reference

[1]: https://juliaio.github.io/FileIO.jl/stable/implementing/
[2]: https://juliaio.github.io/FileIO.jl/stable/registering/
[3]: https://juliaio.github.io/FileIO.jl/stable/reference/
