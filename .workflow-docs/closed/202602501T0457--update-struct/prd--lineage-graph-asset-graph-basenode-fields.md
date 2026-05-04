# PRD: Replace `materialized` with Separate `graph` and `basenode` Fields on `LineageGraphAsset`

## Summary

Replace the single `materialized::MaterializedT` field on `LineageGraphAsset` with two
semantically distinct fields — `graph::GraphT` and `basenode::BasenodeT` — and update the
construction protocol, iterators, and accessors accordingly.

---

## Motivation

`LineageGraphAsset.materialized` currently holds different things depending on the load
surface:

| Load surface | Current `materialized` value |
|---|---|
| Tables-only | `nothing` |
| Native protocol (`add_child` / `bind_basenode!`) | the user's basenode object |
| MetaGraphsNext extension | a `MetaGraph{...}` container |
| PhyloNetworks extension | a `HybridNetwork` container |

This creates a semantic mismatch: for native-protocol loads, `materialized` is a basenode;
for extension loads, it is a graph container. The field name communicates neither
distinction. Callers cannot know what they hold without reading extension-specific
documentation.

Splitting into `graph` (always a library container or `nothing`) and `basenode` (always
a basenode or `nothing`) makes the contract explicit at the type level.

---

## Target State

### Semantic Contract

| Load surface | `asset.graph` | `asset.basenode` |
|---|---|---|
| Tables-only | `nothing` | `nothing` |
| Native protocol | `nothing` | user's basenode object |
| MetaGraphsNext extension | `MetaGraph{...}` | `Symbol(1)` |
| PhyloNetworks extension | `HybridNetwork` | `net.node[net.rooti]` |

### Destructuring Contract

`LineageGraphAsset` is iterable. After this change the stable public iteration order
is **`(graph, basenode, node_table, edge_table)`** — four elements. The existing
implementation yields three (`materialized, node_table, edge_table`); it must be
updated.

```julia
# Explicit destructuring
graph, basenode, node_table, edge_table = only(store.graphs)

# Loop destructuring
for (graph, basenode, node_table, edge_table) in store.graphs
    ...
end

# Partial — discard what you do not need
graph, _, node_table, _ = only(store.graphs)
_, basenode, node_table, _ = only(store.graphs)
```

---

## Required Changes

### 1. `src/views.jl`

#### 1a. `LineageGraphAsset` struct

Replace the existing definition. The struct gains one type parameter (`BasenodeT`) and
one field (`basenode`). `materialized` is removed.

**Current:**
```julia
struct LineageGraphAsset{
    MaterializedT,
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    index::Int
    source_idx::Int
    collection_idx::Int
    collection_graph_idx::Int
    collection_label::OptionalString
    graph_label::OptionalString
    node_table::NodeTableT
    edge_table::EdgeTableT
    materialized::MaterializedT
    source_path::OptionalString
end
```

**New:**
```julia
struct LineageGraphAsset{
    GraphT,
    BasenodeT,
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    index::Int
    source_idx::Int
    collection_idx::Int
    collection_graph_idx::Int
    collection_label::OptionalString
    graph_label::OptionalString
    node_table::NodeTableT
    edge_table::EdgeTableT
    graph::GraphT
    basenode::BasenodeT
    source_path::OptionalString
end
```

Field positions: `graph` is field 9, `basenode` is field 10, `source_path` is field 11.

#### 1b. `LineageGraphStore` struct and constructor

`LineageGraphStore` carries a type parameter derived from the asset type. It currently
has `MaterializedT`; replace with `GraphT` and `BasenodeT`.

**Current struct:**
```julia
struct LineageGraphStore{
    MaterializedT,
    SourceTableT <: SourceTable,
    CollectionTableT <: CollectionTable,
    GraphTableT <: GraphTable,
    GraphsT,
}
    ...
end
```

**New struct:**
```julia
struct LineageGraphStore{
    GraphT,
    BasenodeT,
    SourceTableT <: SourceTable,
    CollectionTableT <: CollectionTable,
    GraphTableT <: GraphTable,
    GraphsT,
}
    ...
end
```

**Current constructor body (relevant lines):**
```julia
graph_asset_type = eltype(GraphAssetVectorT)
materialized_type = fieldtype(graph_asset_type, 9)
graph_iterator_type = typeof(graphs)
return LineageGraphStore{materialized_type, SourceTableT, CollectionTableT, GraphTableT, graph_iterator_type}(...)
```

