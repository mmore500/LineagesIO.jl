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

The builder protocol is the central interface through which LineagesIO.jl
communicates parsed structure to user code. Users implement `add_child` at
whichever level of the protocol matches their graph type.

### Tree-level dispatch (single-parent case)

Users whose graph type is a rooted tree implement two methods:

```julia
add_child(
    parent     :: Nothing,
    label      :: AbstractString,
    edgelength :: Union{EdgeLenT, Nothing},
    data       :: D,
) :: NodeT   # called once; returns the root handle

add_child(
    parent     :: NodeT,
    label      :: AbstractString,
    edgelength :: Union{EdgeLenT, Nothing},
    data       :: D,
) :: NodeT   # called once per non-root node
```

`parent = nothing` signals root creation. The returned `NodeT` is the only
handle the caller holds on the tree.

### Network-level dispatch (multi-parent case)

Users whose graph type supports reticulate or hybrid nodes implement:

```julia
add_child(
    parents     :: AbstractVector{NodeT},
    label       :: AbstractString,
    edgelengths :: AbstractVector{Union{EdgeLenT, Nothing}},
    data        :: D,
) :: NodeT
```

`parents` and `edgelengths` are parallel vectors: `edgelengths[i]` is the
length of the edge from `parents[i]` to the new node. An empty `parents`
vector signals root creation, consistent with the tree-level protocol.

The library dispatches to the tree-level methods when `length(parents) ≤ 1` and
the user has defined them; otherwise it calls the network-level method.

### Semantics (both levels)

* `label` is the node label as it appears in the source file (possibly empty).
* `edgelength` / `edgelengths` is `nothing` when the format or file does not
  supply a value for that edge.
* `data` carries format-supplied metadata (see **Metadata architecture**).
* The returned `NodeT` is passed as a parent in subsequent `add_child` calls
  for that node's children.

### Parse order

Parsers call `add_child` in a top-down (pre-order) traversal after completing
internal format parsing. For inside-out formats such as Newick the parser
maintains internal state during tokenization and begins builder calls only after
the full subtree structure is known. At every `add_child` call, all ancestor
nodes already exist.

### Multi-tree files

For file formats that contain multiple trees (NEXUS, multi-Newick), the parser
invokes the full `add_child` sequence once per tree, returning a separate root
handle for each. The lazy iteration layer exposes these as an iterator over root
handles.

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

* user-supplied builder functions parameterized on `NodeT`, `EdgeLenT`, `D`
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

* `load("file.nwk"; builder = my_builder)` works via FileIO and returns the
  user's graph type
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
