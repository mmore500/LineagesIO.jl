# LineagesIO

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jeetsukumaran.github.io/LineagesIO.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jeetsukumaran.github.io/LineagesIO.jl/dev/)
[![Build Status](https://github.com/jeetsukumaran/LineagesIO.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jeetsukumaran/LineagesIO.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

LineagesIO.jl provides FileIO-compatible loading of rooted lineage graphs into
package-owned authoritative tables and, when requested, through a
single-parent graph-construction protocol.

Phase 1 currently supports simple rooted Newick sources through:

- safe bare `load("tree.nwk")` loads for supported Newick extensions
- explicit overrides through `load(File{format"Newick"}(...))`
- stream-based loads through `load(Stream{format"Newick"}(...))`
- library-created-root construction through `load("tree.nwk", NodeT)`
- supplied-root binding through `load("tree.nwk", rootnode)`
- optional `MetaGraphsNext.jl` materialization through the package-extension path
- explicit builder callbacks through `load("tree.nwk"; builder = fn)`
- lazy `LineageGraphStore.graphs` iteration with authoritative `node_table`
  and `edge_table`
- informative explicit-override errors for ambiguous text extensions such as
  `.txt`

## Quick start

Tables-only loads preserve authoritative structure and retained annotations
without materializing a user graph:

```julia
using FileIO: load
using LineagesIO

store = load("primates.nwk")
asset = first(store.graphs)

asset.materialized === nothing
asset.node_table
asset.edge_table
```

Use an explicit override when the source path is intentionally ambiguous:

```julia
using FileIO
using LineagesIO

store = load(File{format"Newick"}("primates.txt"))
```

Construction loads reuse the same authoritative tables and deliver retained
annotation access through `NodeRowRef` and `EdgeRowRef` values:

```julia
using FileIO: load
using LineagesIO

mutable struct DemoNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    posterior::Union{Nothing, String}
    children::Vector{DemoNode}
end

function LineagesIO.add_child(
    ::Nothing,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata = nothing,
    nodedata,
)
    posterior = LineagesIO.node_property(nodedata, :posterior)
    return DemoNode(nodekey, String(label), posterior, DemoNode[])
end

function LineagesIO.add_child(
    parent::DemoNode,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata,
    nodedata,
)
    posterior = LineagesIO.node_property(nodedata, :posterior)
    child = DemoNode(nodekey, String(label), posterior, DemoNode[])
    push!(parent.children, child)
    return child
end

store = load("annotated_tree.nwk", DemoNode)
rootnode = first(store.graphs).materialized
```

## MetaGraphsNext extension

Loading `MetaGraphsNext` activates the pacakge extension that provides for materialization of a native `MetaGraphs.MetaGraph` type directly from the source.

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext: MetaGraph

store = load("annotated_tree.nwk", MetaGraph)
asset = first(store.graphs)

graph = asset.materialized
graph
asset.node_table
asset.edge_table
```

If `AbstractTrees.jl` is also loaded, the same extension-owned tree-view type
gains rooted traversal methods without changing the basic MetaGraphsNext load
path:

```julia
using AbstractTrees

tree_view = LineagesIO.MetaGraphsNextTreeView(asset)

collect(AbstractTrees.PreOrderDFS(tree_view))
```
