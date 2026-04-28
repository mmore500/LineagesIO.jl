abstract type AbstractLoadRequest end

struct TablesOnlyLoadRequest <: AbstractLoadRequest end

struct NodeTypeLoadRequest{NodeT} <: AbstractLoadRequest
    node_type::Type{NodeT}
end

struct RootBindingLoadRequest{RootNodeT} <: AbstractLoadRequest
    rootnode::RootNodeT
end

struct BuilderLoadRequest{BuilderT} <: AbstractLoadRequest
    builder::BuilderT
end

"""
    bind_rootnode!(rootnode, nodekey, label; nodedata)

Bind a parsed root node onto a caller-supplied `rootnode` handle.
"""
function bind_rootnode!(
    rootnode,
    nodekey,
    label;
    nodedata,
)
    throw(ArgumentError("No `LineagesIO.bind_rootnode!` method is defined for `$(typeof(rootnode))`. Implement `bind_rootnode!(rootnode, nodekey, label; nodedata)` for the supplied rootnode handle or choose a different load surface."))
end

"""
    add_child(parent, nodekey, label, edgekey, edgeweight; edgedata, nodedata)

Materialize a root node or descendant node through the LineagesIO construction
protocol.
"""
function add_child(
    parent,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata = nothing,
    nodedata,
)
    if parent === nothing
        throw(ArgumentError("No `LineagesIO.add_child(::Nothing, ...)` root-construction method is defined for this load target. Implement `add_child(::Nothing, nodekey, label, nothing, nothing; edgedata = nothing, nodedata)` or use `load(src; builder = fn)` instead."))
    end
    throw(ArgumentError("No single-parent `LineagesIO.add_child` method is defined for parent handles of type `$(typeof(parent))`. Implement `add_child(parent, nodekey, label, edgekey, edgeweight; edgedata, nodedata)` for this node-handle type."))
end

"""
    finalize_graph!(graph_rootnode)

Optional post-build cleanup hook. The default implementation is a no-op.
"""
function finalize_graph!(graph_rootnode)
    return graph_rootnode
end

function materialize_graphs(
    graph_assets::GraphAssetVectorT,
    ::TablesOnlyLoadRequest,
) where {GraphAssetVectorT <: AbstractVector}
    return graph_assets
end

function materialize_graphs(
    graph_assets::GraphAssetVectorT,
    request::RootBindingLoadRequest,
) where {GraphAssetVectorT <: AbstractVector}
    length(graph_assets) == 1 || throw(ArgumentError("The supplied-root load surface is valid only for a source that yields exactly one graph, but this source yielded $(length(graph_assets)) graphs. Use `load(src)` for tables-only access or a library-created-root construction surface instead."))
    first_graph = materialize_graph(first(graph_assets), request)
    return [first_graph]
end

function materialize_graphs(
    graph_assets::GraphAssetVectorT,
    request::AbstractLoadRequest,
) where {GraphAssetVectorT <: AbstractVector}
    isempty(graph_assets) && return graph_assets
    first_graph = materialize_graph(first(graph_assets), request)
    materialized_graphs = [first_graph]
    expected_root_type = typeof(first_graph.graph_rootnode)
    for graph_asset in Iterators.drop(graph_assets, 1)
        materialized_graph = materialize_graph(graph_asset, request)
        typeof(materialized_graph.graph_rootnode) == expected_root_type || throw(ArgumentError("All graphs materialized through one construction request must return the same concrete root-handle type, but saw both `$(expected_root_type)` and `$(typeof(materialized_graph.graph_rootnode))`."))
        push!(materialized_graphs, materialized_graph)
    end
    return materialized_graphs
end

