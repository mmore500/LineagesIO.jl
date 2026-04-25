## LineagesIO.jl

## Purpose

This Julia package provides FileIO-compatible loading and saving of phylogenetic graph (tree or network) data together with package-native lazy readers, behaving as a proper FileIO backend for a range of phylogenetic graph data formats.

It serves as:

* a **FileIO backend** for lineage graph formats
* a **format parsing and detection layer**
* an **orchestration layer** that maps parsed data into user-specified or default representations

## Design objectives

The package must satisfy the following goals.

It must provide idiomatic FileIO integration for supported phylogenetic formats through `load`, `save`, explicit `File{format"..."}(...)`, and stream-based entry points. ([Julia.io][4])

It must support multiple phylogenetic file formats under one coherent package, with each format implemented as a bundled submodule rather than as a completely separate package.

It must support lazy iteration over phylogenetic graph collections. 

Using idiomatic Julia generics mechanisms, such as parameterized types and functions, or passing mapping/accessor functions, multiple dispatch etc., this package will not itself provide any concrete types, with all introductions and materialization functions being supplied by the user either implicitly (e.g. methods for their custom types, type parameterization) or explicitly (passing functions as arguments).

The package conforms to FileIO’s backend conventions: FileIO remains the public dispatcher, while this package supplies the actual parsers, serializers, format detectors, and internal loader/saver methods. 

It must distinguish between the **FileIO contract** and **package-native convenience APIs**, rather than overloading FileIO terms for non-FileIO semantics. ([Julia.io][1])

Through use of idiomatic Julia mechanisms and practices, abstractions, parameterization, etc., using keyword-argument function based accesss passed by users, a base layer can be be transparent to particular types yet remain type stable with all types known at compile time (see `STYLE-julia.md`).

## Non-goals

The package will not implement phylogenetic inference, reconciliation, comparative methods, plotting, or analysis algorithms as primary responsibilities.

The package will not attempt, in Phase 1, to solve every dialect or ecosystem-specific annotation convention for every tree-producing program.

The package will not require FileIO registry inclusion in order to be considered complete for the purposes of this PRD, though it must be engineered so that registration can be done later with minimal redesign. ([Julia.io][2])

## Ecosystem and interface constraints

### FileIO contract constraints

FileIO requires backend packages to implement **private** loader/saver functions inside the package module, rather than extending `FileIO.load` or `FileIO.save` directly. The same rule applies to `loadstreaming` and `savestreaming`. FileIO also documents that `loadstreaming` is expected to return an object that can be read from, and its implementation notes describe these as decoded streams with lifecycle management via `close`. ([Julia.io][1])

FileIO identifies formats through `DataFormat`s such as `format"PNG"`, and a package may expose explicit format forcing through forms like `load(File{format"PNG"}(filename))` and stream forcing through `Stream{fmt}(io)`. The package therefore must support both implicit detection and explicit override. ([Julia.io][4])

A new FileIO format is registered by `add_format(fmt, magic, extension, libraries...)`, where the package UUID is part of the registration data. FileIO’s registration docs also note that `fmt` is just an internal identifier chosen by the implementer. ([Julia.io][2])

### Julia graph/tree ecosystem constraints

Graphs.jl defines the `AbstractGraph` ecosystem, and GraphIO already provides graph-format persistence for Graphs.jl, including GraphML support. This matters because generic GraphML handling already exists in the Julia graph ecosystem and should not be semantically appropriated as though all `.graphml` files are phylogenetic trees. ([JuliaGraphs][5])

## Product architecture

The package is divided into:

### Parsing layer

* format-specific parsers
* callback/builder protocol
* no required data structure

### Materialization layer

* user-supplied builders
* default builders from Graphs.jl

### FileIO adapter layer

* private `load`, `save` implementations
* format detection and dispatch

### View layer

* lazy iterators
* projections into lineage graph structures

## Architectural separation

The core parsing model must be defined in terms of:

* user-supplied builder functions or objects
* event-driven or structured construction

The parser must not require any specific return type.

The builder protocol must support:

* construction of arbitrary representations
* maintenance of parser state
* flexible return values

## Default materialization

If no builder is provided:

* the package must use default builders
* default builders can materialize appropriate GraphML concrete types

This ensures:

* type stability
* predictable behavior
* interoperability

## FileIO contract

The package must implement:

* private `load` methods
* private `save` methods
* optional `loadstreaming`/`savestreaming` only if semantics match FileIO expectations

It must support:

* format auto-detection
* explicit format override
* stream-based I/O

## Lazy access design

The package must provide:

* lazy iterators over lineage graph collections
* parameterized views over parsed content

These must not be labeled `loadstreaming` unless they satisfy FileIO stream semantics.

## Format support

### Phase 1

* `format"Newick"`
* `format"LineageGraphML"` [GraphML scheme; maybe we normalized/ratified field name scheme]

### Phase 2

* `format"Nexus"`
* `format"PhyloNetwork"`
* `format"tskit"`
* additional formats as specified

Formats must be implemented as submodules.

## GraphML policy

GraphML must be treated as:

* a general graph format
* used only via a phylogeny-specific profile (`LineageGraphML`)

The package must not claim ownership of generic GraphML.

## Detection policy

Each format must define:

* supported extensions
* detection logic
* auto-detection safety

Ambiguous formats must require explicit override.

## Parameterization requirements

All APIs must support:

* user-supplied builders
* parameterized return types
* configurable parsing modes

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
* builder-based parsing
* default materialization 
* lazy iterators

### Phase 2

* additional formats
* richer metadata preservation
* conversion matrix
* compliance suite

## Success criteria

The package is successful when:

* `load("file")` works via FileIO
* explicit format override works
* lazy iteration is available
* default outputs are type-stable and interoperable
* user-supplied builders integrate cleanly

## Fundamental mandates

Where "reading" means line-by-line, without summarization or assuming,

* Reading and compliance and ensuring community reading and compliance with **GOVERNANCE DOCUMENTS** `STYLE-...md` documents are **MANDATED**, and should be incorporated into *EVERY* stage of the process, from thinking to action, design to final product.

* Reading of **KEY TECHNOLOGICAL CONTEXT** for the project, and ensuring downstream/community reading of:

    - fileio.jl 
    - DendroPy