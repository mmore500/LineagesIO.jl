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
    throw(ArgumentError("No `LineagesIO.bind_rootnode!` method is defined for `$(typeof(rootnode))`. Implement `bind_rootnode!(rootnode, nodekey, label; nodedata)` for the supplied rootnode or materialization target, or choose a different load surface."))
end

"""
    add_child(parent, nodekey, label, edgekey, edgeweight; edgedata, nodedata)
    add_child(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)

Materialize a descendant node through the LineagesIO construction protocol.
The root-construction event uses `add_child(::Nothing, ...)`.
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

function add_child(
    parent_collection::AbstractVector,
    nodekey,
    label,
    edgekeys::AbstractVector,
    edgeweights::AbstractVector;
    edgedata,
    nodedata,
)
    isempty(parent_collection) && throw(ArgumentError("The multi-parent `LineagesIO.add_child(parent_collection, ...)` protocol requires at least one parent handle."))
    throw(ArgumentError("No multi-parent `LineagesIO.add_child` method is defined for parent collections of type `$(typeof(parent_collection))`. Implement `add_child(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)` for this load target if it supports multi-parent graphs."))
end

"""
    finalize_graph!(materialized)

Optional post-build cleanup hook. The default implementation is a no-op.
"""
function finalize_graph!(materialized)
    return materialized
end

function graph_requires_multi_parent(edge_table::EdgeTable)::Bool
    node_count = isempty(Tables.columnnames(edge_table)) ? 0 : maximum(Tables.getcolumn(edge_table, :dst_nodekey); init = 0)
    node_count == 0 && return false
    incoming_edgekeys_by_child = [0 for _ in 1:node_count]
    for dst_nodekey in Tables.getcolumn(edge_table, :dst_nodekey)
        incoming_edgekeys_by_child[dst_nodekey] += 1
        incoming_edgekeys_by_child[dst_nodekey] > 1 && return true
    end
    return false
end

function graph_requires_multi_parent(
    graph_asset::LineageGraphAsset,
)::Bool
    return graph_requires_multi_parent(graph_asset.edge_table)
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
    validate_materialization_request(graph_assets, request)
    first_graph = materialize_graph(first(graph_assets), request)
    return [first_graph]
end

function materialize_graphs(
    graph_assets::GraphAssetVectorT,
    request::AbstractLoadRequest,
) where {GraphAssetVectorT <: AbstractVector}
    isempty(graph_assets) && return graph_assets
    validate_materialization_request(graph_assets, request)
    first_graph = materialize_graph(first(graph_assets), request)
    materialized_graphs = [first_graph]
    expected_materialized_type = typeof(first_graph.materialized)
    for graph_asset in Iterators.drop(graph_assets, 1)
        materialized_graph = materialize_graph(graph_asset, request)
        typeof(materialized_graph.materialized) == expected_materialized_type || throw(ArgumentError("All graphs materialized through one construction request must return the same concrete materialized type, but saw both `$(expected_materialized_type)` and `$(typeof(materialized_graph.materialized))`."))
        push!(materialized_graphs, materialized_graph)
    end
    return materialized_graphs
end

function validate_materialization_request(
    graph_assets::AbstractVector,
    request::AbstractLoadRequest,
)::Nothing
    for graph_asset in graph_assets
        validate_materialization_request(graph_asset, request)
    end
    return nothing
end

function validate_materialization_request(
    ::LineageGraphAsset,
    ::TablesOnlyLoadRequest,
)::Nothing
    return nothing
end

function validate_materialization_request(
    graph_asset::LineageGraphAsset,
    request::NodeTypeLoadRequest,
)::Nothing
    graph_requires_multi_parent(graph_asset) || return nothing
    validate_extension_load_target(request.node_type, graph_asset)
    validate_multi_parent_node_type_request(graph_asset, request)
    return nothing
end

function validate_materialization_request(
    graph_asset::LineageGraphAsset,
    request::RootBindingLoadRequest,
)::Nothing
    graph_requires_multi_parent(graph_asset) || return nothing
    validate_extension_load_target(request.rootnode, graph_asset)
    validate_multi_parent_root_binding_request(graph_asset, request)
    return nothing
end

function validate_materialization_request(
    graph_asset::LineageGraphAsset,
    request::BuilderLoadRequest,
)::Nothing
    graph_requires_multi_parent(graph_asset) || return nothing
    validate_multi_parent_builder_request(graph_asset, request)
    return nothing
end

function validate_multi_parent_node_type_request(
    graph_asset::LineageGraphAsset,
    request::NodeTypeLoadRequest,
)::Nothing
    sample = build_multi_parent_protocol_sample(graph_asset)
    sample === nothing && return nothing
    sample_parents = request.node_type[]
    has_custom_multi_parent_add_child(
        sample_parents,
        sample.child_nodekey,
        sample.label,
        sample.edgekeys,
        sample.edgeweights;
        edgedata = sample.edgedata,
        nodedata = sample.nodedata,
    ) && return nothing

    throw(ArgumentError("The `load(src, $(request.node_type))` surface cannot materialize this source because it does not implement the multi-parent `LineagesIO.add_child(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)` construction tier required by this source."))
end

function validate_multi_parent_root_binding_request(
    graph_asset::LineageGraphAsset,
    request::RootBindingLoadRequest,
)::Nothing
    sample = build_multi_parent_protocol_sample(graph_asset)
    sample === nothing && return nothing
    sample_parents = typeof(request.rootnode)[]
    has_custom_multi_parent_add_child(
        sample_parents,
        sample.child_nodekey,
        sample.label,
        sample.edgekeys,
        sample.edgeweights;
        edgedata = sample.edgedata,
        nodedata = sample.nodedata,
    ) && return nothing

    throw(ArgumentError("The supplied `rootnode` load surface cannot materialize this source because its construction path does not implement the multi-parent `LineagesIO.add_child(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)` tier required by this source."))
end

function validate_multi_parent_builder_request(
    graph_asset::LineageGraphAsset,
    request::BuilderLoadRequest,
)::Nothing
    sample = build_multi_parent_protocol_sample(graph_asset)
    sample === nothing && return nothing
    sample_parents = build_builder_parent_collection_sample(request.builder)
    applicable(
        request.builder,
        sample_parents,
        sample.child_nodekey,
        sample.label,
        sample.edgekeys,
        sample.edgeweights;
        edgedata = sample.edgedata,
        nodedata = sample.nodedata,
    ) && return nothing

    throw(ArgumentError("The supplied `builder` callback cannot materialize this source because it does not accept the multi-parent `(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)` construction tier required by this source."))
end

function first_multi_parent_nodekey(
    edge_table::EdgeTable,
    node_count::Int,
)::Union{Nothing, StructureKeyType}
    incoming_edge_counts = zeros(Int, node_count)
    for dst_nodekey in Tables.getcolumn(edge_table, :dst_nodekey)
        incoming_edge_counts[dst_nodekey] += 1
        incoming_edge_counts[dst_nodekey] > 1 && return dst_nodekey
    end
    return nothing
end

function build_multi_parent_protocol_sample(
    graph_asset::LineageGraphAsset,
)
    node_table = graph_asset.node_table
    edge_table = graph_asset.edge_table
    child_nodekey = first_multi_parent_nodekey(edge_table, lineagetable_nrows(node_table))
    child_nodekey === nothing && return nothing

    edgekeys = StructureKeyType[]
    dst_nodekeys = Tables.getcolumn(edge_table, :dst_nodekey)
    for edgekey in Tables.getcolumn(edge_table, :edgekey)
        dst_nodekeys[edgekey] == child_nodekey || continue
        push!(edgekeys, edgekey)
    end

    edgeweights = Tables.getcolumn(edge_table, :edgeweight)
    return (
        child_nodekey = child_nodekey,
        label = Tables.getcolumn(node_table, :label)[child_nodekey],
        edgekeys = edgekeys,
        edgeweights = EdgeWeightType[edgeweights[edgekey] for edgekey in edgekeys],
        edgedata = [EdgeRowRef(edge_table, edgekey) for edgekey in edgekeys],
        nodedata = NodeRowRef(node_table, child_nodekey),
    )
end

function materialize_graph(
    graph_asset::LineageGraphAsset{Nothing, NodeTableT, EdgeTableT},
    request::AbstractLoadRequest,
) where {
    NodeTableT <: NodeTable,
    EdgeTableT <: EdgeTable,
}
    materialized = materialize_graph_rootnode(graph_asset, request)
    return LineageGraphAsset(
        graph_asset.index,
        graph_asset.source_idx,
        graph_asset.collection_idx,
        graph_asset.collection_graph_idx,
        graph_asset.collection_label,
        graph_asset.graph_label,
        graph_asset.node_table,
        graph_asset.edge_table,
        materialized,
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
    src_nodekeys = Tables.getcolumn(edge_table, :src_nodekey)
    dst_nodekeys = Tables.getcolumn(edge_table, :dst_nodekey)
    edgeweights = Tables.getcolumn(edge_table, :edgeweight)

    child_nodekeys_by_parent, incoming_edgekeys_by_child = build_graph_structure(edge_table, node_count)
    rootnodekey = validate_and_find_rootnodekey(incoming_edgekeys_by_child)

    rootnodedata = NodeRowRef(node_table, rootnodekey)
    rootnode_handle = emit_rootnode(request, rootnodekey, labels[rootnodekey], rootnodedata)
    if !graph_requires_multi_parent(graph_asset)
        child_edgekeys_by_parent = build_child_edgekeys(edge_table, node_count)
        construct_single_parent_descendants!(
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

    materialized_handles = Any[nothing for _ in 1:node_count]
    materialized_ready = falses(node_count)
    materialized_handles[rootnodekey] = rootnode_handle
    materialized_ready[rootnodekey] = true

    ready_nodekeys = StructureKeyType[]
    ready_nodekeys_queued = falses(node_count)
    for child_nodekey in child_nodekeys_by_parent[rootnodekey]
        maybe_queue_ready_node!(
            ready_nodekeys,
            ready_nodekeys_queued,
            child_nodekey,
            incoming_edgekeys_by_child,
            src_nodekeys,
            materialized_ready,
        )
    end

    queue_index = 1
    while queue_index <= length(ready_nodekeys)
        child_nodekey = ready_nodekeys[queue_index]
        queue_index += 1
        materialized_ready[child_nodekey] && continue

        incoming_edgekeys = incoming_edgekeys_by_child[child_nodekey]
        all_parents_ready(incoming_edgekeys, src_nodekeys, materialized_ready) || continue

        child_handle = emit_childnode(
            request,
            materialized_handles,
            child_nodekey,
            labels,
            incoming_edgekeys,
            src_nodekeys,
            edgeweights,
            node_table,
            edge_table,
        )
        materialized_handles[child_nodekey] = child_handle
        materialized_ready[child_nodekey] = true

        for grandchild_nodekey in child_nodekeys_by_parent[child_nodekey]
            maybe_queue_ready_node!(
                ready_nodekeys,
                ready_nodekeys_queued,
                grandchild_nodekey,
                incoming_edgekeys_by_child,
                src_nodekeys,
                materialized_ready,
            )
        end
    end

    all(materialized_ready) || throw_impossible_materialization_schedule(materialized_ready)
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

function construct_single_parent_descendants!(
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
        child_handle = emit_single_parent_childnode(
            request,
            parent_handle,
            child_nodekey,
            labels[child_nodekey],
            edgekey,
            edgeweights[edgekey],
            NodeRowRef(node_table, child_nodekey),
            EdgeRowRef(edge_table, edgekey),
        )
        construct_single_parent_descendants!(
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

function build_graph_structure(
    edge_table::EdgeTable,
    node_count::Int,
)::Tuple{Vector{Vector{StructureKeyType}}, Vector{Vector{StructureKeyType}}}
    child_nodekeys_by_parent = [StructureKeyType[] for _ in 1:node_count]
    incoming_edgekeys_by_child = [StructureKeyType[] for _ in 1:node_count]
    last_child_nodekey_by_parent = fill(StructureKeyType(0), node_count)

    src_nodekeys = Tables.getcolumn(edge_table, :src_nodekey)
    dst_nodekeys = Tables.getcolumn(edge_table, :dst_nodekey)
    edgekeys = Tables.getcolumn(edge_table, :edgekey)

    for edgekey in edgekeys
        src_nodekey = src_nodekeys[edgekey]
        dst_nodekey = dst_nodekeys[edgekey]
        push!(incoming_edgekeys_by_child[dst_nodekey], edgekey)
        if last_child_nodekey_by_parent[src_nodekey] != dst_nodekey && !(dst_nodekey in child_nodekeys_by_parent[src_nodekey])
            push!(child_nodekeys_by_parent[src_nodekey], dst_nodekey)
            last_child_nodekey_by_parent[src_nodekey] = dst_nodekey
        end
    end
    return child_nodekeys_by_parent, incoming_edgekeys_by_child
end

function validate_and_find_rootnodekey(
    incoming_edgekeys_by_child::Vector{Vector{StructureKeyType}},
)::StructureKeyType
    rootnodekeys = StructureKeyType[]
    for (nodekey, incoming_edgekeys) in enumerate(incoming_edgekeys_by_child)
        isempty(incoming_edgekeys) || continue
        push!(rootnodekeys, StructureKeyType(nodekey))
    end
    length(rootnodekeys) == 1 || throw(ArgumentError("The authoritative graph tables must describe exactly one `rootnode`, but this graph yielded $(length(rootnodekeys)) candidate root nodes."))
    rootnodekey = only(rootnodekeys)
    rootnodekey == StructureKeyType(1) || throw(ArgumentError("The authoritative graph tables must preserve the tranche-4 `rootnodekey == 1` invariant for materialization, but this graph placed the root node at nodekey $(rootnodekey)."))
    return rootnodekey
end

function maybe_queue_ready_node!(
    ready_nodekeys::Vector{StructureKeyType},
    ready_nodekeys_queued::BitVector,
    child_nodekey::StructureKeyType,
    incoming_edgekeys_by_child::Vector{Vector{StructureKeyType}},
    src_nodekeys::AbstractVector{StructureKeyType},
    materialized_ready::BitVector,
)::Nothing
    ready_nodekeys_queued[child_nodekey] && return nothing
    all_parents_ready(incoming_edgekeys_by_child[child_nodekey], src_nodekeys, materialized_ready) || return nothing
    push!(ready_nodekeys, child_nodekey)
    ready_nodekeys_queued[child_nodekey] = true
    return nothing
end

function all_parents_ready(
    incoming_edgekeys::AbstractVector{StructureKeyType},
    src_nodekeys::AbstractVector{StructureKeyType},
    materialized_ready::BitVector,
)::Bool
    for edgekey in incoming_edgekeys
        materialized_ready[src_nodekeys[edgekey]] || return false
    end
    return true
end

function throw_impossible_materialization_schedule(
    materialized_ready::BitVector,
)::Nothing
    unresolved_nodekeys = StructureKeyType[]
    for (nodekey, is_ready) in enumerate(materialized_ready)
        is_ready || push!(unresolved_nodekeys, StructureKeyType(nodekey))
    end
    throw(ArgumentError("Could not materialize the authoritative graph because some nodes never became ready after parent scheduling. This usually indicates a cycle or an impossible rooted-network parent schedule. Unresolved nodekeys: $(join(unresolved_nodekeys, ", "))."))
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
    request::AbstractLoadRequest,
    materialized_handles::Vector{Any},
    child_nodekey::StructureKeyType,
    labels::AbstractVector{<:AbstractString},
    incoming_edgekeys::AbstractVector{StructureKeyType},
    src_nodekeys::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType},
    node_table::NodeTable,
    edge_table::EdgeTable,
)
    if length(incoming_edgekeys) == 1
        edgekey = only(incoming_edgekeys)
        parent_handle = materialized_handles[src_nodekeys[edgekey]]
        return emit_single_parent_childnode(
            request,
            parent_handle,
            child_nodekey,
            labels[child_nodekey],
            edgekey,
            edgeweights[edgekey],
            NodeRowRef(node_table, child_nodekey),
            EdgeRowRef(edge_table, edgekey),
        )
    end

    parent_handles = Any[materialized_handles[src_nodekeys[edgekey]] for edgekey in incoming_edgekeys]
    parent_collection = build_parent_collection(request, parent_handles)
    edgekey_collection = StructureKeyType[edgekey for edgekey in incoming_edgekeys]
    edgeweight_collection = EdgeWeightType[edgeweights[edgekey] for edgekey in incoming_edgekeys]
    edgedata_collection = [EdgeRowRef(edge_table, edgekey) for edgekey in incoming_edgekeys]
    return emit_multi_parent_childnode(
        request,
        parent_collection,
        child_nodekey,
        labels[child_nodekey],
        edgekey_collection,
        edgeweight_collection,
        NodeRowRef(node_table, child_nodekey),
        edgedata_collection,
    )
end

function build_parent_collection(
    request::NodeTypeLoadRequest,
    parent_handles::Vector{Any},
)::AbstractVector
    ParentHandleT = request.node_type
    all(parent_handle -> parent_handle isa ParentHandleT, parent_handles) || throw(ArgumentError("The `load(src, $(request.node_type))` surface returned parent handles that are not all compatible with the requested node type during multi-parent construction."))
    return ParentHandleT[parent_handle for parent_handle in parent_handles]
end

function build_parent_collection(
    ::AbstractLoadRequest,
    parent_handles::Vector{Any},
)::AbstractVector
    ParentHandleT = reduce(typejoin, map(typeof, parent_handles))
    return ParentHandleT[parent_handle for parent_handle in parent_handles]
end

function emit_single_parent_childnode(
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

function emit_single_parent_childnode(
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

function emit_single_parent_childnode(
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

function emit_multi_parent_childnode(
    request::NodeTypeLoadRequest,
    parent_collection::AbstractVector,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekeys::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType},
    nodedata::NodeRowRef,
    edgedata::AbstractVector,
)
    ensure_multi_parent_protocol_applicable(
        request,
        parent_collection,
        nodekey,
        label,
        edgekeys,
        edgeweights,
        edgedata,
        nodedata,
    )
    child_handle = add_child(
        parent_collection,
        nodekey,
        label,
        edgekeys,
        edgeweights;
        edgedata = edgedata,
        nodedata = nodedata,
    )
    ensure_constructed_handle(child_handle, "multi-parent child-construction")
    return child_handle
end

function emit_multi_parent_childnode(
    request::RootBindingLoadRequest,
    parent_collection::AbstractVector,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekeys::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType},
    nodedata::NodeRowRef,
    edgedata::AbstractVector,
)
    ensure_multi_parent_protocol_applicable(
        request,
        parent_collection,
        nodekey,
        label,
        edgekeys,
        edgeweights,
        edgedata,
        nodedata,
    )
    child_handle = add_child(
        parent_collection,
        nodekey,
        label,
        edgekeys,
        edgeweights;
        edgedata = edgedata,
        nodedata = nodedata,
    )
    ensure_constructed_handle(child_handle, "multi-parent child-construction")
    return child_handle
end

function emit_multi_parent_childnode(
    request::BuilderLoadRequest,
    parent_collection::AbstractVector,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekeys::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType},
    nodedata::NodeRowRef,
    edgedata::AbstractVector,
)
    ensure_multi_parent_protocol_applicable(
        request,
        parent_collection,
        nodekey,
        label,
        edgekeys,
        edgeweights,
        edgedata,
        nodedata,
    )
    child_handle = request.builder(
        parent_collection,
        nodekey,
        label,
        edgekeys,
        edgeweights;
        edgedata = edgedata,
        nodedata = nodedata,
    )
    ensure_constructed_handle(child_handle, "builder multi-parent child-construction")
    return child_handle
end

function ensure_multi_parent_protocol_applicable(
    request::NodeTypeLoadRequest,
    parent_collection::AbstractVector,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekeys::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType},
    edgedata::AbstractVector,
    nodedata::NodeRowRef,
)::Nothing
    has_custom_multi_parent_add_child(
        parent_collection,
        nodekey,
        label,
        edgekeys,
        edgeweights;
        edgedata = edgedata,
        nodedata = nodedata,
    ) && return nothing
    throw(ArgumentError("The `load(src, $(request.node_type))` surface cannot materialize this source because it does not implement the multi-parent `LineagesIO.add_child(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)` construction tier required by this source."))
end

function ensure_multi_parent_protocol_applicable(
    request::RootBindingLoadRequest,
    parent_collection::AbstractVector,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekeys::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType},
    edgedata::AbstractVector,
    nodedata::NodeRowRef,
)::Nothing
    has_custom_multi_parent_add_child(
        parent_collection,
        nodekey,
        label,
        edgekeys,
        edgeweights;
        edgedata = edgedata,
        nodedata = nodedata,
    ) && return nothing
    throw(ArgumentError("The supplied `rootnode` load surface cannot materialize this source because its construction path does not implement the multi-parent `LineagesIO.add_child(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)` tier required by this source."))
end

function ensure_multi_parent_protocol_applicable(
    request::BuilderLoadRequest,
    parent_collection::AbstractVector,
    nodekey::StructureKeyType,
    label::AbstractString,
    edgekeys::AbstractVector{StructureKeyType},
    edgeweights::AbstractVector{EdgeWeightType},
    edgedata::AbstractVector,
    nodedata::NodeRowRef,
)::Nothing
    applicable(
        request.builder,
        parent_collection,
        nodekey,
        label,
        edgekeys,
        edgeweights;
        edgedata = edgedata,
        nodedata = nodedata,
    ) && return nothing
    throw(ArgumentError("The supplied `builder` callback cannot materialize this source because it does not accept the multi-parent `(parent_collection, nodekey, label, edgekeys, edgeweights; edgedata, nodedata)` construction tier required by this source."))
end

function ensure_constructed_handle(handle, phase::AbstractString)::Nothing
    handle === nothing && throw(ArgumentError("The `$(phase)` callback returned `nothing`, but LineagesIO requires a node handle for every emitted construction event."))
    return nothing
end

function build_builder_parent_collection_sample(
    builder,
)::AbstractVector
    parent_handle_types = Type[]
    for method in methods(builder)
        collect_builder_parent_handle_types!(
            parent_handle_types,
            builder_parent_argument_type(method),
        )
    end
    isempty(parent_handle_types) && return Any[]
    ParentHandleT = reduce(typejoin, parent_handle_types)
    return ParentHandleT[]
end

function builder_parent_argument_type(method::Method)
    signature_parameters = Base.unwrap_unionall(method.sig).parameters
    length(signature_parameters) >= 2 || return Any
    return signature_parameters[2]
end

function collect_builder_parent_handle_types!(
    parent_handle_types::Vector{Type},
    parent_argument_type,
)::Nothing
    parent_argument_type === Any && begin
        push!(parent_handle_types, Any)
        return nothing
    end
    for candidate_type in builder_parent_argument_types(parent_argument_type)
        candidate_type === Nothing && continue
        candidate_type === Any && begin
            push!(parent_handle_types, Any)
            continue
        end
        candidate_type isa UnionAll && begin
            push!(parent_handle_types, Any)
            continue
        end
        if candidate_type <: AbstractVector
            push!(parent_handle_types, eltype(candidate_type))
        else
            push!(parent_handle_types, candidate_type)
        end
    end
    return nothing
end

function builder_parent_argument_types(parent_argument_type)::Vector{Any}
    parent_argument_type isa Union && return collect(Base.uniontypes(parent_argument_type))
    return Any[parent_argument_type]
end

function has_custom_multi_parent_add_child(
    parent_collection::AbstractVector,
    nodekey,
    label,
    edgekeys::AbstractVector,
    edgeweights::AbstractVector,
    ;
    edgedata,
    nodedata,
)::Bool
    keyword_values = (; edgedata = edgedata, nodedata = nodedata)
    selected_method = which(
        Core.kwcall,
        Tuple{
            typeof(keyword_values),
            typeof(add_child),
            typeof(parent_collection),
            typeof(nodekey),
            typeof(label),
            typeof(edgekeys),
            typeof(edgeweights),
        },
    )
    fallback_method = which(
        Core.kwcall,
        Tuple{
            typeof(keyword_values),
            typeof(add_child),
            AbstractVector,
            Any,
            Any,
            AbstractVector,
            AbstractVector,
        },
    )
    return selected_method !== fallback_method
end
