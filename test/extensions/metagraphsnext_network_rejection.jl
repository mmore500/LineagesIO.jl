using MetaGraphsNext

@testset "MetaGraphsNext multi-parent network loading" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))

    node_type_error = capture_expected_load_error() do
        load(fixture_path, MetaGraph)
    end
    @test node_type_error isa ArgumentError
    @test occursin("multi-parent", sprint(showerror, node_type_error))

    graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        Nothing,
        Nothing,
    )
    store = load(fixture_path, graph)
    asset = first(store.graphs)

    @test asset.graph === graph
    @test asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(graph) == 7
    @test MetaGraphsNext.Graphs.ne(graph) == 7
end
