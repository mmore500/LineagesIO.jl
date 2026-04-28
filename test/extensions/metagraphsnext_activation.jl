@testset "MetaGraphsNext extension activation before weakdep load" begin
    @test Base.get_extension(LineagesIO, :MetaGraphsNextIO) === nothing
    @test Base.get_extension(LineagesIO, :MetaGraphsNextAbstractTreesIO) === nothing

    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path)
    asset = first(store.graphs)

    @test asset.graph_rootnode === nothing
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]
end

using MetaGraphsNext

@testset "MetaGraphsNext extension activation after weakdep load" begin
    extension = Base.get_extension(LineagesIO, :MetaGraphsNextIO)

    @test extension !== nothing
    @test Base.get_extension(LineagesIO, :MetaGraphsNextAbstractTreesIO) === nothing

    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path, extension.MetaGraphsNextNodeHandle)
    asset = first(store.graphs)

    @test asset.graph_rootnode isa extension.MetaGraphsNextNodeHandle
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]
end
