---
date-created: 2026-04-27T00:00:00
date-revised: 2026-04-28T00:00:00
status: authoritative-annex
parent-brief: design/brief.md
---

# LineagesIO.jl — Core brief user stories

## Authority

This document is the authoritative user-story annex to `design/brief.md`.

It must be read alongside:

- `design/brief.md`
- `design/brief--community-support-objectives.md` when extension implications matter
- `design/brief--community-support-user-stories.md` when trancheing spans core and extension behavior

This annex anchors the intended package vision through numbered user stories
and Julia syntax examples.

If any example in this annex conflicts with `design/brief.md`, the core brief
governs and this annex must be revised.

Exact identifiers already ratified in `design/brief.md` and
`STYLE-vocabulary.md` are normative. Example-only filenames and other
incidental values in this annex illustrate call shape and verification intent.
They do not create new identifier contracts, ratify new format names, or
authorize new target-package load surfaces by themselves.

## How to use this annex

Tranche files, tasking files, review scopes, and verification plans derived
from the core brief should cite the relevant user story numbers from this
annex.

The examples below are not merely decorative snippets. They represent the
intended package-facing behaviors that tranche and task design should preserve
or deliberately stage.

## User story 1: Tables-only load from a simple Newick file

As a user who only needs authoritative structure and retained annotation
tables, I want `load("file.nwk")` to return a lazy `LineageGraphStore`
without forcing graph materialization into a consumer package.

```julia
using FileIO: load

store = load("primates.nwk")
asset = first(store.graphs)

asset.materialized === nothing
asset.node_table
asset.edge_table
asset.graph_label
asset.source_path
```

## User story 2: Explicit format override and stream-based load

As a user with ambiguous filenames or already-open I/O, I want FileIO-style
explicit override through `File{format"..."}(...)` and `Stream{fmt}(io)`.

```julia
using FileIO

store_from_file = load(File{format"Newick"}("primates.txt"))

open("primates.txt", "r") do io
    store_from_stream = load(Stream{format"Newick"}(io, "primates.txt"))
    first(store_from_stream.graphs)
end
```

## User story 3: Lazy iteration over multi-graph sources

As a user loading a source that contains many graphs, I want the package to
expose a lazy graph iterator rather than forcing eager allocation of all graph
assets.

```julia
using FileIO: load

store = load("posterior.trees")

for asset in store.graphs
    @show asset.index
    @show asset.collection_idx
    @show asset.collection_graph_idx
    @show asset.node_table
end
```

## User story 4: Library-created-root construction into custom node handles

As a package user with a custom node model, I want to implement
`LineagesIO.add_child` and let LineagesIO construct the graph incrementally
through the public protocol.

```julia
using FileIO: load
using LineagesIO

mutable struct DemoNode{NodeRefT}
    nodekey::LineagesIO.StructureKeyType
    label::String
    nodedata::NodeRefT
    child_collection::Vector{DemoNode{NodeRefT}}
end

function LineagesIO.add_child(
    parent::Nothing,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekey::Nothing,
    edgeweight::Nothing;
    edgedata = nothing,
    nodedata,
)
    return DemoNode(nodekey, String(label), nodedata, DemoNode{typeof(nodedata)}[])
end

function LineagesIO.add_child(
    parent::DemoNode,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekey::LineagesIO.StructureKeyType,
    edgeweight;
    edgedata,
    nodedata,
)
    child = DemoNode(nodekey, String(label), nodedata, DemoNode{typeof(nodedata)}[])
    push!(parent.child_collection, child)
    return child
end

store = load("primates.nwk", DemoNode)
asset = first(store.graphs)
basenode = asset.materialized
```

## User story 5: Root binding onto a caller-supplied basenode

As a user who already owns the root graph object, I want LineagesIO to bind the
parsed basenode onto my supplied `basenode` and then continue descendant
construction through `add_child`.

