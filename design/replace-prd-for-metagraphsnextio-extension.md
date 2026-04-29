---
date-created: 2026-04-29T00:00:00
date-revised: 2026-04-29T00:00:00
status: authoritative-prd
---

# LineagesIO.jl — MetaGraphsNext Extension: Product Requirements Document

## 1. Purpose and scope

This document is the authoritative specification for the `MetaGraphsNextIO`
package extension of `LineagesIO.jl`. It defines every user-facing contract,
every internal dispatch decision, every error message, every valid load surface,
and every correctness constraint that the extension must satisfy.

An agent or engineer reading only this document and the project STYLE-*.md
governance documents should be able to implement the extension correctly from
scratch.

### 1.1 What this extension does

`MetaGraphsNextIO` is a Julia package extension that activates automatically
when both `LineagesIO` and `MetaGraphsNext` are loaded in the same session. It
materializes `LineageGraphAsset` sources into native `MetaGraph` objects using
the `LineagesIO` construction protocol. Authoritative `NodeTable` and `EdgeTable`
objects remain available on the `LineageGraphAsset` after materialization; the
`MetaGraph` is a projection layer, not a replacement storage system.

### 1.2 What this extension is not

- It is not a hard dependency. If `MetaGraphsNext` is not loaded, `LineagesIO`
  works unchanged.
- It does not own the authoritative tables. Those live in `LineagesIO` core.
- It does not expose any public types to users. Users interact with native
  `MetaGraph` objects and the existing `LineagesIO` public API (`node_property`,
  `edge_property`, `MetaGraphsNextTreeView`).
- It does not re-export `Graphs`. Users who need `weights(graph)` for
  algorithm-facing weight matrix access must import `Graphs` explicitly.

---

## 2. Upstream contract baseline

All facts below were verified from primary sources and must not be inferred or
assumed. Any deviation from these contracts must be explicit and approved.

| Fact | Source |
|------|--------|
| `MetaGraph` has 8 type params: `{Code, Graph, Label, VertexData, EdgeData, GraphData, WeightFunction, Weight}` | `metagraph.jl:27-36` |
| `Label` should not be an integer type — recommendation, not prohibition | `metagraph.jl:16` |
| Positional constructor is type-stable | `metagraph.jl:61-89` |
| Keyword constructor is type-unstable — documented warning in upstream source | `metagraph.jl:107-125` |
| `add_vertex!(g, label)` — no data arg when VertexData=Nothing | `graphs.jl:181-183` |
| `add_vertex!(g, label, data)` — data arg required when VertexData≠Nothing | `graphs.jl:163-179` |
| `add_edge!(g, l1, l2)` — no data arg when EdgeData=Nothing | `graphs.jl:215-219` |
| `add_edge!(g, l1, l2, data)` — data arg required when EdgeData≠Nothing | `graphs.jl:195-213` |
| `g[label]` → VertexData | `dict_utils.jl:16` |
| `g[l1, l2]` → EdgeData | `dict_utils.jl:24` |
| `weights(g)` → MetaWeights; `MetaWeights[c1,c2]` calls `weight_function(g[l1,l2])` for existing edges | `weights.jl:25`, `weights.jl:62-74` |
| For directed graphs, `arrange(g, l1, l2)` returns `(l1, l2)` unchanged | `directedness.jl:20-24` |
| `Graphs` is imported into `MetaGraphsNext` with `using Graphs` but is NOT re-exported | `MetaGraphsNext.jl:8-17` |

### 2.1 Approved divergence: `Symbol` as `Label` type

The upstream guideline (`metagraph.jl:16`) recommends against integer label
types. `Symbol` is not an integer type and fully satisfies the constraint.

`Symbol` is used as the `Label` type for all MetaGraph instances managed by
this extension. Rationale:

1. Satisfies the `metagraph.jl:16` non-integer requirement.
2. Symbol equality is pointer comparison (interned) — O(1) Dict lookups.
3. `Symbol(nodekey)` converts `StructureKeyType` integer keys to symbols with
   no wrapper struct: `Symbol(1)` → `:1` internally, `Symbol(2)` → `:2`, etc.
4. User access is idiomatic: `graph[Symbol(3)]` for vertex data,
   `graph[Symbol(1), Symbol(2)]` for edge data.
5. No wrapper struct is needed. A struct wrapper would impose an additional
   import, an `isless` method for undirected graphs, and user-visible type
   noise with no benefit.

