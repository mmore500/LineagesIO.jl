module PhyloNetworksIO

using LineagesIO
using PhyloNetworks
using Tables

mutable struct PhyloNetworksBuildState
    node_by_nodekey::Dict{LineagesIO.StructureKeyType, PhyloNetworks.Node}
    edge_by_edgekey::Dict{LineagesIO.StructureKeyType, PhyloNetworks.Edge}
    outgoing_edge_count_by_nodekey::Vector{Int}
    incoming_edge_count_by_nodekey::Vector{Int}
    edge_counts_initialized::Bool
end

struct PhyloNetworksBuildCursor{
    GraphT <: PhyloNetworks.HybridNetwork,
    TargetT,
    StateT <: PhyloNetworksBuildState,
}
    graph::GraphT
    target::TargetT
    node::PhyloNetworks.Node
    nodekey::LineagesIO.StructureKeyType
    state::StateT
end

function node_count(node_table::LineagesIO.NodeTable)::Int
    return length(Tables.getcolumn(node_table, :nodekey))
end

function normalize_label(label::AbstractString)::String
    return String(label)
end

function normalized_leaf_name(
    nodekey::LineagesIO.StructureKeyType,
)::String
    return "LineagesIO__unnamed_leaf__$(nodekey)"
end

function normalize_phylonetworks_node_name(
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    is_leaf::Bool,
)::String
    normalized_label = normalize_label(label)
    is_leaf && isempty(normalized_label) && return normalized_leaf_name(nodekey)
    return normalized_label
end

function normalize_edgeweight(
    edgeweight::LineagesIO.EdgeWeightType,
)::Float64
    edgeweight === nothing && return -1.0
    return Float64(edgeweight)
end

function retained_edge_property_text(
    edgedata::LineagesIO.EdgeRowRef,
    propertykey::Symbol,
)::Union{Nothing, String}
    propertykey in Tables.columnnames(getfield(edgedata, :table)) || return nothing
    return Tables.getcolumn(edgedata, propertykey)
end

function parse_retained_gamma_value(
    edgekey::LineagesIO.StructureKeyType,
    gamma_text::AbstractString,
)::Float64
    gamma_value = try
        parse(Float64, gamma_text)
    catch err
        throw(
            ArgumentError(
                "The PhyloNetworks extension could not parse retained `gamma` value `$(gamma_text)` on edgekey $(edgekey) as `Float64`: $(sprint(showerror, err)).",
            ),
        )
    end
    0.0 <= gamma_value <= 1.0 || throw(
        ArgumentError(
            "The PhyloNetworks extension requires retained `gamma` values to lie in [0, 1], but edgekey $(edgekey) carried $(gamma_value).",
        ),
    )
    return gamma_value
end

function parse_retained_branch_role(
    edgekey::LineagesIO.StructureKeyType,
    branch_role_text::Union{Nothing, String},
)::Union{Nothing, Symbol}
    branch_role_text === nothing && return nothing
    branch_role_text == "major" && return :major
    branch_role_text == "minor" && return :minor
    throw(
        ArgumentError(
            "The PhyloNetworks extension recognizes retained `branch` annotations only as `major` or `minor`, but edgekey $(edgekey) carried `$(branch_role_text)`.",
        ),
    )
end

function require_empty_hybridnetwork!(
    graph::PhyloNetworks.HybridNetwork,
)::Nothing
    isempty(getfield(graph, :node)) || throw(
        ArgumentError(
            "A supplied `HybridNetwork` must be empty before loading.",
        ),
    )
    isempty(getfield(graph, :edge)) || throw(
        ArgumentError(
            "A supplied `HybridNetwork` must be empty before loading.",
        ),
    )
    getfield(graph, :numnodes) == 0 || throw(
        ArgumentError(
            "A supplied `HybridNetwork` must be empty before loading.",
        ),
    )
    getfield(graph, :numedges) == 0 || throw(
        ArgumentError(
            "A supplied `HybridNetwork` must be empty before loading.",
        ),
    )
    return nothing
end