**New constructor body:**
```julia
graph_asset_type = eltype(GraphAssetVectorT)
graph_type = fieldtype(graph_asset_type, 9)      # GraphT is field 9
basenode_type = fieldtype(graph_asset_type, 10)  # BasenodeT is field 10
graph_iterator_type = typeof(graphs)
return LineageGraphStore{graph_type, basenode_type, SourceTableT, CollectionTableT, GraphTableT, graph_iterator_type}(...)
```

#### 1c. `Base.iterate` and `Base.length`

Update the existing implementation from 3-element to 4-element iteration.

**Current:**
```julia
Base.IteratorSize(::Type{<:LineageGraphAsset}) = Base.HasLength()
Base.length(::LineageGraphAsset)::Int = 3

function Base.iterate(asset::LineageGraphAsset, state::Int = 1)
    state == 1 && return asset.materialized, 2
    state == 2 && return asset.node_table, 3
    state == 3 && return asset.edge_table, 4
    return nothing
end
```

**New:**
```julia
Base.IteratorSize(::Type{<:LineageGraphAsset}) = Base.HasLength()
Base.length(::LineageGraphAsset)::Int = 4

# No return type annotation: the return type varies across states (four distinct
# Tuple element types plus Nothing). This is the established pattern for Base.iterate
# overrides in this codebase; see also GraphAssetIterator.iterate.
function Base.iterate(asset::LineageGraphAsset, state::Int = 1)
    state == 1 && return (asset.graph, 2)
    state == 2 && return (asset.basenode, 3)
    state == 3 && return (asset.node_table, 4)
    state == 4 && return (asset.edge_table, 5)
    return nothing
end
```

#### 1d. `basenode(asset)` function

The current implementation returns `asset.materialized` and is overridden per extension
to return the correct basenode. After this change, the correct value is stored in
`asset.basenode` at construction time. The base implementation simplifies; extension
overrides are deleted.

**Current (base method):**
```julia
function basenode(asset::LineageGraphAsset{MaterializedT})::MaterializedT where {MaterializedT}
    asset.materialized === nothing && throw(
        ArgumentError(
            "Cannot extract a `basenode` from a tables-only `LineageGraphAsset`. " *
            "Supply a construction target to `load` to obtain constructed `graph` and `basenode` values."
        )
    )
    return asset.materialized
end
```

**New (base method — no extension overrides needed):**
```julia
"""
    basenode(asset::LineageGraphAsset)

Return the basenode of the graph from a construction load.

The concrete type depends on the load surface:

- **Native protocol**: the user-supplied basenode object.
- **MetaGraphsNext extension**: the vertex label `Symbol(1)`.
- **PhyloNetworks extension**: the basenode `PhyloNetworks.Node` (`net.node[net.rooti]`).

Raises `ArgumentError` for tables-only assets where no construction target was supplied.
"""
function basenode(
    asset::LineageGraphAsset{<:Any, BasenodeT, <:NodeTable, <:EdgeTable},
)::BasenodeT where {BasenodeT}
    asset.basenode === nothing && throw(
        ArgumentError(
            "Cannot extract a `basenode` from a tables-only `LineageGraphAsset`. " *
            "Supply a construction target to `load` to obtain a materialized result."
        )
    )
    return asset.basenode
end
```

---

### 2. `src/construction.jl`

#### 2a. Two new protocol dispatch functions

Add these two functions as new exported protocol extension points. Their defaults
implement native-protocol behaviour (no graph container; the finalized handle IS
the basenode). Extensions override them for their concrete result types.

```julia
"""
    graph_from_finalized(result) -> Union{Nothing, GraphContainerT}

Return the graph container from a finalized construction result, or `nothing`
if the load surface does not produce a container (native protocol).

Extension authors must add a method for their container type if they override
`finalize_graph!` to return one.

# Default behaviour
Returns `nothing`. Applies to native-protocol loads where the user's basenode
IS the graph and no separate container exists.
"""
graph_from_finalized(::Any)::Nothing = nothing

"""
    basenode_from_finalized(result) -> BasenodeT

Return the basenode from a finalized construction result.

Extension authors must add a method for their container type if they override
`finalize_graph!` to return a container rather than a basenode.

# Default behaviour
Returns `result` unchanged. Applies to native-protocol loads where `finalize_graph!`
returns the basenode directly.
"""
basenode_from_finalized(result::T)::T where {T} = result
```

#### 2b. `materialize_graph_basenode`

The function currently returns the single value from `finalize_graph!`. Change it to
return a `(graph_val, basenode_val)` tuple using the two new dispatch functions.

Find the two `return finalize_graph!(basenode_handle)` statements (single-parent path
and multi-parent path) and replace both with:

```julia
finalized = finalize_graph!(basenode_handle)
return graph_from_finalized(finalized), basenode_from_finalized(finalized)
```