**Critical note**: `:1`, `:2`, `:3` are NOT valid Julia symbol literal syntax.
Symbol literals (`:`-prefixed) require a valid identifier (letter or underscore
start). Integer-keyed nodes must be accessed as `graph[Symbol(1)]`, not
`graph[:1]`. All documentation and docstring examples must use `Symbol(n)` form.

### 2.2 Imports the extension module must not use

- **Do not use `using MetaGraphsNext`** (bare). Use `using MetaGraphsNext: ...`
  with an explicit import list (POLP).
- **Do not use the keyword MetaGraph constructor** — it is type-unstable
  (documented warning in upstream source at `metagraph.jl:107-125`).

---

## 3. Extension activation

The extension activates automatically when both packages are loaded in the
same session:

```julia
using LineagesIO
using MetaGraphsNext   # MetaGraphsNextIO activates here
```

No user action beyond the `using` statement is required. The extension must
not require users to import any internal module path. All public-facing API
is on native types: `MetaGraph`, `LineageGraphStore`, `LineageGraphAsset`,
`node_property`, `edge_property`, `MetaGraphsNextTreeView`.

`MetaGraphsNextAbstractTreesIO` is a second extension that activates when
`AbstractTrees` is also loaded. It depends on specific internal names from
`MetaGraphsNextIO` — see §9.

---

## 4. Load surfaces

### 4.1 Library-created path: `load(src, MetaGraph)`

The caller passes the `MetaGraph` type (or any parameterized subtype such as
`typeof(existing_graph)`).

**Behavior**: The extension calls `default_metagraph()` to construct an empty
directed MetaGraph, then fills it using the construction protocol. The caller
receives the completed MetaGraph as `asset.materialized`.

**Parameterized types**: Any `<:MetaGraph` type is accepted without error. The
type is used only for dispatch — the resulting graph is always
`default_metagraph()` regardless of specific parameterization.

**Graph type returned**: always `default_metagraph()` type:
`MetaGraph{Int, SimpleDiGraph{Int}, Symbol, Nothing, Union{Nothing,Float64}, Nothing, <WeightFn>, Float64}`

**VertexData**: `Nothing` — no vertex data is stored in the graph object.
Annotations are available via the authoritative `asset.node_table`.

**EdgeData**: `Union{Nothing, Float64}` — source edge weights are stored
natively. Access: `graph[Symbol(i), Symbol(j)]` returns `Union{Nothing,Float64}`.

**Weight matrix**: requires the caller to have `using Graphs: weights` in scope
(`Graphs` is not re-exported from `MetaGraphsNext`), then `weights(graph)[i,j]`.

**Multi-parent sources**: BLOCKED. See §11 for the exact error message.

### 4.2 Supplied-instance path: `load(src, my_graph)`

The caller passes an empty `MetaGraph` instance. The extension fills it in
place; the caller receives the same object as `asset.materialized`.

**Requirements on the supplied graph** (all validated before any construction):
1. Must be directed (underlying `Graph` type satisfies `is_directed`)
2. Must be empty (`nv(graph) == 0`)
3. Must use `Symbol` as the `Label` type parameter

Violation of any requirement throws `ArgumentError` before any nodes are added
(see §11 for exact messages).

**VertexData dispatch**:

| VertexData type | add_vertex! call | Verified against |
|-----------------|-----------------|-----------------|
| `Nothing` | `add_vertex!(graph, label)` | `graphs.jl:181-183` |
| `<: NodeRowRef` | `add_vertex!(graph, label, nodedata)` | `graphs.jl:163-179` |

**EdgeData dispatch**:

| EdgeData type | add_edge! call | Verified against |
|---------------|---------------|-----------------|
| `Nothing` | `add_edge!(graph, l1, l2)` | `graphs.jl:215-219` |
| `Union{Nothing,Float64}` | `add_edge!(graph, l1, l2, edgeweight)` | `graphs.jl:195-213` |
| `<: Real` (other than `Union{Nothing,Float64}`) | `add_edge!(graph, l1, l2, w)` where `w = edgeweight === nothing ? default_weight(graph) : edgeweight` | `graphs.jl:195-213` |
| `<: EdgeRowRef` | `add_edge!(graph, l1, l2, edgedata)` | `graphs.jl:195-213` |

**Multi-parent sources**: SUPPORTED for the supplied-instance path.

