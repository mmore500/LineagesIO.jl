```@meta
CurrentModule = LineagesIO
```

# LineagesIO

LineagesIO.jl provides FileIO-compatible loading of rooted lineage graph
sources into package-owned authoritative tables and, when requested, through a
single-parent graph-construction protocol.

## Quick start

Tables-only loads preserve authoritative structure and retained annotations
without forcing graph materialization:

```julia
using FileIO: load
using LineagesIO

store = load("primates.nwk")
asset = first(store.graphs)

asset.graph_rootnode === nothing
asset.node_table
asset.edge_table
```

## Supported load surfaces

Phase 1 supports simple rooted Newick loads through:

- `load("tree.nwk")` for safe Newick extensions
- `load(File{format"Newick"}("tree.txt"))` for explicit override on ambiguous paths
- `load(Stream{format"Newick"}(io, "tree.txt"))` for already-open I/O
- `load("tree.nwk", NodeT)` for library-created-root construction
- `load("tree.nwk", rootnode)` for supplied-root binding on one-graph sources
- the optional `MetaGraphsNext.jl` extension path for MetaGraph materialization
- `load("tree.nwk"; builder = fn)` for explicit builder callbacks

Every load returns a `LineageGraphStore` whose `graphs` field lazily
iterates `LineageGraphAsset` values with authoritative `node_table` and
`edge_table` objects. For the tables-only path, `graph_rootnode === nothing`.

Construction loads reuse the same authoritative tables and expose retained
annotation values through `NodeRowRef`, `EdgeRowRef`, `node_property`, and
`edge_property`:

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
rootnode = first(store.graphs).graph_rootnode
```

## MetaGraphsNext extension

Loading `MetaGraphsNext` activates the LineagesIO package extension for the
simple rooted Newick reference path. The extension-owned handle and tree-view
types remain in the extension module and can be retrieved through
`Base.get_extension`.

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext

extension = Base.get_extension(LineagesIO, :MetaGraphsNextIO)
store = load("annotated_tree.nwk", extension.MetaGraphsNextNodeHandle)
asset = first(store.graphs)

rootnode = asset.graph_rootnode
rootnode.nodekey
asset.node_table
asset.edge_table
```

If `AbstractTrees.jl` is also loaded, the same extension-owned tree-view type
supports rooted traversal:

```julia
using AbstractTrees

extension = Base.get_extension(LineagesIO, :MetaGraphsNextIO)
tree_view = extension.MetaGraphsNextTreeView(
    asset.graph_rootnode,
    asset.node_table,
    asset.edge_table,
)

collect(AbstractTrees.PreOrderDFS(tree_view))
```

```@index
```

```@autodocs
Modules = [LineagesIO]
```
