const NETWORK_FIXTURE_EVENTS = Any[]
const NETWORK_BUILDER_EVENTS = Any[]

mutable struct FixtureNetworkNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    child_collection::Vector{FixtureNetworkNode}
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
    push!(NETWORK_FIXTURE_EVENTS, (:root, nodekey, String(label)))
    return FixtureNetworkNode(nodekey, String(label), FixtureNetworkNode[], false)
end

function LineagesIO.add_child(
    parent::FixtureNetworkNode,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata,
    nodedata,
)
    push!(NETWORK_FIXTURE_EVENTS, (:single, nodekey, parent.nodekey, edgekey))
    child = FixtureNetworkNode(nodekey, String(label), FixtureNetworkNode[], false)
    push!(parent.child_collection, child)
    return child
end

function LineagesIO.add_child(
    parent_collection::AbstractVector{FixtureNetworkNode},
    nodekey,
    label,
    edgekeys::AbstractVector{LineagesIO.StructureKeyType},
    edgeweights::AbstractVector;
    edgedata,
    nodedata,
)
    push!(NETWORK_FIXTURE_EVENTS, (:multi, nodekey, [parent.nodekey for parent in parent_collection], collect(edgekeys)))
    child = FixtureNetworkNode(nodekey, String(label), FixtureNetworkNode[], false)
    for parent in parent_collection
        push!(parent.child_collection, child)
    end
    return child
end

function LineagesIO.finalize_graph!(basenode::FixtureNetworkNode)
    push!(NETWORK_FIXTURE_EVENTS, (:finalize, basenode.nodekey))
    basenode.finalized = true
    return basenode
end

mutable struct PublicSingleParentOnlyNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    child_collection::Vector{PublicSingleParentOnlyNode}
end

@testset "Rooted-network-capable Newick tables and public loads" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    store = load(File{LineagesIO.NewickFormat}(fixture_path))
    asset = first(store.graphs)

    @test asset.graph === nothing
    @test asset.basenode === nothing
    @test Tables.columnnames(asset.node_table) == (:nodekey, :label, :posterior)
    @test Tables.columnnames(asset.edge_table) == (:edgekey, :src_nodekey, :dst_nodekey, :edgeweight, :phase, :branch, :gamma, :support)
    @test Tables.getcolumn(asset.node_table, :nodekey) == [1, 2, 3, 4, 5, 6, 7]
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Left", "A", "H1", "B", "Right", "C"]
    @test Tables.getcolumn(asset.node_table, :posterior) == ["0.99", nothing, "0.91", "0.44", nothing, nothing, nothing]
    @test Tables.getcolumn(asset.edge_table, :edgekey) == [1, 2, 3, 4, 5, 6, 7]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 2, 2, 4, 1, 6, 6]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4, 5, 6, 4, 7]
    @test Tables.getcolumn(asset.edge_table, :edgeweight) == Union{Nothing, Float64}[5.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0]
    @test Tables.getcolumn(asset.edge_table, :phase) == [nothing, "left", nothing, nothing, nothing, nothing, nothing]
    @test Tables.getcolumn(asset.edge_table, :support) == [nothing, nothing, "77", nothing, nothing, "55", nothing]
    @test Tables.getcolumn(asset.edge_table, :gamma) == [nothing, nothing, "0.8", nothing, nothing, "0.2", nothing]
    @test Tables.getcolumn(asset.edge_table, :branch) == [nothing, nothing, "major", nothing, nothing, "minor", nothing]

    empty!(NETWORK_FIXTURE_EVENTS)
    materialized_store = load(fixture_path, FixtureNetworkNode)
    materialized_asset = first(materialized_store.graphs)
    @test materialized_asset.graph === nothing
    basenode = materialized_asset.basenode
    @test basenode.finalized
    @test basenode.label == "Root"
    @test length(basenode.child_collection) == 2
    @test NETWORK_FIXTURE_EVENTS == Any[
        (:root, 1, "Root"),
        (:single, 2, 1, 1),
        (:single, 6, 1, 5),
        (:single, 3, 2, 2),
        (:multi, 4, [2, 6], [3, 6]),
        (:single, 7, 6, 7),
        (:single, 5, 4, 4),
        (:finalize, 1),
    ]
    left = basenode.child_collection[1]
    right = basenode.child_collection[2]
    hybrid_from_left = left.child_collection[2]
    hybrid_from_right = right.child_collection[1]
    @test hybrid_from_left === hybrid_from_right
    @test hybrid_from_left.label == "H1"
    @test hybrid_from_left.child_collection[1].label == "B"

    empty!(NETWORK_BUILDER_EVENTS)
    builder = function (parent, nodekey, label, edgekey_or_keys, edgeweight_or_weights; edgedata = nothing, nodedata)
        if parent === nothing
            push!(NETWORK_BUILDER_EVENTS, (:root, nodekey, String(label)))
            return FixtureNetworkNode(nodekey, String(label), FixtureNetworkNode[], false)
        elseif parent isa AbstractVector
            push!(NETWORK_BUILDER_EVENTS, (:multi, nodekey, [node.nodekey for node in parent], collect(edgekey_or_keys)))
            child = FixtureNetworkNode(nodekey, String(label), FixtureNetworkNode[], false)
            for parent_node in parent
                push!(parent_node.child_collection, child)
            end
            return child
        else
            push!(NETWORK_BUILDER_EVENTS, (:single, nodekey, parent.nodekey, edgekey_or_keys))
            child = FixtureNetworkNode(nodekey, String(label), FixtureNetworkNode[], false)
            push!(parent.child_collection, child)
            return child
        end
    end
    builder_store = load(fixture_path; builder = builder)
    builder_basenode = first(builder_store.graphs).basenode
    @test builder_basenode.label == "Root"
    @test (:multi, 4, [2, 6], [3, 6]) in NETWORK_BUILDER_EVENTS

    single_parent_target_error = capture_expected_load_error() do
        load(fixture_path, PublicSingleParentOnlyNode)
    end
    @test single_parent_target_error isa ArgumentError
    @test occursin("multi-parent `LineagesIO.add_child(parent_collection", sprint(showerror, single_parent_target_error))

    unmatched_path = abspath(joinpath(@__DIR__, "..", "fixtures", "invalid_network_unmatched_hybrid.nwk"))
    unmatched_error = capture_expected_load_error() do
        load(File{LineagesIO.NewickFormat}(unmatched_path))
    end
    @test unmatched_error isa ArgumentError
    @test occursin("Unmatched hybrid label", sprint(showerror, unmatched_error))

    repeated_internal_path = abspath(joinpath(@__DIR__, "..", "fixtures", "invalid_network_repeated_internal_hybrid.nwk"))
    repeated_internal_error = capture_expected_load_error() do
        load(File{LineagesIO.NewickFormat}(repeated_internal_path))
    end
    @test repeated_internal_error isa ArgumentError
    @test occursin("more than one occurrence lists descendants", sprint(showerror, repeated_internal_error))

    root_edge_path = abspath(joinpath(@__DIR__, "..", "fixtures", "invalid_network_basenode_edge_data.nwk"))
    root_edge_error = capture_expected_load_error() do
        load(File{LineagesIO.NewickFormat}(root_edge_path))
    end
    @test root_edge_error isa ArgumentError
    @test occursin("Incoming basenode edge", sprint(showerror, root_edge_error))
end
