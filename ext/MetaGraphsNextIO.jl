module MetaGraphsNextIO

using LineagesIO
using MetaGraphsNext

export MetaGraphsNextNodeHandle
export MetaGraphsNextNodeLabel
export MetaGraphsNextTreeView

struct MetaGraphsNextNodeLabel
    nodekey::LineagesIO.StructureKeyType
end

Base.isless(a::MetaGraphsNextNodeLabel, b::MetaGraphsNextNodeLabel) = isless(a.nodekey, b.nodekey)

mutable struct MetaGraphsNextNodeHandle{GraphT <: MetaGraphsNext.MetaGraph}
    graph::GraphT
    nodekey::Union{Nothing, LineagesIO.StructureKeyType}
end

struct MetaGraphsNextTreeView{
    HandleT <: MetaGraphsNextNodeHandle,
    NodeTableT <: LineagesIO.NodeTable,
    EdgeTableT <: LineagesIO.EdgeTable,
}
    nodehandle::HandleT
    node_table::NodeTableT
    edge_table::EdgeTableT
end

function MetaGraphsNextNodeHandle(
    graph::GraphT,
) where {GraphT <: MetaGraphsNext.MetaGraph}
    return MetaGraphsNextNodeHandle{GraphT}(graph, nothing)
end

function MetaGraphsNextNodeHandle()
    return MetaGraphsNextNodeHandle(
        MetaGraphsNext.MetaGraph(
            MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
            MetaGraphsNextNodeLabel,
            Nothing,
            Nothing,
        ),
    )
end

function metagraph_label_type(
    ::Type{<:MetaGraphsNext.MetaGraph{<:Any, <:Any, LabelT}},
) where {LabelT}
    return LabelT
end

function node_label(nodekey::LineagesIO.StructureKeyType)::MetaGraphsNextNodeLabel
    return MetaGraphsNextNodeLabel(nodekey)
end

function label_nodekey(label::MetaGraphsNextNodeLabel)::LineagesIO.StructureKeyType
    return getfield(label, :nodekey)
end

function bound_nodekey(
    nodehandle::MetaGraphsNextNodeHandle,
)::LineagesIO.StructureKeyType
    nodekey = getfield(nodehandle, :nodekey)
    nodekey === nothing && throw(
        ArgumentError(
            "The MetaGraphsNext node handle is not yet bound to a parsed root node.",
        ),
    )
    return nodekey
end

function require_empty_root_handle!(
    nodehandle::MetaGraphsNextNodeHandle,
)::Nothing
    getfield(nodehandle, :nodekey) === nothing || throw(
        ArgumentError(
            "A supplied `MetaGraphsNextNodeHandle` must be unbound (`nodekey === nothing`) before loading.",
        ),
    )
    MetaGraphsNext.Graphs.is_directed(getfield(nodehandle, :graph)) || throw(
        ArgumentError(
            "A supplied `MetaGraphsNextNodeHandle` must wrap a directed `MetaGraph` for the rooted simple-Newick path.",
        ),
    )
    MetaGraphsNext.Graphs.nv(getfield(nodehandle, :graph)) == 0 || throw(
        ArgumentError(
            "A supplied `MetaGraphsNextNodeHandle` must wrap an empty `MetaGraph` before loading.",
        ),
    )
    metagraph_label_type(typeof(getfield(nodehandle, :graph))) === MetaGraphsNextNodeLabel || throw(
        ArgumentError(
            "A supplied `MetaGraphsNextNodeHandle` must wrap a `MetaGraph` whose label type is `MetaGraphsNextNodeLabel`.",
        ),
    )
    return nothing
end

function add_metagraph_node!(
    graph::MetaGraphsNext.MetaGraph,
    nodekey::LineagesIO.StructureKeyType,
)::Nothing
    added = MetaGraphsNext.Graphs.add_vertex!(graph, node_label(nodekey))
    added || throw(
        ArgumentError(
            "The MetaGraphsNext extension could not add nodekey $(nodekey) to the target `MetaGraph`.",
        ),
    )
    return nothing
end

function add_metagraph_edge!(
    graph::MetaGraphsNext.MetaGraph,
    src_nodekey::LineagesIO.StructureKeyType,
    dst_nodekey::LineagesIO.StructureKeyType,
)::Nothing
    added = MetaGraphsNext.Graphs.add_edge!(
        graph,
        node_label(src_nodekey),
        node_label(dst_nodekey),
    )
    added || throw(
        ArgumentError(
            "The MetaGraphsNext extension could not add edge $(src_nodekey) -> $(dst_nodekey) to the target `MetaGraph`.",
        ),
    )
    return nothing
end

function build_child_handle(
    graph::GraphT,
    nodekey::LineagesIO.StructureKeyType,
) where {GraphT <: MetaGraphsNext.MetaGraph}
    return MetaGraphsNextNodeHandle(graph, nodekey)
end

function LineagesIO.emit_rootnode(
    ::LineagesIO.NodeTypeLoadRequest{NodeT},
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    nodedata::LineagesIO.NodeRowRef,
) where {NodeT <: MetaGraphsNextNodeHandle}
    rootnode = MetaGraphsNextNodeHandle()
    add_metagraph_node!(getfield(rootnode, :graph), nodekey)
    rootnode.nodekey = nodekey
    return rootnode
end

function LineagesIO.emit_rootnode(
    request::LineagesIO.RootBindingLoadRequest{HandleT},
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    nodedata::LineagesIO.NodeRowRef,
) where {HandleT <: MetaGraphsNextNodeHandle}
    rootnode = request.rootnode
    require_empty_root_handle!(rootnode)
    add_metagraph_node!(getfield(rootnode, :graph), nodekey)
    rootnode.nodekey = nodekey
    return rootnode
end

function LineagesIO.emit_childnode(
    ::LineagesIO.NodeTypeLoadRequest{NodeT},
    parent_handle::MetaGraphsNextNodeHandle,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekey::LineagesIO.StructureKeyType,
    edgeweight::LineagesIO.EdgeWeightType,
    nodedata::LineagesIO.NodeRowRef,
    edgedata::LineagesIO.EdgeRowRef,
) where {NodeT <: MetaGraphsNextNodeHandle}
    graph = getfield(parent_handle, :graph)
    add_metagraph_node!(graph, nodekey)
    add_metagraph_edge!(graph, bound_nodekey(parent_handle), nodekey)
    return build_child_handle(graph, nodekey)
end

function LineagesIO.emit_childnode(
    request::LineagesIO.RootBindingLoadRequest{HandleT},
    parent_handle::MetaGraphsNextNodeHandle,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekey::LineagesIO.StructureKeyType,
    edgeweight::LineagesIO.EdgeWeightType,
    nodedata::LineagesIO.NodeRowRef,
    edgedata::LineagesIO.EdgeRowRef,
) where {HandleT <: MetaGraphsNextNodeHandle}
    graph = getfield(parent_handle, :graph)
    add_metagraph_node!(graph, nodekey)
    add_metagraph_edge!(graph, bound_nodekey(parent_handle), nodekey)
    return build_child_handle(graph, nodekey)
end

LineagesIO.finalize_graph!(nodehandle::MetaGraphsNextNodeHandle) = nodehandle

end