```julia
using FileIO: load
using LineagesIO

mutable struct BoundNode{NodeRefT}
    nodekey::Union{Nothing,LineagesIO.StructureKeyType}
    label::String
    nodedata::Union{Nothing,NodeRefT}
    child_collection::Vector{BoundNode{NodeRefT}}
end

function LineagesIO.bind_basenode!(
    basenode::BoundNode,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString;
    nodedata,
)
    basenode.nodekey = nodekey
    basenode.label = String(label)
    basenode.nodedata = nodedata
    return basenode
end

function LineagesIO.add_child(
    parent::BoundNode,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekey::LineagesIO.StructureKeyType,
    edgeweight;
    edgedata,
    nodedata,
)
    child = BoundNode(nodekey, String(label), nodedata, BoundNode{typeof(nodedata)}[])
    push!(parent.child_collection, child)
    return child
end

basenode = BoundNode(nothing, "", nothing, BoundNode{Any}[])
store = load("primates.nwk", basenode)
asset = first(store.graphs)
asset.materialized === basenode
```

## User story 6: Eager annotation interpretation during construction

As a user who wants semantic values immediately, I want to read retained
annotation text from row references during `add_child` and coerce it in my own
layer.

```julia
using LineagesIO

mutable struct PosteriorNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    posterior::Union{Nothing,Float64}
    child_collection::Vector{PosteriorNode}
end

function LineagesIO.add_child(
    parent::Union{PosteriorNode,Nothing},
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekey,
    edgeweight;
    edgedata = nothing,
    nodedata,
)
    posterior_txt = LineagesIO.node_property(nodedata, :posterior)
    posterior = posterior_txt === nothing ? nothing : parse(Float64, posterior_txt)
    node = PosteriorNode(nodekey, String(label), posterior, PosteriorNode[])
    parent === nothing || push!(parent.child_collection, node)
    return node
end
```

## User story 7: Deferred annotation access after load

As a user who wants lightweight nodes and scalable post-load workflows, I want
to retain authoritative tables and interpret annotations later through helper
functions and wrappers.

```julia
using FileIO: load
using LineagesIO

store = load("annotated_tree.nwk")
asset = first(store.graphs)

bootstrap(nodekey) = begin
    txt = LineagesIO.node_property(asset.node_table, nodekey, :bootstrap)
    txt === nothing ? nothing : parse(Float64, txt)
end

hybrid_gamma(edgekey) = begin
    txt = LineagesIO.edge_property(asset.edge_table, edgekey, :gamma)
    txt === nothing ? nothing : parse(Float64, txt)
end

bootstrap(4)
hybrid_gamma(7)
```

## User story 8: Multi-parent rooted-network construction

As a user working with rooted networks, I want the same core package to emit a
multi-parent `add_child` call with one `basenode` and retained row references.

```julia
using LineagesIO

mutable struct NetworkNode
    nodekey::LineagesIO.StructureKeyType
    label::String
end

function LineagesIO.add_child(
    parent_collection::AbstractVector{NetworkNode},
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekeys::AbstractVector{LineagesIO.StructureKeyType},
    edgeweights::AbstractVector;
    edgedata,
    nodedata,
)
    @assert length(parent_collection) == length(edgekeys) == length(edgeweights)
    @assert length(edgedata) == length(edgekeys)
    return NetworkNode(nodekey, String(label))
end
```

## User story 9: Source and collection coordinates remain attached to each graph

As a user loading collections, I want each returned graph asset to preserve its
source and collection coordinates so I can reconcile tables back to the input
layout.

```julia
using FileIO: load

store = load("posterior.trees")
asset = first(store.graphs)

asset.source_idx
asset.collection_idx
asset.collection_graph_idx
asset.collection_label
asset.graph_label
```

## User story 10: Informative errors for ambiguous or invalid loads

As a user, I want the package to fail loudly and specifically when it cannot
safely infer a format or when I use a one-graph basenode-binding surface on a
multi-graph source.

```julia
julia> load("primates.txt")
ERROR: Ambiguous format. Supply an explicit override such as `File{format\"Newick\"}(...)`.

julia> load("posterior.trees", my_basenode)
ERROR: The supplied `basenode` load surface is valid only for a source that yields exactly one graph.

julia> LineagesIO.node_property(asset.node_table, 4, :missing_field)
ERROR: Requested node property `:missing_field` is not present in the authoritative node table.
```