**One-graph restriction**: `load(src, my_graph)` is valid only if `src`
contains exactly one graph. Multi-graph sources throw from `LineagesIO` core
(not this extension) — see §11.

### 4.3 Default MetaGraph factory: `default_metagraph()`

Extension-private function. Used only by the library-created path.

```julia
function default_metagraph()::MetaGraph
    MetaGraph(
        SimpleDiGraph{Int}(),             # Code = Int
        Symbol,                           # Label type
        Nothing,                          # VertexData: no node data in graph
        Union{Nothing, Float64},          # EdgeData: source edge weight or nothing
        nothing,                          # GraphData
        ed -> ed === nothing ? 1.0 : ed,  # weight_function
        1.0,                              # default_weight
    )
end
```

The weight function: if EdgeData is `nothing` (no weight in source), return
`1.0`; otherwise return the stored `Float64` directly.

---

## 5. Extension-private types

These types are not part of the public API. Users never see or interact with
them directly.

### 5.1 `MetaGraphsNextBuildCursor{GraphT <: MetaGraph}`

```julia
struct MetaGraphsNextBuildCursor{GraphT <: MetaGraph}
    graph::GraphT
    nodekey::StructureKeyType
end
```

Carries the `MetaGraph` under construction and the `nodekey` of the most
recently added node. Required because the `LineagesIO` construction protocol
does not pass the parent's nodekey to `add_child` on the next call — the
cursor is the only mechanism for drawing the correct parent→child edge. Both
fields are concrete types at every instantiation.

### 5.2 `ConcreteMetaGraphsNextTreeView{GraphT, NodeTableT, EdgeTableT}`

```julia
struct ConcreteMetaGraphsNextTreeView{
    GraphT <: MetaGraph,
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    graph::GraphT
    nodekey::StructureKeyType
    node_table::NodeTableT
    edge_table::EdgeTableT
end
```

Returned by `LineagesIO.MetaGraphsNextTreeView`. Wraps a materialized MetaGraph
with its authoritative tables and a current node position, making it traversable
by `AbstractTrees.jl`.

**Field names must not change**: `MetaGraphsNextAbstractTreesIO` accesses the
fields `graph`, `nodekey`, `node_table`, and `edge_table` by exact name.

---

## 6. Label conversion helpers

These functions are accessed by name from `MetaGraphsNextAbstractTreesIO`.
Their names and signatures must be preserved exactly.

```julia
node_label(nodekey::StructureKeyType)::Symbol = Symbol(nodekey)
label_nodekey(label::Symbol)::StructureKeyType = StructureKeyType(parse(Int, String(label)))
```

`node_label` converts an integer nodekey to a `Symbol` label.
`label_nodekey` is the inverse — recovers the integer key from a `Symbol` label.

---

## 7. Construction protocol overrides

The extension implements the `LineagesIO` construction protocol by overriding
the following functions. All are dispatched through `LineagesIO`'s internal
build loop; none are called directly by users.

### 7.1 `emit_rootnode` (library-created path only)

**Why this override is required**: `construction.jl` contains a generic
`emit_rootnode` that checks `rootnode_handle isa NodeT` where `NodeT = MetaGraph`.
Since this extension's handles are `MetaGraphsNextBuildCursor` (not `MetaGraph`),
that check fails without this override.

```julia
function LineagesIO.emit_rootnode(
    ::LineagesIO.NodeTypeLoadRequest{<:MetaGraph},
    nodekey::StructureKeyType,
    ::AbstractString,
    nodedata::NodeRowRef,
)
    graph = default_metagraph()
    add_node_to_metagraph!(graph, nodekey, nodedata)
    return MetaGraphsNextBuildCursor{typeof(graph)}(graph, nodekey)
end
```

### 7.2 `bind_rootnode!` (supplied-instance path)

```julia
function LineagesIO.bind_rootnode!(
    graph::GraphT,
    nodekey::StructureKeyType,
    ::AbstractString;
    nodedata::NodeRowRef,
) where {GraphT <: MetaGraph}
    validate_empty_metagraph(graph)
    add_node_to_metagraph!(graph, nodekey, nodedata)
    return MetaGraphsNextBuildCursor{GraphT}(graph, nodekey)
end
```

### 7.3 `add_child` — single-parent

