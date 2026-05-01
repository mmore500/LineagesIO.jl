const SINGLE_PARENT_PROTOCOL_EVENTS = Any[]

mutable struct SingleParentProtocolNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    posterior::Union{Nothing, String}
    incoming_edgekey::Union{Nothing, LineagesIO.StructureKeyType}
    incoming_edgeweight::Union{Nothing, Float64}
    incoming_bootstrap::Union{Nothing, String}
    child_collection::Vector{SingleParentProtocolNode}
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
    posterior = node_property(nodedata, :posterior)
    push!(SINGLE_PARENT_PROTOCOL_EVENTS, (:root, nodekey, edgekey, String(label), posterior, nothing, edgeweight))
    return SingleParentProtocolNode(nodekey, String(label), posterior, nothing, nothing, nothing, SingleParentProtocolNode[], false)
end

function LineagesIO.add_child(
    parent::SingleParentProtocolNode,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata,
    nodedata,
)
    posterior = node_property(nodedata, :posterior)
    bootstrap = edge_property(edgedata, :bootstrap)
    push!(SINGLE_PARENT_PROTOCOL_EVENTS, (:child, nodekey, edgekey, String(label), posterior, bootstrap, edgeweight))
    child = SingleParentProtocolNode(
        nodekey,
        String(label),
        posterior,
        edgekey,
        edgeweight,
        bootstrap,
        SingleParentProtocolNode[],
        false,
    )
    push!(parent.child_collection, child)
    return child
end

function LineagesIO.finalize_graph!(basenode::SingleParentProtocolNode)
    push!(SINGLE_PARENT_PROTOCOL_EVENTS, (:finalize, basenode.nodekey, nothing, basenode.label, basenode.posterior, nothing, nothing))
    basenode.finalized = true
    return basenode
end

@testset "Single-parent construction protocol" begin
    empty!(SINGLE_PARENT_PROTOCOL_EVENTS)
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    store = load(fixture_path, SingleParentProtocolNode)
    asset = first(store.graphs)
    basenode = asset.basenode

    @test asset.graph === nothing
    @test basenode isa SingleParentProtocolNode
    @test basenode.finalized
    @test basenode.nodekey == 1
    @test basenode.label == "Root"
    @test basenode.posterior == "0.99"
    @test length(basenode.child_collection) == 2

    inner = basenode.child_collection[1]
    right = basenode.child_collection[2]
    @test inner.nodekey == 2
    @test inner.label == "Inner"
    @test inner.posterior == "0.81"
    @test inner.incoming_edgekey == 1
    @test inner.incoming_edgeweight == 2.0
    @test inner.incoming_bootstrap == "77"
    @test right.nodekey == 5
    @test right.label == "C"
    @test right.posterior == "0.73"
    @test right.incoming_edgekey == 4
    @test right.incoming_bootstrap === nothing

    left_leaf = inner.child_collection[1]
    unlabeled_leaf = inner.child_collection[2]
    @test left_leaf.nodekey == 3
    @test left_leaf.label == "A"
    @test left_leaf.posterior == "0.91"
    @test left_leaf.incoming_edgekey == 2
    @test left_leaf.incoming_edgeweight == 1.5
    @test left_leaf.incoming_bootstrap == "97"
    @test unlabeled_leaf.nodekey == 4
    @test unlabeled_leaf.label == ""
    @test unlabeled_leaf.posterior == "0.52"
    @test unlabeled_leaf.incoming_edgekey == 3
    @test unlabeled_leaf.incoming_edgeweight == 0.25
    @test unlabeled_leaf.incoming_bootstrap == "88"

    @test SINGLE_PARENT_PROTOCOL_EVENTS == Any[
        (:root, 1, nothing, "Root", "0.99", nothing, nothing),
        (:child, 2, 1, "Inner", "0.81", "77", 2.0),
        (:child, 3, 2, "A", "0.91", "97", 1.5),
        (:child, 4, 3, "", "0.52", "88", 0.25),
        (:child, 5, 4, "C", "0.73", nothing, nothing),
        (:finalize, 1, nothing, "Root", "0.99", nothing, nothing),
    ]

    @test LineagesIO.basenode(asset) === asset.basenode
    @test LineagesIO.basenode(asset) isa SingleParentProtocolNode
end

@testset "LineageGraphAsset destructuring" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))

    materialized_store = load(fixture_path, SingleParentProtocolNode)
    materialized_asset = first(materialized_store.graphs)

    graph, basenode, node_table, edge_table = materialized_asset
    @test graph === materialized_asset.graph
    @test basenode === materialized_asset.basenode
    @test node_table === materialized_asset.node_table
    @test edge_table === materialized_asset.edge_table
    @test length(materialized_asset) == 4

    graph_only, basenode_only, _, _ = materialized_asset
    @test graph_only === materialized_asset.graph
    @test basenode_only === materialized_asset.basenode

    _, _, materialized_node_table, materialized_edge_table = materialized_asset
    @test materialized_node_table === materialized_asset.node_table
    @test materialized_edge_table === materialized_asset.edge_table

    iteration_count = 0
    for (graph, basenode, node_table, edge_table) in materialized_store.graphs
        @test graph === materialized_asset.graph
        @test basenode === materialized_asset.basenode
        @test node_table === materialized_asset.node_table
        @test edge_table === materialized_asset.edge_table
        iteration_count += 1
    end
    @test iteration_count == length(materialized_store.graphs)

    tables_only_store = load(fixture_path)
    tables_only_asset = first(tables_only_store.graphs)

    graph, basenode, node_table, edge_table = tables_only_asset
    @test graph === nothing
    @test basenode === nothing
    @test node_table === tables_only_asset.node_table
    @test edge_table === tables_only_asset.edge_table
    @test length(tables_only_asset) == 4

    _, _, tables_only_node_table, tables_only_edge_table = tables_only_asset
    @test tables_only_node_table === tables_only_asset.node_table
    @test tables_only_edge_table === tables_only_asset.edge_table
end
