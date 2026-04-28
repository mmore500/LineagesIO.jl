using MetaGraphsNext

@testset "MetaGraphsNext supplied-root binding" begin
    extension = something(Base.get_extension(LineagesIO, :MetaGraphsNextIO))
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))

    graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        extension.MetaGraphsNextNodeLabel,
        Nothing,
        Nothing,
    )
    store = load(fixture_path, graph)
    asset = first(store.graphs)

    @test asset.materialized === graph
    @test MetaGraphsNext.Graphs.nv(graph) == 5
    @test MetaGraphsNext.Graphs.ne(graph) == 4
    @test LineagesIO.node_property(asset.node_table, 1, :posterior) == "0.99"

    multi_graph_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_graph_root_binding_source.trees"))
    multi_graph_error = capture_expected_load_error() do
        load(multi_graph_path, extension.build_default_metagraph())
    end
    @test multi_graph_error isa ArgumentError
    @test occursin("exactly one graph", sprint(showerror, multi_graph_error))

    occupied_graph = extension.build_default_metagraph()
    MetaGraphsNext.Graphs.add_vertex!(
        occupied_graph,
        extension.MetaGraphsNextNodeLabel(999),
    )
    occupied_error = capture_expected_load_error() do
        load(fixture_path, occupied_graph)
    end
    @test occupied_error isa ArgumentError
    @test occursin("must be empty", sprint(showerror, occupied_error))

    wrong_label_graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        String,
        Nothing,
        Nothing,
    )
    wrong_label_error = capture_expected_load_error() do
        load(fixture_path, wrong_label_graph)
    end
    @test wrong_label_error isa ArgumentError
    @test occursin("must use `MetaGraphsNextNodeLabel`", sprint(showerror, wrong_label_error))
end