```julia
function LineagesIO.add_child(
    parent::MetaGraphsNextBuildCursor{GraphT},
    nodekey::StructureKeyType,
    ::AbstractString,
    ::StructureKeyType,
    edgeweight::EdgeWeightType;
    edgedata::EdgeRowRef,
    nodedata::NodeRowRef,
) where {GraphT <: MetaGraph}
    graph = parent.graph
    add_node_to_metagraph!(graph, nodekey, nodedata)
    add_edge_to_metagraph!(graph, parent.nodekey, nodekey, edgeweight, edgedata)
    return MetaGraphsNextBuildCursor{GraphT}(graph, nodekey)
end
```

### 7.4 `add_child` — multi-parent (supplied-instance path only)

```julia
function LineagesIO.add_child(
    parents::AbstractVector{MetaGraphsNextBuildCursor{GraphT}},
    nodekey::StructureKeyType,
    ::AbstractString,
    ::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType};
    edgedata::AbstractVector{<:EdgeRowRef},
    nodedata::NodeRowRef,
) where {GraphT <: MetaGraph}
    length(parents) == length(edgeweights) == length(edgedata) || throw(
        ArgumentError("Multi-parent construction requires equal-length " *
            "`parents`, `edgeweights`, and `edgedata` collections."),
    )
    graph = first(parents).graph
    add_node_to_metagraph!(graph, nodekey, nodedata)
    for (parent, edgeweight, edgeref) in zip(parents, edgeweights, edgedata)
        add_edge_to_metagraph!(graph, parent.nodekey, nodekey, edgeweight, edgeref)
    end
    return MetaGraphsNextBuildCursor{GraphT}(graph, nodekey)
end
```

### 7.5 `finalize_graph!`

```julia
function LineagesIO.finalize_graph!(cursor::MetaGraphsNextBuildCursor)
    return cursor.graph
end
```

Unwraps the completed `MetaGraph` from the build cursor and returns it as the
`materialized` field of the `LineageGraphAsset`.

### 7.6 `validate_extension_load_target` (three overloads)

**Library-created, type only** — accepts any `<:MetaGraph` parameterization:
```julia
function LineagesIO.validate_extension_load_target(::Type{<:MetaGraph})::Nothing
    return nothing
end
```

**Library-created, with asset** — blocks multi-parent sources:
```julia
function LineagesIO.validate_extension_load_target(
    ::Type{<:MetaGraph},
    graph_asset::LineageGraphAsset,
)::Nothing
    graph_requires_multi_parent(graph_asset) || return nothing
    throw(ArgumentError(...))   # see §11
end
```

**Supplied-instance** — validates the graph before filling:
```julia
function LineagesIO.validate_extension_load_target(
    graph::MetaGraph,
    ::LineageGraphAsset,
)::Nothing
    validate_empty_metagraph(graph)
    return nothing
end
```

---

## 8. Validation helpers

### 8.1 `validate_empty_metagraph(graph::MetaGraph)::Nothing`

Checks three conditions in order. Each failure throws `ArgumentError` with a
specific message — see §11. On success, returns `nothing`.

### 8.2 `metagraph_label_type(::MetaGraph{<:Any,<:Any,LabelT}) where {LabelT}`

Returns the `Label` type parameter of a MetaGraph instance. Used by
`validate_empty_metagraph` to check the Symbol requirement without calling
methods that could fail on a foreign label type.

---

## 9. AbstractTrees integration (`MetaGraphsNextAbstractTreesIO`)

A second extension activates when `AbstractTrees` is also loaded. It is
implemented in `ext/MetaGraphsNextAbstractTreesIO.jl` and depends on the
following names from `MetaGraphsNextIO` by exact string — they must not be
renamed or removed:

| Name | Accessed in `MetaGraphsNextAbstractTreesIO` |
|------|---------------------------------------------|
| `ConcreteMetaGraphsNextTreeView` | type returned by `MetaGraphsNextTreeView` |
| `node_label(nodekey)` | called at line 20 to convert nodekey to Symbol label |
| `label_nodekey(child_label)` | called at line 29 to recover nodekey from Symbol |
| `.graph` field | read at line 18 |
| `.nodekey` field | read at line 19 |
| `.node_table` field | read at line 30 |
| `.edge_table` field | read at line 31 |

`LineagesIO.MetaGraphsNextTreeView` is declared as an extensible function in
`src/LineagesIO.jl`. `MetaGraphsNextIO` extends it with two overloads:

