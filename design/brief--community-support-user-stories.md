---
date-created: 2026-04-27T00:00:00
date-revised: 2026-04-28T00:00:00
status: authoritative-annex
parent-brief: design/brief--community-support-objectives.md
---

# LineagesIO.jl — Community support user stories

## Authority

This document is the authoritative user-story annex to
`design/brief--community-support-objectives.md`.

It must be read alongside:

- `design/brief--community-support-objectives.md`
- `design/brief.md`
- `design/brief--user-stories.md` when trancheing crosses the core and extension boundary

This annex anchors extension-facing intent through numbered user stories and
Julia syntax examples.

If any example in this annex conflicts with either governing brief, the briefs
govern and this annex must be revised.

Example-only filenames, fixtures, and incidental values in this annex do not
ratify new format names, new target-package load surfaces, or new public
helper names by themselves.

## How to use this annex

Tranche files and tasking files for community support should cite the relevant
user story numbers from this annex.

The examples below are intended to anchor:

- the staged extension deliverables, with `MetaGraphsNext.jl` first and the
  `PhyloNetworks.jl` soft release centered on rooted-network-capable
  `format"Newick"`
- the role of `MetaGraphsNext.jl` as the reference-standard consumer
- the way authoritative LineagesIO tables remain available after materialization
- the requirement that public load surfaces stay on native target-package types
- target-specific rejection behavior and compatibility boundaries

## User story 1: Extension activation for the MetaGraphsNext reference path

As a user who loads both LineagesIO and MetaGraphsNext in one Julia session, I
want the MetaGraphsNext extension to activate automatically and make the simple
Newick reference path available without introducing a hard dependency in core.

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext: MetaGraph

store = load("primates.nwk", MetaGraph)
asset = first(store.graphs)

asset.materialized isa MetaGraph
asset.node_table
asset.edge_table
```

## User story 2: MetaGraphsNext is the earliest reference-standard deliverable

As a user who wants the earliest polished consumer integration, I want the
MetaGraphsNext path to be the first fully verified extension for simple Newick
trees and the reference model for later general graph integrations.

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext: MetaGraph

store = load("annotated_tree.nwk", MetaGraph)
asset = first(store.graphs)
graph = asset.materialized

graph
LineagesIO.node_property(asset.node_table, 1, :bootstrap)
asset.edge_table
```

## User story 3: MetaGraphsNext can stage unrooted-tree support with a distinguished basenode

As a user working with simple unrooted trees, I want the MetaGraphsNext path to
support a distinguished entry node without weakening the one-`basenode`
contract of the core package.

```julia
using FileIO
using LineagesIO
using MetaGraphsNext: MetaGraph

store = load(File{format"Newick"}("unrooted_primates.nwk"), MetaGraph)
asset = first(store.graphs)

asset.materialized
asset.node_table
asset.edge_table
```

## User story 4: AbstractTrees traversal works through a MetaGraphsNext wrapper

As a downstream consumer, I want to traverse a MetaGraphsNext materialization
through `AbstractTrees.jl` without requiring LineagesIO core to own
AbstractTrees semantics.

```julia
using FileIO: load
using AbstractTrees
using LineagesIO
using MetaGraphsNext: MetaGraph

store = load("primates.nwk", MetaGraph)
asset = first(store.graphs)

tree_view = LineagesIO.MetaGraphsNextTreeView(asset)

AbstractTrees.children(tree_view)
collect(AbstractTrees.PreOrderDFS(tree_view))
```

## User story 5: Tree-compatible rooted inputs share the same PhyloNetworks public load surface

As a user with ordinary rooted Newick inputs, I want them to load through the
same native `HybridNetwork` path as rooted-network inputs so the soft release
centers one production PhyloNetworks workflow rather than splitting tree and
network usage across different native consumer targets.

```julia
using FileIO: load
using LineagesIO
using PhyloNetworks: HybridNetwork

store = load("primates.nwk", HybridNetwork)
asset = first(store.graphs)

asset.materialized isa HybridNetwork
asset.node_table
asset.edge_table
```

