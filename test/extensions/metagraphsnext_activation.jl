@testset "MetaGraphsNext extension activation before weakdep load" begin
    @test Base.get_extension(LineagesIO, :MetaGraphsNextIO) === nothing
    @test Base.get_extension(LineagesIO, :MetaGraphsNextAbstractTreesIO) === nothing

    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path)
    asset = first(store.graphs)

    @test asset.materialized === nothing
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]
end

using MetaGraphsNext

@testset "MetaGraphsNext extension activation after weakdep load" begin
    extension = Base.get_extension(LineagesIO, :MetaGraphsNextIO)

    @test extension !== nothing
    @test Base.get_extension(LineagesIO, :MetaGraphsNextAbstractTreesIO) === nothing

    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path, MetaGraphsNext.MetaGraph)
    asset = first(store.graphs)

    @test asset.materialized isa MetaGraphsNext.MetaGraph
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]

    parameterized_target_error = capture_expected_load_error() do
        load(fixture_path, typeof(asset.materialized))
    end
    @test parameterized_target_error isa ArgumentError
    @test occursin("construct an empty `MetaGraph` instance", sprint(showerror, parameterized_target_error))
end