```julia
# From a materialized asset
LineagesIO.MetaGraphsNextTreeView(
    asset::LineageGraphAsset{<:MetaGraph, <:NodeTable, <:EdgeTable}
)

# From raw components
LineagesIO.MetaGraphsNextTreeView(
    graph::MetaGraph, node_table::NodeTable, edge_table::EdgeTable
)
```

Both overloads:
- Require `nv(graph) > 0` (throw `ArgumentError` otherwise)
- Return `ConcreteMetaGraphsNextTreeView` with `nodekey = StructureKeyType(1)`
  (the root node is always nodekey 1 by construction-protocol convention)

---

## 10. Canonical usage examples

### Example 1 — Library-created path, simple tree

```julia
using FileIO: load
using LineagesIO
using MetaGraphsNext: MetaGraph

store = load("primates.nwk", MetaGraph)
asset = first(store.graphs)
graph = asset.materialized
# MetaGraph{Int, SimpleDiGraph{Int}, Symbol, Nothing, Union{Nothing,Float64}, ...}

# Direct EdgeData access — no extra import needed
graph[Symbol(1), Symbol(2)]      # → 2.0 or nothing

# Vertex data is Nothing in the library-created path
graph[Symbol(3)]                 # → nothing

# Annotations always available via authoritative table
LineagesIO.node_property(asset.node_table, 1, :label)   # → "Root"
LineagesIO.edge_property(asset.edge_table, 1, :edgeweight)  # → 2.0

# Weight matrix for Graphs.jl algorithm integration (separate import required)
# using Graphs: weights
# weights(graph)[1, 2]   # → Float64 via weight_function(EdgeData)
```

### Example 2 — Parameterized type accepted on library-created path

```julia
store1 = load("primates.nwk", MetaGraph)
existing_graph = first(store1.graphs).materialized

store2 = load("primates.nwk", typeof(existing_graph))
# Succeeds. The specific type parameterization is used for dispatch only.
# The resulting graph is always default_metagraph() type.
```

### Example 3 — Supplied-instance with `Float64` EdgeData

```julia
using MetaGraphsNext: MetaGraph
using MetaGraphsNext.Graphs: SimpleDiGraph

my_graph = MetaGraph(
    SimpleDiGraph{Int}(),
    Symbol,
    Nothing,
    Float64,
    nothing,
    identity,      # weight_function: the Float64 IS the weight
    0.0,           # default when source has no weight for an edge
)
store = load("primates.nwk", my_graph)
graph = first(store.graphs).materialized

graph[Symbol(1), Symbol(2)]   # → 2.0::Float64 (edge weight stored directly)
```

### Example 4 — Supplied-instance with `NodeRowRef`/`EdgeRowRef`

```julia
my_graph = MetaGraph(
    SimpleDiGraph{Int}(),
    Symbol,
    LineagesIO.NodeRowRef,
    LineagesIO.EdgeRowRef,
    nothing,
    ed -> begin
        w = LineagesIO.edge_property(ed, :edgeweight)
        w === nothing ? 1.0 : w
    end,
    1.0,
)
store = load("annotated.nwk", my_graph)
graph = first(store.graphs).materialized

LineagesIO.node_property(graph[Symbol(1)], :label)          # → "Root"
LineagesIO.edge_property(graph[Symbol(1), Symbol(2)], :edgeweight)  # → 2.0
```

### Example 5 — Multi-parent network via supplied-instance

```julia
my_graph = MetaGraph(
    SimpleDiGraph{Int}(),
    Symbol, Nothing, Nothing,
    nothing, ed -> 1.0, 1.0,
)
store = load("network.nwk", my_graph)
graph = first(store.graphs).materialized
# nv(graph) and ne(graph) reflect the full reticulate structure
```

### Example 6 — AbstractTrees traversal

```julia
using AbstractTrees
using MetaGraphsNext: MetaGraph

store = load("primates.nwk", MetaGraph)
asset = first(store.graphs)

tree_view = LineagesIO.MetaGraphsNextTreeView(asset)
collect(AbstractTrees.PreOrderDFS(tree_view))
```

---

## 11. Error contracts

All errors are `ArgumentError`. Each message is tested by substring match.

