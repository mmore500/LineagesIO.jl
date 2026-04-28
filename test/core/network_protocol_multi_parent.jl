function synthetic_network_asset_for_protocol()
    node_table = LineagesIO.NodeTable(
        nodekey = [1, 2, 3, 4, 5],
        label = ["Root", "Left", "Right", "Hybrid", "Leaf"],
        annotation_columns = (
            posterior = ["0.99", "0.81", "0.73", "0.44", "0.52"],
        ),
    )
    edge_table = LineagesIO.EdgeTable(
        edgekey = [1, 2, 3, 4, 5],
        src_nodekey = [1, 1, 2, 3, 4],
        dst_nodekey = [2, 3, 4, 4, 5],
        edgeweight = [2.0, 1.0, 0.8, 0.2, 0.5],
        annotation_columns = (
            kind = [nothing, nothing, "major", "minor", nothing],
        ),
    )
    return LineagesIO.LineageGraphAsset(
        1,
        1,
        1,
        1,
        nothing,
        nothing,
        node_table,
        edge_table,
        nothing,
        nothing,
    )
end

function synthetic_tree_asset_for_protocol()
    node_table = LineagesIO.NodeTable(
        nodekey = [1, 2, 3],
        label = ["Root", "Left", "Right"],
        annotation_columns = (
            posterior = ["0.99", "0.81", "0.73"],
        ),
    )
    edge_table = LineagesIO.EdgeTable(
        edgekey = [1, 2],
        src_nodekey = [1, 1],
        dst_nodekey = [2, 3],
        edgeweight = [2.0, nothing],
        annotation_columns = (
            kind = [nothing, nothing],
        ),
    )
    return LineagesIO.LineageGraphAsset(
        1,
        1,
        1,
        1,
        nothing,
        nothing,
        node_table,
        edge_table,
        nothing,
        nothing,
    )
end

function synthetic_impossible_network_asset()
    node_table = LineagesIO.NodeTable(
        nodekey = [1, 2, 3],
        label = ["Root", "Hybrid", "Parent"],
        annotation_columns = (
            posterior = ["0.99", "0.44", "0.73"],
        ),
    )
    edge_table = LineagesIO.EdgeTable(
        edgekey = [1, 2, 3],
        src_nodekey = [1, 2, 3],
        dst_nodekey = [2, 3, 2],
        edgeweight = [1.0, 1.0, 1.0],
    )
    return LineagesIO.LineageGraphAsset(
        1,
        1,
        1,
        1,
        nothing,
        nothing,
        node_table,
        edge_table,
        nothing,
        nothing,
    )
end

const MULTI_PARENT_PROTOCOL_EVENTS = Any[]

mutable struct SchedulerProtocolNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    child_collection::Vector{SchedulerProtocolNode}
    finalized::Bool
end

function LineagesIO.add_child(
    ::Nothing,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata = nothing,
    nodedata,
)
    push!(MULTI_PARENT_PROTOCOL_EVENTS, (:root, nodekey, String(label), LineagesIO.node_property(nodedata, :posterior)))
    return SchedulerProtocolNode(nodekey, String(label), SchedulerProtocolNode[], false)
end

function LineagesIO.add_child(
    parent::SchedulerProtocolNode,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata,
    nodedata,
)
    push!(
        MULTI_PARENT_PROTOCOL_EVENTS,
        (
            :single,
            nodekey,
            parent.nodekey,
            edgekey,
            edgeweight,
            edgedata.edgekey,
            LineagesIO.edge_property(edgedata, :kind),
            LineagesIO.node_property(nodedata, :posterior),
        ),
    )
    child = SchedulerProtocolNode(nodekey, String(label), SchedulerProtocolNode[], false)
    push!(parent.child_collection, child)
    return child
end

function LineagesIO.add_child(
    parent_collection::AbstractVector{SchedulerProtocolNode},
    nodekey,
    label,
    edgekeys::AbstractVector{LineagesIO.StructureKeyType},
    edgeweights::AbstractVector;
    edgedata,
    nodedata,
)
    push!(
        MULTI_PARENT_PROTOCOL_EVENTS,
        (
            :multi,
            nodekey,
            [parent.nodekey for parent in parent_collection],
            collect(edgekeys),
            collect(edgeweights),
            [rowref.edgekey for rowref in edgedata],
            [LineagesIO.edge_property(rowref, :kind) for rowref in edgedata],
            LineagesIO.node_property(nodedata, :posterior),
        ),
    )
    child = SchedulerProtocolNode(nodekey, String(label), SchedulerProtocolNode[], false)
    for parent in parent_collection
        push!(parent.child_collection, child)
    end
    return child
end

function LineagesIO.finalize_graph!(rootnode::SchedulerProtocolNode)
    push!(MULTI_PARENT_PROTOCOL_EVENTS, (:finalize, rootnode.nodekey))
    rootnode.finalized = true
    return rootnode
end

@testset "Multi-parent scheduler behavior" begin
    empty!(MULTI_PARENT_PROTOCOL_EVENTS)
    network_asset = synthetic_network_asset_for_protocol()
    materialized_asset = LineagesIO.materialize_graph(
        network_asset,
        LineagesIO.NodeTypeLoadRequest(SchedulerProtocolNode),
    )
    @test materialized_asset.materialized.finalized
    @test MULTI_PARENT_PROTOCOL_EVENTS == Any[
        (:root, 1, "Root", "0.99"),
        (:single, 2, 1, 1, 2.0, 1, nothing, "0.81"),
        (:single, 3, 1, 2, 1.0, 2, nothing, "0.73"),
        (:multi, 4, [2, 3], [3, 4], [0.8, 0.2], [3, 4], ["major", "minor"], "0.44"),
        (:single, 5, 4, 5, 0.5, 5, nothing, "0.52"),
        (:finalize, 1),
    ]

    empty!(MULTI_PARENT_PROTOCOL_EVENTS)
    tree_asset = synthetic_tree_asset_for_protocol()
    tree_materialized = LineagesIO.materialize_graph(
        tree_asset,
        LineagesIO.NodeTypeLoadRequest(SchedulerProtocolNode),
    )
    @test tree_materialized.materialized.finalized
    @test MULTI_PARENT_PROTOCOL_EVENTS == Any[
        (:root, 1, "Root", "0.99"),
        (:single, 2, 1, 1, 2.0, 1, nothing, "0.81"),
        (:single, 3, 1, 2, nothing, 2, nothing, "0.73"),
        (:finalize, 1),
    ]

    impossible_error = capture_expected_load_error() do
        LineagesIO.materialize_graph(
            synthetic_impossible_network_asset(),
            LineagesIO.NodeTypeLoadRequest(SchedulerProtocolNode),
        )
    end
    @test impossible_error isa ArgumentError
    @test occursin("impossible rooted-network parent schedule", sprint(showerror, impossible_error))
end
