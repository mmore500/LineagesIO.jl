using PhyloNetworks

@testset "PhyloNetworks loads preserve authoritative tables" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    store = load(fixture_path, PhyloNetworks.HybridNetwork)
    asset = first(store.graphs)

    @test asset.materialized isa PhyloNetworks.HybridNetwork
    @test Tables.columnnames(asset.node_table) == (:nodekey, :label, :posterior)
    @test Tables.columnnames(asset.edge_table) == (:edgekey, :src_nodekey, :dst_nodekey, :edgeweight, :phase, :branch, :gamma, :support)
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Left", "A", "H1", "B", "Right", "C"]
    @test Tables.getcolumn(asset.edge_table, :edgekey) == [1, 2, 3, 4, 5, 6, 7]
    @test LineagesIO.node_property(asset.node_table, 4, :posterior) == "0.44"
    @test LineagesIO.edge_property(asset.edge_table, 3, :gamma) == "0.8"
    @test LineagesIO.edge_property(asset.edge_table, 6, :branch) == "minor"
end