| Condition | Error message substring | Thrown by |
|-----------|------------------------|-----------|
| Multi-parent source on library-created path | `"multi-parent"` | this extension |
| Supplied graph is not directed | `"must be directed"` | `validate_empty_metagraph` |
| Supplied graph is not empty | `"must be empty"` | `validate_empty_metagraph` |
| Supplied graph has wrong Label type | `"must use \`Symbol\`"` | `validate_empty_metagraph` |
| Multi-graph source on supplied-instance path | `"exactly one graph"` | `LineagesIO` core |
| `MetaGraphsNextTreeView` on empty graph | (core error) | `MetaGraphsNextTreeView` |
| Equal-length invariant in multi-parent `add_child` | `"equal-length"` | `add_child` multi-parent overload |

Full messages:

**Multi-parent on library-created path**:
```
"The MetaGraphsNext extension does not support the multi-parent construction
tier for `load(src, MetaGraph)`. Construct an empty `MetaGraph` with `Symbol`
labels and call `load(src, my_graph)` instead, which supports both
single-parent and multi-parent sources."
```

**Not directed**:
```
"A supplied `MetaGraph` must be directed. Use `SimpleDiGraph` as the
underlying graph type."
```

**Not empty**:
```
"A supplied `MetaGraph` must be empty before loading into it."
```

**Wrong Label type**:
```
"A supplied `MetaGraph` must use `Symbol` as its `Label` type. Construct it
with `Symbol` as the second positional argument, e.g.:
`MetaGraph(SimpleDiGraph{Int}(), Symbol, VertexData, EdgeData, ...)`."
```

---

## 12. STYLE compliance

All implementation must comply with the project STYLE-*.md documents. Key rules:

| Rule | Application |
|------|-------------|
| `using Package: name` not bare `using Package` (POLP) | All imports in the extension module |
| Return type annotation on every function and method | `::Nothing`, `::Symbol`, `::StructureKeyType`, etc. |
| `!` suffix only on mutating functions | `add_node_to_metagraph!`, `add_edge_to_metagraph!`, `bind_rootnode!` mutate; `validate_empty_metagraph` validates and does not mutate |
| Anonymous type params for unused args | `::AbstractString`, `::StructureKeyType`, `::EdgeRowRef`, `::EdgeWeightType` where args are intentionally ignored |
| Struct fields concrete or parameterized at instantiation | Both fields of `MetaGraphsNextBuildCursor{GraphT}` are concrete at instantiation |
| No proscribed vocabulary | `node` not `vertex`; `edgeweight` not `edge_weight`; `rootnode`, `src`, `dst` for edge endpoints |
| Getters named for concept, no `get_` prefix | `default_metagraph`, `node_label`, `label_nodekey` |
| No speculative dispatch variants | Only the four EdgeData variants (Nothing, Union{Nothing,Float64}, <:Real, <:EdgeRowRef) that have concrete protocol-facing use cases |

---

## 13. Import requirements in documentation

`Graphs` is NOT re-exported from `MetaGraphsNext`. Documentation must follow
one of these correct patterns for edge weight access. No example may use
`Graphs.weights(graph)` without first importing `Graphs`.

```julia
# Option A: Direct EdgeData access — no extra import needed (preferred for MWEs)
graph[Symbol(1), Symbol(2)]        # → Union{Nothing,Float64}

# Option B: Weight matrix for Graphs.jl algorithm integration
using Graphs: weights
weights(graph)[1, 2]               # → Float64 via weight_function

# Option C: Qualified path (verbose, avoids separate import)
MetaGraphsNext.Graphs.weights(graph)[1, 2]
```

Symbol literal syntax note: `:1`, `:2`, `:3` are NOT valid Julia symbol
literals — identifiers cannot start with digits. All examples must use
`Symbol(n)` for integer-keyed node access.

---

## 14. Testing requirements

Tests live in `test/extensions/metagraphsnext_*.jl` and are included from
`test/runtests.jl`. Each test uses `@testset` with a descriptive name.

### Required test coverage

