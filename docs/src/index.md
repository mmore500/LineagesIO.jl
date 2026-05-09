```@meta
CurrentModule = LineagesIO
```

# LineagesIO

LineagesIO.jl provides a package-owned public read surface,
`LineagesIO.read_lineages(...)`, for rooted lineage graph sources. That
surface owns the authoritative-table-first load contract. Retained
`FileIO.load(...)` entry points stay available as compatibility wrappers, and
`load_alife_table(...)` stays available as the in-memory Tables.jl convenience
wrapper.

## Quick start

Tables-only loads preserve authoritative structure and retained annotations
without forcing graph materialization:

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

## Supported load surfaces

Phase 1 supports rooted-tree and rooted-network-capable Newick loads through:

- `read_lineages("tree.nwk")` for safe Newick extensions
- `read_lineages("tree.txt"; format = :newick)` for explicit package-owned
  override on ambiguous `.txt` paths
- `read_lineages(io; source_path = "tree.nwk")` or
  `read_lineages(io; format = :newick)` for already-open I/O
- `read_lineages("tree.nwk", NodeT)` for library-created-basenode construction
- `read_lineages("tree.nwk", basenode)` for supplied-basenode binding on
  one-graph sources when `construction_handle_type(basenode)` is defined
- `read_lineages("tree.nwk", BuilderDescriptor(builder, HandleT[, ParentCollectionT]))`
  for the first-class typed builder surface
- the optional `PhyloNetworks.jl` extension path for rooted-network and
  tree-compatible rooted `HybridNetwork` materialization
- secondary supplied-target `HybridNetwork()` binding on one-graph sources
- the optional `MetaGraphsNext.jl` extension path for MetaGraph materialization
- `read_lineages("phylogeny.csv")` for alife data standard CSV sources
  (see [Alife data standard](@ref))
- `load_alife_table(table)` for in-memory Tables.jl-compatible alife inputs
- retained `FileIO.load(...)` compatibility wrappers, including
  `File{format"..."}`

Every load returns a `LineageGraphStore` whose `graphs` field lazily
iterates `LineageGraphAsset` values with authoritative `node_table` and
`edge_table` objects. Each asset destructures in the stable public order
`(graph, basenode, node_table, edge_table)`. For the tables-only path, the
destructured `graph` and `basenode` values are both `nothing`.

Construction loads reuse the same authoritative tables and expose retained
annotation values through `NodeRowRef`, `EdgeRowRef`, `node_property`, and
`edge_property`:

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
LineagesIO.basenode(asset) === basenode
```

For typed builder-driven construction, use `BuilderDescriptor`:

```julia
store = read_lineages(
    "annotated_tree.nwk",
    BuilderDescriptor(my_builder, DemoNode),
)
```

The older `load(...; builder = fn)` surface remains supported as a
compatibility wrapper only.

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

The package-owned first-class surface treats `.csv` as alife input directly:

```julia
using LineagesIO

store = read_lineages("phylogeny.csv")
asset = first(store.graphs)
```

If you already rely on `FileIO`, the retained compatibility wrapper
`load(File{LineagesIO.AlifeStandardFormat}("phylogeny.csv"))` continues to
work.

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
(`read_lineages(src, NodeT)`, `read_lineages(src, basenode)`,
`read_lineages(src, BuilderDescriptor(...))`). The raw `builder = fn`
compatibility wrapper remains on `load(...)` and `load_alife_table(...)`.

## PhyloNetworks extension

The current PhyloNetworks soft-release workflow is documented on the
[PhyloNetworks workflow](phylonetworks.md) page. That workflow covers:

- rooted-network native loads through `read_lineages(path, HybridNetwork)`
- explicit overrides through
  `read_lineages(path, HybridNetwork; format = :newick)`
- tree-compatible rooted loads through the same public surface
- authoritative `node_table` and `edge_table` retention after load
- secondary supplied-target binding for an empty `HybridNetwork()` on one-graph
  sources

Retained `FileIO.load(...)` flows remain available as compatibility-only
wrappers.

## MetaGraphsNext extension

Loading `MetaGraphsNext` activates the LineagesIO package extension for
MetaGraph materialization. Nodes are labelled with `Symbol` keys so that
standard MetaGraph access works without wrapper types: `graph[Symbol(3)]` for
vertex data, `graph[Symbol(1), Symbol(2)]` for edge data. (Symbol literals
like `:foo` require an identifier name; integer-keyed nodes need `Symbol(n)`.)
Treat the library-created path (`read_lineages(src, MetaGraph)`) as the
tree-only request token. It always produces a directed MetaGraph with
`Nothing` vertex data and `Union{Nothing, Float64}` edge data, making source
edge weights immediately accessible. Arbitrary concrete `Type{<:MetaGraph}`
requests and hand-written partial `MetaGraph{...}` type literals are not a
supported library-created customization path. The library-created path
supports only single-parent (tree) sources; use the caller-supplied empty
MetaGraph path for multi-parent (network) sources or alternate metadata
parameterizations.

```julia
using LineagesIO
using MetaGraphsNext

store = read_lineages("annotated_tree.nwk", MetaGraph)
asset = first(store.graphs)

# MetaGraph{Int, SimpleDiGraph{Int}, Symbol, Nothing, Union{Nothing,Float64}, ...}
graph = asset.graph
graph[Symbol(1), Symbol(2)]   # source edge weight (Union{Nothing,Float64})
graph[Symbol(3)]              # vertex data (nothing — VertexData=Nothing)
asset.node_table
asset.edge_table
```

Supported caller-supplied custom data is constructor-based on user-owned
types. Implement `VertexData(::LineagesIO.NodeRowRef)` to materialize vertex
data from authoritative node rows, and implement
`EdgeData(::LineagesIO.EdgeWeightType, ::LineagesIO.EdgeRowRef)` to
materialize edge data from the source edge weight plus the authoritative edge
row. To load multi-parent sources or to customise `VertexData`/`EdgeData`
types, pass an empty MetaGraph instance with `Symbol` labels:

```julia
using MetaGraphsNext: MetaGraph
using MetaGraphsNext.Graphs: SimpleDiGraph

my_graph = MetaGraph(
    SimpleDiGraph{Int}(),
    Symbol,
    Nothing,
    Float64,       # Supported built-in EdgeData shape for direct weight storage
    nothing,
    identity,      # weight_function: edge weight IS the stored Float64
    0.0,
)
store = read_lineages("annotated_network.nwk", my_graph)
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
