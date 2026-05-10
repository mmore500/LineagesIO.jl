# LineagesIO

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jeetsukumaran.github.io/LineagesIO.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jeetsukumaran.github.io/LineagesIO.jl/dev/)
[![Build Status](https://github.com/jeetsukumaran/LineagesIO.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jeetsukumaran/LineagesIO.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

LineagesIO.jl provides two package-owned public read surfaces for rooted
lineage graphs. `LineagesIO.read_lineages(...)` is the library-created path:
it returns a new graph. `LineagesIO.read_lineages!(...)` is the
supplied-instance path: it populates a caller-owned empty graph in place.
Retained `FileIO.load(...)` surfaces stay available as compatibility wrappers,
and `load_alife_table(...)` stays available as the in-memory Tables.jl
convenience wrapper.

Phase 1 currently supports rooted-tree and rooted-network-capable Newick
sources through:

- `read_lineages("tree.nwk")` for supported Newick extensions
- `read_lineages("tree.txt"; format = :newick)` for explicit package-owned
  override on ambiguous `.txt` paths
- `read_lineages(io; source_path = "tree.nwk")` or
  `read_lineages(io; format = :newick)` for already-open streams
- `read_lineages("tree.nwk", NodeT)` for library-created-basenode construction
- `read_lineages("tree.nwk", BuilderDescriptor(builder, HandleT[, ParentCollectionT]))`
  for the first-class typed builder surface
- `read_lineages!("tree.nwk", basenode)` for supplied-basenode binding when
  `construction_handle_type(basenode)` is defined
- `read_lineages("phylogeny.csv")` for alife data standard CSV sources
- `load_alife_table(table)` for in-memory Tables.jl-compatible alife inputs
- optional `PhyloNetworks.jl` materialization through
  `read_lineages("network.nwk", HybridNetwork)`
- optional `MetaGraphsNext.jl` materialization through
  `read_lineages("tree.nwk", MetaGraph)`
- lazy `LineageGraphStore.graphs` iteration with authoritative `node_table`
  and `edge_table`
- retained `FileIO.load(...)` compatibility wrappers, including
  `File{format"..."}`

## Quick start

Tables-only loads preserve authoritative structure and retained annotations
without materializing a user graph:

```julia
using LineagesIO

store = read_lineages("primates.nwk")
asset = first(store.graphs)

graph, basenode, node_table, edge_table = asset

graph === nothing
basenode === nothing
node_table === asset.node_table
edge_table === asset.edge_table
```

Use an explicit override when the source path is intentionally ambiguous:

```julia
using LineagesIO

store = read_lineages("primates.txt"; format = :newick)
```

If you already rely on `FileIO`, the retained compatibility wrapper
`load(File{format"Newick"}("primates.txt"))` continues to work. The
package-owned first-class public stories are `read_lineages(...)` for
library-created graphs and `read_lineages!(...)` for supplied-instance binding.

Construction loads reuse the same authoritative tables and deliver retained
annotation access through `NodeRowRef` and `EdgeRowRef` values:

```julia
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

store = read_lineages("annotated_tree.nwk", DemoNode)
asset = first(store.graphs)

graph, basenode, node_table, edge_table = asset
graph === nothing
basenode === asset.basenode
LineagesIO.basenode(asset) === basenode
```

For typed builder-driven construction, use the first-class descriptor surface:

```julia
builder_store = read_lineages(
    "annotated_tree.nwk",
    BuilderDescriptor(my_builder, DemoNode),
)
```

The older `load(...; builder = fn)` story remains supported as a compatibility
wrapper only.

## PhyloNetworks soft release

Loading `PhyloNetworks` activates the package extension that materializes
native `HybridNetwork` values from rooted-network-capable and tree-compatible
rooted Newick sources while keeping authoritative `node_table` and `edge_table`
access attached to each `LineageGraphAsset`.

```julia
using LineagesIO
using PhyloNetworks: HybridNetwork

network_store = read_lineages("hybrid_example.nwk", HybridNetwork)
network_asset = first(network_store.graphs)

tree_store = read_lineages("primates.txt", HybridNetwork; format = :newick)
tree_asset = first(tree_store.graphs)
```

The current soft-release contract includes:

- rooted-network native loads through `read_lineages(path, HybridNetwork)`
- explicit package-owned override through
  `read_lineages(path, HybridNetwork; format = :newick)`
- tree-compatible rooted loads through the same `HybridNetwork` surface
- secondary `read_lineages!(path, HybridNetwork())` supplied-target binding on
  one-graph sources
- first-class authoritative `node_table` and `edge_table` retention after load

The current soft-release contract does not include unrooted-network support,
additional format owners, or serialization. See
`examples/src/phylonetworks_mwe01.jl` and `examples/src/phylonetworks_mwe02.jl`
for runnable package examples.

Retained `FileIO.load(...)` wrapper flows remain supported as
compatibility-only entry paths.

For tree-compatible rooted inputs with empty leaf labels, the authoritative
blank label remains in `node_table`, while the native `HybridNetwork` may
carry a synthesized nonempty leaf name for downstream PhyloNetworks
compatibility and round-trip writing.

## MetaGraphsNext extension

Loading `MetaGraphsNext` activates the package extension that materializes a
native `MetaGraphsNext.MetaGraph` type directly from the source. The
tree-only library-created path is `read_lineages(src, MetaGraph)`: it
constructs a directed `MetaGraph` with `Nothing` vertex data and
`Union{Nothing, Float64}` edge data, and it does not treat arbitrary concrete
`Type{<:MetaGraph}` requests or hand-written partial `MetaGraph{...}` type
literals as a customization path. Nodes carry `Symbol` labels
(`graph[Symbol(3)]`), and source edge weights are stored as
`Union{Nothing, Float64}` edge data accessible via
`graph[Symbol(i), Symbol(j)]`.

For multi-parent sources or alternate metadata parameterizations, use
`read_lineages!(src, my_graph)` with an empty caller-supplied `MetaGraph`
with `Symbol` labels. Supported user-owned custom data is constructor-based:
implement `VertexData(::LineagesIO.NodeRowRef)` and
`EdgeData(::LineagesIO.EdgeWeightType, ::LineagesIO.EdgeRowRef)` on the types
you want stored in the graph.

```julia
using LineagesIO
using MetaGraphsNext: MetaGraph

store = read_lineages("annotated_tree.nwk", MetaGraph)
asset = first(store.graphs)

graph = asset.graph
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
