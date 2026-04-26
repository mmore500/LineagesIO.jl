export add_child
export finalize_graph!

function add_child end

"""
    add_child(...)

Extend this protocol function to materialize parsed graph nodes into a concrete
node handle type. LineagesIO calls `add_child` in pre-order after the parser has
completed its discovery pass and established stable node and edge table row
types for the source.

The protocol has two dispatch levels. The network-level method receives
parallel `parents`, `edgeweights`, and `edgedata` collections and is the
baseline contract for graph formats that may expose nodes with multiple parents.
The single-parent level is the restricted contract for rooted trees; the
entry-point signature is `add_child(parent::Nothing, node_idx::Int,
label::AbstractString, edgeweight::Union{EdgeUnitT, Nothing}; edgedata=nothing,
nodedata=nothing)`, and subsequent node creations receive the concrete parent
handle.

`node_idx` is a 1-based node identifier assigned by the library. `label` is the
raw label from the source and may be empty. `edgeweight` is `nothing` when the
source omits an incoming edge weight. `edgedata` carries the promoted edge row
or edge rows for the incoming edge or edges to the node being created.
`nodedata` carries the promoted node row for the node being created. The
orchestration layer calls `finalize_graph!` once after the final `add_child`
call for a graph and before `LineageGraphAsset` assembly.

Example:

```julia
struct MyNode
    node_idx::Int
    label::String
end

function LineagesIO.add_child(
    parent::Nothing,
    node_idx::Int,
    label::AbstractString,
    edgeweight::Union{EdgeUnitT, Nothing};
    edgedata=nothing,
    nodedata=nothing,
)::MyNode where {EdgeUnitT}
    return MyNode(node_idx, String(label))
end

function LineagesIO.add_child(
    parent::MyNode,
    node_idx::Int,
    label::AbstractString,
    edgeweight::Union{EdgeUnitT, Nothing};
    edgedata=nothing,
    nodedata=nothing,
)::MyNode where {EdgeUnitT}
    return MyNode(node_idx, String(label))
end
```

Required extension signatures:

```julia
function LineagesIO.add_child(
    parents::AbstractVector{NodeT},
    node_idx::Int,
    label::AbstractString,
    edgeweights::AbstractVector{Union{EdgeUnitT, Nothing}};
    edgedata=nothing,
    nodedata=nothing,
)::NodeT where {NodeT, EdgeUnitT}
end

function LineagesIO.add_child(
    parent::Nothing,
    node_idx::Int,
    label::AbstractString,
    edgeweight::Union{EdgeUnitT, Nothing};
    edgedata=nothing,
    nodedata=nothing,
)::NodeT where {EdgeUnitT}
end

function LineagesIO.add_child(
    parent::NodeT,
    node_idx::Int,
    label::AbstractString,
    edgeweight::Union{EdgeUnitT, Nothing};
    edgedata=nothing,
    nodedata=nothing,
)::NodeT where {NodeT, EdgeUnitT}
end
```
"""
add_child

"""
    finalize_graph!(handle::NodeT)::NodeT where {NodeT}

Finalize a graph after the last `add_child` call and before
`LineageGraphAsset` assembly. The default implementation is a no-op that
returns `handle` unchanged. Extensions override this hook for their concrete
node handle types when a graph requires post-build cleanup.

The `PhyloNetworksExt` extension uses this hook to run its post-build
normalization pass after graph construction is complete.
"""
function finalize_graph!(handle::NodeT)::NodeT where {NodeT}
    return handle
end