function validate_phylonetworks_graph_asset(
    graph_asset::LineagesIO.LineageGraphAsset,
)::Nothing
    edge_table = getfield(graph_asset, :edge_table)
    edgekeys = Tables.getcolumn(edge_table, :edgekey)
    dst_nodekeys = Tables.getcolumn(edge_table, :dst_nodekey)
    gamma_column = :gamma in Tables.columnnames(edge_table) ? Tables.getcolumn(edge_table, :gamma) : nothing
    branch_column = :branch in Tables.columnnames(edge_table) ? Tables.getcolumn(edge_table, :branch) : nothing

    incoming_edgekeys_by_child = Dict{LineagesIO.StructureKeyType, Vector{LineagesIO.StructureKeyType}}()
    for edgekey in edgekeys
        child_nodekey = dst_nodekeys[edgekey]
        push!(
            get!(
                incoming_edgekeys_by_child,
                child_nodekey,
                LineagesIO.StructureKeyType[],
            ),
            edgekey,
        )
    end

    for (child_nodekey, incoming_edgekeys) in incoming_edgekeys_by_child
        length(incoming_edgekeys) <= 2 || throw(
            ArgumentError(
                "The PhyloNetworks extension supports hybrid nodes with exactly 2 parent edges, but nodekey $(child_nodekey) has $(length(incoming_edgekeys)) incoming parent edges in the authoritative edge table.",
            ),
        )
        length(incoming_edgekeys) == 2 || continue

        specified_gamma_values = Float64[]
        major_branch_count = 0
        minor_branch_count = 0
        for edgekey in incoming_edgekeys
            if gamma_column !== nothing
                gamma_text = gamma_column[edgekey]
                gamma_text === nothing || push!(
                    specified_gamma_values,
                    parse_retained_gamma_value(edgekey, gamma_text),
                )
            end
            if branch_column !== nothing
                branch_role = parse_retained_branch_role(edgekey, branch_column[edgekey])
                branch_role === :major && (major_branch_count += 1)
                branch_role === :minor && (minor_branch_count += 1)
            end
        end

        length(specified_gamma_values) < 2 || isapprox(sum(specified_gamma_values), 1.0; atol = 1.0e-8) || throw(
            ArgumentError(
                "The PhyloNetworks extension requires the 2 retained `gamma` values feeding hybrid nodekey $(child_nodekey) to sum to 1.0, but they summed to $(sum(specified_gamma_values)).",
            ),
        )
        major_branch_count <= 1 || throw(
            ArgumentError(
                "The PhyloNetworks extension requires at most one retained `branch=major` annotation for hybrid nodekey $(child_nodekey).",
            ),
        )
        minor_branch_count <= 1 || throw(
            ArgumentError(
                "The PhyloNetworks extension requires at most one retained `branch=minor` annotation for hybrid nodekey $(child_nodekey).",
            ),
        )
    end
    return nothing
end

function LineagesIO.validate_extension_load_target(
    node_type::Type{TargetT},
)::Nothing where {TargetT <: PhyloNetworks.HybridNetwork}
    node_type === PhyloNetworks.HybridNetwork && return nothing
    throw(
        ArgumentError(
            "The PhyloNetworks extension supports `load(src, HybridNetwork)` for library-created materialization. To materialize into a caller-supplied target, construct an empty `HybridNetwork()` instance and call `load(src, target)` instead.",
        ),
    )
end

function LineagesIO.validate_extension_load_target(
    ::Type{TargetT},
    graph_asset::LineagesIO.LineageGraphAsset,
)::Nothing where {TargetT <: PhyloNetworks.HybridNetwork}
    validate_phylonetworks_graph_asset(graph_asset)
    return nothing
end

function LineagesIO.validate_extension_load_target(
    graph::PhyloNetworks.HybridNetwork,
    graph_asset::LineagesIO.LineageGraphAsset,
)::Nothing
    require_empty_hybridnetwork!(graph)
    validate_phylonetworks_graph_asset(graph_asset)
    return nothing
end

function LineagesIO.construction_handle_type(
    ::PhyloNetworks.HybridNetwork,
)::Type
    return PhyloNetworksBuildCursor{
        PhyloNetworks.HybridNetwork,
        PhyloNetworks.HybridNetwork,
        PhyloNetworksBuildState,
    }
end

