# PhyloNetworks workflow

LineagesIO's current PhyloNetworks soft release centers one public
`HybridNetwork` workflow over rooted-network-capable `format"Newick"` sources.
The extension stays a thin projection over authoritative LineagesIO tables and
protocol events, so every load keeps first-class `node_table` and `edge_table`
access attached to the returned `LineageGraphAsset`.

## Supported scope

The ratified soft-release contract includes:

- rooted-network native loads through `load(path, HybridNetwork)`
- explicit override through `load(File{format"Newick"}(...), HybridNetwork)`
- tree-compatible rooted loads through the same `HybridNetwork` surface
- secondary supplied-target binding through `load(path, HybridNetwork())`
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
using FileIO: load
using LineagesIO
using PhyloNetworks: HybridNetwork

store = load("hybrid_example.nwk", HybridNetwork)
asset = first(store.graphs)

graph = asset.materialized
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
When the source path is intentionally ambiguous, use FileIO's explicit
override wrapper:

```julia
using FileIO
using LineagesIO
using PhyloNetworks: HybridNetwork

store = load(File{format"Newick"}("primates.txt"), HybridNetwork)
asset = first(store.graphs)

graph = asset.materialized
asset.node_table
asset.edge_table
```

This is still a native `HybridNetwork` load, not a separate tree-only
materialization path.

See `examples/src/phylonetworks_mwe02.jl` for a runnable explicit-override,
tree-compatible rooted example.

## Supplied-target binding

If the caller already owns an empty `HybridNetwork()`, the extension also
supports supplied-target binding on one-graph sources:

```julia
using FileIO: load
using LineagesIO
using PhyloNetworks: HybridNetwork

target = HybridNetwork()
store = load("hybrid_example.nwk", target)
asset = first(store.graphs)

asset.materialized === target
```

The supplied target must be empty before loading. This path is secondary to
`load(path, HybridNetwork)`, which remains the primary public happy path for
the soft release.

## Current boundaries

The soft release is intentionally narrow and honest:

- rooted-network and tree-compatible rooted `HybridNetwork` loads are supported
- authoritative `node_table` and `edge_table` remain first-class after load
- no hard dependency on `PhyloNetworks.jl` is added to LineagesIO core
- unrooted networks, additional formats, and serialization remain out of scope
