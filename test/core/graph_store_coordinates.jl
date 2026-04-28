@testset "Graph store coordinates" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_graph_source.trees"))
    store = load(File{LineagesIO.NewickFormat}(fixture_path))

    @test Tables.getcolumn(store.source_table, :source_idx) == [1]
    @test Tables.getcolumn(store.source_table, :source_path) == Union{Nothing, String}[fixture_path]
    @test Tables.getcolumn(store.source_table, :graph_count) == [2]
    @test Tables.getcolumn(store.collection_table, :collection_idx) == [1]
    @test Tables.getcolumn(store.collection_table, :graph_count) == [2]
    @test Tables.getcolumn(store.graph_table, :index) == [1, 2]
    @test Tables.getcolumn(store.graph_table, :source_idx) == [1, 1]
    @test Tables.getcolumn(store.graph_table, :collection_idx) == [1, 1]
    @test Tables.getcolumn(store.graph_table, :collection_graph_idx) == [1, 2]
    @test Tables.getcolumn(store.graph_table, :node_count) == [3, 5]
    @test Tables.getcolumn(store.graph_table, :edge_count) == [2, 4]

    first_state = iterate(store.graphs)
    @test first_state !== nothing
    first_asset, next_state = first_state
    second_state = iterate(store.graphs, next_state)
    @test second_state !== nothing
    second_asset, final_state = second_state
    @test iterate(store.graphs, final_state) === nothing

    @test first_asset.index == 1
    @test first_asset.source_idx == 1
    @test first_asset.collection_idx == 1
    @test first_asset.collection_graph_idx == 1
    @test first_asset.source_path == fixture_path
    @test first_asset.materialized === nothing
    @test Tables.getcolumn(first_asset.node_table, :label) == ["", "Alpha", "Beta"]

    @test second_asset.index == 2
    @test second_asset.source_idx == 1
    @test second_asset.collection_idx == 1
    @test second_asset.collection_graph_idx == 2
    @test second_asset.source_path == fixture_path
    @test second_asset.materialized === nothing
    @test Tables.getcolumn(second_asset.node_table, :label) == ["", "Inner", "Gamma", "Delta", "Epsilon"]
end