#### 2c. `materialize_graph`

Update to unpack the tuple from `materialize_graph_basenode` and pass both values to
the `LineageGraphAsset` constructor.

**Current:**
```julia
function materialize_graph(
    graph_asset::LineageGraphAsset{Nothing, NodeTableT, EdgeTableT},
    request::AbstractLoadRequest,
) where {NodeTableT <: NodeTable, EdgeTableT <: EdgeTable}
    materialized = materialize_graph_basenode(graph_asset, request)
    return LineageGraphAsset(
        graph_asset.index,
        graph_asset.source_idx,
        graph_asset.collection_idx,
        graph_asset.collection_graph_idx,
        graph_asset.collection_label,
        graph_asset.graph_label,
        graph_asset.node_table,
        graph_asset.edge_table,
        materialized,
        graph_asset.source_path,
    )
end
```

**New:**
```julia
function materialize_graph(
    graph_asset::LineageGraphAsset{Nothing, Nothing, NodeTableT, EdgeTableT},
    request::AbstractLoadRequest,
) where {NodeTableT <: NodeTable, EdgeTableT <: EdgeTable}
    graph_val, basenode_val = materialize_graph_basenode(graph_asset, request)
    return LineageGraphAsset(
        graph_asset.index,
        graph_asset.source_idx,
        graph_asset.collection_idx,
        graph_asset.collection_graph_idx,
        graph_asset.collection_label,
        graph_asset.graph_label,
        graph_asset.node_table,
        graph_asset.edge_table,
        graph_val,
        basenode_val,
        graph_asset.source_path,
    )
end
```

Note: the input constraint type changes from `LineageGraphAsset{Nothing, ...}` to
`LineageGraphAsset{Nothing, Nothing, ...}` because the tables-only asset now has
both `GraphT = Nothing` and `BasenodeT = Nothing`.

---

### 3. `src/newick_format.jl` (and any other format files with a tables-only constructor call)

Find the `LineageGraphAsset(...)` constructor call that creates the tables-only asset
(currently passes `nothing` as the 9th positional argument for `materialized`).
Insert an additional `nothing` for `basenode` so both new fields are `nothing`.

**Current (9th argument is `nothing` for `materialized`):**
```julia
return LineageGraphAsset(
    graph_index,
    1,
    1,
    graph_index,
    nothing,
    nothing,
    node_table,
    edge_table,
    nothing,       # materialized
    source_path,
)
```

**New (9th = `nothing` for `graph`, 10th = `nothing` for `basenode`):**
```julia
return LineageGraphAsset(
    graph_index,
    1,
    1,
    graph_index,
    nothing,
    nothing,
    node_table,
    edge_table,
    nothing,       # graph
    nothing,       # basenode
    source_path,
)
```

---

### 4. `src/LineagesIO.jl`

Add exports for the two new protocol functions:

```julia
export graph_from_finalized
export basenode_from_finalized
```

---

### 5. `ext/MetaGraphsNextIO.jl`

#### 5a. Add `graph_from_finalized` and `basenode_from_finalized` overrides

```julia
"""
    graph_from_finalized(graph::MetaGraph) -> MetaGraph

Return the `MetaGraph` container as the graph component of the finalized result.
"""
function LineagesIO.graph_from_finalized(graph::GraphT)::GraphT where {GraphT <: MetaGraph}
    return graph
end

"""
    basenode_from_finalized(::MetaGraph) -> Symbol

Return `Symbol(1)`, the vertex label of the basenode in any `MetaGraph` built by this
extension. The basenode is always assigned nodekey `1` during construction.
"""
LineagesIO.basenode_from_finalized(::MetaGraph)::Symbol = Symbol(StructureKeyType(1))
```

#### 5b. Delete the `LineagesIO.basenode` extension override

The following method is no longer needed and must be removed:

```julia
# DELETE this entire block:
function LineagesIO.basenode(
    ::LineageGraphAsset{GraphT, NodeTableT, EdgeTableT},
) where {
    GraphT <: MetaGraph,
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    return Symbol(StructureKeyType(1))
end
```

---

### 6. `ext/PhyloNetworksIO.jl`

#### 6a. Add `graph_from_finalized` and `basenode_from_finalized` overrides

```julia
"""
    graph_from_finalized(net::HybridNetwork) -> HybridNetwork

Return the `HybridNetwork` as the graph component of the finalized result.
"""
LineagesIO.graph_from_finalized(net::HybridNetwork)::HybridNetwork = net

"""
    basenode_from_finalized(net::HybridNetwork) -> PhyloNetworks.Node

Return the basenode of the finalized `HybridNetwork`.
"""
function LineagesIO.basenode_from_finalized(net::HybridNetwork)::PhyloNetworks.Node
    return net.node[net.rooti]
end
```

