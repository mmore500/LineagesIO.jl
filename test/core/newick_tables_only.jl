@testset "Simple rooted Newick tables-only parsing" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(File{LineagesIO.NewickFormat}(fixture_path))
    asset = first(store.graphs)

    @test asset.materialized === nothing
    @test asset.source_path == fixture_path
    @test asset.collection_label === nothing
    @test asset.graph_label === nothing

    @test Tables.columnnames(asset.node_table) == (:nodekey, :label)
    @test Tables.columnnames(asset.edge_table) == (:edgekey, :src_nodekey, :dst_nodekey, :edgeweight)
    @test Tables.getcolumn(asset.node_table, :nodekey) == [1, 2, 3, 4, 5]
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]
    @test Tables.getcolumn(asset.edge_table, :edgekey) == [1, 2, 3, 4]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 2, 2, 1]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4, 5]
    @test Tables.getcolumn(asset.edge_table, :edgeweight) == Union{Nothing, Float64}[2.0, 1.5, 0.25, nothing]

    @test node_property(asset.node_table, 4, :label) == ""
    @test edge_property(asset.edge_table, 3, :edgeweight) == 0.25
    @test edge_property(asset.edge_table, 4, :edgeweight) === nothing
end
