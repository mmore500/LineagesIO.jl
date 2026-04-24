## LineagesIO.jl

## Purpose

This Julia package provides FileIO-compatible loading and saving of phylogenetic graph (tree or network) data, together with package-native lazy readers and alternate structural views over collections of these entities. 
This package behaves as a proper FileIO backend for phylogenetic tree data formats, while also exposing domain-native APIs for lazy iteration, `AbstractTrees` views, and `AbstractGraph` views over single trees (or graphs) and collections of trees (or graphs).

## Design objectives

The package must satisfy the following goals.

It must provide idiomatic FileIO integration for supported phylogenetic formats through `load`, `save`, explicit `File{format"..."}(...)`, and stream-based entry points. ([Julia.io][4])

It must support multiple phylogenetic file formats under one coherent package, with each format implemented as a bundled submodule rather than as a completely separate package.

It must support multiple structural access patterns over the same parsed content: eager materialization, lazy iteration over phylogenetic graph collections, `AbstractTrees` views, and `AbstractGraph` views.

It must be designed from the beginning to preserve enough format metadata and provenance to support future FileIO registration, cross-format conversion, and faithful round-tripping where possible. ([Julia.io][2])

The package conforms to FileIO’s backend conventions: FileIO remains the public dispatcher, while this package supplies the actual parsers, serializers, format detectors, and internal loader/saver methods. 

It must distinguish between the **FileIO contract** and **package-native convenience APIs**, rather than overloading FileIO terms for non-FileIO semantics. ([Julia.io][1])

It must not assume that the phylogenetic data is a tree-based or some other class of graph based in structure: it will use the term "lineage graph" ("`lineagegraph`") as a canonical term and concept to maintain this abstraction; reference the "`STYLE-vocabulary.md`" for clarification on this and other terminological decisions to be complied with.

It must give first class support to the generalized concept of "lineage graph", but also recognize that the majority of current phylogenetic data is expressed in tree structures, though there is an increasing need and demand to analyze data that requires expressing of reticulation, such as, for e.g. hybridization or horizontal gene transfer (HGT) events. 
We will consider how to model these structurally in detail in Phase 2.

Through use of idiomatic Julia mechanisms and practices, abstractions, parameterization, etc., using keyword-argument function based accesss passed by users, a base layer can be be transparent to particular types yet remain type stable with all types known at compile time (see `STYLE-julia.md`).

At the same time, it would be useful to provide a semantically-rich suite of types both for internal use, and for use as a default if the user does not want to supply their own.
Proper abstraction hierarchy to express semantics, with parameterization etc. to allow flexible use of user data types.

For e.g.:

```julia
abstract struct AbstractLineageGraph end
abstract struct AbstractDirectedLineageGraph end
abstract struct AbstractBidirectedLineageGraph end
abstract struct AbstractUndirectedLineageGraph end
...
... (TBD)
...
```

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

### Top-level architecture

The package will be organized as a single umbrella package with bundled submodules, one submodule per supported format family.

Planned structure:

* `LineagesIO`

  * `Formats.LineageGraphML`
  * `Formats.tskit`
  * `Formats.Newick`
  * `Formats.Nexus`
  * `Formats.NeXML`
  * `Formats.PhyloXML`
  * `Formats.NHX`
  * additional Phase 2 submodules as adopted

This bundled-submodule design is intentionally chosen instead of the one-package-per-format pattern. 
The rationale is that the domain object model, format conversion logic, validation policy, tree collection abstractions, and format capability matrices are shared across formats. 
The FileIO adapter layer should remain thin, while the submodules own syntax-specific parsing and serialization.

### Internal layers

The internal architecture will have four layers.

Layer 1 is the FileIO adapter layer. This layer defines the FileIO-facing private `load`, `save`, and possibly true `loadstreaming`/`savestreaming` methods for supported `File{fmt}` and `Stream{fmt}` signatures. ([Julia.io][1])

Layer 2 is the format submodule layer. Each format submodule defines syntax, extension aliases, detection logic, parser, serializer, capability declarations, and dialect policy.

Layer 3 is the canonical data model layer. All supported formats map into a common internal representation for lineage graphs, lineage graph collections, annotations, edge metadata, rooting status, and provenance. 

Layer 4 is the view/adaptor layer. This layer provides package-native lazy iterators, `AbstractTrees` views, `AbstractGraph` views, and materialization helpers.

## Canonical graph abstractions

The reference concept we use here is that of the *lineage graph* (see: `STYLE-vocabulary`).  

For this project, we consider a lineage graph to be in one following classes of graph (though implementation may not support the full range in Phase 1, design should, and architecture should or at least should be extensible enough to)


- Directed acyclic graph (DAG)
 - Rooted tree
 - Ancestral recombination graph (ARG); see `codebases-and-documentation/tskit` for reference implementation. Read the files in the archive, documents first, then python code, line-by-line.
 - Phylogenetic network (most definitions)