function build_phylonetworks_state(
    node_table::LineagesIO.NodeTable,
)::PhyloNetworksBuildState
    node_count_value = node_count(node_table)
    return PhyloNetworksBuildState(
        Dict{LineagesIO.StructureKeyType, PhyloNetworks.Node}(),
        Dict{LineagesIO.StructureKeyType, PhyloNetworks.Edge}(),
        zeros(Int, node_count_value),
        zeros(Int, node_count_value),
        false,
    )
end

function ensure_edge_counts_initialized!(
    state::PhyloNetworksBuildState,
    edge_table::LineagesIO.EdgeTable,
)::Nothing
    getfield(state, :edge_counts_initialized) && return nothing
    src_nodekeys = Tables.getcolumn(edge_table, :src_nodekey)
    dst_nodekeys = Tables.getcolumn(edge_table, :dst_nodekey)
    for edgekey in Tables.getcolumn(edge_table, :edgekey)
        getfield(state, :outgoing_edge_count_by_nodekey)[src_nodekeys[edgekey]] += 1
        getfield(state, :incoming_edge_count_by_nodekey)[dst_nodekeys[edgekey]] += 1
    end
    state.edge_counts_initialized = true
    return nothing
end

function node_is_leaf(
    state::PhyloNetworksBuildState,
    nodekey::LineagesIO.StructureKeyType,
)::Bool
    return getfield(state, :outgoing_edge_count_by_nodekey)[nodekey] == 0
end

function node_is_hybrid(
    state::PhyloNetworksBuildState,
    nodekey::LineagesIO.StructureKeyType,
)::Bool
    return getfield(state, :incoming_edge_count_by_nodekey)[nodekey] > 1
end

function ensure_name_slot!(
    graph::PhyloNetworks.HybridNetwork,
    node_number::Int,
)::Nothing
    node_number > 0 || return nothing
    names = getfield(graph, :names)
    while length(names) < node_number
        push!(names, "")
    end
    return nothing
end

function record_node_name!(
    graph::PhyloNetworks.HybridNetwork,
    node::PhyloNetworks.Node,
)::Nothing
    node_number = getfield(node, :number)
    node_number > 0 || return nothing
    ensure_name_slot!(graph, node_number)
    getfield(graph, :names)[node_number] = String(getfield(node, :name))
    return nothing
end

function register_node!(
    graph::PhyloNetworks.HybridNetwork,
    state::PhyloNetworksBuildState,
    nodekey::LineagesIO.StructureKeyType,
    node::PhyloNetworks.Node,
)::Nothing
    haskey(getfield(state, :node_by_nodekey), nodekey) && throw(
        ArgumentError(
            "The PhyloNetworks extension attempted to create nodekey $(nodekey) more than once.",
        ),
    )
    PhyloNetworks.pushNode!(graph, node)
    record_node_name!(graph, node)
    getfield(state, :node_by_nodekey)[nodekey] = node
    return nothing
end

function register_edge!(
    graph::PhyloNetworks.HybridNetwork,
    state::PhyloNetworksBuildState,
    edgekey::LineagesIO.StructureKeyType,
    edge::PhyloNetworks.Edge,
)::Nothing
    haskey(getfield(state, :edge_by_edgekey), edgekey) && throw(
        ArgumentError(
            "The PhyloNetworks extension attempted to create edgekey $(edgekey) more than once.",
        ),
    )
    PhyloNetworks.pushEdge!(graph, edge)
    getfield(state, :edge_by_edgekey)[edgekey] = edge
    return nothing
end

function build_basenode(
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    node_table::LineagesIO.NodeTable,
)::PhyloNetworks.Node
    is_leaf = node_count(node_table) == 1
    basenode = PhyloNetworks.Node(Int(nodekey), is_leaf, false)
    basenode.name = normalize_phylonetworks_node_name(
        nodekey,
        label,
        is_leaf,
    )
    return basenode
end

function build_graph_cursor(
    target::TargetT,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    nodedata::LineagesIO.NodeRowRef,
) where {TargetT}
    graph = PhyloNetworks.HybridNetwork()
    state = build_phylonetworks_state(getfield(nodedata, :table))
    basenode = build_basenode(nodekey, label, getfield(nodedata, :table))
    register_node!(
        graph,
        state,
        nodekey,
        basenode,
    )
    graph.rooti = 1
    return PhyloNetworksBuildCursor(graph, target, basenode, nodekey, state)
end