function materialize_graph(
    graph_asset::LineageGraphAsset{Nothing, NodeTableT, EdgeTableT},
    request::AbstractLoadRequest,
) where {
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    rootnode_handle = materialize_graph_rootnode(graph_asset, request)
    return LineageGraphAsset(
        graph_asset.index,
        graph_asset.source_idx,
        graph_asset.collection_idx,
        graph_asset.collection_graph_idx,
        graph_asset.collection_label,
        graph_asset.graph_label,
        graph_asset.node_table,
        graph_asset.edge_table,
        rootnode_handle,
        graph_asset.source_path,
    )
end

function materialize_graph_rootnode(
    graph_asset::LineageGraphAsset{Nothing, NodeTableT, EdgeTableT},
    request::AbstractLoadRequest,
) where {
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    node_table = graph_asset.node_table
    edge_table = graph_asset.edge_table
    node_count = lineagetable_nrows(node_table)
    node_count > 0 || throw(ArgumentError("Cannot materialize a graph with no nodes."))

    labels = Tables.getcolumn(node_table, :label)
    dst_nodekeys = Tables.getcolumn(edge_table, :dst_nodekey)
    edgeweights = Tables.getcolumn(edge_table, :edgeweight)
    child_edgekeys_by_parent = build_child_edgekeys(edge_table, node_count)

    rootnodekey = StructureKeyType(1)
    rootnodedata = NodeRowRef(node_table, rootnodekey)
    rootnode_handle = emit_rootnode(request, rootnodekey, labels[rootnodekey], rootnodedata)
    construct_descendants!(
        request,
        rootnode_handle,
        rootnodekey,
        labels,
        dst_nodekeys,
        edgeweights,
        child_edgekeys_by_parent,
        node_table,
        edge_table,
    )
    return finalize_graph!(rootnode_handle)
end

function build_child_edgekeys(
    edge_table::EdgeTable,
    node_count::Int,
)::Vector{Vector{StructureKeyType}}
    child_edgekeys_by_parent = [StructureKeyType[] for _ in 1:node_count]
    src_nodekeys = Tables.getcolumn(edge_table, :src_nodekey)
    edgekeys = Tables.getcolumn(edge_table, :edgekey)
    for edgekey in edgekeys
        push!(child_edgekeys_by_parent[src_nodekeys[edgekey]], edgekey)
    end
    return child_edgekeys_by_parent
end

function construct_descendants!(
    request::AbstractLoadRequest,
    parent_handle,
    parent_nodekey::StructureKeyType,
    labels::AbstractVector{<:AbstractString},
    dst_nodekeys::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType},
    child_edgekeys_by_parent::Vector{Vector{StructureKeyType}},
    node_table::NodeTable,
    edge_table::EdgeTable,
)::Nothing
    for edgekey in child_edgekeys_by_parent[parent_nodekey]
        child_nodekey = dst_nodekeys[edgekey]
        child_handle = emit_childnode(
            request,
            parent_handle,
            child_nodekey,
            labels[child_nodekey],
            edgekey,
            edgeweights[edgekey],
            NodeRowRef(node_table, child_nodekey),
            EdgeRowRef(edge_table, edgekey),
        )
        construct_descendants!(
            request,
            child_handle,
            child_nodekey,
            labels,
            dst_nodekeys,
            edgeweights,
            child_edgekeys_by_parent,
            node_table,
            edge_table,
        )
    end
    return nothing
end

function emit_rootnode(
    request::NodeTypeLoadRequest{NodeT},
    nodekey::StructureKeyType,
    label::AbstractString,
    nodedata::NodeRowRef,
) where {NodeT}
    rootnode_handle = add_child(
        nothing,
        nodekey,
        label,
        nothing,
        nothing;
        edgedata = nothing,
        nodedata = nodedata,
    )
    ensure_constructed_handle(rootnode_handle, "root-construction")
    rootnode_handle isa NodeT || throw(ArgumentError("The root-construction `LineagesIO.add_child(::Nothing, ...)` call returned `$(typeof(rootnode_handle))`, but `load(src, $(request.node_type))` requires a value compatible with `$(request.node_type)`."))
    return rootnode_handle
end

function emit_rootnode(
    request::RootBindingLoadRequest,
    nodekey::StructureKeyType,
    label::AbstractString,
    nodedata::NodeRowRef,
)
    rootnode_handle = bind_rootnode!(request.rootnode, nodekey, label; nodedata = nodedata)
    ensure_constructed_handle(rootnode_handle, "root-binding")
    return rootnode_handle
end

function emit_rootnode(
    request::BuilderLoadRequest,
    nodekey::StructureKeyType,
    label::AbstractString,
    nodedata::NodeRowRef,
)
    rootnode_handle = request.builder(
        nothing,
        nodekey,
        label,
        nothing,
        nothing;
        edgedata = nothing,
        nodedata = nodedata,
    )
    ensure_constructed_handle(rootnode_handle, "builder root-construction")
    return rootnode_handle
end

function emit_childnode(
    ::NodeTypeLoadRequest,
    parent_handle,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekey::StructureKeyType,
    edgeweight::EdgeWeightType,
    nodedata::NodeRowRef,
    edgedata::EdgeRowRef,
)
    child_handle = add_child(
        parent_handle,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata = edgedata,
        nodedata = nodedata,
    )
    ensure_constructed_handle(child_handle, "child-construction")
    return child_handle
end

function emit_childnode(
    ::RootBindingLoadRequest,
    parent_handle,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekey::StructureKeyType,
    edgeweight::EdgeWeightType,
    nodedata::NodeRowRef,
    edgedata::EdgeRowRef,
)
    child_handle = add_child(
        parent_handle,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata = edgedata,
        nodedata = nodedata,
    )
    ensure_constructed_handle(child_handle, "child-construction")
    return child_handle
end

function emit_childnode(
    request::BuilderLoadRequest,
    parent_handle,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekey::StructureKeyType,
    edgeweight::EdgeWeightType,
    nodedata::NodeRowRef,
    edgedata::EdgeRowRef,
)
    child_handle = request.builder(
        parent_handle,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata = edgedata,
        nodedata = nodedata,
    )
    ensure_constructed_handle(child_handle, "builder child-construction")
    return child_handle
end

function ensure_constructed_handle(handle, phase::AbstractString)::Nothing
    handle === nothing && throw(ArgumentError("The `$(phase)` callback returned `nothing`, but LineagesIO requires a node handle for every emitted construction event."))
    return nothing
end