| Scenario | File |
|----------|------|
| Extension activation sequence; extension is `nothing` before `using MetaGraphsNext`, non-`nothing` after | `metagraphsnext_activation.jl` |
| Parameterized MetaGraph type accepted on library-created path | `metagraphsnext_activation.jl` |
| Library-created path: nv, ne, Symbol label round-trip for all nodes | `metagraphsnext_simple_newick.jl` |
| Library-created path: correct child nodekeys from `outneighbors` | `metagraphsnext_simple_newick.jl` |
| Library-created path: source edge weights in EdgeData | `metagraphsnext_simple_newick.jl` |
| Library-created path: absent edge weight gives default weight | `metagraphsnext_simple_newick.jl` |
| Authoritative tables preserved; node and edge properties accessible | `metagraphsnext_tables_after_load.jl` |
| Supplied-instance, Nothing/Nothing: materialized === supplied graph | `metagraphsnext_supplied_root.jl` |
| Supplied-instance, Float64 EdgeData: `graph[Symbol(i), Symbol(j)]` returns Float64 | `metagraphsnext_supplied_root.jl` |
| Supplied-instance, NodeRowRef/EdgeRowRef: `node_property`/`edge_property` on graph slot | `metagraphsnext_supplied_root.jl` |
| Validation: non-directed graph rejected | `metagraphsnext_supplied_root.jl` |
| Validation: non-empty graph rejected | `metagraphsnext_supplied_root.jl` |
| Validation: wrong Label type rejected | `metagraphsnext_supplied_root.jl` |
| Multi-parent source rejected on library-created path | `metagraphsnext_network_rejection.jl` |
| Multi-parent source accepted on supplied-instance path; correct nv and ne | `metagraphsnext_network_rejection.jl` |
| AbstractTrees: `children` count, `PreOrderDFS` order, `NodeType`, `ChildIndexing` | `metagraphsnext_abstracttrees.jl` |

### Required test helper

```julia
function metagraph_child_nodekeys(graph, nodekey::Integer)
    nodecode = MetaGraphsNext.code_for(graph, Symbol(nodekey))
    return [
        parse(Int, String(MetaGraphsNext.label_for(graph, child_code)))
        for child_code in MetaGraphsNext.Graphs.outneighbors(graph, nodecode)
    ]
end
```

---

## 15. File inventory

| File | Role |
|------|------|
| `ext/MetaGraphsNextIO.jl` | Extension implementation (sole source of truth) |
| `ext/MetaGraphsNextAbstractTreesIO.jl` | AbstractTrees integration; reads names from `MetaGraphsNextIO` |
| `test/extensions/metagraphsnext_activation.jl` | Extension load sequence and parameterized-type acceptance |
| `test/extensions/metagraphsnext_simple_newick.jl` | Library-created path correctness and edge weight storage |
| `test/extensions/metagraphsnext_tables_after_load.jl` | Authoritative table preservation |
| `test/extensions/metagraphsnext_supplied_root.jl` | Supplied-instance: all EdgeData/VertexData dispatch variants |
| `test/extensions/metagraphsnext_abstracttrees.jl` | AbstractTrees traversal |
| `test/extensions/metagraphsnext_network_rejection.jl` | Multi-parent library rejection and supplied-instance acceptance |
| `README.md` | Public documentation (MetaGraphsNext section) |
| `docs/src/index.md` | Documenter.jl source (MetaGraphsNext section) |

---

## 16. Success criteria

The extension is complete and correct when all of the following hold:

1. `load("tree.nwk", MetaGraph)` succeeds; `asset.materialized isa MetaGraph`.
2. `graph[Symbol(1), Symbol(2)]` returns the source edge weight as `Union{Nothing,Float64}`.
3. `graph[Symbol(3)]` returns `nothing` (VertexData=Nothing on library-created path).
4. `load("tree.nwk", typeof(existing_meta_graph))` succeeds (parameterized type accepted).
5. `load("tree.nwk", float64_graph)` with `EdgeData=Float64` gives `graph[Symbol(1),Symbol(2)] isa Float64`.
6. `load("tree.nwk", rowref_graph)` with `EdgeData=EdgeRowRef` gives `node_property(graph[Symbol(1)], :label) == "Root"`.
7. `load("network.nwk", MetaGraph)` throws `ArgumentError` with `"multi-parent"` in message.
8. `load("network.nwk", symbol_graph)` with supplied `Symbol`-labelled MetaGraph succeeds with correct nv and ne.
9. `load("tree.nwk", non_empty_graph)` throws `ArgumentError` with `"must be empty"` in message.
10. `load("tree.nwk", string_label_graph)` throws `ArgumentError` with `"must use \`Symbol\`"` in message.
11. `MetaGraphsNextTreeView(asset)` followed by `AbstractTrees.PreOrderDFS(tree_view)` returns nodes in pre-order.
12. All tests in `test/extensions/metagraphsnext_*.jl` pass.
13. No example in README, `docs/`, or docstrings uses `Graphs.weights` without first importing `Graphs`.
14. No example uses `:1`, `:2`, `:3` or any digit-prefixed symbol literal.
