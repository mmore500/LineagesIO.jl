# PRD: `LineageGraphAsset` Destructuring Support

## Summary

Add Julia iteration support to `LineageGraphAsset` so that instances can be
destructured into their three primary fields — `materialized`, `node_table`,
`edge_table` — via standard Julia assignment and `for`-loop patterns.

---

## Target Struct

`LineageGraphAsset` is defined in `src/views.jl`:

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
    node_table::NodeTableT       # field 7
    edge_table::EdgeTableT       # field 8
    materialized::MaterializedT  # field 9
    source_path::OptionalString
end
```

`LineageGraphAsset` objects are yielded by iterating `store.graphs`, where
`store` is a `LineageGraphStore` returned by `load`. Currently, `LineageGraphAsset`
has no `Base.iterate` implementation.

---

## Required Behaviour

### Destructuring via assignment

```julia
store = load(src, MyGraph)
asset = only(store.graphs)

graph, node_table, edge_table = asset
# graph       === asset.materialized
# node_table  === asset.node_table
# edge_table  === asset.edge_table
```

### Destructuring directly from a `for` loop

```julia
for (graph, node_table, edge_table) in store.graphs
    # graph, node_table, edge_table are bound per asset
end
```

This works because Julia's `for (a, b, c) in iter` pattern calls `Base.iterate`
on each element yielded by `iter`. Since `store.graphs` yields `LineageGraphAsset`
objects, once `LineageGraphAsset` is iterable, the pattern composes automatically.

### Partial destructuring

```julia
graph, node_table, _ = asset   # edge_table discarded
graph, _, _ = asset            # tables discarded
```

### Length

```julia
length(asset)  # → 3
```

### Tables-only assets (`materialized === nothing`)

When `MaterializedT == Nothing` (tables-only load — no construction target supplied),
destructuring still works:

```julia
store = load(src)              # tables-only
asset = only(store.graphs)
nothing_val, node_table, edge_table = asset
# nothing_val === nothing
```

---

## Implementation

Add the following to `src/views.jl`. Place it directly after the `basenode` function
(currently ending at line 208) and before the `has_property` function (currently at
line 210).

```julia
"""
    Base.iterate(asset::LineageGraphAsset[, state::Int])
    Base.length(::LineageGraphAsset)

Iteration support enabling destructuring of a `LineageGraphAsset` into its three
primary fields in declaration order: `(materialized, node_table, edge_table)`.

Supports explicit assignment:

    graph, node_table, edge_table = only(store.graphs)

And `for`-loop patterns:

    for (graph, node_table, edge_table) in store.graphs
        ...
    end

The full asset remains accessible when all fields are needed together:

    asset = only(store.graphs)
    do_something(asset.materialized, asset.node_table)
"""
Base.IteratorSize(::Type{<:LineageGraphAsset}) = Base.HasLength()
Base.length(::LineageGraphAsset) = 3

function Base.iterate(asset::LineageGraphAsset, state::Int = 1)
    state == 1 && return (asset.materialized, 2)
    state == 2 && return (asset.node_table, 3)
    state == 3 && return (asset.edge_table, nothing)
    return nothing
end
```

**Destructuring order:** `materialized` first (the primary constructed result),
then `node_table`, then `edge_table`. This matches the natural usage pattern
`graph, node_table, edge_table = ...`.

---

## Tests

Locate the test file most appropriate for `LineageGraphAsset` behaviour (likely
`test/core/` — confirm by grepping for existing `LineageGraphAsset` test coverage).
Add a new `@testset` block. It must use an existing fixture already present in
`test/fixtures/`.

The test block must cover:

### Explicit destructuring
```julia
store = load(fixture_path, FixtureNetworkNode)
asset = only(store.graphs)  # or first() if multi-graph fixture

graph, node_table, edge_table = asset
@test graph       === asset.materialized
@test node_table  === asset.node_table
@test edge_table  === asset.edge_table
```

### Length
```julia
@test length(asset) == 3
```

### Loop destructuring
```julia
count = 0
for (g, nt, et) in store.graphs
    @test g  === first(store.graphs).materialized
    @test nt === first(store.graphs).node_table
    @test et === first(store.graphs).edge_table
    count += 1
end
@test count == length(store.graphs)
```

### Tables-only asset (`materialized === nothing`)
```julia
tables_store = load(fixture_path)          # no construction target
tables_asset = only(tables_store.graphs)   # or first()

nothing_val, nt, et = tables_asset
@test nothing_val === nothing
@test nt === tables_asset.node_table
@test et === tables_asset.edge_table
```

---

## Files to Modify

| File | Change |
|---|---|
| `src/views.jl` | Add `Base.IteratorSize`, `Base.length`, `Base.iterate` for `LineageGraphAsset` (docstring + 5 lines) |
| One file under `test/core/` | Add `@testset` covering the four cases above |

No other files require modification. No changes to `construction.jl`, `src/LineagesIO.jl`,
extension files, or any existing callers.

---

## Verification

```bash
cd <repo-root>
julia --project -e 'using Pkg; Pkg.test()'
```

All pre-existing tests must pass. All new tests must pass. No regressions.