#### 6b. Delete the `LineagesIO.basenode` extension override

The following method is no longer needed and must be removed:

```julia
# DELETE this entire block:
function LineagesIO.basenode(asset::LineageGraphAsset{<:HybridNetwork, <:NodeTable, <:EdgeTable})
    net = asset.materialized
    return net.node[net.rooti]
end
```

---

### 7. Test files

#### 7a. Update the destructuring test

The existing destructuring test in `test/core/construction_protocol_single_parent.jl`
validates the 3-element iteration `(materialized, node_table, edge_table)`. Update it
to validate 4-element iteration `(graph, basenode, node_table, edge_table)`.

Required assertions (update existing; do not duplicate):

```julia
# Length
@test length(asset) == 4

# Explicit destructuring
graph, basenode, node_table, edge_table = asset
@test graph      === asset.graph
@test basenode   === asset.basenode
@test node_table === asset.node_table
@test edge_table === asset.edge_table

# For native-protocol assets: graph is nothing, basenode is the basenode object
@test graph === nothing
@test basenode isa FixtureNetworkNode  # or whatever the concrete native type is

# Loop destructuring
count = 0
for (g, bn, nt, et) in store.graphs
    @test g  === asset.graph
    @test bn === asset.basenode
    @test nt === asset.node_table
    @test et === asset.edge_table
    count += 1
end
@test count == length(store.graphs)

# Tables-only: both graph and basenode are nothing
tables_store = load(fixture_path)
tables_asset = only(tables_store.graphs)  # or first()
g, bn, nt, et = tables_asset
@test g  === nothing
@test bn === nothing
@test nt === tables_asset.node_table
@test et === tables_asset.edge_table
```

#### 7b. Update extension tests

In `test/extensions/metagraphsnext_activation.jl` (or equivalent):

```julia
asset = only(store.graphs)
graph, basenode_label, node_table, edge_table = asset
@test graph isa MetaGraph
@test basenode_label === Symbol(1)
```

In `test/extensions/phylonetworks_activation.jl` (or equivalent):

```julia
asset = only(store.graphs)
graph, basenode_node, node_table, edge_table = asset
@test graph isa HybridNetwork
@test basenode_node isa PhyloNetworks.Node
@test basenode_node === graph.node[graph.rooti]
```

#### 7c. Grep and update all remaining `asset.materialized` references

Search across all test files and source files:

```bash
grep -rn "\.materialized" test/ src/ ext/
```

For each hit, replace with `asset.graph` (when the caller used the value as a graph
container) or `asset.basenode` (when the caller used the value as a basenode), based
on context.

---

## Files Modified

| File | Nature of change |
|---|---|
| `src/views.jl` | New type params + fields on `LineageGraphAsset`; update `LineageGraphStore`; update `iterate` / `length`; simplify `basenode(asset)` |
| `src/construction.jl` | Add `graph_from_finalized` / `basenode_from_finalized` defaults; update `materialize_graph_basenode` to return tuple; update `materialize_graph` to unpack tuple and pass both fields |
| `src/LineagesIO.jl` | Export `graph_from_finalized`, `basenode_from_finalized` |
| `src/newick_format.jl` | Add `nothing` for new `basenode` field at tables-only constructor site |
| `ext/MetaGraphsNextIO.jl` | Add two new dispatch methods; delete `basenode` override |
| `ext/PhyloNetworksIO.jl` | Add two new dispatch methods; delete `basenode` override |
| `test/core/construction_protocol_single_parent.jl` | Update destructuring test for 4-element iteration |
| `test/extensions/metagraphsnext_activation.jl` | Add / update destructuring assertions |
| `test/extensions/phylonetworks_activation.jl` | Add / update destructuring assertions |
| Any file with `asset.materialized` | Replace per context (`graph` or `basenode`) |

---

## Verification

```bash
cd <repo-root>
julia --project -e 'using Pkg; Pkg.test()'
```

All pre-existing tests must pass. All new and updated tests must pass.
Additional manual check in REPL:

```julia
using LineagesIO
store = load("test/fixtures/rooted_network_with_annotations.nwk", FixtureNetworkNode)
graph, basenode, nt, et = only(store.graphs)
# graph    → nothing  (native protocol)
# basenode → the FixtureNetworkNode root
# nt       → NodeTable with :nodekey, :label, :posterior columns
# et       → EdgeTable with edge columns
```
