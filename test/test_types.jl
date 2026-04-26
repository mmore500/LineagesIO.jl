using LineagesIO: LineageGraphAsset, LineageGraphStore
using Tables: Tables
using Test: @test, @testset, @inferred

function asset_rootnode(
    asset::LineageGraphAsset{NodeT, NodeTableT, EdgeTableT},
)::NodeT where {NodeT, NodeTableT, EdgeTableT}
    return asset.graph_rootnode
end

function store_graphs(
    store::LineageGraphStore{NodeT, SourceTableT, CollectionTableT, GraphTableT, GraphsT},
)::GraphsT where {NodeT, SourceTableT, CollectionTableT, GraphTableT, GraphsT}
    return store.graphs
end

@testset "types" begin
    struct MyTestNode
        node_idx::Int
        label::String
    end

    node_table = (
        node_idx = [1, 2],
        label = ["root", "leaf"],
    )
    edge_table = (
        src_node_idx = [1],
        dst_node_idx = [2],
        edgeweight = Union{Float64, Nothing}[1.0],
    )
    source_table = (
        source_idx = [1],
        source_path = Union{String, Nothing}["example.nwk"],
    )
    collection_table = (
        source_idx = [1],
        collection_idx = [1],
        label = Union{String, Nothing}["collection"],
        graph_count = [1],
    )
    graph_table = (
        index = [1],
        source_idx = [1],
        collection_idx = [1],
        collection_graph_idx = [1],
        collection_label = Union{String, Nothing}["collection"],
        graph_label = Union{String, Nothing}["graph"],
        source_path = Union{String, Nothing}["example.nwk"],
    )
    rootnode = MyTestNode(1, "root")

    asset = LineageGraphAsset{MyTestNode}(
        1,
        1,
        1,
        1,
        "collection",
        "graph",
        node_table,
        edge_table,
        rootnode,
        "example.nwk",
    )

    @test asset isa LineageGraphAsset{MyTestNode}
    @test (@inferred asset_rootnode(asset)) === rootnode
    @test Tables.istable(asset.node_table)
    @test Tables.istable(asset.edge_table)

    graphs = (graph for graph in (asset,))
    store = LineageGraphStore{MyTestNode}(
        source_table,
        collection_table,
        graph_table,
        graphs,
    )

    @test store isa LineageGraphStore{MyTestNode}
    @test Tables.istable(store.source_table)
    @test Tables.istable(store.collection_table)
    @test Tables.istable(store.graph_table)
    @test collect(store.graphs)[1] === asset
    @test (@inferred store_graphs(store)) isa typeof(graphs)
end
