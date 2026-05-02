```@meta
CurrentModule = LineagesIO
```

# LineagesIO

LineagesIO.jl provides FileIO-compatible loading of rooted lineage graph
sources into package-owned authoritative tables and, when requested, through
single-parent or multi-parent graph-construction protocol tiers.

## Quick start

Tables-only loads preserve authoritative structure and retained annotations
without forcing graph materialization:

```julia
using FileIO: load
using LineagesIO

store = load("primates.nwk")
asset = first(store.graphs)

graph, basenode, node_table, edge_table = asset

graph === nothing
basenode === nothing
node_table === asset.node_table
edge_table === asset.edge_table
```

## Supported load surfaces

Phase 1 supports rooted-tree and rooted-network-capable Newick loads through:

- `load("tree.nwk")` for safe Newick extensions
- `load(File{format"Newick"}("tree.txt"))` for explicit override on ambiguous paths
- `load(Stream{format"Newick"}(io, "tree.txt"))` for already-open I/O
- `load("tree.nwk", NodeT)` for library-created-basenode construction
- `load("tree.nwk", basenode)` for supplied-basenode binding on one-graph sources
- the optional `PhyloNetworks.jl` extension path for rooted-network and
  tree-compatible rooted `HybridNetwork` materialization
- secondary supplied-target `HybridNetwork()` binding on one-graph sources
- the optional `MetaGraphsNext.jl` extension path for MetaGraph materialization
- `load("tree.nwk"; builder = fn)` for explicit builder callbacks
- `load(File{format"AlifeStandard"}("phylogeny.csv"))` for alife data standard CSV
  sources (see [Alife data standard](@ref))
- `load_alife_table(table)` for in-memory Tables.jl-compatible alife inputs

Every load returns a `LineageGraphStore` whose `graphs` field lazily
iterates `LineageGraphAsset` values with authoritative `node_table` and
`edge_table` objects. Each asset destructures in the stable public order
`(graph, basenode, node_table, edge_table)`. For the tables-only path, the
destructured `graph` and `basenode` values are both `nothing`.

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
asset = first(store.graphs)
graph, basenode, node_table, edge_table = asset
graph === nothing
LineagesIO.basenode(asset) === basenode
```

## Alife data standard

LineagesIO.jl loads phylogenies that follow the
[ALife phylogeny data standard](https://alife-data-standards.github.io/alife-data-standards/phylogeny.html);
see that specification for the full schema. LineagesIO requires `id` and
either `ancestor_list` or `ancestor_id`, and retains every other column
as a node annotation. Both `[NONE]`/`[none]`/`[None]`/`[]` (in
`ancestor_list`) and a self-referencing `ancestor_id == id` are
accepted basenode markers; multi-parent rows (`ancestor_list = [a,b]`)
materialize as multi-parent edges. Sources that yield disconnected
components produce one `LineageGraphAsset` per component, with each
component's alife `id` values remapped onto sequential `nodekey`s with
the basenode pinned at `nodekey == 1` (the original `id` is retained
as the node `label`).

`.csv` is registered as ambiguous, so the FileIO entry point requires an
explicit format wrapper:

```julia
using FileIO: File, Stream, load
using LineagesIO

store = load(File{LineagesIO.AlifeStandardFormat}("phylogeny.csv"))
asset = first(store.graphs)
```

For data already in memory, `load_alife_table` accepts any
Tables.jl-compatible object (`DataFrame`, `NamedTuple` of vectors, Arrow
table, etc.) and coerces `Integer`, `AbstractString`, or
`AbstractVector{<:Integer}` cells uniformly:

```julia
table = (
    id = [0, 1, 2, 3],
    ancestor_list = [Int[], [0], [0], [1, 2]],
)
store = load_alife_table(table; source_path = "in-memory")
```

Both surfaces accept the same construction targets as Newick loads
(`load(src, NodeT)`, `load(src, basenode)`, `load(src; builder = fn)`).

## PhyloNetworks extension

The current PhyloNetworks soft-release workflow is documented on the
[PhyloNetworks workflow](phylonetworks.md) page. That workflow covers:

- rooted-network native loads through `load(path, HybridNetwork)`
- explicit overrides through `load(File{format"Newick"}(...), HybridNetwork)`
- tree-compatible rooted loads through the same public surface
- authoritative `node_table` and `edge_table` retention after load
- secondary supplied-target binding for an empty `HybridNetwork()` on
  one-graph sources

## MetaGraphsNext extension

Loading `MetaGraphsNext` activates the LineagesIO package extension for
MetaGraph materialization. Nodes are labelled with `Symbol` keys so that
standard MetaGraph access works without wrapper types: `graph[Symbol(3)]` for
vertex data, `graph[Symbol(1), Symbol(2)]` for edge data. (Symbol literals
like `:foo` require an identifier name; integer-keyed nodes need `Symbol(n)`.)
The library-created path (`load(src, MetaGraph)`) always produces a directed
MetaGraph with `Nothing` vertex data and `Union{Nothing, Float64}` edge data,
making source edge weights immediately accessible. The library-created path
supports only single-parent (tree) sources; pass an empty MetaGraph instance
to `load` for multi-parent (network) sources.

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext

store = load("annotated_tree.nwk", MetaGraph)
asset = first(store.graphs)

# MetaGraph{Int, SimpleDiGraph{Int}, Symbol, Nothing, Union{Nothing,Float64}, ...}
graph = asset.graph
graph[Symbol(1), Symbol(2)]   # source edge weight (Union{Nothing,Float64})
graph[Symbol(3)]              # vertex data (nothing — VertexData=Nothing)
asset.node_table
asset.edge_table
```

To load multi-parent sources or to customise `VertexData`/`EdgeData` types,
pass an empty MetaGraph instance with `Symbol` labels:

```julia
using MetaGraphsNext: MetaGraph
using MetaGraphsNext.Graphs: SimpleDiGraph

my_graph = MetaGraph(
    SimpleDiGraph{Int}(),
    Symbol,
    Nothing,
    Float64,       # EdgeData: stores edge weight as Float64
    nothing,
    identity,      # weight_function: edge weight IS the stored Float64
    0.0,
)
store = load("annotated_network.nwk", my_graph)
graph = first(store.graphs).graph
graph[Symbol(1), Symbol(2)]   # → Float64 edge weight
```

If `AbstractTrees.jl` is also loaded, the same extension-owned tree-view type
supports rooted traversal:

```julia
using AbstractTrees

tree_view = LineagesIO.MetaGraphsNextTreeView(asset)

collect(AbstractTrees.PreOrderDFS(tree_view))
```

```@index
```

```@autodocs
Modules = [LineagesIO]
```
