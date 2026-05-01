@testset "MetaGraphsNext extension activation before weakdep load" begin
    @test Base.get_extension(LineagesIO, :MetaGraphsNextIO) === nothing
    @test Base.get_extension(LineagesIO, :MetaGraphsNextAbstractTreesIO) === nothing

    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path)
    asset = first(store.graphs)

    @test asset.graph === nothing
    @test asset.basenode === nothing
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

    @test asset.graph isa MetaGraphsNext.MetaGraph
    @test asset.basenode === Symbol(1)
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]

    parameterized_store = load(fixture_path, typeof(asset.graph))
    parameterized_asset = first(parameterized_store.graphs)
    @test parameterized_asset.graph isa MetaGraphsNext.MetaGraph
    @test parameterized_asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(parameterized_asset.graph) == 5
    @test MetaGraphsNext.Graphs.ne(parameterized_asset.graph) == 4
end