- Unrooted tree
- (TBD) Gene flow networks?

## Canonical data model requirements

The package must define a canonical structure representation that can support at minimum:

* Any single lineage graph, which may belong to any of the above classes of abstractions.
  **Note:** Not all of these may need full implementation in Phase 1, but the architecture and infrastructure design and implementation should be designed to support these; if this would add too much complexity, can be deferred following discussion.
* Collections of these lineage graphs from one file
* Vertex labels
* Edge lengths
* Edge-level and vertex-level annotations
* Graph or tree-level annotations and metadata
* File-level metadata and provenance
* Partial preservation of format-specific constructs that do not have a perfect common denominator

The canonical model must distinguish a **single lineage graph** from a **lineage graph collection**, because both Newick-family and NEXUS-family workflows commonly contain multiple lineage tree graphs in a single logical resource. This requirement is also consistent with common phylogenetic tooling outside Julia, where parsers often distinguish “read one tree” from “parse all trees in a file.” 

The canonical model must also support loss accounting. When converting between formats, the package must be able to report whether information was preserved, downgraded, or dropped.

## Public API design

### FileIO-facing API

The FileIO-facing surface will be conventional and minimal.

Supported targets:

* `load(filename; kwargs...)`
* `save(filename, data; kwargs...)`
* `load(File{format"..."}(filename); kwargs...)`
* `save(File{format"..."}(filename), data; kwargs...)`
* `load(Stream{format"..."}(io, filename); kwargs...)`
* `save(Stream{format"..."}(io, filename), data; kwargs...)`

These forms align with the FileIO reference and implementation model. ([Julia.io][4])

### Package-native API

Because FileIO does not define raw string-content loading as part of the standard frontend, package-native convenience entry points will be specified separately from the FileIO contract.

Planned package-native capabilities:

* loading from raw text strings
* loading from multiple files in one call
* lazy iteration over tree records in a resource
* explicit parser selection independent of file extension
* structural projections into `AbstractTrees` and `AbstractGraph`

The PRD treats these as first-class product requirements, but they are not to be described as part of the FileIO contract itself. FileIO’s documented high-level interface is centered on filenames, streams, `File{fmt}`, and `Stream{fmt}`. ([Julia.io][4])

## Streaming and lazy access design

### Decision on `loadstreaming`

The Phase 1 generator interface will **not** be named `loadstreaming` unless the implementation is later redesigned to satisfy FileIO’s decoded-stream model. Under current requirements, the package should instead define package-native lazy accessors such as:

* a lazy tree iterator over a file or stream
* lazy `AbstractTrees` views over single trees and tree collections
* lazy `AbstractGraph` views over single trees and tree collections

This is the cleanest interpretation of FileIO’s docs. FileIO’s own terminology reserves `loadstreaming` for something stream-like that can be read from, rather than a semantic iterator over already-decoded tree objects. ([Julia.io][1])

### Phase 1 lazy interfaces

Phase 1 will include parameterized functions returning lazy or generator-like access objects for:

* an `AbstractTrees` interface over a single tree
* an `AbstractTrees` interface over collections of trees in a file
* an `AbstractGraph` interface over a single tree
* an `AbstractGraph` interface over collections of trees in a file

These objects should preserve file provenance and optional metadata where feasible.

### Future true streaming

A true FileIO `loadstreaming` implementation is deferred to a later phase and will only be added if the package introduces a decoded stream abstraction whose semantics match FileIO’s documented expectations, including `read` and `close`. ([Julia.io][1])

## Format taxonomy and phased scope

### Phase 1 formats

Phase 1 will support:

* `format"Newick"`
* `format"PhyloGraphML"`

For Newick, the package will support multiple user-facing extensions, including the user-specified `.tre`, `.tree`, `.trees`, `.newick`, and `.nwk`, with support for additional Newick-family aliases as implementation experience warrants.

For GraphML, the package will not claim all generic GraphML resources as phylogenetic. GraphML itself is a general-purpose graph markup language with an extension mechanism, and GraphIO already documents GraphML support for Julia graph persistence. Accordingly, this package will treat phylogeny-oriented GraphML support as a **profiled subtype**, represented internally by a distinct FileIO format tag such as `format"PhyloGraphML"`, not by generic `format"GraphML"`. Detection should require either explicit format override or evidence of a package-defined phylogenetic profile. ([GraphML][7])

### Phase 2 formats

Phase 2 will support:

* `format"Nexus"` for `.nex`, `.nexus`, and likely `.nxs`
* ten additional distinct phylogenetic or phylogeny-adjacent formats/profiles discovered in the landscape review

The revised Phase 2 candidate set is:

1. `format"NeXML"`
2. `format"PhyloXML"`
3. `format"NHX"`
4. `format"ExtendedNewick"`
5. `format"RichNewick"`
6. `format"JPlace"`
7. `format"CDAO"`
8. `format"NexSON"`
9. `format"NCBIBioTreeASN1"`
10. `format"PhyJSON"`

These are not all equivalent in scope. Some are strict tree formats, some are richer phylogenetic exchange formats, some are network extensions, and some are tree-adjacent exchange or placement formats. But they are all legitimate members of the landscape the package should account for in a roadmap. Newick is documented as the classic tree representation; NEXUS is a broader phylogenetic container beginning with `#NEXUS`; NeXML is an XML phyloinformatics exchange standard inspired by NEXUS; phyloXML is an XML language for phylogenetic trees and associated metadata; NHX is an annotated Newick extension; Extended Newick and Rich Newick target phylogenetic networks; jplace is a JSON-based standard for phylogenetic placements; CDAO formalizes phylogenetic trees and character-state data in an ontology setting; NexSON is Open Tree of Life’s JSON representation derived from NeXML conventions; and NCBI exposes a BioTree ASN.1 specification. ([Phylip Web][8])

The practical implication is that Phase 2 should define a support matrix, not just a flat format list. Each candidate format must be labeled as one of:

* tree
* tree collection container
* annotated tree
* phylogenetic network
* tree-adjacent placement or ontology format
* experimental or profile-specific JSON/XML mapping

## Format-specific design requirements

### Newick

Newick Phase 1 support must include:

* single-tree parsing
* multi-tree files
* rooted and unrooted handling where representable
* branch lengths
* internal node labels
* package policy for comments and common annotation dialects
* a well-defined fallback story for Newick-family extensions

Newick is the baseline interchange format and must be treated as the reference implementation for the first vertical slice. ([Phylip Web][8])

### Nexus

NEXUS Phase 2 support must include:

* `#NEXUS` header detection
* multi-block parsing
* tree extraction from tree-containing blocks
* multi-tree support
* partial support for broader phylogenetic metadata where feasible

Because NEXUS is a container-like syntax rather than just a bare tree encoding, the package must separate tree loading requirements from broader block preservation requirements. NEXUS commonly stores taxa, matrices, distances, and trees, not just trees. ([Paul O. Lewis Lab Home][9])

### GraphML phylogenetic profile

The package will support GraphML only under a phylogeny-specific profile.

Requirements:

* no blanket assumption that `.graphml` means phylogenetic data
* explicit format forcing must be supported
* automatic detection may only succeed when a package-defined phylogenetic schema/profile/metadata signature is present
* export must preserve enough information to round-trip phylogenetic trees faithfully within the package’s declared profile

This avoids semantic collision with generic graph persistence while still enabling GraphML as a useful representation for trees with richer typed attributes. GraphML itself is deliberately general-purpose and extensible. ([GraphML][7])

## Method requirements

### `load`

Package requirements for eager load:

* dispatch internally to the relevant format-specific parser
* collect lazy iteration results into a concrete tree collection type or vector-like container
* support explicit format override
* support stream input
* support multiple-file convenience methods as package-native APIs
* support string-content loading as package-native APIs, not as a claim about standard FileIO behavior

### `save`

Package requirements for save:

* save single trees
* save collections where the target format supports them
* support explicit format override
* preserve metadata where the target format can represent it
* report or warn on lossy serialization

### Multiple-file loading

Multiple-file methods are product requirements but package-native rather than FileIO-standard. They should support uniform loading of many homogeneous resources and optionally heterogeneous resources when explicit format overrides are supplied.

### String loading

Raw string loading is a required package-native capability. It must support explicit format specification, because raw strings do not provide reliable extension-based detection.

## Parameterization requirements

The package must expose parameterized functions and types wherever structural or storage choices are meaningful.

This includes parameterization over:

* tree representation type
* tree collection representation type
* node/edge annotation payload type
* view type (`AbstractTrees` vs `AbstractGraph`)
* parser mode or dialect strictness
* lossy vs strict conversion policy

The purpose is to keep the core generic and composable rather than prematurely committing the entire package to one concrete tree storage type.

## Error handling requirements

The package must distinguish at least four classes of failure:

* syntax parse error
* unsupported but recognized construct
* ambiguous format detection
* lossy conversion or serialization downgrade

Errors must carry source location where feasible.

For ambiguous formats, explicit format override must always be available through `File{format"..."}(...)` and corresponding package-native APIs. This follows directly from the FileIO model of explicit format forcing. ([Julia.io][4])

## Detection and extension policy

The package must maintain a per-format capability profile containing:

* recognized extensions
* magic bytes, if any
* detection function, if required
* whether the format is safely auto-detectable
* whether the format should be registration-candidate or package-private only

