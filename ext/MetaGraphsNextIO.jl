module MetaGraphsNextIO

using LineagesIO
using MetaGraphsNext

struct MetaGraphsNextNodeLabel
    nodekey::LineagesIO.StructureKeyType
end

Base.isless(a::MetaGraphsNextNodeLabel, b::MetaGraphsNextNodeLabel) = isless(a.nodekey, b.nodekey)

struct MetaGraphsNextBuildCursor{GraphT <: MetaGraphsNext.MetaGraph}
    graph::GraphT
    nodekey::LineagesIO.StructureKeyType
end

struct ConcreteMetaGraphsNextTreeView{
    GraphT <: MetaGraphsNext.MetaGraph,
    NodeTableT <: LineagesIO.NodeTable,
    EdgeTableT <: LineagesIO.EdgeTable,
}
    graph::GraphT
    nodekey::LineagesIO.StructureKeyType
    node_table::NodeTableT
    edge_table::EdgeTableT
end

function build_default_metagraph()
    return MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        MetaGraphsNextNodeLabel,
        Nothing,
        Nothing,
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

function require_empty_graph!(
    graph::MetaGraphsNext.MetaGraph,
)::Nothing
    MetaGraphsNext.Graphs.is_directed(graph) || throw(
        ArgumentError(
            "A supplied `MetaGraph` must be directed for the current single-parent MetaGraphsNext load path.",
        ),
    )
    MetaGraphsNext.Graphs.nv(graph) == 0 || throw(
        ArgumentError(
            "A supplied `MetaGraph` must be empty before loading.",
        ),
    )
    metagraph_label_type(typeof(graph)) === MetaGraphsNextNodeLabel || throw(
        ArgumentError(
            "A supplied `MetaGraph` must use `MetaGraphsNextNodeLabel` as its label type for the current single-parent MetaGraphsNext load path.",
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

function LineagesIO.validate_extension_load_target(
    node_type::Type{TargetT},
)::Nothing where {TargetT <: MetaGraphsNext.MetaGraph}
    node_type === MetaGraphsNext.MetaGraph && return nothing
    throw(
        ArgumentError(
            "The MetaGraphsNext extension supports `load(src, MetaGraph)` for library-created materialization. To choose a specific MetaGraph parameterization, construct an empty `MetaGraph` instance yourself and call `load(src, graph)` instead.",
        ),
    )
end

function LineagesIO.validate_extension_load_target(
    ::Type{TargetT},
    graph_asset::LineagesIO.LineageGraphAsset,
)::Nothing where {TargetT <: MetaGraphsNext.MetaGraph}
    LineagesIO.graph_requires_multi_parent(graph_asset) || return nothing
    throw(
        ArgumentError(
            "The MetaGraphsNext extension supports the single-parent construction tier for this load surface and cannot materialize a multi-parent graph from this source.",
        ),
    )
end

function LineagesIO.validate_extension_load_target(
    ::GraphT,
    graph_asset::LineagesIO.LineageGraphAsset,
)::Nothing where {GraphT <: MetaGraphsNext.MetaGraph}
    LineagesIO.graph_requires_multi_parent(graph_asset) || return nothing
    throw(
        ArgumentError(
            "The MetaGraphsNext extension supports the single-parent construction tier for this load surface and cannot materialize a multi-parent graph from this source.",
        ),
    )
end

function LineagesIO.emit_rootnode(
    request::LineagesIO.NodeTypeLoadRequest{TargetT},
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    nodedata::LineagesIO.NodeRowRef,
) where {TargetT <: MetaGraphsNext.MetaGraph}
    LineagesIO.validate_extension_load_target(request.node_type)
    graph = build_default_metagraph()
    add_metagraph_node!(graph, nodekey)
    return MetaGraphsNextBuildCursor(graph, nodekey)
end

function LineagesIO.bind_rootnode!(
    graph::GraphT,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString;
    nodedata,
) where {GraphT <: MetaGraphsNext.MetaGraph}
    require_empty_graph!(graph)
    add_metagraph_node!(graph, nodekey)
    return MetaGraphsNextBuildCursor{GraphT}(graph, nodekey)
end

function LineagesIO.add_child(
    parent::MetaGraphsNextBuildCursor{GraphT},
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekey::LineagesIO.StructureKeyType,
    edgeweight::LineagesIO.EdgeWeightType;
    edgedata,
    nodedata,
) where {GraphT <: MetaGraphsNext.MetaGraph}
    graph = getfield(parent, :graph)
    add_metagraph_node!(graph, nodekey)
    add_metagraph_edge!(graph, getfield(parent, :nodekey), nodekey)
    return MetaGraphsNextBuildCursor{GraphT}(graph, nodekey)
end

function LineagesIO.finalize_graph!(
    cursor::MetaGraphsNextBuildCursor,
)
    return getfield(cursor, :graph)
end

function root_nodekey(
    graph::MetaGraphsNext.MetaGraph,
)::LineagesIO.StructureKeyType
    MetaGraphsNext.Graphs.nv(graph) > 0 || throw(
        ArgumentError(
            "The MetaGraphsNext tree-view helper requires a non-empty `MetaGraph`.",
        ),
    )
    return LineagesIO.StructureKeyType(1)
end

function LineagesIO.MetaGraphsNextTreeView(
    asset::LineagesIO.LineageGraphAsset{GraphT, NodeTableT, EdgeTableT},
) where {
    GraphT <: MetaGraphsNext.MetaGraph,
    NodeTableT <: LineagesIO.NodeTable,
    EdgeTableT <: LineagesIO.EdgeTable,
}
    graph = asset.materialized
    return ConcreteMetaGraphsNextTreeView(
        graph,
        root_nodekey(graph),
        asset.node_table,
        asset.edge_table,
    )
end

function LineagesIO.MetaGraphsNextTreeView(
    graph::GraphT,
    node_table::NodeTableT,
    edge_table::EdgeTableT,
) where {
    GraphT <: MetaGraphsNext.MetaGraph,
    NodeTableT <: LineagesIO.NodeTable,
    EdgeTableT <: LineagesIO.EdgeTable,
}
    return ConcreteMetaGraphsNextTreeView(
        graph,
        root_nodekey(graph),
        node_table,
        edge_table,
    )
end

end