function LineagesIO.emit_basenode(
    request::LineagesIO.NodeTypeLoadRequest{PhyloNetworks.HybridNetwork},
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    nodedata::LineagesIO.NodeRowRef,
)
    LineagesIO.validate_extension_load_target(getfield(request, :node_type))
    return build_graph_cursor(nothing, nodekey, label, nodedata)
end

function LineagesIO.bind_basenode!(
    target::PhyloNetworks.HybridNetwork,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString;
    nodedata,
)
    require_empty_hybridnetwork!(target)
    return build_graph_cursor(target, nodekey, label, nodedata)
end

function build_network_node(
    state::PhyloNetworksBuildState,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
)::PhyloNetworks.Node
    is_leaf = node_is_leaf(state, nodekey)
    node = PhyloNetworks.Node(
        Int(nodekey),
        is_leaf,
        node_is_hybrid(state, nodekey),
    )
    node.name = normalize_phylonetworks_node_name(nodekey, label, is_leaf)
    return node
end

function build_tree_edge(
    edgekey::LineagesIO.StructureKeyType,
    edgeweight::LineagesIO.EdgeWeightType,
)::PhyloNetworks.Edge
    return PhyloNetworks.Edge(Int(edgekey), normalize_edgeweight(edgeweight))
end

function build_hybrid_edge(
    edgekey::LineagesIO.StructureKeyType,
    edgeweight::LineagesIO.EdgeWeightType,
    ismajor::Bool,
)::PhyloNetworks.Edge
    return PhyloNetworks.Edge(
        Int(edgekey),
        normalize_edgeweight(edgeweight),
        true,
        -1.0,
        ismajor,
    )
end

function attach_edge!(
    graph::PhyloNetworks.HybridNetwork,
    state::PhyloNetworksBuildState,
    edgekey::LineagesIO.StructureKeyType,
    edge::PhyloNetworks.Edge,
    parent_node::PhyloNetworks.Node,
    child_node::PhyloNetworks.Node,
)::Nothing
    PhyloNetworks.setNode!(edge, PhyloNetworks.Node[child_node, parent_node])
    PhyloNetworks.setEdge!(child_node, edge)
    PhyloNetworks.setEdge!(parent_node, edge)
    register_edge!(graph, state, edgekey, edge)
    return nothing
end

function child_cursor(
    parent::PhyloNetworksBuildCursor,
    node::PhyloNetworks.Node,
    nodekey::LineagesIO.StructureKeyType,
)
    return PhyloNetworksBuildCursor(
        getfield(parent, :graph),
        getfield(parent, :target),
        node,
        nodekey,
        getfield(parent, :state),
    )
end

function LineagesIO.add_child(
    parent::PhyloNetworksBuildCursor,
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekey::LineagesIO.StructureKeyType,
    edgeweight::LineagesIO.EdgeWeightType;
    edgedata,
    nodedata,
)
    state = getfield(parent, :state)
    ensure_edge_counts_initialized!(state, getfield(edgedata, :table))
    child_node = build_network_node(state, nodekey, label)
    register_node!(getfield(parent, :graph), state, nodekey, child_node)
    edge = build_tree_edge(edgekey, edgeweight)
    attach_edge!(
        getfield(parent, :graph),
        state,
        edgekey,
        edge,
        getfield(parent, :node),
        child_node,
    )
    return child_cursor(parent, child_node, nodekey)
end

function infer_major_edge_index(
    branch_roles::AbstractVector{<:Union{Nothing, Symbol}},
)::Int
    major_index = findfirst(isequal(:major), branch_roles)
    major_index !== nothing && return major_index
    minor_index = findfirst(isequal(:minor), branch_roles)
    if minor_index !== nothing && length(branch_roles) == 2
        return minor_index == 1 ? 2 : 1
    end
    return 1
end

function assign_major_edge_roles!(
    edges::Vector{PhyloNetworks.Edge},
    major_index::Int,
)::Nothing
    for (index, edge) in enumerate(edges)
        edge.ismajor = index == major_index
    end
    return nothing
end