This is especially important because not all phylogenetic formats have strong magic bytes. FileIO supports registration through magic bytes, extensions, and detection functions, but packages should use deterministic detection when available and fall back to explicit format forcing when not. ([Julia.io][4])

For ambiguous or profile-based XML/JSON families, the package should prefer package-private explicit formats first, then promote only the stable ones to registration candidates.

## Registration-ready requirements

Although registry submission is not part of this PRD, the package must be built so that registration later is straightforward.

Registration-ready means:

* every candidate FileIO format has a stable internal `format"..."`
* every candidate format has a clear extension set
* magic bytes or detection policy are documented
* load/save support is enumerated separately
* package UUID is available
* loader/saver ownership is unambiguous
* documentation states whether the format is general, profiled, or package-private

This is exactly the information FileIO requires when adding `add_format(fmt, magic, extension, libraries...)` and associated loader/saver entries. ([Julia.io][2])

## FYI-only registration protocol

For later use, the FileIO registration protocol is:

1. implement the backend package first, using private loader/saver methods rather than extending `FileIO.load` directly
2. choose a stable `format"IDENTIFIER"` for each registration candidate
3. verify detection behavior locally
4. add `add_format(fmt, magic, extension, libraries...)` to FileIO’s registry data, using the package UUID from `Project.toml`
5. add loader and saver registration as appropriate
6. validate that implicit and explicit dispatch work cleanly before opening the FileIO PR

That summary comes directly from FileIO’s registration and implementation docs, but it is included here only as deployment context, not as an implementation task for this PRD. ([Julia.io][2])

## Phase plan

### Phase 1

Phase 1 deliverables:

* Canonical lineage graph and lineage graph-collection model:
    - Encapsulated into its own source tree and package layout, "LineageGraphs.jl"
* Bundled submodule architecture
* Newick support with multiple extensions
* Phylogeny-profiled GraphML support under a non-generic internal format tag
* FileIO-compatible eager `load` and `save`
* Package-native lazy iterators
* Package-native `AbstractTrees` views
* Package-native `AbstractGraph` views
* Explicit format override support
* Stream input support
* String-content and multi-file convenience APIs
* Registration-ready documentation and format matrix
* TBD: `tskit` support 

### Phase 2

Phase 2 deliverables:

* Additional data formats TBD
* Richer metadata preservation
* Format-to-format conversion matrix
* stricter detection and validation policies
* initial round-trip compliance suite across major formats

### Deferred phase

Deferred items:

* true FileIO `loadstreaming` / `savestreaming`
* binary or compressed high-throughput phylogeny transport profiles

## Success criteria

The package is successful when:

* `load("example.nwk")` and `save("example.nwk", tree)` work through FileIO in the expected backend style ([Julia.io][4])
* explicit format forcing works for ambiguous cases
* the package can lazily traverse multi-tree resources without full eager parsing
* the same resource can be projected into both `AbstractTrees` and `AbstractGraph` views
* GraphML support is phylogeny-specific and does not pretend to own generic GraphML
* the project documentation is complete enough that FileIO registration could be done without architectural redesign

## Final design decisions captured in this revision

The revised PRD makes four substantive commitments.

Each format will live in a bundled submodule.

GraphML support will be phylogeny-profiled and internally tagged distinctly rather than “stealing” generic GraphML.

The Phase 1 lazy generator/view API will be package-native and **not** named `loadstreaming` unless later redesigned to match FileIO’s decoded-stream semantics. ([Julia.io][1])

The package will be designed all the way to registration-ready production, while registration itself remains out of scope for the work defined here. ([Julia.io][2])

[1]: https://juliaio.github.io/FileIO.jl/stable/implementing/ "Implementing loaders/savers · FileIO"
[2]: https://juliaio.github.io/FileIO.jl/stable/registering/ "Registering a new format · FileIO"
[3]: https://juliaio.github.io/FileIO.jl/stable/?utm_source=chatgpt.com "Home · FileIO - GitHub Pages"
[4]: https://juliaio.github.io/FileIO.jl/stable/reference/ "Reference · FileIO"
[5]: https://juliagraphs.org/Graphs.jl/dev/?utm_source=chatgpt.com "Graphs.jl · Graphs.jl - JuliaGraphs"
[6]: https://biopython.org/docs/dev/Tutorial/chapter_phylo.html?utm_source=chatgpt.com "Phylogenetics with Bio.Phylo — Biopython 1.88.dev0 documentation"
[7]: https://graphml.graphdrawing.org/specification.html?utm_source=chatgpt.com "GraphML Specification"
[8]: https://phylipweb.github.io/phylip/newicktree.html?utm_source=chatgpt.com "The Newick tree format - GitHub Pages"
[9]: https://plewis.github.io/nexus/?utm_source=chatgpt.com "The NEXUS file format - Paul O. Lewis Lab Home"
