---
date-created: 2026-04-27T00:00:00
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

Some examples below use provisional placeholder names such as
`MetaGraphsNextNodeHandle`, `PhyloNodeHandle`, `PhyloNetworksNodeHandle`, and
`MetaGraphsNextTreeView` to illustrate extension-owned wrapper or view shapes.
These placeholder names do not amend the controlled vocabulary and do not
ratify exported API names. Exact extension-owned names must be ratified before
implementation lands.

## How to use this annex

Tranche files and tasking files for community support should cite the relevant
user story numbers from this annex.

The examples below are intended to anchor:

- the first deliverable for simple Newick trees across all three extensions
- the role of `MetaGraphsNext.jl` as the reference-standard consumer
- the way authoritative LineagesIO tables remain available after materialization
- target-specific rejection behavior and compatibility boundaries

## User story 1: Extension activation for the MetaGraphsNext reference path

As a user who loads both LineagesIO and MetaGraphsNext in one Julia session, I
want the MetaGraphsNext extension to activate automatically and make the simple
Newick reference path available without introducing a hard dependency in core.

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext

store = load("primates.nwk", MetaGraphsNextNodeHandle)
asset = first(store.graphs)

asset.graph_rootnode isa MetaGraphsNextNodeHandle
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
using MetaGraphsNext

store = load("annotated_tree.nwk", MetaGraphsNextNodeHandle)
asset = first(store.graphs)
root_handle = asset.graph_rootnode

LineagesIO.node_property(asset.node_table, root_handle.nodekey, :bootstrap)
asset.edge_table
```

## User story 3: MetaGraphsNext can stage unrooted-tree support with a distinguished rootnode

As a user working with simple unrooted trees, I want the MetaGraphsNext path to
support a distinguished entry node without weakening the one-`rootnode`
contract of the core package.

```julia
using FileIO
using LineagesIO
using MetaGraphsNext

store = load(File{format"Newick"}("unrooted_primates.nwk"), MetaGraphsNextNodeHandle)
asset = first(store.graphs)

asset.graph_rootnode
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
using MetaGraphsNext

store = load("primates.nwk", MetaGraphsNextNodeHandle)
asset = first(store.graphs)

tree_view = MetaGraphsNextTreeView(asset.graph_rootnode, asset.node_table, asset.edge_table)

AbstractTrees.children(tree_view)
collect(AbstractTrees.PreOrderDFS(tree_view))
```

## User story 5: Phylo.jl rooted-tree materialization is available from the same core load

As a rooted-tree user in the Julia phylogenetics ecosystem, I want a supported
Phylo.jl materialization path for simple Newick rooted trees through the same
core package contract.

```julia
using FileIO: load
using LineagesIO
using Phylo

store = load("primates.nwk", PhyloNodeHandle)
asset = first(store.graphs)

asset.graph_rootnode isa PhyloNodeHandle
asset.node_table
asset.edge_table
```

## User story 6: Phylo.jl root binding can target a caller-owned rooted tree

As a user who already owns the tree container, I want the Phylo.jl extension to
support the supplied-root surface where upstream semantics make that clean and
verifiable.

```julia
using FileIO: load
using LineagesIO
using Phylo

phylo_root = PhyloRootHandle()
store = load("primates.nwk", phylo_root)
asset = first(store.graphs)

asset.graph_rootnode === phylo_root
```

## User story 7: PhyloNetworks gets an early simple-tree deliverable

As a PhyloNetworks user, I want an early deliverable that can materialize
simple Newick trees into a `HybridNetwork`-compatible path even before the full
rooted-network tranche is complete.

```julia
using FileIO: load
using LineagesIO
using PhyloNetworks

store = load("primates.nwk", PhyloNetworksNodeHandle)
asset = first(store.graphs)

asset.graph_rootnode isa PhyloNetworksNodeHandle
asset.node_table
asset.edge_table
```

## User story 8: PhyloNetworks can later consume rooted-network inputs with gamma

As a user loading reticulate inputs, I want the PhyloNetworks path to interpret
important retained fields such as `gamma` when the target package needs them,
without moving that semantic coercion into LineagesIO core.

```julia
using FileIO
using LineagesIO
using PhyloNetworks

store = load(File{format"LineageNetwork"}("hybrid_example.ln"), PhyloNetworksNodeHandle)
asset = first(store.graphs)

gamma_txt = LineagesIO.edge_property(asset.edge_table, 7, :gamma)
gamma = gamma_txt === nothing ? nothing : parse(Float64, gamma_txt)
```

## User story 9: The same source can materialize into different consumers

As a user comparing ecosystem targets, I want the same source text to load
through the same core parser and authoritative tables into different supported
consumer packages.

```julia
using FileIO: load

meta_store = load("primates.nwk", MetaGraphsNextNodeHandle)
phylo_store = load("primates.nwk", PhyloNodeHandle)
network_store = load("primates.nwk", PhyloNetworksNodeHandle)

first(meta_store.graphs).node_table
first(phylo_store.graphs).node_table
first(network_store.graphs).node_table
```

## User story 10: Unsupported structural cases fail specifically by target

As a user, I want target-specific rejection behavior rather than silent
structure loss when a package cannot represent the loaded source cleanly.

```julia
julia> load("reticulate_network.nwk", PhyloNodeHandle)
ERROR: The Phylo.jl extension supports the single-parent construction tier for this load surface and cannot materialize a multi-parent graph from this source.

julia> load("posterior.trees", some_existing_rootnode_handle)
ERROR: The supplied-root extension load surface is valid only for a source that yields exactly one graph.
```

## User story 11: Authoritative tables remain first-class after extension-based loads

As a user, I want extension-based materialization to remain a thin projection
layer over authoritative LineagesIO tables rather than a replacement storage
system.

```julia
using FileIO: load

store = load("annotated_tree.nwk", MetaGraphsNextNodeHandle)
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

store = load("annotated_tree.nwk", MetaGraphsNextNodeHandle)
asset = first(store.graphs)

tree_view = MetaGraphsNextTreeView(asset.graph_rootnode, asset.node_table, asset.edge_table)
bootstrap(node_handle) = begin
    txt = LineagesIO.node_property(asset.node_table, node_handle.nodekey, :bootstrap)
    txt === nothing ? nothing : parse(Float64, txt)
end

collect(AbstractTrees.Leaves(tree_view))
bootstrap(first(AbstractTrees.Leaves(tree_view)))
```
