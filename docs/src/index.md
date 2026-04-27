```@meta
CurrentModule = LineagesIO
```

# LineagesIO

LineagesIO.jl provides FileIO-compatible loading of rooted lineage graph
sources into package-owned authoritative tables.

## Quick start

```julia
using FileIO: load
using LineagesIO

store = load("primates.nwk")
asset = first(store.graphs)

asset.graph_rootnode === nothing
asset.node_table
asset.edge_table
```

## Supported tranche 1 load surfaces

Phase 1 supports tables-only simple rooted Newick loads through:

- `load("tree.nwk")` for safe Newick extensions
- `load(File{format"Newick"}("tree.txt"))` for explicit override on ambiguous paths
- `load(Stream{format"Newick"}(io, "tree.txt"))` for already-open I/O

Every tranche 1 load returns a `LineageGraphStore` whose `graphs` field lazily
iterates `LineageGraphAsset` values with authoritative `node_table` and
`edge_table` objects. For the tables-only path, `graph_rootnode === nothing`.

```@index
```

```@autodocs
Modules = [LineagesIO]
```
