@testset "Rooted-network annotation retention" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    store = load(File{LineagesIO.NewickFormat}(fixture_path))
    asset = first(store.graphs)

    @test node_property(asset.node_table, 1, :posterior) == "0.99"
    @test node_property(asset.node_table, 3, :posterior) == "0.91"
    @test node_property(asset.node_table, 4, :posterior) == "0.44"

    @test edge_property(asset.edge_table, 2, :phase) == "left"
    @test edge_property(asset.edge_table, 3, :support) == "77"
    @test edge_property(asset.edge_table, 3, :gamma) == "0.8"
    @test edge_property(asset.edge_table, 3, :branch) == "major"
    @test edge_property(asset.edge_table, 6, :support) == "55"
    @test edge_property(asset.edge_table, 6, :gamma) == "0.2"
    @test edge_property(asset.edge_table, 6, :branch) == "minor"

    @test parse(Float64, edge_property(asset.edge_table, 3, :gamma)) == 0.8
    @test parse(Float64, edge_property(asset.edge_table, 6, :gamma)) == 0.2
end