## User story 6: Clients do not need extension-private handle types

As a user loading into ecosystem-native structures, I do not want to discover
or import extension-private handle types just to request a supported
materialization path.

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext: MetaGraph
using PhyloNetworks: HybridNetwork

meta_store = load("primates.nwk", MetaGraph)
network_store = load("hybrid_example.nwk", HybridNetwork)
```

## User story 7: PhyloNetworks soft release centers the rooted-network public path

As a PhyloNetworks user, I want the soft-release deliverable to target
rooted-network-capable `Newick` inputs directly so the native `HybridNetwork`
workflow is production-oriented rather than staged around a temporary
tree-first path.

```julia
using FileIO
using LineagesIO
using PhyloNetworks: HybridNetwork

store = load(File{format"Newick"}("hybrid_example.nwk"), HybridNetwork)
asset = first(store.graphs)

asset.materialized isa HybridNetwork
asset.node_table
asset.edge_table
```

## User story 8: PhyloNetworks interprets rooted-network Newick inputs with gamma

As a user loading reticulate inputs, I want the PhyloNetworks path to interpret
important retained fields such as `gamma` from rooted-network-capable
`Newick` sources when the target package needs them, without moving that
semantic coercion into LineagesIO core.

```julia
using FileIO
using LineagesIO
using PhyloNetworks: HybridNetwork

store = load(File{format"Newick"}("hybrid_example.nwk"), HybridNetwork)
asset = first(store.graphs)

gamma_txt = LineagesIO.edge_property(asset.edge_table, 7, :gamma)
gamma = gamma_txt === nothing ? nothing : parse(Float64, gamma_txt)
```

## User story 9: The same source can materialize into different consumers

As a user comparing ecosystem targets, I want the same source text to load
through the same core parser and authoritative tables into different currently
supported consumer packages.

```julia
using FileIO: load
using MetaGraphsNext: MetaGraph
using PhyloNetworks: HybridNetwork

meta_store = load("primates.nwk", MetaGraph)
network_store = load("primates.nwk", HybridNetwork)

first(meta_store.graphs).node_table
first(network_store.graphs).node_table
```

## User story 10: Unsupported structural or load-surface cases fail specifically

As a user, I want target-specific rejection behavior rather than silent
structure loss or leaky partial success when a target or load surface cannot
represent the requested source cleanly.

```julia
julia> load("posterior.trees", HybridNetwork())
ERROR: The supplied-target `HybridNetwork` load surface is valid only for a source that yields exactly one graph.
```

## User story 11: Authoritative tables remain first-class after extension-based loads

As a user, I want extension-based materialization to remain a thin projection
layer over authoritative LineagesIO tables rather than a replacement storage
system.

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext: MetaGraph

store = load("annotated_tree.nwk", MetaGraph)
asset = first(store.graphs)

asset.node_table
asset.edge_table
LineagesIO.node_property(asset.node_table, 4, :posterior)
LineagesIO.edge_property(asset.edge_table, 3, :bootstrap)
```

## User story 12: Package-specific wrappers can bridge the loaded graph onward

As a downstream user, I want target-specific wrappers and convenience accessors
to bridge loaded graphs into traversal, plotting, and analysis code without
requiring LineagesIO core to own those semantics.

```julia
using FileIO: load
using AbstractTrees
using LineagesIO
using MetaGraphsNext: MetaGraph

store = load("annotated_tree.nwk", MetaGraph)
asset = first(store.graphs)

tree_view = LineagesIO.MetaGraphsNextTreeView(asset)
bootstrap(nodekey) = begin
    txt = LineagesIO.node_property(asset.node_table, nodekey, :bootstrap)
    txt === nothing ? nothing : parse(Float64, txt)
end

collect(AbstractTrees.Leaves(tree_view))
bootstrap(1)
```