function enforce_branch_role_annotations!(
    edges::Vector{PhyloNetworks.Edge},
    edgekeys::Vector{LineagesIO.StructureKeyType},
    branch_roles::AbstractVector{<:Union{Nothing, Symbol}},
    child_nodekey::LineagesIO.StructureKeyType,
)::Nothing
    for (edge, edgekey, branch_role) in zip(edges, edgekeys, branch_roles)
        branch_role === nothing && continue
        branch_role === :major && getfield(edge, :ismajor) && continue
        branch_role === :minor && !getfield(edge, :ismajor) && continue
        throw(
            ArgumentError(
                "The PhyloNetworks extension derived a hybrid-parent orientation that conflicts with retained `branch` annotation `$(branch_role)` on edgekey $(edgekey) feeding nodekey $(child_nodekey).",
            ),
        )
    end
    return nothing
end

function apply_hybrid_inheritance!(
    edges::Vector{PhyloNetworks.Edge},
    edgekeys::Vector{LineagesIO.StructureKeyType},
    edgedata::AbstractVector,
    child_nodekey::LineagesIO.StructureKeyType,
)::Nothing
    gamma_values = Union{Nothing, Float64}[]
    branch_roles = Union{Nothing, Symbol}[]
    for (edgekey, edge_rowref) in zip(edgekeys, edgedata)
        gamma_text = retained_edge_property_text(edge_rowref, :gamma)
        push!(
            gamma_values,
            gamma_text === nothing ? nothing : parse_retained_gamma_value(edgekey, gamma_text),
        )
        push!(
            branch_roles,
            parse_retained_branch_role(
                edgekey,
                retained_edge_property_text(edge_rowref, :branch),
            ),
        )
    end

    specified_gamma_indices = findall(
        gamma_value -> gamma_value !== nothing,
        gamma_values,
    )
    if !isempty(specified_gamma_indices)
        if length(specified_gamma_indices) == 2
            gamma_sum = sum(something(gamma_values[index]) for index in specified_gamma_indices)
            isapprox(gamma_sum, 1.0; atol = 1.0e-8) || throw(
                ArgumentError(
                    "The PhyloNetworks extension requires the 2 retained `gamma` values feeding hybrid nodekey $(child_nodekey) to sum to 1.0, but they summed to $(gamma_sum).",
                ),
            )
        end
        selected_index = first(specified_gamma_indices)
        selected_gamma = something(gamma_values[selected_index])
        PhyloNetworks.setgamma!(edges[selected_index], selected_gamma)
        specified_gamma_values = [
            something(gamma_values[index]) for index in specified_gamma_indices
        ]
        if any(role -> role !== nothing, branch_roles) &&
           all(gamma -> isapprox(gamma, 0.5; atol = 1.0e-8), specified_gamma_values)
            assign_major_edge_roles!(
                edges,
                infer_major_edge_index(branch_roles),
            )
        end
    else
        assign_major_edge_roles!(
            edges,
            infer_major_edge_index(branch_roles),
        )
    end

    enforce_branch_role_annotations!(
        edges,
        edgekeys,
        branch_roles,
        child_nodekey,
    )
    return nothing
end

function ensure_shared_cursor_owner(
    parent_collection::AbstractVector{<:PhyloNetworksBuildCursor},
)::PhyloNetworksBuildCursor
    isempty(parent_collection) && throw(
        ArgumentError(
            "The PhyloNetworks extension requires at least one parent cursor for multi-parent construction.",
        ),
    )
    first_parent = first(parent_collection)
    for parent in Iterators.drop(parent_collection, 1)
        getfield(parent, :graph) === getfield(first_parent, :graph) || throw(
            ArgumentError(
                "The PhyloNetworks extension received parent cursors from different graph owners during one multi-parent construction event.",
            ),
        )
        getfield(parent, :state) === getfield(first_parent, :state) || throw(
            ArgumentError(
                "The PhyloNetworks extension received parent cursors with different build states during one multi-parent construction event.",
            ),
        )
    end
    return first_parent
end

function LineagesIO.has_custom_multi_parent_add_child(
    ::AbstractVector{<:PhyloNetworks.HybridNetwork},
    nodekey,
    label,
    edgekeys::AbstractVector,
    edgeweights::AbstractVector;
    edgedata,
    nodedata,
)::Bool
    return true
end

