using MetaGraphsNext

@testset "MetaGraphsNext rooted-network rejection" begin
    extension = something(Base.get_extension(LineagesIO, :MetaGraphsNextIO))
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))

    node_type_error = capture_expected_load_error() do
        load(fixture_path, MetaGraph)
    end
    @test node_type_error isa ArgumentError
    @test occursin("single-parent construction tier", sprint(showerror, node_type_error))

    graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        extension.MetaGraphsNextNodeLabel,
        Nothing,
        Nothing,
    )
    supplied_root_error = capture_expected_load_error() do
        load(fixture_path, graph)
    end
    @test supplied_root_error isa ArgumentError
    @test occursin("single-parent construction tier", sprint(showerror, supplied_root_error))
    @test MetaGraphsNext.Graphs.nv(graph) == 0
    @test MetaGraphsNext.Graphs.ne(graph) == 0
end
