# PhyloNetworks workflow

LineagesIO's current PhyloNetworks soft release centers one package-owned
`HybridNetwork` workflow over rooted-network-capable Newick sources through
`read_lineages(...)`. The extension stays a thin projection over authoritative
LineagesIO tables and protocol events, so every load keeps first-class
`node_table` and `edge_table` access attached to the returned
`LineageGraphAsset`. Retained `FileIO.load(...)` flows stay available as
compatibility-only wrappers.

## Supported scope

The ratified soft-release contract includes:

- rooted-network native loads through `read_lineages(path, HybridNetwork)`
- explicit override through
  `read_lineages(path, HybridNetwork; format = :newick)`
- tree-compatible rooted loads through the same `HybridNetwork` surface
- secondary supplied-target binding through
  `read_lineages(path, HybridNetwork())`
- authoritative `node_table` and `edge_table` retention after load

The current soft-release contract does not include:

- unrooted-network support
- additional format owners beyond current `format"Newick"` coverage
- serialization
- extension-private handle types in the public happy path

## Rooted-network happy path

Use the native `HybridNetwork` target directly for rooted-network-capable
Newick inputs:

```julia
using LineagesIO
using PhyloNetworks: HybridNetwork

store = read_lineages("hybrid_example.nwk", HybridNetwork)
asset = first(store.graphs)

graph = asset.graph
asset.node_table
asset.edge_table
```

After load, the result participates in ordinary PhyloNetworks workflow. For
example, the network can be written back to extended Newick with
`writenewick(graph)`, and authoritative table lookups stay directly usable:

```julia
using LineagesIO

LineagesIO.node_property(asset.node_table, 4, :posterior)
LineagesIO.edge_property(asset.edge_table, 3, :gamma)
```

See `examples/src/phylonetworks_mwe01.jl` for a runnable rooted-network
example.

## Explicit override and tree-compatible rooted loads

Tree-compatible rooted inputs use the same public `HybridNetwork` surface.
When the source path is intentionally ambiguous, use the package-owned
`format = :newick` override. A bare `read_lineages(path, HybridNetwork)` call
on an ambiguous `.txt` path is expected to fail fast and tell the caller to
resolve the format explicitly:

```julia
using LineagesIO
using PhyloNetworks: HybridNetwork

store = read_lineages("primates.txt", HybridNetwork; format = :newick)
asset = first(store.graphs)

graph = asset.graph
asset.node_table
asset.edge_table
```

This is still a native `HybridNetwork` load, not a separate tree-only
materialization path. The retained compatibility wrapper
`load(File{format"Newick"}("primates.txt"), HybridNetwork)` remains supported
when you need to stay on the `FileIO` host surface.

If a tree-compatible rooted source carries an empty leaf label, LineagesIO
preserves that exact authoritative label in `node_table`, while the native
`HybridNetwork` receives an extension-owned synthesized leaf name so the
result remains usable in ordinary downstream PhyloNetworks workflow. As a
result, round-tripped Newick text reflects the synthesized native leaf name,
not the empty authoritative label:

```julia
using Tables

Tables.getcolumn(asset.node_table, :label)
[node.name for node in graph.leaf]
```

See `examples/src/phylonetworks_mwe02.jl` for a runnable explicit-override,
tree-compatible rooted example.

## Supplied-target binding

If the caller already owns an empty `HybridNetwork()`, the extension also
supports supplied-target binding on one-graph sources:

```julia
using LineagesIO
using PhyloNetworks: HybridNetwork

target = HybridNetwork()
store = read_lineages("hybrid_example.nwk", target)
asset = first(store.graphs)

asset.graph === target
```

The supplied target must be empty before loading. This path is secondary to
`read_lineages(path, HybridNetwork)`, which remains the primary public happy
path for the soft release.

## Current boundaries

The soft release is intentionally narrow and honest:

- rooted-network and tree-compatible rooted `HybridNetwork` loads are supported
- authoritative `node_table` and `edge_table` remain first-class after load
- no hard dependency on `PhyloNetworks.jl` is added to LineagesIO core
- unrooted networks, additional formats, and serialization remain out of scope
