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
[ALife phylogeny data standard](https://alife-data-standards.github.io/alife-data-standards/phylogeny.html).
The standard schema requires:

- `id` — a non-negative integer that uniquely identifies the entity (row).
- `ancestor_list` — a bracketed text list of ancestor `id`s, e.g. `[NONE]` for
  a basenode entry, `[3]` for an asexual descendant of `id=3`, or `[3,7]` for
  a multi-parent ("sexual") descendant of `id=3` and `id=7`.

Optional columns are retained as node annotations on the authoritative
`node_table`. Common conventional fields include `origin_time` and
`destruction_time`; arbitrary additional columns are also retained.

LineagesIO accepts two ancestry encodings interchangeably:

- `ancestor_list` with `[NONE]` (case-insensitive — `[none]` and `[None]`
  also work) or `[]` to mark a basenode entry; otherwise a bracketed
  comma-separated list of one or more ancestor `id`s.
- `ancestor_id` (single-parent shorthand) where a row is a basenode iff
  `ancestor_id == id` (a self-reference).

Self-references are filtered out of any `ancestor_list` value too, so
`ancestor_list = [self_id]` is also accepted as a basenode marker.

### Loading from CSV

Because `.csv` is registered as ambiguous (alongside other CSV-shaped
formats), bare `load("phylogeny.csv")` raises a FileIO ambiguity error.
Pass an explicit format wrapper to disambiguate:

```julia
using FileIO: File, Stream, load
using LineagesIO

store = load(File{LineagesIO.AlifeStandardFormat}("phylogeny.csv"))
asset = first(store.graphs)
graph, basenode, node_table, edge_table = asset
```

A multi-component source (a forest) yields one `LineageGraphAsset` per
connected component. Within each component the alife `id` values are
remapped to sequential `nodekey`s with the component basenode pinned at
`nodekey == 1`; the original `id` is retained as the node `label`.

The same construction surfaces used for Newick loads work for alife
sources:

```julia
load(File{LineagesIO.AlifeStandardFormat}("phylogeny.csv"), DemoNode)
load(File{LineagesIO.AlifeStandardFormat}("phylogeny.csv"); builder = fn)
```

### Loading from a Tables.jl object

For data already in memory (a `DataFrame`, a `NamedTuple` of vectors, an
Arrow table, etc.), use `load_alife_table` to skip CSV serialization
entirely:

```julia
using LineagesIO

table = (
    id = [0, 1, 2, 3],
    ancestor_list = [Int[], [0], [0], [1, 2]],
    origin_time   = [0.0, 1.0, 1.0, 2.0],
)
store = load_alife_table(table; source_path = "in-memory")
asset = first(store.graphs)
```

`load_alife_table` accepts cells of several types and coerces them
uniformly:

- `id` cells may be `Integer` or string-encoded integers.
- `ancestor_list` cells may be `Vector{Int}` (e.g. `[0, 1]`),
  `String` in the standard text form (`"[0,1]"` / `"[NONE]"`), or
  `missing`/`nothing` for basenode entries.
- `ancestor_id` cells may be `Integer` or string-encoded integers; a
  self-reference marks a basenode entry.
- All other columns are stringified and retained as node annotations
  (with `missing`/`nothing`/empty values stored as a missing annotation).

The same construction surfaces are available:

```julia
load_alife_table(table)                     # tables-only
load_alife_table(table, DemoNode)           # library-created basenode
load_alife_table(table, my_basenode)        # supplied-basenode binding
load_alife_table(table; builder = fn)       # explicit builder callback
```

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
