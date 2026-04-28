using MetaGraphsNext

@testset "MetaGraphsNext loads preserve authoritative tables" begin
    extension = something(Base.get_extension(LineagesIO, :MetaGraphsNextIO))
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    store = load(fixture_path, extension.MetaGraphsNextNodeHandle)
    asset = first(store.graphs)
    rootnode = asset.graph_rootnode

    @test asset.node_table isa LineagesIO.NodeTable
    @test asset.edge_table isa LineagesIO.EdgeTable
    @test rootnode.nodekey == 1
    @test LineagesIO.node_property(asset.node_table, rootnode.nodekey, :posterior) == "0.99"
    @test LineagesIO.node_property(asset.node_table, 4, :posterior) == "0.52"
    @test LineagesIO.edge_property(asset.edge_table, 2, :bootstrap) == "97"
    @test LineagesIO.edge_property(asset.edge_table, 2, :phase) == "left"
    @test Tables.getcolumn(asset.node_table, :posterior) == Union{Nothing, String}["0.99", "0.81", "0.91", "0.52", "0.73"]
    @test Tables.getcolumn(asset.edge_table, :edgeweight) == Union{Nothing, Float64}[2.0, 1.5, 0.25, nothing]
end