function LineagesIO.build_parent_collection(
    ::LineagesIO.NodeTypeLoadRequest{PhyloNetworks.HybridNetwork},
    parent_handles::AbstractVector,
)::AbstractVector
    all(parent_handle -> parent_handle isa PhyloNetworksBuildCursor, parent_handles) || throw(
        ArgumentError(
            "The `load(src, HybridNetwork)` surface received a parent handle that was not constructed by the PhyloNetworks extension.",
        ),
    )
    isempty(parent_handles) && return Any[]
    ParentHandleT = reduce(typejoin, map(typeof, parent_handles))
    return ParentHandleT[parent_handle for parent_handle in parent_handles]
end

function LineagesIO.add_child(
    parent_collection::AbstractVector{<:PhyloNetworksBuildCursor},
    nodekey::LineagesIO.StructureKeyType,
    label::AbstractString,
    edgekeys::AbstractVector{LineagesIO.StructureKeyType},
    edgeweights::AbstractVector{LineagesIO.EdgeWeightType};
    edgedata,
    nodedata,
)
    length(parent_collection) == 2 || throw(
        ArgumentError(
            "The PhyloNetworks extension supports hybrid nodes with exactly 2 parent edges, but nodekey $(nodekey) was scheduled with $(length(parent_collection)) parents.",
        ),
    )

    first_parent = ensure_shared_cursor_owner(parent_collection)
    state = getfield(first_parent, :state)
    ensure_edge_counts_initialized!(state, getfield(first(edgedata), :table))
    child_node = build_network_node(state, nodekey, label)
    register_node!(getfield(first_parent, :graph), state, nodekey, child_node)

    incoming_edges = PhyloNetworks.Edge[]
    incoming_edgekeys = LineagesIO.StructureKeyType[]
    major_index = infer_major_edge_index(
        [
            parse_retained_branch_role(
                edgekey,
                retained_edge_property_text(edge_rowref, :branch),
            ) for (edgekey, edge_rowref) in zip(edgekeys, edgedata)
        ],
    )
    for (index, (parent_cursor, edgekey, edgeweight)) in enumerate(
        zip(parent_collection, edgekeys, edgeweights),
    )
        edge = build_hybrid_edge(edgekey, edgeweight, index == major_index)
        attach_edge!(
            getfield(first_parent, :graph),
            state,
            edgekey,
            edge,
            getfield(parent_cursor, :node),
            child_node,
        )
        push!(incoming_edges, edge)
        push!(incoming_edgekeys, edgekey)
    end

    apply_hybrid_inheritance!(
        incoming_edges,
        incoming_edgekeys,
        edgedata,
        nodekey,
    )
    return child_cursor(first_parent, child_node, nodekey)
end

function normalize_singleton_basenode!(
    graph::PhyloNetworks.HybridNetwork,
)::Nothing
    getfield(graph, :numnodes) == 1 || return nothing
    getfield(graph, :numedges) == 0 || return nothing
    basenode = only(getfield(graph, :node))
    getfield(basenode, :leaf) && return nothing
    basenode.leaf = true
    graph.numtaxa = 1
    graph.leaf = PhyloNetworks.Node[basenode]
    return nothing
end

function copy_network_state!(
    target::PhyloNetworks.HybridNetwork,
    source::PhyloNetworks.HybridNetwork,
)::Nothing
    for fieldname in fieldnames(PhyloNetworks.HybridNetwork)
        setfield!(target, fieldname, getfield(source, fieldname))
    end
    return nothing
end

function LineagesIO.finalize_graph!(
    cursor::PhyloNetworksBuildCursor,
)
    graph = getfield(cursor, :graph)
    normalize_singleton_basenode!(graph)
    PhyloNetworks.storeHybrids!(graph)
    PhyloNetworks.checkNumHybEdges!(graph)
    PhyloNetworks.directedges!(graph; checkMajor = true)
    graph.isrooted = true

    target = getfield(cursor, :target)
    target === nothing && return graph

    # Commit only after a full upstream-valid network exists, so supplied-target
    # loads do not leak partial PhyloNetworks state on failure.
    copy_network_state!(target, graph)
    return target
end

LineagesIO.graph_from_finalized(net::HybridNetwork)::HybridNetwork = net

function LineagesIO.basenode_from_finalized(
    net::HybridNetwork,
)::PhyloNetworks.Node
    return net.node[net.rooti]
end

end
