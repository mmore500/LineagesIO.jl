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

    parameterized_store = load(fixture_path, typeof(asset.materialized))
    parameterized_asset = first(parameterized_store.graphs)
    @test parameterized_asset.materialized isa MetaGraphsNext.MetaGraph
    @test MetaGraphsNext.Graphs.nv(parameterized_asset.materialized) == 5
    @test MetaGraphsNext.Graphs.ne(parameterized_asset.materialized) == 4
end
