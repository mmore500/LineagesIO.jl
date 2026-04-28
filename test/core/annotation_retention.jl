@testset "Simple rooted Newick annotation retention" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    store = load(fixture_path)
    asset = first(store.graphs)

    @test asset.graph_rootnode === nothing
    @test Tables.columnnames(asset.node_table) == (:nodekey, :label, :posterior)
    @test Tables.columnnames(asset.edge_table) == (:edgekey, :src_nodekey, :dst_nodekey, :edgeweight, :bootstrap, :phase)
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]
    @test Tables.getcolumn(asset.node_table, :posterior) == Union{Nothing, String}["0.99", "0.81", "0.91", "0.52", "0.73"]
    @test Tables.getcolumn(asset.edge_table, :edgeweight) == Union{Nothing, Float64}[2.0, 1.5, 0.25, nothing]
    @test Tables.getcolumn(asset.edge_table, :bootstrap) == Union{Nothing, String}["77", "97", "88", nothing]
    @test Tables.getcolumn(asset.edge_table, :phase) == Union{Nothing, String}[nothing, "left", nothing, nothing]

    invalid_fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "invalid_annotation_structured.nwk"))
    invalid_error = capture_expected_load_error() do
        load(invalid_fixture_path)
    end
    @test invalid_error isa ArgumentError
    @test occursin("structured retained node annotation values", sprint(showerror, invalid_error))
    @test occursin("line 1, column", sprint(showerror, invalid_error))
end
