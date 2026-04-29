# LineagesIO

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jeetsukumaran.github.io/LineagesIO.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jeetsukumaran.github.io/LineagesIO.jl/dev/)
[![Build Status](https://github.com/jeetsukumaran/LineagesIO.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jeetsukumaran/LineagesIO.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

LineagesIO.jl provides FileIO-compatible loading of rooted lineage graphs into
package-owned authoritative tables and, when requested, through a
single-parent or multi-parent graph-construction protocol.

Phase 1 currently supports rooted-tree and rooted-network-capable Newick
sources through:

- safe bare `load("tree.nwk")` loads for supported Newick extensions
- explicit overrides through `load(File{format"Newick"}(...))`
- stream-based loads through `load(Stream{format"Newick"}(...))`
- library-created-root construction through `load("tree.nwk", NodeT)`
- supplied-root binding through `load("tree.nwk", rootnode)`
- optional `PhyloNetworks.jl` materialization through
  `load("network.nwk", HybridNetwork)`
- tree-compatible rooted `HybridNetwork` loads through the same public surface
- secondary supplied-target `HybridNetwork()` binding on one-graph sources
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

## PhyloNetworks soft release

Loading `PhyloNetworks` activates the package extension that materializes
native `HybridNetwork` values from rooted-network-capable and tree-compatible
rooted `format"Newick"` sources while keeping authoritative `node_table` and
`edge_table` access attached to each `LineageGraphAsset`.

```julia
using FileIO
using LineagesIO
using PhyloNetworks: HybridNetwork

network_store = load("hybrid_example.nwk", HybridNetwork)
network_asset = first(network_store.graphs)

tree_store = load(File{format"Newick"}("primates.txt"), HybridNetwork)
tree_asset = first(tree_store.graphs)
```

The current soft-release contract includes:

- rooted-network native loads through `load(path, HybridNetwork)`
- explicit override through `load(File{format"Newick"}(...), HybridNetwork)`
- tree-compatible rooted loads through the same `HybridNetwork` surface
- secondary supplied-target binding through `load(path, HybridNetwork())` on
  one-graph sources
- first-class authoritative `node_table` and `edge_table` retention after load

The current soft-release contract does not include unrooted-network support,
additional format owners, or serialization. See
`examples/src/phylonetworks_mwe01.jl` and `examples/src/phylonetworks_mwe02.jl`
for runnable package examples.

For tree-compatible rooted inputs with empty leaf labels, the authoritative
blank label remains in `node_table`, while the native `HybridNetwork` may
carry a synthesized nonempty leaf name for downstream PhyloNetworks
compatibility and round-trip writing.

## MetaGraphsNext extension

Loading `MetaGraphsNext` activates the package extension that materializes a
native `MetaGraphsNext.MetaGraph` type directly from the source. Nodes carry
`Symbol` labels (`graph[Symbol(3)]`), and source edge weights are stored as
`Union{Nothing, Float64}` edge data accessible via `graph[Symbol(i), Symbol(j)]`.
Pass an empty MetaGraph instance to `load` when custom `VertexData`/`EdgeData`
types or multi-parent network sources are needed.

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext: MetaGraph

store = load("annotated_tree.nwk", MetaGraph)
asset = first(store.graphs)

graph = asset.materialized
graph[Symbol(1), Symbol(2)]  # source edge weight (Union{Nothing,Float64})
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
