## Global audit finding 1 fix

Narrow the library-created path to exactly the one concrete type that
`default_metagraph()` produces — `MetaGraph{SimpleDiGraph{Int}, Symbol, Nothing,
Union{Nothing,Float64}}` — and reject every other concrete `MetaGraph` subtype at
`validate_extension_load_target` with a clear `ArgumentError` that names the
supplied type and directs the caller to the supplied-instance path. The two paths
become coherent: library creates it means you get the default, you supply it means
you control the type. No factory, no protocol, no core surgery.

**Dependency:** this redirect is only honest after finding 2 is fixed. The
supplied-instance path must correctly handle custom node and edge data before
callers are directed there.

**Required verification artifact:** `read_lineages(tree_path,
typeof(weighted_metagraph_target()))` must throw an `ArgumentError` naming the
unsupported type and directing the caller to the supplied-instance path. It must
not silently return a graph of the wrong type.


## Global audit finding 2 fix — constructor dispatch

The existing `add_node_to_metagraph!` and `add_edge_to_metagraph!` methods are
specialized on specific MetaGraph type-parameter shapes. The fix adds a generic
fallback for each that captures the node-data or edge-data type parameter and
calls the user's constructor directly. The built-in shapes remain as specific
dispatch arms; the generic fallback handles all user-defined types.

**Node data — three methods in dispatch order:**

```julia
# 1. Specific: no node data stored.
function add_node_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, Nothing},
    nodekey::StructureKeyType,
    ::NodeRowRef,
)::Nothing
    add_vertex!(graph, node_label(nodekey)) || throw(...)
    return nothing
end

# 2. Specific: NodeRowRef passthrough.
function add_node_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, <:NodeRowRef},
    nodekey::StructureKeyType,
    nodedata::NodeRowRef,
)::Nothing
    add_vertex!(graph, node_label(nodekey), nodedata) || throw(...)
    return nothing
end

# 3. Generic fallback for user-defined node data types.
#    NodeDataT captures MetaGraph's fourth type parameter.
#    Users implement NodeDataT(::NodeRowRef) on their own type.
function add_node_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, NodeDataT},
    nodekey::StructureKeyType,
    nodedata::NodeRowRef,
)::Nothing where {NodeDataT}
    add_vertex!(graph, node_label(nodekey), NodeDataT(nodedata)) || throw(...)
    return nothing
end
```

Methods 1 and 2 are more specific than 3 and win dispatch for `Nothing` and
`<:NodeRowRef`. Method 3 must not be collapsed into 1 or 2; all three are
required.

**Edge data — five methods in dispatch order:**

The existing four specialisations (`Nothing`, `Union{Nothing,Float64}`, `<:Real`,
`<:EdgeRowRef`) are retained unchanged. A fifth generic fallback is added:

```julia
# 5. Generic fallback for user-defined edge data types.
#    EdgeDataT captures MetaGraph's fifth type parameter.
#    Users implement EdgeDataT(::EdgeWeightType, ::EdgeRowRef) on their own type.
function add_edge_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, <:Any, EdgeDataT},
    src_nodekey::StructureKeyType,
    dst_nodekey::StructureKeyType,
    edgeweight::EdgeWeightType,
    edgedata::EdgeRowRef,
)::Nothing where {EdgeDataT}
    add_edge!(
        graph,
        node_label(src_nodekey),
        node_label(dst_nodekey),
        EdgeDataT(edgeweight, edgedata),
    ) || throw(...)
    return nothing
end
```

**User extension:** users implement constructors on their own types — no
protocol function name to look up, no LineagesIO namespace to import:

```julia
struct MyNode
    name::String
end
MyNode(nodedata::NodeRowRef) = MyNode(Tables.getcolumn(nodedata, :label))

struct MyEdge
    weight::Float64
    annotation::String
end
MyEdge(weight::EdgeWeightType, edgedata::EdgeRowRef) =
    MyEdge(something(weight, 1.0), Tables.getcolumn(edgedata, :annotation))
```

**Required verification artifacts:**

- `read_lineages(tree_path, MetaGraph(SimpleDiGraph{Int}(), Symbol, MyNode,
  Nothing, ...))` succeeds and every node in the result carries a `MyNode`
  value, given the constructor above. This proves the generic fallback fires
  and produces the correct type.
- The same call without `MyNode(::NodeRowRef)` defined produces a `MethodError`
  on `MyNode(::NodeRowRef)` — not inside `add_node_to_metagraph!` — confirming
  the error originates at the documented extension point.
- The existing built-in shapes (`Nothing`, `NodeRowRef`, `Union{Nothing,Float64}`,
  `<:Real`, `<:EdgeRowRef`) all continue to pass their current tests, confirming
  the specific dispatch arms were not disturbed.


## Global audit finding 3 fix

Add one guard in the `BuilderDescriptor` constructor at `src/read_lineages.jl:27-35`,
mirroring the existing `isconcretetype(ParentCollectionT)` check:

```julia
isconcretetype(HandleT) || throw(
    ArgumentError(
        "The package-owned `BuilderDescriptor` surface requires a concrete `HandleT`, but received `$(HandleT)`.",
    ),
)
```

**Required verification artifact:** `BuilderDescriptor(builder, Any)` throws an
`ArgumentError`; `BuilderDescriptor(builder, ConcreteHandleType)` continues to
succeed.
